---@diagnostic disable:lowercase-global

script_name("MouHud")
script_author("chapo a.k.a moujeek")

DEBUG = MOONLY_BUNDLED == nil; ---@diagnostic disable-line

require("moonloader")
DLStatus = require("moonloader").download_status
Weapons = require("game.weapons")

ffi = require("ffi")
memory = require("memory")
Effil = require("effil")
encoding = require("encoding")
encoding.default = "CP1251"
u8 = encoding.UTF8

faicons = require("fAwesome6")
imgui = require("mimgui")

require("config")
require("utils")
require("cef")
require("arizona")
require("js")
require("ui")

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

function main()
    while not isSampAvailable() do wait(0) end
    Utils.msg(Label.CHAT_LOAD1)
    Utils.msg(Label.CHAT_LOAD2)
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
            if (UI.edit) then
                Utils.msg(Label.COMMAND_EDIT)
            end
        end
        Config()
    end)
    
    Arizona:Init()

    framesCallbacks = {}
    for _, v in ipairs(UI.Frames) do
        if (type(v) == "table") then
            if (type(v.loop) == "function") then
                table.insert(framesCallbacks, v.loop)
            end
            if (type(v.init) == "function") then
                v.init()
            end
        end
    end
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
        for _, fn in ipairs(framesCallbacks) do
            fn()
        end
    end
end