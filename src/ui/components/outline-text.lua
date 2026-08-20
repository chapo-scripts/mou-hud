return function(text, color, outlineSize, outlineColor, dl)
    local dl = imgui.GetWindowDrawList() or dl
    local p = imgui.GetCursorScreenPos()
    print(text, color)
    local oc = imgui.GetColorU32Vec4(imgui.ImVec4(outlineColor.x, outlineColor.y, outlineColor.z, outlineColor.w * (color and color.w or 1)))
    dl:AddText(p + imgui.ImVec2(outlineSize, outlineSize), oc or 0xFFffffff, text)
    dl:AddText(p + imgui.ImVec2(outlineSize, 0), oc or 0xFF000000, text)
    dl:AddText(p + imgui.ImVec2(0, outlineSize), oc or 0xFF000000, text)
    dl:AddText(p - imgui.ImVec2(outlineSize, 0), oc or 0xFF000000, text)
    dl:AddText(p - imgui.ImVec2(0, outlineSize), oc or 0xFF000000, text)
    imgui.TextColored(color or imgui.ImVec4(1, 1, 1, 1), text)
end