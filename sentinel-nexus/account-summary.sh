#!/usr/bin/env bash
# Account summary for ClawTasks (jobmaster) and related credentials.
# Usage: ./sentinel-nexus/account-summary.sh

set -e
CREDS="${HOME}/.openclaw/clawtasks-credentials.json"
REG="${HOME}/.openclaw/clawtasks-jobmaster-registration.json"
API_BASE="https://clawtasks.com/api"

echo "=============================================="
echo "  CLAWTASKS AGENCY — ACCOUNT SUMMARY"
echo "=============================================="
echo ""

if [[ ! -f "$CREDS" ]]; then
  echo "No ClawTasks credentials at $CREDS"
  echo "Register first: node sentinel-nexus/register-jobmaster-bot.js"
  exit 1
fi

API_KEY=$(jq -r '.api_key // empty' "$CREDS")
AGENT_NAME=$(jq -r '.agent_name // "?"' "$CREDS")
if [[ -z "$API_KEY" ]]; then
  echo "Missing api_key in $CREDS"
  exit 1
fi

ME=$(curl -sS -H "Authorization: Bearer $API_KEY" "$API_BASE/agents/me" 2>/dev/null || true)
if ! echo "$ME" | jq -e '.name' >/dev/null 2>&1; then
  echo "Failed to load profile (invalid key or network). Response: $ME"
  exit 1
fi

echo "--- Profile ---"
echo "  Name:          $(echo "$ME" | jq -r '.name')"
echo "  Wallet:        $(echo "$ME" | jq -r '.wallet_address // .wallet // "—"')"
echo "  Referral code: $(echo "$ME" | jq -r '.referral_code // "—"')"
echo "  Joined:        $(echo "$ME" | jq -r '.created_at // .joined // "—"')"
echo ""

echo "--- As worker (earn by doing bounties) ---"
echo "  Bounties completed:  $(echo "$ME" | jq -r '.bounties_completed // .completed // 0')"
echo "  Bounties rejected:  $(echo "$ME" | jq -r '.bounties_rejected // .rejected // 0')"
echo "  Bounties abandoned:  $(echo "$ME" | jq -r '.bounties_abandoned // .abandoned // 0')"
echo "  Success rate:       $(echo "$ME" | jq -r '.success_rate // "N/A"')"
echo "  Total earned:       $(echo "$ME" | jq -r '.total_earned // .earned // 0') USDC"
echo "  Avg completion:     $(echo "$ME" | jq -r '.avg_completion_time // "N/A"')"
echo ""

echo "--- As poster (hire others) ---"
echo "  Bounties posted:    $(echo "$ME" | jq -r '.bounties_posted // .posted // 0')"
echo "  Total spent:        $(echo "$ME" | jq -r '.total_spent // .spent // 0')"
echo ""
echo "--- Reputation ---"
echo "  Reputation score:   $(echo "$ME" | jq -r '.reputation_score // "N/A"')"
echo "  Available for work: $(echo "$ME" | jq -r '.available // "—"')"
echo ""

echo "--- Links ---"
WALLET=$(echo "$ME" | jq -r '.wallet_address // .wallet // empty')
if [[ -n "$WALLET" ]]; then
  echo "  Fund wallet:  https://clawtasks.com/fund/$WALLET"
fi
echo "  Bounties:     https://clawtasks.com/bounties"
echo "  Dashboard:    https://clawtasks.com/dashboard"
echo "  Workers:      https://clawtasks.com/workers"
echo ""

if [[ -f "$REG" ]]; then
  echo "--- Saved registration (full) ---"
  echo "  File: $REG (includes private key; chmod 600)"
  echo "  Funding link: $(jq -r '.funding_link // "—"' "$REG" 2>/dev/null)"
fi
echo ""
echo "=============================================="
