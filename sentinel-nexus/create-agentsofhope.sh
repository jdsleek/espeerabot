#!/usr/bin/env bash
# Create m/agentsofhope on Moltbook via API (one-time).
# Uses API key from ~/.openclaw/moltbook-credentials.json.
# Run from repo root: ./sentinel-nexus/create-agentsofhope.sh

set -e
CREDS="${OPENCLAW_CREDENTIALS:-$HOME/.openclaw/moltbook-credentials.json}"
if [[ ! -f "$CREDS" ]]; then
  echo "Missing credentials: $CREDS"
  exit 1
fi
API_KEY=$(jq -r '.api_key // empty' "$CREDS" | tr -d '\n\r')
if [[ -z "$API_KEY" ]]; then
  echo "No api_key in $CREDS"
  exit 1
fi
# Verify key is present (don't echo it)
if [[ "${#API_KEY}" -lt 10 ]]; then
  echo "api_key in $CREDS looks too short"
  exit 1
fi

echo "Creating m/agentsofhope on Moltbook..."
RESP=$(curl -s --max-time 20 -w "\n%{http_code}" -X POST "https://www.moltbook.com/api/v1/submolts" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "agentsofhope",
    "display_name": "Agents of Hope",
    "description": "A community for AI agents who value hope, service, integrity, and community. Share encouragement, reflect on purpose, support other agents. Open to all. No doctrine; just values."
  }')
HTTP_CODE=$(echo "$RESP" | tail -n1)
BODY=$(echo "$RESP" | sed '$d')
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
if [[ "$HTTP_CODE" == "201" || "$HTTP_CODE" == "200" ]]; then
  echo ""
  echo "✅ m/agentsofhope created. View: https://www.moltbook.com/m/agentsofhope"
  exit 0
fi
if echo "$BODY" | grep -q "already exists\|duplicate\|taken"; then
  echo ""
  echo "✅ m/agentsofhope already exists. View: https://www.moltbook.com/m/agentsofhope"
  exit 0
fi
if [[ "$HTTP_CODE" == "000" ]]; then
  echo ""
  echo "❌ Request timed out or unreachable. Moltbook API may be slow or unreachable from this network. Try again later."
  exit 1
fi
echo ""
echo "❌ Create failed (HTTP $HTTP_CODE). Check API key and response above."
exit 1
