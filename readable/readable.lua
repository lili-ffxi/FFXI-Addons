_addon.name = 'readable'
_addon.author = 'Lili'
_addon.version = '0.1.0'
_addon.command = 'readable'

local config = require('config')

local default = { 
    separator = ',',
    modes = { [121] = true, [150] = true, [151] = true, [152] = true, [190] = true, [210] = true },
    timestamps = true,
    bignumbers = true,
    autoupdate = true,
}

local settings = config.load(default)

local send_command = windower.send_command

windower.register_event('load', function()
    if settings.autoupdate and not _addon.version:endswith('dev') then
        local ltn12 = require('ltn12')
        local https = require('ssl.https')

        function get_txt(url, callback)
            if type(callback) ~= 'function' then return end
            coroutine.schedule(function()
                local body = {}
                response, code = https.request{ url = url, sink = ltn12.sink.table(body), }
                body = table.concat(body)
                callback(response, code, body)
            end, 1)
        end

        local version_url = "https://raw.githubusercontent.com/lili-ffxi/FFXI-Addons/refs/heads/master/readable/readable.lua"
        local version_pattern = "_addon.version *= *['\"](.-)['\"]"
        local file_path = windower.addon_path .. "readable.lua"
        
        get_txt(version_url, function(response, code, body)
            if code == 200 then
                version = body:match(version_pattern)

                print(_addon.version, version)                

                if version and version ~= _addon.version then
                    windower.add_to_chat(207, _addon.name .. ": new version found (%s -> %s), updating.":format(_addon.version, version))

                    -- Open the file in write mode
                    local file = io.open(file_path, "w")

                    -- Check if the file was opened successfully
                    if file then
                        file:write(body)  -- Write the content to the file
                        file:close()         -- Close the file
                        windower.add_to_chat(207, _addon.name .. ": Update successful.")
                        send_command('@wait 0.5;lua reload ' .. _addon.name)
                        return
                        
                    else
                        windower.add_to_chat(207, _addon.name .. "Failed to open file: " .. file_path)
                        
                    end                
                
                end
                
            else
                windower.add_to_chat(207, _addon.name .. ": " .. code .. " Failed to get file.")
                
            end
        end)
        
    end
end)

windower.register_event('incoming text', function(org, mod, mode_org, mode_mod, blocked)
    if not settings.modes[mode_mod] then
        return
    end
    local changed = false
    
    if settings.timestamps then
        local changed = true
        mod = tostring(mod):gsub('(%d%d+) seconds', function(str)
            print(os.date("%X", str), str)
            return tonumber(str) >= 60 and os.date("%X", str) or str..' seconds'
        end)
    end
    
    if settings.bignumbers then
        local changed = true      
        mod = mod:gsub('([1-9]%d%d%d+)', function(str)
            return tostring(str):reverse():gsub("(%d%d%d)","%1"..settings.separator):gsub(",(%-?)$","%1"):reverse()
        end)
    end

    if changed then 
        return mod
    end
end)

windower.register_event('addon command', function(cmd,sep)
    if cmd == 'sep' then
        settings.separator = sep
        config.save(settings)
        return
    end
    
    send_command('lua r '.._addon.name)
end)
