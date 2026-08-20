imgui.OnInitialize(function()
    -- imgui.GetIO().IniFilename = nil
    UI.Colors:Init()
    UI.font.Init({ 12, 14, 15, 16, 20, 24, 27, 40, 64 }, { "HEART", "VEST", "SHIELD", "STAR", "BURGER", "HAND_FIST", "BAN", "GAS_PUMP" })

    local style = imgui.GetStyle()
    local colors = style.Colors
    style.FrameBorderSize = 2
    style.FrameRounding = 10
    style.FramePadding = imgui.ImVec2(5, 5)
    style.WindowPadding = imgui.ImVec2(5, 5)
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(1, 1, 1, 1)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.28, 0.28, 0.28, 0.5)
    -- colors[imgui.Col.Border] = imgui.ImVec4(0, 0, 0, 0/)
    -- colrs[imgui.]

    if (doesFileExist(getGameDirectory() .. "\\moonloader\\MouHUD\\arizona.png")) then
        print("Loading logo from file...")
    else
        UI.logo.arizona = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', UI.Resource.ArizonaLogo), #UI.Resource.ArizonaLogo)
    end
end)