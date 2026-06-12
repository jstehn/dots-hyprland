hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

--# Scrolling layout
hl.bind("SUPER + SHIFT + Apostrophe", hl.dsp.layout("fit all"), { description = "Layout: Fit all columns to screen evenly" })
hl.bind("SUPER + U", hl.dsp.layout("consume"), { description = "Layout: Stack (consume adjacent window into column)" })
hl.bind("SUPER + SHIFT + U", hl.dsp.layout("expel"), { description = "Layout: Unstack (expel window from column)" })
