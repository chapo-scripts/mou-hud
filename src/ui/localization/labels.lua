local __lastindex = 0

local function itoa()
    __lastindex = __lastindex + 1
    return __lastindex
end
---@enum Label
LabelKey = {
    PLAYER_SETTINGS_ENABLED = {"ru Enable", "en Enable"},
    PLAYER_SETTINGS_FONTSCALE = {"1", "2"},
    HUD_PLAYER_MONEY = itoa()
}