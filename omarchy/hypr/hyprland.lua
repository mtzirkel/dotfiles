-- Binary Ring screensaver (started by hypridle, see ~/.config/hypr/hypridle.conf).
o.window("BinaryRing", { fullscreen = true })
o.window("BinaryRing", { float = true })

-- Colored borders for SSH terminals (tagged by the ssh wrapper in ~/.bashrc).
-- Active color, then a dimmer inactive color so they stand out unfocused too.
o.window({ tag = "ssh" }, { border_color = "rgb(e0af68) rgba(e0af6888)" })
o.window({ tag = "ssh-twomed-home" }, { border_color = "rgb(ff9e64) rgba(ff9e6488)" })
o.window({ tag = "ssh-headwaters" }, { border_color = "rgb(bb9af7) rgba(bb9af788)" })
