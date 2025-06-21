# 画像管理クイックスタート 🚀

## 1. 初期セットアップ（初回のみ）

```bash
# リポジトリ作成
gh repo create GIZIN/gizin-content-images --public

# クローン
git clone https://github.com/GIZIN/gizin-content-images.git

# 基本構造作成
cd gizin-content-images
mkdir -p images/{news,tips,common}
echo "# GIZIN Content Images" > README.md

# 初回コミット
git add .
git commit -m "initial commit"
git push
```

## 2. GitHub Pages有効化
1. https://github.com/GIZIN/gizin-content-images/settings/pages
2. Source: Deploy from a branch
3. Branch: main / (root)
4. Save

## 3. 日常的な使い方

### 画像を追加する最速の方法

```bash
# 例：ニュース画像を追加
cd gizin-content-images
cp ~/Desktop/new-product.jpg images/news/2025/06/
git add .
git commit -m "feat: 新商品の画像追加"
git push

# 数分後、以下のURLでアクセス可能に
# https://gizin.github.io/gizin-content-images/images/news/2025/06/new-product.jpg
```

### gizin-content側でURL取得

```bash
# image-helper.shを使う
cd gizin-content
./scripts/image-helper.sh news new-product.jpg
# → URLがクリップボードにコピーされる
```

## 4. ワークフロー例

1. **画像準備**
   - 画像を最適化（2MB以下推奨）
   - わかりやすいファイル名に

2. **アップロード**
   ```bash
   cd gizin-content-images
   cp 画像ファイル images/news/2025/06/
   git add . && git commit -m "feat: ○○画像追加" && git push
   ```

3. **記事で使用**
   ```json
   {
     "image": "https://gizin.github.io/gizin-content-images/images/news/2025/06/画像ファイル名.jpg"
   }
   ```

## Tips

- 🎯 画像は種類別にフォルダ分け（news/tips/common）
- 📅 news/tipsは年月フォルダで整理
- 🔄 pushしたら数分でアクセス可能
- 📋 image-helper.shでURL簡単コピー

これで画像管理が楽になります！