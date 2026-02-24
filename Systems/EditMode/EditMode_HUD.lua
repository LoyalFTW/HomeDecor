local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM  = NS.Systems.EditMode
local HUD = {}
EM.HUD = HUD

local root      = nil
local curAlpha  = 0
local CTRL_KEY  = CTRL_KEY_TEXT  or "Ctrl"
local SHIFT_KEY = SHIFT_KEY_TEXT or "Shift"

local function tc()
	local c = NS.UI and NS.UI.Theme and NS.UI.Theme.colors
	return c or {}
end

local function buildLine(parent, label, key)
	local f = CreateFrame("Frame", nil, parent)
	f:SetSize(420, 44)

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetAtlas("housing-hotkey-icon-key-9slice")
	bg:SetSize(54, 40)
	bg:SetPoint("RIGHT", f, "RIGHT", 0, 0)
	f.keybg = bg

	local keyTxt = f:CreateFontString(nil, "ARTWORK", "Number16Font")
	keyTxt:SetPoint("CENTER", bg, "CENTER", 0, 0)
	keyTxt:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
	keyTxt:SetText(key)
	f.keyTxt = keyTxt

	local lbl = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	lbl:SetJustifyH("RIGHT")
	lbl:SetText(label)
	f.lbl = lbl

	return f
end

local function normalizeWidths(lines)
	local maxW = 0
	for _, ln in ipairs(lines) do
		local w = ln.keyTxt:GetStringWidth() + 22
		if w > maxW then maxW = w end
	end
	for _, ln in ipairs(lines) do
		ln.keybg:SetWidth(maxW)
		ln.lbl:ClearAllPoints()
		ln.lbl:SetPoint("RIGHT", ln, "RIGHT", -(maxW + 10), 0)
	end
end

local function hintsForCurrentState()
	local c = CTRL_KEY
	local s = SHIFT_KEY
	return {
		{ feat = "clipboard",  label = "Copy",        key = c.."+C" },
		{ feat = "clipboard",  label = "Cut",         key = c.."+X" },
		{ feat = "clipboard",  label = "Paste",       key = c.."+V" },
		{ feat = "clipboard",  label = "Duplicate",   key = c.."+D" },
		{ feat = "batchPlace", label = "Batch Place", key = c       },
		{ feat = "lock",       label = "Lock / Unlock", key = "L"   },
	}
end

local function buildHUD()
	if root then return end
	local basic = HouseEditorFrame and HouseEditorFrame.BasicDecorModeFrame
	if not basic then return end
	local panel = basic.Instructions
	if not panel then return end

	root = CreateFrame("Frame", nil, basic)
	root:SetSize(420, 300)
	root:SetPoint("TOPRIGHT", panel, "BOTTOMRIGHT", 0, -4)
	root:SetAlpha(0)
	root:Hide()
	root.lines = {}
	curAlpha = 0

	local hints = hintsForCurrentState()
	for i, h in ipairs(hints) do
		local ln = buildLine(root, h.label, h.key)
		ln.feat = h.feat
		if i == 1 then
			ln:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)
		else
			ln:SetPoint("TOPRIGHT", root.lines[i - 1], "BOTTOMRIGHT", 0, 0)
		end
		ln:Hide()
		table.insert(root.lines, ln)
	end
	normalizeWidths(root.lines)
end

local function setAlpha(target)
	if not root then return end
	if math.abs(curAlpha - target) < 0.01 then
		root:SetAlpha(target)
		curAlpha = target
		root:SetShown(target > 0)
		return
	end
	if target > 0 then root:Show() end
	local speed = target > curAlpha and 7 or 3
	local start = curAlpha
	local t = 0
	root:SetScript("OnUpdate", function(self, dt)
		t = t + dt
		local frac = math.min(t * speed, 1)
		local val  = start + (target - start) * frac
		self:SetAlpha(val)
		if frac >= 1 then
			self:SetScript("OnUpdate", nil)
			curAlpha = target
			if target == 0 then self:Hide() end
		end
	end)
	curAlpha = target
end

function HUD.Refresh()
	if not root then return end
	if not EM.On("hud") or not EM.API.EditorOpen() then
		setAlpha(0)
		return
	end

	local anyVisible = false
	local prev = nil
	for _, ln in ipairs(root.lines) do
		local show = EM.On(ln.feat)
		if show then
			ln:Show()
			ln:ClearAllPoints()
			if not prev then
				ln:SetPoint("TOPRIGHT", root, "TOPRIGHT", 0, 0)
			else
				ln:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT", 0, 0)
			end
			prev = ln
			anyVisible = true
		else
			ln:Hide()
		end
	end

	if not anyVisible then setAlpha(0) return end

	
	setAlpha(1)
end

function HUD.Boot()
	buildHUD()
	HUD.Refresh()
end

function HUD.Destroy()
	if root then
		root:Hide()
		root = nil
		curAlpha = 0
	end
end
