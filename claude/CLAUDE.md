# Global Claude Code Instructions

## Terminal Commands
Always write terminal commands as single-line commands — no backslash line continuations (`\` at end of line). Travis pastes commands directly into the terminal and multi-line continuations break on paste. Long commands stay on one line.

For multi-step workflows (more than 2 commands), write a shell script to `~/fw/` or another short path and use `pbcopy` to stage the run command in the clipboard. Example pattern:
1. Write the script with Write tool
2. Run `echo -n 'bash ~/fw/script.sh' | pbcopy` so Travis can Cmd+V immediately
Do not use Obsidian notes for command runbooks — Obsidian adds formatting on copy.

## Background Task Results
When a `<task-notification>` with `status=completed` appears in the conversation,
**immediately surface the findings to the user** — do not process silently.

- Summarize what the agent found in plain language
- If it was a "Fix + Scan" agent (sent to find repeated issues across the codebase),
  present the full list of discovered locations and ask whether to queue them as tasks
- If the results are long, show a brief summary with the key actionable items first

## Fix + Scan Pattern
When you fix a bug or issue that could plausibly exist elsewhere in the codebase
(hardcoded colors, security patterns, repeated anti-patterns, etc.):
1. Fix the immediate instance
2. Immediately spawn a background Explore agent to scan for the same pattern elsewhere
   (`run_in_background=true`)
3. Continue with the main task
4. When the scan completes (task-notification arrives), surface results to the user
   and offer to queue the remaining fixes as tasks
