BAR_ANMATION_DURATION = 0.25
BAR_HEIGHT = 12
BAR_WIDTH = 190
BAR_VALUES = {}

---@param DL ImDrawList
---@param icon string
---@param value number
---@param maxValue number
---@param panicValue? number
return function(DL, strId, icon, value, maxValue, outline, panicValue)
    if (BAR_VALUES[strId] == nil) then
        BAR_VALUES[strId] = {
            value = value,
            updatedAt = os.clock(),
            previousValue = 0,
            currentValue = value
        }
    else
        if (BAR_VALUES[strId].currentValue ~= value) then
            BAR_VALUES[strId].previousValue = BAR_VALUES[strId].currentValue
            BAR_VALUES[strId].currentValue = value
            BAR_VALUES[strId].updatedAt = os.clock()
        end
    end

    local color = Color.Text.vec4
    
    local value = Utils.bringFloatTo(BAR_VALUES[strId].previousValue, BAR_VALUES[strId].currentValue, BAR_VALUES[strId].updatedAt, BAR_ANMATION_DURATION)
    if (value > maxValue) then
        value = maxValue
    end
    UI.Components.OutlineText(faicons(icon), nil, UI.outline.width, UI.Colors.Color.TextOutline.vec4)
    imgui.SameLine(30)
    UI.Components.OutlineText(tostring(math.floor(value)), nil, UI.outline.width, UI.Colors.Color.TextOutline.vec4)
    imgui.SameLine(30 + 25)
    local p = imgui.GetCursorScreenPos()
    DL:AddRectFilled(p, p + imgui.ImVec2(BAR_WIDTH, BAR_HEIGHT), UI.Colors.Color.TextOutline.u32, 10)
    if (value > 3) then
        local barStart, barEnd = p + imgui.ImVec2(2, 2), p + imgui.ImVec2((BAR_WIDTH / 100 * value) - 2, BAR_HEIGHT - 2)
        DL:AddRectFilled(barStart, barEnd, imgui.GetColorU32Vec4(color), 10)

        if (panicValue and value <= panicValue) then
            DL:AddRectFilled(barStart, barEnd, UI.Colors.withAlpha(UI.Colors.Color.Red.u32, UI.blink.alpha), 10)
            -- Utils.msg("Draw panic for", strId, UI.blink.alpha)
        end
    end
    imgui.Dummy(imgui.ImVec2(BAR_WIDTH, BAR_HEIGHT))
end