local ADDON, NS = ...
NS.Systems = NS.Systems or {}
NS.Systems.EditMode = NS.Systems.EditMode or {}

local API = {}
NS.Systems.EditMode.API = API

local function safe(fn, ...)
	if not fn then return nil end
	local ok, v = pcall(fn, ...)
	return ok and v or nil
end

API.safe = safe

function API.EditorOpen()
	if HouseEditorFrame and HouseEditorFrame:IsShown() then return true end
	return safe(C_HouseEditor and C_HouseEditor.IsHouseEditorActive) == true
end

function API.GetMode()
	return safe(C_HouseEditor and C_HouseEditor.GetActiveHouseEditorMode)
end

function API.IsBasicMode()
	local m = API.GetMode()
	local t = Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.BasicDecor
	return m ~= nil and t ~= nil and m == t
end

function API.IsExpertMode()
	local m = API.GetMode()
	local t = Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.ExpertDecor
	return m ~= nil and t ~= nil and m == t
end

function API.IsHovering()
	return safe(C_HousingDecor and C_HousingDecor.IsHoveringDecor) == true
end

function API.IsSelected()
	return safe(C_HousingBasicMode and C_HousingBasicMode.IsDecorSelected) == true
end

function API.IsPlacing()
	return safe(C_HousingBasicMode and C_HousingBasicMode.IsPlacingNewDecor) == true
end

function API.IsExpertSelected()
	return safe(C_HousingExpertMode and C_HousingExpertMode.IsDecorSelected) == true
end

function API.GetHoveredInfo()
	if not API.IsHovering() then return nil end
	local info = safe(C_HousingDecor and C_HousingDecor.GetHoveredDecorInfo)
	if not info then return nil end
	return {
		guid  = info.decorGUID,
		rid   = info.decorID,
		name  = info.name,
		icon  = info.iconTexture or info.iconAtlas,
	}
end

function API.GetSelectedInfo()
	local info = safe(C_HousingBasicMode and C_HousingBasicMode.GetSelectedDecorInfo)
	if not info or not info.decorID then
		info = safe(C_HousingExpertMode and C_HousingExpertMode.GetSelectedDecorInfo)
	end
	if not info or not info.decorID then return nil end
	return {
		guid  = info.decorGUID,
		rid   = info.decorID,
		name  = info.name,
		icon  = info.iconTexture or info.iconAtlas,
	}
end

function API.GetTargetInfo()
	return API.GetHoveredInfo() or API.GetSelectedInfo()
end

function API.GetCatalogEntry(rid)
	if not rid then return nil end
	local t = Enum and Enum.HousingCatalogEntryType and Enum.HousingCatalogEntryType.Decor or 1
	return safe(C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID, t, rid, true)
end

function API.CancelEditing()
	safe(C_HousingBasicMode and C_HousingBasicMode.CancelActiveEditing)
	safe(C_HousingExpertMode and C_HousingExpertMode.CancelActiveEditing)
end

function API.RemoveSelected()
	if safe(C_HousingBasicMode and C_HousingBasicMode.RemoveSelectedDecor) ~= nil then return true end
	if safe(C_HousingExpertMode and C_HousingExpertMode.RemoveSelectedDecor) ~= nil then return true end
	if safe(C_HousingCleanupMode and C_HousingCleanupMode.RemoveSelectedDecor) ~= nil then return true end
	return false
end

function API.BeginPlacement(rid, onDone, switchFirst)
	if not rid or not API.EditorOpen() then
		if onDone then onDone(false) end
		return
	end

	local function execute()
		API.CancelEditing()
		local entry = API.GetCatalogEntry(rid)
		if not entry or not entry.entryID then
			if onDone then onDone(false) end
			return
		end
		local qty = (entry.quantity or 0) + (entry.remainingRedeemable or 0)
		if qty <= 0 then
			if onDone then onDone(false) end
			return
		end
		if safe(C_HousingDecor and C_HousingDecor.HasMaxPlacementBudget) then
			local spent = safe(C_HousingDecor.GetSpentPlacementBudget) or 0
			local cap   = safe(C_HousingDecor.GetMaxPlacementBudget) or 999
			if spent >= cap then
				if onDone then onDone(false) end
				return
			end
		end
		safe(C_HousingBasicMode and C_HousingBasicMode.StartPlacingNewDecor, entry.entryID)
		if onDone then onDone(true) end
	end

	if switchFirst and not API.IsBasicMode() then
		local basicMode = Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.BasicDecor
		safe(C_HouseEditor and C_HouseEditor.ActivateHouseEditorMode, basicMode)
		C_Timer.After(0.22, execute)
	else
		C_Timer.After(0.05, execute)
	end
end

function API.BounceMode()
	if not API.EditorOpen() then return end
	local cur   = API.GetMode()
	local basic  = Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.BasicDecor
	local expert = Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.ExpertDecor
	local alt = (cur == basic) and expert or basic

	local function avail(m)
		if not m or not C_HouseEditor or not C_HouseEditor.GetHouseEditorModeAvailability then return false end
		return safe(C_HouseEditor.GetHouseEditorModeAvailability, m) == Enum.HousingResult.Success
	end

	C_Timer.After(0, function()
		if alt and avail(alt) then
			safe(C_HouseEditor and C_HouseEditor.ActivateHouseEditorMode, alt)
			C_Timer.After(0, function()
				safe(C_HouseEditor and C_HouseEditor.ActivateHouseEditorMode, cur)
			end)
		else
			safe(C_HouseEditor and C_HouseEditor.ActivateHouseEditorMode, cur)
		end
	end)
end

local AXIS_ADVANCE = { X = 0, Y = 1, Z = 2 }

function API.RotateAxis(axis)
	local advances = AXIS_ADVANCE[axis]
	if advances == nil then return end
	if not API.IsExpertMode() or not API.IsExpertSelected() then return end

	local submode = Enum and Enum.HousingPrecisionSubmode
	if not submode then return end

	safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionSubmode, submode.Translate)
	safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionSubmode, submode.Rotate)

	for i = 1, advances do
		safe(C_HousingExpertMode and C_HousingExpertMode.SelectNextRotationAxis)
	end
end

local DEGREES_PER_SECOND = 45.0

function API.RotatePulse(degrees, onFinish)
	local function finish() if onFinish then onFinish() end end
	if not degrees or degrees == 0 then return finish() end
	if not API.IsExpertMode() or not API.IsExpertSelected() then return finish() end

	local incType = Enum and Enum.HousingIncrementType
	if not incType then return finish() end

	local dir       = degrees > 0 and incType.RotateRight or incType.RotateLeft
	local holdSecs  = math.abs(degrees) / DEGREES_PER_SECOND
	local startTime = GetTime()

	safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionIncrementingActive, dir, true)

	local watcher = CreateFrame("Frame")
	watcher:SetScript("OnUpdate", function(self)
		if GetTime() - startTime < holdSecs then return end
		self:SetScript("OnUpdate", nil)
		safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionIncrementingActive, dir, false)
		finish()
	end)
end

local BASIC_SNAP_DEGREES = 15

function API.RotateDegrees(degrees)
	if not degrees or degrees == 0 then return end
	if not API.IsSelected() and not API.IsPlacing() then return end

	local dir   = degrees > 0 and 1 or -1
	local steps = math.max(1, math.floor((math.abs(degrees) + BASIC_SNAP_DEGREES / 2) / BASIC_SNAP_DEGREES))

	for i = 1, steps do
		safe(C_HousingBasicMode and C_HousingBasicMode.RotateDecor, dir)
	end
end
