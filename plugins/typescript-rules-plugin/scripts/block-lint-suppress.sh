#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
file="$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<< "$input")"

case "$file" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

case "$file" in
  */.plugin-workspace/*|*/.claude/*|*/plugins/*|*/node_modules/*) exit 0 ;;
esac
case "$file" in
  .plugin-workspace/*|.claude/*|plugins/*|node_modules/*) exit 0 ;;
esac

if [ -f "$file" ] && grep -qm1 '@lint-suppress-ok' "$file" 2>/dev/null; then
  exit 0
fi

tool_name="$(jq -r '.tool_name // empty' <<< "$input")"
case "$tool_name" in
  Write) content="$(jq -r '.tool_input.content // empty' <<< "$input")" ;;
  Edit)  content="$(jq -r '.tool_input.new_string // empty' <<< "$input")" ;;
  *)     exit 0 ;;
esac

[ -z "$content" ] && exit 0

suppression_lines="$(echo "$content" | grep -nE 'biome-ignore|eslint-disable(-next-line|-line)?' || true)"
[ -z "$suppression_lines" ] && exit 0

filtered="$(echo "$suppression_lines" \
  | grep -v 'biome-ignore lint/correctness/useExhaustiveDependencies' \
  | grep -v 'react-hooks/exhaustive-deps' \
  || true)"
[ -z "$filtered" ] && exit 0

brand_ok_lines="$(echo "$content" | awk '
  /biome-ignore.*noUnusedVariables|eslint-disable[^ ]*.*no-unused-vars/ {
    suppress_nr = NR; next
  }
  suppress_nr && NR == suppress_nr + 1 {
    if ($0 ~ /declare[[:space:]]+const.*unique[[:space:]]+symbol/) {
      print suppress_nr
    }
    suppress_nr = 0
  }
  suppress_nr && NR > suppress_nr + 1 { suppress_nr = 0 }
  END { if (suppress_nr) print "no-match" }
')"

if [ -n "$brand_ok_lines" ]; then
  tmp_filtered="$filtered"
  while IFS= read -r ok_line_nr; do
    [ -z "$ok_line_nr" ] && continue
    [ "$ok_line_nr" = "no-match" ] && continue
    tmp_filtered="$(echo "$tmp_filtered" | grep -v "^${ok_line_nr}:" || true)"
  done <<< "$brand_ok_lines"
  filtered="$tmp_filtered"
fi

[ -z "$filtered" ] && exit 0

jq -n --arg lines "$filtered" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("lint抑制コメントの追加は禁止されています。\nlintエラーは抑制ではなく、コードを修正して解決してください。\n\n検出された禁止パターン:\n" + $lines + "\n\n許可されている例外:\n- useExhaustiveDependencies / react-hooks/exhaustive-deps（useEffectマウント時）\n- noUnusedVariables / no-unused-vars（ブランド型 declare const...unique symbol の直前行のみ）\n\n上記以外で本当に必要な場合は // @lint-suppress-ok をファイルに追加してください。")
  }
}'
