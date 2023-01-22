_addon.name = 'waveback'
_addon.version = '0.0.1'
_addon.author = 'Lili'
_addon.command = 'waveback'

local cooldown = os.time()
local delay = 'random'
local response = '/wave'

packets = require('packets')

math.randomseed(os.time())
math.random();
math.random:loop(0.1,math.random(5,10))

-- This packet isn't only sent for /check but we pretend it is.
packets.raw_fields.incoming[0x009] = L{
    {ctype='data[17]',              label='_dummy1'},                                   -- 70
    {ctype='char*',                 label='Name'},                                      -- 74
}

windower.register_event('incoming chunk',function(id,org,mod,inj,blk)
    if id ~= 0x009 or not windower.ffxi.get_info().logged_in then
        return
    end
    
    if cooldown > os.time() then
        return
    end
    
    local p = packets.parse('incoming', mod)
    if p.Name then
        coroutine.sleep(math.random(1,5))
        windower.chat.input(response .. ' ' .. p.Name)
        cooldown = os.time()+(delay == 'random' and math.random(2,10) or delay)
    end
end)

windower.register_event('addon command',function(cmd,arg)
    if cmd == 'delay' then
        if arg == 'random' then
            cooldown = arg
            windower.add_to_chat(207,_addon.name .. ': Cooldown set to random.')
        elseif tonumber(arg) then
            cooldown = tonumber(arg)
            windower.add_to_chat(207,_addon.name ..': Cooldown set to ' .. cooldown)
        else
            windower.add_to_chat(207,_addon.name ..'Invalid argument.')
        end
    elseif cmd == 'response' then
        action = arg
    elseif cmd == 'help' then
        windower.add_to_chat(207,_addon.name .. ": Options: delay <n|'random'>; response </command>; help")
    end
end)
