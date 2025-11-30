#!/usr/bin/env bash
set -euo pipefail

METADATA_FILE=".linear/issue"
COMMENT_BODY="${1:-}"

[[ -z "$COMMENT_BODY" ]] && {
  echo "Usage: $0 <comment_body>"
  exit 1
}

[[ "$LINEAR_API_KEY" =~ ^lin_api_[a-zA-Z0-9]{30,}$ ]] || {
  echo "❌ Invalid or missing LINEAR_API_KEY"
  exit 1
}

[[ -f "$METADATA_FILE" ]] || {
  echo "❌ Metadata file not found: $METADATA_FILE"
  exit 1
}

ISSUE_KEY=$(<"$METADATA_FILE")
[[ -z "$ISSUE_KEY" ]] && {
  echo "❌ Issue key is empty in metadata file"
  exit 1
}

# Resolve issueId from issueKey
ISSUE_LOOKUP=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN"
  -H "Content-Type: application/json" \
  -X POST https://api.linear.app/graphql \
  -d '{
    "query": "query IssueByKey($key: String!) { issue(key: $key) { id title } }",
    "variables": { "key": "'"$ISSUE_KEY"'" }
  }')

ISSUE_ID=$(echo "$ISSUE_LOOKUP" | jq -r '.data.issue.id // empty')

[[ -z "$ISSUE_ID" ]] && {
  echo "❌ Could not resolve issue ID for key: $ISSUE_KEY"
  echo "$ISSUE_LOOKUP" | jq
  exit 1
}

# Post comment
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
  -H "Content-Type: application/json" \
  -X POST https://api.linear.app/graphql \
  -d '{
    "query": "mutation CommentCreate($input: CommentCreateInput!) { commentCreate(input: $input) { success comment { id body } } }",
    "variables": {
      "input": {
        "issueId": "'"$ISSUE_ID"'",
        "body": "'"$COMMENT_BODY"'"
      }
    }
  }')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n1)

[[ "$STATUS" == "200" ]] || {
  echo "❌ HTTP $STATUS — mutation failed"
  echo "$BODY" | jq
  exit 1
}

echo "✅ Comment posted to $ISSUE_KEY:"
echo "$BODY" | jq '.data.commentCreate.comment'
