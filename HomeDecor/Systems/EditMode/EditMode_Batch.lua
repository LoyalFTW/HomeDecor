local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM    = NS.Systems.EditMode
local Batch = {}
EM.Batch = Batch

local lastRID    = nil
local placeCount = 0

hooksecurefunc(C_HousingBasicMode, "StartPlacingNewDecor", function(entryID)
	if type(entryID) == "table" and entryID.recordID then
		lastRID = entryID.recordID
	end
end)

if C_HousingBasicMode.StartPlacingPreviewDecor then
	hooksecurefunc(C_HousingBasicMode, "StartPlacingPreviewDecor", function(rid)
		lastRID = rid
	end)
end

function Batch.OnPlaced(decorGUID)
	if not EM.On("batchPlace") then
		placeCount = 0
		return
	end

	local rid = lastRID
	if decorGUID and C_HousingDecor and C_HousingDecor.GetDecorInstanceInfoForGUID then
		local info = EM.API.safe(C_HousingDecor.GetDecorInstanceInfoForGUID, decorGUID)
		if info and info.decorID then rid = info.decorID end
	end

	if not rid or not IsControlKeyDown() then
		placeCount = 0
		return
	end

	placeCount = placeCount + 1
	local count = placeCount

	EM.API.BeginPlacement(rid, function(ok)
		if ok and EM.On("batchRotate") then
			C_Timer.After(0.1, function()
				local step = EM.DB().batchStep or 15
				local deg  = (count * step) % 360
				if deg ~= 0 then EM.API.RotateDegrees(deg) end
			end)
		end
	end, false)
end

function Batch.Reset()
	lastRID    = nil
	placeCount = 0
end
