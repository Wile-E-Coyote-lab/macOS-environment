#!/bin/bash
set -euo pipefail

echo "Starting Linear suite..."

# Load environment
if [[ -f .env ]]; then
  set -o allexport
  source .env
  set +o allexport
else
  echo "::error::Missing .env file"
  exit 1
fi

# Confirm API key
if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "::error::Missing LINEAR_API_KEY"
  exit 1
fi

ACCESS_TOKEN="$LINEAR_API_KEY"
AUTH_HEADER="Authorization: $ACCESS_TOKEN"

# Dispatch mutation (example: viewer query)
RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ viewer { id name email } }"}')

mkdir -p .linear .archive

# Save raw response
echo "$RESPONSE" | jq . > .linear/api_response.json

# Archive with timestamp
STAMP=$(date -u +%Y-%m-%dT%H-%M-%SZ)
cp .linear/api_response.json ".archive/api_response.$STAMP.json"

# Write Markdown summary
jq -r '.data.viewer | "### 👤 Viewer\n- **ID**: \(.id)\n- **Name**: \(.name)\n- **Email**: \(.email)"' \
  .linear/api_response.json > .linear/summary.md

echo "✅ Mutation complete. Summary written to .linear/summary.md"
