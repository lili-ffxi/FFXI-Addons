_addon.name = 'ondemand'
_addon.author = 'Lili'
_addon.version = '1.3.2'
_addon.command = 'ondemand'

require('logger')
local files = require('files')
local config = require('config')

local defaults = {
    ignore = S{ 'homepoint', 'logger', 'gearswap' },
    neverunload = S{ 'logger', 'gearswap', 'maga' },
    periodic = {},
    refreshlogger = true,
    expire = 60*15, -- 15min
    customdelays = { htmb = 30 },
    customcommands = { },
    silent = false,
}

local settings = config.load(defaults)

local addon_commands = {}
local commands_addon = {}
local expiration = {}

windower.register_event('load', function()

    local addons_path = windower.windower_path .. 'addons\\'
    local addons = T(windower.get_dir(addons_path))
    
    for name in addons:it() do
        local name = name:lower()
        local addonfile = '%s%s\\%s.lua':format(addons_path, name, name)
        
        if windower.file_exists(addonfile) and not settings.ignore[name] then
            local fh = io.open(addonfile, 'r')
            local content = fh:read('*all*')
            fh:close()

            -- Remove byte order mark for UTF-8, if present
            if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
                content = content:sub(4)
            end

            if content:match("'addon command'") then
                local str = content:match("_addon%.command%s*=%s*(%b'')") or ''
                local tab = content:match('_addon%.commands%s*=%s*(%b{})')
                tab = tab and tab:gsub("%s*",""):gsub("[{}]","") or ''
                
                local cmd = S{}
                
                if #str > 0 then 
                    cmd = cmd:union(str:gsub("'",""):lower()) 
                end
                
                if #tab > 0 then
                    tab = S(tab:split(","):filter(-''))
                    cmd = cmd:union(tab:map(string.lower .. string.gsub-{"'",""}))
                end

                if cmd:length() > 0 then
                    addon_commands[name] = cmd
                    for entry in cmd:it() do
                        if commands_addon[entry] then
                            warning('Conflict! %s has the same command as %s (%s)':format(name, commands_addon[entry], entry))
                        else
                            commands_addon[entry] = name
                        end
                    end
                end
            end
        end
    end

end)

windower.register_event('unhandled command', function(...)
    local param = T{...}:map(string.strip_format .. windower.convert_auto_trans):map(function(str)
        return str:find(' ', string.encoding.shift_jis, true) and str:enclose('"') or str
    end):sconcat()
    
    local cmd = param:match("^(%w*)")

    if commands_addon[cmd] then
        local addon = commands_addon[cmd]

        log('Addon found: %s (//%s) - loading...':format(addon, cmd))
        local delay = math.random(1,3)
        windower.send_command('lua load %s;wait %s;%s':format(addon, delay, param))
        if not settings.neverunload:contains(addon) then
            expiration[addon] = os.clock() + (settings.customdelays[addon] or settings.expire) + 1
        end
    end

end)

windower.register_event('addon command', function(...)
    local cmd = select(1, ...)
    local param = table.sconcat({select(2, ...)})

    if cmd == 'keep' and type(param) == 'string' and expiration[param] then
        expiration[param] = nil
        log('%s will not be unloaded automatically.':format(param))
        return
    end
    
    table.vprint(expiration)
end)

windower.register_event('outgoing chunk', function(id)
    if id ~= 0x015 then
        return
    end
    
    for addon, ts in pairs(expiration) do
        if ts < os.clock() then
            if not settings.silent then 
                log('Unloading %s after %s seconds.':format(addon, settings.customdelays[addon] or settings.expire))
            end
            windower.send_command('lua u ' .. addon)
            expiration[addon] = nil
        end
    end

end)
