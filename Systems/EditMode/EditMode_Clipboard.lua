local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM  = NS.Systems.EditMode
local CB  = {}
EM.Clipboard = CB

local stored = nil

function CB.Set(rid, name, icon)
	if not rid then return false end
	stored = { rid = rid, name = name, icon = icon }
	return true
end

function CB.Get()   return stored end
function CB.Has()   return stored ~= nil end
function CB.Clear() stored = nil end

function CB.Copy()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	local info = EM.API.GetTargetInfo()
	if not info or not info.rid then return false end
	CB.Set(info.rid, info.name, info.icon)
	return true
end

function CB.Cut()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	local info = EM.API.GetSelectedInfo()
	if not info or not info.rid then
		local hov = EM.API.GetHoveredInfo()
		if hov and hov.rid then CB.Set(hov.rid, hov.name, hov.icon) end
		return false
	end
	CB.Set(info.rid, info.name, info.icon)
	EM.API.RemoveSelected()
	return true
end

function CB.Paste()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	if not CB.Has() then return false end
	EM.API.BeginPlacement(stored.rid, nil, true)
	return true
end

function CB.Duplicate()
	if not EM.On("clipboard") or not EM.API.EditorOpen() then return false end
	local info = EM.API.GetTargetInfo()
	if not info or not info.rid then return false end
	EM.API.BeginPlacement(info.rid, nil, true)
	return true
end
