#!/bin/bash
set -euo pipefail

# Load environment
[ -f .env ] && export $(grep -v '^#' .env | xargs)

./scripts/check-requirements.sh
./scripts/linear-bootstrap.sh
./scripts/linear-init.sh
./scripts/env_sync_secrets.sh
bash cli/oauth/session.sh
bash scripts/validate-oauth-code.sh
./scripts/validate-linear-token.sh
./scripts/linear-verify.sh
./scripts/linear-link-issue.sh || echo "skip"
./scripts/post-linear-content.sh
./scripts/linear_api_response.sh
bash scripts/linear-session-status.sh
