#!/usr/bin/env bash
# Ask your Moltbook bot to send the "set up your account" magic link to an email.
# Moltbook: "No account found with this email. If you already have a bot, ask it to set up your account."
# Usage: ./sentinel-nexus/moltbook-setup-owner-email.sh your@email.com
#        EMAIL=your@email.com ./sentinel-nexus/moltbook-setup-owner-email.sh
#        MOLTBOOK_CREDS=path/to/sentinel-nexus-creds.json $0 jdsleek@gmail.com   # use specific agent
# Uses MOLTBOOK_CREDS, or ~/.openclaw/moltbook-credentials.json, or nexus-chapel-credentials.json.

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
EMAIL="${1:-$EMAIL}"
if [[ -z "$EMAIL" ]]; then
  echo "Usage: $0 your@email.com   or   EMAIL=your@email.com $0"
  exit 1
fi

# If user passed a specific creds file (e.g. for Sentinel_Nexus), use it first
CREDS_LIST=()
if [[ -n "$MOLTBOOK_CREDS" && -f "$MOLTBOOK_CREDS" ]]; then
  CREDS_LIST+=("$MOLTBOOK_CREDS")
fi
CREDS_LIST+=("$OPENCLAW/moltbook-credentials.json" "$OPENCLAW/nexus-chapel-credentials.json")

for CREDS in "${CREDS_LIST[@]}"; do
  [[ -f "$CREDS" ]] || continue
  KEY=$(jq -r '.api_key // empty' "$CREDS")
  if [[ -z "$KEY" ]]; then continue; fi
  NAME=$(jq -r '.agent_name // "unknown"' "$CREDS")
  echo "Using agent: $NAME ($CREDS) → sending owner-setup link to $EMAIL ..."
  R=$(curl -sS -m 15 -X POST "https://www.moltbook.com/api/v1/agents/me/setup-owner-email" \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg e "$EMAIL" '{ email: $e }')" 2>/dev/null)
  echo "$R" | jq . 2>/dev/null || echo "$R"
  if echo "$R" | jq -e '.success == true' >/dev/null 2>&1; then
    echo ""
    echo "Check $EMAIL for the magic link from Moltbook (noreply@moltbook.com). Link expires in 15 min."
    exit 0
  fi
  if echo "$R" | jq -e '.message' >/dev/null 2>&1; then
    msg=$(echo "$R" | jq -r '.message')
    if [[ "$msg" == *"claimed"* ]] || [[ "$msg" == *"Claim"* ]]; then
      echo ""
      echo "→ This agent ($NAME) is not claimed. Use a CLAIMED agent (e.g. Sentinel_Nexus)."
      echo "  If you claimed Sentinel_Nexus: put its API key in moltbook-credentials.json:"
      echo "    {\"api_key\": \"YOUR_SENTINEL_NEXUS_KEY\", \"agent_name\": \"Sentinel_Nexus\"}"
      echo "  Get the key from Moltbook dashboard (login with X) or from when you claimed. Then run this script again."
      exit 1
    fi
    echo ""
    echo "Response: $msg"
    exit 1
  fi
  if echo "$R" | jq -e '.error' >/dev/null 2>&1; then
    echo ""
    echo "Try from the Moltbook UI: open a chat with your bot and ask it to set up your account with this email."
    exit 1
  fi
done

echo "No Moltbook API key found in $OPENCLAW/moltbook-credentials.json or nexus-chapel-credentials.json."
echo "Create a bot first (e.g. openclaw agents claim moltbook --name YourBot), then run this script again."
exit 1
