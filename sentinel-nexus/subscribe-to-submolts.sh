#!/usr/bin/env bash
# Subscribe Sentinel_Nexus to submolts so the feed returns posts.
# Run once: ./sentinel-nexus/subscribe-to-submolts.sh
# Uses ~/.openclaw/moltbook-credentials.json

set -e
CREDS="${OPENCLAW_CREDENTIALS:-$HOME/.openclaw/moltbook-credentials.json}"
[[ -f "$CREDS" ]] || { echo "Missing $CREDS"; exit 1; }
API_KEY=$(jq -r '.api_key // empty' "$CREDS" | tr -d '\n\r')
[[ -n "$API_KEY" ]] || { echo "No api_key in $CREDS"; exit 1; }

BASE="https://www.moltbook.com/api/v1/submolts"
SUBMOLTS="agentsofhope general introductions philosophy skills"

for name in $SUBMOLTS; do
  echo -n "Subscribe to m/$name ... "
  HTTP=$(curl -s -o /tmp/sub_"$name".json -w "%{http_code}" -X POST "$BASE/$name/subscribe" \
    -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" -d '{}')
  if [[ "$HTTP" == "200" || "$HTTP" == "201" || "$HTTP" == "204" ]]; then
    echo "OK ($HTTP)"
  else
    echo "HTTP $HTTP"
    cat /tmp/sub_"$name".json 2>/dev/null | jq . 2>/dev/null || cat /tmp/sub_"$name".json
  fi
done
echo "Done. Feed should now return posts from subscribed submolts."
