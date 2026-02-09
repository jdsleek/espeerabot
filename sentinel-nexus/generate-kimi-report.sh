#!/usr/bin/env bash
# Generate a research report using Kimi 2.5 via OpenClaw. Gateway must be running.
# Writes raw CLI output to workspace/cron-results/kimi-sachet-report.txt.
# Usage: ./sentinel-nexus/generate-kimi-report.sh

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
OUT="$OPENCLAW/workspace/cron-results/kimi-sachet-report.txt"
mkdir -p "$(dirname "$OUT")"

PROMPT="You are a research analyst. Write a detailed research report (about 500-600 words) on: Best practices for sachet water sales in Lagos, Nigeria. Use this exact structure and write only the report, no preamble or meta-commentary:

## Executive summary
(2 short paragraphs: main channels, what drives volume and trust, and what matters for margins in Lagos.)

## Key findings
(5 numbered findings. Each 2-4 sentences. Include Lagos-specific context: areas like Oshodi, Agege, markets; pure water culture; NAFDAC; pricing in Naira; kiosks vs mobile vendors.)

## Recommendations
(5 actionable recommendations. Be specific: e.g. pilot in one area, partner with 3-5 kiosks, branding and seal, pricing per sachet/pack, retailer support.)

End your reply with exactly: ---END REPORT---"

if ! command -v openclaw &>/dev/null; then
  echo "ERROR: openclaw not in PATH. Install OpenClaw and ensure the gateway can run."
  exit 1
fi

# Run one-off event and wait for final response so we capture the report. Gateway must be running.
openclaw system event --text "$PROMPT" --mode now --expect-final --timeout 120000 2>&1 | tee "$OUT" || true

# Extract report section if output contains wrapper text (e.g. from --expect-final)
if [[ -s "$OUT" ]]; then
  if grep -q "## Executive summary" "$OUT" 2>/dev/null; then
    # Keep only from first heading to ---END REPORT--- or end
    sed -n '/## Executive summary/,$p' "$OUT" | sed '/---END REPORT---/q' | sed '/---END REPORT---/d' > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"
  fi
  echo "Report written to $OUT"
else
  echo "No output captured. Is the gateway running? Try: openclaw gateway run"
  exit 1
fi
