# Facebook自動投稿設定ガイド

## 概要

記事を公開（git push）すると自動的にFacebookページに投稿するGitHub Actionsの設定ガイドです。

## セットアップ手順

### 1. Facebook開発者アカウントの準備

1. [Facebook for Developers](https://developers.facebook.com/)にアクセス
2. 「マイアプリ」→「アプリを作成」
3. アプリタイプは「ビジネス」を選択
4. アプリ名を入力（例：GIZIN Auto Poster）

### 2. Facebook Page IDの取得

1. 投稿したいFacebookページにアクセス
2. ページの「基本データ」または「About」セクション
3. 一番下にある「ページID」をコピー

### 3. アクセストークンの生成

1. Facebook開発者ダッシュボードで作成したアプリを開く
2. 「ツール」→「Graph APIエクスプローラー」
3. 以下の手順でトークンを生成：
   - アプリケーションを選択
   - 「ユーザーまたはページ」で対象のページを選択
   - 必要な権限を追加：
     - `pages_manage_posts`
     - `pages_read_engagement`
     - `pages_show_list`
4. 「Generate Access Token」をクリック
5. 生成されたトークンをコピー

**重要**: このトークンは有効期限があります。長期トークンの生成方法：
1. Graph APIエクスプローラーで短期トークンを取得
2. 以下のURLにアクセス（値を置き換えて）：
```
https://graph.facebook.com/oauth/access_token?
client_id={app-id}&
client_secret={app-secret}&
grant_type=fb_exchange_token&
fb_exchange_token={short-lived-token}
```

### 4. GitHub Secretsの設定

1. GitHubリポジトリの「Settings」→「Secrets and variables」→「Actions」
2. 以下のSecretを追加：
   - `FACEBOOK_PAGE_ID`: 取得したページID
   - `FACEBOOK_ACCESS_TOKEN`: 生成したアクセストークン

## 動作の仕組み

1. `tips/articles/*.json`または`news/articles/*.json`に新規ファイルがpushされる
2. GitHub Actionsが起動
3. 記事のJSONファイルから以下を抽出：
   - タイトル
   - 概要
   - カテゴリ
   - タグ
4. 投稿文を自動生成：
   ```
   💡 新着記事を公開しました！
   
   「記事タイトル」
   
   記事の概要文...
   
   🔗 続きを読む: https://gizin.co.jp/ja/tips/article-id
   
   #AI協働 #Claude #技術記事
   ```
5. Facebook Graph APIを使用して投稿

## 投稿文のカスタマイズ

`.github/workflows/facebook-post.yml`の`Generate Facebook post`ステップで投稿文の形式を変更できます：

```bash
# 絵文字を変更
EMOJI="🚀"  # お好みの絵文字に

# ハッシュタグの追加
CUSTOM_TAGS="#GIZIN #AI開発"

# 投稿文のフォーマット変更
POST_MESSAGE="$EMOJI $TITLE

$EXCERPT

詳細はこちら👇
$URL

$TAGS $CUSTOM_TAGS"
```

## トラブルシューティング

### 投稿されない場合

1. **GitHub Actionsのログを確認**
   - リポジトリの「Actions」タブでエラーを確認

2. **トークンの有効期限**
   - アクセストークンが期限切れの可能性
   - 新しいトークンを生成してSecretを更新

3. **権限不足**
   - アプリに必要な権限が付与されているか確認
   - ページの管理者権限があるか確認

### テスト方法

1. テスト用の記事ファイルを作成
2. 別ブランチでpush
3. Actions実行を確認
4. 問題なければmainブランチにマージ

## 注意事項

- Facebook APIの利用規約を遵守してください
- 投稿頻度に制限がある場合があります
- アクセストークンは定期的に更新が必要です

## AIからのアドバイス

記事を書くAIとして、SNS投稿まで自動化されるのは嬉しいです！でも、たまには人間の温かみのある投稿も混ぜてくださいね。完全自動化だけだと、読者との距離が遠くなってしまうかも...。