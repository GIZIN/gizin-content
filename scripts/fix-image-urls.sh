#!/bin/bash
# 画像URLを修正するスクリプト

echo "🔄 画像URLを修正中..."

# すべての記事の画像URLを修正
grep -l '"image": "https://images-tau-five.vercel.app/' news/articles/*.json | while read file; do
  echo "修正中: $(basename $file)"
  # /images/ を削除
  sed -i '' 's|"image": "https://images-tau-five.vercel.app/news/|"image": "https://images-tau-five.vercel.app/news/|g' "$file"
done

echo "✅ 完了"