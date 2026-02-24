local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM   = NS.Systems.EditMode
local Lock = {}
EM.Lock = Lock

local bouncing = false

local function store()
	local db = EM.DB()
	db.locks = db.locks or {}
	return db.locks
end

function Lock.Has(guid)
	if not guid then return false end
	return store()[guid] ~= nil
end

function Lock.Add(guid, name)
	if not guid then return end
	store()[guid] = { name = name or "?", t = time() }
end

function Lock.Remove(guid)
	if not guid then return end
	store()[guid] = nil
end

function Lock.ToggleHovered()
	if not EM.On("lock") or not EM.API.EditorOpen() then return end
	local info = EM.API.GetHoveredInfo()
	if not info or not info.guid then return end
	if Lock.Has(info.guid) then
		Lock.Remove(info.guid)
		print("|cffffd100HomeDecor|r Unlocked: " .. (info.name or "Unknown"))
	else
		Lock.Add(info.guid, info.name)
		print("|cffffd100HomeDecor|r Locked: " .. (info.name or "Unknown"))
	end
	if EM.HUD then EM.HUD.Refresh() end
end

local POPUP = "HD_EM_LOCKED"

local function ensurePopup()
	if StaticPopupDialogs[POPUP] then return end
	StaticPopupDialogs[POPUP] = {
		text          = "|TInterface\\AddOns\\HomeDecor\\Media\\UI\\logo.tga:0|t  This decoration is locked:\n\n|cffffd100%s|r\n\nWhat do you want to do?",
		button1       = "Edit Anyway",
		button2       = "Cancel",
		button3       = "Unlock",
		timeout       = 0,
		whileDead     = true,
		hideOnEscape  = true,
		showAlert     = false,
		preferredIndex = 3,
		OnCancel = function(_, data, reason)
			if reason == "clicked" then EM.API.CancelEditing() end
		end,
		OnAlt = function(_, data)
			if data then
				local name = data and store()[data] and store()[data].name or "Unknown"
				Lock.Remove(data)
				print("|cffffd100HomeDecor|r Unlocked: " .. name)
			end
		end,
	}
end

function Lock.OnSelected(hasSelected)
	if not hasSelected or not EM.On("lock") or bouncing then return end
	local info = EM.API.GetSelectedInfo()
	if not info or not info.guid or not Lock.Has(info.guid) then return end
	EM.API.CancelEditing()
	bouncing = true
	EM.API.BounceMode()
	C_Timer.After(0.2, function() bouncing = false end)
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST or 857)
	ensurePopup()
	StaticPopup_Show(POPUP, info.name or "Unknown", nil, info.guid)
end
