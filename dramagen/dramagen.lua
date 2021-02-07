_addon.name = 'Dramagen'
_addon.author = 'Evil Lili'
_addon.version = '6.6.6'
_addon.subversion = '1'
_addon.command = 'drama'

local packets = require('packets')
local weaponskills = require('resources').weapon_skills

local cmd = windower.send_command
local say = windower.chat.input

local drama = {}

local ordinal = {'>>> First','Second','Third',}

windower.register_event('load','login',function(name)
    local name = name or windower.ffxi.get_player().name
    
    if not name then
        return
    end
   
    log('dramagen: Drama Generator 6.6.6.' .. _addon.subversion)
    log('dramagen: Use at your own risk.')
    log('dramagen: //drama')
end)

windower.register_event('action',function(act)
    if act.category ~= 3 then
        return
    end
    
    local actor = windower.ffxi.get_mob_by_id(act.actor_id)
    if not actor or not actor.in_party or not actor.in_alliance then
        return
    end

    local data = {}
    data.actor = actor.id
    data.actor_name = actor.name or 'Unknown'
    data.target = act.targets[1].id
    data.target_name = windower.ffxi.get_mob_by_id(data.target).name or 'Unknown'
    data.damage = act.targets[1].actions[1].param
    data.ws = weaponskills[act.param].english
    
    for i=1,math.max(#drama,3) do
        local t = drama[i]
        if not t or data.damage > t.damage then
            if tonumber(i) == 1 then
                say('/p New best! %s takes the lead with %s damage on %s!':format(data.actor_name,data.damage,data.target_name))            
            end
            table.insert(drama, i, data)
            break
        end
    end

    if #drama > 3 then 
        drama = {drama[1],drama[2],drama[3]}
    end
end)

windower.register_event('addon command',function(arg)
    if arg == 'r' then
        cmd('lua r dramagen')
        return
    end
    
    if #drama < 1 then
      say('/e No drama yet! Perform some weapon skills please.')
      return
    end
    
    for i=#drama,1,-1 do
        local t = drama[i]
        if t.damage > 0 then
            say('/p %s place: %s with a %s %s on %s':format(ordinal[i],t.actor_name,t.damage,t.ws,t.target_name))
            coroutine.sleep(2+math.random(0.5,2))
        end
    end   
end)