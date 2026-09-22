Config = {
    frames = {
        player = {
            enabled = imgui.new.bool(true),
            hideArizonaHUD = imgui.new.bool(true),
            hideGameHUD = imgui.new.bool(true),
            showSatiety = imgui.new.bool(true),
            showStamina = imgui.new.bool(false),
            moneySeparator = imgui.new.bool(true),
            bar = {
                height = imgui.new.int(12),
                width = imgui.new.int(190),
                outlineWidth = imgui.new.int(2),
                blink = {
                    enabled = imgui.new.bool(true),
                    minValues = imgui.new.int[3](20, 20, 20)
                },
                color = imgui.new.float[4](1, 1, 1, 1),
                bgColor = imgui.new.float[4](0, 0, 0, 1)
            },
        },
        serverLogo = {
            enabled = imgui.new.bool(true),
            autoDetect = imgui.new.bool(true),
            scale = imgui.new.float(1),
            mode = imgui.new.int(1), -- 0, 1, 2 (none/arizona/custom)
            customFile = "", -- for mode == 2
            showServer = imgui.new.bool(true),
            showPlayers = imgui.new.bool(true),
        },
        info = {
            enabled = imgui.new.bool(true),
            fontScale = imgui.new.float(1),
            list = {
                "newline", "icon:USER", "spacing:5", "data:name", "spacing:5", "text:(", "data:id", "text:)",
                "newline", "icon:PERSON_WALKING", "spacing:5", "data:ped_animation", "spacing:5", "text:(", "data:ped_animation_id", "text:)",
                "newline", "icon:CLOCK", "spacing:5", "data:system_time", "spacing:15", "icon:CALENDAR", "spacing:5", "data:system_date",
                "newline", "icon:SIGNAL", "spacing:5", "data:ping", "spacing:15", "icon:IMAGES", "spacing:5", "data:fps"
            }
        }
    },
    additionalIcons = {}
}

function LoadConfig()
    Utils.debugMsg("Loading config...")
end