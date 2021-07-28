_addon.name = 'kaomoji'
_addon.author = 'Lili'
_addon.version = '1.0.0'
_addon.command = 'kao'

local commands = {
    ['shrug'] = '¯\\\\\_(ツ)_/¯', -- less than 4 backslashes and the backslash doesn't appear at all
    ['tableflip'] = '(ノ°□°）ノ彡 ┻━┻', -- sadly ︵ doesn't show up
    ['personflip'] = '(ノ°Д°）ノ彡/(.□ . )',
    ['unflip'] = '┬─┬ ノ( ゜-゜ノ)',
    --['effu'] = '凸ಠ益ಠ)凸', --cba finding proper characters for this one
}

function log(...)
    local str = table.concat(arg,' ')
    windower.add_to_chat(207,str)
end

windower.register_event('unhandled command',function(cmd,...)
    if commands[cmd] then
        message = arg[1] and (table.concat(arg,' ') .. ' ') or ''
        windower.chat.input(message .. windower.to_shift_jis(commands[cmd]))
    end
end)

windower.register_event('addon command',function(cmd)
    if cmd == 'r' then
        windower.send_command('lua r kaomoji')
        return
    end

    log('Available:')
    for i,v in pairs(commands) do
        local command,kaomoji = ' //' .. i .. ':', windower.to_shift_jis(v)
        log(command,kaomoji)
    end
end)
