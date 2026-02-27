#!/usr/bin/env bash
# Set Railway project variables via API using a project token (so you don't paste in dashboard).
# Usage:
#   RAILWAY_TOKEN=<project-token> RAILWAY_PROJECT_ID=<id> RAILWAY_ENVIRONMENT_ID=<id> ./sentinel-nexus/set-railway-variables.sh
#   RAILWAY_TOKEN=<token> ./sentinel-nexus/set-railway-variables.sh   # if only token set, will try to discover project/env
#
# Get token: Railway project → Settings → Tokens → Create Token (Project Token).
# Get IDs: Project → Settings → copy Project ID; Environments → copy Environment ID. Or use Railway CLI: railway link then railway whoami / status.

set -e
# Load .env from repo root so you can set RAILWAY_TOKEN once
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
for _env in "$REPO_ROOT/.env" ".env"; do
  if [[ -f "$_env" ]]; then set -a; . "$_env"; set +a; break; fi
done
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
RAILWAY_API="https://backboard.railway.com/graphql/v2"
TOKEN="$(echo "${RAILWAY_TOKEN:-$RAILWAY_API_TOKEN}" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
PROJECT_ID="$(echo "${RAILWAY_PROJECT_ID:-}" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
ENV_ID="$(echo "${RAILWAY_ENVIRONMENT_ID:-}" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
SERVICE_ID="$(echo "${RAILWAY_SERVICE_ID:-}" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

if [[ -z "$TOKEN" ]]; then
  echo "Set RAILWAY_TOKEN (or RAILWAY_API_TOKEN). Get it: Project → Settings → Tokens → Create Token."
  exit 1
fi
# Detect token type and scope: account/workspace use Bearer; project tokens use Project-Access-Token and projectToken query
ME_RESP=$(curl -sS -X POST "$RAILWAY_API" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"query":"query { me { name email } }"}')
PT_RESP=$(curl -sS -X POST "$RAILWAY_API" -H "Project-Access-Token: $TOKEN" -H "Content-Type: application/json" -d '{"query":"query { projectToken { projectId environmentId } }"}')
USE_PROJECT_HEADER=false
if echo "$PT_RESP" | jq -e '.data.projectToken' >/dev/null 2>&1; then
  USE_PROJECT_HEADER=true
  TOKEN_PROJECT=$(echo "$PT_RESP" | jq -r '.data.projectToken.projectId')
  TOKEN_ENV=$(echo "$PT_RESP" | jq -r '.data.projectToken.environmentId')
  echo "Token OK (project). Scope: project=$TOKEN_PROJECT env=$TOKEN_ENV"
  # Project tokens are scoped to one env: use token's IDs if we have them
  [[ -n "$TOKEN_PROJECT" && "$TOKEN_PROJECT" != "null" ]] && PROJECT_ID="${PROJECT_ID:-$TOKEN_PROJECT}"
  [[ -n "$TOKEN_ENV" && "$TOKEN_ENV" != "null" ]] && ENV_ID="${ENV_ID:-$TOKEN_ENV}"
elif echo "$ME_RESP" | jq -e '.data.me' >/dev/null 2>&1; then
  echo "Token OK (account). Pushing variables..."
else
  echo "Could not verify token. Trying both auth methods."
fi
if [[ -z "$PROJECT_ID" ]]; then
  echo "RAILWAY_PROJECT_ID is empty in .env. Add it from Railway → Project → Settings."
fi
if [[ -z "$ENV_ID" ]]; then
  echo "RAILWAY_ENVIRONMENT_ID is empty in .env. Add it from Railway → Project → Environments (click environment, copy ID)."
fi

# Discover project and environment if not set (project tokens get it from projectToken; account tokens from projects query)
if [[ -z "$PROJECT_ID" ]] || [[ -z "$ENV_ID" ]]; then
  if [[ "$USE_PROJECT_HEADER" == "true" && -n "$TOKEN_PROJECT" && "$TOKEN_PROJECT" != "null" ]]; then
    PROJECT_ID="$TOKEN_PROJECT"
    ENV_ID="$TOKEN_ENV"
    echo "Using token scope: project=$PROJECT_ID env=$ENV_ID"
  else
    echo "Discovering project and environment..."
    AUTH_HDR="Authorization: Bearer $TOKEN"
    [[ "$USE_PROJECT_HEADER" == "true" ]] && AUTH_HDR="Project-Access-Token: $TOKEN"
    RESP=$(curl -sS -X POST "$RAILWAY_API" \
      -H "$AUTH_HDR" \
      -H "Content-Type: application/json" \
      -d '{"query":"query { projects { edges { node { id name environments { edges { node { id name } } } } } } }"}')
    if echo "$RESP" | jq -e '.data.projects.edges[0].node.id' >/dev/null 2>&1; then
      PROJECT_ID="${RAILWAY_PROJECT_ID:-$(echo "$RESP" | jq -r '.data.projects.edges[0].node.id')}"
      ENV_ID="${RAILWAY_ENVIRONMENT_ID:-$(echo "$RESP" | jq -r '.data.projects.edges[0].node.environments.edges[0].node.id')}"
      echo "Using project $PROJECT_ID, environment $ENV_ID"
    else
      echo "Add to .env: RAILWAY_PROJECT_ID and RAILWAY_ENVIRONMENT_ID (from Railway → Project → Settings / Environments)"
      exit 1
    fi
  fi
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
  # OpenClaw gateway config (base64) for /openclaw on Railway
  oc_json="$OPENCLAW/openclaw.json"
  if [[ -f "$oc_json" ]]; then
    b64=$(base64 < "$oc_json" | tr -d '\n')
    b64_escaped=$(echo "$b64" | jq -Rs .)
    VARS_JSON=$(echo "$VARS_JSON" | jq --arg k "OPENCLAW_CONFIG_JSON" --argjson v "$b64_escaped" '. + {($k): $v}')
  fi
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

# If no SERVICE_ID, get first service in project so variables attach to the deployable service
if [[ -z "$SERVICE_ID" ]]; then
  SVC_BODY=$(jq -n -c --arg projectId "$PROJECT_ID" '{ query: "query($projectId: String!) { project(id: $projectId) { services { edges { node { id } } } } }", variables: { projectId: $projectId } }')
  AUTH_HDR="Authorization: Bearer $TOKEN"
  [[ "$USE_PROJECT_HEADER" == "true" ]] && AUTH_HDR="Project-Access-Token: $TOKEN"
  SVC_RESP=$(curl -sS -X POST "$RAILWAY_API" \
    -H "$AUTH_HDR" \
    -H "Content-Type: application/json" \
    -d "$SVC_BODY")
  SERVICE_ID=$(echo "$SVC_RESP" | jq -r '.data.project.services.edges[0].node.id // empty')
  [[ -n "$SERVICE_ID" ]] && echo "Using service: $SERVICE_ID"
fi

# Build input: shared vars (no serviceId) vs service vars
INPUT_SHARED=$(jq -c -n \
  --arg projectId "$PROJECT_ID" \
  --arg environmentId "$ENV_ID" \
  --argjson vars "$VARS_JSON" \
  '{ projectId: $projectId, environmentId: $environmentId, variables: $vars }')
INPUT_SVC=""
[[ -n "$SERVICE_ID" ]] && INPUT_SVC=$(echo "$INPUT_SHARED" | jq -c --arg serviceId "$SERVICE_ID" '. + { serviceId: $serviceId }')

# Project tokens MUST use Project-Access-Token; account/workspace use Bearer
AUTH_HDR="Authorization: Bearer $TOKEN"
[[ "$USE_PROJECT_HEADER" == "true" ]] && AUTH_HDR="Project-Access-Token: $TOKEN"
ALT_HDR="Project-Access-Token: $TOKEN"
[[ "$USE_PROJECT_HEADER" == "true" ]] && ALT_HDR="Authorization: Bearer $TOKEN"

# Try shared vars first (project tokens often limited to shared); then service-specific
for INPUT in "$INPUT_SHARED" "$INPUT_SVC"; do
  [[ -z "$INPUT" ]] && continue
  BODY=$(jq -n -c \
    --arg query 'mutation variableCollectionUpsert($input: VariableCollectionUpsertInput!) { variableCollectionUpsert(input: $input) }' \
    --argjson input "$INPUT" \
    '{ query: $query, variables: { input: $input } }')
  RESP=$(curl -sS -X POST "$RAILWAY_API" -H "$AUTH_HDR" -H "Content-Type: application/json" -d "$BODY")
  if echo "$RESP" | jq -e '.errors[].message | select(contains("Not Authorized"))' >/dev/null 2>&1; then
    RESP=$(curl -sS -X POST "$RAILWAY_API" -H "$ALT_HDR" -H "Content-Type: application/json" -d "$BODY")
  fi
  if echo "$RESP" | jq -e '.data.variableCollectionUpsert' >/dev/null 2>&1; then
    echo "Variables set successfully. Redeploy the service if needed (Railway may auto-redeploy)."
    exit 0
  fi
done

if echo "$RESP" | jq -e '.data.variableCollectionUpsert' >/dev/null 2>&1; then
  echo "Variables set successfully. Redeploy the service if needed (Railway may auto-redeploy)."
  exit 0
fi

# Fallback: if bulk upsert not allowed, try single variableUpsert per variable
if echo "$RESP" | jq -e '.errors' >/dev/null 2>&1; then
  echo "Bulk upsert failed; trying single-variable upserts..."
  UPDATED=0
  while IFS= read -r line; do
    KEY=$(echo "$line" | jq -r '.key')
    VAL=$(echo "$line" | jq -r '.value')
    [[ -z "$KEY" ]] || [[ "$KEY" == "null" ]] && continue
    ONE_INPUT=$(jq -n -c \
      --arg projectId "$PROJECT_ID" \
      --arg environmentId "$ENV_ID" \
      --arg serviceId "$SERVICE_ID" \
      --arg name "$KEY" \
      --arg value "$VAL" \
      '{ projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId, name: $name, value: $value }')
    ONE_BODY=$(jq -n -c --arg query 'mutation variableUpsert($input: VariableUpsertInput!) { variableUpsert(input: $input) }' --argjson input "$ONE_INPUT" '{ query: $query, variables: { input: $input } }')
    ONE_RESP=$(curl -sS -X POST "$RAILWAY_API" -H "$AUTH_HDR" -H "Content-Type: application/json" -d "$ONE_BODY")
    if echo "$ONE_RESP" | jq -e '.errors[].message | select(contains("Not Authorized"))' >/dev/null 2>&1; then
      ONE_RESP=$(curl -sS -X POST "$RAILWAY_API" -H "$ALT_HDR" -H "Content-Type: application/json" -d "$ONE_BODY")
    fi
    if echo "$ONE_RESP" | jq -e '.data.variableUpsert' >/dev/null 2>&1; then
      echo "  Set: $KEY"
      UPDATED=$((UPDATED + 1))
    else
      ERR=$(echo "$ONE_RESP" | jq -r '.errors[0].message // "unknown"')
      echo "  Fail $KEY: $ERR"
    fi
  done < <(echo "$VARS_JSON" | jq -c 'to_entries[] | {key: .key, value: .value}')
  if [[ $UPDATED -gt 0 ]]; then
    echo "Variables set: $UPDATED. Redeploy if needed."
    exit 0
  fi
fi

echo "Railway API error:"
echo "$RESP" | jq '.errors // .'

# Fallback: use Railway CLI if logged in and linked (railway login && railway link)
if command -v railway >/dev/null 2>&1; then
  if railway whoami &>/dev/null; then
    echo ""
    echo "Trying Railway CLI (railway variables --set)..."
    SET_ARGS=()
    while IFS= read -r line; do
      KEY=$(echo "$line" | jq -r '.key')
      VAL=$(echo "$line" | jq -r '.value')
      [[ -z "$KEY" ]] || [[ "$KEY" == "null" ]] && continue
      # Escape value for shell: use single quotes, escape single quotes as '\''
      SAFE_VAL=$(echo "$VAL" | sed "s/'/'\\\\''/g")
      SET_ARGS+=("--set")
      SET_ARGS+=("${KEY}='${SAFE_VAL}'")
    done < <(echo "$VARS_JSON" | jq -c 'to_entries[] | {key: .key, value: .value}')
    if [[ ${#SET_ARGS[@]} -gt 0 ]]; then
      if railway variables "${SET_ARGS[@]}" 2>/dev/null; then
        echo "Variables set via CLI. Redeploy if needed."
        exit 0
      fi
    fi
  fi
fi

if echo "$RESP" | jq -e '.errors[].message | select(contains("Not Authorized"))' >/dev/null 2>&1; then
  echo ""
  echo "Variable write returned Not Authorized. Try:"
  echo "  1. Account token for API: railway.com/account/tokens → create token, set RAILWAY_API_TOKEN in .env"
  echo "  2. CLI method: run 'railway login' and 'railway link' in this dir, then re-run this script"
  echo "  3. Manual: run ./sentinel-nexus/export-credentials-for-railway.sh and paste into Railway → Variables"
fi
exit 1
