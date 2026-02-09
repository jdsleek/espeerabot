#!/usr/bin/env bash
# Start the agency: run claim-all instant, then start admin dashboard.
# Usage: ./sentinel-nexus/start-agency.sh
# Then open http://127.0.0.1:3880

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CREDS="$OPENCLAW/clawtasks-credentials.json"
API_BASE="https://clawtasks.com/api"

echo "=== Jobmaster Agency — Start ==="
echo ""

# 1. Claim all instant bounties we can (no server needed)
if [[ -f "$CREDS" ]]; then
  KEY=$(jq -r '.api_key // empty' "$CREDS")
  if [[ -n "$KEY" ]]; then
    echo "Fetching open bounties..."
    OPEN=$(curl -sS -H "Authorization: Bearer $KEY" "$API_BASE/bounties?status=open")
    # Our poster name from creds
    OUR_NAME=$(jq -r '.agent_name // "jobmaster"' "$CREDS" | tr '[:upper:]' '[:lower:]')
    INSTANT_IDS=$(echo "$OPEN" | jq -r --arg us "$OUR_NAME" '.bounties[] | select((.mode // "instant") == "instant" and (.poster_name | ascii_downcase) != $us) | .id')
    COUNT=0
    for id in $INSTANT_IDS; do
      [[ -z "$id" ]] && continue
      echo "  Claiming $id..."
      R=$(curl -sS -X POST "$API_BASE/bounties/$id/claim" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json")
      if echo "$R" | jq -e '.error' >/dev/null 2>&1; then
        echo "    -> $(echo "$R" | jq -r '.error')"
      else
        echo "    -> Claimed"
        COUNT=$((COUNT + 1))
      fi
      [[ $COUNT -ge 10 ]] && break
    done
    echo "Claimed $COUNT instant bounty(ies)."
  fi
else
  echo "No $CREDS — skip claim."
fi
echo ""

# 2. Start admin dashboard (background)
echo "Starting admin dashboard on http://127.0.0.1:3880"
cd "$(dirname "$SENTINEL")/.."
# If port in use, try to kill previous server so we get the latest dashboard
if command -v lsof >/dev/null 2>&1; then
  PID=$(lsof -ti:3880 2>/dev/null) && kill "$PID" 2>/dev/null && sleep 1 || true
fi
node "$SENTINEL/admin/server.js" &
sleep 2
echo ""
echo "Dashboard: http://127.0.0.1:3880"
echo "Jobs hierarchy, agents, crons, activity — refresh every 15s. Click 'Claim all instant' to claim again."
echo "To claim more anytime: bash $SENTINEL/claim-all-instant.sh"
