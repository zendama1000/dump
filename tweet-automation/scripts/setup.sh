#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
WORKTREES_DIR="$ROOT_DIR/worktrees"
AGENTS_DIR="$ROOT_DIR/agent-definitions"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ツイート製造システム セットアップ"
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

# 既存worktreesクリーンアップ
echo ""
echo "🧹 既存worktreesをクリーンアップ中..."
for agent in "${AGENTS[@]}"; do
  if [ -d "$WORKTREES_DIR/$agent" ]; then
    git worktree remove "$WORKTREES_DIR/$agent" --force 2>/dev/null || true
  fi
  git branch -D "$agent" 2>/dev/null || true
done

# Worktrees作成
echo ""
echo "🌳 Git worktreesを作成中..."
for agent in "${AGENTS[@]}"; do
  echo "  → $agent"

  # ブランチを作成してworktreeを追加
  git worktree add "$WORKTREES_DIR/$agent" -b "$agent" 2>/dev/null || \
  git worktree add "$WORKTREES_DIR/$agent" "$agent"

  # CLAUDE.mdをコピー
  if [ -f "$AGENTS_DIR/$agent/CLAUDE.md" ]; then
    cp "$AGENTS_DIR/$agent/CLAUDE.md" "$WORKTREES_DIR/$agent/"
  else
    echo "    ⚠️  警告: $AGENTS_DIR/$agent/CLAUDE.md が見つかりません"
  fi

  # sharedディレクトリへのシンボリックリンク作成
  ln -sf "$ROOT_DIR/shared" "$WORKTREES_DIR/$agent/shared"

  # .claudeディレクトリをコピー（存在する場合）
  mkdir -p "$WORKTREES_DIR/$agent/.claude"
  if [ -f "$ROOT_DIR/.claude/config.json" ]; then
    cp "$ROOT_DIR/.claude/config.json" "$WORKTREES_DIR/$agent/.claude/"
  fi
done

echo ""
echo "✅ セットアップ完了！"
echo ""
echo "次のステップ："
echo "1. shared/input/[name]/source.md にコンテンツを配置"
echo "2. scripts/generate.sh [content-name] で実行"
echo ""
