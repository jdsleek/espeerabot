#!/usr/bin/env bash
# Submit good proposals from ALL enabled agents (maximize: each agent has 10/hour quota = 30/hour total).
# Usage: ./sentinel-nexus/submit-proposals-now.sh [max_per_agent]

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS_JSON="$SENTINEL/agency-agents.json"
API_BASE="https://clawtasks.com/api"
MAX_PER_AGENT="${1:-10}"

if [[ ! -f "$AGENTS_JSON" ]]; then
  echo "No $AGENTS_JSON"
  exit 1
fi

# Get list of proposal bounty IDs (not ours) — use first available agent to fetch
AGENTS=()
while IFS= read -r cf; do
  [[ -n "$cf" && -f "$OPENCLAW/$cf" ]] && AGENTS+=( "$cf" )
done < <(jq -r '.agents[]? | select(.enabled == true) | .credentialsFile // empty' "$AGENTS_JSON" 2>/dev/null)
[[ ${#AGENTS[@]} -eq 0 ]] && { echo "No enabled agents"; exit 1; }

FIRST_KEY=$(jq -r '.api_key // empty' "$OPENCLAW/${AGENTS[0]}")
[[ -z "$FIRST_KEY" ]] && { echo "No API key"; exit 1; }
OPEN=$(curl -sS -H "Authorization: Bearer $FIRST_KEY" "$API_BASE/bounties?status=open" | tr -d '\000-\010\013-\037')
BountyIDs=()
while IFS= read -r id; do [[ -n "$id" ]] && BountyIDs+=( "$id" ); done < <(echo "$OPEN" | jq -r '.bounties[]? | select(.mode == "proposal") | select((.poster_name // "" | ascii_downcase) != "jobmaster" and (.poster_name // "" | ascii_downcase) != "jobmaster2" and (.poster_name // "" | ascii_downcase) != "jobmaster3") | .id' 2>/dev/null)
[[ ${#BountyIDs[@]} -eq 0 ]] && BountyIDs=($(echo "$OPEN" | jq -r '.bounties[]? | select(.mode == "proposal") | select(.poster_name != "jobmaster" and .poster_name != "jobmaster2" and .poster_name != "jobmaster3") | .id' 2>/dev/null))

echo "=== Submit proposals (all agents, max ${MAX_PER_AGENT} per agent = $(( MAX_PER_AGENT * ${#AGENTS[@]} )) total) ==="
TOTAL=0
# Each agent gets a slice of bounties so we maximize coverage (no duplicate proposals to same bounty per run)
for i in "${!AGENTS[@]}"; do
  cf="${AGENTS[$i]}"
  KEY=$(jq -r '.api_key // empty' "$OPENCLAW/$cf")
  AGENT_NAME=$(jq -r '.agent_name // .agent_name // "jobmaster"' "$OPENCLAW/$cf" 2>/dev/null)
  [[ -z "$KEY" ]] && continue
  # Slice: agent 0 gets 0, N, 2N...; agent 1 gets 1, N+1, 2N+1... (N = num agents)
  N=${#AGENTS[@]}
  COUNT=0
  for (( j = i; j < ${#BountyIDs[@]} && COUNT < MAX_PER_AGENT; j += N )); do
    id="${BountyIDs[$j]}"
    TITLE=$(echo "$OPEN" | jq -r --arg id "$id" '.bounties[]? | select(.id == $id) | .title[0:55]' 2>/dev/null)
    PROPOSAL="$AGENT_NAME: We will deliver on \"${TITLE}\" with a clear report (summary, findings, recommendations). Completed bounties on ClawTasks; on-time delivery. Ready to start."
    R=$(curl -sS -X POST "$API_BASE/bounties/$id/propose" \
      -H "Authorization: Bearer $KEY" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg p "$PROPOSAL" '{proposal: $p}')")
    if ! echo "$R" | jq -e '.error' >/dev/null 2>&1; then
      COUNT=$((COUNT + 1))
      TOTAL=$((TOTAL + 1))
      echo "[${cf%.json}] Proposed: $id — ${TITLE:0:35}…"
    else
      echo "[${cf%.json}] Skip $id: $(echo "$R" | jq -r '.error // .')"
    fi
  done
  echo "  → ${COUNT} from this agent"
done
echo "Submitted $TOTAL proposal(s) across ${#AGENTS[@]} agent(s). View Analysis or ClawTasks."