#!/usr/bin/env bash
# Go outside: hit ClawTasks in real time and don't rest until there's no free work left.
# Runs all enabled agents: claim every instant bounty, submit every pending, repeat until nothing to do.
# Usage: ./sentinel-nexus/drain-free-work.sh

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS_JSON="$SENTINEL/agency-agents.json"
MAX_ROUNDS="${MAX_ROUNDS:-30}"

if [[ ! -f "$AGENTS_JSON" ]]; then
  echo "No $AGENTS_JSON"
  exit 1
fi

# Get enabled agents' credential filenames (no path)
AGENTS=()
while IFS= read -r cf; do
  [[ -n "$cf" && -f "$OPENCLAW/$cf" ]] && AGENTS+=( "$cf" )
done < <(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null)

if [[ ${#AGENTS[@]} -eq 0 ]]; then
  echo "No enabled agents with credentials found."
  exit 1
fi

echo "=== Drain free work (real-time, don't rest till nothing to do) ==="
echo "Agents: ${AGENTS[*]}"
echo ""

round=0
while [[ $round -lt $MAX_ROUNDS ]]; do
  round=$((round + 1))
  total_claimed=0
  total_submitted=0

  for cf in "${AGENTS[@]}"; do
    name="${cf%.json}"
    name="${name#clawtasks-credentials-}"
    echo "[round $round] $name: claim..."
    out=$(CREDS_FILE="$cf" bash "$SENTINEL/claim-all-instant.sh" 2>&1) || true
    echo "$out"
    n=$(echo "$out" | sed -n 's/Claimed \([0-9]*\).*/\1/p')
    [[ -n "$n" ]] && total_claimed=$((total_claimed + n))
  done

  for cf in "${AGENTS[@]}"; do
    name="${cf%.json}"
    name="${name#clawtasks-credentials-}"
    echo "[round $round] $name: submit pending..."
    out=$(CREDS_FILE="$cf" MAX_SUBMIT=20 bash "$SENTINEL/submit-2-pending.sh" 2>&1) || true
    echo "$out"
    n=$(echo "$out" | sed -n 's/Submitted \([0-9]*\).*/\1/p')
    [[ -n "$n" ]] && total_submitted=$((total_submitted + n))
  done

  echo "[round $round] auto-approve our bounties (so workers get completion)..."
  bash "$SENTINEL/auto-approve-ours.sh" 2>&1 || true

  echo "Round $round: claimed=$total_claimed submitted=$total_submitted"
  if [[ $total_claimed -eq 0 && $total_submitted -eq 0 ]]; then
    echo "Nothing left to do. Done."
    exit 0
  fi
  sleep 3
done

echo "Reached max rounds ($MAX_ROUNDS). Run again to continue."
exit 0
