#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
skill="$(jq -r '.tool_input.skill // empty' <<< "$input")"

case "$skill" in
  typescript-rules-plugin:*) ;;
  *) exit 0 ;;
esac

skill_name="${skill#typescript-rules-plugin:}"

session_id="$(jq -r '.session_id // empty' <<< "$input")"
[ -z "$session_id" ] && exit 0
session_id="$(echo "$session_id" | sed 's/[^a-zA-Z0-9_-]/_/g')"

marker_dir="${CLAUDE_PROJECT_DIR:-.}/.plugin-workspace/skill-fired/${session_id}"
mkdir -p "$marker_dir"
touch "$marker_dir/$skill_name"
