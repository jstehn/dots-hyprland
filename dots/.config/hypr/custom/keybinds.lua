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

--# Scrolling layout
hl.bind("SUPER + SHIFT + Apostrophe", hl.dsp.layout("fit all"), { description = "Layout: Fit all columns to screen evenly" })
hl.bind("SUPER + U", hl.dsp.layout("consume"), { description = "Layout: Stack (consume adjacent window into column)" })
hl.bind("SUPER + SHIFT + U", hl.dsp.layout("expel"), { description = "Layout: Unstack (expel window from column)" })

-- Override SUPER+SHIFT+Left/Right: swap columns instead of stacking into adjacent column.
-- At the leftmost/rightmost column, move to the adjacent monitor instead of wrapping.
hl.unbind("SUPER + SHIFT + Left")
hl.unbind("SUPER + SHIFT + Right")

local function swapcol_or_move_monitor(dir)
    local win = hl.get_active_window()
    if not win then return end
    local ws = win.workspace
    if not ws then return end

    local function get_x(w)
        local at = w.at
        if type(at) == "table" then return at.x or at[1] or 0 end
        return at or 0
    end

    local win_x = get_x(win)
    local at_edge = true
    for _, w in ipairs(hl.get_windows({ workspace = ws })) do
        if not w.floating and w.address ~= win.address then
            local wx = get_x(w)
            if (dir == "l" and wx < win_x) or (dir == "r" and wx > win_x) then
                at_edge = false
                break
            end
        end
    end

    if at_edge then
        hl.dispatch(hl.dsp.window.move({ monitor = dir }))
        -- Push to the near edge of the new monitor: entering from right → leftmost column,
        -- entering from left → rightmost column. wrap_swapcol=false makes extras no-ops.
        local opposite = dir == "r" and "l" or "r"
        for _ = 1, 50 do
            hl.dispatch(hl.dsp.layout("swapcol " .. opposite))
        end
    else
        hl.dispatch(hl.dsp.layout("swapcol " .. dir))
    end
end

hl.bind("SUPER + SHIFT + Left",
    function() swapcol_or_move_monitor("l") end,
    { description = "Window: Swap column left (move to left monitor at edge)" })
hl.bind("SUPER + SHIFT + Right",
    function() swapcol_or_move_monitor("r") end,
    { description = "Window: Swap column right (move to right monitor at edge)" })
