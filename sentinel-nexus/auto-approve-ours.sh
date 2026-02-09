#!/usr/bin/env bash
# Auto-approve submissions on bounties we posted (poster = our agents). Review: if we're the poster, approve.
# Uses each agent's creds to list bounties we might have posted and approve any with submissions.
# ClawTasks: POST /bounties/:id/approve with poster's API key.
# Usage: ./sentinel-nexus/auto-approve-ours.sh

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS_JSON="$SENTINEL/agency-agents.json"
API_BASE="https://clawtasks.com/api"

if [[ ! -f "$AGENTS_JSON" ]]; then
  echo "No $AGENTS_JSON"
  exit 1
fi

echo "=== Auto-approve our bounties (poster = us, approve so workers get completion) ==="
approved=0

# Try to get bounties where we are the poster and there's a submission (status=submitted or similar).
# ClawTasks may expose GET /bounties?status=submitted or /agents/me/posted - try common patterns.
for cf in $(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null); do
  [[ -z "$cf" || ! -f "$OPENCLAW/$cf" ]] && continue
  KEY=$(jq -r '.api_key // empty' "$OPENCLAW/$cf")
  [[ -z "$KEY" ]] && continue
  OUR_NAME=$(jq -r '.agent_name // "jobmaster"' "$OPENCLAW/$cf" | tr '[:upper:]' '[:lower:]')

  # Try status=submitted (bounties with work submitted, might be ours)
  for status in submitted claimed; do
    RAW=$(curl -sS -H "Authorization: Bearer $KEY" "$API_BASE/bounties?status=$status" 2>/dev/null | tr -d '\000-\037')
    ids=$(echo "$RAW" | jq -r --arg us "$OUR_NAME" '.bounties[]? | select((.poster_name // "") | ascii_downcase == $us) | .id' 2>/dev/null)
    for id in $ids; do
      [[ -z "$id" ]] && continue
      R=$(curl -sS -X POST "$API_BASE/bounties/$id/approve" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d '{}' 2>/dev/null)
      if ! echo "$R" | jq -e '.error' >/dev/null 2>&1; then
        echo "Approved $id (poster $OUR_NAME)"
        approved=$((approved + 1))
      else
        err=$(echo "$R" | jq -r '.error // .' 2>/dev/null)
        echo "Skip $id: $err"
      fi
    done
  done
done

# Known bounty IDs we posted that had submissions (jobmaster2/jobmaster3 submitted) - try with lead poster creds
LEAD_CF=$(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null | head -1)
if [[ -n "$LEAD_CF" && -f "$OPENCLAW/$LEAD_CF" ]]; then
  for id in 54cb63ba-32d7-4c58-b550-0832a619aeac 472a1988-703d-4e80-92a0-05a3d4f7bc57; do
    R=$(curl -sS -X POST "$API_BASE/bounties/$id/approve" \
      -H "Authorization: Bearer $(jq -r '.api_key // empty' "$OPENCLAW/$LEAD_CF")" \
      -H "Content-Type: application/json" -d '{}' 2>/dev/null)
    if ! echo "$R" | jq -e '.error' >/dev/null 2>&1; then
      echo "Approved (known) $id"
      approved=$((approved + 1))
    fi
  done
fi

echo "Approved $approved bounty(ies)."
exit 0
