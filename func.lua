

local _G = _G
local getn = table.getn
local tostring = tostring
local chatFrame = _G["ChatFrame1"]
local GetPlayerMapPosition = GetPlayerMapPosition
local GetPlayerFacing = GetPlayerFacing
local math_deg = math.deg
local math_rad = math.rad
local math_cos = math.cos
local math_sin = math.sin
local math_abs = math.abs
local GetCurrentMapContinent = GetCurrentMapContinent
local GetCurrentMapZone = GetCurrentMapZone
local SetMapToCurrentZone = SetMapToCurrentZone
local SetMapZoom = SetMapZoom
local math_sqrt = math.sqrt
local math_floor = math.floor

local prev_OnInitialize = core.OnInitialize;
function core:OnInitialize()
	chatFrame = _G["ChatFrame1"]
	prev_OnInitialize(self);
end

local DEBUG = false
--[===[@debug@
DEBUG = true
--@end-debug@]===]

local strWhiteBar		= "|cffffff00 || |r" -- a white bar to seperate the debug info.
local colouredName		= "|cff7f7f7f{|r|cffff0000TR|r|cff7f7f7f}|r "
local function echo(...)
	local tbl  = {...}
	local msg = tostring(tbl[1])
	for i=2,getn(tbl) do 
		msg = msg..strWhiteBar..tostring(tbl[i])
	end
	
	local cf = chatFrame
	if cf then
		cf:AddMessage(colouredName..msg,.7,.7,.7)
	end
end
core.echo = echo

--~ local whiteText			= "|cffffffff%s|r"
local strDebugFrom		= "|cffffff00[%s]|r" --Yellow function name. help pinpoint where the debug msg is from.
-----------------------------
local function Debug(from, ...)	--
-- simple print function.	--
------------------------------
	if DEBUG == false then
		return 
	end
	local tbl  = {...}
	local msg = tostring(tbl[1])
	for i=2,getn(tbl) do 
		msg = msg..strWhiteBar..tostring(tbl[i])
	end
	echo(strDebugFrom:format(from).." "..msg)
end
core.Debug = Debug

------------------------------------------
function core:CoordsToYardCoords(x, y)		--
-- Convert map coords to yard coords.	--
------------------------------------------
	local width, height = core:GetZoneSize()
	local yX = width * x
	local yY = height * y
	return yX, yY
end

----------------------------------------------------------------------------------
local function GetMyYardCoords()														--
-- Returns our coords in yards instead of map coords.							--
-- Every map has coords of 0-100, but each zone is a different size in yards.	--
----------------------------------------------------------------------------------
	local mX, mY = GetPlayerMapPosition("player")
	return core:CoordsToYardCoords(mX, mY)
end



--[[math.deg(GetPlayerFacing())
	North = 0/360
	West = 90
	South = 180
	East = 270]]
----------------------------------
local function MyHeading()			--
-- Returns heading in degrees.	--
----------------------------------
	return math_deg(GetPlayerFacing())
end


----------------------------------------------------------------------------------
local function SwitchEW(angle)														--
-- This function switchs east and west directions.								--
----------------------------------------------------------------------------------
	local z = 0 - angle;
	local t = 0 - math_abs(z);
	if t < 0 then
		t = t + 360;
	end
	return t
end

--------------------------------------------------------------------------------------
local function GetDirectionCoords(mX, mY, direction, distance)							--
-- Returns a set of coords in a direction and distance of another set of coords.	--
-- Many thanks to Granola of Baelgun server for helping me.							--
--------------------------------------------------------------------------------------
	local direction = direction + 90 -- cos & sin see 360/0deg as east, but GetPlayerFacing sees it at north. We need to adjust for this.
	local direction = SwitchEW(direction) --This seems to work, I don't know why.
	local rad = math_rad(direction)
	local tX = mX + distance * math_cos(rad)
	local tY = mY + distance * math_sin(rad)
	return tX, tY
end

------------------------------------------
local function YardCoordsToMapCoords(sX, sY)	--
-- Convert yard coords to map coords.	--
------------------------------------------
	local width, height = core:GetZoneSize()
	local tX = sX / width
	local tY = sY / height
	return tX, tY
end

----------------------------------------------------------------------------------
function core:GetTotemCoords(direction)												--
-- Input a heading and this returns the coords 3 yards away in that direction.	--
----------------------------------------------------------------------------------
	--Get our current coords in yards.
	local x, y = GetMyYardCoords() --Get our coords in yards.

	local heading = MyHeading() + direction --Adjust the heading to compensate for our current heading.
	if (heading < 0) then --Make sure the heading is 0-360. This may not be needed but helped in testing.
		heading = heading + 360;
	elseif heading > 360 then
		heading = heading - 360;
	end
	
	--Get the coords of where the totem spawned, 3 yards away from us.
	local tX, tY = GetDirectionCoords(x, y, heading, self.spawnDistance)

	--Convert the totem coords back to map coords.
	local cX, cY = YardCoordsToMapCoords(tX, tY)
	return cX, cY
end

function core:GetUnitPosition( unit, noMapChange )
	local x, y = GetPlayerMapPosition(unit);
	if ( x <= 0 and y <= 0 ) then
		if ( noMapChange ) then
			-- no valid position on the current map, and we aren't allowed
			-- to change map zoom, so return
			return;
		end
		local lastCont, lastZone = GetCurrentMapContinent(), GetCurrentMapZone()
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition(unit);
		if ( x <= 0 and y <= 0 ) then
			SetMapZoom(lastCont);
			x, y = GetPlayerMapPosition(unit);
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance or otherwise off the continent map
				return;
			end
		end
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()
		local map = self:GetZoneMap()
		if ( C ~= lastCont or Z ~= lastZone ) then
			SetMapZoom(lastCont, lastZone); -- set map zoom back to what it was before
		end
		return C, Z, x, y, map;
	end
	return GetCurrentMapContinent(), GetCurrentMapZone(), x, y, self:GetZoneMap()
end
--~ 	local tex=GetMapInfo()
--~ 	local level=GetCurrentMapDungeonLevel()

----------------------------------------------------------------------
function core:ComputeDistance(fX, fY, tX, tY)							--
-- Return the distance and x/y distance between a set of coords.	--
----------------------------------------------------------------------
	local xDelta = (tX - fX);
	local yDelta = (tY - fY);
	local dist = math_sqrt(xDelta*xDelta + yDelta*yDelta);
	return dist, xDelta, yDelta
end

------------------------------------------------------------------
function core:Round(num, zeros)										--
-- zeroes is the number of decimal places. eg 1=*.*, 3=*.***	--
------------------------------------------------------------------
	return math_floor( num * 10 ^ (zeros or 0) + 0.5 ) / 10 ^ (zeros or 0)
end