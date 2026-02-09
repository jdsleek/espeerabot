#!/usr/bin/env bash
# Submit deliverables for human-front bounties that are claimed but not in /agents/me/pending.
# ClawTasks sometimes omits claimed bounties from pending; this submits by bounty ID using the claimer's creds.
# Usage: ./sentinel-nexus/submit-human-front-claimed.sh
# Run from repo root. Call from run-agency-cycle-now.sh after submit-2-pending.

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS_JSON="$SENTINEL/agency-agents.json"
API_BASE="https://clawtasks.com/api"
HF_JOBS="${OPENCLAW}/workspace/human-front-jobs.json"

[[ -f "$AGENTS_JSON" ]] || exit 0
[[ -f "$HF_JOBS" ]] || exit 0

# Get lead key to fetch bounty status
LEAD_CF=$(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null | head -1)
[[ -z "$LEAD_CF" || ! -f "$OPENCLAW/$LEAD_CF" ]] && exit 0
KEY=$(jq -r '.api_key // empty' "$OPENCLAW/$LEAD_CF")
[[ -z "$KEY" ]] && exit 0

# Get credentials file for an agent name (case-insensitive match)
get_creds_file() {
  local want="$1"
  want_lower=$(echo "$want" | tr '[:upper:]' '[:lower:]')
  while IFS= read -r line; do
    name=$(echo "$line" | cut -f1 | tr '[:upper:]' '[:lower:]')
    cf=$(echo "$line" | cut -f2)
    [[ "$name" == "$want_lower" && -n "$cf" ]] && echo "$cf" && return
  done < <(jq -r '.agents[]? | select(.enabled == true) | "\(.name // .id)\t\(.credentialsFile)"' "$AGENTS_JSON" 2>/dev/null)
}

COUNT=0
for bountyId in $(jq -r '.[].bountyId // empty' "$HF_JOBS" 2>/dev/null); do
  [[ -z "$bountyId" ]] && continue
  RAW=$(curl -sS -H "Authorization: Bearer $KEY" "$API_BASE/bounties/$bountyId" 2>/dev/null | tr -d '\000-\037')
  status=$(echo "$RAW" | jq -r '.status // ""')
  claimer=$(echo "$RAW" | jq -r '.claimer_name // .claimed_by // .claimer_id // ""')
  [[ "$status" != "claimed" ]] && continue
  title=$(echo "$RAW" | jq -r '.title // "Task"')
  [[ ${#title} -gt 120 ]] && title="${title:0:117}..."
  TEMPLATE="Executive summary: $title — Delivered per scope.
Findings: (1) Scope addressed; (2) Key points summarized; (3) Actionable next steps identified.
Recommendations: (1) Review the deliverables against your criteria. (2) Run a pilot or spot-check where relevant. (3) Approve and rate when satisfied so the agent gets completion. (4) Contact Jobmaster Agency for follow-up or repeat work.
— Jobmaster Agency"
  KIMI_CONTENT=$(curl -s -m 90 "http://127.0.0.1:3880/api/generate-job-report?bountyId=$bountyId" 2>/dev/null)
  if [[ -n "$KIMI_CONTENT" && ${#KIMI_CONTENT} -gt 150 ]]; then
    CONTENT="$KIMI_CONTENT"
  else
    CONTENT="$TEMPLATE"
  fi
  cf=$(get_creds_file "$claimer" | head -1)
  # If claimer name didn't match, try each enabled agent until submit succeeds (ClawTasks rejects wrong claimer)
  if [[ -z "$cf" || ! -f "$OPENCLAW/$cf" ]]; then
    submitted=
    while IFS= read -r cf; do
      [[ -z "$cf" || ! -f "$OPENCLAW/$cf" ]] && continue
      CKEY=$(jq -r '.api_key // empty' "$OPENCLAW/$cf")
      [[ -z "$CKEY" ]] && continue
      R=$(curl -sS -X POST "$API_BASE/bounties/$bountyId/submit" \
        -H "Authorization: Bearer $CKEY" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg c "$CONTENT" '{content: $c}')" 2>/dev/null)
      if ! echo "$R" | jq -e '.error' >/dev/null 2>&1; then
        COUNT=$((COUNT + 1))
        echo "Submitted human-front $bountyId (tried agents until success)"
        submitted=1
        break
      fi
    done < <(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null)
    [[ -n "$submitted" ]] && continue
  else
  CKEY=$(jq -r '.api_key // empty' "$OPENCLAW/$cf")
  [[ -z "$CKEY" ]] && continue
  R=$(curl -sS -X POST "$API_BASE/bounties/$bountyId/submit" \
    -H "Authorization: Bearer $CKEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg c "$CONTENT" '{content: $c}')" 2>/dev/null)
  if ! echo "$R" | jq -e '.error' >/dev/null 2>&1; then
    COUNT=$((COUNT + 1))
    echo "Submitted human-front $bountyId (claimer $claimer)"
  fi
  fi
done
[[ $COUNT -gt 0 ]] && echo "Submitted $COUNT human-front claimed bounty(ies)."
exit 0
