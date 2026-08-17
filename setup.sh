#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=========================================="
echo " Starting workstation setup script..."
echo "=========================================="

# 1. Update package lists and install dependencies
echo "==> Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y zsh tmux feh curl git

# 2. Install Oh My Zsh via Git clone (bypasses HTTP 429 rate limits)
echo "==> Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    if [ ! -f "$HOME/.zshrc" ]; then
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
    fi
else
    echo "Oh My Zsh is already installed."
fi

# 3. Set Zsh as default shell
echo "==> Setting Zsh as the default shell..."
ZSH_PATH=$(which zsh)
CURRENT_USER=$(whoami)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    sudo usermod -s "$ZSH_PATH" "$CURRENT_USER"
fi

# 4. Clone and set up dotfiles repository (bare repo + sparse-checkout)
echo "==> Setting up dotfiles..."
mkdir -p "$HOME/personal"
CFG_DIR="$HOME/personal/.cfg"

if [ ! -d "$CFG_DIR" ]; then
    git clone --bare https://github.com/kardasbart/dotfiles.git "$CFG_DIR"
fi

# Configure sparse-checkout to prevent repo files (README, setup.sh, etc.) from cluttering $HOME
/usr/bin/git --git-dir="$CFG_DIR" --work-tree="$HOME" config core.sparseCheckout true
/usr/bin/git --git-dir="$CFG_DIR" --work-tree="$HOME" config status.showUntrackedFiles no

mkdir -p "$CFG_DIR/info"
cat << 'EOF' > "$CFG_DIR/info/sparse-checkout"
/*
!/README.md
!/setup.sh
!/test.sh
!/Dockerfile
EOF

# Checkout only actual dotfiles into $HOME
/usr/bin/git --git-dir="$CFG_DIR" --work-tree="$HOME" checkout -f

# Append alias to .zshrc if not already present
if ! grep -q "alias config=" "$HOME/.zshrc" 2>/dev/null; then
    echo "alias config='/usr/bin/git --git-dir=\$HOME/personal/.cfg/ --work-tree=\$HOME'" >> "$HOME/.zshrc"
fi

# 5. Safely configure Git include path
echo "==> Configuring Git include path..."
git config --global include.path "~/.gitconfig-common"

# 6. Install Zsh plugins
echo "==> Installing Zsh plugins..."
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

# 7. Install Tmux Plugin Manager (TPM)
echo "==> Installing Tmux Plugin Manager (TPM)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "=========================================="
echo " Installation completed successfully!"
echo "=========================================="
echo "Next steps:"
echo "1. Restart your terminal or log out and back in for Zsh to become your default shell."
echo "2. Inside tmux, press 'Ctrl+b' then 'I' (capital i) to install tmux plugins."