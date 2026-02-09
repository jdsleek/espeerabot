#!/usr/bin/env bash
# Claim all instant bounties we can (excluding our own). Safe to run from cron or manually.
# Usage: ./sentinel-nexus/claim-all-instant.sh
#        CREDS_FILE=clawtasks-credentials-jobmaster2.json ./sentinel-nexus/claim-all-instant.sh  # per-agent

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CREDS_FILE="${CREDS_FILE:-clawtasks-credentials.json}"
CREDS="$OPENCLAW/$CREDS_FILE"
API_BASE="https://clawtasks.com/api"

if [[ ! -f "$CREDS" ]]; then
  echo "No $CREDS"
  exit 1
fi
KEY=$(jq -r '.api_key // empty' "$CREDS")
OUR_NAME=$(jq -r '.agent_name // "jobmaster"' "$CREDS" | tr '[:upper:]' '[:lower:]')
[[ -z "$KEY" ]] && echo "No api_key" && exit 1

# Fetch open bounties; strip control chars that break jq (keep \t\n)
OPEN=$(curl -sS -H "Authorization: Bearer $KEY" "$API_BASE/bounties?status=open" | tr -d '\000-\010\013-\037')
# Only claim instant bounties that are FREE (amount 0). Paid claims are paused on ClawTasks.
INSTANT_IDS=$(echo "$OPEN" | jq -r --arg us "$OUR_NAME" '.bounties[]? | select((.mode // "instant") == "instant" and ((.poster_name // "") | ascii_downcase) != $us) | select((.amount | tonumber? // 0) == 0) | .id' 2>/dev/null)
if [[ -z "$INSTANT_IDS" ]]; then
  # Fallback: no ascii_downcase or amount filter (older jq)
  INSTANT_IDS=$(echo "$OPEN" | jq -r '.bounties[]? | select((.mode // "instant") == "instant") | select(.poster_name != "jobmaster" and .poster_name != "jobmaster2" and .poster_name != "jobmaster3") | select((.amount | tonumber? // 0) == 0) | .id' 2>/dev/null)
fi
COUNT=0
for id in $INSTANT_IDS; do
  [[ -z "$id" ]] && continue
  R=$(curl -sS -X POST "$API_BASE/bounties/$id/claim" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d '{}')
  if ! echo "$R" | jq -e '.error' >/dev/null 2>&1; then
    COUNT=$((COUNT + 1))
    echo "Claimed $id"
  else
    err=$(echo "$R" | jq -r '.error // .code // "unknown"' 2>/dev/null)
    echo "Skip $id: $err"
  fi
  [[ $COUNT -ge 10 ]] && break
done
echo "Claimed $COUNT instant bounty(ies)."
