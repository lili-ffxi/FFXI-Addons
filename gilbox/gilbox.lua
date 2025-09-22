_addon.name = 'gilbox'
_addon.author = 'Lili'
_addon.version = '1.0.3'
_addon.command = 'gilbox'

require('logger')

local treshold = 1000000

function pretty(gil)
    return tostring(math.floor(gil)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end

function print_gil(name,gil)
    log(name..':',pretty(gil):color(tonumber(gil) >= treshold and 204 or ''))
end

windower.register_event('ipc message', function(msg)
    if msg:sub(1,6) == 'gilbox' then
        local arg = msg:split(' ')
        if arg[2] == 'pls' then
            local name = windower.ffxi.get_player().name
            local target = arg[3]
            windower.send_ipc_message(("gilbox gil %s %s %s"):format(target,name,windower.ffxi.get_items('gil')))
        elseif arg[2] == 'gil' then
            local target = arg[3]
            if target == windower.ffxi.get_player().name then
                local name = arg[4]
                local gil = arg[5]
                print_gil(name,gil)
            end
        end
    end 
end)

windower.register_event('addon command',function(arg)
    if tonumber(arg) then
        treshold = tonumber(arg)
        log('Values above %s will be highlighted.':format(treshold))
        return
    end
    
    local player = windower.ffxi.get_player()
    if player.name then
        windower.send_ipc_message('gilbox pls '..player.name)
        local gil = windower.ffxi.get_items('gil')
        print_gil(player.name,gil)
    end
end)
