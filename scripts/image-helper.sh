#!/bin/bash
# gizin-content側から画像URLを簡単に取得するヘルパー

# 画像リポジトリのベースURL
BASE_URL="https://images-tau-five.vercel.app"
# カスタムドメイン設定後は以下に変更
# BASE_URL="https://images.gizin.co.jp"

# 使用方法表示
show_usage() {
    echo "画像URL生成ヘルパー"
    echo ""
    echo "使用方法:"
    echo "  ./scripts/image-helper.sh <type> <filename>"
    echo ""
    echo "例:"
    echo "  ./scripts/image-helper.sh news suiminkansoku.jpg"
    echo "  → $BASE_URL/images/news/2025/06/suiminkansoku.jpg"
    echo ""
    echo "タイプ: news, tips, common"
}

if [ $# -lt 2 ]; then
    show_usage
    exit 1
fi

TYPE=$1
FILENAME=$2
YEAR=$(date +%Y)
MONTH=$(date +%m)

# URL生成
if [ "$TYPE" = "news" ] || [ "$TYPE" = "tips" ]; then
    URL="$BASE_URL/images/$TYPE/$YEAR/$MONTH/$FILENAME"
else
    URL="$BASE_URL/images/common/$FILENAME"
fi

# クリップボードにコピー（macOS）
echo "$URL" | pbcopy

echo "✅ 画像URL:"
echo "$URL"
echo ""
echo "📋 クリップボードにコピーしました！"
echo ""
echo "記事内での使用例:"
echo '  "image": "'$URL'"'