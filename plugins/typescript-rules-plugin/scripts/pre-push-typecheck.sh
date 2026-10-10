#!/usr/bin/env bash
set -euo pipefail

# --- stdin から Bash コマンドを取得 ---
input="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<< "$input")"

# git push 以外はスルー
if ! echo "$command" | grep -qE '(^|\s|[;&|])\s*git\s+push\b'; then
  exit 0
fi

# --- typescript を持つ最寄りの package.json を探索 ---
find_dep_root() {
  local dep="$1" dir="$2"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/package.json" ] && \
       jq -e --arg name "$dep" '(.dependencies[$name] // .devDependencies[$name]) != null' "$dir/package.json" >/dev/null 2>&1; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# typescript が見つからなければスルー
ts_root="$(find_dep_root "typescript" "$PWD")" || exit 0

# tsc が実行可能か確認
if ! (cd "$ts_root" && pnpm exec tsc --version >/dev/null 2>&1); then
  exit 0
fi

# --- tsconfig.json を $PWD から上方向に探索 ---
find_tsconfig() {
  local dir="$1" root="$2"
  while [ "$dir" != "/" ] && [[ "$dir" == "$root"* ]]; do
    if [ -f "$dir/tsconfig.json" ]; then
      echo "$dir/tsconfig.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

tsconfig="$(find_tsconfig "$PWD" "$ts_root")" || exit 0

# --- tsc --noEmit 実行 ---
result="$(cd "$ts_root" && pnpm exec tsc --noEmit --project "$tsconfig" 2>&1)" && exit 0

# 型エラーあり → push をブロックし、エラー内容を AI にフィードバック
jq -Rn --arg msg "$result" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("tsc --noEmit で型エラーが検出されたため push をブロックしました。以下の型エラーをすべて修正してから再度 push してください。\n\n" + $msg)
  }
}'
