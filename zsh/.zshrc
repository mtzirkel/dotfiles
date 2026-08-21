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

# OpenClaw Completion
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"

# mosh + tmux: attach (or create) a session on a remote host
# Usage: mx <host> [session]   → defaults to session "main"
mx () {
        mosh "$1" -- tmux new -A -D -s "${2:-main}"
}
alias hw='mx headwaters'
