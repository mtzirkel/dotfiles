# shellcheck shell=bash
# Tag this terminal's window while ssh runs so Hyprland gives it a colored
# border (rules in ~/.config/hypr/hyprland.lua, added by dotfiles/omarchy). Known hosts get their own color.
ssh() {
  local pid=$$ host="" arg
  while [[ $pid -gt 1 && $(ps -o comm= -p "$pid") != foot ]]; do
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  done
  for arg in "$@"; do
    [[ $arg != -* ]] && host=${arg#*@} && break
  done
  local tag=ssh
  case $host in twomed-home|headwaters) tag=ssh-$host ;; esac

  if [[ $pid -gt 1 && -n $HYPRLAND_INSTANCE_SIGNATURE ]]; then
    hyprctl dispatch "hl.dsp.window.tag({ tag = \"+$tag\", window = \"pid:$pid\" })" >/dev/null 2>&1
    command ssh "$@"
    local rc=$?
    hyprctl dispatch "hl.dsp.window.tag({ tag = \"-$tag\", window = \"pid:$pid\" })" >/dev/null 2>&1
    return $rc
  fi
  command ssh "$@"
}
