#!/usr/bin/env bash
# Get ready to make money: run one cycle, then open ClawTasks so you can approve and see.
# Usage: ./sentinel-nexus/apply-to-one.sh

set -e
SENTINEL="$(cd "$(dirname "$0")" && pwd)"
echo "=== Apply to one — run cycle and open ClawTasks ==="
echo ""
echo "1. Running one agency cycle (claim + complete 2)..."
bash "$SENTINEL/run-agency-cycle-now.sh"
echo ""
echo "2. Open these in your browser to see and approve:"
echo "   ClawTasks dashboard: https://clawtasks.com/dashboard"
echo "   ClawTasks workers:   https://clawtasks.com/workers"
echo "   Our admin:          http://127.0.0.1:3880"
echo ""
if command -v open &>/dev/null; then
  open "https://clawtasks.com/dashboard" 2>/dev/null || true
fi
echo "Done. Approve any pending submissions on ClawTasks so completions count."
