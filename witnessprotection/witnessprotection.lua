_addon.name = 'Witness Protection'
_addon.version = '0.0.8'
_addon.author = 'Lili'
_addon.command = 'wit'

require('logger')
packets = require('packets')

debugging = false

function dbg(...)
	if debugging then log(...) end
end

local fields = {
	[0x00A] = {['name_key'] = 'Player Name',	has_id = true,	['id_key'] = 'Player'		},
	[0x00D] = {['name_key'] = 'Character Name',	has_id = true,	['id_key'] = 'Player'		},
	[0x0DD] = {['name_key'] = 'Name', 			has_id = true,	['id_key'] = 'ID'			},

	[0x027] = {['name_key'] = 'Player Name',	has_id = true,	['id_key'] = 'Player'		},
	[0x017] = {['name_key'] = 'Sender Name',	has_id = false,								},	
	[0x0B6] = {['name_key'] = 'Target Name',	has_id = false,								},
	[0x078] = {['name_key'] = 'Proposer Name',	has_id = true,	['id_key'] = 'Proposer ID'	},
	[0x079] = {['name_key'] = 'Proposer Name',	has_id = false,								},
	[0x0CA] = {['name_key'] = 'Player Name',	has_id = false,								},
	[0x0CC] = {['name_key'] = 'Player Name',	has_id = false,								},
	[0x0DC] = {['name_key'] = 'Inviter Name',	has_id = false,								},
	--[0x0E2] = {['name_key'] = 'Name',			has_id = true,	['id_key'] = 'ID'			}, -- Seems unnecessary
	[0x106] = {['name_key'] = 'Name',			has_id = false								},
	[0x107] = {['name_key'] = 'Name',			has_id = false								},
	[0x108] = {['name_key'] = 'Name',			has_id = true,	['id_key'] = 'ID'			},
	[0x109] = {['name_key'] = 'Buyer Name',		has_id = true,	['id_key'] = 'Buyer ID'		},
	[0x10A] = {['name_key'] = 'Buyer Name',		has_id = false								},	
	--[0x070] = {['name_key'] = 'Player Name'	has_id = false, }--Untested
}

local name_cache = { -- Can put in here any default renaming you want
	['Example'] = 'Elpmaxe',
}
local anon_cache = {}
local reverse_cache = {}

-- Get some better randomness for this session
math.randomseed(os.time())
math.random();
math.random:loop(0.1,math.random(1,5))

-- Can have fun in here. Add or remove consonants, switch things around, etc
local vowels = {'a','e','i','o','u'}
local consonants = {'b','d','g','h','j','k','l','m','n','r','s','t','w','z',}
local cypher = {}

for i = 0,15 do -- makes a syllabe for each hex digit 0-F
	cypher['%X':format(i)] = consonants[math.random(1,#consonants)] .. vowels[math.random(1,#vowels)]
end

function syllabize(number)
	local number = '%X':format(number)
	dbg(number)
	local r = ''
	for i = #number,1,-1 do
		r = r..cypher[number:sub(i,i)]
	end
	return r
end

windower.register_event('incoming chunk',function(id, original, modified, injected, blocked)
	--[[if id == 0x0E2 then 
		p = packets.parse('incoming',original)
		print(p.Name)
		dbg(#p.Name)
		local asd = {p.Name:byte(1,#p.Name)}
		for i,v in pairs(asd) do
			dbg(i,v)
		end
	end]]
	if fields[id] then
		p = packets.parse('incoming',original)	
		
		if id == 0x00D and not p['Update Name'] then return end

		local name_key = fields[id].name_key
		local original_name = p[name_key]

		if #original_name < 3 then return end
		
		if name_cache[original_name] then
			new_name = name_cache[original_name]
		elseif fields[id].has_id then
			local index = p[fields[id].id_key]
			new_name = syllabize(index):gsub("^%l", string.upper)
			name_cache[original_name] = new_name
			reverse_cache[new_name] = original_name
			dbg('%03X':format(id),'New:',original_name,new_name)
		elseif anon_cache[original_name] then
			new_name = anon_cache[original_name]
		else
			new_name = 'Anon'..math.random(111,999)
			anon_cache[original_name] = new_name
			reverse_cache[new_name] = original_name
			dbg('%03X':format(id),'New anon:',original_name,new_name)				
		end
		dbg('%03X':format(id),original_name,new_name)
		p[name_key] = new_name
		return(packets.build(p))
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
end

windower.register_event('addon command',function()
	print_cache()
end)
