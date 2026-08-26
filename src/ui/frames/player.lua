imgui.OnFrame(
    function() return Config.frames.player.enabled[0] and not isGamePaused() and isGameWindowForeground() end,
    function(thisFrame)
        thisFrame.HideCursor = not UI.edit
        local res = imgui.GetIO().DisplaySize
        
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        if (imgui.Begin('MouHUD', UI.hud, imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize)) then
            local DL = imgui.GetWindowDrawList()

            local outline = {
                size = 2,
                color = imgui.ImVec4(0.28, 0.28, 0.28, 0.5),
                colorVec4 = imgui.ImVec4(0.28, 0.28, 0.28, 0.5)
            }

            
            local editBlinkValue = 100 * UI.blink.alpha
            imgui.PushFont(UI.font[15].Bold)
            UI.Components.Bar(DL, "HP", "heart", UI.edit and editBlinkValue or getCharHealth(PLAYER_PED), 100, outline, 20)
            if (getCharArmour(PLAYER_PED) > 0 or UI.edit) then
                UI.Components.Bar(DL, "ARMOUR", "shield", UI.edit and editBlinkValue or getCharArmour(PLAYER_PED), 100, outline)
            end
            if (Config.frames.player.showSatiety[0] and (HUD.satiety ~= nil or UI.edit)) then
                UI.Components.Bar(DL, "SATIETY", "burger", UI.edit and editBlinkValue or HUD.satiety, 100, outline, 20)
            end
            if (Config.frames.player.showStamina[0]) then
                UI.Components.Bar(DL, "STAMINA", "PERSON_WALKING", UI.edit and editBlinkValue or HUD.satiety, 100, outline, 20)
            end
            
            -- Wanted
            if (HUD.wanted > 0 or UI.edit) then
                UI.Components.OutlineText(faicons("STAR"), nil, outline.size, outline.color)
                imgui.SameLine(30)
                UI.Components.OutlineText(tostring(HUD.wanted), nil, outline.size, outline.color)
                imgui.SameLine()
            end

            -- Money
            imgui.PushFont(UI.font[24].Bold)
            local moneyLabel = "$ " .. (Config.frames.player.moneySeparator[0] and Utils.commaValue(getPlayerMoney(nil), ".") or getPlayerMoney(nil)) ---@diagnostic disable-line
            imgui.SetCursorPosX(imgui.GetWindowWidth() - imgui.CalcTextSize(moneyLabel).x - 10)
            UI.Components.OutlineText(moneyLabel, nil, outline.size, outline.color)
            imgui.PopFont()

            -- Weapon
            local weapon = getCurrentCharWeapon(PLAYER_PED)
            if (weapon ~= 0 or UI.edit) then
                local weaponName = Arizona:GetWeaponName(weapon)
                UI.Components.OutlineText(weaponName, nil, outline.size, outline.color)

                if (not Utils.isCurrentWeaponMelee() or UI.edit) then
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
            if (HUD.isGreenZone or UI.edit) then
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
            UI.Components.Editor("player", {})
            imgui.End()
        end
    end
)

return {
    name = Label.TAB_PLAYER,
    description = Label.TAB_PLAYER_DESCRIPTION,
    editorFrame = function()
        imgui.Checkbox(Label.ENABLE .. "##Config.frames.player.enabled", Config.frames.player.enabled)
        imgui.Checkbox(Label.TAB_PLAYER_SETTINGS_DISABLE_GAME_HUD .. "##Config.frames.player.hideGameHUD", Config.frames.player.hideGameHUD)
        if (imgui.Checkbox(Label.TAB_PLAYER_SETTINGS_DISABLE_ARIZONA_HUD .. "##Config.frames.player.hideArizonaHUD", Config.frames.player.hideArizonaHUD)) then
            CEF:evalnon(Config.frames.player.hideArizonaHUD[0] and JS.DisableArizonaHUD or JS.EnableArizonaHUD)
        end

        imgui.Checkbox(Label.TAB_PLAYER_SETTINGS_DISPLAY_SATIETY .. "##Config.frames.player.showSatiety", Config.frames.player.showSatiety)
        imgui.Checkbox(Label.TAB_PLAYER_SETTINGS_DISPLAY_STAMINA .. "##Config.frames.player.showStamina", Config.frames.player.showStamina)
        imgui.Checkbox(Label.TAB_PLAYER_SETTINGS_MONEY_SEPARATOR .. "##Config.frames.player.moneySeparator", Config.frames.player.moneySeparator)
        
        imgui.Spacing()
        imgui.PushFont(UI.font[20].Bold)
        imgui.TextDisabled(Label.TAB_PLAYER_SETTINGS_TITLE_BARS)
        imgui.PopFont()
        imgui.Checkbox(Label.TAB_PLAYER_SETTINGS_BLINK_ON_LOW .. "##Config.frames.player.bar.blink.enabled", Config.frames.player.bar.blink.enabled)
        
        -- imgui.SliderInt3("Low values", Config.frames.player.bar.blink.minValues, 1, 100, "%d%%")
    end,
    loop = function()
        displayHud(not Config.frames.player.hideGameHUD[0])
    end
}