#!/usr/bin/env bash
# Start Jobmaster Agency 24/7: OpenClaw gateway (crons every 5min) + admin dashboard.
# Run from repo root. Keep this terminal open or run in tmux/screen for 24/7.
#
# Usage: ./sentinel-nexus/run-agency-24-7.sh

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SENTINEL="$REPO_ROOT/sentinel-nexus"
cd "$REPO_ROOT"

echo "=== Jobmaster Agency — 24/7 ==="
echo ""

# 1. OpenClaw gateway (runs crons every 5 min: ClawTasks + Moltbook)
if ! command -v openclaw &>/dev/null; then
  echo "OpenClaw CLI not in PATH. Install OpenClaw and ensure 'openclaw' works."
  exit 1
fi
echo "Starting OpenClaw gateway (crons every 5 min)..."
openclaw gateway run &
GATEWAY_PID=$!
sleep 3
echo "  Gateway PID: $GATEWAY_PID"
echo ""

# 2. Admin dashboard (kill previous if on 3880)
if command -v lsof &>/dev/null; then
  lsof -ti:3880 2>/dev/null | xargs kill 2>/dev/null && sleep 1 || true
fi
echo "Starting admin dashboard on http://127.0.0.1:3880 ..."
OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}" node "$SENTINEL/admin/server.js" &
ADMIN_PID=$!
sleep 2
echo "  Admin PID: $ADMIN_PID"
echo ""

# 3. Claim instant bounties once so we have work
bash "$SENTINEL/claim-all-instant.sh" 2>/dev/null || true
echo ""

# 4. Run one full cycle immediately so any already-claimed human-front job gets submitted right away
echo "Running one cycle now (submit any claimed jobs)..."
export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
bash "$SENTINEL/run-agency-cycle-now.sh" 2>/dev/null || true
echo ""

# 5. Autonomous cycle loop: every 2 min run full cycle (claim → submit pending → submit human-front claimed → auto-approve)
#    So jobs get submitted without you clicking "Run cycle now".
echo "Starting autonomous cycle loop (every 2 min: claim, submit, approve)..."
(
  export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
  while true; do
    sleep 120
    bash "$SENTINEL/run-agency-cycle-now.sh" 2>/dev/null || true
  done
) &
LOOP_PID=$!
echo "  Cycle loop PID: $LOOP_PID"
echo ""

echo "--- Agency running (full autonomy) ---"
echo "  Hub (all links): http://127.0.0.1:3880/hub"
echo "  Landing:         http://127.0.0.1:3880/"
echo "  Admin:           http://127.0.0.1:3880/admin   → dashboard, workers, completed, analysis, brain"
echo "  OpenClaw UI:     http://127.0.0.1:18789/?token=YOUR_GATEWAY_TOKEN  (gateway; brain + Moltbook every 5 min)"
echo "  Cycle loop: every 2 min — claim, submit, human-front fallback, auto-approve"
echo "  Moltbook: 24/7 active (if enabled). Add once: ./sentinel-nexus/enable-auto-moltbook.sh"
echo ""
echo "Keep this session open for 24/7. Or run in tmux/screen: tmux new -s agency ./sentinel-nexus/run-agency-24-7.sh"
echo "To stop: kill $GATEWAY_PID $ADMIN_PID $LOOP_PID"
