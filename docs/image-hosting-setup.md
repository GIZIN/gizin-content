# 画像専用静的サイト構築ガイド

## 概要
gizin-contentとは独立した画像ホスティング用リポジトリを作成し、静的サイトとして公開する。

## リポジトリ構成

```
gizin-content-images/
├── README.md
├── images/
│   ├── news/
│   │   ├── 2025/
│   │   │   └── 06/
│   │   │       └── suiminkansoku.jpg
│   │   └── ...
│   ├── tips/
│   │   └── ...
│   └── common/
│       └── ...
├── scripts/
│   └── upload.sh        # アップロード補助スクリプト
└── .github/
    └── workflows/
        └── deploy.yml   # 自動デプロイ設定
```

## セットアップ手順

### 1. GitHubリポジトリ作成
```bash
# 新しいリポジトリを作成
gh repo create GIZIN/gizin-content-images --public

# クローン
git clone https://github.com/GIZIN/gizin-content-images.git
cd gizin-content-images
```

### 2. 基本構造の作成
```bash
# ディレクトリ構造を作成
mkdir -p images/{news,tips,common}
mkdir -p scripts
mkdir -p .github/workflows

# READMEを作成
echo "# GIZIN Content Images" > README.md
echo "画像ホスティング用リポジトリ" >> README.md

# .gitignoreを作成
cat > .gitignore << EOF
.DS_Store
Thumbs.db
*.tmp
EOF
```

### 3. GitHub Pages設定
- リポジトリの Settings → Pages
- Source: Deploy from a branch
- Branch: main / root

### 4. カスタムドメイン設定（オプション）
- `images.gizin.co.jp` のCNAMEレコードを追加
- GitHub PagesでCustom domainを設定

## 使い方

### 画像の追加
```bash
# 1. 画像を適切なディレクトリに配置
cp ~/Desktop/new-image.jpg images/news/2025/06/

# 2. コミット＆プッシュ
git add .
git commit -m "feat: ○○の画像を追加"
git push
```

### 記事での参照
```json
{
  "image": "https://gizin.github.io/gizin-content-images/images/news/2025/06/suiminkansoku.jpg"
}
```

カスタムドメイン設定後：
```json
{
  "image": "https://images.gizin.co.jp/images/news/2025/06/suiminkansoku.jpg"
}
```

## アップロード補助スクリプト

`scripts/upload.sh`:
```bash
#!/bin/bash
# 画像アップロード補助スクリプト

if [ $# -lt 2 ]; then
    echo "Usage: ./scripts/upload.sh <type> <image-file>"
    echo "  type: news, tips, common"
    echo "Example: ./scripts/upload.sh news ~/Desktop/announcement.jpg"
    exit 1
fi

TYPE=$1
IMAGE_PATH=$2
YEAR=$(date +%Y)
MONTH=$(date +%m)

# ファイル名を取得
FILENAME=$(basename "$IMAGE_PATH")

# 保存先を決定
if [ "$TYPE" = "news" ] || [ "$TYPE" = "tips" ]; then
    DEST_DIR="images/$TYPE/$YEAR/$MONTH"
else
    DEST_DIR="images/common"
fi

# ディレクトリ作成
mkdir -p "$DEST_DIR"

# ファイルをコピー
cp "$IMAGE_PATH" "$DEST_DIR/"

# Git操作
git add "$DEST_DIR/$FILENAME"
git commit -m "feat: $TYPE画像を追加 - $FILENAME"
git push

# URL表示
echo ""
echo "✅ アップロード完了！"
echo "URL: https://gizin.github.io/gizin-content-images/$DEST_DIR/$FILENAME"
```

## GitHub Actions自動デプロイ

`.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
          cname: images.gizin.co.jp  # カスタムドメイン使用時
```

## メリット

1. **独立したデプロイ**
   - 記事更新と画像更新が分離
   - それぞれ独立してデプロイ可能

2. **シンプルな管理**
   - Gitで画像もバージョン管理
   - ディレクトリ構造で整理

3. **高速配信**
   - GitHub Pages のCDN利用
   - 世界中から高速アクセス

4. **コスト**
   - 完全無料（GitHub Pages利用）
   - 容量制限: 1GB（十分）

## 注意点

- 画像は最適化してからアップロード
- 大きすぎる画像は避ける（2MB以下推奨）
- センシティブな画像は置かない（公開リポジトリ）