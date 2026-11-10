-- Passwords: open Bitwarden instead of 1Password (was: omarchy 1password).
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", "launch-bitwarden")

-- Super+Return is a plain terminal (run `herdr --remote headwaters` from it);
-- Super+Ctrl+Return opens local herdr on this machine.
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + CTRL + RETURN")
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + CTRL + RETURN", "Terminal (herdr)", { omarchy = "terminal-herdr" })

-- Super+Ctrl+Left/Right: previous/next workspace on this monitor
-- (replaces Omarchy's grouped-window focus on those keys).
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")
o.bind("SUPER + CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "m-1" }))
o.bind("SUPER + CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "m+1" }))
