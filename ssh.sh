#!/data/data/com.termux/files/usr/bin/bash

# --- SSH Setup Script for GitHub ---

echo "1. Generating SSH Key (ed25519)..."
# Check if key exists; if not, generate a new one
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519 -N ""
else
    echo "Key already exists. Skipping generation."
fi

echo "---"

echo "2. Starting the SSH Agent..."
# Start the SSH agent in the background
eval "$(ssh-agent -s)"

echo "---"

echo "3. Adding Key to Agent..."
# Add the private key to the agent
ssh-add ~/.ssh/id_ed25519

echo "---"

echo "4. Configuring ~/.ssh/config for GitHub..."
# Create or overwrite a basic config file for GitHub
cat <<EOF > ~/.ssh/config
Host github.com
    Hostname ssh.github.com
    Port 443
    IdentityFile ~/.ssh/id_ed25519
    User git
EOF
chmod 600 ~/.ssh/config

echo "---"

echo "5. ACTION REQUIRED: Copy and paste the public key below into your GitHub settings:"
# Output the public key for the user to copy
cat ~/.ssh/id_ed25519.pub

echo "--- SETUP COMPLETE ---"
echo "Run 'ssh -T github.com' to test the connection."
