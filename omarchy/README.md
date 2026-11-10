# omarchy

Desktop tweaks for an Omarchy (Arch + Hyprland) laptop. `../install.sh` runs
`install.sh` here automatically when it detects Omarchy; it is safe to re-run.

## New machine (or hand this file to Claude)

```bash
git clone https://github.com/mtzirkel/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh     # needs sudo once, for packages
```

Run it from a terminal inside the Hyprland session so the theme and background
apply live. Then do the manual steps below.

## What install.sh does

| Area | Change |
|---|---|
| Packages | `hypridle`, `xscreensaver` (Binary Ring), `bitwarden`, `jq` |
| Screensaver | Omarchy's text screensaver off (`idle.screensaver: 0` in `~/.config/omarchy/shell.json`, lock stays 300s). `hypridle` runs `binaryring-screensaver` at 150s with a Tokyo Night screen shader (`screensaver/tokyo-night.glsl`) |
| Background | Nord theme + Nord's black-moon wallpaper recolored through `backgrounds/tokyo-night-clut.png`. Generated on the machine, since the source image ships with Omarchy |
| Hyprland | Snippets from `hypr/` appended between `-- >>> dotfiles/omarchy` markers in `~/.config/hypr/`: Binary Ring window rule, colored ssh borders, tighter gaps, floating cheatsheets, Super+Shift+/ opens Bitwarden, 3-finger workspace swipe, terminal and workspace keys (see Keys). Monitor scale 1.25 on a ThinkPad T14 Gen 5 only |
| Bar plugins | [Spaces](https://github.com/tornikegomareli/omarchy-spaces) replaces the stock workspace numbers (app icons per workspace, `perMonitor` on so it follows Omarchy's per-monitor 1-10); [omaherdr](https://github.com/njpatel/omaherdr) shows herdr agents, including headwaters' when a `herdr --remote headwaters` window is open. Needs a desktop session |
| Solaar | `solaar/rules.yaml` symlinked: MX Master 4 thumb button / haptic click = Omarchy menu; haptic hold + swipe = workspaces (natural direction: swipe left goes to the next one), up = fullscreen, down = close |
| Keys | Super+Return = plain terminal, Super+Ctrl+Return = local herdr; Super+Ctrl+Left/Right = previous/next workspace |
| the-source only | `HDMI-A-1` disabled (the Dell is cabled over both HDMI and USB-C/DP, and the HDMI link showed up as an invisible second screen); foot font size 11.5 for the 4K panel |
| bash | `ssh()` wrapper (`bash/ssh-borders.sh`) tags the foot window while connected: orange for twomed-home, purple for headwaters, yellow otherwise |
| Surfshark | Not launched at login (app setting off, autostart entry removed) |

Edit the files here, not the copies: `bin/` and `hypridle.conf` are symlinked;
`hypr/*.lua` snippets are copied in, so re-run `install.sh` after editing them.

## Manual steps (not scripted)

- `sudo tailscale up` and sign in
- `gh auth login` (account mtzirkel)
- ssh: new key, then `ssh-copy-id` to the other machines (see `../ssh/config.d/`)
- Zen browser (`zen-browser-bin`) as default, Bitwarden extension in it
- Surfshark (`surfshark-client` from AUR), only if wanted
- Hermes Agent: Ollama Cloud (`https://ollama.com/v1`), model `deepseek-v4.1-flash:cloud`
- Moshi Desktop webapp + `moshi-hook`/`moshi-web` user services, voxtype
- `~/AGENTS.md` with `~/.claude/CLAUDE.md` containing `@~/AGENTS.md`;
  `agents-machine-info` (installed by `../install.sh`) fills in the machine block
