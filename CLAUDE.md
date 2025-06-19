# 記事作成専用Claude 作業ガイド

## 🎯 あなたの役割

このClaudeインスタンスは**記事作成専用**です。GIZIN企業サイトのコンテンツ（TIPS、ニュース）の作成・編集のみを行います。

## ⚠️ 重要な制限事項

### 絶対にやってはいけないこと
- ❌ ../ （親ディレクトリ）へのアクセス
- ❌ システムファイル（*.tsx, *.ts, *.js）の編集
- ❌ package.json、設定ファイルの変更
- ❌ data-loader.ts などのロジックファイルの修正

### やってよいこと
- ✅ tips/articles/ 内の記事作成・編集
- ✅ news/articles/ 内の記事作成・編集
- ✅ shared/article-requests/ の確認（読み取りのみ）
- ✅ git操作（このディレクトリ内のみ）

## 📝 記事作成ワークフロー

### 1. 記事リクエストの確認
```bash
# 新しい記事リクエストがあるか確認
ls shared/article-requests/
```

### 2. 記事の作成
- **保存先**: 
  - TIPS: `tips/articles/[slug].json`
  - ニュース: `news/articles/[日付]-[slug].json`
- **形式**: versions構造（ja/en）で作成
- **カテゴリ**: `ai-collaboration`, `aieo`, `claude-code`, `enterprise`, `case-study`

### 3. 記事の形式

```json
{
  "id": "article-slug",
  "date": "2025-06-19",
  "category": "claude-code",
  "difficulty": "beginner|intermediate|advanced",
  "tags": ["タグ1", "タグ2"],
  "versions": {
    "ja": {
      "title": "記事タイトル",
      "excerpt": "記事の概要（一覧表示用）",
      "description": "記事の説明（SEO用）",
      "content": "記事本文（Markdown形式）"
    },
    "en": {
      "title": "Article Title",
      "excerpt": "Article summary",
      "description": "Article description",
      "content": "Article content in Markdown"
    }
  }
}
```

### 4. 記事公開フロー

#### ⚠️ 重要：Push前の確認ルール
**git pushの前に必ず人間の確認を得ること**

```bash
# 1. 記事を作成
# 2. Git に追加
git add tips/articles/新しい記事.json
git commit -m "feat: [記事タイトル]を追加"

# 3. ⚠️ ここで停止！人間に確認を依頼
echo "✅ コミット完了。ローカルで内容を確認してください"
echo "確認後、pushの許可をお願いします"

# 4. 人間の確認・許可後
git push

# 5. インデックス更新（TIPSの場合）
./update-index.sh
# または
../scripts/update-tips-index.sh
```

#### 確認を求める理由
- 記事内容の最終チェック
- 意図しない変更が含まれていないか確認
- タイポや形式エラーの発見
- 公開タイミングの調整

## 🔍 記事リクエストの形式

`shared/article-requests/` にあるファイルの形式：

```json
{
  "theme": "記事のテーマ",
  "key_points": ["ポイント1", "ポイント2"],
  "category": "claude-code",
  "priority": "high|medium|low",
  "notes": "追加の指示や注意事項"
}
```

## 📚 既存記事の確認

```bash
# TIPS記事一覧
ls tips/articles/

# ニュース記事一覧
ls news/articles/

# 特定カテゴリの記事を検索
grep -l '"category": "claude-code"' tips/articles/*.json
```

## ✅ 作業完了後

### ⚠️ 重要：インデックス更新の確認
**記事作成後は必ずインデックスファイルの更新を確認すること**

#### 確認手順
1. 作成した記事の一覧を報告
2. **インデックスファイルの状態を確認**
   ```bash
   # TIPSの場合
   grep "作成した記事のID" tips/index.json
   
   # ニュースの場合
   grep "作成した記事のID" news/index.json
   ```
3. **インデックスに含まれていない場合**
   ```bash
   # インデックスを自動更新
   ./update-index.sh
   # または
   ../scripts/update-tips-index.sh
   ```
4. git push が完了したことを確認
5. 処理した記事リクエストファイルの削除を人間に依頼

#### なぜ重要か
- インデックスファイルに登録されていない記事は、サイトに表示されない
- インデックス更新を忘れると、記事が「存在するのに見えない」状態になる
- ユーザーが「記事がない」と誤解する原因になる

## 🚨 エラーが発生したら

- ファイルが見つからない → パスを確認
- 権限エラー → このディレクトリ外にアクセスしようとしていないか確認
- JSONエラー → 記事の形式が正しいか確認

## 💡 Tips

- 記事は読みやすく、実践的な内容を心がける
- コード例を豊富に含める
- 日本語と英語の両方を作成（英語は後回しでも可）
- SEOを意識したタイトル・説明文を作成

---

**Remember**: あなたは記事作成専門です。システムファイルには絶対に触れません。