local ADDON, NS = ...



local MT = {}
NS.Systems = NS.Systems or {}
NS.Systems.MapTracker = MT

local C_Map = _G.C_Map
local Enum = _G.Enum
local GetRealZoneText = _G.GetRealZoneText
local CreateFrame = _G.CreateFrame
local C_Timer = _G.C_Timer
local GetTime = _G.GetTime


local builtIndex = false
local vendorsByMapID = {}
local vendorsByZoneName = {}


local continentChildCache = {}


local listeners = {}

local function ParseMapIDFromWorldmap(worldmap)
	if type(worldmap) ~= "string" then return nil end
	local a = worldmap:match("^(%d+):")
	return a and tonumber(a) or nil
end

local function VendorMapID(v)
	if type(v) ~= "table" then return nil end
	local wm = v.worldmap or (v.source and v.source.worldmap)
	return ParseMapIDFromWorldmap(wm)
end

local function VendorZoneName(v)
	if type(v) ~= "table" then return nil end
	return v.zone or (v.source and v.source.zone)
end

local function EnsureIndex()
	if builtIndex then return end

	local vendorsRoot = NS.Data and NS.Data.Vendors
	if type(vendorsRoot) ~= "table" then

		return
	end







	local out = {}
	local seen = {}

	local function IsVendorRecord(t)
		if type(t) ~= "table" then return false end

		if type(t.items) ~= "table" then return false end
		local s = t.source
		local wm = t.worldmap or (s and s.worldmap)
		local zn = t.zone or (s and s.zone)
		if (wm and wm ~= "") or (zn and zn ~= "") then
			return true
		end
		return false
	end

	local function Walk(node)
		if type(node) ~= "table" then return end
		if seen[node] then return end
		seen[node] = true

		if IsVendorRecord(node) then
			out[#out + 1] = node
			return
		end

		for _, v in pairs(node) do
			if type(v) == "table" then
				Walk(v)
			end
		end
	end

	Walk(vendorsRoot)


	if #out == 0 then
		return
	end

	builtIndex = true
	wipe(vendorsByMapID)
	wipe(vendorsByZoneName)

	for i = 1, #out do
		local vendor = out[i]
		local mid = VendorMapID(vendor)
		if mid then
			local key = tostring(mid)
			local t = vendorsByMapID[key]
			if not t then t = {}; vendorsByMapID[key] = t end
			t[#t + 1] = vendor
		end

		local zn = VendorZoneName(vendor)
		if zn and zn ~= "" then
			local t2 = vendorsByZoneName[zn]
			if not t2 then t2 = {}; vendorsByZoneName[zn] = t2 end
			t2[#t2 + 1] = vendor
		end
	end
end


local function ResolveContinentChildByName(continentID, zoneName)
	if not continentID or not zoneName or zoneName == "" then return nil end

	local byContinent = continentChildCache[continentID]
	if not byContinent then
		byContinent = {}
		continentChildCache[continentID] = byContinent
	end

	local cached = byContinent[zoneName]
	if cached ~= nil then
		return cached or nil
	end

	local childMapID
	if C_Map and C_Map.GetMapChildrenInfo then
		local children = C_Map.GetMapChildrenInfo(continentID, nil, true)
		if type(children) == "table" then
			for i = 1, #children do
				local c = children[i]
				if c and c.name == zoneName and c.mapID then
					childMapID = c.mapID
					break
				end
			end
		end
	end

	byContinent[zoneName] = childMapID or false
	return childMapID
end

local function ResolveStableZoneMapID(mapID, zoneName)
	if not mapID or not C_Map or not C_Map.GetMapInfo then return mapID end

	local uiType = Enum and Enum.UIMapType
	local T_CONTINENT = uiType and uiType.Continent or 2
	local T_ZONE      = uiType and uiType.Zone      or 3
	local T_DUNGEON   = uiType and uiType.Dungeon   or 4

	local cur = mapID
	local guard = 0
	local info = C_Map.GetMapInfo(cur)

	while info and info.parentMapID and info.parentMapID > 0 and guard < 25 do
		guard = guard + 1
		local mt = info.mapType
		if mt == T_ZONE or mt == T_DUNGEON then
			return cur
		end
		local parent = info.parentMapID
		if not parent or parent == 0 or parent == cur then break end
		cur = parent
		info = C_Map.GetMapInfo(cur)
	end

	if info and info.mapType == T_CONTINENT then
		local z = zoneName or (GetRealZoneText and GetRealZoneText())
		local child = ResolveContinentChildByName(cur, z)
		if child then
			return child
		end
	end

	return cur or mapID
end

local function FireZoneChanged(zoneName, mapID)
	for _, fn in pairs(listeners) do
		local ok, err = pcall(fn, zoneName, mapID)
		if not ok then

		end
	end
end

function MT:RegisterCallback(key, fn)
	if type(fn) ~= "function" then return end
	key = key or tostring(fn)
	listeners[key] = fn
	return key
end

function MT:UnregisterCallback(key)
	if key then listeners[key] = nil end
end


MT.zoneName = nil
MT.zoneMapID = nil

MT._enabled = false
MT._queued = false
MT._lastRun = 0

function MT:GetCurrentZone()
	return self.zoneName or "", self.zoneMapID
end

function MT:_UpdateNow(force)
	if not self._enabled then return end


	local now = (GetTime and GetTime()) or 0
	if not force and (now - (self._lastRun or 0) < 0.25) then
		return
	end
	self._lastRun = now

	local zoneName = (GetRealZoneText and GetRealZoneText()) or ""
	local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or nil
	if mapID then
		mapID = ResolveStableZoneMapID(mapID, zoneName)
	end

	local name = zoneName
	if mapID and C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(mapID)
		if info and info.name and info.name ~= "" then
			name = info.name
		end
	end

	local changed = false
	if mapID ~= self.zoneMapID then
		changed = true
	elseif (not mapID) and name ~= self.zoneName then

		changed = true
	end

	if changed then
		self.zoneName = name
		self.zoneMapID = mapID
		FireZoneChanged(name, mapID)
	end
end

function MT:_QueueUpdate(delay, force)
	if not self._enabled then return end
	if self._queued then return end
	self._queued = true

	C_Timer.After(delay or 0.35, function()
		if not MT._enabled then
			MT._queued = false
			return
		end
		MT._queued = false
		MT:_UpdateNow(force)
	end)
end

function MT:Enable(enabled)
	enabled = enabled and true or false
	if enabled == self._enabled then return end
	self._enabled = enabled

	if enabled then
		EnsureIndex()
		self:_QueueUpdate(0, true)
		if not self._frame then
			local f = CreateFrame("Frame")
			f:RegisterEvent("PLAYER_ENTERING_WORLD")
			f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			f:RegisterEvent("ZONE_CHANGED")
			f:RegisterEvent("ZONE_CHANGED_INDOORS")
			f:RegisterEvent("ADDON_LOADED")
			f:SetScript("OnEvent", function(_, event, arg1)
				if event == "ADDON_LOADED" then


					if type(arg1) == "string" and (arg1 == ADDON or arg1:match("^" .. ADDON)) then
						MT:ClearCaches()
						MT:_QueueUpdate(0.15, true)
					end
					return
				end

				MT:_QueueUpdate(0.35, false)
			end)
			self._frame = f
		else
			self._frame:Show()
		end
	else
		if self._frame then
			self._frame:Hide()
		end
	end
end

function MT:ClearCaches()
	builtIndex = false
	wipe(vendorsByMapID)
	wipe(vendorsByZoneName)
	wipe(continentChildCache)
end

function MT:GetVendorsForCurrentZone()
	EnsureIndex()
	local name, mapID = self:GetCurrentZone()
	if mapID then
		local t = vendorsByMapID[tostring(mapID)]
		if t then return t end
	end
	if name and name ~= "" then
		local t2 = vendorsByZoneName[name]
		if t2 then return t2 end
	end
	return {}
end




function MT:CountVendor(vendor)
	local U = (NS.UI and NS.UI.TrackerUtil)
	if U and U.CountVendor then
		return U:CountVendor(vendor)
	end
	local total = 0
	for _, it in ipairs(vendor and vendor.items or {}) do
		if type(it) == "table" then total = total + 1 end
	end
	return 0, total
end

function MT:CountVendors(vendors)
	local U = (NS.UI and NS.UI.TrackerUtil)
	if U and U.CountVendors then
		return U:CountVendors(vendors)
	end
	local total = 0
	for _, v in ipairs(vendors or {}) do
		local _, t = self:CountVendor(v)
		total = total + t
	end
	return 0, total
end

return MT