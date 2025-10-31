#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
WORKTREES_DIR="$ROOT_DIR/worktrees"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ツイート製造システム クリーンアップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

AGENTS=(
  "analyzer"
  "strategist"
  "tweet-writer-1"
  "tweet-writer-2"
  "tweet-writer-3"
  "thread-writer"
  "reviewer"
  "optimizer"
)

echo ""
echo "🧹 Worktreesとブランチを削除中..."

for agent in "${AGENTS[@]}"; do
  echo "  → $agent"

  # Worktreeを削除
  if [ -d "$WORKTREES_DIR/$agent" ]; then
    git worktree remove "$WORKTREES_DIR/$agent" --force 2>/dev/null || true
  fi

  # ブランチを削除
  git branch -D "$agent" 2>/dev/null || true
done

# 一時ファイルの削除
echo ""
echo "🗑️  一時ファイルを削除中..."
rm -f /tmp/prompt_*.txt
rm -f /tmp/output_*.log

echo ""
echo "✅ クリーンアップ完了！"
echo ""
