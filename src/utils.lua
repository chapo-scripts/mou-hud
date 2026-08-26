Utils = {};

function MyID()
    return isSampAvailable() and select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) or 0
end

function Utils.msg(...)
    if (not isSampAvailable()) then
        return
    end
    sampAddChatMessage(("MouHUD // %s"):format(table.concat({ ... }, " ")), -1)
end

function Utils.debugMsg(...)
    return DEBUG and Utils.msg("DEBUG //", ...) or nil
end

function Utils.commaValue(n, char) -- https://www.blast.hk/threads/39380/
	local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)','%1' .. char):reverse()) .. right
end

function Utils.bringVec4To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end

function Utils.isCurrentWeaponMelee()
    local pointer = getCharPointer(playerPed)
    local weapon = getCurrentCharWeapon(playerPed)
    local slot = getWeapontypeSlot(weapon)
    
    local weapon = ffi.cast("void*", pointer + 0x5A0 + slot * 0x1C)
    local res = ffi.cast("bool(__thiscall*)(void *this)", 0x73B1C0)(weapon)
    return res
end

function Utils.getCurrentWeaponState()
    local pedPtr = getCharPointer(PLAYER_PED)
    local weapon = getCurrentCharWeapon(PLAYER_PED)
    local slot = getWeapontypeSlot(weapon)
    return ffi.cast("int*", pedPtr + 0x5A0 + slot * 0x4)[0]
end

function Utils.getAmmoInClip()
    local pointer = getCharPointer(playerPed)
    local weapon = getCurrentCharWeapon(playerPed)
    local slot = getWeapontypeSlot(weapon)
    local cweapon = pointer + 0x5A0
    local current_cweapon = cweapon + slot * 0x1C
    return memory.getuint32(current_cweapon + 0x8)
end

function Utils.bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    end
    return (timer > duration) and to or from, false
end

function Utils.asyncHttpRequest(method, url, args, resolve, reject)
    local request_thread = Effil.thread(function(method, url, args)
        local requests = require 'requests'
        local result, response = pcall(requests.request, method, url, args)
        if result then
            response.json, response.xml = nil, nil
            return true, response
        else
            return false, response
        end
    end)(method, url, args)
    if not resolve then resolve = function() end end
    if not reject then reject = function() end end
    lua_thread.create(function()
        local runner = request_thread
        while true do
            local status, err = runner:status()
            if not err then
                if status == 'completed' then
                    local result, response = runner:get()
                    if result then
                        resolve(response)
                    else
                        reject(response)
                    end
                    return
                elseif status == 'canceled' then
                    return reject(status)
                end
            else
                return reject(err)
            end
            wait(0)
        end
    end)
end

function table.toString(tbl, indent)
    local function formatTableKey(k)
        local defaultType = type(k)
        if (defaultType ~= 'string') then
            k = tostring(k)
        end
        local useSquareBrackets = k:find('^(%d+)') or k:find('(%p)') or k:find('\\') or k:find('%-');
        return useSquareBrackets == nil and k or ('[%s]'):format(defaultType == 'string' and "'" .. k .. "'" or k)
    end
    local str = { '{' }
    local indent = indent or 0
    for k, v in pairs(tbl) do
        table.insert(str,
            ('%s%s = %s,'):format(string.rep("    ", indent + 1), formatTableKey(k),
                type(v) == "table" and table.toString(v, indent + 1) or
                (type(v) == 'string' and "'" .. v .. "'" or tostring(v))))
    end
    table.insert(str, string.rep('    ', indent) .. '}')
    return table.concat(str, '\n')
end
