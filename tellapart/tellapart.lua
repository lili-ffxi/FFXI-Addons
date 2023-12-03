_addon.name = 'tellapart'
_addon.author = 'Lili'
_addon.version = '1.1.4'
_addon.commands = { 'tellapart', 'ta' }

packets = require('packets')

local renames = {}
local zonecache = {}

local mask = true

--[[ Disabled by default in cities:
            "Northern San d'Oria", "Southern San d'Oria", "Port San d'Oria", "Chateau d'Oraguille",
            "Bastok Markets", "Bastok Mines", "Port Bastok", "Metalworks",
            "Windurst Walls", "Windurst Waters", "Windurst Woods", "Port Windurst", "Heavens Tower",
            "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno",
            "Selbina", "Mhaura", "Kazham", "Norg", "Rabao", "Tavnazian Safehold",
            "Aht Urhgan Whitegate", "Nashmau",
            "Western Adoulin", "Eastern Adoulin", "Celennia Memorial Library",
            "Bastok-Jeuno Airship", "Kazham-Jeuno Airship", "San d'Oria-Jeuno Airship", "Windurst-Jeuno Airship",
            "Chocobo Circuit", "Feretory", "Mog Garden", "The Colosseum"
    Enabled in city-like areas where mobs can appear:
            "Al Zahbi", "Southern San d'Oria (S)", "Bastok Markets (S)", "Windurst Waters (S)",
            "Walk of Echoes", "Provenance",
            "Ship bound for Mhaura", "Ship bound for Selbina", "Open sea route to Al Zahbi", "Open sea route to Mhaura",
            "Silver Sea route to Al Zahbi", "Silver Sea route to Nashmau", "Manaclipper", "Phanauet Channel", 
]]

local Cities = S{ 70, 247, 256, 249, 244, 234, 245, 257, 246, 248, 230, 53, 236, 233, 223, 238, 235, 226, 239, 240, 232, 250, 231, 284, 242, 26, 252, 280, 285, 225, 224, 237, 50, 241, 243, 71 }

function letter_suffix(num)
    local s = ''
    while num >= 1 do
        m = (num -1) %26 + string.byte("A")
        s = string.char(m) .. s
        num = math.floor((num-1) / 26)
    end
    
    return ' '..s
end

function prepare_names()

    if Cities[windower.ffxi.get_info().zone] then
        active = false
        return
    end

    zonecache = {}
    
    local mobs = windower.ffxi.get_mob_list()
    
    local duplicates = {}
    for index,name in pairs(mobs) do
        if #name > 1 then
            if duplicates[name] then
                duplicates[name]:append(index)
            else
                duplicates[name] = L{index}
            end
        end
    end

    function countmobs()
        local sorted = {}
        for i,v in pairs(duplicates) do
            if v.n > 1 then
                sorted[#sorted+1] = i
            end
        end
        table.sort(sorted)
        for i,v in pairs(sorted) do
            windower.add_to_chat(207,'tellapart: %s: %s':format(v,duplicates[v].n))
        end
    end
    
    for name, indexes in pairs(duplicates) do
        if name ~= 'n' and indexes.n > 1 then
            local counter = 1
            for index in indexes:it() do
                zonecache[index] = name:sub(1,20) .. letter_suffix(counter)
                counter = counter + 1
            end
        end
    end
    
    renames = {}
    
    for idx in pairs(zonecache) do
        local t = windower.ffxi.get_mob_by_index(idx)
        if t and (t.spawn_type == 0x010) then
            renames[t.id] = zonecache[idx]
            zonecache[idx] = nil
        end
    end
    
    active = true
end

windower.register_event('load',function()
    if not windower.ffxi.get_info().logged_in then
        active = false
        return
    end
    prepare_names()
end)

windower.register_event('zone change',function()
    zonecache = {}
    duplicates = {}
    renames = {}
    active = false
end)

windower.register_event('outgoing chunk', function(id,org,mod,inj,blk)
    if id ~= 0x00C then
        return
    end
    prepare_names()
end)

windower.register_event('incoming chunk', function(id,org,mod,inj,blk)
    if id ~= 0x00E then
        return
    end
    
    local idx = org:unpack('H',0x009)
    
    if zonecache[idx] then
        local t = windower.ffxi.get_mob_by_index(idx)
        if t then
            if t.spawn_type == 0x010 then
                renames[t.id] = zonecache[idx]
            end
            zonecache[idx] = nil
        end
    end
end)

windower.register_event('prerender', function()
    if not active then
        return
    end
    
    for i,v in pairs(renames) do
        windower.set_mob_name(i,v)
    end
end)

windower.register_event('outgoing text',function(_,mod,block)
    if block or not mask then
        return
    end
    
    if mod:find('<t>') then
        local t = windower.ffxi.get_mob_by_target('t')
        if t and renames[t.id] then
            local name = t.name:gsub('(%s%u%u?)$','')
            return mod:gsub('<t>',name)
        end
    end
end)

windower.register_event('addon command',function(arg)
    arg = arg:lower()
    if arg:startswith('mask') then
        mask = not mask
        windower.add_to_chat(207, _addon.name..': Chat masking is now '..tostring(mask):upper())
    end
end)
