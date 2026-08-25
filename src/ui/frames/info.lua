local infoCallbacks = {
    ["ping"] = { name = "Ping", fn = function() return sampGetPlayerPing(MyID()) end },
    ["id"] = { name = "ID", fn = function() return MyID() end },
    ["name"] = { name = "Nickname", fn = function() return sampGetPlayerNickname(MyID()) end },
    ["players_streamed"] = { name = "Players in stream", fn = function() return sampGetPlayerCount(true) end },
    ["players_total"] = { name = "Players on server", fn = function() return sampGetPlayerCount(false) end },
    ["server_name"] = { name = "Server Name", fn = function() return sampGetCurrentServerName() end },
    ["server_address"] = { name = "Server Address", fn = function() return table.concat({ sampGetCurrentServerAddress() }, ":") end },
    ["ped_position"] = { name = "Player position (XYZ)", fn = function() return ("X: %0.0f Y: %0.0f Z: %0.0f"):format(getCharCoordinates(PLAYER_PED)) end },
    ["ped_heading"] = { name = "Player headnig angle", fn = function() return getCharHeading(PLAYER_PED) end },
    ["ped_animation"] = { name = "Player animation (IFP:NAME)", fn = function() return ("%s:%s"):format(sampGetAnimationNameAndFile(sampGetPlayerAnimationId(MyID()))) end },
    ["ped_animation_id"] = { name = "Player animation ID", fn = function() return sampGetPlayerAnimationId(MyID()) end },
    ["system_time"] = { name = "System time", fn = function() return os.date("%d.%m.%y") end },
    ["system_date"] = { name = "System date", fn = function() return os.date("%H:%M:%S") end },
    ["fps"] = { name = "FPS", fn = function()
        if (not _G.FPS) then
            _G.FPS = { value = -1, updatedAt = os.clock() }
        else
            if (os.clock() - _G.FPS.updatedAt > 0.5) then
                _G.FPS.value = ("%.0f"):format(memory.getfloat(0xB7CB50, true))
                _G.FPS.updatedAt = os.clock()
            end
        end
        return _G.FPS.value
    end },
}

local test = {
    "icon:USER",
    "spacing",
    "data:name",
    "spacing",
    "text:(",
    "data:id",
    "text:)",
    "spacing",
    "data:ping",
    "newline",
    "icon:CALENDAR",
    "spacing",
    "data:system_date",
    "spacing",
    "icon:CLOCK",
    "spacing",
    "data:system_time",
}


local function getLabelData(item)
    if (not item:find(":")) then
        return item, item
    end
    local type, payload = item:match("(%w+):(.+)")
    if (type == "text") then
        return type, payload
    elseif (type == "icon") then
        return type, faicons(payload)
    elseif (type == "data") then
        local data = infoCallbacks[payload]
        return type, data and tostring(data.fn()) or "NULL"
    elseif (type == "spacing") then
        return type, payload
    end
    return "NULL", "UNK:" .. item
end

local editMode = {
    type = nil,
    index = nil
}

local fpsUpdatedAt, fpsRefreshRate = 0, 0.5



imgui.OnFrame(
    function() return isSampAvailable() end,
    function(frame)
        frame.HideCursor = not UI.edit
        if (imgui.Begin("MouHUD: Info", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground)) then
            imgui.SetWindowFontScale(Config.frames.info.fontScale[0])
            imgui.PushFont(UI.font[20].Bold)
            for index, item in ipairs(Config.frames.info.list) do
                local nextItem = Config.frames.info.list[index + 1]
                local itemType, itemString = getLabelData(item)
                local color, outlineSize, outlineColor = UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4
                
                if (itemType == "text" or itemType == "data" or itemType == "icon") then
                    UI.Components.OutlineText(itemString, color, outlineSize, outlineColor)
                elseif (itemType == "spacing") then
                    imgui.SameLine(nil, tonumber(itemString) or 5)
                elseif (itemType == "newline") then
                    imgui.Text("")
                end

                if ((nextItem or "newline") ~= "newline" and itemType ~= "spacing") then
                    imgui.SameLine(nil, 5)
                end
            end
            imgui.PopFont()
        end
        imgui.End()
    end
)

local function __editorFrame(drawList, pos, size)
    imgui.PushFont(UI.font[15].Bold)
    local p, childSize = imgui.GetCursorScreenPos(), imgui.ImVec2(size.x - 10, 300)
    drawList:AddRectFilled(p, p + childSize, imgui.GetColorU32(imgui.Col.FrameBg), 15)
    if (imgui.BeginChild("editor-items-query", childSize, false, imgui.WindowFlags.AlwaysHorizontalScrollbar)) then
        imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
        for index, item in ipairs(Config.frames.info.list) do
            local nextItem = Config.frames.info.list[index + 1]
            local itemType, itemValue = getLabelData(item)
            local buttonLabel = itemValue .. "##" .. index
            if (imgui.Button(buttonLabel)) then
                if (itemType == "text") then
                    editMode = { type = itemType, index = index, buff = imgui.new.char[128](itemValue) }
                    imgui.OpenPopup("info-edit-item")
                end
            end
            if (imgui.IsItemClicked(1)) then
                table.remove(Config.frames.info.list, index)
            end
            if (imgui.BeginDragDropSource(1)) then
                imgui.SetDragDropPayload('##payload', ffi.new('int[1]', index), 23);
            end
            if (imgui.BeginDragDropTarget()) then
                local Payload = imgui.AcceptDragDropPayload(nil, 1);
                if (Payload ~= nil) then
                    local oldIndex = ffi.cast("int*",Payload.Data)[0];
                    local firstItem = Config.frames.info.list[oldIndex]
                    Config.frames.info.list[oldIndex] = item
                    Config.frames.info.list[index] = firstItem
                end
                imgui.EndDragDropTarget();
            end
            if (nextItem and nextItem ~= "newline") then
                imgui.SameLine(nil, 5)
            end
        end
        imgui.PopStyleColor()
        imgui.SameLine()
        
        -- Edit item
        if (imgui.BeginPopupModal("info-edit-item", nil, imgui.WindowFlags.AlwaysAutoResize)) then
            imgui.Text("Edit item")
            if (editMode.type == "text") then
                if (imgui.InputText("##edit-label-as-text", editMode.buff, 128)) then
                    Config.frames.info.list[editMode.index] = "text:" .. ffi.string(editMode.buff)
                end
            end
            if (imgui.Button("Close")) then
                editMode = { index = nil, type = nil }
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        -- Push new item
        if (imgui.Button(faicons("PLUS"))) then
            imgui.OpenPopup("info-push")
        end
        if (imgui.BeginPopup("info-push", nil)) then
            if (imgui.MenuItemBool("Text")) then
                table.insert(Config.frames.info.list, "text:Left click to edit this label")
            end
            -- if (imgui.MenuItemBool("Spacing")) then
            --     table.insert(Config.frames.info.list, "spacing")
            -- end
            if (imgui.BeginMenu("Spacing")) then
                for _, px in ipairs({5, 10, 15, 20, 25, 30, 45, 50, 75, 100}) do
                    if (imgui.MenuItemBool(px .. " px.")) then
                        table.insert(Config.frames.info.list, "spacing:" .. px)
                    end
                end
                imgui.EndMenu()
            end
            if (imgui.MenuItemBool("New line")) then
                table.insert(Config.frames.info.list, "newline")
            end
            if (imgui.BeginMenu("Icon")) then
                for _, icon in ipairs(UI.font.requiredIcons) do
                    if (imgui.MenuItemBool(faicons(icon), icon)) then
                        table.insert(Config.frames.info.list, "icon:" .. icon)
                    end
                end
                imgui.EndMenu()
            end
            if (imgui.BeginMenu("Info")) then
                for k, v in pairs(infoCallbacks) do
                    if (imgui.MenuItemBool(v.name, tostring(v.fn() or ""))) then
                        table.insert(Config.frames.info.list, "data:" .. k)
                    end
                end
                imgui.EndMenu();
            end
            imgui.EndPopup();
        end
    end
    imgui.EndChild()

    imgui.SliderFloat("Font scale", Config.frames.info.fontScale, 0.1, 4)
    imgui.PopFont()
end

return {
    name = "Info",
    description = "Display any info as widget",
    editorFrame = __editorFrame
}