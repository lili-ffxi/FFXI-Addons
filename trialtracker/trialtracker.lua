_addon.name = 'Trialtracker'
_addon.author = 'Lili'
_addon.version = '0.0.1'
_addon.command = 'tt'

require('logger')
local packets = require('packets')
local texts = require('texts')

local track = texts.new('Trial ${trial}: ${status}.') 
texts.pos(track, 500, 500)

windower.register_event('incoming chunk',function(id,org)
    if id ~= 0x029 then
        return
    end
    
    local p = packets.parse('incoming',org)
    
    if p.Message == 583 then
        track.trial = p["Param 1"]
        track.status = p["Param 2"] .. ' remaining'

        track:show()

    elseif p.Message == 584 then
        track.trial = p["Param 1"]
        track.status = 'Completed'

        track:show()
    end
end)
