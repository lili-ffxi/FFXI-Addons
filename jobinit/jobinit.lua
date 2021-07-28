_addon.name = 'Job Init'
_addon.author = 'Lili'
_addon.version = '0.0.2'
_addon.commands = {'jobinit','ji'}

require('logger')
files = require('files')
--[[
Syntax

//ji
    addbind|removebind <job> <shortcut> <commands>
]]

-- first run
if not windower.file_exists(windower.addon_path .. 'data/default.txt') then
    local default = [[
//Default settings
//Lines beginning with // are comments.
//Each category has its own syntax, see the examples.

//Lockstyle
1

//Binds
//Both key names and symbols are valid. Examples:
//  NoChat-Alt+R input /tell Selindrile Alt+R is for replies
//  %i send @all /item "Holy Water" <me>
nochat+f12 fps
^i send @whm cure me
shift-a input /p nice

//Aliases
shihei get shihei 99
followall send @all /follow Lili
openmap input /map
closemap setkey escape down;wait .3;setkey escape up

//Commands
//Note: at the moment commands only execute when entering a job, not when leaving it.
get remedy 12
]]
    local f = files.new('data/default.txt', true)
    f:write(default)
end

local player

local commands = {}
commands.action = {  reload='r', bind='b', alias='a', command='c',help='h',jobinit='t' }
commands.operation = { set='add', unset='remove' }

commands.lockstyle = function()
    local cooldown = os.clock()
    local set_number = 0
    local queue
    return function(operation, command)
        if operation == 'unset' then
            return
        elseif operation == 'cooldown' then
            cooldown = command
            return
        else
        end

        if not tonumber(command) then
            log('Invalid Lockstyle provided. Please specify a number.')    
            return
        end

        if cooldown > os.clock() then
            log('Waiting for lockstyle cooldown...')
            commands.lockstyle:schedule(cooldown-os.clock(),'set',command)
            return
        end

        log('Setting lockstyle to',command) 
        windower.chat.input('/lockstyleset '.. command)
    end
end()

commands.binds = function()
    local keydict = {
        ctrl = '%^',
        alt = '%!',
        win = '%@',
        apps = '%#',
        shift = '%~',
        nochat = '%%',
        chatonly = '%$',
    }
    return function(operation, line) 
        local keys, command = line:match("([^%s]+)(.+)")
        
        keys = keys:gsub('[+-]','')
        for i,v in pairs(keydict) do
            keys = keys:gsub(i,v)
        end
        
        if operation == 'set' then
            windower.send_command('bind',keys,command)
        elseif operation == 'unset' then
            windower.send_command('unbind',keys)
        end
    end
end()

commands.aliases = function(operation, line)
    local name, command = line:match("([^%s]+)(.+)")
    
    if operation == 'set' then
        windower.send_command('alias', name, command)
    elseif operation == 'unset' then
        windower.send_command('unalias', name)
    end

end

commands.commands = function(operation, command) 
    if operation == 'unset' then
        return
    end
    
    winower.send_command('command:',command)
end

commands.reload = windower.send_command+{'lua r jobinit'}

-- there's a way better way to do this
commands.help = log+{'Job Init v%s\nSee README.md for instructions.':format(_addon.version)}

local settings = {}

settings.lockstyle = function(line) end
settings.binds = function(line) end
settings.aliases = function(line) end
settings.commands = function(line) end

-- utilities

local log = log or function(...) windower.add_to_chat(207,'Job Init: ' .. ...) end

local get_arg = function(dict,arg)
    local arg = arg and arg:lower() or ''
    for i,v in pairs(commands[dict]) do
        if i == arg or v == arg then
            return i
        end
    end
end

local jobinit = function(op, main_job, sub_job)
    main_job = main_job or player.main_job
    sub_job = sub_job or player.sub_job
    
    -- code below copied and adapted from Yush, for any bugs blame Arcon.
    local file, filename, filepath, err
    local basepath = windower.addon_path .. 'data/'

    for filepath_template in L{
        'name_main_sub.txt',
        'name_main.txt',
        'name.txt',
        'main_sub.txt',
        'main.txt',
        'default.txt',
    }:it() do
        filename = filepath_template:gsub('name', player.name):gsub('main', player.main_job):gsub('sub', player.sub_job or '')
        filepath = basepath .. filename
        if windower.file_exists(filepath) then
            log('Processing',filename)
            file, err = loadfile(filepath)
            break
        end
    end

    commands.parse_settings(op, (not err and file))
end

commands.parse_settings = function(operation, file)
    local operation = operation or 'set'
    local f = file and files.it(file) or files.it('data/default.txt')
    local mode = 'commands'
    
    for line in f do
        line = line:trim():lower()
        local comment = function()
            if line:startswith('//') then
                for i in pairs(settings) do
                    if line:startswith('//' .. i) then
                        mode = i
                    end
                end
                return true
            end
        end()

        if #line > 0 and not comment and settings[mode] then 
            commands[mode](operation, line)
        end
    end
end

-- events

windower.register_event('load','login', function()
    player = windower.ffxi.get_player()
    if player then 
        print('jobinit:','working',player.name,player.main_job,player.sub_job)
        jobinit('set')
    end
end)

windower.register_event('job change', function(main_job_id, main_job_level, sub_job_id, sub_job_level)
    jobinit('unset')
    player = windower.ffxi.get_player()
    jobinit:schedule(3,'set')
end)

windower.register_event('unload','logout', function(name)
    jobinit('unset')
end)

windower.register_event('addon command',function(...)
    local args = {...}
    local action = args[1] and get_arg('action',args[1]) or 'help'
    local operation = get_arg('operation',args[2])
    
    log(action .. ' ' .. (operation or ''))

    if commands[action] then
        commands[action](operation)
    end
end)

windower.register_event('outgoing chunk',function(id)
    if id == 0x053 then
        commands.lockstyle('cooldown',os.clock() +10)
    end
end)
