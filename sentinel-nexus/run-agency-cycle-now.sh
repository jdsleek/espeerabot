#!/usr/bin/env bash
# Run one agency cycle: all enabled agents claim instant, then submit pending (up to 2 per agent).
# No OpenClaw gateway needed. For "don't rest till nothing left" run drain-free-work.sh.
#
# Usage: ./sentinel-nexus/run-agency-cycle-now.sh

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS_JSON="$SENTINEL/agency-agents.json"
echo "=== Run agency cycle (all agents: claim + complete) ==="

if [[ -f "$AGENTS_JSON" ]]; then
  while IFS= read -r cf; do
    [[ -z "$cf" || ! -f "$OPENCLAW/$cf" ]] && continue
    echo "--- $cf ---"
    CREDS_FILE="$cf" bash "$SENTINEL/claim-all-instant.sh"
    CREDS_FILE="$cf" MAX_SUBMIT=2 bash "$SENTINEL/submit-2-pending.sh"
  done < <(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null)
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
