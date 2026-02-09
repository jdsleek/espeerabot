#!/usr/bin/env bash
# Quick check: gateway, admin, credentials, cron-results. Run from repo root.
# Usage: ./sentinel-nexus/check-openclaw-status.sh

set -e
echo "=== OpenClaw / Agency status ==="
echo ""

# Gateway (default 18789)
if curl -s -o /dev/null -w "" --connect-timeout 2 "http://127.0.0.1:18789/" 2>/dev/null; then
  echo "  Gateway:     RUNNING (http://127.0.0.1:18789)"
else
  echo "  Gateway:     NOT RUNNING — start with: openclaw gateway run"
fi

# Admin dashboard (3880)
if curl -s -o /dev/null -w "" --connect-timeout 2 "http://127.0.0.1:3880/api/agency" 2>/dev/null; then
  echo "  Admin:       RUNNING (http://127.0.0.1:3880)"
else
  echo "  Admin:       NOT RUNNING — start with: node sentinel-nexus/admin/server.js"
fi

# Credentials
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
for f in clawtasks-credentials.json moltbook-credentials.json; do
  if [[ -f "$OPENCLAW/$f" ]]; then
    echo "  $f: OK"
  else
    echo "  $f: missing (optional for agency: moltbook)"
  fi
done

# Workspace cron-results (brain writes here)
if [[ -d "${OPENCLAW}/workspace/cron-results" ]]; then
  echo "  cron-results: exists"
else
  echo "  cron-results: missing — mkdir -p $OPENCLAW/workspace/cron-results"
fi

echo ""
echo "Crons run every 5 min when gateway is running. Full 24/7: ./sentinel-nexus/run-agency-24-7.sh"
