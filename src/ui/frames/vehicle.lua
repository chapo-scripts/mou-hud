imgui.OnFrame(
    function() return isCharInAnyCar(PLAYER_PED) end,
    function(frame)
        frame.HideCursor = true
        if (imgui.Begin("MouHUD: Vehicle", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground)) then
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            local DL = imgui.GetWindowDrawList()
            -- imgui.Text("Speed: " .. HUD.vehicle.speed)
            -- imgui.Text("Mileage: " .. HUD.vehicle.mileage)
            -- imgui.Text("Fuel: " .. HUD.vehicle.fuel.count)

            imgui.PushFont(UI.font[40].Bold)
            local speedStr = tostring(HUD.vehicle.speed)
            if (#speedStr < 3) then
                speedStr = "0" .. speedStr
            end
            local oneNumberSize = imgui.ImVec2(30, 50)
            local allNumbersSize = imgui.ImVec2(oneNumberSize.x * 3, oneNumberSize.y)
            for i = 1, 3 do
                local char = speedStr:sub(i, i)
                imgui.PushStyleColor(imgui.Col.Text, char == "0" and UI.Colors.Color.TextOutline.vec4 or UI.Colors.Color.Text.vec4)
                -- imgui.Button(char, oneNumberSize)
                if (imgui.BeginChild("child-speed-letter-" .. i, oneNumberSize, true)) then
                    UI.Components.OutlineText(char, char == "0" and UI.Colors.Color.TextOutline.vec4 or UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4)
                end
                imgui.EndChild()
                imgui.PopStyleColor()
                imgui.SameLine(nil, 0)
            end
            imgui.PopFont()
            
            imgui.PushFont(UI.font[15].Bold)
            local carHealthInt = veh and getCarHealth(veh) or -1
            local fuelLabel = faicons("GAS_PUMP") .. " " .. HUD.vehicle.fuel.count
            local healthLabel = faicons("HEART") .. " " .. carHealthInt
            
            local fuelLabelSize = imgui.CalcTextSize(fuelLabel)
            local healthLabelSize = imgui.CalcTextSize(healthLabel)
            local containerSize = imgui.ImVec2(fuelLabelSize.x > healthLabelSize.x and fuelLabelSize.x or healthLabelSize.x + 10, fuelLabelSize.y + healthLabelSize.y + imgui.GetStyle().ItemSpacing.y + 10)

            imgui.SetCursorPosY(imgui.GetWindowHeight() / 2 - containerSize.y / 2)
            if (imgui.BeginChild("speedometer-params", containerSize, true)) then
                local p = imgui.GetCursorScreenPos()
                UI.Components.OutlineText(fuelLabel, UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4, DL)
                if (true) then
                    UI.Components.OutlineTextDL(DL, UI.font[15].Bold, 15, p, fuelLabel, UI.Colors.withAlpha(UI.Colors.Color.Red.vec4, UI.blink.alpha), 2, UI.Colors.Color.TextOutline.vec4)
                    -- DL:AddTextFontPtr(UI.font[15].Bold, 15, p, UI.Colors.withAlpha(UI.Colors.Color.Red.u32, UI.blink.alpha), fuelLabel)
                end

                local p = imgui.GetCursorScreenPos()
                UI.Components.OutlineText(healthLabel, UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4)
                if (HUD.vehicle.fuel.count < 20) then
                    -- UI.Components.OutlineTextDL(DL, UI.font[15].Bold, 15, p, fuelLabel, 2, UI.Colors.withAlpha(UI.Colors.Color.Red.vec4, UI.blink.alpha))
                end
            end
            imgui.EndChild()
            imgui.PopFont()
                

            local secondaryInfoLabel = ("%s %s  %s %s"):format(faicons("GAS_PUMP"), HUD.vehicle.fuel.count, faicons("HEART"), veh and getCarHealth(veh) or -1)
            
            imgui.PushFont(UI.font[15].Bold)
            imgui.SetCursorPosY(oneNumberSize.y + 10)
            UI.Components.OutlineText(secondaryInfoLabel, UI.Colors.Color.Text.vec4, 2, UI.Colors.Color.TextOutline.vec4)
            imgui.PopFont()
        end
        imgui.End()
    end
)