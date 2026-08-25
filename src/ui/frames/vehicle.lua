local function subChar(str, i)
    local c = str:sub(i, i)
    return #c > 0 and c or "-"
end
imgui.OnFrame(
    function() return isCharInAnyCar(PLAYER_PED) end,
    function(frame)
        frame.HideCursor = true

        imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0)
        if (imgui.Begin("MouHUD: Vehicle", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground)) then
            if (not isCharInAnyCar(PLAYER_PED)) then
                return
            end
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            local DL = imgui.GetWindowDrawList()
            HUD.vehicle.speed = math.floor(getCarSpeed(veh)) * 4
            -- Speed
            local oneNumberSize = imgui.ImVec2(30, 40)

            local childPos = imgui.GetCursorScreenPos()
            local childSize = imgui.ImVec2(oneNumberSize.x * 3 + 10 * 2, oneNumberSize.y + 20 + 15 + 5);
            DL:AddRectFilled(childPos, childPos + childSize, UI.Colors.Color.Text.u32, 10)
            if (imgui.BeginChild("speedometer", childSize, false)) then
                -- Speed
                imgui.PushFont(UI.font[40].Bold)
                local speedStr = tostring(HUD.vehicle.speed)
                local speedStrFormatted = string.rep("-", 3 - #speedStr) .. speedStr
                local speedChars = { subChar(speedStrFormatted, 1), subChar(speedStrFormatted, 2), subChar(speedStrFormatted, 3) }

                imgui.SetCursorPos(imgui.ImVec2(10, 10))
                for charIndex, char in ipairs(speedChars) do
                    if (imgui.BeginChild("##speedometer-speed-char-" .. charIndex, oneNumberSize)) then
                        imgui.SetCursorPosX(oneNumberSize.x / 2 - imgui.CalcTextSize(tostring(char)).x / 2)
                        local isLeftZero = tostring(char) == "-"
                        imgui.TextColored(isLeftZero and UI.Colors.Color.TextOutline.vec4 or UI.Colors.Color.Black.vec4, char == "-" and "0" or char)
                    end
                    imgui.EndChild()
                    if (charIndex < 3) then
                        imgui.SameLine(nil, 0)
                    end
                end
                -- for i = 1, 3 do
                    -- local letter = speedStrFormatted:sub(i, i)
                    -- if (imgui.BeginChild("##speedometer-speed-char-" .. i, oneNumberSize)) then
                        -- imgui.SetCursorPosX(oneNumberSize.x / 2 - imgui.CalcTextSize(letter).x / 2)
                        -- local nextChar, prevChar = speedStrFormatted:sub(i + 1, i + 1), speedStrFormatted:sub(i - 1, i - 1)
                        -- local isLeftZero = letter == "0" and (tonumber(nextChar) or 0) > 0 and (tonumber(prevChar) or 0) > 0
-- 
                        -- printStringNow(("%s %s %s"):format(speedStr, speedStrFormatted, speedStr:reverse(), isLeftZero), 100)
                        -- imgui.TextColored(isLeftZero and UI.Colors.Color.TextOutline.vec4 or UI.Colors.Color.Black.vec4, letter)
                    -- end
                    -- imgui.EndChild()
                    -- if (i < 3) then
                        -- imgui.SameLine(nil, 0)
                    -- end
                -- end
                imgui.PopFont()

                -- Icons
                local icons = {
                    { "CARET_LEFT", true },
                    { "LOCK", true },
                    { "COGS", true },
                    { "CARET_RIGHT", false },
                }
                
                imgui.PushFont(UI.font[20].Bold)
                local icons = {
                    "CARET_LEFT",
                    "LOCK",
                    "COGS",
                    "CARET_RIGHT",
                }
                local iconsSizes, totalWidth = {}, 0
                for k, v in ipairs(icons) do
                    iconsSizes[k] = imgui.CalcTextSize(v)
                    totalWidth = totalWidth + iconsSizes[k].x + 5
                    -- print(v, iconsSizes[k].x)
                end



                imgui.SetCursorPosX(totalWidth / 2 - totalWidth / 2)

                imgui.SetCursorPosX(20)
                imgui.TextColored(UI.Colors.Color.TextOutline.vec4, faicons("CARET_LEFT"))
                
                imgui.SameLine(imgui.GetWindowWidth() - 20 - imgui.CalcTextSize(faicons("CARET_RIGHT")).x)
                imgui.TextColored(UI.Colors.Color.TextOutline.vec4, faicons("CARET_RIGHT"))
                
                local lockStatus = faicons(HUD.vehicle.isLocked and "LOCK" or "UNLOCK")
                imgui.SameLine(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(lockStatus).x / 2)
                imgui.TextColored(UI.Colors.Color.TextOutline.vec4, lockStatus)
                
                imgui.PopFont()
            end
            imgui.EndChild()
            
            imgui.SameLine()

            -- Other info
            imgui.PushFont(UI.font[15].Bold)
            -- local labels = ("%s %s\n%s %s\n%s %s"):format(
            --     faicons("HEART"), (getCarHealth(veh) or 0), faicons("GAS_PUMP"), HUD.vehicle.fuel.count, faicons("ROAD"), HUD.vehicle.mileage
            -- )
            -- local labelsSize = imgui.CalcTextSize(labels)

            -- imgui.SetCursorPosY(childSize.y / 2 - labelsSize.y / 2)
            -- UI.Components.OutlineText(labels, UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4)
            local labels = {
                { text = faicons("HEART") .. " 999", criticalValue = false },
                { text = faicons("GAS_PUMP") .. " " .. HUD.vehicle.fuel.count, criticalValue = false },
                { text = faicons("ROAD") .. " " .. HUD.vehicle.mileage, criticalValue = false },
            }
            local totalSize = imgui.ImVec2(0, imgui.GetStyle().ItemSpacing.y * (#labels - 1) + imgui.GetStyle().WindowPadding.y * 2)
            for k, v in ipairs(labels) do
                totalSize = totalSize + imgui.CalcTextSize(v.text)
            end
            imgui.SetCursorPosY(childSize.y / 2 - totalSize.y / 2)
            if (imgui.BeginChild("it", totalSize, true)) then
                for k, v in ipairs(labels) do
                    imgui.Text(v.text)
                end
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        imgui.End()
        imgui.PopStyleVar()
    end
)

return {
    name = "Vehicle",
    description = ""
}