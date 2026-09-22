---@class ArizonaWeapon
---@field available boolean
---@field name string
---@field name_ru string
---@field chat_icon string
---@field server_id number

ffi.cdef('const char* GetCommandLineA(void);')

UpdaterState = {
    None = 0,
    Loading = 1,
    Ready = 2
}


Arizona = {
    WEAPONS_DATA_URL = "https://api.arztools.tech/tools/arizona/weapons.json",
    WEAPONS_DATA_PATH = getGameDirectory() .. "\\moonloader\\resource\\mouhud-weapons-data.json",
    RESOURCE_PATH = getGameDirectory() .. "\\moonloader\\resource\\MouHUD",
    ---@type ArizonaWeapon[]
    weapons = {},
    cachedWeaponsName = {},
    updaterState = UpdaterState.None
}

function Arizona:IsArizona()
    return ffi.string(ffi.C.GetCommandLineA()):find('%-arizona')
end

function Arizona:Init()
    Arizona:LoadWeaponsDataFromFile()
    Arizona:DownloadWeaponsData()
    if (not self:IsArizona()) then
        return
    end
    if (not doesDirectoryExist(self.RESOURCE_PATH)) then
        createDirectory(self.RESOURCE_PATH .. "\\arizona-server-logo")
    end

    addEventHandler("onSendPacket", function(id, bs)
        local status, str = CEF:readOutcomingPacket(id, bs, true)
        if (status and str:find("^mouhud:(.+);(.+)")) then
            local event, payload = str:match("^mouhud:(.+);(.+)")
            if (event == "ready") then
                Utils.debugMsg("Ready. Was ALREADY started: ", payload)
                Arizona.updaterState = UpdaterState.Ready
            elseif (event == "setServer") then
                local newServerId = tonumber(payload) or 0
                if (HUD.serverId ~= newServerId) then
                    UI.logo.server = nil
                    HUD.serverId = newServerId
                end
            elseif (event == "setSpeed") then
                HUD.vehicle.speed = tonumber(payload) or -1
            elseif (event == "setMileage") then
                HUD.vehicle.mileage = tonumber(payload) or -1
            elseif (event == "setFuel") then
                HUD.vehicle.fuel.count = tonumber(payload:match("(%d+)")) or -1
            elseif (event == "setIsGreenZone") then
                HUD.isGreenZone = tonumber(payload) == 1
            end
            -- Utils.debugMsg("CEF->Lua:", str)
        end
    end)
    addEventHandler("onReceivePacket", function(id, bs)
        local status, event, data, json = CEF:readIncomingPacket(id, bs, true)
        if (status) then
            if (event:find("arizonahud")) then
                -- CEF:evalnon(JS.CheckGreenZone)
                CEF:evalnon(JS.DisableArizonaHUD)
                if (Arizona.updaterState == UpdaterState.None) then
                    Utils.debugMsg("Starting...")
                    CEF:evalnon(JS.SetupInfotHooks)
                    Arizona.updaterState = UpdaterState.Loading
                end
            end
            if (event == "event.arizonahud.playerSatiety") then
                HUD.satiety = tonumber(data) or -1
            elseif (event == "event.arizonahud.playerWanted") then
                HUD.wanted = tonumber(data) or 0
            elseif (event == "event.arizonahud.vehicleMileage") then
                HUD.vehicle.mileage = tonumber(data) or -1
            elseif (event == "event.arizonahud.vehicleLiters") then
                HUD.vehicle.fuel.count = tonumber(data) or -1
            elseif (event == "event.arizonahud.vehicleFuelType") then
                HUD.vehicle.fuel.type = data or "petrol"
            elseif (event == "event.arizonahud.serverInfo") then
                ---@cast data {id: number, title: string, project: string, type: string, onLine: number, flag: number, logo: number, multiplier: number}
                HUD.serverId = data.id
            end
        end
    end)
end

---@param serverNumber number
function Arizona:GetServerLogo(serverNumber)
    if (serverNumber <= 0) then
        return
    end
    local path = ("%s\\arizona-server-logo\\%d.png"):format(self.RESOURCE_PATH, serverNumber)
    if (doesFileExist(path)) then
        return path
    end
    -- Utils.debugMsg("Downloading logo for", serverNumber)
    -- downloadUrlToFile(
    --     ("https://reserve-cdn.azresources.cloud/projects/arizona-rp/assets/images/project_icons/%d.png"):format(serverNumber),
    --     path .. "_temp",
    --     function(id, status, p1, p2)
    --     if (status == DLStatus.STATUSEX_ENDDOWNLOAD) then
    --         os.rename(path .. "_temp", path)
    --     end
    -- end
    -- )
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