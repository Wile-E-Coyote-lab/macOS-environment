# cli/oauth/extract_code_from_url.sh
#!/bin/bash
set -euo pipefail

# Accept full redirect URL as input
REDIRECT_URL="$1"

# Extract ?code=... from the URL
OAUTH_CODE=$(echo "$REDIRECT_URL" | sed -n 's/.*[?&]code=\([^&]*\).*/\1/p')

if [[ -z "$OAUTH_CODE" ]]; then
  echo "❌ No OAuth code found in URL"
  exit 1
fi

# Write to artifact
mkdir -p .linear
echo "$OAUTH_CODE" > .linear/oauth_code
echo "✅ OAuth code extracted and saved to .linear/oauth_code"

# Optional: push to GitHub Secrets
if command -v gh >/dev/null; then
  gh secret set LINEAR_OAUTH_CODE --body "$OAUTH_CODE"
  echo "🔐 LINEAR_OAUTH_CODE updated in GitHub Secrets"
else
  echo "⚠️ GitHub CLI not found. Skipping secret injection."
fi
