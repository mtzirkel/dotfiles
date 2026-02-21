#!/bin/bash
# Migrate an existing Omakub/Omabuntu machine to Twomedux
# Run this on a machine that already has omakub installed
set -e

echo "=== Migrating to Twomedux ==="
echo ""

# --- 1. Replace omakub repo with twomed-linux ---
echo "[1/8] Updating repo to Twomedux..."
cd ~/.local/share/omakub
git remote set-url origin https://github.com/mtzirkel/twomed-linux.git
git fetch origin main
git checkout main
git reset --hard origin/main
cd -

# Ensure bin scripts are on PATH
export PATH="$HOME/.local/share/omakub/bin:$PATH"

# --- 2. Install Ghostty ---
echo "[2/8] Installing Ghostty..."
if ! command -v ghostty &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
fi

# Set up Ghostty config
mkdir -p ~/.config/ghostty
cp ~/.local/share/omakub/config/ghostty/config ~/.config/ghostty/config

# Desktop entry for xdg-terminal-exec
mkdir -p ~/.local/share/applications ~/.local/share/xdg-terminals
cat > ~/.local/share/applications/com.mitchellh.ghostty.desktop << EOF
[Desktop Entry]
Type=Application
TryExec=ghostty
Exec=ghostty
Icon=com.mitchellh.ghostty
Terminal=false
Categories=System;TerminalEmulator;
Name=Ghostty
GenericName=Terminal
Comment=A fast, feature-rich, and cross-platform terminal emulator
StartupNotify=true
StartupWMClass=com.mitchellh.ghostty
Actions=New;
X-TerminalArgExec=-e
X-TerminalArgDir=--working-directory=

[Desktop Action New]
Name=New Terminal
Exec=ghostty
EOF
cp ~/.local/share/applications/com.mitchellh.ghostty.desktop ~/.local/share/xdg-terminals/

# Set as default terminal
rm -f ~/.config/xdg-terminals.list ~/.config/ubuntu-xdg-terminals.list ~/.config/GNOME-xdg-terminals.list
cat > ~/.config/ubuntu-xdg-terminals.list << EOF
com.mitchellh.ghostty.desktop
EOF
omakub-env-set TERMINAL "ghostty" 2>/dev/null || true

# --- 3. Set Everforest theme ---
echo "[3/8] Setting Everforest theme..."
omakub-theme-set "Everforest" 2>/dev/null || true

# --- 4. Update GNOME hotkeys ---
echo "[4/8] Updating keybinds..."
# Workspace navigation
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Ctrl><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Ctrl><Super>Right']"

# Rebrand hotkey labels
omakub-keybinding-remove 'Omabuntu Menu' 2>/dev/null || true
omakub-keybinding-remove 'Omabuntu Themes' 2>/dev/null || true
omakub-keybinding-remove 'Omabuntu Background Next' 2>/dev/null || true
omakub-keybinding-remove 'Omabuntu System' 2>/dev/null || true
omakub-keybinding-add 'Twomedux Menu' 'omakub-menu' '<Alt><Super>space' 2>/dev/null || true
omakub-keybinding-add 'Twomedux Themes' 'omakub-menu theme' '<Super><Shift><Control>space' 2>/dev/null || true
omakub-keybinding-add 'Twomedux Background Next' 'omakub-theme-bg-next' '<Super><Control>space' 2>/dev/null || true
omakub-keybinding-add 'Twomedux System' 'omakub-menu system' '<Super>Escape' 2>/dev/null || true

# Replace webapp hotkeys
omakub-keybinding-remove 'ChatGPT' 2>/dev/null || true
omakub-keybinding-remove 'WhatsApp' 2>/dev/null || true
omakub-keybinding-remove 'YouTube' 2>/dev/null || true
omakub-keybinding-remove 'GitHub' 2>/dev/null || true
omakub-keybinding-remove 'X' 2>/dev/null || true
omakub-keybinding-add 'Claude' 'omakub-launch-webapp "https://claude.ai" "Claude"' '<Super><Shift>a' 2>/dev/null || true
omakub-keybinding-add 'HEY' 'omakub-launch-webapp "https://app.hey.com" "HEY"' '<Super><Shift>h' 2>/dev/null || true

# --- 5. Install webapps ---
echo "[5/8] Setting up webapps..."
omakub-webapp-install "Claude" https://claude.ai/ Claude.png 2>/dev/null || true
omakub-webapp-install "HEY" https://app.hey.com/ HEY.png 2>/dev/null || true

# --- 6. Install extra apps ---
echo "[6/8] Installing apps (Bitwarden, Obsidian, Zen)..."
for app in bitwarden obsidian zen; do
    if [[ -f "$HOME/.local/share/omakub/applications/install/${app}.sh" ]]; then
        source "$HOME/.local/share/omakub/applications/install/${app}.sh" 2>/dev/null || true
    fi
done

# --- 7. Install zsh + dotfiles ---
echo "[7/8] Setting up zsh + dotfiles..."
sudo apt install -y zsh

if [ -d ~/.dotfiles ]; then
    git -C ~/.dotfiles pull || true
else
    git clone https://github.com/mtzirkel/dotfiles.git ~/.dotfiles
fi
bash ~/.dotfiles/install.sh

if [ "$(basename "$SHELL")" != "zsh" ]; then
    sudo chsh -s "$(which zsh)" "$USER"
fi

# --- 8. Update branding ---
echo "[8/8] Updating branding..."
mkdir -p ~/.config/omakub/branding
echo "Twomedux" > ~/.config/omakub/branding/brand

echo ""
echo "=== Twomedux migration complete! ==="
echo "Log out and back in for zsh to take effect."
echo "Ghostty is your new default terminal — launch with Super+Return."
