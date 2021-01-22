_addon.name = 'menufix'
_addon.author = 'Lili'
_addon.version = '1.0.0'

windower.register_event('incoming chunk',function(id,org,mod,inj,blo)
    if id ~= 0x01B or inj then
        return 
    end

    return mod..string.char(0,0,0,0)
end)

windower.register_event('load','login',function()
    if not windower.ffxi.get_info().logged_in then
        return
    end 
    
    windower.add_to_chat(207,'menufix: MenuFix is ENABLED.')
    windower.add_to_chat(207,'menufix: This is a temporary solution until your private server updated the Job Info packet.')
    windower.add_to_chat(207,'menufix: Please report to GitHub if you\'re still experiencing crashes.')    
end)