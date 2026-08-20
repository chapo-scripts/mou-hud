---@class ArizonaWeapon
---@field available boolean
---@field name string
---@field name_ru string
---@field chat_icon string
---@field server_id number

ffi.cdef('const char* GetCommandLineA(void);')

Arizona = {
    WEAPONS_DATA_URL = "https://api.arztools.tech/tools/arizona/weapons.json",
    WEAPONS_DATA_PATH = getGameDirectory() .. "\\moonloader\\resource\\mouhud-weapons-data.json",
    RESOURCE_PATH = getGameDirectory() .. "\\moonloader\\resource\\MouHUD",
    ---@type ArizonaWeapon[]
    weapons = {},
    cachedWeaponsName = {}
}

function Arizona:IsArizona()
    return ffi.string(ffi.C.GetCommandLineA()):find('%-arizona')
end

---@param serverNumber number
function Arizona:GetServerLogo(serverNumber)
    if (not doesDirectoryExist(self.RESOURCE_PATH)) then
        createDirectory(self.RESOURCE_PATH .. "\\server-logo")
    end
    if (serverNumber <= 0) then
        return
    end
    local path = ("%s\\server-logo\\%d.png"):format(self.RESOURCE_PATH, serverNumber)
    if (doesFileExist(path)) then
        return path
    end
    Utils.debugMsg("Downloading logo for", serverNumber)
    downloadUrlToFile(
        ("https://reserve-cdn.azresources.cloud/projects/arizona-rp/assets/images/project_icons/%d.png"):format(serverNumber),
        path,
        nil
    )
end

---@param id number
function Arizona:GetWeaponName(id, russian)
    if (self.cachedWeaponsName[id]) then
        return self.cachedWeaponsName[id]
    end

    for _, weap in ipairs(self.weapons) do
        if (weap.server_id == id) then
            self.cachedWeaponsName[id] = weap.name
            return weap.name
        end
    end
end

function Arizona:LoadWeaponsDataFromFile()
    local file = io.open(self.WEAPONS_DATA_PATH)
    if (not file) then
        return Utils.msg("Ошибка загрузки информации об оружии: не удалось открыть файл")
    end
    local json = file:read("*a")
    file:close()
    local data = decodeJson(json)
    if (not data or #data == 0) then
        return Utils.msg("Ошибка загрузки информации об оружии: INVALID_JSON_FILE")
    end
    self.weapons = data
end

function Arizona:DownloadWeaponsData()
    Utils.asyncHttpRequest(
        "GET",
        self.WEAPONS_DATA_URL,
        nil,
        function(response)
            if (response.status_code ~= 200) then
                return Utils.msg("Ошибка загрузки информации об оружии: " .. response.status_code)
            end
            local data = decodeJson(response.text)
            if (not data or #data == 0) then
                return Utils.msg("Ошибка загрузки информации об оружии: INVALID_JSON")
            end
            self.weapons = data
            local file = io.open(self.WEAPONS_DATA_PATH, "w")
            if (not file) then
                return Utils.msg("Ошибка сохранения списка оружия: невозможно открыть файл для записи")
            end
            file:write(encodeJson(data))
            file:close()
        end,
        function(err)
            Utils.msg("Ошибка загрузки информации об оружии:")
            Utils.msg(tostring(err))
        end
    )
end