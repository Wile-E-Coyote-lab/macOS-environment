#!/bin/bash
set -euo pipefail

echo "🔧 Replacing space-indented recipe bodies with tabs..."

tmp=$(mktemp)
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]{4,}[^[:space:]] ]]; then
    echo -e "\t${line#"${line%%[![:space:]]*}"}" >> "$tmp"
  else
    echo "$line" >> "$tmp"
  fi
done < justfile

mv "$tmp" justfile
echo "✅ justfile indentation corrected."
