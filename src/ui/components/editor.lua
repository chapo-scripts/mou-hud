local EDITOR_ANIMATION_DURATION = 0.3
local anim = {}
---@type table<string, { pos: ImVec2, size: ImVec2, anim: {hovered: boolean, start: number, progress: number} }>
local windows = {}
local activeWindow = nil

imgui.OnFrame(
    function() return UI.edit end,
    function(frame)
        local drawList = imgui.GetBackgroundDrawList()
        local res = imgui.GetIO().DisplaySize
        for strId, window in pairs(windows) do
            local isActiveWindow = window.anim.hovered
            local gridColor = imgui.GetColorU32Vec4(imgui.ImVec4(1, 0.61, 0.16, window.anim.progress + 0.25))
            drawList:AddLine(imgui.ImVec2(window.pos.x, 0), imgui.ImVec2(window.pos.x, res.y), gridColor)
            drawList:AddLine(imgui.ImVec2(window.pos.x + window.size.x, 0), imgui.ImVec2(window.pos.x + window.size.x, res.y), gridColor)
            
            drawList:AddLine(imgui.ImVec2(0, window.pos.y), imgui.ImVec2(res.x, window.pos.y), gridColor)
            drawList:AddLine(imgui.ImVec2(0, window.pos.y + window.size.y), imgui.ImVec2(res.x, window.pos.y + window.size.y), gridColor)
            -- x
            local offsetsLabels = {
                { "" }
            }
            drawList:AddText(imgui.ImVec2(window.pos.x / 2, window.pos.y), 0xFF00ff00, tostring(window.pos.x))
            drawList:AddText(imgui.ImVec2((res.x - (window.pos.x + window.size.x)) / 2, window.pos.y), 0xFF00ff00, tostring(res.x - window.pos.x + window.size.x))
        end
    end
)

local function handleKeyboardControls()
    local pos = imgui.GetWindowPos()
    local offset = imgui.ImVec2(0, 0)

    -- for _, v in ipairs({})
    for key, offsets in pairs({
        [VK_LEFT] = {-1, 0},
        [VK_RIGHT] = {1, 0},
        [VK_UP] = {0, -1},
        [VK_DOWN] = {0, 1}
    }) do
        if (isKeyDown(key)) then
            if (isKeyDown(VK_LSHIFT)) then
                offsets[1], offsets[2] = offsets[1] * 10, offsets[2] * 10
            end
            offset.x, offset.y = offset.x + offsets[1], offset.y + offsets[2]
        end    
    end
    
    -- imgui.SetWindowSizeVec2(imgui.ImVec2(100, 100), imgui.Cond.Once)
    -- imgui.SetWindowPosVec2(pos + offset, imgui.Cond.Always)
end

---@param strId string
---@param params {}
return function(strId, params)
    if (not UI.edit) then
        return
    end

    if (activeWindow == strId) then
        handleKeyboardControls()
    end

    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    local mousePos = imgui.GetMousePos()
    local isWindowHovered = imgui.IsMouseHoveringRect(pos, pos + size)
    local isWindowActive = activeWindow == strId
    
    
    if (imgui.IsMouseClicked(0)) then
        if (isWindowHovered and not isWindowActive) then
            activeWindow = strId
        elseif (not isWindowHovered and isWindowActive) then
            activeWindow = nil
        end
    end

    local drawList = imgui.GetForegroundDrawList()
    
    if (not windows[strId]) then
        windows[strId] = {
            pos = pos,
            size = size,
            anim = { hovered = false, start = 0, progress = 0 }
        }
    end
    if (windows[strId].anim.hovered ~= isWindowActive) then
        windows[strId].anim.start = os.clock()
        windows[strId].anim.hovered = isWindowActive
    end
    windows[strId].pos, windows[strId].size = pos, size

    windows[strId].anim.progress = Utils.bringFloatTo(isWindowActive and 0 or 1, isWindowActive and 1 or 0, windows[strId].anim.start, EDITOR_ANIMATION_DURATION)
    drawList:AddRectFilled(pos, pos + size, UI.Colors.withAlpha(UI.Colors.Color.TextOutline.u32, windows[strId].anim.progress / 2), 5)

    if (isWindowActive) then
        imgui.SetMouseCursor(2)
    else
        drawList:AddRect(pos, pos + size, UI.Colors.withAlpha(UI.Colors.Color.Text.u32, UI.blink.alpha - windows[strId].anim.progress), 5)
    end

    imgui.PushFont(UI.font[20].Bold)
    local moveIcon = faicons("RESIZ")
    local moveIconSize = imgui.CalcTextSize(moveIcon)

    -- imgui.SetCursorPos(imgui.ImVec2(0, 0))
    -- if (imgui.BeginChild("e" .. strId, imgui.GetContentRegionAvail())) then
    --     imgui.Button(faicons("heart"))
    -- end
    -- imgui.EndChild()
    imgui.PopFont()
end