# Claude Code shell functions
# Source this from your .bashrc / .zshrc

YOLO_FLAGS="--dangerously-skip-permissions"

# Wrap the claude CLI so --yolo expands to the skip-permissions flag.
# The flag can appear anywhere in the arg list; everything else passes through.
# Usage: claude --yolo
#        claude --yolo -c
#        claude -p "fix the tests" --yolo
claude() {
    local args=() arg
    for arg in "$@"; do
        if [ "$arg" = "--yolo" ]; then
            args+=("$YOLO_FLAGS")
        else
            args+=("$arg")
        fi
    done
    command claude "${args[@]}"
}

# Start or resume a Claude session by name
# Usage: claude-session [name] [--yolo]
#   claude-session          → interactive resume picker
#   claude-session orgflow  → resume session matching "orgflow"
#   claude-session --yolo   → resume picker, skip permissions
claude-session() {
    local yolo=""
    local args=()
    for arg in "$@"; do
        if [ "$arg" = "--yolo" ]; then
            yolo="$YOLO_FLAGS"
        else
            args+=("$arg")
        fi
    done

    if [ ${#args[@]} -eq 0 ]; then
        claude --resume $yolo
    else
        claude --resume "${args[@]}" $yolo
    fi
}

# Open Claude in a specific project directory
# Usage: claude-project <alias> [--yolo]
# Add your projects to the case statement below
claude-project() {
    local dir yolo=""
    local project=""
    for arg in "$@"; do
        if [ "$arg" = "--yolo" ]; then
            yolo="$YOLO_FLAGS"
        else
            project="$arg"
        fi
    done

    case "$project" in
        orgflow)          dir="$HOME/Projects/OrgFlow" ;;
        album|album_bot)  dir="$HOME/Projects/album_bot" ;;
        dotfiles)         dir="$HOME/dotfiles" ;;
        *)
            echo "Unknown project: $project"
            echo "Available: orgflow, album, dotfiles"
            return 1
            ;;
    esac

    if [ -d "$dir" ]; then
        cd "$dir" && claude $yolo
    else
        echo "Directory not found: $dir"
        return 1
    fi
}

# Tab completion for claude-project
if [ -n "$ZSH_VERSION" ]; then
    _claude_project_completions() {
        local projects=(orgflow album album_bot dotfiles --yolo)
        compadd -a projects
    }
    compdef _claude_project_completions claude-project
elif [ -n "$BASH_VERSION" ]; then
    _claude_project_completions() {
        local projects="orgflow album album_bot dotfiles --yolo"
        COMPREPLY=($(compgen -W "$projects" -- "${COMP_WORDS[COMP_CWORD]}"))
    }
    complete -F _claude_project_completions claude-project
fi
