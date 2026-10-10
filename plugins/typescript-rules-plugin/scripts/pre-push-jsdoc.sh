#!/usr/bin/env bash
set -euo pipefail

# --- stdin から Bash コマンドを取得 ---
input="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<< "$input")"

# git push 以外はスルー
if ! echo "$command" | grep -qE '(^|\s|[;&|])\s*git\s+push\b'; then
  exit 0
fi

# --- 1ファイル分の JSDoc 違反を検出する awk スクリプト ---
check_file() {
  local file="$1"
  awk -v FILE="$file" '
  BEGIN { jsdoc=""; jdend=0; injd=0; state=0 }

  /\/\*\*/ { jsdoc=""; injd=1 }
  injd { jsdoc=jsdoc RS $0 }
  injd && /\*\// { injd=0; jdend=NR }

  state==1 {
    if (/{/) seen_brace=1
    if (seen_brace) {
      tmp=$0; gsub(/[^{]/,"",tmp); depth+=length(tmp)
      tmp=$0; gsub(/[^}]/,"",tmp); depth-=length(tmp)
      if (/throw[[:space:]]/) hasthr=1
      if (depth<=0) {
        if (hasthr && index(fjsdoc,"@throw")==0)
          print FILE":"fline": @throws が不足しています"
        state=0
      }
    } else if (NR > fline) {
      state=0
    }
    if (NR - fline > 200) state=0
    if (state==1) next
  }

  /^[[:space:]]*(export[[:space:]]+(default[[:space:]]+)?)?(async[[:space:]]+)?function[[:space:]]+[a-zA-Z_$]/ ||
  /^[[:space:]]*(export[[:space:]]+)?(const|let)[[:space:]]+[a-zA-Z_$][a-zA-Z0-9_$]*[[:space:]]*=[[:space:]]*(async[[:space:]]*)?\(/ ||
  /^[[:space:]]+[a-zA-Z_$][a-zA-Z0-9_$]*[[:space:]]*:[[:space:]]*(async[[:space:]]*)?\(/ {

    if (jdend < NR-1 || jsdoc=="") {
      print FILE":"NR": docコメントがありません"
      jsdoc=""; jdend=0
      next
    }

    cur_jsdoc=jsdoc; line=$0

    pstart=index(line,"("); pend=index(line,")")
    if (pstart>0 && pend>pstart+1) {
      pstr=substr(line,pstart+1,pend-pstart-1)
      gsub(/[[:space:]]/,"",pstr)
      if (pstr!="" && index(cur_jsdoc,"@param")==0)
        print FILE":"NR": @param が不足しています"
    }

    if (pend>0) {
      after=substr(line,pend+1)
      if (after ~ /^[[:space:]]*:/ && after !~ /:[[:space:]]*void/ && after !~ /:[[:space:]]*Promise<void>/)
        if (index(cur_jsdoc,"@return")==0)
          print FILE":"NR": @returns が不足しています"
    }

    state=1; fjsdoc=cur_jsdoc; fline=NR; hasthr=0; depth=0; seen_brace=0
    if (/{/) {
      seen_brace=1
      tmp=$0; gsub(/[^{]/,"",tmp); depth+=length(tmp)
      tmp=$0; gsub(/[^}]/,"",tmp); depth-=length(tmp)
      if (/throw[[:space:]]/) hasthr=1
      if (depth<=0) {
        if (hasthr && index(fjsdoc,"@throw")==0)
          print FILE":"fline": @throws が不足しています"
        state=0
      }
    }

    jsdoc=""; jdend=0
  }
  ' "$file"
}

# --- 対象ファイルを列挙して検査 ---
violations=""
while IFS= read -r file; do
  # ファイルレベル無効化
  if grep -qm1 '@jsdoc-rules-disable' "$file" 2>/dev/null; then
    continue
  fi
  result="$(check_file "$file")" || true
  if [ -n "$result" ]; then
    violations="${violations}${result}
"
  fi
done < <(find "$PWD" \
  \( -path '*/node_modules' -o -path '*/dist' -o -path '*/.next' -o -path '*/build' -o -path '*/.git' \) -prune -o \
  -type f \( -name '*.ts' -o -name '*.tsx' \) \
  ! -name '*.test.ts' ! -name '*.test.tsx' \
  ! -name '*.spec.ts' ! -name '*.spec.tsx' \
  ! -name '*.d.ts' \
  -print)

if [ -n "$violations" ]; then
  jq -Rn --arg msg "$violations" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("push 前の全体 JSDoc 検査で違反が検出されたため push をブロックしました。以下の違反をすべて修正してから再度 push してください。\n\n" + $msg + "\nルール: 関数にはdocコメント必須。パラメータには@param、例外には@throws、戻り値には@returnsを記載すること。")
    }
  }'
fi
