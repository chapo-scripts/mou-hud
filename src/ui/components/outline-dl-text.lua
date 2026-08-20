return function(dl, font, fontSize, p, text, color, outlineSize, outlineColor)
    local oc = imgui.GetColorU32Vec4(imgui.ImVec4(outlineColor.x, outlineColor.y, outlineColor.z, outlineColor.w * (color and color.w or 1)))
    dl:AddText(p + imgui.ImVec2(outlineSize, outlineSize), oc or 0xFFffffff, text)
    dl:AddText(p + imgui.ImVec2(outlineSize, 0), oc or 0xFF000000, text)
    dl:AddText(p + imgui.ImVec2(0, outlineSize), oc or 0xFF000000, text)
    dl:AddText(p - imgui.ImVec2(outlineSize, 0), oc or 0xFF000000, text)
    dl:AddText(p - imgui.ImVec2(0, outlineSize), oc or 0xFF000000, text)
    dl:AddText(p, imgui.GetColorU32Vec4(color) or 0xFFffffff, text)
end