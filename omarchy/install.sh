#!/bin/bash
# Omarchy customizations from twomed-laptop. Safe to re-run.
# Called by ../install.sh on Omarchy, or run on its own.
set -e

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR=~/.config/hypr
BEGIN="-- >>> dotfiles/omarchy (managed, edit in ~/dotfiles/omarchy/hypr)"
END="-- <<< dotfiles/omarchy"

if [ ! -d /usr/share/omarchy ]; then
    echo "omarchy: not an Omarchy machine, skipping"
    exit 0
fi

# Append a snippet to one of Omarchy's user hypr files between markers, or
# refresh it if the markers are already there. Omarchy seeds these files and
# keeps them yours, so only the snippet is managed, not the whole file.
add_snippet() {
    local name="$1" dst="$HYPR/$1" src="$HERE/hypr/$1" line
    touch "$dst"
    if grep -qxF -- "$BEGIN" "$dst"; then
        awk -v b="$BEGIN" -v e="$END" '$0 == b { skip = 1 } !skip; $0 == e { skip = 0 }' "$dst" > "$dst.tmp"
        mv "$dst.tmp" "$dst"
    else
        # Already added by hand before this script existed: every code line present
        while IFS= read -r line; do
            grep -qxF -- "$line" "$dst" || break
        done < <(grep -v -e '^ *--' -e '^$' "$src")
        if [ -z "$line" ]; then  # read hit EOF: nothing missing
            echo "  skipped: $name already has these lines (unmarked)"
            return
        fi
    fi
    { echo "$BEGIN"; cat "$src"; echo "$END"; } >> "$dst"
    echo "  updated: $dst"
}

echo "omarchy packages:"
omarchy-pkg-add hypridle xscreensaver bitwarden jq

echo "omarchy scripts:"
mkdir -p ~/.local/bin
for f in "$HERE"/bin/*; do
    ln -sf "$f" ~/.local/bin/"$(basename "$f")"
    echo "  linked: $f -> ~/.local/bin/"
done

echo "omarchy hyprland:"
for f in hyprland.lua looknfeel.lua bindings.lua input.lua; do
    add_snippet "$f"
done
# Display scale for the ThinkPad T14 Gen 5 panel only
if grep -q "T14 Gen 5" /sys/class/dmi/id/product_version 2>/dev/null; then
    sed -i -e 's/^local omarchy_gdk_scale = .*/local omarchy_gdk_scale = 1/' \
           -e 's/^local omarchy_monitor_scale = .*/local omarchy_monitor_scale = 1.25/' "$HYPR/monitors.lua"
    echo "  set: monitor scale 1.25 (T14 Gen 5)"
fi

# the-source (AZW SER9 + Dell U4323QE): the Dell is cabled over both HDMI and
# DP (USB-C); Hyprland would treat HDMI as an invisible second screen.
if [ "$(hostname)" = "the-source" ]; then
    grep -q 'output = "HDMI-A-1", disabled = true' "$HYPR/monitors.lua" 2>/dev/null || \
        printf '\n-- Dell U4323QE is also cabled via HDMI (same panel as DP-2); ignore that input.\nhl.monitor({ output = "HDMI-A-1", disabled = true })\n' >> "$HYPR/monitors.lua"
    echo "  set: HDMI-A-1 disabled (the-source)"
    sed -i 's/^font=Adwaita Mono:size=.*/font=Adwaita Mono:size=11.5/' ~/.config/foot/foot.ini 2>/dev/null && \
        echo "  set: foot font size 11.5 (the-source, 4K panel)"
fi

echo "omarchy bar plugins:"
# Spaces (app icons per workspace) replaces the stock workspace numbers;
# omaherdr shows herdr agents, including ones on headwaters via herdr --remote.
add_plugin() {
    [ -d ~/.config/omarchy/plugins/"$1" ] && { echo "  present: $1"; return; }
    omarchy plugin add "$2" --enable --yes >/dev/null && echo "  added: $1"
}
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    add_plugin tornikegomareli.spaces https://github.com/tornikegomareli/omarchy-spaces.git
    add_plugin njpatel.omaherdr https://github.com/njpatel/omaherdr.git
    omarchy bar set tornikegomareli.spaces perMonitor true >/dev/null   # follow Omarchy's per-monitor 1-10
    omarchy plugin disable omarchy.workspaces >/dev/null 2>&1 || true
else
    echo "  skipped: run install.sh from a desktop session to add bar plugins"
fi

echo "omarchy solaar:"
# MX Master 4 gestures (thumb button = Omarchy menu, haptic hold + natural swipe = workspaces)
mkdir -p ~/.config/solaar
[ -e ~/.config/solaar/rules.yaml ] && [ ! -L ~/.config/solaar/rules.yaml ] && mv ~/.config/solaar/rules.yaml ~/.config/solaar/rules.yaml.bak
ln -sf "$HERE/solaar/rules.yaml" ~/.config/solaar/rules.yaml
echo "  linked: solaar/rules.yaml (restart solaar to apply)"

echo "omarchy screensaver:"
# Omarchy's text screensaver off; its lock stays at 300s
SHELL_JSON=~/.config/omarchy/shell.json
if [ -f "$SHELL_JSON" ]; then
    jq '.idle.screensaver = 0' "$SHELL_JSON" > "$SHELL_JSON.tmp" && mv "$SHELL_JSON.tmp" "$SHELL_JSON"
    echo "  set: idle.screensaver = 0 in $SHELL_JSON"
fi
mkdir -p ~/.config/omarchy/screensaver
ln -sf "$HERE/screensaver/tokyo-night.glsl" ~/.config/omarchy/screensaver/tokyo-night.glsl
[ -e "$HYPR/hypridle.conf" ] && [ ! -L "$HYPR/hypridle.conf" ] && mv "$HYPR/hypridle.conf" "$HYPR/hypridle.conf.bak"
ln -sf "$HERE/hypr/hypridle.conf" "$HYPR/hypridle.conf"
systemctl --user enable hypridle.service
systemctl --user restart hypridle.service 2>/dev/null || true
echo "  linked: hypridle.conf, tokyo-night.glsl; enabled hypridle (Binary Ring at 150s)"

echo "omarchy background:"
# Nord's black-moon wallpaper recolored through a Tokyo Night lookup table.
# Generated rather than committed: the original image is Omarchy's.
SRC=/usr/share/omarchy/themes/nord/backgrounds/0-black-moon.jpg
BG_DIR=~/.config/omarchy/backgrounds/nord
BG="$BG_DIR/1-black-moon-tokyo-night.jpg"
if [ -f "$SRC" ]; then
    mkdir -p "$BG_DIR"
    [ -f "$BG" ] || magick "$SRC" -colorspace gray -colorspace sRGB -type TrueColor \
        "$HERE/backgrounds/tokyo-night-clut.png" -clut -quality 92 "$BG"
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        [ "$(omarchy-theme-current 2>/dev/null)" = "Nord" ] || omarchy-theme-set "Nord"
        omarchy-theme-bg-set "$BG"
        echo "  set: Nord theme + $BG"
    else
        echo "  made: $BG (run omarchy-theme-set Nord and omarchy-theme-bg-set on it from a desktop session)"
    fi
else
    echo "  skipped: $SRC not found"
fi

echo "omarchy bash:"
if grep -q '^ssh()' ~/.bashrc 2>/dev/null; then
    echo "  skipped: ~/.bashrc already defines ssh()"
elif ! grep -q 'omarchy/bash/ssh-borders.sh' ~/.bashrc 2>/dev/null; then
    printf '\n# Colored Hyprland borders on ssh terminals, from dotfiles\n[[ -f %s ]] && source %s\n' \
        "$HERE/bash/ssh-borders.sh" "$HERE/bash/ssh-borders.sh" >> ~/.bashrc
    echo "  added: source ssh-borders.sh to ~/.bashrc"
fi

echo "omarchy surfshark:"
# Don't launch at login. The app recreates its autostart entry while its own
# setting is on, so turn both off. Only takes if the app isn't running.
SS=~/.config/Surfshark/globals.json
if [ -f "$SS" ]; then
    jq '.settings_autolaunch = false' "$SS" > "$SS.tmp" && mv "$SS.tmp" "$SS"
    echo "  set: settings_autolaunch = false"
fi
rm -f ~/.config/autostart/surfshark.desktop

hyprctl reload >/dev/null 2>&1 || true
