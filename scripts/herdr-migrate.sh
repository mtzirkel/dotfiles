#!/bin/bash
# One-time move from tmux to herdr. Run on every Mac after the herdr PR merges:
#   bash ~/dotfiles/scripts/herdr-migrate.sh
# On headwaters it also moves hermes-eddy from tmux into herdr.
# tmux `main` and its LaunchAgent stay as the `hwt` fallback during the pilot.
set -e
cd ~/dotfiles

IS_HW=no
[[ "$(scutil --get LocalHostName 2>/dev/null | tr '[:upper:]' '[:lower:]')" == headwaters* ]] && IS_HW=yes
echo "headwaters: $IS_HW"

# --- 1. pull the repo --------------------------------------------------
if ! git diff --quiet; then
    if [ "$IS_HW" = yes ]; then
        # headwaters' uncommitted WIP was committed in the herdr branch;
        # park the identical local copy so the pull is clean.
        git stash push -m "pre-herdr-migrate"
        echo "stashed local edits as 'pre-herdr-migrate' (drop once you've confirmed nothing is missing)"
    else
        echo "~/dotfiles has uncommitted edits — commit or stash them, then rerun:"
        git status -s
        exit 1
    fi
fi
git checkout main
git pull --ff-only

# --- 2. tools + links --------------------------------------------------
brew install herdr mosh
./install.sh

# --- 3. per-host -------------------------------------------------------
if [ "$IS_HW" = yes ]; then
    echo ""
    read -r -p "Move hermes-eddy into herdr now? This restarts the running Hermes TUI. [y/N] " ok
    if [ "$ok" = y ] || [ "$ok" = Y ]; then
        launchctl bootout "gui/$(id -u)/com.travis.hermes-eddy" 2>/dev/null || true
        mkdir -p ~/fw/retired
        [ -f ~/Library/LaunchAgents/com.travis.hermes-eddy.plist ] && mv ~/Library/LaunchAgents/com.travis.hermes-eddy.plist ~/fw/retired/
        tmux kill-session -t hermes-eddy 2>/dev/null || true
        launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/local.herdr-boot.plist 2>/dev/null || launchctl kickstart -k "gui/$(id -u)/local.herdr-boot"
        sleep 4
        herdr workspace list | python3 -c 'import json,sys; print("herdr workspaces:", [w["label"] for w in json.load(sys.stdin)["result"]["workspaces"]])'
        echo "Attach with: hw   (hermes is in the hermes-eddy workspace)"
    else
        echo "Skipped. hermes-eddy is still in tmux; rerun this script to move it."
    fi
else
    echo ""
    echo "Check for an old hw definition that would shadow the new one:"
    grep -n -E '(alias|function)[[:space:]]+hw|^hw[[:space:]]*\(\)' ~/.zshrc.local ~/.zprofile ~/.zshenv ~/.aliases 2>/dev/null || echo "  none found outside the dotfiles"
    grep -n -E '^Host[[:space:]].*\bhw\b' ~/.ssh/config 2>/dev/null && echo "  ^ old 'Host hw' in ~/.ssh/config — delete it; hw is a zsh function now" || true
    echo ""
    echo "Open a new shell, then: hw   (tmux fallback: hwt, no-mosh: hws)"
    echo "Moshi on iPhone: set the headwaters host's startup command to /opt/homebrew/bin/herdr"
fi
