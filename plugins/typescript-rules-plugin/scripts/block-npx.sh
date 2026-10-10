#!/bin/bash
COMMAND=$(cat | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -qE '(^|\s|[;&|])\s*(npx|pnpm dlx)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "npx および pnpm dlx の使用は禁止されています。パッケージはpnpm addでインストールしてから使用してください。"
    }
  }'
else
  exit 0
fi
