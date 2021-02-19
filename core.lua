

local LibStub = LibStub
local Debug
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local GetTotemInfo = GetTotemInfo
local pairs = pairs
local IsInInstance = IsInInstance
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local select = select
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local GetUnitName = GetUnitName
local GetSpellInfo = GetSpellInfo
local UnitIsUnit = UnitIsUnit
local GetPlayerMapPosition = GetPlayerMapPosition
local GetTime = GetTime
local GetCurrentMapContinent = GetCurrentMapContinent
local GetCurrentMapZone = GetCurrentMapZone
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local _ --so FindGloabls doesn't nag me.

core.title		= "TotemRadius"
core.version	= ""
core.titleFull	= core.title.." "..core.version
core.addonDir = "Interface\\AddOns\\"..folder.."\\"

local timerFrame = CreateFrame("Frame")
LibStub("AceAddon-3.0"):NewAddon(core, folder, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0") 

core.L = LibStub("AceLocale-3.0"):GetLocale(folder, true)
local L = core.L

local commPrefixTotemLoc	= "TR_L"--New totem info
local commPrefixRemoveTotem	= "TR_K"--Remove totem.

core.userName = userName
local timers = {}

local db
local P --db.profile

local defaultSettings = {
	profile = {
		totemColour= {},
		totemOpts = {},
	},
}
local activeTotems = {}
local activeCasters = {} --shaman who've cast totems.
local totemInfo

core.defaultSettings = defaultSettings
core.activeTotems = activeTotems
core.activeCasters = activeCasters

local regEvents = {
	"PLAYER_TOTEM_UPDATE",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"PLAYER_ENTERING_WORLD",
	"UNIT_HEALTH",
	"CVAR_UPDATE",
	"MINIMAP_UPDATE_ZOOM",
}

--Option windows
local coreOpts

function core:OnInitialize()
	Debug = self.Debug
	totemInfo = self.totemInfo

	db = LibStub("AceDB-3.0"):New("TR_DB", core.defaultSettings)
	self.CoreOptionsTable.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
	db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	self.db = db
	self:RegisterChatCommand("tr", "MySlashProcessorFunc")
	
	local config = LibStub("AceConfig-3.0")
	local dialog = LibStub("AceConfigDialog-3.0")
	config:RegisterOptionsTable(folder, self.CoreOptionsTable)
	coreOpts = dialog:AddToBlizOptions(folder, self.titleFull)

	
end

----------------------------------------------
function core:MySlashProcessorFunc(input)	--
-- /da function brings up the UI options.	--
----------------------------------------------
	InterfaceOptionsFrame_OpenToCategory(coreOpts)
end

core.updateThrottle = 0.05  --Update minimap location 20x a second.

local lastX, lastY = 0,0, 0
local rlu = 0
local function timerUpdate(self, elapsed)
	self.lastUpdate = (self.lastUpdate or 0) + elapsed
	if self.lastUpdate > core.updateThrottle then
		self.lastUpdate = 0
		
		--Make sure we've moved, else we waste CPU cycles not changing anything.
		local sX, sY = GetPlayerMapPosition("player")
		if lastX == sX and lastY == sY then
			return
		end
		lastX = sX
		lastY = sY 
		
--~ 		Debug("timerUpdate", GetTime() - rlu)
--~ 		rlu = GetTime()
		
		for totemGUID in pairs(activeTotems) do 
			core:TotemUpdate(totemGUID)
		end
		
	end
end

function core:OnEnable()
	P = db.profile

	for i, event in pairs(regEvents) do 
		self:RegisterEvent(event)
	end
	
	self.userName = GetUnitName("player")
--~ 	Debug("OnEnable","core")

	timerFrame:SetScript("OnUpdate", timerUpdate)
	
	if P.showOnMinimap == false then
		self.updateThrottle = 0.25 --User's probably running AVR. We just do inside/outside check. This doesn't need to be done very rapidly.
	else
		self.updateThrottle = 0.05
	end
	
	self:RegisterComm(commPrefixTotemLoc, "IncComm")
	self:RegisterComm(commPrefixRemoveTotem, "IncComm")
end

function core:OnDisable()
--~ 	HideAllTotems()
--~ 	Debug("OnDisable","core")

	timerFrame:SetScript("OnUpdate", nil)
end



----------------------------------------------------------------------
function core:OnProfileChanged(...)									--
-- User has reset proflie, so we reset our spell exists options.	--
----------------------------------------------------------------------
	-- Shut down anything left from previous settings
	self:Disable()
	-- Enable again with the new settings
	self:Enable()
end

local function RemoveTotem(totemGUID)
	if timers[totemGUID] then
		core:CancelTimer(timers[totemGUID], true);
	end

	if activeTotems[totemGUID] then
		core:RemoveTotemFromAVR(totemGUID)
		core:RemoveTotemFromMinimap(totemGUID)
		
		activeTotems[totemGUID] = nil
		
--~ 		activeTotems[totemGUID].icon:Hide()
--~ 		activeTotems[totemGUID].icon:SetParent(nil)
--~ 		activeTotems[totemGUID].icon = nil
--~ 		activeTotems[totemGUID] = nil
	end
	
end

----------------------------------------------------------------------------------
local function BroadcastRemoveTotem(totemGUID)										--
-- Sends the totemGUID to group for others to remove if from their minimap.		--
-- This is needed cause UNIT_DEAD doesn't always fire if we're out of range.	--
----------------------------------------------------------------------------------
	if GetNumPartyMembers() > 0 then
		local str = core:Serialize(totemGUID)
--~ 		core:SendCommMessage(commPrefixRemoveTotem, str, "GUILD", nil, "ALERT")

		local iActive, iType = IsInInstance()
		if iActive and iType == "pvp" then
			--We're in a battlefield. 
			core:SendCommMessage(commPrefixRemoveTotem, str, "BATTLEGROUND", nil, "BULK")
		else
			core:SendCommMessage(commPrefixRemoveTotem, str, GetNumRaidMembers() > 1 and "raid" or "party", nil, "BULK")
		end
	end
end

function core:PLAYER_TOTEM_UPDATE(event, totemSlot)
	local haveTotem, totemName, startTime, duration = GetTotemInfo(totemSlot)

	if startTime == 0 then
		for GUID, data in pairs(activeTotems) do 
			if data.caster == self.userName and data.totemSlot == totemSlot then
				RemoveTotem(GUID)
				if P.broadcastTotemLocation == true then
					BroadcastRemoveTotem(GUID)
				end
				break
			end
		end
	end
end

------------------------------------------
local function RemoveCastersTotems(caster)	--
-- Remove all totems from a shaman.		--
------------------------------------------
--~ 	for totemGUID, data in pairs(activeTotems) do 
--~ 		if data.caster == caster then
--~ 			RemoveTotem(totemGUID)
--~ 		end
--~ 	end
--~ 	activeCasters[caster] = nil
end


----------------------------------------------------------------------------------------------------------
local function BroadcastTotemLoc(totemGUID, spellID, tC, tZ, tX, tY, zoneMap)							--
-- Send the precise coords of our totems so others can update the locs of our totems on their minimap.	--
----------------------------------------------------------------------------------------------------------
	if GetNumPartyMembers() > 0 then
		tX = core:Round(tX,8) --shrink the outgoing message by 15 characters.
		tY = core:Round(tY,8)
		local str = core:Serialize(totemGUID, spellID, tC, tZ, tX, tY, zoneMap)
--~ 		Debug("BroadcastTotemLoc 2", str)

		local iActive, iType = IsInInstance()
		if iActive and iType == "pvp" then
			core:SendCommMessage(commPrefixTotemLoc, str, "BATTLEGROUND", nil, "ALERT")
		else
			core:SendCommMessage(commPrefixTotemLoc, str, GetNumRaidMembers() > 1 and "raid" or "party", nil, "ALERT")
		end
	end
end

----------------------------------------------------------
local function RemoveCastersOldTotems(caster, totemSlot)--
-- Remove last known totem for a caster's totem slot.	--
----------------------------------------------------------
	for totemGUID, data in pairs(activeTotems) do 
		if data.caster == caster and data.totemSlot == totemSlot then
--~ 			Debug("RemoveCastersOldTotems", caster, totemSlot, totemGUID)
			RemoveTotem(totemGUID)
			return
		end
	end
end


function core:AddTotem(totemGUID, spellID, caster, tC, tZ, tX, tY, precise, totemSlot, zoneMap)	--
	if not totemInfo[spellID] then
		return
	end
	local totemSlot = totemSlot or totemInfo[spellID].slot or 1
	RemoveCastersOldTotems(caster, totemSlot)
	
	local zoneMap = zoneMap or self:ZoneIDToMap(tC, tZ)
	
	local totemName = totemInfo[spellID].name or GetSpellInfo(spellID)
--~ 	if P.totemOpts[totemName] and P.totemOpts[totemName].shown == false then
--~ 		return
--~ 	end	
--~ 	Debug("AddTotem", 1, totemName)
	if not P.totemOpts[totemName] then
		return
	end
--~ 	Debug("AddTotem", 2, totemName)

	if P.totemOpts[totemName].shown == 4 then --never show
		return
	end
	
--~ 	Debug("AddTotem", caster, totemName, P.totemOpts[totemName].shown)
	
--~ 	if caster ~= self.userName then
--~ 		if P.totemOpts[totemName].shown == 2 and not UnitInParty(caster) then --only show party
--~ 			return
--~ 		elseif P.totemOpts[totemName].shown == 1 and not UnitInRaid(caster) then --only show raid
--~ 			return
--~ 		elseif P.totemOpts[totemName].shown == 3 then
--~ 			return
--~ 		end
--~ 	elseif P.totemOpts[totemName].shown ~= 3 then
--~ 		return
--~ 	end

	if P.totemOpts[totemName].shown == 4 then --never show totem
		return
	end
	if (caster == self.userName) or (P.totemOpts[totemName].shown == 2 and UnitInParty(caster)) or (P.totemOpts[totemName].shown == 1 and UnitInRaid(caster)) then
		activeCasters[caster] = true
		
		local range = totemInfo[spellID].range or 0
		if precise == false and range > self.spawnDistance then
			range = range - self.spawnDistance --We don't know the precise coords of the totem. So we remove 3 yards from the totem's range to make sure we'll be inside it. 
		end
		
		if not activeTotems[totemGUID] then
			local duration = totemInfo[spellID].duration or 5
			local zW, zH = self:GetZoneSize()
			
			
			activeTotems[totemGUID] = {
				caster	= caster,
	
				--coords
				tC = tC,
				tZ = tZ,
				tX = tX,
				tY = tY,
	
				zW = zW, --Zone width
				zH = zH, --Zone height
				
				range	= range,
				precise	= precise,
				totemSlot = totemSlot,
				death = GetTime() + duration,--Remove the icon at this time, just in case UNIT_DEAD doesn't see it.
				totemName = totemName, 
				zoneMap = zoneMap,
				
			}
			
			
			activeTotems[totemGUID].minimapIcon = self:AddTotemToMinimap(totemGUID, spellID, totemSlot, range, precise)
			
	
			self:ScheduleTimer("TotemAgeDeath", duration, totemGUID)
		end
			
			
	--~ 	Debug("AddTotem", 3, totemName)
		
		local myMap = self:GetCurrentMap()
		
		if zoneMap == myMap or tC == GetCurrentMapContinent() and tZ == GetCurrentMapZone() then
			if P.AVRdisplay == true then
				self:AddTotemToAVR(totemGUID, tX, tY, totemSlot, spellID, range, precise, caster, totemName) --
			end
				
				
			if activeTotems[totemGUID].minimapIcon then
				activeTotems[totemGUID].minimapIcon:Show()
			end
			self:TotemUpdate(totemGUID)
		end
	
	end
end

function core:ForceUpdate()
	for totemGUID in pairs(activeTotems) do 
		core:TotemUpdate(totemGUID)
	end
end


function core:TotemUpdate(totemGUID)
	local sX, sY = GetPlayerMapPosition("player")

--~ 	Debug("TotemUpdate", totemGUID)

	local totemData = activeTotems[totemGUID]
	local range = totemData.range
	
	--Zone width and height
	local zW, zH = totemData.zW, totemData.zH
	
	--Totem's map coords.
	local tX, tY = totemData.tX, totemData.tY
	--Convert to yard coords.
	tX = zW * tX
	tY = zH * tY
	
	--Our coords in yard coords.
	sX = zW * sX
	sY = zH * sY

	local dist, xDist, yDist = self:ComputeDistance(sX, sY, tX, tY)
	
	local insideRing = true

	if range > 0 then
		if dist > range then --hasBuff and 
			insideRing = false --for AVR
		end
	end
	
--~ 	Debug("TotemUpdate", tX, tY, "||", sX, sY, "||", range, dist)
	
--~ 	Debug("TotemUpdate", totemGUID, range, dist)
	
	if totemData.minimapIcon and totemData.minimapIcon:IsShown() then
		self:UpdateMinimapLocation(totemGUID, range, dist, xDist, yDist, insideRing)
	end
	
	if P.AVRdisplay == true then
		local totemSlot = totemData.totemSlot or 1
		
		
		if totemData.zoneMap == self:GetCurrentMap() then
			self:UpdateAVRDisplay(totemGUID, dist, insideRing, totemSlot)
		end
	end
end

function core:TotemAgeDeath(totemGUID)
	RemoveTotem(totemGUID)
end

function core:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags  = ...-- ***
	
	if eventType == "SPELL_SUMMON" then
		local spellID, spellName, spellSchool = select(9,...)
		if totemInfo[spellID] then
			local tC, tZ, tX, tY
			local precise = false
			local totemSlot = totemInfo[spellID].slot
			local zoneMap
			
			if UnitIsUnit("player", srcName) then
				tC, tZ, _, _, zoneMap = self:GetUnitPosition("player")
				tX, tY = self:GetTotemCoords(self.totemHeadings[totemSlot])

				precise = true
--~ 				Debug("combat","You dropped a totem!")
			elseif P.trackOthersTotems == true and UnitInParty(srcName) or UnitInRaid(srcName) then
				tC, tZ, tX, tY, zoneMap = self:GetUnitPosition(srcName)
			end
		
			if tC then
				self:AddTotem(dstGUID, spellID, srcName, tC, tZ, tX, tY, precise, totemSlot, zoneMap)
				if P.broadcastTotemLocation == true and precise == true then
					BroadcastTotemLoc(dstGUID, spellID, tC, tZ, tX, tY, zoneMap)
				end

			end
		end
		
	elseif eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" or eventType == "UNIT_DISSIPATES" then
		
		if activeTotems[dstGUID] then
			Debug("COMBAT", dstGUID, eventType)
			RemoveTotem(dstGUID)
			return
		end
		if dstName then
			RemoveCastersTotems(dstName)
		end
	end
end





function core:PLAYER_ENTERING_WORLD(event, ...)
--~ 	HideAllTotems()
end

function core:UNIT_HEALTH(event, ...)
	local unitID = ...
	
	if not UnitIsUnit(unitID,"player") and UnitHealth(unitID) == 0 then
		local name = GetUnitName(unitID, true)
		if name and activeCasters[name] then
			RemoveCastersTotems(name)
		end
	end
end



function core:IncComm(prefix, message, distribution, sender)
--~ 	if sender ~= userName then
		if prefix == commPrefixTotemLoc then
			if P.trackOthersTotems == true then
				local success, totemGUID, spellID, tC, tZ, tX, tY, zoneMap = core:Deserialize(message)
		--~ 		Debug("IncComm",sender.." dropped a totem!")
				
				if success then
					Debug("IncComm", sender, totemGUID, zoneMap, tX, tY)
					self:AddTotem(totemGUID, spellID, sender, tC, tZ, tX, tY, true, nil, zoneMap)
				end
			end
		elseif prefix == commPrefixRemoveTotem then
			local success, totemGUID = core:Deserialize(message)
			if success then
				if activeTotems[totemGUID] and activeTotems[totemGUID].caster == sender then
--~ 					Debug("IncComm","Removing "..sender.."'s totem.")
					RemoveTotem(totemGUID)
				end
			end
		end
--~ 	end
end


function core:HideTotem(totemGUID)
	local data = activeTotems[totemGUID]
	if data then
		data.minimapIcon:Hide()
--~ 		Debug("ZoneChanged", "Hiding ",totemGUID, self:GetCurrentMap(), data.zoneMap)
		
		local meshes = self.totemMeshes[totemGUID]
		if meshes then
			for name, mesh in pairs(meshes) do 
				mesh.visible = false
			end
		end
	end
end

function core:ShowTotem(totemGUID)
	local data = activeTotems[totemGUID]
	if data then
		data.minimapIcon:Show()
--~ 		Debug("ZoneChanged", "Showing ",totemGUID)
		
		local meshes = self.totemMeshes[totemGUID]
		if meshes then
			for name, mesh in pairs(meshes) do 
				mesh.visible = true
			end
		end
	end
end

function core:ZoneChanged()
	local myMap = self:GetCurrentMap()
	for totemGUID, data in pairs(activeTotems) do 
		if data.zoneMap == myMap then
			self:ShowTotem(totemGUID)
		else
			self:HideTotem(totemGUID)
		end
	end
end
