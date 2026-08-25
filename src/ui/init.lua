UI = {
    hud = imgui.new.bool(true),
    edit = false,
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
            "CARET_RIGHT"
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

UI.outline.color = UI.Colors.Color.TextOutline.vec4

function UI.blink:GetPanicColor()
    return imgui.ImVec4(0.92, 0.29, 0.29, self.alpha)
end

require("ui.style")