hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- Override Super+number: bring workspace to the current monitor instead of switching monitors
for i = 1, 10 do
    hl.unbind("SUPER + " .. (i % 10))
    hl.bind("SUPER + " .. (i % 10), function()
        hl.dispatch(hl.dsp.focus({ workspace = workspace_in_group(i), on_current_monitor = true }))
    end, { description = "Workspace: Focus " .. i .. " (this monitor)" })
end
for i = 1, 10 do
    local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
    hl.unbind("SUPER + code:" .. numberkey[i])
    hl.bind("SUPER + code:" .. numberkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = workspace_in_group(i), on_current_monitor = true }))
    end)
end
