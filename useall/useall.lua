_addon.name = 'useall'
_addon.author = 'Lili'
_addon.version = '0.3.5'
_addon.command = 'useall'

local items = require('resources').items
local packets = require('packets')
require('logger')

local mod = 'shift'

local keys = { [42] = 'shift', [219] = 'win', }

local diks = { ['shift'] = 42, ['win'] = 219, }

local active = false
local item = false

function use_item()
    if windower.ffxi.get_player().status ~= 0 or not item then
        return
    end

    local inventory = windower.ffxi.get_items(0)
    local found = false
    for _, t in pairs(inventory) do
        if type(t) == 'table' and t.id == item.id and t.status ~= 25 then
            windower.chat.input('/item "%s" <me>':format(item.name))
            found = true
            break
        end
    end
    
    if not found then
        log('Done using %s.':format(item.name))
        item = false
    end
end

windower.register_event('keyboard', function(dik, pressed, flags, blocked)
    if blocked or diks[mod] ~= dik then 
        return 
    end
    
    active = pressed
end)

windower.register_event('status change', function(status)
    if item and status ~= 0 then
        item = false
    end
end)

windower.register_event('outgoing chunk', function(id, org, mod, blocked)
    if not active or blocked or id ~= 0x037 then
        return
    end
    
    p = packets.parse('outgoing', org)
    
    if p.Bag ~= 0 then  -- Ignore all bags except Inventory.
        return
    end
    
    local item_id = windower.ffxi.get_items(0, p.Slot).id
    item = items[item_id]

    if not item.category == 'Usable' then
        item = false
        return
    end
    
    log('Using all %s. //%s stop or /heal to stop.':format(item.name, _addon.name))
end)

windower.register_event('action', function(act)
    if not item or act.category ~= 5 or act.actor_id ~= windower.ffxi.get_player().id then
        return 
    end
    
    if act.param ~= item.id then
        log('Different item used. Stopping.')
        item = false
        return
    end
    
    use_item:schedule(1)
end)

windower.register_event('addon command', function(...)
    local args = T({...}):map(string.lower)
    local cmd = table.remove(args,1)
    
    if item and cmd == 'stop' then
        item = false
        log('Stopped')
        return
    end
    
    if diks[cmd] then
        mod = cmd
    end
    
    log('Modifier:',mod)
end)
