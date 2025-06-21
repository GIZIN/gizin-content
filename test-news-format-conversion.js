#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// テスト用のサンプルデータ
const testCases = [
  {
    name: '統一形式（変更なし）',
    input: {
      id: 'test-unified',
      date: '2024-01-01',
      category: 'announcement',
      featured: false,
      tags: ['test'],
      versions: {
        ja: {
          title: '統一形式のテスト',
          description: '説明文',
          content: '本文'
        },
        en: {
          title: 'Unified Format Test',
          description: 'Description',
          content: 'Content'
        }
      }
    }
  },
  {
    name: '多言語オブジェクト形式',
    input: {
      id: 'test-multilang',
      date: '2024-01-02',
      category: 'update',
      title: {
        ja: '多言語タイトル',
        en: 'Multilingual Title'
      },
      excerpt: {
        ja: '多言語抜粋',
        en: 'Multilingual Excerpt'
      },
      content: {
        ja: '多言語本文',
        en: 'Multilingual Content'
      }
    }
  },
  {
    name: '単純文字列形式',
    input: {
      id: 'test-simple',
      date: '2024-01-03',
      category: 'general',
      title: 'シンプルなタイトル',
      excerpt: 'シンプルな抜粋',
      content: 'シンプルな本文'
    }
  },
  {
    name: 'タグが多言語オブジェクトの場合',
    input: {
      id: 'test-tags',
      date: '2024-01-04',
      category: 'case-study',
      title: {
        ja: 'タグテスト',
        en: 'Tag Test'
      },
      excerpt: {
        ja: '説明',
        en: 'Description'
      },
      tags: {
        ja: ['タグ1', 'タグ2'],
        en: ['tag1', 'tag2']
      }
    }
  }
];

// 変換関数（normalize-news-format.jsから抜粋）
function detectFormat(data) {
  if (data.versions) {
    return 'unified';
  } else if (data.title && typeof data.title === 'object' && (data.title.ja || data.title.en)) {
    return 'multi-lang';
  } else if (data.title && typeof data.title === 'string') {
    return 'simple';
  } else {
    return 'unknown';
  }
}

function convertToUnifiedFormat(data, format) {
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
      return data;
      
    case 'multi-lang':
      unified.versions.ja.title = data.title?.ja || data.title || '';
      unified.versions.ja.description = data.excerpt?.ja || data.description?.ja || '';
      unified.versions.ja.content = data.content?.ja || '';
      
      unified.versions.en.title = data.title?.en || data.title?.ja || data.title || '';
      unified.versions.en.description = data.excerpt?.en || data.description?.en || data.excerpt?.ja || '';
      unified.versions.en.content = data.content?.en || data.content?.ja || '';
      break;
      
    case 'simple':
      unified.versions.ja.title = data.title || '';
      unified.versions.ja.description = data.excerpt || data.description || '';
      unified.versions.ja.content = data.content || '';
      
      unified.versions.en.title = data.title || '';
      unified.versions.en.description = data.excerpt || data.description || '';
      unified.versions.en.content = data.content || '';
      break;
      
    default:
      console.log(`不明な形式のデータ: ${data.id}`);
      return null;
  }
  
  return unified;
}

// テスト実行
console.log('News形式変換のテストを開始します...\n');

let passCount = 0;
let failCount = 0;

testCases.forEach((testCase, index) => {
  console.log(`\nテスト ${index + 1}: ${testCase.name}`);
  console.log('入力:', JSON.stringify(testCase.input, null, 2).substring(0, 200) + '...');
  
  try {
    const format = detectFormat(testCase.input);
    console.log(`検出された形式: ${format}`);
    
    const result = convertToUnifiedFormat(testCase.input, format);
    
    if (!result) {
      console.log('❌ 変換失敗');
      failCount++;
      return;
    }
    
    // 検証
    const hasRequiredFields = 
      result.id && 
      result.date && 
      result.category &&
      result.versions &&
      result.versions.ja &&
      result.versions.en &&
      result.versions.ja.title &&
      result.versions.ja.description !== undefined &&
      result.versions.ja.content !== undefined;
    
    if (hasRequiredFields) {
      console.log('✅ 変換成功');
      console.log('出力:', JSON.stringify(result, null, 2).substring(0, 200) + '...');
      passCount++;
    } else {
      console.log('❌ 必須フィールドが不足');
      failCount++;
    }
  } catch (error) {
    console.log('❌ エラー:', error.message);
    failCount++;
  }
});

console.log('\n' + '='.repeat(50));
console.log(`テスト結果: ${passCount} 成功 / ${failCount} 失敗`);
console.log('='.repeat(50));

// 実際のファイルを1つテスト（読み取りのみ）
const CONTENT_DIR = path.join(__dirname, '../../gizin-content');
const NEWS_DIR = path.join(CONTENT_DIR, 'news/articles');

if (fs.existsSync(NEWS_DIR)) {
  console.log('\n実際のファイルでテスト（読み取りのみ）:');
  const files = fs.readdirSync(NEWS_DIR).filter(f => f.endsWith('.json')).slice(0, 3);
  
  files.forEach(file => {
    try {
      const content = fs.readFileSync(path.join(NEWS_DIR, file), 'utf-8');
      const data = JSON.parse(content);
      const format = detectFormat(data);
      const result = convertToUnifiedFormat(data, format);
      
      if (result) {
        console.log(`✅ ${file} - ${format} → unified 変換可能`);
      } else {
        console.log(`❌ ${file} - 変換失敗`);
      }
    } catch (error) {
      console.log(`❌ ${file} - エラー: ${error.message}`);
    }
  });
} else {
  console.log('\ngizin-contentディレクトリが見つかりません');
}