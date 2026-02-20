#!/bin/bash
# Dotfiles install script — symlinks configs to their expected locations
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        echo "  backup: $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "  linked: $src -> $dst"
}

echo "Installing dotfiles from $DOTFILES"

# Neovim
mkdir -p ~/.config
echo "nvim:"
link "$DOTFILES/nvim" ~/.config/nvim

# Ghostty
echo "ghostty:"
mkdir -p ~/.config/ghostty
link "$DOTFILES/ghostty/config" ~/.config/ghostty/config

# Zellij
echo "zellij:"
mkdir -p ~/.config/zellij
link "$DOTFILES/zellij/config.kdl" ~/.config/zellij/config.kdl

# tmux
echo "tmux:"
link "$DOTFILES/tmux/.tmux.conf" ~/.tmux.conf

# zsh
echo "zsh:"
link "$DOTFILES/zsh/.zshrc" ~/.zshrc
link "$DOTFILES/zsh/.zprofile" ~/.zprofile

echo ""
echo "Done! You may need to restart your shell or terminal."
