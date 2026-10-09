# dotfiles

Personal dotfiles for macOS and Linux.

## Contents

- `nvim/` — Neovim (LazyVim) configuration
- `ghostty/` — Ghostty terminal config
- `herdr/` — herdr config (prefix `ctrl+a`) + headwaters boot script
- `tmux/` — tmux config (fallback: `hwt`)
- `ssh/config.d/` — SSH host fragments, pulled in by `Include config.d/*`
- `launchd/` — LaunchAgents, installed on headwaters only
- `scripts/` — one-off migrations
- `zsh/` — zsh shell config (.zshrc, .zprofile)

## Install

```bash
git clone https://github.com/mtzirkel/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The install script symlinks everything to the expected locations, backing up any existing files.

## headwaters (herdr)

headwaters runs a persistent [herdr](https://herdr.dev) server; `local.herdr-boot` starts it at login, restores the saved layout, and relaunches `hermes` in the `hermes-eddy` workspace.

| Command | On headwaters | Anywhere else |
|---|---|---|
| `hw` | attach to herdr | `mosh headwaters -- herdr` |
| `hws` | — | same over plain SSH (mosh UDP blocked) |
| `hwt` | tmux `main` | tmux `main` over mosh (fallback) |

Detach: `ctrl+a` then `q`. All bindings: `ctrl+a` then `?`.

Host-specific bits are gated on `scutil --get LocalHostName` starting with `headwaters`, in both `zsh/.zshrc` and `install.sh`.

Moving an existing machine from tmux: `bash ~/dotfiles/scripts/herdr-migrate.sh`.

## Dependencies

### Neovim (0.10+)

**macOS:**
```bash
brew install neovim fzf ripgrep
```

**Linux:**
```bash
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim build-essential fzf
```

### Nerd Fonts

```bash
# macOS
brew install font-meslo-lg-nerd-font

# Linux
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
fc-cache -fv
```
