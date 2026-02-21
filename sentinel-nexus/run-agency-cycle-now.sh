#!/usr/bin/env bash
# Run one agency cycle: all enabled agents claim instant, then submit pending (up to 2 per agent).
# No OpenClaw gateway needed. For "don't rest till nothing left" run drain-free-work.sh.
# Logs actions to workspace/cron-results/cycle-actions.log for live dashboard.
#
# Usage: ./sentinel-nexus/run-agency-cycle-now.sh

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS_JSON="$SENTINEL/agency-agents.json"
RESULTS_DIR="${OPENCLAW}/workspace/cron-results"
ACTIONS_LOG="${RESULTS_DIR}/cycle-actions.log"
mkdir -p "$RESULTS_DIR"

append_action() {
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $1 $2 $3" >> "$ACTIONS_LOG"
}

echo "=== Run agency cycle (all agents: claim + complete) ==="

if [[ -f "$AGENTS_JSON" ]]; then
  while IFS= read -r cf; do
    [[ -z "$cf" || ! -f "$OPENCLAW/$cf" ]] && continue
    AGENT_NAME=$(jq -r --arg f "$cf" '.agents[]? | select(.credentialsFile == $f) | .name // .id // "agent"' "$AGENTS_JSON" 2>/dev/null | head -1)
    [[ -z "$AGENT_NAME" ]] && AGENT_NAME="${cf%-credentials*.json}" && AGENT_NAME="${AGENT_NAME#clawtasks-}"
    echo "--- $cf ---"
    OUT=$(CREDS_FILE="$cf" bash "$SENTINEL/claim-all-instant.sh" 2>&1) || true
    echo "$OUT"
    while read -r line; do
      id="${line#Claimed }"
      [[ -n "$id" ]] && append_action "$AGENT_NAME" "claimed" "$id"
    done <<< "$(echo "$OUT" | grep -o "Claimed [a-f0-9-]*")"
    OUT2=$(CREDS_FILE="$cf" MAX_SUBMIT=2 bash "$SENTINEL/submit-2-pending.sh" 2>&1) || true
    echo "$OUT2"
    while read -r line; do
      id="${line#Submitted bounty }"
      [[ -n "$id" ]] && append_action "$AGENT_NAME" "submitted" "$id"
    done <<< "$(echo "$OUT2" | grep -o "Submitted bounty [a-f0-9-]*")"
  done < <(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null)
  # Trim actions log
  [[ -f "$ACTIONS_LOG" ]] && tail -200 "$ACTIONS_LOG" > "${ACTIONS_LOG}.tmp" && mv "${ACTIONS_LOG}.tmp" "$ACTIONS_LOG"
  bash "$SENTINEL/submit-human-front-claimed.sh" 2>/dev/null || true
else
  bash "$SENTINEL/claim-all-instant.sh"
  bash "$SENTINEL/submit-2-pending.sh"
fi
# Human-front: submit any claimed bounties that don't appear in /agents/me/pending
bash "$SENTINEL/submit-human-front-claimed.sh" 2>/dev/null || true
echo "Auto-approving our bounties (review & approve so workers get completion)..."
bash "$SENTINEL/auto-approve-ours.sh" 2>&1 || true
echo ""
echo "Done. To drain all free work: ./sentinel-nexus/drain-free-work.sh"
