_addon.name = 'Witness Protection'
_addon.version = '0.1.1'
_addon.author = 'Lili'
_addon.command = 'wit'

require('logger')
require('strings')
require('pack')
local extdata = require('extdata')
local packets = require('packets')

packets.raw_fields.incoming[0x009] = L{
    {ctype='data[17]',              label='_dummy1'},                                   -- 70
    {ctype='char*',                 label='Name'},                                      -- 74
}

local filtered_packets = {
    [0x00A] = {['name_field'] = 'Player Name',      ['id_field'] = 'Player',        },
    [0x00D] = {['name_field'] = 'Character Name',   ['id_field'] = 'Player',        },
    [0x0DD] = {['name_field'] = 'Name',             ['id_field'] = 'ID',            },

    [0x009] = {['name_field'] = 'Name',             ['id_field'] = false,           }, -- Check notifications and a lots other things.
    [0x027] = {['name_field'] = 'Player Name',      ['id_field'] = 'Player',        },
    [0x017] = {['name_field'] = 'Sender Name',      ['id_field'] = false,           },    
    [0x070] = {['name_field'] = 'Player Name',      ['id_field'] = false,           }, -- Synthesis, untested    
    [0x078] = {['name_field'] = 'Proposer Name',    ['id_field'] = 'Proposer ID',   },
    [0x079] = {['name_field'] = 'Proposer Name',    ['id_field'] = false,           },
    [0x0B6] = {['name_field'] = 'Target Name',      ['id_field'] = false,           },    
    [0x0CA] = {['name_field'] = 'Player Name',      ['id_field'] = false,           },
    [0x0CC] = {['name_field'] = 'Player Name',      ['id_field'] = false,           },
    [0x0DC] = {['name_field'] = 'Inviter Name',     ['id_field'] = false,           },
    --[0x0E2] = {['name_field'] = 'Name',             ['id_field'] = 'ID',            }, -- Seems unnecessary
    [0x106] = {['name_field'] = 'Name',             ['id_field'] = false,           },
    [0x107] = {['name_field'] = 'Name',             ['id_field'] = false,           },
    [0x108] = {['name_field'] = 'Name',             ['id_field'] = 'ID',            },
    [0x109] = {['name_field'] = 'Buyer Name',       ['id_field'] = 'Buyer ID',      },
    [0x10A] = {['name_field'] = 'Buyer Name',       ['id_field'] = false,           },    
}

local ls_enc = {
    charset = T('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ':split()):update({
        [0] = '`',
        [60] = 0:char(),
        [63] = 0:char(),
    }),
    bits = 6,
    terminator = function(str)
        return (#str % 4 == 2 and 60 or 63):binary()
    end
}

local name_cache = { -- Can put in here any default renaming you want
    ['Example'] = 'Elpmaxe',
}
local anon_cache = {}
local reverse_cache = {}
local linkshell_cache = {}

math.randomseed(os.time())
math.random();
math.random:loop(0.1,math.random(1,5))

syllabize = function()
    local     vowels = { 'a', 'e', 'i', 'o', 'u'}
    local consonants = { 'b', 'd', 'g', 'h', 'j', 'k', 'm', 'n', 'r', 's', 't', 'w', 'z' }
    local cypher = {}    
    local s = S{}
    local i = 0
    repeat
        local k = consonants[math.random(1,#consonants)] .. vowels[math.random(1,#vowels)]
        if not s[k] then 
            s:add(k)
            cypher['%X':format(i)] = k
            i = i+1
        end
    until i > 15
    
    return function (number)
        local number = '%X':format(number)
        local r = ''
        for i = #number,1,-1 do
            r = r..cypher[number:sub(i,i)]
        end
        return r
    end
end()

random_ls_color = function()
    return math.random(0,15), math.random(0,15), math.random(0,15)
end

random_ls_name = function()
    local    colors = { 'Yellow', 'Green', 'Purple', 'Rose', 'Azure', 'Red', 'Violet', 'Blue', 
                        'Alabaster', 'Amber', 'Black', 'Bronze', 'Carmine', 'Charcoal', 'Copper', 'Crimson', 'Desert', 
                        'Emerald', 'Iron', 'Heliotrope', 'Honeydew', 'Iceberg', 'Indigo', 'Ivory', 
                        'Lemon', 'Liberty', 'Lilac', 'Mauve', 'Mint', 'Peachy', 'Platinum', 'Saffron', 'Shamrock', --'Opaline',
                        'Snow', 'Teal', 'Tomato', 'Vanilla', 'Xanthic', 'PolkaDot', 'Rainbow', 
                        'Lime', 'Golden', 'Cerise', 'Pink', 'Bicolor', 'Scarlet', 'Blonde', 'Evergreen', }
    local   animals = { 'Rats', 'Oxen', 'Tigers', 'Rabbits', 'Dragons', 'Snakes', 'Horses', 'Goats', 'Monkeys', 'Roosters', 'Dogs', 'Pigs',
                        'Antelopes', 'Deer', 'Salmons', 'Cats', 'Spiders', 'Bats', 'Bugbears', }
    return function()
        local name
        repeat
            name = colors[math.random(1,#colors)] .. animals[math.random(1,#animals)]
        until #name < 20 and not reverse_cache[name]
        return name
    end
end()

function names(original_name,id) -- this is ugly and needs rewritten
    
    if not name_cache[original_name] then
        if id and filtered_packets[id].id_field then
            local id = p[filtered_packets[id].id_field]
            local l = #original_name
            local max_len = l+3-(l-1)%4
            new_name = syllabize(id):sub(1,max_len):gsub("^%l", string.upper)
            name_cache[original_name] = new_name
            reverse_cache[new_name] = original_name            
        elseif not anon_cache[original_name] then
            new_name = 'Anon'
            repeat
                for i = 1,#original_name-4 do
                    new_name = new_name .. string.char(math.random(97,122))
                end
            until not reverse_cache[new_name]
            anon_cache[original_name] = new_name
            reverse_cache[new_name] = original_name            
        end
    end

    return name_cache[original_name] or anon_cache[original_name] or original_name
end

function ls_names(name)
    name = name:gsub('%W','') 
    
    if not linkshell_cache[name] then 
        linkshell_cache[name] = random_ls_name()
    end

    return linkshell_cache[name]
end

function ls_colors(r, g, b) -- this is also ugly but I'm sleepy
    local m = r < 16 and function(n) return n end or function(n) return n*13+56 end
    
    local color = r > 15 and r..g..b or r*13+56 .. g*13+56 .. b*13+56
    
    if not linkshell_cache[color] then
        linkshell_cache[color] = {random_ls_color()}
    end
    
    return m(linkshell_cache[color][1]), m(linkshell_cache[color][2]), m(linkshell_cache[color][3])
end

windower.register_event('incoming chunk',function(id, original, modified, injected, blocked)
    if filtered_packets[id] then
        local updated = false
        p = packets.parse('incoming',original)    

        --[[ 
        -- blocks everybody else from spawning entirely lol
        -- pets still appear 
        if id == 0x00D and p.Player ~= windower.ffxi.get_player().id then
            return true
        end]]

        if id == 0x00D then
            if p['Update Vitals'] then
                p['Linkshell Red'], p['Linkshell Blue'], p['Linkshell Green'] = ls_colors(p['Linkshell Red'], p['Linkshell Blue'], p['Linkshell Green'])
                --updated = true
            end

            if not p['Update Name'] then
                if p['Update Vitals'] then
                    return packets.build(p)
                else
                    return false
                end
            end
        end

        if id == 0x0CC then
            p['Message'] = 'Nothing to see here. Move along!'
            p['Linkshell'] = ls_names(p['Linkshell'])
            --updated = true
        end
        
        local name_field = filtered_packets[id].name_field
        local original_name = p[name_field]
        
        if not original_name or #original_name < 3 then return false end
   
        p[name_field] = names(original_name,id)
        
        return(packets.build(p))
    end

    -- player update. 
    if id == 0x037 then
        p = packets.parse('incoming',original)
        if p['LS Color Red'] then
            p['LS Color Red'], p['LS Color Green'], p['LS Color Blue'] = ls_colors(p['LS Color Red'], p['LS Color Green'], p['LS Color Blue'])
        end
        return(packets.build(p))
    end

    -- /check results.
    if id == 0x0C9 then
        p = packets.parse('incoming',original)
        if p['Linkshell Green'] then
            p['Linkshell Red'], p['Linkshell Blue'], p['Linkshell Green'] = ls_colors(p['Linkshell Red'], p['Linkshell Blue'], p['Linkshell Green'])
        end
        if p['Linkshell'] then
            p['Linkshell'] = ls_names(p['Linkshell'])
        end
        return(packets.build(p))
    end
    
    -- inventory update
    if id == 0x020 then
        p = packets.parse('incoming', original)
        if p.Item >= 513 and p.Item <= 528 then -- linkshell/pearlsack/linkpearl
            p.extdata = p.ExtData
            p.id = p.Item
            local data = extdata.decode(p)
            if data.status_id ~= 0 then
                local name = ls_names(data.name)
                local encoded_name = name:encode(ls_enc)
                local r, g, b = ls_colors(data.r/17, data.g/17, data.b/17)
                p.ExtData = p.extdata:sub(0,6)..'b4b4b4b4':pack(r, g, b, p.extdata:unpack('b8', 8, 4))..p.extdata:sub(9,9)..encoded_name
                return packets.build(p)
            end
        end
        return
    end
end)
windower.register_event('outgoing chunk',function(id, original, modified, injected, blocked)
    if id == 0x0B6 then
        p = packets.parse('outgoing',original)
        if reverse_cache[p['Target Name']] then
            p['Target Name'] = reverse_cache[p['Target Name']]
        end
        return(packets.build(p))
    end    
end)

function print_cache()
    log('Name cache:')
    table.vprint(name_cache)
    log('Anon cache:')
    table.vprint(anon_cache)
    log('Reverse cache:')
    table.vprint(reverse_cache)
    log('Linkshell cache:')
    table.vprint(linkshell_cache)
end

windower.register_event('addon command',function(cmd)
    if cmd == 'r' then
        windower.send_command('lua r witnessprotection')
    elseif cmd == 'u' then
        windower.send_command('lua u witnessprotection')
    else
        print_cache()
    end
end)

windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        warning('Please zone at least once after loading, or anonymization might be incomplete.')
    end
end)

-- couple utility functions for debugging and testing, leaving these in for now

function dec2base (n, base)
    local result, digit = ""
    while n > 0 do
        digit = n % base
        if digit > 9 then digit = string.char(digit + 87) end
        n = math.floor(n / base)
        result = digit .. result
    end
    return result
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function shuffle(str)
   local letters = {}
   for letter in str:gmatch'.[\128-\191]*' do
      table.insert(letters, {letter = letter, rnd = math.random()})
   end
   table.sort(letters, function(a, b) return a.rnd < b.rnd end)
   for i, v in ipairs(letters) do letters[i] = v.letter end
   return table.concat(letters)
end
