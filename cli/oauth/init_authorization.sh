#!/bin/bash
set -euo pipefail

# Load .env if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

CLIENT_ID="${LINEAR_APP_ID:-}"
REDIRECT_URI="${LINEAR_REDIRECT_URI:-http://127.0.0.1:8787/callback}"

if [[ -z "$CLIENT_ID" ]]; then
  echo "❌ LINEAR_APP_ID is not set in .env or environment"
  exit 1
fi

AUTH_URL="https://linear.app/oauth/authorize?client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&response_type=code"

echo "🌐 Opening browser for OAuth authorization..."
open "$AUTH_URL" 2>/dev/null || xdg-open "$AUTH_URL" || echo "🔗 Visit this URL manually:"
echo "$AUTH_URL"
