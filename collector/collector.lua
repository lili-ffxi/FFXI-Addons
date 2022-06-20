_addon.name = 'Collector'
_addon.author = 'Lili'
_addon.version = '0.0.5'
_addon.commands = {'memnon','collection','col'}

require('chat')
require('logger')
require('tables')

local slips = require('slips')
local res_items = require('resources').items

local collections = require('collections') 

bags = L{'safe','safe2','storage','locker','inventory','satchel','sack','case','wardrobe','wardrobe2','wardrobe3','wardrobe4','wardrobe5','wardrobe6','wardrobe7','wardrobe8',}

sorted_bags = L{'safe', 'safe2', 'storage', 'locker', 
                'satchel', 'sack', 'case', 'inventory', 
                'wardrobe', 'wardrobe2', 'wardrobe3','wardrobe4', 
                'wardrobe5', 'wardrobe6', 'wardrobe7','wardrobe8', 
                'slip 01', 'slip 02', 'slip 03', 'slip 04', 'slip 05', 'slip 06', 'slip 07', 'slip 08', 'slip 09', 'slip 10', 
                'slip 11', 'slip 12', 'slip 13', 'slip 14', 'slip 15', 'slip 16', 'slip 17', 'slip 18', 'slip 19', 'slip 20', 
                'slip 21', 'slip 22', 'slip 23', 'slip 24', 'slip 25', 'slip 26', 'slip 27', 'slip 28', }

function add_result(result,bag,count)
    local count = count > 1 and ' ('..count..')' or ''
    return (bag == 'missing' and result:color(259) or result:color(258)) .. count
end

function curate(set)
    
    local collection = L(collections[set])
    local inventory = windower.ffxi.get_items()

    local results = T{
                missing = collection:copy(),
                owned = L{},
            }
    
	for _,bag in ipairs(bags) do 
		for i = 1, inventory[bag].max do
			data = inventory[bag][i]
			if data.id ~= 0 then
                local name = res_items[data.id].name
                if collection:contains(name) then
                    if not results[bag] then
                        results[bag] = L{}
                    end
                    results[bag]:append(add_result(name,bag,data.count))
                    local m = results.missing:find(name)
                    if m then
                        results.missing:remove(m)
                    end
                    results.owned:append(name)
                end
			end
        end
    end

    local slip_storages = slips.get_player_items()
    for _, slip_id in ipairs(slips.storages) do
        local slip_name = 'slip '..tostring(slips.get_slip_number_by_id(slip_id)):lpad('0', 2)
        for _, id in ipairs(slip_storages[slip_id]) do
            local name = res_items[id].name
            if collection:contains(name) then
                if not results[slip_name] then
                    results[slip_name] = L{}
                end
                results[slip_name]:append(add_result(name,slip_name,1))
                local m = results.missing:find(name)
                if m then
                    results.missing:remove(m)
                end
                results.owned:append(name)                
            end
        end
    end
    
    --table.vprint(results)
    
    log('Results:')
    for i=#results.missing,1,-1 do
        local name = results.missing[i]
        local item = res_items:with('name',name)
        if not item then
            log('invalid item:',name:color(123)..'.','Check the spelling!')
            results.missing:remove(i)
        else
            log('missing:',name:color(259))
        end
    end

    for _,bag in ipairs(sorted_bags) do 
        if results[bag] then
            for _,item in ipairs(results[bag]) do
                log('%s: %s':format(bag,item))
            end
        end
    end
    
    log(set..':\n',results.owned.n,'owned /',results.missing.n,'missing')
    if results.owned.n + results.missing.n > #collection then
        log(' ' .. #collection,'unique items in the set.')
    end
end

function cmd(args)
    windower.send_command(args)
end

windower.register_event('addon command', function(...)
    
    local args = T{...}
    local mode = args[1] and args[1]:lower() or 'help'
    
    if mode == 'r' or mode == 'reload' then
        cmd('lua r '.._addon.name)
        return
        
    elseif mode == 'u' or mode == 'unload' then
        cmd('lua u '.._addon.name)
        return
        
    elseif mode == 'missing' then
        table.remove(args,1)
        log('missing only')
        
    elseif mode == 'owned' then
        table.remove(args,1)
        log('owned only')
        
    else
        mode = default_mode
        
    end
    
    local arg = args:concat(' '):lower()
    
    if collections[arg] then
        curate(arg)
    else
        if arg ~= 'help' then
            log('Collection not found: '..arg)
        end
        
        log('Usage:\n//col <collection name>\nAvailable collections:')
        for k,v in pairs(collections) do
            if #v > 1 then 
                log('\t',k)
            end
        end
    end
end)

--[[
Curation is about knowing which pieces belong together.
                          -- Memnon Delphius Vanderbeam
]]
