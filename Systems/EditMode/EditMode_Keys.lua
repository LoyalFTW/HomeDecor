local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM   = NS.Systems.EditMode
local Keys = {}
EM.Keys = Keys

local owner = nil

local function ensureOwner()
	if owner then return end
	owner = CreateFrame("Frame", nil, UIParent)

	local function proxy(name, fn)
		local btn = CreateFrame("Button", name, owner, "SecureActionButtonTemplate")
		btn:SetScript("OnClick", fn)
		return btn
	end

	Keys.btnCopy  = proxy("HD_EM_Copy",  function() if EM.API.EditorOpen() then EM.Clipboard.Copy()      end end)
	Keys.btnCut   = proxy("HD_EM_Cut",   function() if EM.API.EditorOpen() then EM.Clipboard.Cut()       end end)
	Keys.btnPaste = proxy("HD_EM_Paste", function() if EM.API.EditorOpen() then EM.Clipboard.Paste()     end end)
	Keys.btnDupe  = proxy("HD_EM_Dupe",  function() if EM.API.EditorOpen() then EM.Clipboard.Duplicate() end end)
	Keys.btnLock  = proxy("HD_EM_Lock",  function() if EM.API.EditorOpen() then EM.Lock.ToggleHovered()  end end)
end

function Keys.Apply()
	ensureOwner()
	ClearOverrideBindings(owner)
	if not EM.API.EditorOpen() then return end

	local function bind(key, btn)
		if key and key ~= "" then
			SetOverrideBindingClick(owner, true, key, btn:GetName())
		end
	end

	if EM.On("clipboard") then
		bind(EM.GetKeybind("copy"),      Keys.btnCopy)
		bind(EM.GetKeybind("cut"),       Keys.btnCut)
		bind(EM.GetKeybind("paste"),     Keys.btnPaste)
		bind(EM.GetKeybind("duplicate"), Keys.btnDupe)
	end

	if EM.On("lock") then
		bind(EM.GetKeybind("lock"), Keys.btnLock)
	end
end

function Keys.Clear()
	if owner then ClearOverrideBindings(owner) end
end
