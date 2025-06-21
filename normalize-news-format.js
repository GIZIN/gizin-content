#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// gizin-contentのパス
const CONTENT_DIR = __dirname;  // 現在のディレクトリがgizin-content
const NEWS_DIR = path.join(CONTENT_DIR, 'news/articles');
const BACKUP_DIR = path.join(CONTENT_DIR, 'news/articles.backup');

// 統一されたNews記事の形式
// この形式に全てのNews記事を変換します
const UNIFIED_FORMAT = {
  id: '',
  date: '',
  category: '',
  featured: false,
  tags: [],
  versions: {
    ja: {
      title: '',
      description: '',
      content: ''
    },
    en: {
      title: '',
      description: '',
      content: ''
    }
  }
};

// 色付きログ
const log = {
  info: (msg) => console.log(`\x1b[36m${msg}\x1b[0m`),
  success: (msg) => console.log(`\x1b[32m✓ ${msg}\x1b[0m`),
  error: (msg) => console.log(`\x1b[31m✗ ${msg}\x1b[0m`),
  warning: (msg) => console.log(`\x1b[33m⚠ ${msg}\x1b[0m`)
};

// バックアップディレクトリを作成
function createBackup() {
  if (fs.existsSync(BACKUP_DIR)) {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const newBackupDir = `${BACKUP_DIR}-${timestamp}`;
    fs.renameSync(BACKUP_DIR, newBackupDir);
    log.info(`既存のバックアップを ${newBackupDir} に移動しました`);
  }
  
  fs.mkdirSync(BACKUP_DIR, { recursive: true });
  
  // 全ファイルをバックアップ
  const files = fs.readdirSync(NEWS_DIR);
  files.forEach(file => {
    if (file.endsWith('.json')) {
      fs.copyFileSync(
        path.join(NEWS_DIR, file),
        path.join(BACKUP_DIR, file)
      );
    }
  });
  
  log.success(`${files.length}個のファイルをバックアップしました`);
}

// データ形式を判定
function detectFormat(data) {
  if (data.versions) {
    return 'unified'; // 既に統一形式
  } else if (data.title && typeof data.title === 'object' && (data.title.ja || data.title.en)) {
    return 'multi-lang'; // 多言語オブジェクト形式
  } else if (data.title && typeof data.title === 'string') {
    return 'simple'; // 単純な文字列形式
  } else {
    return 'unknown';
  }
}

// データを統一形式に変換
function convertToUnifiedFormat(data, format) {
  const unified = JSON.parse(JSON.stringify(UNIFIED_FORMAT));
  
  // 共通フィールド
  unified.id = data.id || '';
  unified.date = data.date || '';
  unified.category = data.category || 'general';
  unified.featured = data.featured || false;
  
  // タグの処理
  if (data.tags) {
    if (Array.isArray(data.tags)) {
      unified.tags = data.tags;
    } else if (typeof data.tags === 'object' && (data.tags.ja || data.tags.en)) {
      unified.tags = data.tags.ja || data.tags.en || [];
    }
  }
  
  // 画像がある場合は追加
  if (data.image) {
    unified.image = data.image;
  }
  
  // 形式に応じた変換
  switch (format) {
    case 'unified':
      // 既に統一形式なのでそのまま返す
      return data;
      
    case 'multi-lang':
      // 多言語オブジェクト形式からの変換
      unified.versions.ja.title = data.title?.ja || data.title || '';
      unified.versions.ja.description = data.excerpt?.ja || data.description?.ja || '';
      unified.versions.ja.content = data.content?.ja || '';
      
      unified.versions.en.title = data.title?.en || data.title?.ja || data.title || '';
      unified.versions.en.description = data.excerpt?.en || data.description?.en || data.excerpt?.ja || '';
      unified.versions.en.content = data.content?.en || data.content?.ja || '';
      break;
      
    case 'simple':
      // 単純な文字列形式からの変換（日本語のみと仮定）
      unified.versions.ja.title = data.title || '';
      unified.versions.ja.description = data.excerpt || data.description || '';
      unified.versions.ja.content = data.content || '';
      
      // 英語版は日本語と同じ内容
      unified.versions.en.title = data.title || '';
      unified.versions.en.description = data.excerpt || data.description || '';
      unified.versions.en.content = data.content || '';
      break;
      
    default:
      log.warning(`不明な形式のデータ: ${data.id}`);
      return null;
  }
  
  return unified;
}

// メイン処理
async function main() {
  log.info('News記事の形式統一を開始します...\n');
  
  // バックアップを作成
  createBackup();
  
  // 記事ファイルを処理
  const files = fs.readdirSync(NEWS_DIR).filter(f => f.endsWith('.json'));
  const stats = {
    total: files.length,
    unified: 0,
    converted: 0,
    errors: 0
  };
  
  for (const file of files) {
    const filePath = path.join(NEWS_DIR, file);
    
    try {
      // ファイルを読み込み
      const content = fs.readFileSync(filePath, 'utf-8');
      const data = JSON.parse(content);
      
      // 形式を判定
      const format = detectFormat(data);
      
      if (format === 'unified') {
        stats.unified++;
        log.info(`✓ ${file} - 既に統一形式です`);
        continue;
      }
      
      // 変換
      const unified = convertToUnifiedFormat(data, format);
      
      if (!unified) {
        stats.errors++;
        log.error(`${file} - 変換に失敗しました`);
        continue;
      }
      
      // ファイルに書き戻し
      fs.writeFileSync(filePath, JSON.stringify(unified, null, 2));
      stats.converted++;
      log.success(`${file} - ${format} → unified に変換しました`);
      
    } catch (error) {
      stats.errors++;
      log.error(`${file} - エラー: ${error.message}`);
    }
  }
  
  // 統計を表示
  console.log('\n' + '='.repeat(50));
  log.info('変換結果:');
  console.log(`  総ファイル数: ${stats.total}`);
  console.log(`  既に統一形式: ${stats.unified}`);
  console.log(`  変換成功: ${stats.converted}`);
  console.log(`  エラー: ${stats.errors}`);
  console.log('='.repeat(50) + '\n');
  
  if (stats.errors === 0) {
    log.success('すべての記事を統一形式に変換しました！');
    log.info('\n次のステップ:');
    log.info('1. gizin-contentディレクトリで以下を実行:');
    log.info('   ./update-index.sh --news');
    log.info('2. 変換結果を確認');
    log.info('3. 問題なければコミット＆プッシュ');
  } else {
    log.warning('一部のファイルで変換エラーが発生しました');
    log.info(`バックアップは ${BACKUP_DIR} にあります`);
  }
}

// 実行
if (require.main === module) {
  main().catch(error => {
    log.error(`エラーが発生しました: ${error.message}`);
    process.exit(1);
  });
}