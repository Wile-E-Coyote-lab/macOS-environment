#!/bin/bash
set -euo pipefail

# ─── Load Environment ───────────────────────────────────
[ -f .env ] && export $(grep -v '^#' .env | xargs)

# ─── Validate Requirements ──────────────────────────────
./scripts/check-requirements.sh
./scripts/linear-bootstrap.sh
./scripts/linear-init.sh
./scripts/env_sync_secrets.sh

# ─── OAuth Session Flow ─────────────────────────────────
bash cli/oauth/session.sh
bash scripts/validate-oauth-code.sh
./scripts/validate-linear-token.sh

# ─── Issue Context and Mutation ─────────────────────────
./scripts/linear-verify.sh
./scripts/linear-link-issue.sh || echo "⚠️ Skipping issue linking"
./scripts/post-linear-content.sh
./scripts/linear_api_response.sh

# ─── Final Audit ────────────────────────────────────────
bash scripts/linear-session-status.sh
