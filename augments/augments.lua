_addon.name = 'augments'
_addon.author = 'Lili'
_addon.version = '0.0.1'
_addon.commands = { 'augs', 'augments' }

require('logger')
res = require('resources')
local extdata = require('extdata')

send_command = windower.send_command

function work(search)
    
    log('Results: (%s)':format(search))
    local items = {}
   
    -- Gather Unity items
    for id,bag in pairs(res.bags) do
    
        items = windower.ffxi.get_items(id)
        
        for slot,item in pairs(items) do
            if type(item) == 'table' and item.id > 0 and res.items[item.id] and res.item_descriptions[item.id] then
                name = res.items[item.id].name
                desc = res.item_descriptions[item.id].en
                
                if name:lower():find(search) or res.items[item.id].name_log:lower():find(search) then
                    
                    local augs = ''
                    local augments = extdata.decode(item).augments
                    if type(augments) == 'table' then
                        augs = table.tostring(augments)
                    else
                        augs = 'none'
                    end
                    
                    log('%s: %s (%s)':format(bag.name,name:color(258),augs))
                    
                end
            end
        end
    end
end

windower.register_event('addon command', function(...)
    local arg = T({...}):concat(' '):lower()
    if arg == 'r' then
        log('reloading.')
        send_command('wait 0.1;lua r %s':format(_addon.name))
        return
    end

    work(arg)
end)
