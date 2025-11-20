#!/usr/bin/env bash

set -e

echo "[+] Updating package database..."
sudo pacman -Sy --noconfirm

# Base dependencies for Neovim and clipboard
echo "[+] Installing Neovim core dependencies..."
sudo pacman -S --needed --noconfirm \
    neovim xsel git curl wget gcc make python3 python-pip ruby ruby \
    ripgrep fd tree-sitter fzf python-pynvim python-black python-isort

# 1. Node.js management via nvm
if [ ! -d "$HOME/.nvm" ]; then
    echo "[+] Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    echo "[✓] NVM already present."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

echo "[+] Installing latest Node.js..."
nvm install --lts
nvm use --lts
echo "[+] Global npm packages for Neovim..."
npm install -g neovim yarn @fsouza/prettierd typescript-language-server

echo "[+] Installing Ruby provider..."
gem install neovim


# 4. Verify Treesitter & Telescope binaries
echo "[+] Checking external tools..."
command -v rg >/dev/null || echo "⚠️ ripgrep missing (should be installed)"
command -v fd >/dev/null || echo "⚠️ fd missing (should be installed)"

# 5. Build healthcheck summary
echo "[+] Running Neovim healthcheck..."
nvim --headless "+checkhealth" +qa

echo "[✓] Neovim setup complete."
echo "Restart shell (or source ~/.zshrc) to load nvm."
