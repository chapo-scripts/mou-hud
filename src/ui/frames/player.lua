imgui.OnFrame(
    function() return UI.hud[0] and not isGamePaused() and isGameWindowForeground() end,
    function(thisFrame)
        thisFrame.HideCursor = true
        local res = imgui.GetIO().DisplaySize
        
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        if (imgui.Begin('MouHUD', UI.hud, imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize)) then
            local DL = imgui.GetWindowDrawList()

            local outline = {
                size = 2,
                color = imgui.ImVec4(0.28, 0.28, 0.28, 0.5),
                colorVec4 = imgui.ImVec4(0.28, 0.28, 0.28, 0.5)
            }

            imgui.PushFont(UI.font[15].Bold)
            UI.Components.Bar(DL, "HP", "heart", getCharHealth(PLAYER_PED), 100, outline, 20)
            if (getCharArmour(PLAYER_PED) > 0) then
                UI.Components.Bar(DL, "ARMOUR", "shield", getCharArmour(PLAYER_PED), 100, outline)
            end
            if (HUD.satiety ~= nil) then
                UI.Components.Bar(DL, "SATIETY", "burger", HUD.satiety, 100, outline, 20)
            end
            
            -- Wanted
            if (HUD.wanted > 0) then
                UI.Components.OutlineText(faicons("STAR"), nil, outline.size, outline.color)
                imgui.SameLine(30)
                UI.Components.OutlineText(tostring(HUD.wanted), nil, outline.size, outline.color)
                imgui.SameLine()
            end

            -- Money
            imgui.PushFont(UI.font[24].Bold)
            local moneyLabel = "$ " .. Utils.commaValue(getPlayerMoney(nil), ".") ---@diagnostic disable-line
            imgui.SetCursorPosX(imgui.GetWindowWidth() - imgui.CalcTextSize(moneyLabel).x - 10)
            UI.Components.OutlineText(moneyLabel, nil, outline.size, outline.color)
            imgui.PopFont()

            -- Weapon
            local weapon = getCurrentCharWeapon(PLAYER_PED)
            if (weapon ~= 0) then
                local weaponName = Arizona:GetWeaponName(weapon)
                UI.Components.OutlineText(weaponName, nil, outline.size, outline.color)

                if (not Utils.isCurrentWeaponMelee()) then
                    local ammoInClip = Utils.getAmmoInClip()
                    local totalAmmo = getAmmoInCharWeapon(PLAYER_PED, weapon) - ammoInClip
                    
                    imgui.SameLine()
                    local ammoInClipLabelSize, totalAmmoLabelSize, padding = imgui.CalcTextSize(tostring(ammoInClip)), imgui.CalcTextSize(tostring(totalAmmo)), imgui.ImVec2(4, 2)
                    local pos = imgui.GetCursorScreenPos() - imgui.ImVec2(0, padding.y)
                    
                    -- Clip
                    DL:AddRectFilled(pos, pos + ammoInClipLabelSize + padding + padding, UI.Colors.Color.Text.u32, 5, 1 + 4)
                    DL:AddRect(pos, pos + ammoInClipLabelSize + padding + padding, UI.Colors.Color.TextOutline.u32, 5, 1 + 4)
                    DL:AddTextFontPtr(UI.font[15].Bold, 15, pos + padding, UI.Colors.withAlpha(UI.Colors.Color.TextOutline.u32, 1), tostring(ammoInClip))
                    
                    
                    -- Total
                    local totalAmmoPosStart = pos + imgui.ImVec2(padding.x + ammoInClipLabelSize.x + padding.x, 0)
                    DL:AddRectFilled(totalAmmoPosStart, totalAmmoPosStart + padding + padding + totalAmmoLabelSize, UI.Colors.Color.TextOutline.u32, 5, 2 + 8)
                    DL:AddTextFontPtr(UI.font[15].Bold, 15, totalAmmoPosStart + padding, UI.Colors.Color.Text.u32, tostring(totalAmmo))
                    imgui.Dummy(imgui.ImVec2(padding.x + ammoInClipLabelSize.x + padding.x + padding.x + totalAmmoLabelSize.x + padding.x, ammoInClipLabelSize.y + padding.y * 2))
                    imgui.SameLine()
                end
            end
            
            -- GreenZone
            local effects = {HUD.isGreenZone}
            if (HUD.isGreenZone) then
                imgui.PushFont(UI.font[24].Bold)
                local greenZoneBanIconSize = imgui.CalcTextSize(faicons("BAN"))
                imgui.SetCursorPosX(imgui.GetWindowWidth() - greenZoneBanIconSize.x - 5)
                local greenZoneBanIconPos = imgui.GetCursorScreenPos()
                UI.Components.OutlineText(faicons("BAN"), UI.Colors.withAlpha(UI.Colors.Color.Red.vec4, UI.blink.alpha), outline.size, outline.color)
                imgui.PopFont()

                imgui.PushFont(UI.font[15].Bold)
                local fistSize = imgui.CalcTextSize(faicons("HAND_FIST"))
                UI.Components.OutlineTextDL(imgui.GetBackgroundDrawList(), UI.font[15].Bold, 15, greenZoneBanIconPos + imgui.ImVec2(greenZoneBanIconSize.x / 2 - fistSize.x / 2, greenZoneBanIconSize.y / 2 - fistSize.y / 2), faicons("HAND_FIST"), UI.Colors.Color.Text.vec4, outline.size, outline.color)
                imgui.PopFont()
            end
            -- faicons("MASK_FACE")
            
            imgui.PopFont()
            imgui.End()
        end
    end
)

