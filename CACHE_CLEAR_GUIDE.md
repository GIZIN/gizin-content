# キャッシュクリアガイド 🔄

## 重要：記事が反映されない問題の解決

### 問題
記事を更新してGitHubにプッシュしても、本番サイト（https://gizin.co.jp）に反映されない。

### 原因
Next.jsのキャッシュが残っているため。特に**News記事**で発生しやすい。

## clear-cache.shの使い方

### 基本コマンド
```bash
# TIPSのキャッシュをクリア（デフォルト）
./clear-cache.sh

# TIPSのキャッシュをクリア（明示的）
./clear-cache.sh tips

# Newsのキャッシュをクリア ⚠️ 重要
./clear-cache.sh news

# 両方のキャッシュをクリア
./clear-cache.sh all
```

### いつ使うか

1. **TIPS記事を更新した後**
   ```bash
   ./clear-cache.sh tips
   ```

2. **News記事を更新した後** ⚠️ 特に重要
   ```bash
   ./clear-cache.sh news
   ```

3. **どちらか分からない/両方更新した場合**
   ```bash
   ./clear-cache.sh all
   ```

## update-index.shとの連携

### 自動キャッシュクリア（推奨）
```bash
# インデックス更新 + プッシュ + キャッシュクリア
./update-index.sh --tips --push  # TIPSの場合
./update-index.sh --news --push  # Newsの場合
./update-index.sh --all --push   # 両方
```

### 手動実行の場合
```bash
# 1. インデックス更新
./update-index.sh --news

# 2. Git操作
git add -A
git commit -m "記事を更新"
git push

# 3. キャッシュクリア（忘れずに！）
./clear-cache.sh news
```

## トラブルシューティング

### エラー: REVALIDATE_TOKENが設定されていません
```bash
# .envファイルを確認
cat .env | grep REVALIDATE_TOKEN

# 設定されていない場合は追加
echo "REVALIDATE_TOKEN=your-token-here" >> .env
```

### エラー: キャッシュクリアに失敗しました
- ネットワーク接続を確認
- トークンが正しいか確認
- https://gizin.co.jp/api/revalidate にアクセス可能か確認

## まとめ

1. **News記事の更新後は必ず `./clear-cache.sh news` を実行**
2. **迷ったら `./clear-cache.sh all` で両方クリア**
3. **`--push`オプション付きなら自動でクリアされる**

記事が反映されない時は、まずキャッシュクリアを試してください！