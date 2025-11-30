run:
	bash run-linear-suite.sh

bootstrap:
	@echo "🔧 Bootstrapping Linear project..."
	@test -f .env || (echo "::error::Missing .env file" && exit 1)
	@mkdir -p .linear .archive
	@echo "✅ Environment and directories ready"
