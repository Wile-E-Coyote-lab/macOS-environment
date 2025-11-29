#!/usr/bin/env bash
# sync-env-to-gh-secrets.sh
# Technician-safe .env → GitHub Secrets parity script with validation and self-regulation

set -euo pipefail

# CONFIGURATION
REPO="Wile-E-Coyote-lab/macOS-environment"  # Replace with your GitHub org/repo
REQUIRED_SECRETS=(LINEAR_API_KEY)
ENV_FILE=".env"

# VALIDATION RULES
validate_secret() {
  local key="$1"
  local value="$2"

  if [[ -z "$value" ]]; then
    echo "::error::❌ $key is empty"
    return 1
  fi

  if [[ "$value" == "***" || "$value" == "changeme" ]]; then
    echo "::error::❌ $key contains a placeholder value: '$value'"
    return 1
  fi

  if [[ "$key" == "LINEAR_API_KEY" && ! "$value" =~ ^lin_api_[a-zA-Z0-9]+$ ]]; then
    echo "::error::❌ $key format invalid: '$value'"
    return 1
  fi

  return 0
}

# SELF-REGULATION: Ensure script is only run in correct context
if ! command -v gh &>/dev/null; then
  echo "::error::❌ GitHub CLI (gh) not found. Install it from https://cli.github.com/"
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "::error::❌ Missing $ENV_FILE file. Cannot sync secrets."
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "::error::❌ GitHub CLI not authenticated. Run: gh auth login"
  exit 1
fi

# MAIN SYNC LOOP
echo "🔄 Starting .env → GitHub Secrets sync for $REPO"
for key in "${REQUIRED_SECRETS[@]}"; do
  if ! grep -q "^$key=" "$ENV_FILE"; then
    echo "::error::❌ $key not found in $ENV_FILE"
    exit 1
  fi

  value=$(grep "^$key=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"')

  if validate_secret "$key" "$value"; then
    echo "🔐 Syncing $key..."
    echo -n "$value" | gh secret set "$key" --repo "$REPO" --body -
    echo "✅ $key synced successfully"
  else
    echo "::error::❌ Validation failed for $key. Aborting sync."
    exit 1
  fi
done

echo "✅ All secrets validated and synced to $REPO"
