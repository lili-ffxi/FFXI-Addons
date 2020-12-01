--[[
Copyright © Lili, 2019
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of dumperino nor the
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

_addon.name = 'dupefind'
_addon.author = 'Lili'
_addon.version = '0.9.0'
_addon.commands = {'dupefind','dupe', 'df',}

require('logger')
require('tables')
require('strings')
config = require('config')

texts = require('texts')

res = require('resources')

-- Returns true if searchval is in t.
function table.key_mcontains(t, searchval)
    for key, _ in pairs(t) do
        if key:contains(searchval) then
            return true
        end
    end
    return false
end

colors = {}
colors['white'] =       '\\cs(255,255,255)'
colors['red'] =         '\\cs(255,0,0)'
colors['green'] =       '\\cs(0,255,0)'
colors['blue'] =        '\\cs(0,0,255)'
colors['gray'] =        '\\cs(102,102,102)'
colors['lightgray'] =   '\\cs(211,211,211)'
colors['black'] =       '\\cs(0,0,0)'
colors['yellow'] =      '\\cs(255,255,0)'
colors['gold'] =        '\\cs(255,215,0)'
colors['darkyellow'] =  '\\cs(204,204,0)'
colors['flatblue'] =    '\\cs(51,153,255)'
colors['lightgreen'] =  '\\cs(51,255,153)'
colors['purple'] =      '\\cs(153,51,255)'
colors['mauve'] =       '\\cs(255,51,153)'
colors['flatgreen'] =   '\\cs(153,255,51)'
colors['flatorange'] =  '\\cs(255,153,51)'
colors['tomato'] =      '\\cs(255,99,71)'

color = function(text,shade)
    shade = colors[shade] and shade or 'white' -- default color
    return colors[shade] .. text .. '\\cr'
end

local defaults = {}
defaults.ignore_items = S{ 'linkshell', 'linkpearl' }
defaults.ignore_players = S{ 'Freonski','Cromechu','Ariasan','Muljn','Mulka','Miavi','Tuavi' }
defaults.ignore_rare = true
defaults.ignore_ex = true
defaults.ignore_cannotsendpol = true  -- ignores 'Can Send POL' == false
defaults.ignore_nostack = true
defaults.player_only = true         -- basically the findall flag
defaults.match_player = true        -- filters findall results to dupes with current player
defaults.filter_by_player = true
defaults.print_to_log = false
defaults.print_to_textbox = true
defaults.sort_mode = 'asc'          -- valid modes: asc, desc, none

defaults.view_textbox = true
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 10
defaults.display.pos.y = 10
defaults.display.padding = 15
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 152
defaults.display.text = {}
defaults.display.text.font = 'Consolas'--'Arial'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 11

templates = {
    default = {
        header = '- - - - -< duplicates >- - - - -',
        item = '\n  ' .. color('%s','yellow') .. color(' found in: ','lightgray'),
        location = '           [ ' .. color('%4d','gold') .. ' ] ' .. color(' %s','green'),
        total = '\n- - - - - -< %d' .. color(' found','red') .. ' >- - - - - -',
    -- item = '${item_name} found in:',
    -- location = '${bag} ${quantity}':lpad(' ', 5),
    -- total_dupes = '${count} found.'
    },
    freespace = {
        header = 'Bag          Used/Max  Free\n--------- ________ ----',
        body = '%s',
        footer = '',
        -- free = '${bag} [${used}/${max}] '
    },
    box = {
        header = '- - - - -< duplicates >- - - - -',
        item = '\n  ' .. color('%s','yellow') .. color(' found in: ','lightgray'),
        location = '           [ ' .. color('%4d','gold') .. ' ] ' .. color(' %s','green'),
        total = '\n- - - - - -< %d' .. color(' found','red') .. ' >- - - - - -'
    },
    log = {
        header = '- - - - -< duplicates >- - - - -',
        item = '\n  %s found in: ',
        location = '           [ %4d ]  %s',
        total = '\n- - - - - -< %d found >- - - - - -'
    },

}

settings = config.load(defaults)
settings:save()

display = T{last_args = nil}
display.box = {
    active = false,
    visible = false,
    results = {},
    view = texts.new(settings.display, settings),
    hide = function(box)
        box.view:hide()
        box.visible = false
    end,
    clear = function(box)
        box.view:hide()
        box.visible = false
        box.view:clear()
        box.active = false
    end,
    show = function(box)
        if box.view.active then
            box.view:show()
            box.visible = true
        else
            warning('No active results box. Running new dupefind.')
            windower.send_command('df')
        end
    end,
    print = function(box, dupes, template)
        box.view:clear()
        -- local header = box.format({header=dupes.header,items={}})
        local results = box.format(dupes, template)
        -- log('results.length: ',results.n) -- #debug
        box.view:append(results:slice(1,50):concat('\n '))
        box:fix_position()
        box.active = true
        box.view:show()
        box.visible = true
    end,
    format = function(dupes, template)
        local results = L{}  -- collects formatted lines
        results:append(template.header)
        for _,item in ipairs(dupes.sorted) do
            results:append(template.item:format(item))
            for location, count in pairs(dupes.items[item]) do
                results:append(template.location:format(count, location))
            end
        end
        results:append(template.total:format(dupes.count))
        return results
    end,
    doScroll = function(dupes, delta)
        return true
    end,
    update = function()
        -- TODO: break up work() so it can be run in piecemeal
        -- just rerunning work for now until the rewrite
        work(display.last_args)
    end,
    fix_position = function(box)
        local _x, _y, _dx, _dy, _win
        _x, _y = box.view:pos() -- display.box.view:pos()
        _dx, _dy = box.view:extents() -- display.box.view:extents()
        _win = windower.get_windower_settings()
        if (_y + _dy) < 0 or  _y > _win.ui_y_res then
            box.view:pos_y(10) -- display.box.view:pos_y(10)
        end
        if (_x + _dx) < 0 or _x > _win.ui_x_res then
            box.view:pos_x(10) -- display.box.view:pos_x(10)
        end
    end,
}

display.log = {
    print = function(dupes, template)
        log(template.header)
        for _,item in ipairs(dupes.sorted) do
            log(template.item:format(item))
            for location, count in pairs(dupes.items[item]) do
                log(template.location:format(count, location))
            end
        end
        log(template.total:format(dupes.count))
    end,
}
-- display.con = {}  -- just a thought

bags = S{'safe','safe2','storage','locker','inventory','satchel','sack','case','wardrobe','wardrobe2','wardrobe3','wardrobe4'}

-------------------------------------------------------------------------------------------------------------
local state = {
    player_name = nil,
    findall_data = nil,
    findall_data_status = nil, -- stale when it needs to update
    lang = windower.ffxi.get_info().language:lower(),
}

ignore_items = settings.ignore_items:map(string.lower)
ignore_ids = res.items:filter(function(item) 
        return ignore_items:contains(item.name:lower()) or ignore_items:contains(item.name_log:lower()) 
    end):keyset()

-- searches args
local get_flag = function(args, flag, default)
    if #args == 0 then return default end
    local tflag = (type(flag) == 'table') and T(flag) or T{flag}

    for _, arg in ipairs(args) do
        if tflag:contains(arg:lower()) then
            if type(flag) == 'table' then
                return arg:lower()
            else
                return false
            end
        end
    end
    return default
end

function CanSendPol(id) return S(res.items[id].flags):contains('Can Send POL') end
function IsRare(id) return S(res.items[id].flags):contains('Rare') end
function IsExclusive(id) return S(res.items[id].flags):contains('Exclusive') or S(res.items[id].flags):contains('No PC Trade') end
function IsStackable(id) return res.items[id].stack > 1 end

function init()
    local player = windower.ffxi.get_player()
    state.player_name = player and player.name
    update_findall_data('init')
end

-- returns an array alphanumerically sorted based on the mode parameter
-- valid modes: none, asc, desc -- none returns an unsorted array
function sort_by_keys(items, mode)
    local a = {}  -- array of item names to be sorted
    for n in pairs(items) do a[#a + 1] = n end
    if mode == 'none' then 
        return a
    elseif mode == 'desc' then
        table.sort(a, function(item1, item2)
            return (item1 > item2)
        end)
    else
        table.sort(a)
    end
    return a
end

function work(...)
    local args = {...}
    display.last_args = ...
    
    local ignore_rare = get_flag(args, 'rare', settings.ignore_rare) -- where `settings` is the global settings table
    local ignore_ex = get_flag(args, 'ex', settings.ignore_ex)
    local ignore_cannotsendpol = get_flag(args, 'csp', settings.ignore_cannotsendpol) -- results will include items not sendable to same pol
    local ignore_nostack = get_flag(args, 'nostack', settings.ignore_nostack)
    local player_only = get_flag(args, 'findall', settings.player_only)
    local filter_by_player = get_flag(args, 'nofilter', settings.filter_by_player)
    local sort_mode = get_flag(args, {'asc','desc','none'}, settings.sort_mode)
    
    local player_name = state.player_name
    local inventory = windower.ffxi.get_items()
    local storages = {}

    if not player_only then
        if state.findall_data_status == 'processing' then
            return work:schedule(.5, ...)
        end
        storages = state.findall_data     -- adds findall data to storages
    end
    storages[player_name] = {}
  
    local haystack = {}

    local dupes = {}
    dupes.count = 0
    dupes.items = {}
    dupes.sorted = nil

    -- flatten inventory
    -- Shamelessly stolen from findAll. Many thanks to Zohno.    
    for bag,_ in pairs(bags:keyset()) do
        storages[player_name][bag] = T{}
        for i = 1, inventory[bag].max do
            local data = inventory[bag][i]
            if data.id ~= 0 then
                local id = data.id
                storages[player_name][bag][id] = (storages[player_name][bag][id] or 0) + data.count
            end
        end
    end
    
    for character, inventory in pairs(storages) do
        if not settings.ignore_players:contains(character) then
            for bag,items in pairs(inventory) do
                if bags:contains(bag) then
                    for id, count in pairs(items) do
                        id = tonumber(id)
                        --if item is valid, stackable, not ignored, not rare, not Exclusive, and CanSendPol
                        if res.items[id] and (not ignore_ids:contains(id))
                            and (IsStackable(id) or not ignore_nostack)
                            and (not IsRare(id) or not ignore_rare)
                            -- this can only evaluate to false under one set of conditions
                            --  IsExclusive + not CanSendPol + ignore_cannotsendpol + ignore_ex
                            and ((not IsExclusive(id) or (CanSendPol(id) or not ignore_cannotsendpol)) or not ignore_ex)
                        then
                            --player str, bag str, id int, count int
                            local location = (player_only and bag or character..': '..bag)
                            if not haystack[id] then haystack[id] = T{} end
                            haystack[id][location] = count
                        end
                    end
                end
            end
        end
    end

    --record duplicates
    for id,locations in pairs(haystack) do
        if table.length(locations) > 1 then -- if item is in more than one location
            if not player_only and settings.match_player then -- findall only if player is in location table
                if locations:key_mcontains(player_name..':') then
                    dupes.count = dupes.count + 1
                    dupes.items[res.items[id].name] = locations
                end
            else
                dupes.count = dupes.count + 1
                dupes.items[res.items[id].name] = locations
            end
        end
    end

    if dupes.count >= 1 then  -- display results
        dupes.sorted = sort_by_keys(dupes.items, sort_mode)
        if settings.print_to_textbox then 
            display.box:print(dupes, templates.box)
        end
        if settings.print_to_log then display.log.print(dupes, templates.log) end
    else
        display.box:clear()
        log('No duplicates found. Congratulations!')
    end
end

function update_findall_data(force_update)
    local player = windower.ffxi.get_player()
    local player_name = player and player.name

    local findall_data
    --[[ two states to respond to
        1) display.box is visible
            -- need to update findall_data immediately
        2) display.box is not visible 
            -- when we update this depends on how long get_findall_data() takes and how much it lags the system.
            -- if it's fast then can update it immediately
            -- otherwise we should wait for the next dupefind command
    ]]
    if player_name and force_update or display.box.visible then
        findall_data = get_findall_data(player_name)
        state.findall_data = findall_data
    end
end

-- get offline storages from findAll if available. This code is also lifted almost verbatim from findAll.
function get_findall_data(player_name)
    local findall_data = windower.get_dir(windower.addon_path..'..\\findall\\data')
    local storages = T{}
    if findall_data then
        for _,f in pairs(findall_data) do
            if f:sub(-4) == '.lua' and f:sub(1,-5) ~= player_name then
                local success,result = pcall(dofile,windower.addon_path..'..\\findall\\data\\'..f)
                if success then
                    storages[f:sub(1,-5)] = result
                else
                    warning('Unable to retrieve updated item storage for %s.':format(f:sub(1,-5)))
                end
            end
        end
    end
    state.findall_data_status = 'fresh'
    return storages
end

function list_filters(...)
    -- print a list of filter:names
end

function delete_filter(...)
    -- delete the provided filter
end

function save_filter(filter, ...)
    -- create a new filter or overwrite an existing one.
end

local function eval(args)
    assert(loadstring(table.concat(args, ' ')))()
end

function handle_commands(...)
    local args = T{...}
    if args[1] == 'r' then -- shorthand for easy reloading
        windower.send_command('lua r '.._addon.name)
    elseif T{'eval','e'}:contains(args[1]) then
        args:remove(1)
        eval(args)
    elseif T{'hide','h'}:contains(args[1]) then
        display.box:hide()
    elseif T{'clear','c'}:contains(args[1]) then
        display.box:clear()
    elseif T{'show','s'}:contains(args[1]) then
        display.box:show()
    elseif T{'filter','f'}:contains(args[1]) then
        if T{'list','l'}:contains(args[2]) then
            args:remove(2)
            list_filters(args)
        elseif T{'delete','d','remove','r'}:contains(args[2]) then
            args:remove(2)
            delete_filter(args)
        elseif #args < 3 then
            warning('Invalid filter syntax. Ask for help next time...')
        else
            args:remove(1)
            if T{'save','s','new','n','create','c'}:contains(args[1]) then
                args:remove(1)
            end
            save_filter(args)
        end
    else
        work(...)
    end
end

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
    if id == 0x01D then
        if display.box.active then
            display.box.update()
        end
    end
end)

windower.register_event('load', 'login', init)


windower.register_event('ipc message', function(str)
    if str == 'findAll update' then
        state.findall_data_status = 'stale'
        -- update_findall_data('findall update')
    end
end)

windower.register_event('prerender', function()
    if display.box.active and state.findall_data_status == 'stale' then
        state.findall_data_status = 'processing'
        update_findall_data('findall update')
    end
end)

windower.register_event('logout',function()
    display.box:clear()
    display.last_args = nil
    state.player_name = nil
end)

windower.register_event('addon command',handle_commands)

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end
    if type == 4 and display.box.view:hover(x, y) then
        return true
    elseif type == 5 and display.box.view:hover(x, y) then
        display.box:clear()
        return true
    elseif delta > 0 then
      -- scrolled up
      display.box:doScroll(-1)
    elseif delta < 0 then
      -- scrolled down
      display.box:doScroll(+1)
    end
end)
