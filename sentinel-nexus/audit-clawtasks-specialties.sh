#!/usr/bin/env bash
# Audit open ClawTasks bounties by inferred specialty (test ground: what jobs we can take).
# Usage: ./sentinel-nexus/audit-clawtasks-specialties.sh

set -e
CREDS="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/clawtasks-credentials.json"
API="https://clawtasks.com/api"
if [[ ! -f "$CREDS" ]]; then echo "No $CREDS"; exit 1; fi
KEY=$(jq -r '.api_key // empty' "$CREDS")
if [[ -z "$KEY" ]]; then echo "No api_key"; exit 1; fi

OPEN=$(curl -sS -H "Authorization: Bearer $KEY" "$API/bounties?status=open" | tr -d '\000-\010\013-\037')
echo "=== ClawTasks open bounties — specialty audit (excluding our posters) ==="
echo ""

# Exclude jobmaster, jobmaster2, jobmaster3
echo "$OPEN" | jq -r '
  .bounties // []
  | map(select((.poster_name // "" | test("^(jobmaster|jobmaster2|jobmaster3)$"; "i")) | not))
  | sort_by(-(.amount | tonumber? // 0))
  | .[]
  | "\(.amount | tostring)\t\(.mode // "instant")\t\(.id)\t\(.poster_name // "")\t\(.title // "")"
' 2>/dev/null | while IFS=$'\t' read -r amt mode id poster title; do
  [[ -z "$id" ]] && continue
  u=$(echo "$title" | tr '[:upper:]' '[:lower:]')
  if [[ "$u" =~ (research|report|findings|analyze|analysis) ]]; then spec="research"
  elif [[ "$u" =~ (blog|post|article|write|content) ]]; then spec="blog_content"
  elif [[ "$u" =~ (summary|summarize|recap) ]]; then spec="summary"
  elif [[ "$u" =~ (compare|comparison|vs\.|versus) ]]; then spec="comparison"
  elif [[ "$u" =~ (list|curate|resources|ideas|tips|best\ practices) ]]; then spec="list_tips"
  elif [[ "$u" =~ (image|graphic|design|logo|illustration|visual|png|jpg) ]]; then spec="image_design"
  elif [[ "$u" =~ (video|edit|clip|footage) ]]; then spec="video"
  elif [[ "$u" =~ (proposal|pitch|apply) ]]; then spec="proposal"
  elif [[ "$u" =~ (review|feedback|audit) ]]; then spec="review"
  elif [[ "$u" =~ (code|script|api|implement) ]]; then spec="code"
  else spec="other"; fi
  printf "%s\t%s\t%s\t%s\t%s\n" "$spec" "$amt" "$mode" "$id" "${title:0:60}"
done | tee /tmp/clawtasks_audit.tsv | while IFS=$'\t' read -r spec amt mode id title; do
  printf "  %-14s %5s %-8s %s  %s\n" "$spec" "$amt" "$mode" "$id" "$title"
done

echo ""
echo "--- Summary by specialty ---"
cut -f1 /tmp/clawtasks_audit.tsv 2>/dev/null | sort | uniq -c | sort -k2
echo ""
echo "We can take today: research, summary, comparison, list_tips, blog_content, review, other (text)."
echo "Graphics/images/video: see CLAWTASKS_SPECIALTIES.md — we need to employ image-capable agents or add APIs."
