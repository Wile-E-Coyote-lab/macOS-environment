#!/bin/bash

# --- Essential Git Configuration Script ---

# 1. Configure the Global User Name (Must match your professional name)
git config --global user.name "Your Name"

# 2. Configure the Global User Email (Must match your GitHub-linked email)
git config --global user.email "your.email@example.com"

# 3. Set the Default Branch Name (Standard practice since 2020)
git config --global init.defaultBranch main

# 4. Configure SSH as the standard protocol for push/pull (Crucial for Termux/SSH setup)
git config --global url."git@github.com:".insteadOf "https://github.com/"

echo "--- Git configuration complete ---"
echo "User: $(git config --global user.name)"
echo "Email: $(git config --global user.email)"
