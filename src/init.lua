---@diagnostic disable:lowercase-global

script_name("MouHud")
script_author("chapo a.k.a moujeek")

DLStatus = require('moonloader').download_status
ffi = require("ffi")
memory = require("memory")
faicons = require("fAwesome6")
imgui = require("mimgui")
Weapons = require("game.weapons")
encoding = require("encoding")
encoding.default = "CP1251"
u8 = encoding.UTF8
require("utils")
require("cef")
require("arizona")
require("js")
require("ui")
Effil = require("effil")

DEBUG = MOONLY_BUNDLED == nil; ---@diagnostic disable-line
HUD = {
    serverId = 0,
    satiety = nil,
    wanted = 0,
    isGreenZone = false,
    vehicle = {
        isLocked = false,
        speed = 87,
        mileage = 0,
        fuel = {
            count = 0,
            type = "petrol"
        }
    }
}

UpdaterState = {
    None = 0,
    Loading = 1,
    Ready = 2
}
updaterState = UpdaterState.None

function main()
    while not isSampAvailable() do wait(0) end
    Arizona:Init()
    Utils.msg("t.me/moujeek")
    
    sampRegisterChatCommand("mouhud", function(arg)
        if (DEBUG and #arg > 0) then
            if (arg:find("(%w+) (%d+)")) then
                local field, value = arg:match("(%w+) (%d+)")
                if (field == "satiety") then
                    HUD.satiety = tonumber(value)
                elseif (field == "wanted") then
                    HUD.wanted = tonumber(value)
                elseif (field == "gz") then
                    HUD.isGreenZone = tonumber(value) == 1
                elseif (field == "server") then
                    HUD.serverId = tonumber(value) or 0
                    UI.logo.server = nil
                elseif (field == "arz") then
                    if (value == "1") then
                        CEF:evalnon(JS.EnableArizonaHUD)
                    else
                        CEF:evalnon(JS.DisableArizonaHUD)
                    end
                elseif (field == "ismask") then
                    local color = sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                    local a, r, g, b = UI.Colors.explodeArgb(color)
                    Utils.debugMsg(a, r, g, b)
                else
                    Utils.debugMsg("Unknown MouHUD command")
                end
            end
        else
            UI.edit = not UI.edit
        end
    end)
    addEventHandler("onSendPacket", function(id, bs)
        local status, str = CEF:readOutcomingPacket(id, bs, true)
        if (status and str:find("^mouhud:(.+);(.+)")) then
            local event, payload = str:match("^mouhud:(.+);(.+)")
            if (event == "ready") then
                Utils.debugMsg("Ready. Was ALREADY started: ", payload)
                updaterState = UpdaterState.Ready
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
                if (updaterState == UpdaterState.None) then
                    Utils.debugMsg("Starting...")
                    CEF:evalnon(JS.SetupInfotHooks)
                    updaterState = UpdaterState.Loading
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
    while (true) do
        wait(0)
        UI.blink.alpha = Utils.bringFloatTo(UI.blink.alpha, UI.blink.state == 1 and 1 or 0, UI.blink.start, UI.blink.duration)
        if (UI.blink.alpha == 1) then
            UI.blink.start = os.clock()
            UI.blink.state = 0
        elseif (UI.blink.alpha == 0) then
            UI.blink.start = os.clock()
            UI.blink.state = 1
        end
    end
end