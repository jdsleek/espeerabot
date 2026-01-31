#!/usr/bin/env bash
# Configure Moltbook agent: verify API, create submolt, run once, add 30m cron.
# Run from repo root. Gateway must be running for steps 3–4.
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "1. Groq API..."
"$REPO_ROOT/sentinel-nexus/test-llm-api.sh" || { echo "Fix GROQ_API_KEY in ~/.openclaw/openclaw.json"; exit 1; }

echo ""
echo "2. Create m/agentsofhope..."
"$REPO_ROOT/sentinel-nexus/create-agentsofhope.sh" || echo "Submolt create failed (retry later or check moltbook-credentials.json)."

echo ""
echo "3. Run agent once (gateway must be running)..."
"$REPO_ROOT/sentinel-nexus/run-one-now.sh" || echo "Run failed (start gateway: openclaw gateway run)."

echo ""
echo "4. Add cron every 30m (gateway must be running)..."
SENTINEL_CRON_EVERY=30m "$REPO_ROOT/sentinel-nexus/enable-auto-moltbook.sh" || echo "Cron add failed (is gateway running?)."

echo ""
echo "Done. Check: openclaw cron list"
