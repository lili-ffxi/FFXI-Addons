_addon.name = 'Mousehalo'
_addon.version = '0.1.0'
_addon.author = 'Lili'
_addon.command = 'mousehalo'

require('logger')
local texts = require('texts')
local config = require('config')

local default = {
    style = 'text', -- currently unused
    image = nil, -- currently unused
    text = '<-mouse',
    delay = 2,
    offset = { x = 20, y = -(64*3/4)},
    text_box_settings = {
        pos = {x = 0, y = 0,},
        bg = {
            alpha = 255, red = 0,green = 0, blue = 0,
            visible = false
        },
        flags = { right = false, bottom = false, bold = false, italic = false },
        padding = 0,
        text = {
            size = 64, font = 'Consolas', fonts = {},
            alpha = 255, red = 255, green = 255, blue = 255,
            stroke = { width = 2 }
        }
    }
}

local settings = config.load(default)

local mouse = {x=0, y=0}


box = texts.new(settings.text,settings.text_box_settings)
box.content = ''

windower.register_event('mouse',function(type,x,y,delta,blocked)
    if type == 0 then
        mouse.x = x
        mouse.y = y
    end
end)

windower.register_event('prerender',function() 
    local delta = { x = mouse.x, y = mouse.y, t = os.clock() }    
    return function()
        if delta.x ~= mouse.x and delta.y ~= mouse.y then
            delta = { x = mouse.x, y = mouse.y, t = os.clock() }
            box:pos(mouse.x + settings.offset.x,mouse.y + settings.offset.y)
            box:show()
        elseif os.clock() - delta.t > settings.delay then
            box:hide()
        end
    end
end())

windower.register_event('addon command', function(...)
    local args = {...}
    local cmd = args[1]:lower()
    
    if cmd == 'delay' then
        if not tonumber(args[2]) then
            error('Delay must be a number.')
            return
        end
        settings.delay = tonumber(args[2])
        config.save(settings,'all')
        windower.add_to_chat(207,'Mousehalo: Delay set to %s seconds':format(settings.delay))
    elseif cmd == 'offset' then
        if not (tonumber(args[2]) and tonumber(args[3])) then
            error('Offsets must be two numbers (x value, y value).')
            return
        end
        settings.offset.x = tonumber(args[2])
        settings.offset.y = tonumber(args[3])
        config.save(settings,'all')
        windower.add_to_chat(207,'Mousehalo: Offsets set to %s, %s pixels.':format(settings.offset.x,settings.offset.y))        
    end
end)
