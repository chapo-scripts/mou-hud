Localization = {
    currentLangIndex = 1
}

---@enum Labels
local labels = {
    ENABLE = {"Включить", "Enable"},
    SCALE = {"Размер", "Scale"},
    FONTSCALE = {"Размер шрифта", "Font scale"},

    CHAT_LOAD1 = {"Moujeek's HUD Загружен! (t.me/moujeek)", "Moujeek's HUD Loaded! (t.me/moujeek)"},
    CHAT_LOAD2 = {"Используйте /mouhud для настроек", "Use /mouhud to open settings"},
    COMMAND_EDIT = {"Для закрытия выхода из режима редактирования используйте /mouhud", "Use /mouhud to close settings"},
    COMMAND_ERROR = {"", ""},

    TAB_PLAYER = {"HUD", "HUD"},
    TAB_PLAYER_DESCRIPTION = {"Настройки интерфейса", "Player HUD settings"},
    TAB_PLAYER_SETTINGS_DISABLE_ARIZONA_HUD = {"Выключить CEF HUD Arizona RP", "Disable Arizona RP CEF HUD"},
    TAB_PLAYER_SETTINGS_DISABLE_GAME_HUD = {"Выключить HUD GTA:SA", "Disable GTA:SA HUD"},
    TAB_PLAYER_SETTINGS_DISPLAY_SATIETY = {"Отображать голод (Arizona RP)", "Display satiety (Arizona RP)"},
    TAB_PLAYER_SETTINGS_DISPLAY_STAMINA = {"Отображать выносливость/кислород", "Display stamina/oxygen"},
    TAB_PLAYER_SETTINGS_MONEY_SEPARATOR = {"Разделять деньги", "Money separator"},
    TAB_PLAYER_SETTINGS_TITLE_BARS = {"Полоски", "Bars"},
    TAB_PLAYER_SETTINGS_BLINK_ON_LOW = {"Мигать при низком значении (< 20)", "Blink on low"},
    TAB_PLAYER_SETTINGS_BAR_WIDTH = {"Ширина полосок: %d px", "Bars width: %d px"},
    TAB_PLAYER_SETTINGS_BAR_HEIGHT = {"Высота полосок: %d px", "Bars height: %d px"},
    TAB_PLAYER_SETTINGS_BAR_OUTLINE_WIDTH = {"Толщина обводки: %d px", "Bars outline width: %d px"},

    TAB_VEHICLE = {"HUD (В машине)", "HUD (In vehicle)"},
    TAB_VEHICLE_DESCRIPTION = {"Спидометр", "Speedometer"},

    TAB_SERVER_LOGO = {"Логотип", "Server Logo"},
    TAB_SERVER_DESCRIPTION = {"Отображение логотипа сервера", "Server logo"},
    TAB_SERVER_SETTINGS_TITLE_MODE = {"Тип логотипа", "Logo type"},
    TAB_SERVER_SETTINGS_MODE_NONE = {"Нет", "None"},
    TAB_SERVER_SETTINGS_MODE_ARIZONA = {"Arizona RP", "Arizona RP"},
    TAB_SERVER_SETTINGS_MODE_CUSTOM = {"Свой", "Custom"},
    TAB_SERVER_SETTINGS_MODE_ARIZONA_ERROR = {"Доступно только на Arizona RP!", "Available on Arizona RP only!"},
    TAB_SERVER_SETTINGS_CUSTOM_ERROR = {"Логотипы не найдены.\nПоместите .png логотип в папку \"%s\"", "Images not found.\nPut .png logo to \"%s\""},
    TAB_SERVER_SETTINGS_ARIZONA_SHOW_SERVER = {"Отображать логотип сервера", "Show server logo"},
    TAB_SERVER_SETTINGS_ARIZONA_SHOW_PLAYERS = {"Отображать ваш ID и кол-во игроков", "Show ID and players count"},
    TAB_SERVER_SETTINGS_AUTODETECT = {"Определять автоматически", "Detect automatically"},

    TAB_INFOBAR = {"Инфо-бар", "Infobar"},
    TAB_INFOBAR_DESCRIPTION = {"Виджет для отображения дополнительной информации", "Display additional information"},
    TAB_INFOBAR_SETTINGS_SPACING = {"Отступ", "Spacing"},
    TAB_INFOBAR_SETTINGS_ICON = {"Иконка", "Icon"},
    TAB_INFOBAR_SETTINGS_TEXT = {"Текст", "Text"},
    TAB_INFOBAR_SETTINGS_DATA = {"Информации", "Information"},
    TAB_INFOBAR_SETTINGS_NEWLINE = {"Перенос на новую строку", "New line"},

    -- CHAT_ERROR_CUSTOM_LOGO_NOT_FOUND
}

---@type LabelType
Label = setmetatable({}, {
    __index = function(self, key)
        local dict = labels[key]
        return dict and dict[Localization.currentLangIndex] or ("UNKNOWN:" .. key)
    end
})

if (DEBUG) then
    Utils.debugMsg("Generating localization\\types.lua...")
    local lines = { "---@class LabelType" }
    for k, _ in pairs(labels) do
        table.insert(lines, ("---@field %s string"):format(k))
    end
    table.insert(lines, "\n---@type LabelType")
    table.insert(lines, "Label = {} ---@diagnostic disable-line")
    local file, err = io.open(getWorkingDirectory() .. "\\src\\ui\\localization\\types.lua", "w")
    if (file) then
        file:write(table.concat(lines, "\n"))
        file:close()
    else
        Utils.debugMsg("Error gnerating labels types:")
        print(tostring(err))
    end
end