#!/bin/bash
# ニュース画像の移行スクリプト

echo "🔄 ニュース画像の移行を開始します..."

# 画像と記事の対応を処理
grep -l '"image": "/images/news/' news/articles/*.json | while read file; do
  date=$(grep '"date"' "$file" | cut -d'"' -f4)
  year=$(echo $date | cut -d'-' -f1)
  month=$(echo $date | cut -d'-' -f2)
  
  # 現在の画像パス
  current_image=$(grep '"image"' "$file" | cut -d'"' -f4)
  image_filename=$(basename "$current_image")
  
  # 画像が存在するか確認
  if [ -f "images/news/$image_filename" ]; then
    # 年月フォルダを作成
    mkdir -p "images/news/$year/$month"
    
    # 画像を移動
    mv "images/news/$image_filename" "images/news/$year/$month/" 2>/dev/null || true
    
    # 新しいURL
    new_url="https://images-tau-five.vercel.app/news/$year/$month/$image_filename"
    
    # 記事を更新
    sed -i '' "s|\"image\": \"$current_image\"|\"image\": \"$new_url\"|" "$file"
    
    echo "✅ $image_filename → $year/$month/"
  else
    echo "⚠️  $image_filename が見つかりません"
  fi
done

echo ""
echo "📊 移行結果:"
echo "===================="
find images/news -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | wc -l | xargs echo "総画像数:"
find images/news/2* -type f | wc -l | xargs echo "整理済み:"
find images/news -maxdepth 1 -type f | wc -l | xargs echo "未整理:"