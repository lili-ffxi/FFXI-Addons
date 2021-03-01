_addon.name = 'Safe Oboro'
_addon.version = '0.1.2'
_addon.author = 'Lili'

require('logger')
local packets = require("packets")

local so = {
    player = false,
    partymembers = {},
    zone = false,
}

local blocked = {}

local oboro = false --{x = -180, y = 86, z = 11, r = 10, zone = 246}

local npc_by_zone = {
    [246] = {name = 'Oboro', x = -180, y = 86, z = 11, r = 10},
    [252] = {name = 'Oseem', x = 13.5, y = 24.70, z = 0.19, r = 6}
}

function oboro_is_near(t)
    local t = t or windower.ffxi.get_mob_by_target('me')
    if t.x then t.X = t.x t.Y = t.y end
    
    local dist = math.sqrt((oboro.x - t.X)^2 + (oboro.y - t.Y)^2)
    return oboro.r > dist and dist
end

windower.register_event('load','login',function()
    so.player = windower.ffxi.get_player()
    oboro = npc_by_zone[id]
    so.partymembers = windower.ffxi.get_party()
    
    if oboro and oboro_is_near() then
        notice('You loaded SafeOboro while already in Port Jeuno.')
        notice('Please zone and come back to ensure the addon works properly. Thanks!')
    end
end)

windower.register_event('zone change',function(id)
    oboro = npc_by_zone[id]
end)

windower.register_event('unload','logout', function()
    so.player = false
    so.zone = false
end)

windower.register_event('incoming chunk', function (id, org, mod, inj)
    if not oboro or not so.player or inj then -- Port Jeuno
        return
    end
    
    if id == 0x00D and string.sub(org, 5,8):unpack("I") ~= so.player.id then
        
        local p = packets.parse('incoming', org)
       
        if oboro_is_near(p) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p) 
        end
    end
end)