ARIZONA_LOGO_SIZE = imgui.ImVec2(64, 64)
SERVER_LOGO_SIZE = imgui.ImVec2(32, 32)

imgui.OnFrame(
    function() return Config.frames.serverLogo.mode[0] > 0 end,
    function(frame)
        frame.HideCursor = true
        if (imgui.Begin("MouHUD: Logo", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground)) then
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
                    if (UI.logo.server) then
                        imgui.SetCursorPos(imgui.ImVec2(ARIZONA_LOGO_SIZE.x - SERVER_LOGO_SIZE.x / 2, ARIZONA_LOGO_SIZE.y - SERVER_LOGO_SIZE.y / 2))
                        local p = imgui.GetCursorScreenPos()
                        -- imgui.Image(UI.logo.server, SERVER_LOGO_SIZE)
                        drawList:AddCircleFilled(p + imgui.ImVec2(SERVER_LOGO_SIZE.x / 2, SERVER_LOGO_SIZE.y / 2), SERVER_LOGO_SIZE.x / 2 + UI.outline.width, UI.Colors.Color.TextOutline.u32)
                        drawList:AddImage(UI.logo.server, p, p + SERVER_LOGO_SIZE, nil, nil, UI.Colors.Color.Text.u32)
                    else
                        local path = Arizona:GetServerLogo(HUD.serverId)
                        if (path) then
                            UI.logo.server = imgui.CreateTextureFromFile(path)
                        else
                            -- UI.Componens.Spinner()
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
                
            end
            UI.Components.Editor("logo", {})
        end
        imgui.End()
    end
)

return {
    name = Label.TAB_SERVER_LOGO,
    description = Label.TAB_SERVER_DESCRIPTION,
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

        if (Config.frames.serverLogo.mode[0] == 1) then
            imgui.Checkbox(Label.TAB_SERVER_SETTINGS_ARIZONA_SHOW_SERVER .. "##Config.frames.serverLogo.showServer", Config.frames.serverLogo.showServer)
            imgui.Checkbox(Label.TAB_SERVER_SETTINGS_ARIZONA_SHOW_PLAYERS .. "##Config.frames.serverLogo.showPlayers", Config.frames.serverLogo.showPlayers)
            imgui.SliderFloat(Label.SCALE .. "##Config.frames.serverLogo.scale", Config.frames.serverLogo.scale, 0.1, 5, "x %0.1f")
        elseif (Config.frames.serverLogo.mode[0] == 2) then
            imgui.TextWrapped((Label.TAB_SERVER_SETTINGS_CUSTOM_ERROR):format(Arizona.RESOURCE_PATH))
        end
    end
}