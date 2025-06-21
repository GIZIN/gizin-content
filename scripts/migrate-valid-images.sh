#!/bin/bash
# 正常な画像のみを移行するスクリプト

echo "🔄 正常なニュース画像の移行を開始します..."
echo ""

# 移行カウンター
migrated=0
skipped=0
broken=0

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
    # ファイルサイズを確認
    size=$(stat -f%z "images/news/$image_filename" 2>/dev/null || stat -c%s "images/news/$image_filename" 2>/dev/null)
    
    if [ "$size" -eq 138 ]; then
      # 壊れた画像は画像フィールドをnullに
      sed -i '' "s|\"image\": \"$current_image\"|\"image\": null|" "$file"
      echo "❌ 壊れた画像を無効化: $image_filename (記事: $(basename $file))"
      broken=$((broken + 1))
    elif [ "$size" -gt 0 ]; then
      # 正常な画像を移行
      mkdir -p "images/news/$year/$month"
      
      # 画像を移動（既に移動済みの場合はスキップ）
      if [ -f "images/news/$year/$month/$image_filename" ]; then
        echo "⏭️  既に移動済み: $image_filename"
        skipped=$((skipped + 1))
      else
        mv "images/news/$image_filename" "images/news/$year/$month/"
        echo "✅ 移動完了: $image_filename → $year/$month/"
        migrated=$((migrated + 1))
      fi
      
      # 新しいURL
      new_url="https://images-tau-five.vercel.app/news/$year/$month/$image_filename"
      
      # 記事を更新
      sed -i '' "s|\"image\": \"$current_image\"|\"image\": \"$new_url\"|" "$file"
    else
      # 0バイトのファイル
      sed -i '' "s|\"image\": \"$current_image\"|\"image\": null|" "$file"
      echo "⚠️  0バイトファイル無効化: $image_filename"
      broken=$((broken + 1))
    fi
  else
    echo "❓ ファイルが見つかりません: $image_filename"
  fi
done

# 残った196バイトの画像も確認
echo ""
echo "🔍 その他の小さな画像を確認中..."
find images/news -maxdepth 1 -type f -name "*.png" | while read f; do
  size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null)
  if [ "$size" -eq 196 ]; then
    rm "$f"
    echo "🗑️  196バイトの画像を削除: $(basename $f)"
  fi
done

echo ""
echo "📊 移行結果:"
echo "===================="
echo "✅ 移動した画像: $migrated"
echo "⏭️  スキップ: $skipped"
echo "❌ 無効化: $broken"
echo ""
echo "📁 フォルダ別画像数:"
find images/news -type d -name "20*" | sort | while read dir; do
  count=$(find "$dir" -type f | wc -l | xargs)
  echo "  $dir: $count 枚"
done