local navanim = {
    current = 0,
    to = 1,
    start = 0,
    drag = 0
}

function navanim:switchTo(newIndex, add)
    if (not newIndex) then
        newIndex = self.to + add
    end
    if (newIndex < 1) then
        newIndex = 4
    elseif (newIndex > 4) then
        newIndex = 1
    end
    self.to = newIndex
    self.start = os.clock()
end

local function nav(items, itemSize)
    local drawList = imgui.GetWindowDrawList()
    local totalSize = imgui.ImVec2((itemSize * #items), 26)
    
    imgui.NewLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - totalSize.x / 2)

    local p = imgui.GetCursorScreenPos()
    local padding = imgui.ImVec2(5, 5)
    local currentTabX = itemSize * (navanim.current - 1)
    drawList:AddRectFilled(p - padding, p + totalSize + padding, imgui.GetColorU32(imgui.Col.FrameBg), 100)
    drawList:AddRectFilled(p + imgui.ImVec2(currentTabX, 0), p + imgui.ImVec2(itemSize + currentTabX, totalSize.y), imgui.GetColorU32(imgui.Col.FrameBg, 1), 100)
    navanim.current = Utils.bringFloatTo(navanim.current, navanim.to, navanim.start, 1)
    
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0))
    if (imgui.BeginChild("settings-nav", totalSize, false)) then
        for k, v in ipairs(items) do
            if (imgui.Button(v.name, imgui.ImVec2(itemSize, totalSize.y))) then
                navanim:switchTo(k)
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
    if (not m) then
        return false
    end
    return m.x >= a.x and m.y >= a.y and m.x <= b.x and m.y <= b.y
end

local frames = {}

imgui.OnFrame(
    function() return UI.edit end,
    function(frame)
        if (#frames == 0) then
            for index, frame in ipairs(UI.Frames) do
                if (type(frame) == "table") then
                    frame.index = index
                    table.insert(frames, frame)
                end
            end
        end

        local res = imgui.GetIO().DisplaySize
        local size = imgui.ImVec2(500, 500)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, size.y * anim.progress), imgui.Cond.Always, imgui.ImVec2(0.5, 1))
        imgui.SetNextWindowSize(size, imgui.Cond.Always)
        -- imgui.PushStyleVarVec2(imgui.StyleVar.WindowMinSize, imgui.ImVec2(500, 50))
        if (imgui.Begin("MouHUD: Settings", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoScrollWithMouse)) then
            local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
            local bgDrawList, fgDrawList = imgui.GetBackgroundDrawList(), imgui.GetForegroundDrawList()

            imgui.PushFont(UI.font[16].Bold)
            bgDrawList:AddRectFilled(pos, pos + size + imgui.ImVec2(0, 40), imgui.GetColorU32(imgui.Col.WindowBg), 20, 4 + 8)
            local label = "Moujeek's HUD"
            local labelSize = imgui.CalcTextSize(label) + imgui.ImVec2(10, 10)
            local labelBgStart = pos + imgui.ImVec2(size.x / 2 - labelSize.x / 2, size.y - labelSize.y) + imgui.ImVec2(0, 40)
            bgDrawList:AddRectFilled(labelBgStart, labelBgStart + labelSize, imgui.GetColorU32(imgui.Col.FrameBg), 10, 1 + 2)
            bgDrawList:AddText(labelBgStart + imgui.ImVec2(5, 5), 0xFFffffff, label)
            local isSettingsHovered = imgui.IsMouseInRect(pos, pos + size + imgui.ImVec2(0, 40)) or imgui.IsWindowFocused(imgui.FocusedFlags.ChildWindows)
            if (anim.hovered ~= isSettingsHovered) then
                anim.hovered = isSettingsHovered
                anim.start = os.clock()
            end
            -- bgDrawList:AddRect(pos, pos + size + imgui.ImVec2(0, 40), isSettingsHovered and 0xFF00ff00 or 0xFF0000ff)

            anim.progress = Utils.bringFloatTo(anim.progress, anim.hovered and 1 or 0, anim.start, 1)


            

            nav(frames, 100)

            
            local contentSize = imgui.ImVec2(size.x - 30, size.y - imgui.GetCursorPosY() - 1)
            imgui.SetCursorPos(imgui.ImVec2(15 - (contentSize.x * (navanim.current - 1)) - (30 * (navanim.current - 1)) + navanim.drag, 15 + 10 + 26 + 10 + 15))
            for i, frame in ipairs(frames) do
                local p = imgui.GetCursorScreenPos()
                -- fgDrawList:AddRect(p, p + contentSize, 0xFFff0000)
                imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
                if (imgui.BeginChild("settings-page-content-" .. frame.index, contentSize, true)) then
                    local drawList, pos, size = imgui.GetWindowDrawList(), imgui.GetWindowPos(), imgui.GetWindowSize()

                    local wheel = imgui.GetIO().MouseWheel
                    if (wheel > 0) then
                        navanim:switchTo(navanim.to - 1)
                    elseif (wheel < 0) then
                        navanim:switchTo(navanim.to + 1)
                    end

                    if (frame.description) then
                        imgui.PushFont(UI.font[20].Bold)
                        imgui.TextWrapped(frame.description)
                        imgui.PopFont()
                    end
                    if (frame.editorFrame) then
                        frame.editorFrame(drawList, pos, size)
                    else
                        imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), "Error, field \":onFrame\" is nil")
                    end
                end
                imgui.EndChild()
                imgui.PopStyleVar()
                if (i < #frames) then
                    imgui.SameLine(nil, 30)
                end
            end
            
            imgui.PopFont()
        end
        imgui.End()
        -- imgui.PopStyleVar()
    end
)