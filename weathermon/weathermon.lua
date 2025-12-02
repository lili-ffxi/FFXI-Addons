_addon.name = 'Weathermon'
_addon.author = 'Lili'
_addon.version = '0.1.0'

texts = require('texts')
config = require('config')
packets = require('packets')

require('tables')
require('logger')

local days = require('resources').days
local weathers = require('resources').weather
local elements = require('resources').elements

storms = {
    [178] = 4, [179] = 12, [180] = 10, [181] = 8, [182] = 14, [183] = 6, [184] = 16, [185] = 18,
    [589] = 5, [590] = 13, [591] = 11, [592] = 9, [593] = 15, [594] = 7, [595] = 17, [596] = 19
}

local default = {}
default.text_box_settings = {
    pos = {x = 25, y = 120,},
    bg = { visible = false},
    text = {
        size = 12,
        font = 'MS Gothic',
        bold = true,
        italic = true,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = { 
            width = 1,
            alpha = 0x33,
            red = 0,
            green = 0,
            blue = 0,
        },
    }
}

default.box_string = '${day} - ${intensity}${element} (${weather})'

local settings = config.load(default)

local box = texts.new(settings.box_string, settings.text_box_settings)


function update_weather(id)

    local day = days[windower.ffxi.get_info().day].name

    local weather_id = id or windower.ffxi.get_info().weather
    local weather = weathers[weather_id].name

    local player = windower.ffxi.get_player()
    if player then 
      for i,v in pairs(player.buffs) do
          if storms[v] then
              weather_id = storms[v]
              weather = 'Storm'
          end
      end
    end

    local element = elements[weathers[weather_id].element].name
    local intensity = weathers[weather_id].intensity

    box.day = day
    box.weather = weather
    box.element = (intensity > 1 and 'Double ' or '') .. element
end

update_weather()

windower.register_event('prerender',function()
    local info = windower.ffxi.get_info()
    if not info.logged_in then 
        return
    end
    
    if info.menu_open then
        box:hide()
    else
        box:show()
    end
end)

windower.register_event('weather change','day change', function(id)
    update_weather()
end)

windower.register_event('gain buff','lose buff',function(id)
    if not storms[id] then
        return
    end
    update_weather()
end)
