imgui.OnInitialize(function()
    -- imgui.GetIO().IniFilename = nil
    UI.Colors:Init()
    UI.font.Init(UI.font.requiredSizes, UI.font.requiredIcons)

    local style = imgui.GetStyle()
    local colors = style.Colors
    style.FrameBorderSize = 2
    style.FrameRounding = 10
    style.FramePadding = imgui.ImVec2(5, 5)
    style.WindowPadding = imgui.ImVec2(5, 5)
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(1, 1, 1, 1)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.28, 0.28, 0.28, 0.5)
    colors[imgui.Col.Border] = imgui.ImVec4(1, 0, 0, 0.25)
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.15, 0.15, 0.15, 1)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.28, 0.28, 0.28, 0.5)
    -- colrs[imgui.]

    if (doesFileExist(getGameDirectory() .. "\\moonloader\\MouHUD\\arizona.png")) then
        print("Loading logo from file...")
        UI.logo.arizona = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\MouHUD\\arizona.png")
    else
        UI.logo.arizona = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', UI.Resource.ArizonaLogo), #UI.Resource.ArizonaLogo)
    end
end)