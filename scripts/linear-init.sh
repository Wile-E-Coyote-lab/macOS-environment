#!/bin/bash
# linear-init.sh — One-step Linear bootstrap with API key prompt, validation, and context generation

set -euo pipefail
mkdir -p .dev

# Prompt for API key if .env is missing
if [ ! -f .dev/linear.env ]; then
  read -p "Enter your Linear API key (sk_live_...): " LINEAR_API_KEY
  LINEAR_API_KEY=$(echo "$LINEAR_API_KEY" | sed 's/^Bearer //')
  echo "export LINEAR_API_KEY=\"$LINEAR_API_KEY\"" > .dev/linear.env
  echo "✅ Saved API key to .dev/linear.env"
fi

# Load key
source .dev/linear.env
LINEAR_API_KEY=$(echo "$LINEAR_API_KEY" | sed 's/^Bearer //')

# Validate key
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

echo "$RESPONSE" > .dev/linear.viewer.json
USER_ID=$(jq -r '.data.viewer.id' .dev/linear.viewer.json)
USER_NAME=$(jq -r '.data.viewer.name' .dev/linear.viewer.json)
USER_EMAIL=$(jq -r '.data.viewer.email' .dev/linear.viewer.json)
echo "export LINEAR_USER_ID=\"$USER_ID\"" >> .dev/linear.env

# Fetch teams
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ teams { nodes { id name key } } }"}' \
  > .dev/linear.teams.json
TEAM_KEY=$(jq -r '.data.teams.nodes[0].key' .dev/linear.teams.json)
echo "export LINEAR_TEAM_KEY=\"$TEAM_KEY\"" >> .dev/linear.env

# Fetch projects
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ projects { nodes { id name state teams { nodes { key name } } } } }"}' \
  > .dev/linear.projects.json
PROJECT_ID=$(jq -r '.data.projects.nodes[0].id' .dev/linear.projects.json)
echo "export LINEAR_PROJECT_ID=\"$PROJECT_ID\"" >> .dev/linear.env

# Fetch issues
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ issues(first: 50) { nodes { id title state { name } assignee { name } } } }"}' \
  > .dev/linear.issues.json

# Generate context
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
    "LINEAR_USER_ID": "$USER_ID",
    "LINEAR_TEAM_KEY": "$TEAM_KEY",
    "LINEAR_PROJECT_ID": "$PROJECT_ID"
  },
  "files": [
    "linear.viewer.json",
    "linear.teams.json",
    "linear.projects.json",
    "linear.issues.json"
  ]
}
EOF

echo "$TIMESTAMP ✅ linear-init.sh completed" >> .dev/linear.status.log
echo "✅ Context logged to .dev/linear.context.js"
