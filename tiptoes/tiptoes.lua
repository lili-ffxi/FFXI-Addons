_addon.name = 'Tiptoes'
_addon.author = 'Lili'
_addon.version = '0.0.9'
_addon.commands = {'tiptoes','tt'}

require('logger')
require('pack')
local res = require('resources')

local active = false
local queue = {}

local verbose = false

function dbg() table.vprint(queue) end

function cmd(str)
    if str:sub(1,1) == '/' then
        windower.chat.input(str)
    else
        windower.send_command(str)
    end
end

local argdict = {
    s = {'sneak'},
    sn = {'sneak'},
    sneak = {'sneak'},
    i = {'invisible'},
    ['in'] = {'invisible'},
    invis = {'invisible'},
    invisible = {'invisible'},
    si = {'sneak','invisible'},
    snin = {'sneak','invisible'},
    sneakinv = {'sneak','invisible'},
    sneakinvis = {'sneak','invisible'},
    both = {'sneak','invisible'},
}

-- can change priorities here by simply reordering the lines.
-- TODO: configurable priorities.
local actions = {
    sneak = {
        {job='DNC',type='ja',name='Spectral Jig',level=25,command='/ja "Spectral Jig" <me>'},
        {job='WHM',type='ma',name='Sneak',level=20,command='/ma Sneak <me>'},
        {job='RDM',type='ma',name='Sneak',level=20,command='/ma Sneak <me>'},
        {job='SCH',type='ma',name='Sneak',level=20,command='/ma Sneak <me>'},
        {job='NIN',type='ma',name='Monomi: Ichi',level=25,command='/ma "Monomi:ichi" <me>'},
        item = {type='item',name='Silent Oil',command='/item "Silent Oil" <me>'},
    },
    invisible = {
        {job='DNC',type='ja',name='Spectral Jig',level=25,command='/ja "Spectral Jig" <me>'},
        {job='WHM',type='ma',name='Invisible',level=25,command='/ma Invisible <me>'},
        {job='RDM',type='ma',name='Invisible',level=25,command='/ma Invisible <me>'},
        {job='SCH',type='ma',name='Invisible',level=25,command='/ma Invisible <me>'},
        {job='NIN',type='ma',name='Tonko: Ni',level=9,command='/ma "Tonko: Ni" <me>'},
        {job='NIN',type='ma',name='Tonko: Ichi',level=9,command='/ma "Tonko: Ichi" <me>'},
        item = {type='item',name='Prism Powder',command='/item "Prism Powder" <me>'},
    },
}

function queue_action(...)
    queue[#queue+1] = ...
    active = true
end

function work(job)
    local player = windower.ffxi.get_player()
    if verbose then log(player.main_job,player.main_job_level,player.sub_job,player.sub_job_level) end
    
    for _,task in ipairs(job) do
        if actions[task] then
            if verbose then log('task:',task) end
            local result = false
            for _,action in ipairs(actions[task]) do
                if (player.main_job == action.job and player.main_job_level >= action.level) or
                    (player.sub_job == action.job and player.sub_job_level >= action.level) then
                    local recasts local recast_id
                    if action.type == 'ja' then
                        recasts = windower.ffxi.get_ability_recasts()
                        recast_id = res.job_abilities:with('name',action.name).recast_id
                    elseif action.type == 'ma' then
                        local spell_id = res.spells:with('name',action.name).id
                        local spells = windower.ffxi.get_spells()
                        recasts = windower.ffxi.get_spell_recasts()
                        recast_id = spells[spell_id] and spell_id
                    end
                    if recasts[recast_id] == 0 then
                        result = table.copy(action)
                    end
                    break
                end
            end
            if not result then
                local item_id = res.items:with('name',actions[task].item.name).id
                local bags = res.bags:filter(function(t) return t.access == 'Everywhere' and t.en ~= "Recycle" end)
                for _,bag in pairs(bags) do
                    local items = windower.ffxi.get_items(bag.id)
                    for slot,item in ipairs(items) do
                        if item.id > 0 and item.id == item_id then
                            if verbose then log('found',item.id,res.bags[bag.id].en,actions[task].item.name) end
                            result = table.update(table.copy(actions[task].item),{item_id=item.id,bag=bag.id})
                            break
                        end
                    end
                end
            end
            if result then
                queue_action(table.update(result,{['task']=task:ucfirst()})) -- 3am hack that I will certainly never ever regret
                next_sequence = 0
            end
        end
    end
end

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

windower.register_event('addon command', function(...)
    if not windower.ffxi.get_info().logged_in then
        print('Tiptoes: not logged in.')
        return
    end
    
    local args = {...}
    
    local arg = args[1] and args[1]:lower() or 'both'
    local job     
    
    if arg == 'r' then 
        cmd('lua r tiptoes') 
        return
    elseif arg == 'help' then
        log('v.'.._addon.version)
        log('valid arguments:')
        log('//tiptoes <sneak|invis|sneakinvis>')
        log('commands can be shortened to s sn i in si snin')
        log('if no argument or an invalid argument is passed, I will apply both Sneak and Invisible.')
        return
    elseif argdict[arg] then
        job = argdict[arg]
    else
        log(arg:color(64), 'is an invalid command. Performing default action.')
        job = argdict.both
    end
        
    work(job)
    
end)

windower.register_event('incoming chunk',function(id,org,mod,inj,blk)
    if not active then
        return
    end

    if id == 0x028 then
        p = windower.packets.parse_action(org)
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
    end
end)

local moving = false
windower.register_event('outgoing chunk',function(id,org,mod,inj,blk)
    if not active then
        return
    end

    local seq = org:unpack('H',3)
    
    if id == 0x015 then
        moving = lastlocation ~= mod:sub(5, 16)
        lastlocation = mod:sub(5, 16)
        if not next_sequence then 
            next_sequence = (seq+5)%0x10000 -- 128 packets is about 1 minute. 5 packets is about 2 seconds.
        end
    end

	if next_sequence and seq >= next_sequence then
        if windower.ffxi.get_player().status > 1 or moving or midaction() then
            return
        end
        
        next_sequence = nil
        
        while #queue > 0 do
            local buffactive = S(windower.ffxi.get_player().buffs):map(function(id) return res.buffs[id].name end)

            local action = table.remove(queue,1)
            if verbose then
                table.print(action)
                log(action.task,buffactive[action.task])
            end
            if not buffactive[action.task] then
                if action.type == 'item' and action.bag > 0 then -- need pull
                    local inventory = windower.ffxi.get_bag_info(0)
                    if inventory.count >= inventory.max then
                        error('Not enough space in inventory to use %s, aborting.':format(action.name))
                        next_sequence = 0
                        return
                    end
                    local bag = windower.ffxi.get_items(action.bag)
                    for slot,item in pairs(bag) do
                        if item.id == action.item_id then
                            windower.ffxi.get_item(action.bag,slot,1)
                            table.insert(queue,1,table.update(action,{retry=true,bag=0}))
                            next_sequence = nil
                            return
                        end
                    end
                elseif action.name == 'Spectral Jig' and buffactive['Sneak'] then
                    if action.retry then
                        error('Cannot cancel Sneak, giving up.')
                        return
                    end
                    log('Sneak active, attempting to cancel the buff...')
                    cmd('cancel sneak')
                    table.insert(queue,1,table.update(action,{retry=true}))
                    return
                end
                log('using %s.':format(action.name))
                cmd(action.command)
                return
            end
        end
        
        active = false
        
    end
    
end)

windower.register_event('zone change','job change','logout','unload',function()
    active = false
    queue = {}
end)
