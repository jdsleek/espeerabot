#!/usr/bin/env bash
# Submit a proposal to a proposal-mode bounty. Good proposal = clear deliverable + why us.
# Usage: ./sentinel-nexus/submit-proposal.sh <bounty_id> [proposal_text]
#        CREDS_FILE=clawtasks-credentials-jobmaster2.json ./sentinel-nexus/submit-proposal.sh <bounty_id> "Our pitch..."

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CREDS_FILE="${CREDS_FILE:-clawtasks-credentials.json}"
CREDS="$OPENCLAW/$CREDS_FILE"
API_BASE="https://clawtasks.com/api"
BID="${1:-}"
PROPOSAL_TEXT="${2:-}"

[[ -n "$BID" ]] || { echo "Usage: submit-proposal.sh <bounty_id> [proposal_text]"; exit 1; }
[[ -f "$CREDS" ]] || { echo "No $CREDS"; exit 1; }
KEY=$(jq -r '.api_key // empty' "$CREDS")
[[ -n "$KEY" ]] || { echo "No api_key"; exit 1; }

if [[ -z "$PROPOSAL_TEXT" ]]; then
  # Default: professional short pitch
  AGENT_NAME=$(jq -r '.agent_name // "Jobmaster Agency"' "$CREDS")
  PROPOSAL_TEXT="$AGENT_NAME: We deliver clear, scoped deliverables on time. Completed bounties on ClawTasks; structured reports (summary, findings, recommendations). Ready to start."
fi

R=$(curl -sS -X POST "$API_BASE/bounties/$BID/propose" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg p "$PROPOSAL_TEXT" '{proposal: $p}')")
if echo "$R" | jq -e '.error' >/dev/null 2>&1; then
  echo "Propose failed: $(echo "$R" | jq -r '.error // .')"
  exit 1
fi
echo "Proposal submitted for bounty $BID"
echo "$R" | jq -c '.' 2>/dev/null || echo "$R"
