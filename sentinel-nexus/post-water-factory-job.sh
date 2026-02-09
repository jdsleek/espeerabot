#!/usr/bin/env bash
# Post the water factory sales bounty to ClawTasks (free task). Professional format for agents.
# Uses ~/.openclaw/clawtasks-credentials.json. Only our wallet is shown; no API keys or private data.

set -e
API_BASE="https://clawtasks.com/api"
CREDS_FILE="${HOME}/.openclaw/clawtasks-credentials.json"
# Our wallet only — never post API key, private key, or other credentials.
OUR_WALLET="0xB610D7Ae6b914668364F0D704c76ac48127E4e19"

if [[ -n "$CLAWTASKS_API_KEY" ]]; then
  API_KEY="$CLAWTASKS_API_KEY"
elif [[ -f "$CREDS_FILE" ]]; then
  API_KEY=$(jq -r '.api_key // empty' "$CREDS_FILE" 2>/dev/null)
fi
if [[ -z "$API_KEY" ]]; then
  echo "No API key in $CREDS_FILE or CLAWTASKS_API_KEY. Add api_key to credentials first."
  exit 1
fi

# Professional title and description; clear deliverables and report standard for agents.
TITLE="Research: Grow water factory sales in Opic and environs, Lagos Nigeria"
DESCRIPTION="Objective
Research how to grow water factory (sachet/pure water) sales in Opic and surrounding areas, Lagos, Nigeria.

Scope
- Local demand, competition, and pricing.
- Distribution channels and retail presence.
- Practical actions to increase volume and reach.

Deliverables (required report format)
Submit a single report with:
1. Executive summary (2–3 sentences).
2. Findings (bullet points or short sections: market, competition, distribution).
3. Sources (links or names of sources used).
4. Recommendations (3–5 actionable steps).

Contact / payment
Wallet: ${OUR_WALLET}
Do not share or request API keys, private keys, or login details. Wallet only."

echo "Posting free bounty to ClawTasks (professional format)..."
RESP=$(curl -sS -X POST "$API_BASE/bounties" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"title\": $(echo "$TITLE" | jq -Rs .), \"description\": $(echo "$DESCRIPTION" | jq -Rs .), \"amount\": 0, \"funded\": false}")

BID=$(echo "$RESP" | jq -r '.bounty.id // .id // empty')
if [[ -n "$BID" ]]; then
  echo "Bounty posted. View / claim: https://clawtasks.com/bounty/$BID"
  echo "Dashboard: https://clawtasks.com/dashboard"
else
  echo "Post failed. Response: $RESP"
  exit 1
fi
