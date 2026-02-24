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

# fzf key bindings
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Claude Code shell functions
[[ -f ~/.claude_functions.sh ]] && source ~/.claude_functions.sh
