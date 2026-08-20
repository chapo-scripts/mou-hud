return function(sizes, icons)
    for name, fontBase85 in pairs(UI.Resource.Fonts) do
        for _, size in ipairs(sizes) do
            UI.font[size] = {};
            -->> Local
            local builder = imgui.ImFontGlyphRangesBuilder()
            local range = imgui.ImVector_ImWchar()
            local config = imgui.ImFontConfig()
            config.MergeMode, config.PixelSnapH = true, true

            -->> Font
            builder:AddRanges(imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
            builder:AddText("��������������-���")
            builder:BuildRanges(range)
            defaultGlyphRanges = imgui.ImVector_ImWchar()
            -- UI.font[size][name] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', size, nil, defaultGlyphRanges[0].Data)
            UI.font[size][name] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fontBase85, size, nil, range[0].Data)

            -->> Icons
            local defaultGlyphRanges = imgui.ImVector_ImWchar()
            local list = icons
            for _, b in ipairs(list) do builder:AddText(faicons(b)) end
            builder:BuildRanges(defaultGlyphRanges)
            UI.font[size][name] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), size, config, defaultGlyphRanges[0].Data)
        end
    end
end