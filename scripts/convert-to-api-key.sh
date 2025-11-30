#!/bin/bash
set -euo pipefail

echo "🔁 Replacing OAuth token usage with LINEAR_API_KEY..."

# 1. Replace access_token extraction from .linear/token_response.json
find . \( -name "*.sh" -o -name "*.ts" -o -name "*.js" \) -type f -print0 | while IFS= read -r -d '' file; do
  sed -i'' \
    -e 's|ACCESS_TOKEN="${LINEAR_API_KEY}"
    -e 's|Authorization: Bearer $ACCESS_TOKEN"
    "$file"
done

echo "✅ Replacements complete. OAuth logic replaced with LINEAR_API_KEY usage."
