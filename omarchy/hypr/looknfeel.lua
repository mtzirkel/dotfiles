-- Tighter gaps between windows and screen edges.
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
  },
})

-- Float the cheatsheets app as a centered window.
o.window("^(omarchy-cheatsheets)$", { float = true, center = true, size = { 980, 660 } })
