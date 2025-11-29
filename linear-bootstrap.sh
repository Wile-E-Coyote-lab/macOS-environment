#!/bin/bash
# linear-bootstrap.sh — Fetch Linear context using existing API key for workspace linkage and upstream orchestration

set -euo pipefail

# Optional: pass --clean to remove prior artifacts
CLEAN=false
[[ "${1:-}" == "--clean" ]] && CLEAN=true

mkdir -p .dev

# Load API key
if [ ! -f .dev/linear.env ]; then
  echo "❌ .dev/linear.env not found. Please create it with: export LINEAR_API_KEY=\"sk_live_...\""
  exit 1
fi

source .dev/linear.env
LINEAR_API_KEY=$(echo "$LINEAR_API_KEY" | sed 's/^Bearer //')

# Clean prior artifacts if requested
if $CLEAN; then
  echo "🧹 Cleaning prior .dev/linear.* artifacts..."
  rm -f .dev/linear.{viewer.json,teams.json,projects.json,issues.json,context.js}
  rm -f .dev/linear.issues.*.txt
fi

# Validate API key
echo "🔎 Validating API key..."
RESPONSE=$(curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ viewer { id name email } }"}')

if echo "$RESPONSE" | jq -e '.errors' >/dev/null; then
  echo "❌ API key validation failed:"
  echo "$RESPONSE" | jq '.errors'
  exit 1
fi

# Extract viewer metadata
echo "$RESPONSE" > .dev/linear.viewer.json
USER_ID=$(jq -r '.data.viewer.id' .dev/linear.viewer.json)
USER_NAME=$(jq -r '.data.viewer.name' .dev/linear.viewer.json)
USER_EMAIL=$(jq -r '.data.viewer.email' .dev/linear.viewer.json)

echo "export LINEAR_USER_ID=\"$USER_ID\"" >> .dev/linear.env
echo "✅ LINEAR_USER_ID=$USER_ID ($USER_NAME <$USER_EMAIL>)"

# Fetch teams
echo "🧑‍🤝‍🧑 Fetching teams..."
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ teams { nodes { id name key } } }"}' \
  > .dev/linear.teams.json

# Fetch projects
echo "📦 Fetching projects..."
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ projects { nodes { id name state team { key } } } }"}' \
  > .dev/linear.projects.json

# Fetch issues
echo "📝 Fetching issues..."
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ issues(first: 50) { nodes { id title state { name } team { key } assignee { name } } } }"}' \
  > .dev/linear.issues.json

# Log context
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat <<EOF > .dev/linear.context.js
{
  "timestamp": "$TIMESTAMP",
  "user": {
    "id": "$USER_ID",
    "name": "$USER_NAME",
    "email": "$USER_EMAIL"
  },
  "env": {
    "LINEAR_API_KEY": "${LINEAR_API_KEY:0:8}...REDACTED",
    "LINEAR_USER_ID": "$USER_ID"
  },
  "files": [
    "linear.viewer.json",
    "linear.teams.json",
    "linear.projects.json",
    "linear.issues.json"
  ]
}
EOF

echo "✅ Context logged to .dev/linear.context.js"
echo "$TIMESTAMP ✅ linear-bootstrap.sh completed" >> .dev/linear.status.log
