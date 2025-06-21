# Vercelで画像ホスティング

## 概要
gizin-contentリポジトリをVercelにデプロイして、画像を配信する。

## セットアップ手順

### 1. vercel.jsonの作成
```json
{
  "buildCommand": "echo 'No build needed'",
  "outputDirectory": ".",
  "headers": [
    {
      "source": "/images/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ],
  "rewrites": [
    {
      "source": "/",
      "destination": "/README.md"
    }
  ]
}
```

### 2. Vercelにデプロイ
```bash
# Vercel CLIをインストール（未インストールの場合）
npm i -g vercel

# デプロイ
vercel

# プロジェクト名: gizin-content-images
# フレームワーク: Other
# ルートディレクトリ: ./
```

### 3. カスタムドメイン設定（オプション）
- Vercelダッシュボードで `images.gizin.co.jp` を追加
- DNSのCNAMEレコードを設定

## 使い方

### 画像の追加
```bash
# 画像を追加
mkdir -p images/news/2025/06
cp ~/Desktop/new-image.jpg images/news/2025/06/

# コミット＆プッシュ
git add images/
git commit -m "feat: 画像追加"
git push

# Vercelが自動的にデプロイ
```

### URLの形式
```
# Vercelのデフォルトドメイン
https://gizin-content-images.vercel.app/images/news/2025/06/image.jpg

# カスタムドメイン設定後
https://images.gizin.co.jp/images/news/2025/06/image.jpg
```

## メリット

1. **商用利用OK** - Vercelの無料枠で商用利用可能
2. **高速配信** - グローバルCDN
3. **自動デプロイ** - git pushで自動更新
4. **画像最適化** - Vercelの画像最適化機能も利用可能
5. **HTTPS対応** - 自動でSSL証明書

## Vercelの無料枠
- 帯域幅: 100GB/月
- ストレージ: 十分
- 商用利用: OK

これで完璧！