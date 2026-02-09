#!/usr/bin/env bash
# Create two test jobs (image + video) and run one cycle so the system claims, generates, and submits.
# Requires: admin server on http://127.0.0.1:3880
# Usage: ./sentinel-nexus/create-multimodal-test-jobs.sh

set -e
BASE="${1:-http://127.0.0.1:3880}"

echo "=== MultimodalFull test: creating image + video jobs ==="

# 1. Image job
echo "Posting image job..."
IMG_RESP=$(curl -s -X POST "$BASE/api/post-job" \
  -H "Content-Type: application/json" \
  -d '{"title":"Generate an image: a serene lake at sunset with mountains","description":"Create a single image. Style: photorealistic, warm light."}' 2>/dev/null || echo '{}')
IMG_OK=$(echo "$IMG_RESP" | jq -r '.ok // false')
IMG_BOUNTY=$(echo "$IMG_RESP" | jq -r '.bountyId // empty')
IMG_TRACK=$(echo "$IMG_RESP" | jq -r '.trackUrl // empty')
if [[ "$IMG_OK" == "true" && -n "$IMG_BOUNTY" ]]; then
  echo "  Image job created: $IMG_BOUNTY"
  echo "  Track: $BASE$IMG_TRACK"
else
  echo "  Image job failed: $IMG_RESP"
fi

# 2. Video job
echo "Posting video job..."
VID_RESP=$(curl -s -X POST "$BASE/api/post-job" \
  -H "Content-Type: application/json" \
  -d '{"title":"Generate a short video: waves on a beach at golden hour","description":"5–10 second clip. Calm waves, sunset, cinematic."}' 2>/dev/null || echo '{}')
VID_OK=$(echo "$VID_RESP" | jq -r '.ok // false')
VID_BOUNTY=$(echo "$VID_RESP" | jq -r '.bountyId // empty')
VID_TRACK=$(echo "$VID_RESP" | jq -r '.trackUrl // empty')
if [[ "$VID_OK" == "true" && -n "$VID_BOUNTY" ]]; then
  echo "  Video job created: $VID_BOUNTY"
  echo "  Track: $BASE$VID_TRACK"
else
  echo "  Video job failed: $VID_RESP"
fi

# 3. Run cycle (claim + submit human-front + auto-approve)
echo ""
echo "Running one cycle (submit + approve)..."
CYCLE=$(curl -s -X POST "$BASE/api/run-cycle" -m 180 2>/dev/null || echo '{}')
echo "$CYCLE" | jq -r '.message // .error // .' 2>/dev/null || echo "$CYCLE"
echo ""
echo "Done. Check track links above or dashboard: $BASE/admin/dashboard"
