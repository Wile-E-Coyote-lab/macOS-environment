#!/bin/bash
set -euo pipefail

echo "🔍 Starting Linear OAuth session validation..."

# ─── 1. Load .env safely ───────────────────────────────────────────────
if [ -f .env ]; then
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
    export "$key"="$(echo "$value" | sed -e 's/^"//' -e 's/"$//')"
  done < .env
else
  echo "::error::❌ .env file not found"
  exit 1
fi

# ─── 2. Validate required environment variables ─────────────────────────
echo "🔹 Checking required environment variables..."
REQUIRED_VARS=(LINEAR_APP_ID LINEAR_CLIENT_SECRET LINEAR_REDIRECT_URI)
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "::error::❌ Missing required env var: $var"
    exit 1
  fi
done
echo "✅ Environment variables present"

# ─── 3. Validate OAuth code presence and freshness ─────────────────────
CODE_FILE=".linear/oauth_code"
if [[ ! -s "$CODE_FILE" ]]; then
  echo "::error::❌ Missing or empty OAuth code file: $CODE_FILE"
  exit 1
fi

# Cross-platform stat: Linux (GNU) vs macOS (BSD)
if stat --version >/dev/null 2>&1; then
  CODE_MTIME=$(stat -c %Y "$CODE_FILE")
else
  CODE_MTIME=$(stat -f %m "$CODE_FILE")
fi

CODE_AGE=$(($(date +%s) - CODE_MTIME))
if [[ "$CODE_AGE" -gt 300 ]]; then
  echo "::error::❌ OAuth code is too old ($CODE_AGE seconds). Must be < 5 minutes."
  exit 1
fi
echo "✅ OAuth code is fresh ($CODE_AGE seconds old)"

# ─── 4. Attempt token exchange ─────────────────────────────────────────
echo "🔹 Attempting token exchange..."
# ─── 4. Attempt token exchange ─────────────────────────────────────────
echo "🔹 Attempting token exchange..."
RESPONSE=$(curl -s -X POST https://api.linear.app/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=$(cat "$CODE_FILE")" \
  -d "client_id=$LINEAR_APP_ID" \
  -d "client_secret=$LINEAR_CLIENT_SECRET" \
  -d "redirect_uri=$LINEAR_REDIRECT_URI")

echo "$RESPONSE" > .linear/token_response.json

if echo "$RESPONSE" | jq -e '.error' >/dev/null; then
  echo "::error::❌ Token exchange failed: $(echo "$RESPONSE" | jq -r '.error_description // .error')"
  exit 1
fi

ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token // empty')
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "::error::❌ No access_token in response"
  exit 1
fi
echo "✅ Access token acquired"

# ─── 5. Validate token authentication ──────────────────────────────────
echo "🔹 Validating token authentication..."
AUTH_CHECK=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ viewer { id name email } }"}')

if echo "$AUTH_CHECK" | jq -e '.errors[0].extensions.code == "AUTHENTICATION_ERROR"' >/dev/null; then
  echo "::error::❌ Token is invalid or unauthorized:"
  echo "$AUTH_CHECK" | jq .
  exit 1
fi

echo "✅ Token is authenticated and usable"
