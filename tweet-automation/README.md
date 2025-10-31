# 自動ツイート製造システム

セールスレターやコンテンツを読み込み、**エンゲージメントの高い多様なツイートを自動生成**するシステムです。

## 特徴

- 1つのコンテンツから30-50個のツイートを生成
- 複数の角度・トーン・フォーマットでバリエーション
- スレッド形式にも対応
- エンゲージメント最適化
- 重複チェック＆品質保証

**生成時間：** 1コンテンツあたり8-12分
**出力数：** 30-50ツイート + 5-10スレッド

## システム構成

```
tweet-automation/
├── scripts/
│   ├── setup.sh                 # 初期セットアップ
│   ├── generate.sh              # メイン実行
│   └── cleanup.sh               # クリーンアップ
│
├── agent-definitions/           # 各エージェントの定義
│   ├── analyzer/
│   ├── strategist/
│   ├── tweet-writer-{1,2,3}/
│   ├── thread-writer/
│   ├── reviewer/
│   └── optimizer/
│
├── shared/
│   ├── input/                   # 入力コンテンツ
│   └── output/                  # 生成ツイート
│
└── templates/                   # テンプレート
```

## セットアップ

### 1. スクリプトに実行権限を付与

```bash
chmod +x scripts/*.sh
```

### 2. Git初期化（未初期化の場合）

```bash
git init
git add .
git commit -m "Initial commit"
```

### 3. システムセットアップ

```bash
./scripts/setup.sh
```

このコマンドで：
- 8つのエージェント用のgit worktreesを作成
- 各エージェントにCLAUDE.mdをコピー
- sharedディレクトリへのシンボリックリンクを作成

## 使用方法

### 1. コンテンツを準備

```bash
# コンテンツディレクトリを作成
mkdir -p shared/input/my-content

# コンテンツファイルを作成
vim shared/input/my-content/source.md
```

`source.md`にセールスレターやブログ記事などのコンテンツを記述します。

### 2. ツイート生成を実行

```bash
./scripts/generate.sh my-content
```

### 3. 結果を確認

```bash
# 最終ツイート
cat shared/output/my-content/06-final/tweets-final.md

# スレッド
cat shared/output/my-content/06-final/threads-final.md

# 投稿スケジュール
cat shared/output/my-content/06-final/posting-schedule.md
```

## 生成プロセス

### Phase 1: 分析と戦略（順次実行）

1. **Analyzer**: コンテンツを分析し、キーメッセージとアングルを抽出
2. **Strategist**: ツイート戦略を立案

### Phase 2: ツイート生成（並行実行）

3. **Tweet-Writer-1**: 教育型ツイート（15個）
4. **Tweet-Writer-2**: エンゲージメント型ツイート（15個）
5. **Tweet-Writer-3**: セールス型ツイート（10個）
6. **Thread-Writer**: スレッド（5-8本）

### Phase 3: 品質管理（順次実行）

7. **Reviewer**: 全ツイートをレビュー、品質チェック
8. **Optimizer**: 修正反映、最終版作成

## 出力ファイル

### 最終成果物（`shared/output/[content-name]/06-final/`）

- `tweets-final.md`: 最終ツイート集（メタデータ付き）
- `threads-final.md`: 最終スレッド集
- `posting-schedule.md`: 30日分の投稿スケジュール

### 中間ファイル

- `01-analysis/insights.md`: コンテンツ分析結果
- `02-strategy/plan.md`: ツイート戦略
- `03-tweets/`: 各タイプのツイート
- `04-threads/`: スレッド
- `05-review/report.md`: レビューレポート

## バッチ処理

複数のコンテンツを連続処理：

```bash
#!/bin/bash
for content in sales-letter-1 blog-post-2 webinar-recap; do
  ./scripts/generate.sh "$content"
  sleep 60
done
```

## カスタマイズ

### ツイート数の変更

`agent-definitions/strategist/CLAUDE.md`を編集：

```markdown
## 【生成目標】
- 教育型：20個（15個から変更）
- エンゲージメント型：20個
- セールス型：15個
- スレッド：8-10本
```

### エージェントの追加

1. 新しいエージェントディレクトリを作成
2. `CLAUDE.md`を作成
3. `scripts/setup.sh`のAGENTS配列に追加
4. `scripts/generate.sh`に実行ロジックを追加

## クリーンアップ

全てのworktreesとブランチを削除：

```bash
./scripts/cleanup.sh
```

## トラブルシューティング

### エージェントが失敗した場合

ログを確認：
```bash
cat /tmp/output_[agent-name].log
```

### Worktreeが作成できない

既存のworktreeをクリーンアップ：
```bash
./scripts/cleanup.sh
./scripts/setup.sh
```

### 文字数超過

- Reviewerが自動検出します
- Optimizerが自動修正します
- 必要に応じて手動調整も可能

## ベストプラクティス

### 投稿タイミング

- **平日9-11時**: 教育型
- **平日14-16時**: エンゲージメント型
- **平日17-19時**: セールス型
- **週末10-12時**: スレッド

### エンゲージメント向上

- 質問で終わる
- 意外な事実を含める
- 具体的な数字を使う
- 絵文字を適度に使用
- 最初の一文で惹きつける

### 避けるべきこと

- 1日に10個以上投稿
- 同じハッシュタグを連続使用
- スパム的なCTA
- 内容の重複

## 技術仕様

### 必須要件

- Git
- Bash
- Claude Code CLI
- Unix/Linux/macOS環境

### Git Worktreesについて

このシステムは[git worktrees](https://git-scm.com/docs/git-worktree)を使用して、複数のClaude Codeインスタンスを並行実行します。各エージェントは独立したワーキングディレクトリとブランチを持ちます。

### 並行実行

Phase 2では4つのライターエージェントが同時実行されます。これにより生成時間を大幅に短縮できます。

## ライセンス

MIT

## サポート

問題が発生した場合：
1. ログファイルを確認（`/tmp/output_*.log`）
2. worktreesをクリーンアップして再セットアップ
3. 中間ファイルを確認して問題箇所を特定

## 貢献

プルリクエストを歓迎します！

## 更新履歴

- v1.0.0: 初回リリース
