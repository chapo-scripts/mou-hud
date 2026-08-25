local navanim = {
    current = 0,
    to = 1,
    start = 0
}

local function nav(items, itemSize)
    local drawList = imgui.GetWindowDrawList()
    local totalSize = imgui.ImVec2((itemSize * #items) + 5, 26)
    
    imgui.NewLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - totalSize.x / 2)

    local p = imgui.GetCursorScreenPos()
    local padding = imgui.ImVec2(10, 10)
    drawList:AddRectFilled(p - padding, p + totalSize + padding, imgui.GetColorU32(imgui.Col.FrameBg), 100)
    drawList:AddRectFilled(p + imgui.ImVec2(navanim.current, 0), p + imgui.ImVec2(itemSize + navanim.current, totalSize.y), imgui.GetColorU32(imgui.Col.FrameBg, 1), 100)
    navanim.current = Utils.bringFloatTo(navanim.current, navanim.to, navanim.start, 1)
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0))
    if (imgui.BeginChild("settings-nav", totalSize, false)) then
        for k, v in ipairs(items) do
            if (imgui.Button(v.name, imgui.ImVec2(itemSize, totalSize.y))) then
                navanim.to = itemSize * (k - 1)
                navanim.start = os.clock()
            end
            if (k < #items) then
                imgui.SameLine(nil, 0)
            end
        end
    end
    imgui.EndChild()
    imgui.PopStyleColor()
end

local anim = {
    hovered = false,
    progress = 0,
    start = 0
}

function imgui.IsMouseInRect(a, b)
    local m = imgui.GetMousePos()
    return m.x >= a.x and m.y >= a.y and m.x <= b.x and m.y <= b.y
end

imgui.OnFrame(
    function() return UI.edit end,
    function(frame)
        local res = imgui.GetIO().DisplaySize
        local size = imgui.ImVec2(500, 500)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, size.y * anim.progress), imgui.Cond.Always, imgui.ImVec2(0.5, 1))
        imgui.SetNextWindowSize(size, imgui.Cond.Always)
        -- imgui.PushStyleVarVec2(imgui.StyleVar.WindowMinSize, imgui.ImVec2(500, 50))
        if (imgui.Begin("MouHUD: Settings", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoBackground)) then
            local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
            local bgDrawList = imgui.GetBackgroundDrawList()

            imgui.PushFont(UI.font[16].Bold)
            bgDrawList:AddRectFilled(pos, pos + size + imgui.ImVec2(0, 40), imgui.GetColorU32(imgui.Col.WindowBg), 20, 4 + 8)
            local label = "Moujeek's HUD"
            local labelSize = imgui.CalcTextSize(label) + imgui.ImVec2(10, 10)
            local labelBgStart = pos + imgui.ImVec2(size.x / 2 - labelSize.x / 2, size.y - labelSize.y) + imgui.ImVec2(0, 40)
            bgDrawList:AddRectFilled(labelBgStart, labelBgStart + labelSize, imgui.GetColorU32(imgui.Col.FrameBg), 10, 1 + 2)
            bgDrawList:AddText(labelBgStart + imgui.ImVec2(5, 5), 0xFFffffff, label)
            local isSettingsHovered = imgui.IsMouseInRect(pos, pos + size + imgui.ImVec2(0, 40))
            if (anim.hovered ~= isSettingsHovered) then
                anim.hovered = isSettingsHovered
                anim.start = os.clock()
            end
            -- bgDrawList:AddRect(pos, pos + size + imgui.ImVec2(0, 40), isSettingsHovered and 0xFF00ff00 or 0xFF0000ff)

            anim.progress = Utils.bringFloatTo(anim.progress, anim.hovered and 1 or 0, anim.start, 1)


            local frames = {}
            for _, frame in ipairs(UI.Frames) do
                if (type(frame) == "table") then
                    table.insert(frames, frame)
                end
            end

            nav(frames, 100)

            imgui.NewLine()
            local contentSize = imgui.ImVec2(size.x - 20, size.y - imgui.GetCursorPosY() - 10)
            if (imgui.BeginChild("settings-page-content", contentSize, true)) then
                imgui.Text("ASDASD")
            end
            imgui.EndChild()

            imgui.PopFont()
        end
        imgui.End()
        -- imgui.PopStyleVar()
    end
)