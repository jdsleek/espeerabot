#!/usr/bin/env bash
# Backup and clear the main session transcript so the next chat in main is fresh.
# Run with the OpenClaw gateway STOPPED. Then start the gateway again.
set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
AGENTS="$OPENCLAW/agents"
if [[ ! -d "$AGENTS" ]]; then
  echo "No agents dir: $AGENTS"
  exit 1
fi
# Default agent is often the first or only dir under agents
AGENT_ID=$(ls -1 "$AGENTS" 2>/dev/null | head -1)
if [[ -z "$AGENT_ID" ]]; then
  echo "No agent found under $AGENTS"
  exit 1
fi
SESSIONS="$AGENTS/$AGENT_ID/sessions"
if [[ ! -d "$SESSIONS" ]]; then
  echo "No sessions dir: $SESSIONS"
  exit 1
fi
SESSIONS_JSON="$SESSIONS/sessions.json"
if [[ ! -f "$SESSIONS_JSON" ]]; then
  echo "No sessions.json: $SESSIONS_JSON"
  exit 1
fi
# Main chat session key is agent:AGENT_ID:main
MAIN_KEY="agent:${AGENT_ID}:main"
SESSION_ID=$(jq -r --arg k "$MAIN_KEY" '.[$k].sessionId // empty' "$SESSIONS_JSON" 2>/dev/null)
if [[ -z "$SESSION_ID" ]]; then
  echo "Could not get sessionId for $MAIN_KEY from $SESSIONS_JSON"
  exit 1
fi
TRANSCRIPT="$SESSIONS/${SESSION_ID}.jsonl"
if [[ -f "$TRANSCRIPT" ]]; then
  BACKUP="$SESSIONS/${SESSION_ID}.jsonl.bak.$(date +%Y%m%d%H%M%S)"
  cp "$TRANSCRIPT" "$BACKUP"
  echo "Backed up to $BACKUP"
  rm -f "$TRANSCRIPT"
fi
# Clear sessionId for main so gateway creates a new transcript on next message
jq --arg k "$MAIN_KEY" '.[$k].sessionId = ""' "$SESSIONS_JSON" > "$SESSIONS_JSON.tmp" && mv "$SESSIONS_JSON.tmp" "$SESSIONS_JSON"
echo "Cleared main session. Start the gateway again and open chat; you get a fresh conversation."
