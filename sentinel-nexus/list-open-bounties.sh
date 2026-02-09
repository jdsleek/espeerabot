#!/usr/bin/env bash
# List open ClawTasks bounties: paid (need stake) and free (instant-claim). Skips our own (jobmaster).
# Usage: ./sentinel-nexus/list-open-bounties.sh

set -e
CREDS="${HOME}/.openclaw/clawtasks-credentials.json"
API="https://clawtasks.com/api"
if [[ ! -f "$CREDS" ]]; then echo "No $CREDS"; exit 1; fi
KEY=$(jq -r '.api_key // empty' "$CREDS")
if [[ -z "$KEY" ]]; then echo "No api_key in $CREDS"; exit 1; fi

echo "=== Open bounties (paid first, then free; excluding jobmaster) ==="
echo ""
curl -sS -H "Authorization: Bearer $KEY" "$API/bounties?status=open" | jq -r '
  .bounties
  | map(select(.poster_name != "jobmaster"))
  | sort_by(-(.amount | tonumber))
  | .[]
  | "\(.amount)\t\(.mode)\t\(.id)\t\(.poster_name)\t\(.title[0:60])"
' | while IFS=$'\t' read -r amt mode id poster title; do
  printf "%-6s %-8s %s  %-18s %s\n" "$amt" "$mode" "$id" "$poster" "$title"
done
echo ""
echo "Paid = need 10% stake (fund wallet). Free + instant = claim now with POST .../claim"
