#!/usr/bin/env bash
# Set Railway project variables via API using a project token (so you don't paste in dashboard).
# Usage:
#   RAILWAY_TOKEN=<project-token> RAILWAY_PROJECT_ID=<id> RAILWAY_ENVIRONMENT_ID=<id> ./sentinel-nexus/set-railway-variables.sh
#   RAILWAY_TOKEN=<token> ./sentinel-nexus/set-railway-variables.sh   # if only token set, will try to discover project/env
#
# Get token: Railway project → Settings → Tokens → Create Token (Project Token).
# Get IDs: Project → Settings → copy Project ID; Environments → copy Environment ID. Or use Railway CLI: railway link then railway whoami / status.

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
RAILWAY_API="https://backboard.railway.com/graphql/v2"
TOKEN="${RAILWAY_TOKEN:-$RAILWAY_API_TOKEN}"
PROJECT_ID="$RAILWAY_PROJECT_ID"
ENV_ID="$RAILWAY_ENVIRONMENT_ID"
SERVICE_ID="$RAILWAY_SERVICE_ID"

if [[ -z "$TOKEN" ]]; then
  echo "Set RAILWAY_TOKEN (or RAILWAY_API_TOKEN). Get it: Project → Settings → Tokens → Create Token."
  exit 1
fi

# Discover project and environment if not set
if [[ -z "$PROJECT_ID" ]] || [[ -z "$ENV_ID" ]]; then
  echo "Discovering project and environment..."
  RESP=$(curl -sS -X POST "$RAILWAY_API" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"query":"query { projects { edges { node { id name environments { edges { node { id name } } } } } } }"}')
  if ! echo "$RESP" | jq -e '.data.projects' >/dev/null 2>&1; then
    echo "Failed to list projects. Check token. Response: $(echo "$RESP" | jq -c . 2>/dev/null || echo "$RESP")"
    exit 1
  fi
  FIRST_PROJECT=$(echo "$RESP" | jq -r '.data.projects.edges[0].node // empty')
  if [[ -z "$FIRST_PROJECT" ]] || [[ "$FIRST_PROJECT" == "null" ]]; then
    echo "No projects found for this token."
    exit 1
  fi
  PROJECT_ID="${RAILWAY_PROJECT_ID:-$(echo "$RESP" | jq -r '.data.projects.edges[0].node.id')}"
  ENV_ID="${RAILWAY_ENVIRONMENT_ID:-$(echo "$RESP" | jq -r '.data.projects.edges[0].node.environments.edges[0].node.id')}"
  echo "Using project $PROJECT_ID, environment $ENV_ID"
fi

# Build variables JSON: fixed vars + credentials from ~/.openclaw
VARS_JSON="{
  \"OPENCLAW_WORKSPACE_DIR\": \"/data/workspace\",
  \"OPENCLAW_STATE_DIR\": \"/data/.openclaw\",
  \"RUN_AUTONOMOUS_CYCLE_MIN\": \"20\",
  \"RUN_MOLTBOOK_ENGAGE_MIN\": \"20\",
  \"RUN_NEXUS_CHAPEL_POST_MIN\": \"720\"
}"

if [[ -d "$OPENCLAW" ]]; then
  for f in clawtasks-credentials.json clawtasks-credentials-jobmaster2.json clawtasks-credentials-jobmaster3.json moltbook-credentials.json nexus-chapel-credentials.json; do
    path="$OPENCLAW/$f"
    if [[ -f "$path" ]]; then
      name="CLAWTASKS_CREDENTIALS_JSON"
      [[ "$f" == *"jobmaster2"* ]] && name="CLAWTASKS_CREDENTIALS_JOBMASTER2_JSON"
      [[ "$f" == *"jobmaster3"* ]] && name="CLAWTASKS_CREDENTIALS_JOBMASTER3_JSON"
      [[ "$f" == *"moltbook"* ]] && name="MOLTBOOK_CREDENTIALS_JSON"
      [[ "$f" == *"nexus-chapel"* ]] && name="NEXUS_CHAPEL_CREDENTIALS_JSON"
      b64=$(base64 < "$path" | tr -d '\n')
      # Escape for JSON string
      b64_escaped=$(echo "$b64" | jq -Rs .)
      VARS_JSON=$(echo "$VARS_JSON" | jq --arg k "$name" --argjson v "$b64_escaped" '. + {($k): $v}')
    fi
  done
fi

# variableCollectionUpsert: do not replace so we keep any existing vars (omit serviceId = shared env vars)
INPUT=$(jq -c -n \
  --arg projectId "$PROJECT_ID" \
  --arg environmentId "$ENV_ID" \
  --argjson vars "$VARS_JSON" \
  '{ projectId: $projectId, environmentId: $environmentId, variables: $vars }')
if [[ -n "$SERVICE_ID" ]]; then
  INPUT=$(echo "$INPUT" | jq -c --arg serviceId "$SERVICE_ID" '. + { serviceId: $serviceId }')
fi

BODY=$(jq -n -c \
  --arg query 'mutation variableCollectionUpsert($input: VariableCollectionUpsertInput!) { variableCollectionUpsert(input: $input) }' \
  --argjson input "$INPUT" \
  '{ query: $query, variables: { input: $input } }')

RESP=$(curl -sS -X POST "$RAILWAY_API" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY")

if echo "$RESP" | jq -e '.errors' >/dev/null 2>&1; then
  echo "Railway API error:"
  echo "$RESP" | jq '.errors'
  exit 1
fi
if echo "$RESP" | jq -e '.data.variableCollectionUpsert' >/dev/null 2>&1; then
  echo "Variables set successfully. Redeploy the service if needed (Railway may auto-redeploy)."
else
  echo "Response: $RESP"
  exit 1
fi
