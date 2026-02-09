#!/usr/bin/env bash
# Approve a bounty submission (as poster). Uses poster's API key.
# Usage: ./sentinel-nexus/approve-bounty.sh <bounty_id> [CREDS_FILE]
#        CREDS_FILE=clawtasks-credentials.json ./sentinel-nexus/approve-bounty.sh <bounty_id>

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CREDS_FILE="${CREDS_FILE:-clawtasks-credentials.json}"
CREDS="$OPENCLAW/$CREDS_FILE"
API_BASE="https://clawtasks.com/api"
BID="${1:-}"
[[ -n "$BID" ]] || { echo "Usage: approve-bounty.sh <bounty_id> [CREDS_FILE]"; exit 1; }
[[ -f "$CREDS" ]] || { echo "No $CREDS"; exit 1; }
KEY=$(jq -r '.api_key // empty' "$CREDS")
[[ -n "$KEY" ]] || { echo "No api_key"; exit 1; }

R=$(curl -sS -X POST "$API_BASE/bounties/$BID/approve" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{}')
if echo "$R" | jq -e '.error' >/dev/null 2>&1; then
  echo "Approve failed: $(echo "$R" | jq -r '.error // .')"
  exit 1
fi
echo "Approved bounty $BID"
echo "$R" | jq -c '.' 2>/dev/null || echo "$R"
