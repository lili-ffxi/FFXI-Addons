_addon.name = 'TPSreport'
_addon.author = 'Lili'
_addon.version = '0.0.3'
_addon.command = 'tpsreport'

require('logger')
require('xml')
files = require('files')
packets = require('packets')
res_jobs = require('resources').jobs
local party = windower.ffxi.get_party()

local current_members = T{}
local known_players = T{}

function get_members()
    local prefixes = L{'p','a1','a2'}
    for _,prefix in ipairs(prefixes) do
        for i=0,5 do
            local m = party[prefix..i]
            if m and m.mob then
                local id = m.mob.id
                local job = function()
                    if known_players[id] then 
                        local mjob = res_jobs[known_players[id].mjob].name_short
                        local mjob_lv = known_players[id].mjob_lv
                        local sjob = res_jobs[known_players[id].sjob].name_short
                        local sjob_lv = known_players[id].sjob_lv
                        return '%s%s/%s%s':format(mjob,mjob_lv,sjob,sjob_lv)
                    end
                    return false
                end()
                current_members[m.name] = {
                        ['job'] = job or function() 
                                warning('Job unknown for',m.name,'- ask them to zone.')
                                return 'unknown'
                            end()
                    }
            end
        end
    end
end

windower.register_event('incoming chunk',function(id,data)
    if id ~= 0x0DD and id ~= 0x0DF then 
        return 
    end
    
    local p = packets.parse('incoming',data)
    if p.ID and p['Main job'] then
        known_players[p.ID] = {
                ['name'] = p['Name'] or false,
                ['mjob'] = p['Main job'] or p['Main Job'] ,
                ['mjob_lv'] = p['Main job level'] or p['Main Job level'],
                ['sjob'] = p['Sub job'] or p['Sub Job'] ,
                ['sjob_lv'] = p['Sub job level'] or p['Sub Job level'] 
            }
    end
end)

windower.register_event('addon command',function(cmd)
    if not windower.ffxi.get_info().logged_in then
        return
    end
    
    if cmd == 'help' then
        log('Load the addon before inviting people to the alliance, then when you\'re done and everybody is in zone input //tpsreport.')
        log('A timestamped file will be created in the export folder.')
        return
    end
    
    get_members()

    log('These People Showed:')
    for i,v in pairs(current_members) do
        if v.job ~= 'unknown' then
            log(i, '->',v.job)
        end
    end

    local date = os.date('*t')
    local time = os.date('%H%M%S')
    
    local name = windower.ffxi.get_player().name
    local filename = 'report_%.4u.%.2u.%.2u_%.2u.log':format(date.year, date.month, date.day, time)
    local timestamp = '%.4u%.2u%.2u%.2u':format(date.year, date.month, date.day, time)

    local report = T({ ['members'] = current_members }):to_xml()
    
    local file = files.new('/export/'..filename)
    if not file:exists() then
        file:create()
    end
    
    file:append('<?xml version="1.1" ?>\n')
    file:append('<timestamp>'.. timestamp ..'</timestamp>\n')
    file:append(report)

    current_members = {}

end)
