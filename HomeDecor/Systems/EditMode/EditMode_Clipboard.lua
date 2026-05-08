local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM  = NS.Systems.EditMode
local CB  = {}
EM.Clipboard = CB

local stored = nil

local function snapshotRotation()
	if not EM.API.IsExpertMode() then return nil end
	local rp = EM.RotPanel
	if not rp or not rp.GetTrackedDeg then return nil end
	local deg = rp.GetTrackedDeg()
	if not deg then return nil end
	if deg.X == 0 and deg.Y == 0 and deg.Z == 0 then return nil end
	return { X = deg.X, Y = deg.Y, Z = deg.Z }
end

local function replayRotation(rot)
	if not rot then return end
	local AXES = { "X", "Y", "Z" }
	local function applyNext(i)
		if i > #AXES then return end
		local axis = AXES[i]
		local deg  = rot[axis] or 0
		if deg == 0 then
			applyNext(i + 1)
			return
		end
		if not EM.API.IsExpertMode() then
			local expertMode = Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.ExpertDecor
			EM.API.safe(C_HouseEditor and C_HouseEditor.ActivateHouseEditorMode, expertMode)
			C_Timer.After(0.25, function()
				EM.API.RotateAxis(axis)
				C_Timer.After(0.08, function()
					EM.API.RotatePulse(deg, function() applyNext(i + 1) end)
				end)
			end)
		else
			EM.API.RotateAxis(axis)
			C_Timer.After(0.08, function()
				EM.API.RotatePulse(deg, function() applyNext(i + 1) end)
			end)
		end
	end
	C_Timer.After(0.3, function() applyNext(1) end)
end

function CB.Set(rid, name, icon, rot)
	if not rid then return false end
	stored = { rid = rid, name = name, icon = icon, rot = rot }
	return true
end

function CB.Get()   return stored end
function CB.Has()   return stored ~= nil end
function CB.Clear() stored = nil end

function CB.Copy()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	local info = EM.API.GetTargetInfo()
	if not info or not info.rid then return false end
	CB.Set(info.rid, info.name, info.icon, snapshotRotation())
	print("|cffffd100HomeDecor|r Copied: " .. (info.name or "Unknown"))
	return true
end

function CB.Cut()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	local info = EM.API.GetSelectedInfo()
	if not info or not info.rid then
		local hov = EM.API.GetHoveredInfo()
		if hov and hov.rid then
			CB.Set(hov.rid, hov.name, hov.icon, snapshotRotation())
			print("|cffffd100HomeDecor|r Cut: " .. (hov.name or "Unknown"))
		end
		return false
	end
	CB.Set(info.rid, info.name, info.icon, snapshotRotation())
	print("|cffffd100HomeDecor|r Cut: " .. (info.name or "Unknown"))
	EM.API.RemoveSelected()
	return true
end

function CB.Paste()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	if not CB.Has() then return false end
	local rot = stored.rot
	local name = stored.name or "Unknown"
	EM.API.BeginPlacement(stored.rid, function(ok)
		if ok then
			print("|cffffd100HomeDecor|r Pasted: " .. name)
			if rot then replayRotation(rot) end
		end
	end, true)
	return true
end

function CB.Duplicate()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	local info = EM.API.GetTargetInfo()
	if not info or not info.rid then return false end
	local rot = snapshotRotation()
	local name = info.name or "Unknown"
	EM.API.BeginPlacement(info.rid, function(ok)
		if ok then
			print("|cffffd100HomeDecor|r Duplicated: " .. name)
			if rot then replayRotation(rot) end
		end
	end, true)
	return true
end
