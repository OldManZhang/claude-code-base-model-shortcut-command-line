#!/bin/bash

# cc install script
# Usage: curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh

set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.cc/configs"
CC_REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing cc..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Install cc command
echo "Installing cc to $INSTALL_DIR/cc"
cp "$CC_REPO_DIR/bin/cc" "$INSTALL_DIR/cc"
chmod +x "$INSTALL_DIR/cc"

# Create config directory
mkdir -p "$CONFIG_DIR"

# Copy sample config if no configs exist
if [ ! -f "$CONFIG_DIR/env.kimi" ] && [ ! -f "$CONFIG_DIR/env.glm" ] && [ ! -f "$CONFIG_DIR/env.openai" ]; then
    echo "Installing sample configs to $CONFIG_DIR"
    for config in "$CC_REPO_DIR"/configs/env.*; do
        if [ -f "$config" ]; then
            cp "$config" "$CONFIG_DIR/"
        fi
    done

    # Copy sample
    if [ -f "$CC_REPO_DIR/env.sample" ]; then
        cp "$CC_REPO_DIR/env.sample" "$CONFIG_DIR/"
    fi
fi

# Add to PATH if not already in PATH
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q '~/.local/bin' "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo '# cc' >> "$SHELL_RC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo "Added ~/.local/bin to PATH in $SHELL_RC"
        echo "Please run: source $SHELL_RC"
    fi
fi

echo "Installation complete!"
echo "Run 'cc help' to get started."
