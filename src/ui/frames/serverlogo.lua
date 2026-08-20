ARIZONA_LOGO_SIZE = imgui.ImVec2(64, 64)
SERVER_LOGO_SIZE = imgui.ImVec2(32, 32)

imgui.OnFrame(
    function() return true end,
    function(frame)
        frame.HideCursor = true
        if (imgui.Begin("MouHUD: Logo", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground)) then
            if (UI.logo.arizona) then
                imgui.Image(UI.logo.arizona, ARIZONA_LOGO_SIZE)
            end
            if (UI.logo.server) then
                imgui.SetCursorPos(imgui.ImVec2(ARIZONA_LOGO_SIZE.x - SERVER_LOGO_SIZE.x / 2, ARIZONA_LOGO_SIZE.y - SERVER_LOGO_SIZE.y / 2))
                imgui.Image(UI.logo.server, SERVER_LOGO_SIZE)
            else
                local path = Arizona:GetServerLogo(HUD.serverId)
                if (path) then
                    UI.logo.server = imgui.CreateTextureFromFile(path)
                    -- Utils.debugMsg("creating logo texture")
                    print(path, UI.logo.server)
                end
            end
        end
        imgui.End()
    end
)