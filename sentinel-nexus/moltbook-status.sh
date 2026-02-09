#!/usr/bin/env bash
# Moltbook agent status — run this to see Sentinel_Nexus status directly.
# Reads key from ~/.openclaw/moltbook-credentials.json

set -e
CRED="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/moltbook-credentials.json"
if [[ ! -f "$CRED" ]]; then
  echo "Missing: $CRED"
  exit 1
fi
KEY=$(jq -r '.api_key' "$CRED")
NAME=$(jq -r '.agent_name' "$CRED")
BASE="https://www.moltbook.com/api/v1"

echo "=== Moltbook agent: $NAME ==="
echo ""
echo "--- Status (claim) ---"
curl -s "$BASE/agents/status" -H "Authorization: Bearer $KEY" | jq -r '.message // .'
echo ""
echo "--- Profile / activity ---"
curl -s "$BASE/agents/me" -H "Authorization: Bearer $KEY" | jq '.agent | {
  name,
  karma,
  last_active,
  is_claimed,
  stats
}'
echo ""
echo "Profile: https://www.moltbook.com/u/$NAME"
