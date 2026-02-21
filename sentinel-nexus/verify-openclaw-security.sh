#!/usr/bin/env bash
# Verify OpenClaw security posture. Run before starting 24/7.
# Usage: ./sentinel-nexus/verify-openclaw-security.sh

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CONFIG="$OPENCLAW/openclaw.json"
OK=0
FAIL=0

echo "=== OpenClaw Security Check ==="
echo ""

# 1. Gateway bind
if [[ -f "$CONFIG" ]]; then
  BIND=$(jq -r '.gateway.bind // "NOT_SET"' "$CONFIG" 2>/dev/null || echo "PARSE_FAIL")
  if [[ "$BIND" == "loopback" ]]; then
    echo "✓ Gateway bind: loopback (safe)"
    ((OK++))
  else
    echo "✗ Gateway bind: $BIND — should be 'loopback'. Edit $CONFIG"
    ((FAIL++))
  fi
else
  echo "? No openclaw.json at $CONFIG (not yet configured)"
fi

# 2. No credentials in repo
if git rev-parse --git-dir >/dev/null 2>&1; then
  if git ls-files | grep -qE 'openclaw\.json|credentials.*\.json|registration\.json'; then
    echo "✗ DANGER: Credentials or config in git. Run: git reset HEAD <file>"
    ((FAIL++))
  else
    echo "✓ No credentials committed to repo"
    ((OK++))
  fi
fi

# 3. Skills dir (informational)
if [[ -d "$OPENCLAW/skills" ]]; then
  COUNT=$(find "$OPENCLAW/skills" -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')
  echo "  Skills installed: $COUNT (audit: ls $OPENCLAW/skills)"
else
  echo "  No skills dir (OK if fresh install)"
fi

# 4. Registration files permissions
for f in "$OPENCLAW"/*-registration.json; do
  if [[ -f "$f" ]]; then
    perms=$(stat -f "%Lp" "$f" 2>/dev/null || stat -c "%a" "$f" 2>/dev/null || echo "?")
    if [[ "$perms" == "600" ]]; then
      echo "✓ $f has chmod 600"
      ((OK++))
    else
      echo "! $f has permissions $perms — run: chmod 600 $f"
    fi
  fi
done

echo ""
if [[ $FAIL -gt 0 ]]; then
  echo "Result: $FAIL issue(s) need fixing. Do not expose OpenClaw to the internet."
  exit 1
else
  echo "Result: OK ($OK checks passed). Safe to run."
  exit 0
fi
