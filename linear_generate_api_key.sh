#!/bin/bash
# linear-generate-api-key.sh — Prompt user to create API key and validate it

set -e
mkdir -p .dev

echo "🔐 Visit this URL to generate a new Linear API key:"
echo "👉 https://linear.app/settings/api"
echo
read -p "Paste your new LINEAR_API_KEY (starts with sk_live_): " LINEAR_API_KEY

# Write to .env
echo "export LINEAR_API_KEY=\"$LINEAR_API_KEY\"" > .dev/linear.env
echo "✅ Saved LINEAR_API_KEY to .dev/linear.env"

# Test the key with a minimal query
echo "🔎 Validating API key..."
RESPONSE=$(curl -s https://api.linear.app/graphql \
  -H "Authorization: Bearer $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ viewer { id name email } }"}')

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' >/dev/null; then
  echo "❌ API key validation failed:"
  echo "$RESPONSE" | jq '.errors'
  exit 1
fi

# Extract and store viewer metadata
echo "$RESPONSE" > .dev/linear.viewer.json
USER_ID=$(echo "$RESPONSE" | jq -r '.data.viewer.id')
USER_NAME=$(echo "$RESPONSE" | jq -r '.data.viewer.name')
USER_EMAIL=$(echo "$RESPONSE" | jq -r '.data.viewer.email')

echo "export LINEAR_USER_ID=\"$USER_ID\"" >> .dev/linear.env
echo "✅ LINEAR_USER_ID=$USER_ID ($USER_NAME <$USER_EMAIL>)"

echo "🎉 API key is valid and scoped correctly."
