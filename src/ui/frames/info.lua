local infoCallbacks = {
    ["ping"] = { name = "Ping", fn = function() return sampGetPlayerPing(MyID()) end },
    ["id"] = { name = "ID", fn = function() return MyID() end },
    ["name"] = { name = "Nickname", fn = function() return sampGetPlayerNickname(MyID()) end },
    ["fps"] = { name = "FPS", fn = function() end },
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
}

local testString = {
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

local itemsLabels = {
    ["text:(.+)"] = function(arg)
        return arg
    end,
    ["icon:(.+)"] = function(arg)
        return faicons(arg)
    end,
    ["data:(.+)"] = function(arg)
        local data = infoCallbacks[arg]
        return data and tostring(data.fn()) or "NULL"
    end,
    ["spacing"] = function() return "spacing" end,
    ["newline"] = function() return "newline" end
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
    end
    return "NULL", "UNK:" .. item
end

local editMode = {
    type = nil,
    index = nil
}

imgui.OnFrame(
    function() return true end,
    function(frame)
        frame.HideCursor = not UI.edit
        if (imgui.Begin("MouHUD: Info", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize)) then
            imgui.PushFont(UI.font[20].Bold)
            for index, item in ipairs(testString) do
                local nextItem = testString[index + 1]
                if (item:find("text:(.+)")) then
                    local text = item:match("text:(.+)")
                    imgui.Text(tostring(text))
                elseif (item:find("icon:(.+)")) then
                    local icon = item:match("icon:(.+)")
                    imgui.Text(faicons(icon))
                elseif (item:find("data:(.+)")) then
                    local fnField = item:match("data:(.+)")
                    local data = infoCallbacks[fnField]
                    imgui.Text(data and tostring(data.fn()) or "NULL")
                elseif (item == "newline") then
                    imgui.Text("")
                end
                if ((nextItem or "newline") ~= "newline") then
                    imgui.SameLine(nil, item == "spacing" and 5 or 0)
                else
                    print("Skip sameline at index", index, item)
                    -- imgui.Spacing()
                end
            end
            imgui.PopFont()
        end
        imgui.End()
    end
)

local function __editorFrame(drawList, pos, size)
    imgui.PushFont(UI.font[15].Bold)
        
            for index, item in ipairs(testString) do
                local nextItem = testString[index + 1]
                local itemType, itemValue = getLabelData(item)
                local buttonLabel = itemValue .. "##" .. index
                if (imgui.Button(buttonLabel)) then
                    if (itemType == "text") then
                        editMode = { type = itemType, index = index, buff = imgui.new.char[128](itemValue) }
                        imgui.OpenPopup("info-edit-item")
                    end
                end
                if (imgui.IsItemClicked(1)) then
                    table.remove(testString, index)
                end
                if (imgui.BeginDragDropSource(1)) then
                    imgui.SetDragDropPayload('##payload', ffi.new('int[1]', index), 23);
                end
                if (imgui.BeginDragDropTarget()) then
                    local Payload = imgui.AcceptDragDropPayload(nil, 1);
                    if (Payload ~= nil) then
                        local oldIndex = ffi.cast("int*",Payload.Data)[0];
                        local firstItem = testString[oldIndex]
                        testString[oldIndex] = item
                        testString[index] = firstItem
                    end
                    imgui.EndDragDropTarget();
                end

                if (nextItem and nextItem ~= "newline") then
                    imgui.SameLine(nil, 5)
                end
            end
            imgui.SameLine()

            -- Edit item
            if (imgui.BeginPopupModal("info-edit-item", nil, imgui.WindowFlags.AlwaysAutoResize)) then
                imgui.Text("Edit item")
                if (editMode.type == "text") then
                    if (imgui.InputText("##edit-label-as-text", editMode.buff, 128)) then
                        testString[editMode.index] = "text:" .. ffi.string(editMode.buff)
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
                    table.insert(testString, "text:Left click to edit this label")
                end
                if (imgui.MenuItemBool("Spacing")) then
                    table.insert(testString, "spacing")
                end
                if (imgui.MenuItemBool("New line")) then
                    table.insert(testString, "newline")
                end
                if (imgui.BeginMenu("Icon")) then
                    for _, icon in ipairs(UI.font.requiredIcons) do
                        if (imgui.MenuItemBool(faicons(icon), icon)) then
                            table.insert(testString, "icon:" .. icon)
                        end
                    end
                    imgui.EndMenu()
                end
                if (imgui.BeginMenu("Info")) then
                    for k, v in pairs(infoCallbacks) do
                        if (imgui.MenuItemBool(v.name, tostring(v.fn() or ""))) then
                            table.insert(testString, "data:" .. k)
                        end
                    end
                    imgui.EndMenu();
                end
                imgui.EndPopup();
            end
        
        imgui.PopFont()
end

return {
    name = "Info",
    description = "Display any info as widget",
    onDraw = __editorFrame
}