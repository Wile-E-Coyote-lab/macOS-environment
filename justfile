# Set default shell
set shell := ["bash", "-cu"]

# Run full suite (viewer query + logging)
run:

# Bootstrap environment and directories
bootstrap:

# Clean OAuth remnants and log auth context
clean:

# Validate .env and API key presence
check-env:
  test -f .env && grep -q LINEAR_API_KEY .env && echo "✅ .env and LINEAR_API_KEY present" || (echo "::error::Missing LINEAR_API_KEY" && exit 1)

# Test mutation dispatch (commentCreate or viewer)
test-mutation:

# Test response logging and summary generation
test-logging:
  test -f .linear/api_response.json && test -f .linear/summary.md && echo "✅ Response and summary exist" || (echo "::error::Missing response artifacts" && exit 1)

# Test archival logic
test-archive:
  ls .archive/api_response.*.json >/dev/null && echo "✅ Archive exists" || (echo "::error::No archived responses found" && exit 1)

# Full local test suite
test-all: check-env bootstrap run test-mutation test-logging test-archive clean

mutate-comment:

auth-check:
  bash .linear/env.sh

validate:
	bash scripts/validate.sh
