#!/usr/bin/env bash
set -euo pipefail

# --- stdin から編集されたファイルパスを取得 ---
input="$(cat)"
file="$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<< "$input")"

# テストファイルと型定義ファイルはスキップ
case "$file" in
  *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx|*.d.ts) exit 0 ;;
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

# ファイルレベル無効化: // @jsdoc-rules-disable
if grep -qm1 '@jsdoc-rules-disable' "$file" 2>/dev/null; then
  exit 0
fi

violations="$(awk '
BEGIN { jsdoc=""; jdend=0; injd=0; state=0 }

# --- JSDoc ブロック追跡 ---
/\/\*\*/ { jsdoc=""; injd=1 }
injd { jsdoc=jsdoc RS $0 }
injd && /\*\// { injd=0; jdend=NR }

# --- 関数本体追跡 (@throws 検出用) ---
state==1 {
  if (/{/) seen_brace=1
  if (seen_brace) {
    tmp=$0; gsub(/[^{]/,"",tmp); depth+=length(tmp)
    tmp=$0; gsub(/[^}]/,"",tmp); depth-=length(tmp)
    if (/throw[[:space:]]/) hasthr=1
    if (depth<=0) {
      if (hasthr && index(fjsdoc,"@throw")==0)
        print fline": @throws が不足しています"
      state=0
    }
  } else if (NR > fline) {
    state=0
  }
  if (NR - fline > 200) state=0
  if (state==1) next
}

# --- 関数宣言の検出 ---
/^[[:space:]]*(export[[:space:]]+(default[[:space:]]+)?)?(async[[:space:]]+)?function[[:space:]]+[a-zA-Z_$]/ ||
/^[[:space:]]*(export[[:space:]]+)?(const|let)[[:space:]]+[a-zA-Z_$][a-zA-Z0-9_$]*[[:space:]]*=[[:space:]]*(async[[:space:]]*)?\(/ ||
/^[[:space:]]+[a-zA-Z_$][a-zA-Z0-9_$]*[[:space:]]*:[[:space:]]*(async[[:space:]]*)?\(/ {

  # JSDoc が直前にあるか
  if (jdend < NR-1 || jsdoc=="") {
    print NR": docコメントがありません"
    jsdoc=""; jdend=0
    next
  }

  cur_jsdoc=jsdoc; line=$0

  # --- @param チェック ---
  pstart=index(line,"("); pend=index(line,")")
  if (pstart>0 && pend>pstart+1) {
    pstr=substr(line,pstart+1,pend-pstart-1)
    gsub(/[[:space:]]/,"",pstr)
    if (pstr!="" && index(cur_jsdoc,"@param")==0)
      print NR": @param が不足しています"
  }

  # --- @returns チェック (戻り値の型注釈ベース) ---
  if (pend>0) {
    after=substr(line,pend+1)
    if (after ~ /^[[:space:]]*:/ && after !~ /:[[:space:]]*void/ && after !~ /:[[:space:]]*Promise<void>/)
      if (index(cur_jsdoc,"@return")==0)
        print NR": @returns が不足しています"
  }

  # --- @throws 用: 関数本体の追跡開始 ---
  state=1; fjsdoc=cur_jsdoc; fline=NR; hasthr=0; depth=0; seen_brace=0
  if (/{/) {
    seen_brace=1
    tmp=$0; gsub(/[^{]/,"",tmp); depth+=length(tmp)
    tmp=$0; gsub(/[^}]/,"",tmp); depth-=length(tmp)
    if (/throw[[:space:]]/) hasthr=1
    if (depth<=0) {
      if (hasthr && index(fjsdoc,"@throw")==0)
        print fline": @throws が不足しています"
      state=0
    }
  }

  jsdoc=""; jdend=0
}
' "$file" | head -10)"

if [ -n "$violations" ]; then
  jq -Rn --arg msg "$violations" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: ("JSDoc違反を検出しました:\n" + $msg + "\nルール: 関数にはdocコメント必須。パラメータには@param、例外には@throws、戻り値には@returnsを記載すること。")
    }
  }'
fi
