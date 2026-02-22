#!/bin/bash
# Fresh Mac setup script
# Run after a clean macOS install to get back to a working dev environment.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mtzirkel/dotfiles/main/setup.sh | bash
#   — or —
#   git clone https://github.com/mtzirkel/dotfiles.git ~/dotfiles && bash ~/dotfiles/setup.sh
set -e

echo "=== Fresh Mac Setup ==="
echo ""

# -------------------------------------------------------
# 1. Xcode Command Line Tools
# -------------------------------------------------------
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press ENTER after the install dialog finishes."
    read -r
else
    echo "Xcode CLT: already installed"
fi

# -------------------------------------------------------
# 2. Homebrew
# -------------------------------------------------------
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew: already installed"
fi

# -------------------------------------------------------
# 3. Clone dotfiles (if not already)
# -------------------------------------------------------
DOTFILES="$HOME/dotfiles"
if [ ! -d "$DOTFILES" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/mtzirkel/dotfiles.git "$DOTFILES"
else
    echo "Dotfiles: already cloned at $DOTFILES"
fi

# -------------------------------------------------------
# 4. Brewfile — install formulas and casks
# -------------------------------------------------------
echo ""
echo "Installing from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# -------------------------------------------------------
# 5. Symlink dotfiles (install.sh)
# -------------------------------------------------------
echo ""
echo "Symlinking dotfiles..."
bash "$DOTFILES/install.sh"

# -------------------------------------------------------
# 6. uv (Python package manager)
# -------------------------------------------------------
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv: already installed"
fi

# -------------------------------------------------------
# 7. Claude Code global CLAUDE.md
# -------------------------------------------------------
echo ""
echo "Setting up Claude Code config..."
mkdir -p "$HOME/.claude"
if [ -f "$DOTFILES/claude/CLAUDE.md" ]; then
    cp "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    echo "  copied: CLAUDE.md -> ~/.claude/CLAUDE.md"
fi

# -------------------------------------------------------
# 8. Create common directories
# -------------------------------------------------------
mkdir -p "$HOME/Projects"
mkdir -p "$HOME/fw"

# -------------------------------------------------------
# 9. Flameshot as default screenshot tool
# -------------------------------------------------------
echo ""
echo "Configuring Flameshot..."
# Disable macOS default screenshot shortcuts so Flameshot can use them
# Cmd+Shift+3 (full screen) → disabled
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 '{ enabled = 0; value = { parameters = (65535, 20, 1179648); type = standard; }; }'
# Cmd+Shift+4 (selection) → disabled
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 '{ enabled = 0; value = { parameters = (65535, 21, 1179648); type = standard; }; }'
# Cmd+Shift+5 (screenshot toolbar) → disabled
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 184 '{ enabled = 0; value = { parameters = (65535, 23, 1179648); type = standard; }; }'
echo "  Disabled macOS screenshot shortcuts (Cmd+Shift+3/4/5)"
echo "  Open Flameshot preferences and set Cmd+Shift+4 as the capture hotkey"

# -------------------------------------------------------
# 10. macOS preferences
# -------------------------------------------------------
echo ""
echo "Setting macOS preferences..."
# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
# Disable press-and-hold for keys (enable key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
echo "  Applied Finder + keyboard preferences"

# -------------------------------------------------------
# Done
# -------------------------------------------------------
echo ""
echo "========================================="
echo "  Setup complete!"
echo "========================================="
echo ""
echo "Manual steps remaining:"
echo "  1. Open Tailscale and sign in"
echo "  2. Open Obsidian and enable vault sync"
echo "  3. Open Bitwarden and sign in"
echo "  4. Open Flameshot → Preferences → set Cmd+Shift+4 as capture hotkey"
echo "  5. Open Rectangle → grant accessibility permission, choose shortcuts"
echo "  6. Sign into GitHub CLI:  gh auth login"
echo "  7. Restart terminal to pick up new shell config"
echo ""
echo "To clone projects later:"
echo "  git clone https://github.com/mtzirkel/OrgFlow.git ~/Projects/OrgFlow"
echo ""
