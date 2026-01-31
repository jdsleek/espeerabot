#!/usr/bin/env bash
# Call the configured LLM API once (Groq) to verify the key works.
# Reads GROQ_API_KEY from ~/.openclaw/openclaw.json env or from environment.
# Usage: ./sentinel-nexus/test-llm-api.sh

set -e
CONFIG="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
MODEL="${GROQ_TEST_MODEL:-llama-3.3-70b-versatile}"

if [[ -f "$CONFIG" ]]; then
  KEY=$(jq -r '.env.GROQ_API_KEY // .env.groq_api_key // empty' "$CONFIG" 2>/dev/null | tr -d '\n\r')
fi
if [[ -z "$KEY" ]]; then
  KEY="${GROQ_API_KEY:-}"
fi
if [[ -z "$KEY" ]] || [[ "$KEY" == "null" ]]; then
  echo "No GROQ_API_KEY found in $CONFIG or env. Set it in openclaw.json (env.GROQ_API_KEY) or export GROQ_API_KEY."
  exit 1
fi

echo "Calling Groq API once (model: $MODEL)..."
RESP=$(curl -s -w "\n%{http_code}" -X POST "https://api.groq.com/openai/v1/chat/completions" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Reply with exactly: OK"}],"model":"'"$MODEL"'","max_tokens":10}')

HTTP_CODE=$(echo "$RESP" | tail -n1)
BODY=$(echo "$RESP" | sed '$d')

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "API call succeeded (HTTP 200)."
  echo "$BODY" | jq -r '.choices[0].message.content // .choices[0].text // .' 2>/dev/null || echo "$BODY"
else
  echo "API call failed (HTTP $HTTP_CODE)."
  echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
  exit 1
fi
