Config = {
    frames = {
        player = {
            enabled = imgui.new.bool(true),
            showSatiety = imgui.new.bool(true),
            bar = {
                height = imgui.new.int(12),
                width = imgui.new.int(190),
                blinkOnLowValue = imgui.new.bool(true)
            },
        },
        info = {
            enabled = imgui.new.bool(true),
            fontScale = imgui.new.float(1),
            list = {
                "newline", "icon:USER", "spacing", "data:name", "spacing", "text:(", "data:id", "text:)",
                "newline", "icon:PERSON_WALKING", "spacing", "data:ped_animation", "spacing", "text:(", "data:ped_animation_id", "text:)",
                "newline", "icon:CLOCK", "spacing:5", "data:system_time", "spacing:15", "icon:CALENDAR", "spacing", "data:system_date",
                "newline", "icon:SIGNAL", "spacing:5", "data:ping", "spacing:15", "icon:IMAGES", "spacing:5", "data:fps"
            }
        }
    },
    additionalIcons = {}
}

function LoadConfig()
    Utils.debugMsg("Loading config...")
end