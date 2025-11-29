#!/data/data/com.termux/files/usr/bin/bash
# linear-env-from-api.sh — Extracts routed metadata and maps to .env

set -euo pipefail
mkdir -p .dev
source .dev/linear.env

# Fetch and store viewer
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ viewer { id name email } }"}' \
  > .dev/linear.viewer.json

USER_ID=$(jq -r '.data.viewer.id' .dev/linear.viewer.json)
echo "export LINEAR_USER_ID=\"$USER_ID\"" >> .dev/linear.env

# Fetch and store teams
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ teams { nodes { id name key } } }"}' \
  > .dev/linear.teams.json

TEAM_KEY=$(jq -r '.data.teams.nodes[] | select(.name=="Engineering") | .key' .dev/linear.teams.json)
echo "export LINEAR_TEAM_KEY=\"$TEAM_KEY\"" >> .dev/linear.env

# Fetch and store projects
curl -s https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ projects { nodes { id name state team { key } } } }"}' \
  > .dev/linear.projects.json

PROJECT_ID=$(jq -r '.data.projects.nodes[] | select(.name=="Chroma") | .id' .dev/linear.projects.json)
echo "export LINEAR_PROJECT_ID=\"$PROJECT_ID\"" >> .dev/linear.env

echo "✅ .dev/linear.env populated with routed metadata"
