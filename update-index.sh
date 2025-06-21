#!/bin/bash

# gizin-contentのTIPSおよびNewsインデックスを更新するスクリプト
# Phase 1: ローカル確認のみ
# Phase 2: --push オプションでPushとキャッシュ削除
#
# 使用方法:
#   ./update-index.sh --tips        # TIPSのみ更新
#   ./update-index.sh --news        # Newsのみ更新
#   ./update-index.sh --all         # 両方更新（デフォルト）
#   ./update-index.sh --all --push  # 両方更新してPush

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTENT_REPO="."
PUSH_FLAG=false
UPDATE_TIPS=false
UPDATE_NEWS=false

# コマンドライン引数を解析
for arg in "$@"; do
  case $arg in
    --push)
      PUSH_FLAG=true
      ;;
    --tips)
      UPDATE_TIPS=true
      ;;
    --news)
      UPDATE_NEWS=true
      ;;
    --all)
      UPDATE_TIPS=true
      UPDATE_NEWS=true
      ;;
  esac
done

# デフォルトで両方更新
if [[ "$UPDATE_TIPS" == false && "$UPDATE_NEWS" == false ]]; then
  UPDATE_TIPS=true
  UPDATE_NEWS=true
fi

echo -e "${YELLOW}📑 インデックスを更新します...${NC}"

# TIPSインデックス更新用のNode.jsスクリプト
if [[ "$UPDATE_TIPS" == true ]]; then
  echo -e "${BLUE}📚 TIPSインデックスを更新中...${NC}"
  
  cat > /tmp/update-tips-index.js << 'EOF'
const fs = require('fs');
const path = require('path');

const tipsDir = process.argv[2] + '/tips/articles';
const indexPath = process.argv[2] + '/tips/index.json';

// すべての記事ファイルを読み込む
const articles = [];
const files = fs.readdirSync(tipsDir);

files.forEach(file => {
  if (file.endsWith('.json')) {
    const content = fs.readFileSync(path.join(tipsDir, file), 'utf-8');
    const article = JSON.parse(content);
    
    // インデックス用のメタデータを抽出
    const meta = {
      id: article.id,
      slug: article.id,
      date: article.date,
      category: article.category,
      difficulty: article.difficulty || 'intermediate',
      readingTime: article.readingTime || 5,
      featured: article.featured || false,
      tags: article.tags || []
    };
    
    // タイトルと抜粋を追加
    if (article.versions) {
      meta.title = {
        ja: article.versions.ja.title,
        en: article.versions.en?.title || article.versions.ja.title
      };
      meta.excerpt = {
        ja: article.versions.ja.description,
        en: article.versions.en?.description || article.versions.ja.description
      };
    } else if (article.title) {
      meta.title = article.title;
      meta.excerpt = article.excerpt;
    }
    
    articles.push(meta);
  }
});

// 日付でソート（新しい順）
articles.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

// インデックスを保存
const index = { articles };
fs.writeFileSync(indexPath, JSON.stringify(index, null, 2));

console.log(`✅ ${articles.length}件のTIPS記事をインデックスに追加しました`);
EOF

  # 実行
  cd "$CONTENT_REPO"
  node /tmp/update-tips-index.js .
  cd - > /dev/null
  rm -f /tmp/update-tips-index.js
fi

# Newsインデックス更新用のNode.jsスクリプト
if [[ "$UPDATE_NEWS" == true ]]; then
  echo -e "${BLUE}📰 Newsインデックスを更新中...${NC}"
  
  cat > /tmp/update-news-index.js << 'EOF'
const fs = require('fs');
const path = require('path');

const newsDir = process.argv[2] + '/news/articles';
const indexPath = process.argv[2] + '/news/index.json';

// すべての記事ファイルを読み込む
const articles = [];
const files = fs.readdirSync(newsDir);

files.forEach(file => {
  if (file.endsWith('.json')) {
    const content = fs.readFileSync(path.join(newsDir, file), 'utf-8');
    const article = JSON.parse(content);
    
    // インデックス用のメタデータを抽出
    const meta = {
      id: article.id,
      slug: article.id,
      date: article.date,
      category: article.category || 'general',
      featured: article.featured || false,
      tags: article.tags || []
    };
    
    // タイトルと抜粋を追加
    if (article.versions) {
      meta.title = {
        ja: article.versions.ja.title,
        en: article.versions.en?.title || article.versions.ja.title
      };
      meta.excerpt = {
        ja: article.versions.ja.description || article.versions.ja.excerpt,
        en: article.versions.en?.description || article.versions.en?.excerpt || article.versions.ja.description || article.versions.ja.excerpt
      };
    } else if (article.title) {
      meta.title = article.title;
      meta.excerpt = article.excerpt || article.description;
    }
    
    articles.push(meta);
  }
});

// 日付でソート（新しい順）
articles.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

// インデックスを保存
const index = { articles };
fs.writeFileSync(indexPath, JSON.stringify(index, null, 2));

console.log(`✅ ${articles.length}件のNews記事をインデックスに追加しました`);
EOF

  # 実行
  cd "$CONTENT_REPO"
  node /tmp/update-news-index.js .
  cd - > /dev/null
  rm -f /tmp/update-news-index.js
fi

# Git操作
cd "$CONTENT_REPO"
CHANGES_TIPS=false
CHANGES_NEWS=false
COMMIT_MSG=""

if [[ "$UPDATE_TIPS" == true ]]; then
  if ! git diff --quiet tips/index.json 2>/dev/null; then
    CHANGES_TIPS=true
    git add tips/index.json
  fi
fi

if [[ "$UPDATE_NEWS" == true ]]; then
  if ! git diff --quiet news/index.json 2>/dev/null; then
    CHANGES_NEWS=true
    git add news/index.json
  fi
fi

# コミットメッセージを組み立て
if [[ "$CHANGES_TIPS" == true && "$CHANGES_NEWS" == true ]]; then
  COMMIT_MSG="fix: TIPSとNewsのインデックスを更新"
elif [[ "$CHANGES_TIPS" == true ]]; then
  COMMIT_MSG="fix: TIPSインデックスを更新"
elif [[ "$CHANGES_NEWS" == true ]]; then
  COMMIT_MSG="fix: Newsインデックスを更新"
fi

if [[ -n "$COMMIT_MSG" ]]; then
  git commit -m "$COMMIT_MSG"
  
  if [[ "$PUSH_FLAG" == true ]]; then
    echo -e "${BLUE}📤 Phase 2: GitHubへPushします...${NC}"
    git push
    echo -e "${GREEN}✅ インデックスを更新しました！${NC}"
    
    # キャッシュクリア
    if [[ -f ".env" ]]; then
      echo -e "${BLUE}🔄 キャッシュをクリアします...${NC}"
      source .env
      
      # 更新したコンテンツタイプに応じてキャッシュクリア
      if [[ "$UPDATE_TIPS" == true && "$UPDATE_NEWS" == true ]]; then
        # 両方クリア
        RESPONSE_TIPS=$(curl -s -X POST "https://gizin.co.jp/api/revalidate" \
          -H "Content-Type: application/json" \
          -H "x-revalidate-token: $REVALIDATE_TOKEN" \
          -d '{"type": "tips"}')
        
        RESPONSE_NEWS=$(curl -s -X POST "https://gizin.co.jp/api/revalidate" \
          -H "Content-Type: application/json" \
          -H "x-revalidate-token: $REVALIDATE_TOKEN" \
          -d '{"type": "news"}')
        
        if [[ "$RESPONSE_TIPS" == *"success"* && "$RESPONSE_NEWS" == *"success"* ]]; then
          echo -e "${GREEN}✅ TIPSとNewsのキャッシュをクリアしました！${NC}"
        else
          echo -e "${RED}❌ キャッシュクリアに失敗しました${NC}"
          [[ "$RESPONSE_TIPS" != *"success"* ]] && echo "TIPS: $RESPONSE_TIPS"
          [[ "$RESPONSE_NEWS" != *"success"* ]] && echo "News: $RESPONSE_NEWS"
        fi
      elif [[ "$UPDATE_TIPS" == true ]]; then
        # TIPSのみクリア
        RESPONSE=$(curl -s -X POST "https://gizin.co.jp/api/revalidate" \
          -H "Content-Type: application/json" \
          -H "x-revalidate-token: $REVALIDATE_TOKEN" \
          -d '{"type": "tips"}')
        
        if [[ "$RESPONSE" == *"success"* ]]; then
          echo -e "${GREEN}✅ TIPSのキャッシュをクリアしました！${NC}"
        else
          echo -e "${RED}❌ TIPSのキャッシュクリアに失敗しました${NC}"
          echo "レスポンス: $RESPONSE"
        fi
      elif [[ "$UPDATE_NEWS" == true ]]; then
        # Newsのみクリア
        RESPONSE=$(curl -s -X POST "https://gizin.co.jp/api/revalidate" \
          -H "Content-Type: application/json" \
          -H "x-revalidate-token: $REVALIDATE_TOKEN" \
          -d '{"type": "news"}')
        
        if [[ "$RESPONSE" == *"success"* ]]; then
          echo -e "${GREEN}✅ Newsのキャッシュをクリアしました！${NC}"
        else
          echo -e "${RED}❌ Newsのキャッシュクリアに失敗しました${NC}"
          echo "レスポンス: $RESPONSE"
        fi
      fi
    else
      echo -e "${YELLOW}⚠️  .envファイルが見つからないため、キャッシュクリアはスキップされました${NC}"
    fi
  else
    echo -e "${GREEN}✅ Phase 1 完了: ローカルでインデックスを更新しました${NC}"
    echo -e "${BLUE}ℹ️  Phase 2を実行するには、以下のコマンドを使用してください:${NC}"
    echo -e "${YELLOW}   ./update-index.sh --push${NC}"
  fi
else
  echo -e "${YELLOW}インデックスに変更はありません${NC}"
fi

cd - > /dev/null

echo -e "${GREEN}🎉 完了！${NC}"