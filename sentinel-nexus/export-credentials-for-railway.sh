#!/usr/bin/env bash
# Export ClawTasks credentials for Railway Variables (so Railway works 100% like local).
# Run locally: ./sentinel-nexus/export-credentials-for-railway.sh
# Then in Railway dashboard → Variables, add each line (or the bulk base64).

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
if [[ ! -d "$OPENCLAW" ]]; then
  echo "Missing $OPENCLAW — run from a machine that has OpenClaw credentials."
  exit 1
fi

echo "# --- Paste these into Railway → Variables, then redeploy ---"
echo ""

for f in clawtasks-credentials.json clawtasks-credentials-jobmaster2.json clawtasks-credentials-jobmaster3.json; do
  path="$OPENCLAW/$f"
  if [[ -f "$path" ]]; then
    name="CLAWTASKS_CREDENTIALS_JSON"
    [[ "$f" == *"jobmaster2"* ]] && name="CLAWTASKS_CREDENTIALS_JOBMASTER2_JSON"
    [[ "$f" == *"jobmaster3"* ]] && name="CLAWTASKS_CREDENTIALS_JOBMASTER3_JSON"
    b64=$(base64 < "$path" | tr -d '\n')
    echo "${name}=${b64}"
  fi
done

# Optional: one bulk variable (base64 of {"filename": "<json string>", ...})
if command -v jq >/dev/null 2>&1; then
  BULK=""
  for f in clawtasks-credentials.json clawtasks-credentials-jobmaster2.json clawtasks-credentials-jobmaster3.json; do
    path="$OPENCLAW/$f"
    if [[ -f "$path" ]]; then
      json=$(jq -c . "$path" 2>/dev/null || cat "$path")
      [[ -n "$BULK" ]] && BULK="$BULK,"
      BULK="$BULK\"$f\":$(echo "$json" | jq -Rs .)"
    fi
  done
  if [[ -n "$BULK" ]]; then
    echo ""
    echo "# Or set one variable (base64):"
    echo -n "RAILWAY_CLAWTASKS_CREDENTIALS="
    echo "{$BULK}" | base64 | tr -d '\n'
    echo ""
  fi
fi

echo ""
echo "# --- After pasting in Railway Variables, redeploy. Server will write credentials to the volume. ---"
