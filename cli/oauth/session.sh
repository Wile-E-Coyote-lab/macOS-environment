#!/bin/bash
set -euo pipefail

# Load .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Validate required vars
: "${LINEAR_APP_ID:?LINEAR_APP_ID not set}"
: "${LINEAR_REDIRECT_URI:=http://127.0.0.1:8787/callback}"

# Start listener in background
echo "🔊 Starting OAuth listener..."
python3 cli/oauth/listener.py &
LISTENER_PID=$!

# Launch browser for authorization
AUTH_URL="https://linear.app/oauth/authorize?client_id=$LINEAR_APP_ID&redirect_uri=$LINEAR_REDIRECT_URI&response_type=code"
echo "🌐 Opening browser for OAuth authorization..."
open "$AUTH_URL" 2>/dev/null || xdg-open "$AUTH_URL" || echo "🔗 Visit manually: $AUTH_URL"

# Wait for code to appear
echo "⏳ Waiting for OAuth code..."
for i in {1..30}; do
  if [ -s .linear/oauth_code ]; then
    echo "✅ OAuth code captured"
    break
  fi
  sleep 1
done

# Kill listener
kill "$LISTENER_PID" 2>/dev/null || true

# Export to GitHub Secrets
OAUTH_CODE=$(cat .linear/oauth_code | tr -d '\n')
if command -v gh >/dev/null; then
  echo "🔐 Pushing code to GitHub Secrets..."
  gh secret set LINEAR_OAUTH_CODE --body "$OAUTH_CODE"
  echo "✅ LINEAR_OAUTH_CODE updated"
else
  echo "⚠️ GitHub CLI not found. Code saved locally only."
fi
