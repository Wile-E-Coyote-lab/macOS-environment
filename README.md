# 🍏 macOS-Dotfiles-Starter

A banal, minimal template for automating developer environment setup on macOS.

This project is intended as a test space for setting up our new Linear/GitHub/Android-driven workflow.

---

## Purpose

This repository holds initial configuration files (dotfiles) and a setup script to automate common administrative tasks for a developer's machine.

**The goal is to move from manual configuration to a single-command setup.**

## 🛠️ Getting Started (Local Test)

1. **Clone the Repository:**
   ```bash
   git clone git@github.com:YourUsername/macOS-Dotfiles-Starter.git
   cd macOS-Dotfiles-Starter


Linear-Integrated Workspace Bootstrap

Overview

This repository scaffolds a modular, audit-ready macOS development environment with Linear issue linkage, GitHub Actions (GHA) comment delivery, and preflight verification. It is designed for technicians who need reproducible, interruption-resilient workflows.

Step-by-Step Bootstrap

1. Clone and inspect

git clone https://github.com/your-org/macOS-enviro.git
cd macOS-enviro

2. Install dependencies

brew bundle

Uses Brewfile to install required CLI tools and utilities.

3. Initialize workspace

bash linear-init.sh

Creates .dev/ and .linear/ directories, scaffolds environment files.

4. Generate Linear API key

bash linear_generate_api_key.sh

Guides technician through API key creation and stores it in .dev/linear.env.

5. Bootstrap viewer/team/project metadata

bash linear-bootstrap.sh

Fetches and caches metadata into .dev/linear.*.json for offline use.

6. Link to a Linear issue

bash linear-link-issue.sh

Prompts for team key and issue title, creates issue via CLI, extracts canonical ID (e.g. CHR-42), and writes .linear/issue_id.

7. Verify linkage

bash linear-verify.sh

Confirms .linear/issue_id is valid and workspace is push-ready.

Final Push Workflow

1. Stage intentional changes

git add linear-clean.sh linear-link-issue.sh .github/workflows/linear-notify.yml

2. Commit with issue reference

git commit -m "CHR-42: Add Linear linkage and clean script"

3. Push to main or feature branch

git push origin main

4. Observe GitHub Actions

Workflow Notify Linear triggers

Reads .linear/issue_id

Posts comment to Linear issue via GraphQL

Expected Linear Comment

Commit abc1234 by Shane on branch main

This confirms successful linkage and comment delivery.

Cleanup (optional before packaging)

bash linear-clean.sh

Removes .linear/issue_id, .dev/linear.env, and other local-only artifacts.

File Reference

File

Purpose

Brewfile

Declares CLI dependencies

setup.sh

macOS environment setup

mac_defaults.sh

Configures macOS system defaults

ssh.sh

SSH key and config setup

git_config.sh

Git identity and config setup

grep.sh

Utility for CLI parsing

.gitignore

Blocks secrets and local artifacts

.github/workflows/linear-notify.yml

GHA workflow to post comments to Linear

linear-init.sh

Creates workspace directories

linear-bootstrap.sh

Fetches viewer/team/project metadata

linear_generate_api_key.sh

Guides API key creation

linear-link-issue.sh

Creates and links to Linear issue

linear-verify.sh

Validates linkage and readiness

linear-clean.sh

Purges local-only artifacts

linear_api_response.sh

(Optional) Logs or inspects API responses

✅ Final Checklist Before Push

[x] .linear/issue_id exists and is valid

[x] .dev/linear.env is ignored via .gitignore

[x] Commit message references issue (e.g. CHR-42)

[x] GHA workflow is present and triggers on push

[x] Pre-commit hook blocks secrets and enforces linkage
