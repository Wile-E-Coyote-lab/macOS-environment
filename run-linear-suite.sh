#!/bin/bash
set -euo pipefail

echo "🔧 [1/9] Checking requirements..."
./scripts/check-requirements.sh

echo "🚀 [2/9] Bootstrapping Linear environment..."
./scripts/linear-bootstrap.sh

echo "🧰 [3/9] Initializing Linear project context..."
./scripts/linear-init.sh

echo "🔐 [4/9] Syncing secrets from .env to GitHub..."
./scripts/env_sync_secrets.sh

echo "🔄 [5/9] Running OAuth session flow..."
bash cli/oauth/session.sh

echo "🧪 [6/9] Validating Linear token..."
./scripts/validate-linear-token.sh

echo "🔎 [7/9] Verifying Linear issue context..."
./scripts/linear-verify.sh

echo "🔗 [8/9] Linking issue (optional)..."
./scripts/linear-link-issue.sh || echo "⚠️ Skipping issue linking"

echo "📝 [9/9] Posting content to Linear..."
./scripts/post-linear-content.sh

echo "📬 Capturing Linear API response..."
./scripts/linear_api_response.sh

echo "✅ Linear OAuth CLI suite executed successfully"
