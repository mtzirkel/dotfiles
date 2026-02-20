# dotfiles

Personal dotfiles for macOS and Linux.

## Contents

- `nvim/` — Neovim (LazyVim) configuration
- `ghostty/` — Ghostty terminal config
- `tmux/` — tmux config
- `zsh/` — zsh shell config (.zshrc, .zprofile)

## Install

```bash
git clone https://github.com/mtzirkel/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The install script symlinks everything to the expected locations, backing up any existing files.

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
