#!/bin/bash
# Started at login on headwaters by ~/Library/LaunchAgents/local.herdr-boot.plist.
# Brings up the herdr server (which restores the saved layout as fresh shells)
# and relaunches `hermes` in the hermes-eddy workspace.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Optional first arg = named session, used for testing; HERMES_CMD overrides
# what gets launched in the hermes-eddy workspace.
herdr() { command herdr ${SESSION:+--session "$SESSION"} "$@"; }
SESSION=$1
HERMES_CMD=${HERMES_CMD:-hermes}

# Already running (e.g. you attached with `hw` first): leave it alone.
herdr status server 2>/dev/null | grep -q 'status: running' && exit 0

nohup /opt/homebrew/bin/herdr ${SESSION:+--session "$SESSION"} server >/dev/null 2>&1 </dev/null &
for _ in $(seq 1 20); do
  herdr workspace list >/dev/null 2>&1 && break
  sleep 0.5
done

ws_pane() {  # first pane of the workspace labelled $1, empty if none
  local ws
  ws=$(herdr workspace list 2>/dev/null | python3 -c '
import json, sys
print(next((w["workspace_id"] for w in json.load(sys.stdin)["result"]["workspaces"] if w["label"] == sys.argv[1]), ""))' "$1")
  [ -n "$ws" ] || return 0
  herdr pane list 2>/dev/null | python3 -c '
import json, sys
print(next((p["pane_id"] for p in json.load(sys.stdin)["result"]["panes"] if p["workspace_id"] == sys.argv[1]), ""))' "$ws"
}

[ -n "$(ws_pane main)" ] || herdr workspace create --cwd "$HOME" --label main --no-focus >/dev/null

PANE=$(ws_pane hermes-eddy)
if [ -z "$PANE" ]; then
  PANE=$(herdr workspace create --cwd "$HOME" --label hermes-eddy --no-focus | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
fi
sleep 1   # let the restored shell print its prompt before typing into it
herdr pane run "$PANE" "$HERMES_CMD"
exit 0
