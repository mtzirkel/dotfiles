#!/bin/bash
# Dotfiles install script — cross-platform (macOS + Linux)
# Symlinks configs and assembles platform-specific files
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
OS="$(uname)"

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
echo "Detected OS: $OS"
echo ""

# --- Neovim ---
echo "nvim:"
mkdir -p ~/.config
link "$DOTFILES/nvim" ~/.config/nvim

# --- Ghostty (assembled from base + platform) ---
echo "ghostty:"
mkdir -p ~/.config/ghostty
if [ "$OS" = "Darwin" ]; then
    cat "$DOTFILES/ghostty/config.base" "$DOTFILES/ghostty/config.macos" > ~/.config/ghostty/config
    echo "  assembled: config.base + config.macos -> ~/.config/ghostty/config"
elif [ "$OS" = "Linux" ]; then
    cat "$DOTFILES/ghostty/config.base" "$DOTFILES/ghostty/config.linux" > ~/.config/ghostty/config
    echo "  assembled: config.base + config.linux -> ~/.config/ghostty/config"
fi

# Copy custom Ghostty themes (ones without built-in support)
mkdir -p ~/.config/ghostty/themes
for theme in "$DOTFILES/ghostty/themes/"*; do
    [ -f "$theme" ] && cp "$theme" ~/.config/ghostty/themes/
done
echo "  copied: custom themes -> ~/.config/ghostty/themes/"

# --- Zellij ---
echo "zellij:"
mkdir -p ~/.config/zellij
link "$DOTFILES/zellij/config.kdl" ~/.config/zellij/config.kdl

# --- herdr ---
echo "herdr:"
mkdir -p ~/.config/herdr
link "$DOTFILES/herdr/config.toml" ~/.config/herdr/config.toml

# --- tmux (fallback: `hwt`) ---
echo "tmux:"
link "$DOTFILES/tmux/.tmux.conf" ~/.tmux.conf

# --- ssh host fragments (never touches keys) ---
echo "ssh:"
mkdir -p ~/.ssh/config.d && chmod 700 ~/.ssh
for frag in "$DOTFILES/ssh/config.d/"*; do
    ln -sf "$frag" ~/.ssh/config.d/"$(basename "$frag")"
    echo "  linked: $frag -> ~/.ssh/config.d/"
done
# Include must come before any Host block, so prepend it once.
touch ~/.ssh/config
if ! grep -q '^Include config.d/\*' ~/.ssh/config; then
    { echo 'Include config.d/*'; echo; cat ~/.ssh/config; } > ~/.ssh/config.tmp
    mv ~/.ssh/config.tmp ~/.ssh/config && chmod 600 ~/.ssh/config
    echo "  added: Include config.d/* to ~/.ssh/config"
fi

# --- headwaters only: herdr boot at login (replaces the tmux LaunchAgents) ---
if [ "$OS" = "Darwin" ] && [[ "$(scutil --get LocalHostName 2>/dev/null | tr '[:upper:]' '[:lower:]')" == headwaters* ]]; then
    echo "headwaters:"
    # copied, not linked: launchd can skip symlinked plists at login
    cp "$DOTFILES/launchd/local.herdr-boot.plist" ~/Library/LaunchAgents/
    echo "  copied: local.herdr-boot.plist -> ~/Library/LaunchAgents/"
    echo "  load once with: launchctl bootstrap gui/\$(id -u) ~/Library/LaunchAgents/local.herdr-boot.plist"
fi

# --- Starship ---
echo "starship:"
mkdir -p ~/.config
link "$DOTFILES/starship/starship.toml" ~/.config/starship.toml

# --- Zsh ---
echo "zsh:"
link "$DOTFILES/zsh/.zshrc" ~/.zshrc

# --- Claude shell functions ---
echo "claude:"
link "$DOTFILES/claude/functions.sh" ~/.claude_functions.sh

# --- fzf key bindings (if installed) ---
if [ -f "$(brew --prefix 2>/dev/null)/opt/fzf/install" ]; then
    echo "fzf:"
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

echo ""
echo "Done! You may need to restart your shell or terminal."
