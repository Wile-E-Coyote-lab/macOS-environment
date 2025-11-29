#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

source .env

./scripts/check-requirements.sh
./scripts/linear-bootstrap.sh
./scripts/linear-init.sh
./scripts/env_sync_secrets.sh
./scripts/validate-linear-token.sh
./scripts/linear-verify.sh
./scripts/linear-link-issue.sh || echo "Skipping issue linking"
./scripts/post-linear-content.sh
./scripts/linear_api_response.sh

echo "✅ Linear OAuth CLI suite executed successfully."
