#!/bin/bash
# gizin-content用のキャッシュクリアスクリプト
#
# 使用方法:
#   ./clear-cache.sh         # デフォルト: TIPSをクリア
#   ./clear-cache.sh tips    # TIPSをクリア
#   ./clear-cache.sh news    # Newsをクリア
#   ./clear-cache.sh all     # TIPSとNews両方をクリア

# デフォルトのタイプを設定
TYPE="${1:-tips}"

# REVALIDATEトークンを確認
if [ -z "$REVALIDATE_TOKEN" ]; then
  if [ -f .env ]; then
    export $(cat .env | grep REVALIDATE_TOKEN | xargs)
  elif [ -f .env.local ]; then
    export $(cat .env.local | grep REVALIDATE_TOKEN | xargs)
  fi
fi

if [ -z "$REVALIDATE_TOKEN" ]; then
  echo "❌ REVALIDATE_TOKENが設定されていません"
  exit 1
fi

# 関数: キャッシュクリアを実行
clear_cache() {
  local cache_type=$1
  echo "🔄 ${cache_type}のキャッシュをクリアしています..."
  
  response=$(curl -s -X POST "https://gizin.co.jp/api/revalidate" \
    -H "Content-Type: application/json" \
    -H "x-revalidate-token: $REVALIDATE_TOKEN" \
    -d "{\"type\": \"${cache_type}\"}")
  
  if [[ "$response" == *"\"revalidated\":true"* ]]; then
    echo "✅ ${cache_type}のキャッシュをクリアしました"
  else
    echo "❌ ${cache_type}のキャッシュクリアに失敗しました: $response"
  fi
}

# メイン処理
case "$TYPE" in
  tips)
    clear_cache "tips"
    ;;
  news)
    clear_cache "news"
    ;;
  all)
    clear_cache "tips"
    clear_cache "news"
    ;;
  *)
    echo "❌ 無効なタイプ: $TYPE"
    echo "使用可能なタイプ: tips, news, all"
    exit 1
    ;;
esac