# ~/.zshrc — cross-platform (macOS + Linux)

# Paths first — everything below depends on these
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# OS-specific setup
if [[ "$(uname)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

elif [[ "$(uname)" == "Linux" ]]; then
    # Twomedux tools
    export OMAKUB_PATH="$HOME/.local/share/omakub"
    [[ -d "$OMAKUB_PATH/bin" ]] && export PATH="$OMAKUB_PATH/bin:$PATH"
fi

# Starship prompt
eval "$(starship init zsh)"

# uv / Python environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# zsh completion system
autoload -Uz compinit && compinit

# fzf key bindings
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Claude Code shell functions
[[ -f ~/.claude_functions.sh ]] && source ~/.claude_functions.sh

# mosh + tmux: attach (or create) a session on any remote host
# Usage: mx <host> [session]   → defaults to session "main"
mx () {
        mosh "$1" -- tmux new -A -D -s "${2:-main}"
}

# --- headwaters (herdr) -------------------------------------------------
# hw  = attach to herdr on headwaters (mosh from elsewhere, local on the box)
# hwt = old tmux `main` session, kept as a fallback during the herdr pilot
# Absolute paths: mosh/ssh commands on macOS don't get Homebrew's PATH.
HW_BIN=/opt/homebrew/bin
if [[ "$(uname)" == "Darwin" && "${(L)$(scutil --get LocalHostName 2>/dev/null)}" == headwaters* ]]; then
    hw() {
        if [[ -n "$HERDR_ENV" ]]; then echo "already inside herdr"; return 1; fi
        herdr "$@"
    }
    hwt() { tmux new-session -A -s main; }
else
    hw()  { mosh --server=$HW_BIN/mosh-server headwaters -- $HW_BIN/herdr "$@"; }
    hws() { ssh -t headwaters $HW_BIN/herdr "$@"; }   # plain SSH, if mosh UDP is blocked
    hwt() { mosh --server=$HW_BIN/mosh-server headwaters -- $HW_BIN/tmux new-session -A -s main; }
fi
