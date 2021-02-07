--[[
Copyright © Lili, 2019-2020
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Smeagol nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Smeagol'
_addon.author = 'Lili'
_addon.version = '1.2.5'
_addon.commands = {'smeagol','sm'}

require('logger')
require('tables')
require('pack')
packets = require('packets')
extdata = require('extdata')
res_slots = require('resources').slots
res_zones = require('resources').zones
--res_buffs = require('resources').buffs -- tentatively removed
send_command = windower.send_command

-- Adjust the rings you want to use here. Case sensitive.
xp_rings = T{'Echad Ring','Caliber Ring','Emperor Band', 'Empress Band', 'Chariot Band', 'Resolution Ring', 'Allied Ring', 'Kupofried\'s Ring','Sprout Beret',}
cp_rings = T{'Trizek Ring','Endorsement Ring','Facility Ring','Capacity Ring','Vocation Ring','Guide Beret',}

-- smeagol will swap to this ring after using the appropriate xp/cp ring. Set to false to disable.
-- currently only works with rings and not with berets
idle_ring = false

-- set your preferences here
function init()
    override = 'no' -- 'no','xp','bo'
    cycle_time = 4
    use_in_town = 'no' -- 'no', 'yes'
    capped_jp = true        -- Assume capped JP and Merits, 
    capped_merits = true    -- until a proper packet is detected.
    start:schedule(8)
end

-------------------------------------------------------------------------------
----------------- Do not touch anything below this point, ok? -----------------
-------------------------------------------------------------------------------

lang = string.lower(windower.ffxi.get_info().language)
active = false
busy = false
moving = false

buff_id = {
    ['Commitment'] = 579, --res_buffs:with('en','Commitment').id,
    ['Dedication'] = 249, --res_buffs:with('en','Dedication').id,
    ['Emporox\'s Gift'] = 618,
}

-- Having this here makes the addon use less ram than using the resources lib... maybe.

item_resources = T{
    [10796] = {id=10796,en="Decennial Ring",ja="デセニアルリング",enl="decennial ring",jal="デセニアルリング",cast_delay=15,cast_time=3,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=10,races=510,recast_delay=3600,slots=24576,stack=1,targets=1,type=5},
    [11666] = {id=11666,en="Novennial Ring",ja="ノベニアルリング",enl="novennial ring",jal="ノベニアルリング",cast_delay=15,cast_time=3,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=10,races=510,recast_delay=3600,slots=24576,stack=1,targets=1,type=5},
    [14671] = {id=14671,en="Allied Ring",ja="アライドリング",enl="Allied ring",jal="アライドリング",cast_delay=5,cast_time=1,category="Armor",flags=64576,jobs=8388606,level=30,max_charges=5,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [15198] = {id=15198,en="Sprout Beret",ja="スプラウトベレー",enl="Sprout beret",jal="スプラウトベレー",cast_delay=5,cast_time=1,category="Armor",flags=60480,jobs=8388606,level=1,max_charges=1,races=510,recast_delay=72000,slots=16,stack=1,targets=1,type=5},
    [15761] = {id=15761,en="Chariot Band",ja="戦車の指輪",enl="Chariot band",jal="戦車の指輪",cast_delay=5,cast_time=1,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=7,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [15762] = {id=15762,en="Empress Band",ja="女帝の指輪",enl="Empress band",jal="女帝の指輪",cast_delay=5,cast_time=1,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=7,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [15763] = {id=15763,en="Emperor Band",ja="皇帝の指輪",enl="Emperor band",jal="皇帝の指輪",cast_delay=5,cast_time=1,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=3,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [15793] = {id=15793,en="Anniversary Ring",ja="アニバーサリリング",enl="anniversary ring",jal="アニバーサリリング",cast_delay=15,cast_time=3,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=10,races=510,recast_delay=3600,slots=24576,stack=1,targets=1,type=5},
    [15840] = {id=15840,en="Kupofried's Ring",ja="クポフリートリング",enl="Kupofried's ring",jal="クポフリートリング",cast_delay=5,cast_time=1,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=11,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [26164] = {id=26164,en="Caliber Ring",ja="カリバーリング",enl="caliber ring",jal="カリバーリング",cast_delay=5,cast_time=1,category="Armor",flags=64596,jobs=8388606,level=1,max_charges=3,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [27556] = {id=27556,en="Echad Ring",ja="エチャドリング",enl="echad ring",jal="エチャドリング",cast_delay=5,cast_time=1,category="Armor",flags=64592,jobs=8388606,level=1,max_charges=1,races=510,recast_delay=7200,slots=24576,stack=1,targets=1,type=5},
    [28528] = {id=28528,en="Undecennial Ring",ja="ウデセニアルリング",enl="undecennial ring",jal="ウデセニアルリング",cast_delay=15,cast_time=3,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=11,races=510,recast_delay=3600,slots=24576,stack=1,targets=1,type=5},
    [28562] = {id=28562,en="Duodec. Ring",ja="ドデセニアルリング",enl="duodecennial ring",jal="ドデセニアルリング",cast_delay=15,cast_time=3,category="Armor",flags=64576,jobs=8388606,level=1,max_charges=12,races=510,recast_delay=3600,slots=24576,stack=1,targets=1,type=5},
    [28568] = {id=28568,en="Resolution Ring",ja="レゾルションリング",enl="resolution ring",jal="レゾルションリング",cast_delay=5,cast_time=1,category="Armor",flags=3108,jobs=8388606,level=30,max_charges=5,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [28569] = {id=28569,en="Expertise Ring",ja="エキスパートリング",enl="expertise ring",jal="エキスパートリング",cast_delay=5,cast_time=1,category="Armor",flags=64580,jobs=8388606,level=99,max_charges=10,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [15199] = {id=15199,en="Guide Beret",ja="ガイドベレー",enl="Guide beret",jal="ガイドベレー",cast_delay=5,cast_time=1,category="Armor",flags=60480,jobs=8388606,level=1,max_charges=1,races=510,recast_delay=72000,slots=16,stack=1,targets=1,type=5},
    [27557] = {id=27557,en="Trizek Ring",ja="トリゼックリング",enl="trizek ring",jal="トリゼックリング",cast_delay=5,cast_time=1,category="Armor",flags=64592,jobs=8388606,level=99,max_charges=1,races=510,recast_delay=7200,slots=24576,stack=1,targets=1,type=5},
    [26165] = {id=26165,en="Facility Ring",ja="ファシリティリング",enl="facility ring",jal="ファシリティリング",cast_delay=5,cast_time=1,category="Armor",flags=64596,jobs=8388606,level=99,max_charges=3,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
    [28469] = {id=28469,en="Endorsement Ring",ja="エンドースリング",enl="endorsement ring",jal="エンドースリング",cast_delay=5,cast_time=1,category="Armor",flags=64576,jobs=8388606,level=99,max_charges=1,races=510,recast_delay=7200,slots=24576,stack=1,targets=1,type=5},
    [28563] = {id=28563,en="Vocation Ring",ja="ボケイションリング",enl="vocation ring",jal="ボケイションリング",cast_delay=15,cast_time=3,category="Armor",flags=64576,jobs=8388606,level=99,max_charges=12,races=510,recast_delay=3600,slots=24576,stack=1,targets=1,type=5},
    [28546] = {id=28546,en="Capacity Ring",ja="キャパシティリング",enl="capacity ring",jal="キャパシティリング",cast_delay=5,cast_time=1,category="Armor",flags=64580,jobs=8388606,level=99,max_charges=7,races=510,recast_delay=900,slots=24576,stack=1,targets=1,type=5},
}

function get_item_info(items)
    local results = T{}
    for i,v in ipairs(items) do
        local item = item_resources:with('en', v) -- TODO: expand to check for long and jp text. Is jp text even needed?
        if item and item.id > 0 then
            results[i] = {
                ['id'] = item.id,
                ['slot'] = item.slots == 16 and 4 or 13,
                ['english'] = '"'..item.en..'"',
                ['japanese'] = item.ja,
            }
        end
    end
    return results
end

xp_rings_info = get_item_info(xp_rings)
cp_rings_info = get_item_info(cp_rings)

-- returns current zone
local function get_zone()
    return res_zones[windower.ffxi.get_info().zone].en
end

-- returns true if current zone is a city or town.
local in_town = function()
	local Cities = S{
            "Northern San d'Oria", "Southern San d'Oria", "Port San d'Oria", "Chateau d'Oraguille",
            "Bastok Markets", "Bastok Mines", "Port Bastok", "Metalworks",
            "Windurst Walls", "Windurst Waters", "Windurst Woods", "Port Windurst", "Heavens Tower",
            "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno",
            "Selbina", "Mhaura", "Kazham", "Norg", "Rabao", "Tavnazian Safehold",
            "Aht Urhgan Whitegate", "Al Zahbi", "Nashmau",
            "Southern San d'Oria (S)", "Bastok Markets (S)", "Windurst Waters (S)",
            -- "Walk of Echoes", "Provenance", -- YMMV
            "Western Adoulin", "Eastern Adoulin", "Celennia Memorial Library",
            "Bastok-Jeuno Airship", "Kazham-Jeuno Airship", "San d'Oria-Jeuno Airship", "Windurst-Jeuno Airship",
            "Ship bound for Mhaura", "Ship bound for Selbina", "Open sea route to Al Zahbi", "Open sea route to Mhaura",
            "Silver Sea route to Al Zahbi", "Silver Sea route to Nashmau", "Manaclipper", "Phanauet Channel",
            "Chocobo Circuit", "Feretory", "Mog Garden",
            }
    return function()
        if Cities:contains(get_zone()) then
            return true
        end
        return false
    end
end()

local midaction = function()
    local acting = false
    local last_action = -1
    local cooldown = false
    
    return function(param)
        if param ~= nil then
            acting = param and true
            cooldown = type(param) == 'number' and param > 0 and param
            last_action = os.clock()
        end
        if cooldown and os.clock() > (last_action + cooldown) then
            cooldown = false
            acting = false
        end

        return acting
    end
end()


-- returns a string with human readable time.
local time2human = function(seconds,period)
    local response = ''
    if seconds > 86400 then 
        response = 'more than a day'
    else
        local h = math.floor(seconds/3600)
        local m = math.floor(seconds%3600/60)
        local s = seconds%60

        if h > 0 then response = '%s hour%s':format(h,h > 1 and 's' or '') end
        if h > 0 and m > 0 then response = response .. ' and ' end
        if m > 0 then response = response .. '%s minute%s':format(m,m > 1 and 's' or '') end
        if (h*10 + m) < 2 then response = '%s seconds':format(s) end
    end
    
    return response .. (period and '.' or '')
end

function start()
    if not active then
        active = check_exp_buffs:loop(cycle_time)
    end
end

function stop()
    if active then
        coroutine.close(active)
        active = false
    end
end

function gs_disable_slot(slot)
    send_command('gs disable '..res_slots[slot].en:gsub(' ','_'))
end

function gs_enable_slot(slot)
    send_command('gs enable '..res_slots[slot].en:gsub(' ','_'))
end

function my_preciouss() -- not very semantic but the ring will do that to you
    if not windower.ffxi.get_info().logged_in then
        return false
    end

    if busy or moving or midaction() then 
        return false
    end
    
    if in_town() and use_in_town == 'no' then
        return false
    end

    if windower.ffxi.get_info().mog_house then
        return false
    end

    if windower.ffxi.get_player().status > 1 then
        return false
    end

    return true
end

function check_exp_buffs(option)

    if not my_preciouss() then
        return
    end

    -- detect ring buffs
    local xp_buff = 0
    local cp_buff = 0
    local capped_merits = capped_merits

    local player = windower.ffxi.get_player()
    for _,v in ipairs(player.buffs) do
        if v == buff_id['Dedication'] then
            xp_buff = xp_buff +1
        elseif v == buff_id['Commitment'] then
            cp_buff = cp_buff +1
        elseif v == buff_id['Emporox\'s Gift'] then
            capped_merits = false
        end
    end

    -- account for Kupofried trust
    -- can fail in the time between summoning Kupofried and the aura becoming active on the player.
    if xp_buff > 0 then
        local party = windower.ffxi.get_party()
        for i = 1,5 do
            local member = party['p' .. i]
            if member and member.name == 'Kupofried' and math.sqrt(member.mob.distance) < 6 then -- possibly make sure we're in range of the aura
                xp_buff = xp_buff -1
            end
        end
    end

    if xp_buff < 1 and cp_buff < 1 then
        local rings = T{}
        if (player.main_job_level == 99 and override ~= 'xp') and not capped_jp then
            rings:extend(cp_rings_info)
        end
        if player.main_job_level < 99 or ((override == 'bo' or override == 'xp') and not capped_merits) then
            rings:extend(xp_rings_info)
        end
        search_rings(rings)
    end
end

function search_rings(item_info) -- thanks to from20020516, this code is from MyHome addon with some modifications.
    local item_array = {}
    local bags = {0,8,10,11,12} --inventory,wardrobe1-4
    local get_items = windower.ffxi.get_items
    for i=1,#bags do
        for _,item in ipairs(get_items(bags[i])) do
            if item.id > 0 then
                item_array[item.id] = item
                item_array[item.id].bag = bags[i]
            end
        end
    end
    local min_recast = false
    for index,stats in pairs(item_info) do
        local item = item_array[stats.id]
        local set_equip = windower.ffxi.set_equip
        if item then
            local ext = extdata.decode(item)
            local enchant = ext.type == 'Enchanted Equipment'
            local recast = enchant and ext.charges_remaining > 0 and math.max(ext.next_use_time+18000-os.time(),0)
            local usable = recast and recast == 0
            if usable then
                log(stats[lang])
            elseif recast then
                log(stats[lang],time2human(recast,true))
                if not min_recast or recast < min_recast then
                    min_recast = recast
                end
            end
            if usable then
                gs_disable_slot(stats.slot)
                busy = true
                if enchant and item.status ~= 5 then --not equipped
                    set_equip(item.slot,stats.slot,item.bag)
                    log_flag = true
                    local timeout = 0
                    repeat --waiting cast delay
                        coroutine.sleep(1)
                        local ext = extdata.decode(get_items(item.bag,item.slot))
                        local delay = ext.activation_time+18000-os.time()
                        timeout = timeout +1
                        if midaction() then
                            log(stats[lang],math.max(delay,0),'busy')
                            ext.usable = false
                        elseif delay > 0 then
                            log(stats[lang],delay)
                        elseif log_flag then
                            log_flag = false
                            log('Item use within 3 seconds..')
                        end
                    until ext.usable or delay > 15 or timeout > 30
                end
            windower.chat.input('/item '..windower.to_shift_jis(stats[lang])..' <me>')
            coroutine.sleep(2)
            busy = false
            gs_enable_slot(stats.slot)
            if idle_ring then
                coroutine.sleep(5)
                windower.chat.input('/equip "%s" %s':format(res_slots[stats.slot].name,idle_ring))
            end
            min_recast = false
            break
            end
        end
    end
    if min_recast then
        stop()
        start:schedule(min_recast)
        log('All rings on recast. Sleeping for',time2human(min_recast,true))
    end
end

windower.register_event('incoming chunk', function(id,data,modified,is_injected,is_blocked)
    if id == 0x028 then
        p = windower.packets.parse_action(data)
        if p.actor_id ~= windower.ffxi.get_player().id then
            return
        end
        -- this could be much simpler but I like the categorizations
        if p.category >= 2 and p.category <= 8 then -- finish: ranged atk, WS, spells, items; begin: JAs, WSs,
            midaction(2.5)
        elseif p.category == 6 or p.category == 7 or p.category == 14 then -- JA, WS/TP moves, DNC moves
            midaction(2.5)
        elseif p.category == 8 or p.category == 9 or p.category == 12 or p.category == 15 then -- spells, items, ranged attacks, run JAs?
            if p.param == 28787 then
                midaction(2.5)
            else
                midaction(true)
            end
        end
    elseif id == 0x63 then
        -- thanks Byrth, this is verbatim from Pointwatch.
        if data:byte(5) == 5 then
            local offset = windower.ffxi.get_player().main_job_id*6+13 -- So WAR (ID==1) starts at byte 19
            local jp_held = data:unpack('H',offset+2)
            capped_jp = jp_held == 500
        elseif data:byte(5) == 2 then
            local merits_held = data:byte(11)%128
            local maximum_merits = data:byte(0x0D)%128    
            capped_merits = merits_held == maximum_merits
        end
    end
end)

windower.register_event('load', function()
    if not windower.ffxi.get_info().logged_in then
        return
    end
    
    coroutine.sleep(0.5)
    
    -- opening equipment menu also gets current JP and Merits held.
    local packet = packets.new('outgoing', 0x061, {}) 
    packets.inject(packet)
end)

windower.register_event('unload',stop)

windower.register_event('outgoing chunk',function(id,data,modified,is_injected,is_blocked)
    if id == 0x015 then
        moving = lastlocation ~= modified:sub(5, 16)
        lastlocation = modified:sub(5, 16)

		-- if wasmoving ~= moving then
			-- log(moving and 'moving' or 'stopped')
		-- end
		-- wasmoving = moving
    end
end)


windower.register_event('addon command',function(cmd,opt)
    local cmd = cmd:lower()
    if cmd == 'reload' or cmd == 'r' then
        send_command('lua reload smeagol')
    elseif cmd == 'unload' or cmd == 'u' then
        send_command('lua unload smeagol')
    elseif cmd == 'on' or cmd == 'start' then
        log('Starting.')
        start()
    elseif cmd == 'off' or cmd == 'stop' then
        log('Stopping.')
        stop()
    elseif cmd == 'xp' or cmd == 'both' or cmd == 'normal' then
        override = cmd:sub(1,2)
        log('Override mode set to %s.':format(cmd:upper()))
    elseif tonumber(cmd) and tonumber(cmd) < 300 and tonumber(cmd) > 0 then
        cycle_time = cmd
        log('Delay between checks set to %s seconds.':format(cmd))
    elseif cmd == 'town' then
        use_in_town = use_in_town == 'no' and 'yes' or 'no'
        log('Rings %s be used in town.':format(use_in_town == 'yes' and 'will' or 'will not'))
    elseif cmd == 'check' then
        stop()
        start()
        log('Checking for new available rings...')
        log(capped_jp and 'JP are capped.' or '',capped_merits and 'Merits are capped' or '')
    elseif cmd == 'reset' then
        stop()
        init()
        log('Override disabled and delay between checks reset to %s seconds. Restarting.':format(cycle_time))
    elseif cmd == 'help' then
        log('Go to ffxiah.com and search for \'smeagol\' to get help.')
    else
        log('Command not valid.')
        send_command('smeagol help')
    end
end)

init()
