_addon.name = 'clevel'
_addon.author = 'Lili'
_addon.version = '1.1.1'
_addon.command = 'clevel'

local packets = require('packets')

local log = windower.add_to_chat+{207}

local XPtnls = {500,750,1000,1250,1500,1750,2000,2200,2400,2600,2800,3000,3200,3400,3600,3800,4000,4200,4400,4600,4800,5000,5100,5200,5300,5400,5500,5600,5700,5800,5900,6000,6100,6200,6300,6400,6500,6600,6700,6800,6900,7000,7100,7200,7300,7400,7500,7600,7700,7800,8000,9200,10400,11600,12800,14000,15200,16400,17600,18800,20000,21500,23000,24500,26000,27500,29000,30500,32000,34000,36000,38000,40000,42000,44000,44500,45000,45500,46000,46500,47000,47500,48000,48500,49000,49500,50000,50500,51000,51500,52000,52500,53000,53500,54000,54500,55000,55500,56000,}

local EPtnls = {2500,5550,8721,11919,15122,18327,21532,24737,27942,31147,41205,48130,53677,58618,63292,67848,72353,76835,81307,85775,109112,127014,141329,153277,163663,173018,181692,189917,197845,205578,258409,307400,353012,395651,435673,473392,509085,542995,575336,606296,769426,951369,1154006,1379407,1629848,1907833,2216116,2557728,2936001,3354601,3817561,}

local levels, Mlevels, tnl, tnml = {}, {}, 0, 0
for i=1,#XPtnls do
    levels[XPtnls[i]] = i
end

for i=1,#EPtnls do
    Mlevels[EPtnls[i]] = i
end

function get_amounts(data)
    local p = packets.parse('incoming',data)
    tnl = p['Required EXP']
    tnml = p['Required Exemplar Points']
    tolvlup = tnml - p['Current Exemplar Points']
end

windower.register_event('login','load',function()
    local org = windower.packets.last_incoming(0x061)
    if org then get_amounts(org) end
end)

windower.register_event('incoming chunk',function(id,org)
    if id == 0x061 then
        get_amounts(org)
    end
end)

windower.register_event('addon command',function(...)
    local sync = tostring(T(windower.ffxi.get_player().buffs):contains(269)) -- level sync
    local tnl = levels[tnl]
    local tnml = Mlevels[tnml]-1
    local tolvlup = tonumber(tolvlup)
    local msg = 'Current level: %s - Master level: %s - Sync: %s - To level up: %s'
    log(msg:format(tnl, tnml, sync, tolvlup))
end)
