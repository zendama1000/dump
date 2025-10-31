#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
WORKTREES_DIR="$ROOT_DIR/worktrees"
SHARED_DIR="$ROOT_DIR/shared"

if [ -z "$1" ]; then
  echo "使用法: $0 <content-name>"
  echo "例: $0 'sales-letter-2025'"
  exit 1
fi

CONTENT_NAME="$1"
INPUT_DIR="$SHARED_DIR/input/$CONTENT_NAME"
OUTPUT_DIR="$SHARED_DIR/output/$CONTENT_NAME"

if [ ! -f "$INPUT_DIR/source.md" ]; then
  echo "❌ エラー: $INPUT_DIR/source.md が見つかりません"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"/{01-analysis,02-strategy,03-tweets,04-threads,05-review,06-final}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ツイート生成開始"
echo "コンテンツ: $CONTENT_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 関数: エージェント実行
run_agent() {
  local agent_name=$1
  local prompt=$2

  echo "→ $agent_name を起動中..."

  cd "$WORKTREES_DIR/$agent_name"
  echo "$prompt" > /tmp/prompt_$agent_name.txt

  (
    claude < /tmp/prompt_$agent_name.txt > "/tmp/output_$agent_name.log" 2>&1
    if [ $? -eq 0 ]; then
      echo "  ✓ $agent_name 完了"
    else
      echo "  ✗ $agent_name 失敗"
      echo "  ログ: /tmp/output_$agent_name.log"
    fi
    rm -f /tmp/prompt_$agent_name.txt
  ) &
}

# Phase 1: 分析と戦略
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 1: 分析と戦略"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_agent "analyzer" "shared/input/$CONTENT_NAME/source.mdを分析してください。結果をshared/output/$CONTENT_NAME/01-analysis/insights.mdに保存してください。"
wait

run_agent "strategist" "shared/output/$CONTENT_NAME/01-analysis/insights.mdを読み、ツイート戦略を立案してください。結果をshared/output/$CONTENT_NAME/02-strategy/plan.mdに保存してください。"
wait

echo ""

# Phase 2: ツイート生成（並行）
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 2: ツイート生成（並行実行）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_agent "tweet-writer-1" "戦略に基づき教育型ツイートを生成してください。shared/output/$CONTENT_NAME/03-tweets/educational.mdに保存。" &
PID1=$!

run_agent "tweet-writer-2" "戦略に基づきエンゲージメント型ツイートを生成してください。shared/output/$CONTENT_NAME/03-tweets/engagement.mdに保存。" &
PID2=$!

run_agent "tweet-writer-3" "戦略に基づきセールス型ツイートを生成してください。shared/output/$CONTENT_NAME/03-tweets/sales.mdに保存。" &
PID3=$!

run_agent "thread-writer" "戦略に基づきスレッドを生成してください。shared/output/$CONTENT_NAME/04-threads/threads.mdに保存。" &
PID4=$!

wait $PID1 $PID2 $PID3 $PID4

echo ""

# Phase 3: レビューと最適化
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3: レビューと最適化"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_agent "reviewer" "全てのツイートをレビューしてください。結果をshared/output/$CONTENT_NAME/05-review/report.mdに保存。"
wait

run_agent "optimizer" "レビュー結果を反映し最終版を作成してください。shared/output/$CONTENT_NAME/06-final/に保存。"
wait

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ツイート生成完了！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "出力ディレクトリ: $OUTPUT_DIR/06-final/"
echo ""
