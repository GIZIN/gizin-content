# News形式統一移行ガイド

## 概要
このガイドでは、News記事のデータ形式を安全に統一形式に移行する手順を説明します。

## 現在の状況
- News記事には3つの異なる形式が混在
- 一時的な対応（transformNewsArticle関数）で動作中
- 根本的な解決のため、データ形式の統一が必要

## 統一される形式
```json
{
  "id": "記事ID",
  "date": "2024-01-01",
  "category": "announcement",
  "featured": false,
  "tags": ["タグ1", "タグ2"],
  "versions": {
    "ja": {
      "title": "日本語タイトル",
      "description": "日本語の説明",
      "content": "日本語の本文"
    },
    "en": {
      "title": "English Title",
      "description": "English description",
      "content": "English content"
    }
  }
}
```

## 移行手順

### 1. 事前準備
```bash
# gizin-contentディレクトリに移動
cd /Users/h/Dropbox/Claude/gizin-content

# 現在の状態を確認
git status
git pull
```

### 2. テスト実行（推奨）
```bash
# まず1つのファイルでテスト
cp news/articles/2024-04-15-dx-subsidy-support.json test-article.json
node normalize-news-format.js --test test-article.json
```

### 3. バックアップの確認
スクリプトは自動的にバックアップを作成しますが、念のため手動でもバックアップ：
```bash
cp -r news/articles news/articles.manual-backup-$(date +%Y%m%d)
```

### 4. 本番実行
```bash
# スクリプトを実行
./normalize-news-format.js

# 結果を確認
# - 変換されたファイル数
# - エラーの有無
# - バックアップの場所
```

### 5. 検証
```bash
# 変換後のファイルを確認（例）
cat news/articles/2024-04-15-dx-subsidy-support.json | jq .

# インデックスを更新
./update-index.sh --news

# ローカルで動作確認
cd ../web
npm run dev
# http://localhost:3000/ja/news にアクセス
```

### 6. 問題があった場合のロールバック
```bash
# バックアップから復元
rm -rf news/articles
mv news/articles.backup news/articles
```

### 7. 確定
問題がなければ：
```bash
git add news/articles
git commit -m "feat: News記事のデータ形式を統一形式に移行"
git push
```

## リスクと対策

### リスク
1. データ破損の可能性
2. 変換ロジックの不具合
3. 予期しない形式のデータ

### 対策
1. 自動バックアップ機能
2. テスト実行オプション
3. 詳細なログ出力
4. ロールバック手順の明確化

## 責任分担
- **スクリプト作成**: web開発担当（このClaude）
- **実行判断**: ユーザー
- **実行作業**: gizin-content担当Claude（推奨）
- **最終確認**: ユーザー

## 注意事項
- 実行前に必ずGitの状態を確認
- 本番実行は営業時間外を推奨
- 問題発生時は即座にロールバック