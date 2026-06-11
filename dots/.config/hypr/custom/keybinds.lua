hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("bash -c 'qs kill -c ${qsConfig:-ii} 2>/dev/null; sleep 0.3; qs -c ${qsConfig:-ii} & hyprctl reload'"), { description = "Reload: Restart Quickshell and reload Hyprland" })
