local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM   = NS.Systems.EditMode
local RP   = {}
EM.RotPanel = RP

local panel      = nil
local selAxis    = "X"
local rotLocked  = false
local trackedDeg = { X = 0, Y = 0, Z = 0 }
local selGUID    = nil
local AXES       = { "X", "Y", "Z" }

local BACKDROP = {
	bgFile   = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	edgeSize = 1,
	insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local function col(key, r, g, b, a)
	local t = NS.UI and NS.UI.Theme and NS.UI.Theme.colors
	local c = t and t[key]
	if c then return c[1], c[2], c[3], c[4] or 1 end
	return r, g, b, a or 1
end

local function makeBtn(parent, w, h)
	local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
	btn:SetSize(w, h)
	btn:SetBackdrop(BACKDROP)
	local r, g, b, a = col("row", 0.13, 0.13, 0.15, 1)
	local br, bg_, bb = col("border", 0.24, 0.24, 0.28, 1)
	btn:SetBackdropColor(r, g, b, a)
	btn:SetBackdropBorderColor(br, bg_, bb, 1)

	btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	btn.label:SetPoint("CENTER", 0, 0)

	btn:SetScript("OnEnter", function(self)
		local hr, hg, hb, ha = col("hover", 0.17, 0.17, 0.20, 1)
		self:SetBackdropColor(hr, hg, hb, ha)
	end)
	btn:SetScript("OnLeave", function(self)
		if self._sel then
			local ar, ag, ab = col("accentDark", 0.28, 0.24, 0.10, 1)
			self:SetBackdropColor(ar, ag, ab, 0.8)
		else
			self:SetBackdropColor(r, g, b, a)
		end
	end)
	btn:SetScript("OnMouseDown", function(self)
		self.label:SetPoint("CENTER", 1, -1)
	end)
	btn:SetScript("OnMouseUp", function(self)
		self.label:SetPoint("CENTER", 0, 0)
	end)
	return btn
end

local function refreshRows()
	if not panel then return end
	local ar, ag, ab = col("accent", 0.9, 0.72, 0.18, 1)
	local tr, tg, tb = col("text",   0.92, 0.92, 0.92, 1)
	local mr, mg, mb = col("textMuted", 0.65, 0.65, 0.68, 1)
	local bdr, bdg, bdb = col("border", 0.24, 0.24, 0.28, 1)
	local adr, adg, adb = col("accentDark", 0.28, 0.24, 0.10, 1)
	local rowr, rowg, rowb, rowa = col("row", 0.13, 0.13, 0.15, 1)

	for _, axis in ipairs(AXES) do
		local row = panel.rows[axis]
		if row then
			local sel = axis == selAxis
			row.axisBtn._sel = sel
			if sel then
				row.axisBtn.label:SetTextColor(ar, ag, ab)
				row.axisBtn:SetBackdropBorderColor(ar, ag, ab, 1)
				row.axisBtn:SetBackdropColor(adr, adg, adb, 0.8)
			else
				row.axisBtn.label:SetTextColor(tr, tg, tb)
				row.axisBtn:SetBackdropBorderColor(bdr, bdg, bdb, 1)
				row.axisBtn:SetBackdropColor(rowr, rowg, rowb, rowa)
			end

			local deg = trackedDeg[axis] % 360
			if deg < 0 then deg = deg + 360 end
			if sel then
				row.degTxt:SetTextColor(tr, tg, tb)
			else
				row.degTxt:SetTextColor(mr, mg, mb)
			end
			row.degTxt:SetText(string.format("%d°", deg))
		end
	end

	if panel.stepTxt then
		local mr2, mg2, mb2 = col("textMuted", 0.65, 0.65, 0.68, 1)
		panel.stepTxt:SetTextColor(mr2, mg2, mb2)
		panel.stepTxt:SetText("Step: " .. (EM.DB().rotPanelStep or 15) .. "°")
	end
end

local function doRotate(axis, degrees)
	if rotLocked then return end
	if axis ~= selAxis then
		selAxis = axis
		EM.API.RotateAxis(axis)
	end
	rotLocked = true
	C_Timer.After(0.08, function()
		EM.API.RotatePulse(degrees, function()
			trackedDeg[axis] = trackedDeg[axis] + degrees
			rotLocked = false
			refreshRows()
		end)
	end)
end

local function buildPanel()
	if panel then return end
	local expertFrame = HouseEditorFrame and HouseEditorFrame.ExpertDecorModeFrame
	if not expertFrame then return end

	panel = CreateFrame("Frame", nil, expertFrame, "BackdropTemplate")
	panel:SetSize(194, 182)
	panel:SetPoint("RIGHT", UIParent, "CENTER", 415, 0)
	panel:SetFrameStrata("MEDIUM")
	panel:SetFrameLevel(50)
	panel:SetMovable(true)
	panel:EnableMouse(true)
	panel:RegisterForDrag("LeftButton")
	panel:SetClampedToScreen(true)
	panel:SetScript("OnDragStart", panel.StartMoving)
	panel:SetScript("OnDragStop",  panel.StopMovingOrSizing)

	local bgR, bgG, bgB, bgA = col("bg",     0.045, 0.045, 0.05, 0.97)
	local aR,  aG,  aB       = col("accent", 0.9, 0.72, 0.18, 1)
	panel:SetBackdrop(BACKDROP)
	panel:SetBackdropColor(bgR, bgG, bgB, bgA)
	panel:SetBackdropBorderColor(aR, aG, aB, 0.55)

	local hdrR, hdrG, hdrB = col("header", 0.075, 0.075, 0.085, 1)
	local hdrBG = panel:CreateTexture(nil, "BACKGROUND", nil, 1)
	hdrBG:SetPoint("TOPLEFT",  panel, "TOPLEFT",   1, -1)
	hdrBG:SetPoint("TOPRIGHT", panel, "TOPRIGHT",  -1, -1)
	hdrBG:SetHeight(22)
	hdrBG:SetColorTexture(hdrR, hdrG, hdrB, 1)

	local titleTxt = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titleTxt:SetPoint("TOP", panel, "TOP", 0, -5)
	titleTxt:SetTextColor(aR, aG, aB)
	titleTxt:SetText("Rotation")

	local div1 = panel:CreateTexture(nil, "ARTWORK")
	div1:SetPoint("TOPLEFT",  panel, "TOPLEFT",  1, -22)
	div1:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -1, -22)
	div1:SetHeight(1)
	div1:SetColorTexture(aR, aG, aB, 0.28)

	panel.rows = {}

	for i, axis in ipairs(AXES) do
		local yOff = -(26 + (i - 1) * 46)
		local row  = CreateFrame("Frame", nil, panel)
		row:SetSize(178, 38)
		row:SetPoint("TOP", panel, "TOP", 0, yOff)

		local minus = makeBtn(row, 26, 28)
		minus:SetPoint("LEFT", row, "LEFT", 2, 0)
		minus.label:SetText("–")
		local tr, tg, tb = col("text", 0.92, 0.92, 0.92, 1)
		minus.label:SetTextColor(tr, tg, tb)
		minus:SetScript("OnClick", function()
			if rotLocked or not EM.API.IsExpertSelected() then return end
			doRotate(axis, -(EM.DB().rotPanelStep or 15))
		end)

		local axisBtn = makeBtn(row, 32, 32)
		axisBtn:SetPoint("LEFT", minus, "RIGHT", 4, 0)
		axisBtn.label:SetText(axis)
		axisBtn:SetScript("OnClick", function()
			if rotLocked or not EM.API.IsExpertSelected() then return end
			selAxis = axis
			EM.API.RotateAxis(axis)
			refreshRows()
		end)
		row.axisBtn = axisBtn

		local plus = makeBtn(row, 26, 28)
		plus:SetPoint("LEFT", axisBtn, "RIGHT", 4, 0)
		plus.label:SetText("+")
		plus.label:SetTextColor(tr, tg, tb)
		plus:SetScript("OnClick", function()
			if rotLocked or not EM.API.IsExpertSelected() then return end
			doRotate(axis, EM.DB().rotPanelStep or 15)
		end)

		local degTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		degTxt:SetPoint("LEFT", plus, "RIGHT", 6, 0)
		degTxt:SetWidth(48)
		degTxt:SetJustifyH("RIGHT")
		degTxt:SetText("0°")
		row.degTxt = degTxt

		panel.rows[axis] = row
	end

	local div2 = panel:CreateTexture(nil, "ARTWORK")
	div2:SetPoint("BOTTOMLEFT",  panel, "BOTTOMLEFT",  1, 20)
	div2:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -1, 20)
	div2:SetHeight(1)
	div2:SetColorTexture(aR, aG, aB, 0.2)

	local stepTxt = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	stepTxt:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 6, 5)
	panel.stepTxt = stepTxt

	local resetBtn = makeBtn(panel, 52, 18)
	resetBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -3, 3)
	resetBtn.label:SetText("Reset")
	local mr, mg, mb = col("textMuted", 0.65, 0.65, 0.68, 1)
	resetBtn.label:SetTextColor(mr, mg, mb)
	resetBtn:SetScript("OnClick", function()
		if not EM.API.IsExpertSelected() then return end
		local R = Enum and Enum.HousingPrecisionSubmode and Enum.HousingPrecisionSubmode.Rotate
		if R then EM.API.safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionSubmode, R) end
		EM.API.safe(C_HousingExpertMode and C_HousingExpertMode.ResetPrecisionChanges, false)
		trackedDeg = { X = 0, Y = 0, Z = 0 }
		refreshRows()
	end)

	if expertFrame.SubmodeBar and expertFrame.SubmodeBar.ResetButton then
		expertFrame.SubmodeBar.ResetButton:HookScript("OnClick", function()
			trackedDeg = { X = 0, Y = 0, Z = 0 }
			refreshRows()
		end)
	end

	panel:Hide()
	refreshRows()
end

function RP.GetTrackedDeg()
	return { X = trackedDeg.X, Y = trackedDeg.Y, Z = trackedDeg.Z }
end

function RP.Show()
	if not EM.On("rotPanel") then return end
	if not EM.API.IsExpertMode() or not EM.API.IsExpertSelected() then return end
	if not panel then buildPanel() end
	if not panel then return end

	local info = EM.API.safe(C_HousingExpertMode and C_HousingExpertMode.GetSelectedDecorInfo)
	local guid = info and info.decorGUID
	if guid ~= selGUID then
		trackedDeg = { X = 0, Y = 0, Z = 0 }
		selAxis    = "X"
		selGUID    = guid
	end

	refreshRows()
	panel:Show()
end

function RP.Hide()
	if rotLocked then
		local RL = Enum and Enum.HousingIncrementType and Enum.HousingIncrementType.RotateLeft
		local RR = Enum and Enum.HousingIncrementType and Enum.HousingIncrementType.RotateRight
		if RL then EM.API.safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionIncrementingActive, RL, false) end
		if RR then EM.API.safe(C_HousingExpertMode and C_HousingExpertMode.SetPrecisionIncrementingActive, RR, false) end
		rotLocked = false
	end
	if panel then panel:Hide() end
end

function RP.OnSelection()
	if EM.API.IsExpertMode() and EM.API.IsExpertSelected() then RP.Show() else RP.Hide() end
end

function RP.OnModeChange()
	if EM.API.IsExpertMode() and EM.API.IsExpertSelected() then RP.Show() else RP.Hide() end
end

function RP.Boot()
	local ef = HouseEditorFrame and HouseEditorFrame.ExpertDecorModeFrame
	if not ef then return end
	ef:HookScript("OnShow", function() C_Timer.After(0.1, RP.OnModeChange) end)
	ef:HookScript("OnHide", RP.Hide)
	if ef:IsShown() and EM.API.IsExpertSelected() then C_Timer.After(0.2, RP.Show) end
end
