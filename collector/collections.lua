_addon.subversion = '2'

local custom = T{}
if windower.file_exists(windower.addon_path..'custom.lua') then
    custom = require('custom')
end

return T{
    ['reive capes'] = { "Mauler's Mantle", "Anchoret's Mantle", "Mending Cape", "Bane Cape", "Ghostfyre Cape", "Canny Cape", 
                        "Weard Mantle", "Niht Mantle", "Pastoralist's Mantle", "Rhapsode's Cape", "Lutian Cape", "Takaha Mantle", 
                        "Yokaze Mantle", "Updraft Mantle", "Conveyance Cape", "Cornflower Cape", "Gunslinger's Cape", 
                        "Dispersal Mantle", "Toetapper Mantle", "Bookworm's Cape", "Lifestream Cape", "Evasionist's Cape", },
    ['empyrean feet'] = {"Ravager's Calligae","Tantra Gaiters","Orison Duckbills","Goetia Sabots","Estq. Houseaux",
                        "Raider's Poulaines","Creed Sabatons","Bale Sollerets","Ferine Ocreae","Aoidos' Cothurnes",
                        "Sylvan Bottillons","Unkai Sune-Ate","Iga Kyahan","Lncr. Schynbalds","Caller's Pigaches","Mavi Basmak",
                        "Navarch's Bottes","Cirque Scarpe","Charis Toe Shoes","Savant's Loafers"}, -- geo and run cannot be exchanged with Lame Deer
    ['ambuscade weapons'] = {"Karambit", "Tauret", "Naegling", "Nandaka", "Dolichenus", "Lycurgos", "Drepanum", "Shining One", "Gokotai", "Hachimonji", "Maxentius", "Xoanon", "Ullr", "Khonsu", },
    ['pulse weapons'] = {"Sagasinger", "Murasamemaru", "Tenkomaru", "Himthige", "Aytanri", "Adflictio", "Girru", "Gusterion", "Dukkha", "Ephemeron", "Coruscanti", "Asteria", "Borealis", "Ikarigiri", "Delphinius", "Chastisers", "Router", "Annealed Lance", },
    ['mission rewards'] = { "Bastokan Flag", "Windurstian Flag", "San d'Orian Flag", -- rank 10
                            "Abyssal Earring", "Beastly Earring", "Bushinomimi", "Knight's Earring", "Suppanomimi", -- zilart
                            "Dcl.Grd. Ring", "Tavnazian Ring", "Rajas Ring", "Sattva Ring", "Tamas Ring", -- cop
                            "Ethereal Earring", "Hollow Earring", "Magnetic Earring", "Static Earring", -- zilart/cop epilogue
                            "Balrahn's Ring", "Jalzahn's Ring","Ulthalam's Ring","Glory Crown", -- toau
                            "Jeunoan Flag", "Fourth Staff", "Ram Staff", "Cobra Staff", "Moonshade Earring", --wotg
                            "Mirke Wardecors", "Nuevo Coselete", "Royal Redingote", 
                            "Champion's Galea", "Anwig Salade", "Selenian Cap", 
                            "Blitzer Poleyn", "Desultor Tassets", "Tatsu. Sitagoromo",  }, -- addon scenarions
    ['adoulin'] = { "Adoulin's Refuge", "Ygnas's Resolve", "Arciela's Grace", "Adoulin's Refuge +1", "Ygnas's Resolve +1", "Arciela's Grace +1",
                    "Councilor's Cuffs", "Councilor's Garb", 
                    "Adoulin Ring", "Gorney Ring", "Haverton Ring", "Janniston Ring", "Karieyh Ring", "Orvail Ring", 
                    "Renaye Ring", "Shneddick Ring", "Thurandaut Ring", "Vocane Ring", "Weather. Ring", "Woltaris Ring", 
                    "Delegate's Cuffs", "Delegate's Garb", 
                    "Adoulin Ring +1", "Gorney Ring +1", "Haverton Ring +1", "Jann. Ring +1", "Karieyh Ring +1", "Orvail Ring +1", 
                    "Renaye Ring +1", "Shneddick Ring +1", "Thur. Ring +1", "Vocane Ring +1", "Weather. Ring +1", "Woltaris Ring +1",   },
    ['monster mementos'] = { "abyssal wyrm memento", "abyssobugard memento", "adamantoise memento", "adenium memento", "ake-ome memento", 
                             "alabaster lizard memento", "baby adamantoise memento", "baby cockatrice memento", "baby colibri memento", 
                             "baby eft memento", "baby lizard memento", "baby rabbit memento", "baby raptor memento", "behemoth cub memento",
                             "behemoth memento", "blazing wyrm memento", "blue sea monk memento", "blue wyvern memento", "bomb memento", 
                             "buffalo calf memento", "buffalo memento", "bugard memento", "citrullus memento", "clot memento", "cluster memento",
                             "cockatrice memento", "coeurl cub memento", "coeurl memento", "colibri memento", "crab memento", "dhalmel calf memento",
                             "dhalmel memento", "djinn memento", "dragon hatchling memento", "eft memento", "elasmoth memento", 
                             "elder adenium memento", "elder mandragora memento", "ferromantoise memento", "great adamantoise memento", 
                             "great dhalmel memento", "great ferromantoise memento", "green foliage treant memento", "green wyvern memento", 
                             "hecteyes memento", "immature crab memento", "jumbotender memento", "karakul memento", "king behemoth memento", 
                             "korrigan memento", "lamb memento", "limascabra memento", "lizard memento", "lunar wyrm memento", "lycopodium memento",
                             "lynx memento", "mandragora memento", "mandragora sproutling memento", "mini slime memento", "pachypodium memento",
                             "pequetender memento", "porter crab memento", "rabbit memento", "ram memento", "raptor memento", 
                             "red foliage treant memento", "red raptor memento", "sabotender memento", "sapling memento", "sea monk larva memento",
                             "sea monk memento", "sheep memento", "skormoth memento", "slime memento", "snoll memento", "tarichuk memento", 
                             "tiny bugard memento", "toucalibri memento", "uragnite memento", "uragnite youngling memento", 
                             "white adamantoise memento", "white rabbit memento", "wyvern memento", "ziz memento"    },
    ['twilight'] = { "Twilight Cape", "Twilight Knife", "Twilight Scythe", "Twilight Helm", "Twilight Mail", "Twilight Cloak", "Twilight Torque", "Twilight Belt", }, -- twilight set from Shinryu
    ['dynamis currency'] = {"1 Byne Bill", "O. Bronzepiece", "T. Whiteshell", "100 Byne Bill", "M. Silverpiece", "L. Jadeshell", "10,000 Byne Bill", "R. Goldpiece", "R. Stripeshell",},
    ['relic weapons'] = { "Aegis", "Gjallarhorn", "Mandau", "Ragnarok", "Apocalypse", "Annihilator", "Amanomurakumo", "Excalibur", "Yoichinoyumi", "Spharai", "Kikoku", "Bravura", "Gungnir", "Guttler", "Mjollnir", "Claustrum", },
    ['mythic weapons'] = { "Conqueror", "Glanzfaust", "Yagrush", "Laevateinn", "Murgleis", "Vajra", "Burtgang", "Liberator", "Aymur", "Carnwenhan", "Gastraphetes", "Kogarasumaru", "Nagi", "Ryunohige", "Nirvana", "Tizona", "Death Penalty", "Kenkonken", "Terpsichore", "Tupsimati", "Idris", "Epeolatry", },
    ['empyrean weapons'] = { "Verethragna", "Twashtar", "Almace", "Caladbolg", "Farsha", "Ukonvasara", "Redemption", "Rhongomiant", "Kannagi", "Masamune", "Gambanteinn", "Hvergelmir", "Gandiva", "Armageddon", "Daurdabla", "Ochain", },
    ['aeonic weapons'] = { "Godhands", "Aeneas", "Sequence", "Lionheart", "Tri-edge", "Chango", "Anguta", "Trishula", "Heishi Shorinken", "Dojikiri Yasutsuna", "Tishtrya", "Khatvanga", "Fail-Not", "Fomalhaut", "Marsyas", "Srivatsa", },
    ['divergence weapons'] = {"Aram", "Asclepius", "Barfawc", "Bhima", "Crocea Mors", "Draumstafir", "Father Time", "Fudo Masamune", "Fusenaikyo", "Gandring", "Kaumodaki", "Labraunda", "Moralltach", "Morgelai", "Musa", "Pangu", "Rostam", "Sagitta", "Setan Kober", "Sharanga", "Xiucoatl", "Zomorrodnegar"},
    ['divergence necks'] = {"Abyssal Beads +2", "Argute Stole +2", "Asn. Gorget +2", "Bagua Charm +2", "Bard's Charm +2", "Bst. Collar +2", "Clr. Torque +2", "Comm. Charm +2", "Dgn. Collar +2", "Dls. Torque +2", "Etoile Gorget +2", "Futhark Torque +2", "Kgt. Beads +2", "Mirage Stole +2", "Mnk. Nodowa +2", "Ninja Nodowa +2", "Pup. Collar +2", "Sam. Nodowa +2", "Scout's Gorget +2", "Smn. Collar +2", "Src. Stole +2", "War. Beads +2",},
    ['combatant torque'] = { "Combatant's Torque", "Carnal Torque", "Decimus Torque", "Bilious Torque", "Agelast Torque", "Maskirova Torque", "Yarak Torque", "Acantha Torque", },
    ['incanter torque'] = { "Incanter's Torque", "Melic Torque", "Henic Torque", "Deceiver's Torque", },
    ['eschan torques'] = { "Combatant's Torque", "Incanter's Torque", "Carnal Torque", "Decimus Torque", "Bilious Torque", "Agelast Torque", "Maskirova Torque", "Yarak Torque", "Acantha Torque", "Melic Torque", "Henic Torque", "Deceiver's Torque", },
    ['elemental gorgets'] = { "Flame Gorget", "Soil Gorget", "Aqua Gorget", "Breeze Gorget", "Snow Gorget", "Thunder Gorget", "Light Gorget", "Shadow Gorget", "Fotia Gorget",  },
    ['elemental belts'] = { "Flame Belt", "Soil Belt", "Aqua Belt", "Breeze Belt", "Snow Belt", "Thunder Belt", "Light Belt", "Shadow Belt", "Fotia Belt",  },
    ['elemental obi'] = { "Karin Obi", "Dorin Obi", "Suirin Obi", "Furin Obi", "Hyorin Obi", "Rairin Obi", "Korin Obi", "Anrin Obi", "Hachirin-no-Obi", },
    ['sinister reign'] = {  "Himetsuruichimonji", "Humility", "Lengo Pants", "Leyline Gloves",  -- Arciela
                            "Amm Greaves", "Fleshcarvers", "Koresuke", "Ta'lab Trousers",       -- Darrcuiln
                            "Dampening Tam", "Fanatic Gloves", "Malevolence", "Purgation",      -- Ingrid
                            "Rubicundity", "Samnuha Coat", "Samnuha Tights", "Vampirism",       -- Teodor
                            "Brutality", "Ferocity", "Lilitu Headpiece", "Loyalist Sabatons",   -- Morimar
                            "Floral Gauntlets", "Medium's Sabots", "Nobility", "Serenity",      -- Rosulatia
                            "Enticer's Pants", "Ochu", "Taming Sari", "Witching Robe",          -- Arciela
                            "Brilliance", "Divinity", "Jumalik Helm", "Jumalik Mail",           -- Sajj'aka
                            "Founder's Corona", "Found. Breastplate", "Founder's Gauntlets", "Founder's Hose", "Founder's Greaves", -- August
                            },
    ['reisenjima helm'] = { "Firangi", "Freydis", "Gozuki Mezuki", "Hodadenon", "Izcalli", "Lembing", "Misanthropy", "Oranyan", "Sangoma", "Shishio", "Steinthor", "Suwaiyas", "Taka", "Takoba", "Wochowsen",
                            "Ahosi Leggings", "Arjuna Breeches", "Composer's Mitts", "Composer's Sabots", "Iktomi Dastanas", "Ipoca Beret", "Mrigavyadha Gloves", "Navon Crackows", "Nzingha Cuirass", "Sayadio's Kaftan", "Skaoi Boots", "Vedic Coat", "Ynglinga Sallet", },
    ['skirmish stones'] = {
                            "Snowslit Stone", "Snowslit Stone +1", "Snowslit Stone +2",
                            "Snowtip Stone", "Snowtip Stone +1", "Snowtip Stone +2",
                            "Snowdim Stone", "Snowdim Stone +1", "Snowdim Stone +2",
                            "Snoworb Stone", "Snoworb Stone +1", "Snoworb Stone +2",
                            "Leafslit Stone", "Leafslit Stone +1", "Leafslit Stone +2",
                            "Leaftip Stone", "Leaftip Stone +1", "Leaftip Stone +2",
                            "Leafdim Stone", "Leafdim Stone +1", "Leafdim Stone +2",
                            "Leaforb Stone", "Leaforb Stone +1", "Leaforb Stone +2",
                            "Duskslit Stone", "Duskslit Stone +1", "Duskslit Stone +2",
                            "Dusktip Stone", "Dusktip Stone +1", "Dusktip Stone +2",
                            "Duskdim Stone", "Duskdim Stone +1", "Duskdim Stone +2",
                            "Duskorb Stone", "Duskorb Stone +1", "Duskorb Stone +2",    },
    -- HTMBs
    ['htmb key items'] = {"Shadow Lord phantom gem", "Celestial Nexus phantom gem", "Stellar Fulcrum phantom gem", "phantom gem of apathy", "phantom gem of arrogance", "phantom gem of envy", "phantom gem of cowardice", "phantom gem of rage", "P. Perpetrator phantom gem", "Savage's phantom gem", "Warrior's Path phantom gem", "Puppet in Peril phantom gem", "Legacy phantom gem", "Head Wind phantom gem", "avatar phantom gem", "Moonlit Path phantom gem", "Waking the Beast phantom gem", "Waking Dreams phantom gem", "Feared One phantom gem", "Dawn phantom gem", "Stygian Pact phantom gem", "Champion phantom gem", "Divine phantom gem", "Maiden phantom gem", "Wyrm God phantom gem",},
    ['lilith htmb'] = { "Daybreak", "Malignance Pole", "Malignance Sword", "Malignance Earring", "Malignance Chapeau", "Malignance Tabard", "Malignance Gloves", "Malignance Tights", "Malignance Boots",},
    ['odin htmb'] = {"Geirrothr", "Zantetsuken", "Zantetsuken X", "Hjarrandi Helm", "Hjarrandi Breast.", "Freke Ring", "Gere Ring"},
    ['alex htmb'] = {"Sacro Bulwark", "Sacro Breastplate", "Sacro Gorget", "Sacro Cord", "Sacro Mantle",},
    ['shinryu htmb'] = {"Crepuscular Knife", "Crepuscular Pebble", "Crepuscular Scythe", "Crepuscular Helm", "Crepuscular Cloak", "Crepuscular Mail","Crepuscular Ring", "Crepuscular Earring" },
}:update(custom)
