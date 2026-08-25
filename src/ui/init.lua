UI = {
    hud = imgui.new.bool(true),
    edit = true,
    Components = {
        Bar = require("ui.components.bar"),
        OutlineTextDL = require("ui.components.outline-dl-text"),
        OutlineText = require("ui.components.outline-text"),
        Spinner = require("ui.components.spinner"),
        Editor = require("ui.components.editor")
    },
    Frames = {
        require("ui.frames.player"),
        require("ui.frames.vehicle"),
        require("ui.frames.serverlogo"),
        require("ui.frames.info"),
        require("ui.frames.editor"),
    },
    Resource = {
        Fonts = require("ui.resource.fonts"),
        ArizonaLogo = require("ui.resource.arizona-logo")
    },
    Colors = require("ui.colors"),
    font = {
        Init = require("ui.fonts"),
        requiredSizes = { 15, 16, 20, 24, 40, 64 },
        requiredIcons = {
            "PLUS",
            "HEART",
            "VEST",
            "SHIELD",
            "STAR",
            "BURGER",
            "HAND_FIST",
            "BAN",
            "GAS_PUMP",
            "ROAD",
            "USER",
            "USERS",
            "LOCK",
            "UNLOCK",
            "GEAR",
            "CARET_LEFT",
            "CARET_RIGHT",
            
            "CALENDAR",
            "CLOCK",

            "PERSON",

            "PERSON_WALKING",
            "SIGNAL",
            "IMAGE",
            "IMAGES"
        }
    },
    blink = {
        start = os.clock(),
        state = 0,
        alpha = 1,
        duration = 0.25
    },
    logo = {
        arizona = nil,
        server = nil
    },
    outline = {
        width = 2,
        color = imgui.ImVec4(0, 0, 0, 0)
    }
}

for _, additionalIcon in ipairs(Config.additionalIcons) do
    table.insert(UI.font.requiredIcons, additionalIcon)
end

UI.outline.color = UI.Colors.Color.TextOutline.vec4

function UI.blink:GetPanicColor()
    return imgui.ImVec4(0.92, 0.29, 0.29, self.alpha)
end

require("ui.style")

-- Load default values
for _, frame in ipairs(UI.Frames) do
    if (type(frame) == "table") then
        if (frame.defaultConfig) then

        end
    end
end