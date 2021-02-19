

--locals
local _G = _G
local unpack = unpack
local Debug = core.Debug
local pairs = pairs
local UnitInRaid = UnitInRaid
local UnitInParty = UnitInParty
local totemInfo = core.totemInfo
local AVRCircleMesh = _G.AVRCircleMesh
local AVRFilledCircleMesh = _G.AVRFilledCircleMesh
local spawnDistance = core.spawnDistance
local echo = core.echo
local GetSpellInfo = GetSpellInfo

local L = core.L or LibStub("AceLocale-3.0"):GetLocale(folder, true)

local fireNovaRange = 10 --Fire Nova has a range of 10 yards.

local AVR = false
local scene = {}


--~ local fireNovaTotems = {}

local P
local prev_OnEnable = core.OnEnable;
function core:OnEnable()
	prev_OnEnable(self);

	P = self.db.profile
	
	AVR = _G.AVR
	self.AVR = AVR
	
	if AVR then
		AVRCircleMesh = _G.AVRCircleMesh
		AVRFilledCircleMesh = _G.AVRFilledCircleMesh
		
		self:AddAVROptions()
	
		scene = AVR:GetTempScene(folder)
		scene:ClearScene()
		scene.visible = true
	end
	
--~ 	local spellName
--~ 	for spellID, show in pairs(core.fireNovaTotemIDs) do 
--~ 		spellName = GetSpellInfo(spellID)
--~ 		fireNovaTotems[spellName] = show
--~ 	end
	
end

local totemMeshes = {}
core.totemMeshes = totemMeshes





local prev_OnDisable = core.OnDisable
function core:OnDisable()
	prev_OnDisable(self)
	
	for totemGUID in pairs(totemMeshes) do 
		self:RemoveTotemFromAVR(totemGUID)
	end
	scene:ClearScene()
	scene.visible = false
end

--------------------------------------------------
local function GetAVRYardCoords(aX, aY)			--
-- AVR converts numbers differently then I do.	--
-- Thier X is the same, but Y is not. 			--
--------------------------------------------------
	local sX, sY = unpack(AVR.zoneData.currentScale)
	return aX*sX,(1-aY)*sY
end




local fireTotemRange = {}
function core:AddTotemToAVR(totemGUID, x, y, totemSlot, spellID, range, precise, caster, totemName)
	if AVR then
		if totemMeshes[totemGUID] then --it's already in our list? odd
			self:RemoveTotemFromAVR(totemGUID)
		end
		
		totemMeshes[totemGUID] = totemMeshes[totemGUID] or {}
		
		local bX, bY = GetAVRYardCoords(x, y)
		local range = range or totemInfo[spellID].range or 3
		
		local m
		
--~ 		Debug("AddTotemToAVR", self.userName, caster)
		
		local dottedLine = P.avrOtherDottedLine
		if self.userName == caster then
			dottedLine = false
		end
--~ 		Debug("AddTotemToAVR", 1.5*range+15)
		
		local lines = core:Round(1.5*range+15) --10y = 30 parts, 30y = 60 parts.
		
		
		--[[ Main ring]]
		m = AVRCircleMesh:New(range, lines, dottedLine, P.AVRLineThickness * 32)
		m:TranslateMesh(bX, bY)
		m:SetColor(P.totemColour[totemSlot].r, P.totemColour[totemSlot].g, P.totemColour[totemSlot].b, 1)
		scene:AddMesh(m)
		totemMeshes[totemGUID].rangeRing = m
		
		--[[ Small texture under totem.]]
		if P.AVRTotemLocation == true then
			m = AVRFilledCircleMesh:New(1,6, false, nil)
			m:TranslateMesh(bX, bY)
			m:SetColor(P.totemColour[totemSlot].r, P.totemColour[totemSlot].g, P.totemColour[totemSlot].b, .2)
			scene:AddMesh(m)
			totemMeshes[totemGUID].smallCircle = m
		end
		
		--[[ Add a fire nova ring if it's a fire totem.]]
		if totemSlot == 1 and P.showFireNova[totemName] and P.showFireNova[totemName] == true then
		
			--P.avrFireNovaRing == 3
			if P.avrFireNovaRing ~= 4 then --never show

				if (caster == self.userName) or (P.avrFireNovaRing == 2 and UnitInParty(caster)) or (P.avrFireNovaRing == 1 and UnitInRaid(caster)) then

					if precise == true then
						range = fireNovaRange --We know the exact location of the totem, set ring at 10 yards.
					else
						range = fireNovaRange - spawnDistance --Don't know the totem's location, set ring at 7 yards.
					end
					lines = self:Round(1.5*range+15)
					
					m = AVRCircleMesh:New(range, lines, dottedLine, P.AVRLineThickness * 32)
					m:TranslateMesh(bX, bY)
					m:SetColor(P.avrFireNovaColour.r, P.avrFireNovaColour.g, P.avrFireNovaColour.b, 1)
					scene:AddMesh(m)
					totemMeshes[totemGUID].firenovaRangeRing = m
					fireTotemRange[totemGUID] = range
				end
			end
		end

	end
end


function core:RemoveTotemFromAVR(totemGUID)
	if AVR and totemMeshes[totemGUID] then
		for name, mesh in pairs(totemMeshes[totemGUID]) do 
			mesh:Remove()
			mesh = nil
		end
		totemMeshes[totemGUID] = nil
	end
end


function core:HideAllFireNova()
	echo(L["Removing all fire nova rings."])
	if AVR then
		for totemGUID, data in pairs(totemMeshes) do 
			if data.firenovaRangeRing then
				data.firenovaRangeRing:Remove()
				data.firenovaRangeRing = nil
			end
		end
	end
end


function core:UpdateAVRDisplay(totemGUID, dist, insideRing, totemSlot)
	if AVR and totemMeshes[totemGUID] then
		local meshes = totemMeshes[totemGUID]
	
		if dist > P.avrShowRange then
			for name, mesh in pairs(meshes) do 
				meshes[name].visible = false
			end
		else
			for name, mesh in pairs(meshes) do 
				meshes[name].visible = true
			end
		end

		
		
		if insideRing == true then
			if meshes.rangeRing then
				if P.avrColourRingBySchool == true then
					meshes.rangeRing:SetColor(P.totemColour[totemSlot].r, P.totemColour[totemSlot].g, P.totemColour[totemSlot].b, P.avrInsideRingAlpha)
				else
					meshes.rangeRing:SetColor(P.insideRingColour.r, P.insideRingColour.g, P.insideRingColour.b, P.avrInsideRingAlpha)
				end
			end

			if meshes.colourRing then
				meshes.colourRing:SetColor(P.totemColour[totemSlot].r, P.totemColour[totemSlot].g, P.totemColour[totemSlot].b, P.avrInsideRingAlpha)
			end
		else
			if meshes.rangeRing then
				if P.avrColourRingBySchool == true then
					meshes.rangeRing:SetColor(P.totemColour[totemSlot].r, P.totemColour[totemSlot].g, P.totemColour[totemSlot].b, P.avrOutsideRingAlpha)
				else
					meshes.rangeRing:SetColor(P.outsideRingColour.r, P.outsideRingColour.g, P.outsideRingColour.b, P.avrOutsideRingAlpha)
				end
			end
			
			if meshes.colourRing then
				meshes.colourRing:SetColor(P.totemColour[totemSlot].r, P.totemColour[totemSlot].g, P.totemColour[totemSlot].b, P.avrOutsideRingAlpha)
			end
		end
		
		--P.avrFireNovaRing == true and 
		--firenova ring for fire totems.
		if meshes.firenovaRangeRing then
			if dist < fireTotemRange[totemGUID] then
				if P.avrColourRingBySchool == true then
					meshes.firenovaRangeRing:SetColor(P.avrFireNovaColour.r, P.avrFireNovaColour.g, P.avrFireNovaColour.b, P.avrInsideRingAlpha)
				else
					meshes.firenovaRangeRing:SetColor(P.insideRingColour.r, P.insideRingColour.g, P.insideRingColour.b, P.avrInsideRingAlpha)
				end
				
				if meshes.firenovaColourRing then
					meshes.firenovaColourRing:SetColor(P.avrFireNovaColour.r, P.avrFireNovaColour.g, P.avrFireNovaColour.b, P.avrInsideRingAlpha)
				end
			else
				if P.avrColourRingBySchool == true then
					meshes.firenovaRangeRing:SetColor(P.avrFireNovaColour.r, P.avrFireNovaColour.g, P.avrFireNovaColour.b, P.avrOutsideRingAlpha)
				else
					meshes.firenovaRangeRing:SetColor(P.outsideRingColour.r, P.outsideRingColour.g, P.outsideRingColour.b, P.avrOutsideRingAlpha)
				end
				
				if meshes.firenovaColourRing then
					meshes.firenovaColourRing:SetColor(P.avrFireNovaColour.r, P.avrFireNovaColour.g, P.avrFireNovaColour.b, P.avrOutsideRingAlpha)
				end
			end
		end	
		
		
	end
end
