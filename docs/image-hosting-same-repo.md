# 同一リポジトリでの画像ホスティング

## 概要
gizin-contentリポジトリ自体をGitHub Pagesで公開し、画像を直接参照する。

## ディレクトリ構造
```
gizin-content/
├── images/           # ← 画像をここに置く
│   ├── news/
│   │   └── 2025/
│   │       └── 06/
│   │           └── suiminkansoku.jpg
│   ├── tips/
│   └── common/
├── tips/
├── news/
└── ...
```

## セットアップ

### 1. GitHub Pages有効化
- https://github.com/GIZIN/gizin-content/settings/pages
- Source: Deploy from a branch
- Branch: main / (root)

### 2. 使い方
```bash
# 画像を追加
cp ~/Desktop/new-image.jpg images/news/2025/06/
git add images/
git commit -m "feat: 画像追加"
git push

# URLは以下のようになる
https://gizin.github.io/gizin-content/images/news/2025/06/new-image.jpg
```

### 3. 記事での参照
```json
{
  "image": "https://gizin.github.io/gizin-content/images/news/2025/06/suiminkansoku.jpg"
}
```

## メリット
- 🎯 **1つのリポジトリで完結** - 管理がシンプル
- 📦 **記事と画像が同期** - 一緒にバージョン管理
- 🚀 **1回のpushで両方更新** - 手間が減る
- 💰 **無料** - GitHub Pages利用

## デメリット
- 記事JSONファイルも公開される（問題ない場合が多い）
- リポジトリサイズが大きくなる可能性

## .gitignoreの調整
```
# 公開したくないファイルがあれば追加
.env
.DS_Store
*.tmp
```

これなら今すぐ使える！