#!/usr/bin/env bash
# Merges openclaw-gateway-patch.json into openclaw.json so Control UI can connect
# without device pairing (fixes "disconnected 1008: pairing required").
#
# Usage:
#   ./apply-gateway-patch.sh [path-to-openclaw.json]
# If no path given, uses OPENCLAW_STATE_DIR/openclaw.json or ~/.openclaw/openclaw.json
#
# For Railway backup: extract backup, then:
#   ./apply-gateway-patch.sh path/to/extracted/.clawdbot/openclaw.json
# Then re-upload/restore the backup if your setup supports it.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH="$SCRIPT_DIR/openclaw-gateway-patch.json"

CONFIG="${1:-}"
if [ -z "$CONFIG" ]; then
  OPENCLAW="${OPENCLAW_STATE_DIR:-${HOME}/.openclaw}"
  CONFIG="$OPENCLAW/openclaw.json"
  # Clawdbot Railway often uses .clawdbot
  if [ ! -f "$CONFIG" ]; then
    CONFIG="$OPENCLAW/../.clawdbot/openclaw.json"
  fi
  if [ ! -f "$CONFIG" ]; then
    CONFIG="/data/.clawdbot/openclaw.json"
  fi
fi

if [ ! -f "$CONFIG" ]; then
  echo "Config not found: $CONFIG" >&2
  echo "Usage: $0 [path-to-openclaw.json]" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install with: brew install jq (macOS) or apt install jq (Linux)" >&2
  exit 1
fi

if [ ! -f "$PATCH" ]; then
  echo "Patch file not found: $PATCH" >&2
  exit 1
fi

echo "Merging patch into $CONFIG"
TMP="$CONFIG.tmp.$$"
# Deep-merge: set gateway.controlUi.allowInsecureAuth = true without overwriting other gateway keys
jq '.gateway.controlUi = ((.gateway.controlUi // {}) + {"allowInsecureAuth": true})' "$CONFIG" > "$TMP" && mv "$TMP" "$CONFIG"
echo "Done. gateway.controlUi.allowInsecureAuth is now true. Restart the gateway if it is running."
