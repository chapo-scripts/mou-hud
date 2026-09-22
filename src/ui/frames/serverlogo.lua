ARIZONA_LOGO_SIZE = imgui.ImVec2(64, 64)
SERVER_LOGO_SIZE = imgui.ImVec2(32, 32)

local modeFlags = {
    [0] = 0,
    [1] = imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize,
    [2] = imgui.WindowFlags.NoTitleBar
}

imgui.OnFrame(
    function() return Config.frames.serverLogo.mode[0] > 0 end,
    function(frame)
        frame.HideCursor = true
        if (imgui.Begin("MouHUD: Logo", nil, modeFlags[Config.frames.serverLogo.mode[0]] + imgui.WindowFlags.NoBackground)) then
            local drawList, p = imgui.GetBackgroundDrawList(), imgui.GetCursorScreenPos()
            if (Config.frames.serverLogo.mode[0] == 1) then
                if (UI.logo.arizona) then
                    imgui.Dummy(ARIZONA_LOGO_SIZE)
                    local outlineSize = UI.outline.width
                    for _, p in ipairs({
                        p + imgui.ImVec2(outlineSize, outlineSize),
                        p + imgui.ImVec2(outlineSize, 0),
                        p + imgui.ImVec2(0, outlineSize),
                        p - imgui.ImVec2(outlineSize, 0),
                        p - imgui.ImVec2(0, outlineSize)
                    }) do
                        drawList:AddImage(UI.logo.arizona, p, p + ARIZONA_LOGO_SIZE, nil, nil, UI.Colors.Color.TextOutline.u32)
                    end
                    drawList:AddImage(UI.logo.arizona, p, p + ARIZONA_LOGO_SIZE, nil, nil, UI.Colors.Color.Text.u32)
                    -- imgui.Image(UI.logo.arizona, ARIZONA_LOGO_SIZE)
                end
                if (Config.frames.serverLogo.showServer[0]) then
                    imgui.SetCursorPos(imgui.ImVec2(ARIZONA_LOGO_SIZE.x - SERVER_LOGO_SIZE.x / 2, ARIZONA_LOGO_SIZE.y - SERVER_LOGO_SIZE.y / 2))
                    local p = imgui.GetCursorScreenPos()
                    drawList:AddCircleFilled(p + imgui.ImVec2(SERVER_LOGO_SIZE.x / 2, SERVER_LOGO_SIZE.y / 2), SERVER_LOGO_SIZE.x / 2 + UI.outline.width, UI.Colors.Color.TextOutline.u32)
                    if (UI.logo.server) then
                        drawList:AddImage(UI.logo.server, p, p + SERVER_LOGO_SIZE, nil, nil, UI.Colors.Color.Text.u32)
                    else
                        local path = Arizona:GetServerLogo(HUD.serverId)
                        if (path) then
                            UI.logo.server = imgui.CreateTextureFromFile(path)
                        else
                            drawList:AddCircleFilled(p + imgui.ImVec2(SERVER_LOGO_SIZE.x / 2, SERVER_LOGO_SIZE.y / 2), (SERVER_LOGO_SIZE.x / 2) * UI.blink.alpha, UI.Colors.Color.Text.u32)
                        end
                    end
                end

                if (Config.frames.serverLogo.showPlayers[0]) then
                    imgui.PushFont(UI.font[12].Bold)
                    local infoLabel = ("%s %s %s %s"):format(faicons("USER"), MyID(), faicons("USERS"), sampGetPlayerCount(false))
                    imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(infoLabel).x / 2)
                    
                    UI.Components.OutlineTextDL(drawList, UI.font[12].Bold, 12, p + imgui.ImVec2(0, ARIZONA_LOGO_SIZE.y + 7), infoLabel, UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4)
                    imgui.PopFont()
                end
            elseif (Config.frames.serverLogo.mode[0] == 2) then
                if (UI.logo.custom) then
                    imgui.Image(UI.logo.custom, imgui.GetWindowSize() - imgui.ImVec2(10, 10))
                else
                    local file = Arizona.RESOURCE_PATH .. "\\" .. Config.frames.serverLogo.customFile
                    if (Config.frames.serverLogo.customFile ~= "" and doesFileExist(file)) then
                        UI.logo.custom = imgui.CreateTextureFromFile(file)
                    else
                        -- Config.frames.serverLogo.mode[0] = 0
                        -- Utils.msg(Label.CHAT_ERROR_CUSTOM_LOGO_NOT_FOUND)
                    end
                end
            end
            UI.Components.Editor("logo", {})
        end
        imgui.End()
    end
)

local customLogos = nil

return {
    name = Label.TAB_SERVER_LOGO,
    description = Label.TAB_SERVER_DESCRIPTION,
    init = function()
        if (Config.frames.serverLogo.autoDetect[0]) then
            Config.frames.serverLogo.mode[0] = Arizona:IsArizona() and 1 or 0
        else
            if (Config.frames.serverLogo.mode[0] == 1 and not Arizona:IsArizona()) then
                Config.frames.serverLogo.mode[0] = 0
            end
        end
    end,
    editorFrame = function()
        imgui.PushFont(UI.font[20].Bold)
        imgui.TextDisabled(Label.TAB_SERVER_SETTINGS_TITLE_MODE)
        imgui.PopFont()
        imgui.RadioButtonIntPtr(Label.TAB_SERVER_SETTINGS_MODE_NONE .. "##Config.frames.serverLogo.mode-0", Config.frames.serverLogo.mode, 0)
        local arizonaSelecteChanged = imgui.RadioButtonIntPtr(Label.TAB_SERVER_SETTINGS_MODE_ARIZONA .. "##Config.frames.serverLogo.mode-1", Config.frames.serverLogo.mode, 1)
        if (not Arizona:IsArizona()) then
            imgui.SameLine()
            imgui.TextColored(UI.Colors.Color.Red.vec4, Label.TAB_SERVER_SETTINGS_MODE_ARIZONA_ERROR)
            if (arizonaSelecteChanged) then
                -- Config.frames.serverLogo.mode[0] = 0
            end
        end
        imgui.RadioButtonIntPtr(Label.TAB_SERVER_SETTINGS_MODE_CUSTOM .. "##Config.frames.serverLogo.mode-2", Config.frames.serverLogo.mode, 2)
        imgui.Checkbox(Label.TAB_SERVER_SETTINGS_AUTODETECT .. "##Config.frames.serverLogo.autoDetect", Config.frames.serverLogo.autoDetect)
        
        if (Config.frames.serverLogo.mode[0] == 1) then
            imgui.Checkbox(Label.TAB_SERVER_SETTINGS_ARIZONA_SHOW_SERVER .. "##Config.frames.serverLogo.showServer", Config.frames.serverLogo.showServer)
            imgui.Checkbox(Label.TAB_SERVER_SETTINGS_ARIZONA_SHOW_PLAYERS .. "##Config.frames.serverLogo.showPlayers", Config.frames.serverLogo.showPlayers)
            imgui.SliderFloat(Label.SCALE .. "##Config.frames.serverLogo.scale", Config.frames.serverLogo.scale, 0.1, 5, "x %0.1f")
        elseif (Config.frames.serverLogo.mode[0] == 2) then
            local files = Utils.getFilesInPath(Arizona.RESOURCE_PATH, "*.png")
            if (#files > 0) then
                imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 10))
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.FrameBg])
                if (imgui.BeginChild("", imgui.ImVec2(imgui.GetWindowWidth() - 20, 100))) then
                    for _, file in ipairs(files) do
                        if (imgui.Selectable(file .. "##Config.frames.serverLogo.customFile", file == Config.frames.serverLogo.customFile)) then
                            Config.frames.serverLogo.customFile = file
                            UI.logo.custom = nil
                        end
                    end
                end
                imgui.EndChild()
                imgui.PopStyleColor()
                imgui.PopStyleVar()
            else
                imgui.TextWrapped((Label.TAB_SERVER_SETTINGS_CUSTOM_ERROR):format(Arizona.RESOURCE_PATH))
            end
        end
    end
}