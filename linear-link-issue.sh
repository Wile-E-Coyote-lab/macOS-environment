#!/bin/bash
# linear-link-issue.sh — Create a Linear issue and bind it to this workspace

set -euo pipefail
mkdir -p .linear

# Load API key
if [ ! -f .dev/linear.env ]; then
  echo "❌ .dev/linear.env not found. Run linear-init.sh first."
  exit 1
fi
source .dev/linear.env

# Prompt for team key and issue title
read -p "📌 Enter Linear team key (e.g., ENG): " TEAM_KEY
read -p "📝 Enter issue title: " ISSUE_TITLE

# Create issue via Linear CLI and log output
CLI_OUTPUT=$(linear issue create --title "$ISSUE_TITLE" --team "$TEAM_KEY" | tee .linear/issue_create.log)
echo "📤 CLI output logged to .linear/issue_create.log"

# Extract issue URL
ISSUE_URL=$(echo "$CLI_OUTPUT" | grep -oE 'https://linear\.app/[a-z0-9-]+/issue/[A-Z]+-[0-9]+/[^ ]+')

# Extract issue key (e.g., CHR-41)
ISSUE_KEY=$(echo "$ISSUE_URL" | grep -oE '[A-Z]+-[0-9]+')

# Validate and store
if [[ -z "$ISSUE_KEY" ]]; then
  echo "❌ Failed to extract issue key from CLI output."
  exit 1
fi

echo "$ISSUE_KEY" > .linear/issue_id
echo "✅ Linked to issue: $ISSUE_KEY"

# Optional: scaffold comment template
cat <<EOF > .linear/comment.tmpl
🔄 Commit by {{actor}} on {{branch}}:
- Message: {{message}}
- SHA: {{sha}}
- Files: {{files}}
EOF

echo "🧠 Comment template scaffolded at .linear/comment.tmpl"
