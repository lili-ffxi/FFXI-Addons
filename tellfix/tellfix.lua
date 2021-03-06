_addon.name = 'tellfix'
_addon.author = 'Lili'
_addon.version = '1.0.0'

windower.register_event('outgoing chunk',function(id,org,mod,inj,blo)
    if id ~= 0x0B6 or inj then
        return 
    end
    
    return mod:sub(1,0x05) .. mod:sub(0x7,0x15) .. mod:sub(0x16)
end)

windower.register_event('load','login',function()
    if not windower.ffxi.get_info().logged_in then
        return
    end 
    
    windower.add_to_chat(207,'tellfix: TellFix is ENABLED.')
    windower.add_to_chat(207,'tellfix: This is a temporary solution until your private server updated the tell packet.')
    windower.add_to_chat(207,'tellfix: If your recipients are receiving empty or garbage tells from you, try unloading this addon with //lua unload tellfix.')    
end)
