local EDITOR_ANIMATION_DURATION = 0.3
local anim = {}
---@type table<string, { pos: ImVec2, size: ImVec2, anim: {hovered: boolean, start: number, progress: number} }>
local windows = {}
local lastHoveredWindow = nil

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

---@param strId string
---@param params {}
return function(strId, params)
    if (not UI.edit) then
        return
    end

    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    local mousePos = imgui.GetMousePos()
    local isWindowHovered = imgui.IsMouseHoveringRect(pos, pos + size)
    
    local drawList = imgui.GetForegroundDrawList()
    
    if (not windows[strId]) then
        windows[strId] = {
            pos = pos,
            size = size,
            anim = { hovered = false, start = 0, progress = 0 }
        }
    end
    if (windows[strId].anim.hovered ~= isWindowHovered) then
        windows[strId].anim.start = os.clock()
        windows[strId].anim.hovered = isWindowHovered
    end
    windows[strId].pos, windows[strId].size = pos, size

    windows[strId].anim.progress = Utils.bringFloatTo(isWindowHovered and 0 or 1, isWindowHovered and 1 or 0, windows[strId].anim.start, EDITOR_ANIMATION_DURATION)
    drawList:AddRectFilled(pos, pos + size, UI.Colors.withAlpha(UI.Colors.Color.TextOutline.u32, windows[strId].anim.progress / 2), 5)

    if (isWindowHovered) then
        imgui.SetMouseCursor(2)
    else
        drawList:AddRect(pos, pos + size, UI.Colors.withAlpha(UI.Colors.Color.Text.u32, UI.blink.alpha - windows[strId].anim.progress), 5)
    end

    imgui.PushFont(UI.font[20].Bold)
    local moveIcon = faicons("RESIZ")
    local moveIconSize = imgui.CalcTextSize(moveIcon)

    imgui.SetCursorPos(imgui.ImVec2(0, 0))
    if (imgui.BeginChild("e" .. strId, imgui.GetContentRegionAvail())) then
        imgui.Button(faicons("heart"))
    end
    imgui.EndChild()
    imgui.PopFont()
end