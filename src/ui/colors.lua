local Colors = {
    Color = {
        Text = { vec4 = imgui.ImVec4(1, 1, 1, 1), u32 = -1 },
        TextOutline = { vec4 = imgui.ImVec4(0.28, 0.28, 0.28, 0.5), u32 = -1 },
        Red = { vec4 = imgui.ImVec4(0.92, 0.29, 0.29, 1), u32 = -1 },
        Black = { vec4 = imgui.ImVec4(0, 0, 0, 1), u32 = -1 },
    }
}
Color = Colors.Color

function Colors:Init()
    for k, v in pairs(self.Color) do
        self.Color[k].u32 = imgui.GetColorU32Vec4(v.vec4)
        print("Colors:init", k)
    end
end

function Colors.explodeArgb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function Colors.joinArgb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function Colors.argbToU32(argb)
    local a, r, g, b = Colors.explodeArgb(argb);
    return Colors.joinArgb(a, b, g, r);
end

---@overload fun(col: number, alpha: number): number
---@overload fun(col: ImVec4, alpha: number): ImVec4
function Colors.withAlpha(col, alpha)
    local isU32 = type(col) == "number"
    if (isU32) then
        local _, b, g, r = Colors.explodeArgb(col);
        return imgui.GetColorU32Vec4(imgui.ImVec4(r / 255, g / 255, b / 255, alpha));
    end
    return imgui.ImVec4(col.x, col.y, col.z, alpha)
end

return Colors