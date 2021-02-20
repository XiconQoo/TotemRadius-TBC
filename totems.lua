

core.spawnDistance = 3 --Totems spawn 3 yards away from you.


--[[math.deg(GetPlayerFacing())
	North	= 0/360
	NE		= 315
	East	= 270
	SE		= 225
	South	= 180
	SW		= 135
	West	= 90
	NW		= 45
]]

core.totemHeadings = {--Headings of where totems spawn relative to your characters direction.
	[1] = 45,	--#1 = 45deg (NW)	fire
	[2] = 315,	--#2 = 315deg (NE)	earth
	[3] = 225,	--#3 = 225deg (SE)	water
	[4] = 135,	--#4 = 135deg (SW)	air
}

core.totemInfo = {
	--[[[string.lower(select(1, GetSpellInfo(3599)))] = totemData[string.lower("Searing Totem")], -- Searing Totem
	[string.lower(select(1, GetSpellInfo(8227)))] = totemData[string.lower("Flametongue Totem")], -- Flametongue Totem
	[string.lower(select(1, GetSpellInfo(8190)))] = totemData[string.lower("Magma Totem")], -- Magma Totem
	[string.lower(select(1, GetSpellInfo(1535)))] = totemData[string.lower("Fire Nova Totem")], -- Fire Nova Totem
	[string.lower(select(1, GetSpellInfo(30706)))] = totemData[string.lower("Totem of Wrath")], -- Totem of Wrath
	[string.lower(select(1, GetSpellInfo(32982)))] = totemData[string.lower("Fire Elemental Totem")], -- Fire Elemental Totem
	[string.lower(select(1, GetSpellInfo(8181)))] = totemData[string.lower("Frost Resistance Totem")], -- Frost Resistance Totem
	-- Water
	[string.lower(select(1, GetSpellInfo(8184)))] = totemData[string.lower("Fire Resistance Totem")], -- Fire Resistance Totem
	[string.lower(select(1, GetSpellInfo(8166)))] = totemData[string.lower("Poison Cleansing Totem")], -- Poison Cleansing Totem
	[string.lower(select(1, GetSpellInfo(8170)))] = totemData[string.lower("Disease Cleansing Totem")], -- Disease Cleansing Totem
	[string.lower(select(1, GetSpellInfo(5394)))] = totemData[string.lower("Healing Stream Totem")], -- Healing Stream Totem
	[string.lower(select(1, GetSpellInfo(16190)))] = totemData[string.lower("Mana Tide Totem")], -- Mana Tide Totem
	[string.lower(select(1, GetSpellInfo(5675)))] = totemData[string.lower("Mana Spring Totem")], -- Mana Spring Totem
	-- Earth
	[string.lower(select(1, GetSpellInfo(2484)))] = totemData[string.lower("Earthbind Totem")], -- Earthbind Totem
	[string.lower(select(1, GetSpellInfo(5730)))] = totemData[string.lower("Stoneclaw Totem")], -- Stoneclaw Totem
	[string.lower(select(1, GetSpellInfo(8071)))] = totemData[string.lower("Stoneskin Totem")], -- Stoneskin Totem
	[string.lower(select(1, GetSpellInfo(8075)))] = totemData[string.lower("Strength of Earth Totem")], -- Strength of Earth Totem
	[string.lower(select(1, GetSpellInfo(33663)))] = totemData[string.lower("Earth Elemental Totem")], -- Earth Elemental Totem
	[string.lower(select(1, GetSpellInfo(8143)))] = totemData[string.lower("Tremor Totem")], -- Tremor Totem
	-- Air
	[string.lower(select(1, GetSpellInfo(8177)))] = totemData[string.lower("Grounding Totem")], -- Grounding Totem
	[string.lower(select(1, GetSpellInfo(8835)))] = totemData[string.lower("Grace of Air Totem")], -- Grace of Air Totem
	[string.lower(select(1, GetSpellInfo(10595)))] = totemData[string.lower("Nature Resistance Totem")], -- Nature Resistance Totem
	[string.lower(select(1, GetSpellInfo(8512)))] = totemData[string.lower("Windfury Totem")], -- Windfury Totem
	[string.lower(select(1, GetSpellInfo(6495)))] = totemData[string.lower("Sentry Totem")], -- Sentry Totem
	[string.lower(select(1, GetSpellInfo(15107)))] = totemData[string.lower("Windwall Totem")], -- Windwall Totem
	[string.lower(select(1, GetSpellInfo(3738)))] = totemData[string.lower("Wrath of Air Totem")], -- Wrath of Air Totem
	[string.lower(select(1, GetSpellInfo(25908)))] = totemData[string.lower("Tranquil Air Totem")], -- Tranquil Air Totem
	[2484] = {duration=45, range=10, slot=2, texture="Interface\\Icons\\Spell_nature_earthbindtotem"}, --Earthbind Totem

	--]]

	[8071] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"}, --Stoneskin Totem
	[8154] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	[8155] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	[10406] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	[10407] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	[10408] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	[25508] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	[25509] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	--[58751] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	--[58753] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_stoneskintotem"},
	
	[5730] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"}, --Stoneclaw Totem
	[6390] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	[6391] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	[6392] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	[10427] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	[10428] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	[25525] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	--[58580] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	--[58581] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},
	--[58582] = {duration=15, range=8, slot=2, texture="Interface\\Icons\\spell_nature_stoneclawtotem"},

	[8075] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"}, --Strength of Earth Totem
	[8160] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},
	[8161] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},
	[10442] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},
	[25361] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},
	[25528] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},
	--[57622] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},
	--[58643] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_strengthofearthtotem02"},

	[8143] = {duration=60*5, range=30, slot=2, texture="Interface\\Icons\\spell_nature_tremortotem"}, --Tremor Totem
	
	[2062] = {duration=60*2, range=0, slot=2, texture="Interface\\Icons\\Spell_nature_earthelemental_totem"}, --Earth Elemental Totem
	
	[3599] = {duration=30, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"}, --Searing Totem
	[6363] = {duration=35, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	[6364] = {duration=40, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	[6365] = {duration=45, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	[10437] = {duration=50, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	[10438] = {duration=55, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	[25533] = {duration=60, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	--[58699] = {duration=60, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	--[58703] = {duration=60, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},
	--[58704] = {duration=60, range=20, slot=1, texture="Interface\\Icons\\Spell_fire_searingtotem"},

	[8190] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"}, --Magma Totem
	[10585] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"},
	[10586] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"},
	[10587] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"},
	[25552] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"},
	--[58731] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"},
	--[58734] = {duration=21, range=8, slot=1, texture="Interface\\Icons\\Spell_fire_selfdestruct"},
	
	[8181] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_fire_frostresistancetotem"}, --Frost Resistance Totem
	[10478] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_fire_frostresistancetotem"},
	[10479] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_fire_frostresistancetotem"},
	[25560] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_fire_frostresistancetotem"},
	--[58741] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_fire_frostresistancetotem"},
	--[58745] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_fire_frostresistancetotem"},

	[8227] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"}, --Flametongue Totem
	[8249] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},
	[10526] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},
	[16387] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},
	[25557] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},
	--[58649] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},
	--[58652] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},
	--[58656] = {duration=60*5, range=30, slot=1, texture="Interface\\Icons\\Spell_nature_guardianward"},

	[30706] = {duration=60*5, range=40, slot=1, texture="Interface\\Icons\\Spell_fire_totemofwrath"}, --Totem of Wrath
	--[57720] = {duration=60*5, range=40, slot=1, texture="Interface\\Icons\\Spell_fire_totemofwrath"},
	--[57721] = {duration=60*5, range=40, slot=1, texture="Interface\\Icons\\Spell_fire_totemofwrath"},
	--[57722] = {duration=60*5, range=40, slot=1, texture="Interface\\Icons\\Spell_fire_totemofwrath"},
	
	[2894] = {duration=60*2, range=0, slot=1, texture="Interface\\Icons\\Spell_Fire_Elemental_Totem"}, --Fire Elemental Totem
	
	[5394] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"}, --Healing Stream Totem
	[6375] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	[6377] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	[10462] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	[10463] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	[25567] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	--[58755] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	--[58756] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},
	--[58757] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Inv_spear_04"},

	[5675] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"}, --Mana Spring Totem
	[10495] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},
	[10496] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},
	[10497] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},
	[25570] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},
	--[58771] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},
	--[58773] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},
	--[58774] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_nature_manaregentotem"},

	[8170] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\spell_nature_diseasecleansingtotem"}, --Cleansing Totem
	
	[16190] = {duration=12, range=30, slot=3, texture="Spell_frost_summonwaterelemental"}, --Mana Tide Totem
	
	[8184] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_fireresistancetotem"},--Fire Resistance Totem
	[10537] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_fireresistancetotem"},
	[10538] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_fireresistancetotem"},
	[25563] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_fireresistancetotem"},
	--[58737] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_fireresistancetotem"},
	--[58739] = {duration=60*5, range=30, slot=3, texture="Interface\\Icons\\Spell_fireresistancetotem"},

	[8512] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\Spell_nature_windfury"},--Windfury Totem *
	
	[8177] = {duration=45, range=20, slot=4, texture="Interface\\Icons\\Spell_nature_groundingtotem"}, --Grounding Totem
	
	[6495] = {duration=60*5, range=0, slot=4, texture="Interface\\Icons\\Spell_nature_removecurse"}, --Sentry Totem
	
	[10595] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_natureresistancetotem"}, --Nature Resistance Totem
	[10600] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_natureresistancetotem"},
	[10601] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_natureresistancetotem"},
	[25574] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_natureresistancetotem"},
	--[58746] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_natureresistancetotem"},
	--[58749] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_natureresistancetotem"},

	[3738] = {duration=60*5, range=30, slot=4, texture="Interface\\Icons\\spell_nature_wrathofair_totem"}, --Wrath of Air Totem
	
}

--[[show  1=raid, 2=party, 3=mine, 4=never]]
core.totemList = {
	[2484] = 3, --Earthbind Totem
	[8143] = 2, --Tremor Totem
	[8177] = 2, --Grounding Totem
	[8512] = 1, --Windfury Totem
	[6495] = 3, --Sentry Totem
	[8170] = 2, --Cleansing Totem
	[3738] = 1, --Wrath of Air Totem
	[2062] = 4, --Earth Elemental Totem
	[2894] = 4, --Fire Elemental Totem
	[25552] = 3, --Magma Totem
	[25525] = 3, --Stoneclaw Totem
	[25509] = 1, --Stoneskin Totem
	[25563] = 1, --Fire Resistance Totem
	[25557] = 1, --Flametongue Totem
	[25560] = 1, --Frost Resistance Totem
	[25567] = 2, --Healing Stream Totem
	[25570] = 1, --Mana Spring Totem
	[25574] = 1, --Nature Resistance Totem
	[25533] = 3, --Searing Totem
	[25528] = 1, --Strength of Earth Totem
	[30706] = 1, --Totem of Wrath
}

core.fireNovaTotemIDs = {
	[25557] = false, --Flametongue Totem
	[25552] = true, --Magma Totem
	[25560] = false, --Frost Resistance Totem
	[25533] = true, --Searing Totem
	[30706] = false, --Totem of Wrath
}