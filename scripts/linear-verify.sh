#!/bin/bash
# linear-verify.sh — Confirm that Linear API key and context files are valid and complete

set -euo pipefail
cd "$(dirname "$0")"
PASS=true

echo "🔍 Verifying Linear context..."

# Check .env
if [ ! -f .dev/linear.env ]; then
  echo "❌ Missing .dev/linear.env"
  PASS=false
else
  source .dev/linear.env
  if [[ -z "${LINEAR_API_KEY:-}" ]]; then
    echo "❌ LINEAR_API_KEY not set in .dev/linear.env"
    PASS=false
  fi
fi

# Check required files
for file in linear.viewer.json linear.teams.json linear.projects.json linear.issues.json linear.context.js; do
  if [ ! -f ".dev/$file" ]; then
    echo "❌ Missing .dev/$file"
    PASS=false
  fi
done

# Check issue linkage
if [ ! -f .linear/issue_id ]; then
  echo "⚠️  No .linear/issue_id found — workspace not linked to a Linear issue"
else
  echo "🔗 Linked to issue: $(cat .linear/issue_id)"
fi

# Check comment template
if [ ! -f .linear/comment.tmpl ]; then
  echo "⚠️  No .linear/comment.tmpl found — GHA comments may be empty"
fi

# Final verdict
if $PASS; then
  echo "✅ Linear context is valid and complete"
  exit 0
else
  echo "❌ Linear context verification failed"
  exit 1
fi
