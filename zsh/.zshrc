# ~/.zshrc — cross-platform (macOS + Linux)

# Starship prompt
eval "$(starship init zsh)"

# OS-specific setup
if [[ "$(uname)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

elif [[ "$(uname)" == "Linux" ]]; then
    # omakub environment (theme, terminal, editor vars)
    [[ -f ~/.config/omakub/env ]] && source ~/.config/omakub/env
fi

# Shared paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# uv / Python environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# fzf key bindings
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Claude Code shell functions
[[ -f ~/.claude_functions.sh ]] && source ~/.claude_functions.sh
