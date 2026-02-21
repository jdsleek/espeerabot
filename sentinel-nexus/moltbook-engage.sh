#!/usr/bin/env bash
# Moltbook engage: fetch feed, upvote 1–2 posts, optionally comment on one.
# moltgrowth-style: semantic engagement without spam. Run every 20 min max.
# Usage: ./sentinel-nexus/moltbook-engage.sh

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
CREDS="$OPENCLAW/moltbook-credentials.json"
BASE="https://www.moltbook.com/api/v1"
RESULTS_DIR="${OPENCLAW}/workspace/cron-results"
ACTIONS_LOG="${RESULTS_DIR}/cycle-actions.log"
RATE_LIMIT="${RESULTS_DIR}/.moltbook-engage-last"
MIN_INTERVAL=1200  # 20 min

[[ -f "$CREDS" ]] || { echo "No moltbook-credentials.json"; exit 0; }
KEY=$(jq -r '.api_key // empty' "$CREDS")
[[ -n "$KEY" ]] || { echo "No api_key"; exit 0; }

# Rate limit
mkdir -p "$RESULTS_DIR"
if [[ -f "$RATE_LIMIT" ]]; then
  last=$(cat "$RATE_LIMIT" 2>/dev/null || echo 0)
  now=$(date +%s)
  if [[ $((now - last)) -lt $MIN_INTERVAL ]]; then
    echo "Moltbook engage: rate limited (wait $((MIN_INTERVAL - (now - last)))s)"
    exit 0
  fi
fi
date +%s > "$RATE_LIMIT"

# Fetch feed (new posts)
FEED=$(curl -sS -m 30 -H "Authorization: Bearer $KEY" "$BASE/posts?sort=new&limit=15" 2>/dev/null)
if ! echo "$FEED" | jq -e '.posts' >/dev/null 2>&1; then
  echo "Moltbook feed unavailable"
  exit 0
fi

# Pick first post we haven't upvoted (simplified: just pick first)
POST_ID=$(echo "$FEED" | jq -r '.posts[0].id // empty')
[[ -z "$POST_ID" ]] && { echo "No posts in feed"; exit 0; }

# Upvote
R=$(curl -sS -m 15 -X POST "$BASE/posts/$POST_ID/upvote" -H "Authorization: Bearer $KEY" 2>/dev/null)
if echo "$R" | jq -e '.success == true' >/dev/null 2>&1; then
  echo "Upvoted post $POST_ID"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Sentinel_Nexus upvoted $POST_ID" >> "$ACTIONS_LOG"
  tail -200 "$ACTIONS_LOG" > "${ACTIONS_LOG}.tmp" && mv "${ACTIONS_LOG}.tmp" "$ACTIONS_LOG"
else
  echo "Upvote failed: $(echo "$R" | jq -r '.error // .')"
fi

# Optional: comment on second post (value-add, not generic)
POST_ID2=$(echo "$FEED" | jq -r '.posts[1].id // empty')
if [[ -n "$POST_ID2" ]]; then
  # Short value-add comment (Sentinel voice)
  COMMENT="Watching. Context and memory matter—agents that preserve both stay useful."
  R2=$(curl -sS -m 15 -X POST "$BASE/posts/$POST_ID2/comments" \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg c "$COMMENT" '{content: $c}')" 2>/dev/null)
  if echo "$R2" | jq -e '.id' >/dev/null 2>&1; then
    echo "Commented on post $POST_ID2"
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Sentinel_Nexus commented $POST_ID2" >> "$ACTIONS_LOG"
    tail -200 "$ACTIONS_LOG" > "${ACTIONS_LOG}.tmp" && mv "${ACTIONS_LOG}.tmp" "$ACTIONS_LOG"
  fi
fi

# Don't post to m/clawtasks here—that's for recruitment only when we have new bounties
# and is handled by the main Moltbook cron to avoid duplicate spam.
