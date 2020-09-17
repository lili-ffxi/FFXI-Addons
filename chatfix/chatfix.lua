_addon.name = 'chatfix'
_addon.author = 'Lili'
_addon.version = '1.0.0'

windower.register_event('incoming chunk',function(id,org,mod,inj,blo)
    if id ~= 0x017 or inj then
        return
    end
    
    return mod:sub(1,0x16) .. mod:sub(0x18) .. string.byte(0)
end)

windower.register_event('load','login',function()
    if not windower.ffxi.get_info().logged_in then
        return
    end
    
    windower.add_to_chat(207,'chatfix: ChatFix is ENABLED.')
    windower.add_to_chat(207,'chatfix: This is a temporary solution until your private server updated the chat packet.')
    windower.add_to_chat(207,'chatfix: If you\'re receiving empty chat lines, try unloading this addon with //lua unload chatfix.')
end)
