# ~/.zshrc — cross-platform (macOS + Linux)

# Starship prompt
eval "$(starship init zsh)"

# OS-specific setup
if [[ "$(uname)" == "Darwin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
    export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"

    # JetBrains Toolbox
    export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

elif [[ "$(uname)" == "Linux" ]]; then
    # omabuntu environment (theme, terminal, editor vars)
    [[ -f ~/.config/omakub/env ]] && source ~/.config/omakub/env
fi

# Shared paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# uv / Python environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# Claude Code shell functions
[[ -f ~/.claude_functions.sh ]] && source ~/.claude_functions.sh
