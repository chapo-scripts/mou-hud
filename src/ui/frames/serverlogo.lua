ARIZONA_LOGO_SIZE = imgui.ImVec2(64, 64)
SERVER_LOGO_SIZE = imgui.ImVec2(32, 32)

imgui.OnFrame(
    function() return true end,
    function(frame)
        frame.HideCursor = true
        if (imgui.Begin("MouHUD: Logo", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground)) then
            local drawList, p = imgui.GetBackgroundDrawList(), imgui.GetCursorScreenPos()
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
            end
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

            -- imgui.PushFont(UI.font[12].Bold)
            local infoLabel = ("%s %s %s %s"):format(faicons("USER"), MyID(), faicons("USERS"), sampGetPlayerCount(false))
            imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(infoLabel).x / 2)
            
            -- UI.Components.OutlineTextDL(drawList, UI.font[12].Bold, 12, p + imgui.ImVec2(0, ARIZONA_LOGO_SIZE.y + 7), infoLabel, UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4)
            -- imgui.PopFont()
            UI.Components.Editor("logo", {})
        end
        imgui.End()
    end
)

return {
    name = "Sever logo",
    description = ""
}