#!/usr/bin/env bash

# --- Setup Script for macOS Developer Environment ---
# This script performs initial setup checks and links config files.

DOTFILES_REPO_DIR=$(pwd)
CONFIGS_DIR="$DOTFILES_REPO_DIR/configs"
HOME_DIR="$HOME"

echo "Starting macOS environment setup..."
echo "------------------------------------"

# 1. Install/Check for Homebrew (The macOS package manager)
if command -v brew >/dev/null 2>&1; then
    echo "✅ Homebrew is already installed."
else
    echo "⚠️ Homebrew not found. Installing now..."
    # The official Homebrew install command
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✅ Homebrew installed."
fi

# 2. Check for Oh My Zsh (Optional, but recommended for Zsh setup)
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    echo "⚠️ Oh My Zsh not found. Installing now..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME_DIR/.oh-my-zsh"
    echo "✅ Oh My Zsh installed."
fi

# 3. Create Symlinks for Dotfiles (The core orchestration step)
echo "------------------------------------"
echo "Creating symbolic link for .zshrc..."

# Backup existing .zshrc if it exists
if [ -f "$HOME_DIR/.zshrc" ]; then
    echo "   - Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME_DIR/.zshrc" "$HOME_DIR/.zshrc.bak"
fi

# Create the symbolic link
ln -s "$CONFIGS_DIR/.zshrc.template" "$HOME_DIR/.zshrc"
echo "✅ Symlink created: $HOME_DIR/.zshrc now links to the repository."

echo "------------------------------------"
echo "Setup complete. Please run 'source ~/.zshrc' or restart your shell."
