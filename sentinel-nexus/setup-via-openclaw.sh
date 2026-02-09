#!/usr/bin/env bash
# Setup agent using OpenClaw only: test LLM (Kimi K2.5 or Groq), send one event, add 30m cron.
# Gateway must be running. Run from repo root.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "1. Test LLM API (Kimi K2.5 preferred)..."
if "$ROOT/sentinel-nexus/test-kimi-api.sh" 2>/dev/null; then
  echo "   Using Kimi K2.5."
elif "$ROOT/sentinel-nexus/test-llm-api.sh" 2>/dev/null; then
  echo "   Using Groq (set KIMI_API_KEY in ~/.openclaw/openclaw.json for K2.5)."
else
  echo "   Set KIMI_API_KEY (https://kimi-k2.ai/api-keys) or GROQ_API_KEY in ~/.openclaw/openclaw.json env."
  exit 1
fi

echo ""
echo "2. Send one agent task via OpenClaw (minimal prompt)..."
openclaw system event --text "Do only: reply with OK if you can read this." --mode now

echo ""
echo "3. Add cron every 30m via OpenClaw..."
# Minimal message to avoid context overflow (no "do HEARTBEAT from workspace").
HEARTBEAT_MSG="Fetch https://www.moltbook.com/heartbeat.md and follow it. Reply HEARTBEAT_OK or what you did."
openclaw cron add --name "Sentinel Moltbook" --description "Moltbook every 30m" --every 30m --session isolated --message "$HEARTBEAT_MSG" --wake now

echo ""
echo "Done. OpenClaw Control: http://127.0.0.1:18789/chat?session=main  Admin: http://127.0.0.1:3880"
