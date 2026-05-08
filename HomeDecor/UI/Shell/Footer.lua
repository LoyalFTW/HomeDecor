local ADDON, NS = ...

NS.UI = NS.UI or {}

local C = NS.UI.Controls
local T = NS.UI.Theme and NS.UI.Theme.colors or {}

local unpack = unpack
local format = string.format
local mmin   = math.min
local mmax   = math.max
local floor  = math.floor

local ACCENT      = T.accent      or { 0.90, 0.72, 0.18, 1 }
local BORDER      = T.border      or { 0.24, 0.24, 0.28, 1 }
local TEXT_MUTED  = T.textMuted   or { 0.65, 0.65, 0.68, 1 }
local ACCENT_DARK = T.accentDark  or { 0.28, 0.24, 0.10, 1 }

local function Backdrop(f, bg, border)
	if C and C.Backdrop then C:Backdrop(f, bg, border) end
end

local function NewFS(parent, template)
	return parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
end

local function AttachFooter(f)
	if not f or f.HDFooter then return end

	local footer = CreateFrame("Frame", nil, f, "BackdropTemplate")
	Backdrop(footer, T.header, T.border)
	footer:SetPoint("BOTTOMLEFT",  f, "BOTTOMLEFT",   8,  8)
	footer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8,  8)
	footer:SetHeight(30)
	footer:SetFrameLevel((f:GetFrameLevel() or 0) + 2)
	f.HDFooter = footer

	local divTop = footer:CreateTexture(nil, "ARTWORK")
	divTop:SetColorTexture(BORDER[1], BORDER[2], BORDER[3], 0.8)
	divTop:SetHeight(1)
	divTop:SetPoint("TOPLEFT",  footer, "TOPLEFT",  0, 0)
	divTop:SetPoint("TOPRIGHT", footer, "TOPRIGHT", 0, 0)

	local levelCircle = CreateFrame("Frame", nil, footer, "BackdropTemplate")
	Backdrop(levelCircle, ACCENT_DARK, ACCENT)
	levelCircle:SetSize(24, 24)
	levelCircle:SetPoint("LEFT", footer, "LEFT", 8, 0)

	local levelFS = NewFS(levelCircle, "GameFontNormal")
	levelFS:SetPoint("CENTER", levelCircle, "CENTER", 0, 0)
	levelFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
	levelFS:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")

	local houseLvlFS = NewFS(footer, "GameFontNormalSmall")
	houseLvlFS:SetPoint("LEFT", levelCircle, "RIGHT", 7, 0)
	houseLvlFS:SetText("HOUSE LVL")
	houseLvlFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.9)
	houseLvlFS:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")

	local xpBarHolder = CreateFrame("Frame", nil, footer, "BackdropTemplate")
	Backdrop(xpBarHolder, T.progressBG or T.panel, T.border)
	xpBarHolder:SetHeight(18)
	xpBarHolder:SetPoint("LEFT",  houseLvlFS, "RIGHT", 10, 0)
	xpBarHolder:SetPoint("RIGHT", footer,     "CENTER", -60, 0)

	local xpGrad = xpBarHolder:CreateTexture(nil, "ARTWORK")
	xpGrad:SetPoint("TOPLEFT",    xpBarHolder, "TOPLEFT",    2, -2)
	xpGrad:SetPoint("BOTTOMLEFT", xpBarHolder, "BOTTOMLEFT", 2,  2)
	xpGrad:SetGradient("HORIZONTAL",
		CreateColor(ACCENT_DARK[1], ACCENT_DARK[2], ACCENT_DARK[3], 1),
		CreateColor(ACCENT[1],      ACCENT[2],      ACCENT[3],      1)
	)

	local xpFS = NewFS(xpBarHolder, "GameFontNormalSmall")
	xpFS:SetPoint("CENTER", xpBarHolder, "CENTER", 0, 0)
	xpFS:SetTextColor(1, 1, 1, 0.95)
	xpFS:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")

	local nextLvlFS = NewFS(footer, "GameFontNormalSmall")
	nextLvlFS:SetPoint("LEFT", xpBarHolder, "RIGHT", 8, 0)
	nextLvlFS:SetTextColor(TEXT_MUTED[1], TEXT_MUTED[2], TEXT_MUTED[3], 1)
	nextLvlFS:SetFont(STANDARD_TEXT_FONT, 10, "")

	local endSepLine = footer:CreateTexture(nil, "ARTWORK")
	endSepLine:SetColorTexture(BORDER[1], BORDER[2], BORDER[3], 0.8)
	endSepLine:SetWidth(1)
	endSepLine:SetHeight(16)
	endSepLine:SetPoint("LEFT", nextLvlFS, "RIGHT", 14, 0)

	local endLabelFS = NewFS(footer, "GameFontNormalSmall")
	endLabelFS:SetPoint("LEFT", endSepLine, "RIGHT", 12, 0)
	endLabelFS:SetText("ENDEAVORS")
	endLabelFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.9)
	endLabelFS:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")

	local MAX_DOTS    = 6
	local DOT_SIZE    = 10
	local DOT_SPACING = 4
	local dots        = {}

	for i = 1, MAX_DOTS do
		local dot = CreateFrame("Frame", nil, footer, "BackdropTemplate")
		dot:SetSize(DOT_SIZE, DOT_SIZE)
		if i == 1 then
			dot:SetPoint("LEFT", endLabelFS, "RIGHT", 8, 0)
		else
			dot:SetPoint("LEFT", dots[i - 1], "RIGHT", DOT_SPACING, 0)
		end
		Backdrop(dot, T.panel, T.border)
		dot.fill = dot:CreateTexture(nil, "ARTWORK")
		dot.fill:SetPoint("TOPLEFT",     dot, "TOPLEFT",     2, -2)
		dot.fill:SetPoint("BOTTOMRIGHT", dot, "BOTTOMRIGHT", -2, 2)
		dot.fill:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		dot.fill:Hide()
		dots[i] = dot
	end

	local daysFS = NewFS(footer, "GameFontNormalSmall")
	daysFS:SetPoint("LEFT", dots[MAX_DOTS], "RIGHT", 8, 0)
	daysFS:SetTextColor(TEXT_MUTED[1], TEXT_MUTED[2], TEXT_MUTED[3], 1)
	daysFS:SetFont(STANDARD_TEXT_FONT, 10, "")

	local couponSepLine = footer:CreateTexture(nil, "ARTWORK")
	couponSepLine:SetColorTexture(BORDER[1], BORDER[2], BORDER[3], 0.8)
	couponSepLine:SetWidth(1)
	couponSepLine:SetHeight(16)
	couponSepLine:SetPoint("RIGHT", footer, "RIGHT", -14, 0)

	local couponFS = NewFS(footer, "GameFontNormalSmall")
	couponFS:SetPoint("RIGHT", couponSepLine, "LEFT", -8, 0)
	couponFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.85)
	couponFS:SetFont(STANDARD_TEXT_FONT, 10, "")

	local couponIcon = footer:CreateTexture(nil, "OVERLAY")
	couponIcon:SetSize(14, 14)
	couponIcon:SetPoint("RIGHT", couponFS, "LEFT", -4, 0)

	local cachedLevel = nil
	local cachedXP    = 0
	local cachedMaxXP = 0

	local function RequestHouseLevelFavor()
		if not (C_Housing and C_Housing.GetCurrentHouseLevelFavor) then return end
		local Sys    = NS.Systems and NS.Systems.Endeavors
		local houses = Sys and Sys:GetHouseList()
		local idx    = Sys and Sys:GetSelectedHouseIndex()
		local house  = houses and houses[idx]
		if house and house.houseGUID then
			pcall(C_Housing.GetCurrentHouseLevelFavor, house.houseGUID)
		end
	end

	local function Refresh()

		if cachedLevel == nil then
			RequestHouseLevelFavor()
		end

		local level = cachedLevel or "?"
		levelFS:SetText(level)

		local barW = mmax(0, (xpBarHolder:GetWidth() or 200) - 4)
		local pct  = (cachedMaxXP > 0) and (cachedXP / cachedMaxXP) or 0
		xpGrad:SetWidth(mmax(2, barW * mmin(pct, 1)))
		if cachedMaxXP > 0 then
			xpFS:SetText(format("%.0f / %d XP", cachedXP, cachedMaxXP))
		else
			xpFS:SetText(format("%.0f XP", cachedXP))
		end

		if type(level) == "number" then
			nextLvlFS:SetText(format("\226\134\146 Lvl %d", level + 1))
		else
			nextLvlFS:SetText("")
		end

		local Sys = NS.Systems and NS.Systems.Endeavors
		if Sys then
			local info = Sys:GetEndeavorInfo()
			if info and (info.daysRemaining or 0) > 0 then
				local tasks = Sys:GetTasks() or {}
				local done  = 0
				for i = 1, #tasks do
					if tasks[i].completed then done = done + 1 end
				end

				local total    = #tasks
				local dotTotal = mmin(total, MAX_DOTS)
				for i = 1, MAX_DOTS do
					local dot = dots[i]
					if i <= dotTotal then
						dot:Show()
						if i <= done then
							dot.fill:Show()
						else
							dot.fill:Hide()
						end
					else
						dot:Hide()
					end
				end

				daysFS:SetText(format("%dd left", info.daysRemaining))
			else
				for i = 1, MAX_DOTS do dots[i]:Hide() end
				daysFS:SetText("")
			end

			local coupons = Sys:GetCommunityCoupons() or 0
			couponFS:SetText(coupons .. " Coupons")

			local iconID = Sys.GetCouponIconID and Sys:GetCouponIconID() or 134400
			if iconID and iconID > 0 then
				couponIcon:SetTexture(iconID)
				couponIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			end
		else
			for i = 1, MAX_DOTS do dots[i]:Hide() end
			daysFS:SetText("")
			couponFS:SetText("0 Coupons")
		end
	end

	footer:SetScript("OnShow", Refresh)
	f:HookScript("OnShow", Refresh)

	if C_Timer and C_Timer.NewTicker then
		footer._ticker = C_Timer.NewTicker(5, function()
			if footer:IsShown() then Refresh() end
		end)
	end

	do
		local evFrame = CreateFrame("Frame")
		evFrame:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED")
		evFrame:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
		evFrame:SetScript("OnEvent", function(_, event, ...)
			if event == "HOUSE_LEVEL_FAVOR_UPDATED" then
				local favor = ...
				if not favor then return end

				cachedLevel = favor.houseLevel or 1
				cachedXP    = favor.houseFavor or 0

				local maxLevel = 50
				if C_Housing and C_Housing.GetMaxHouseLevel then
					local ok, max = pcall(C_Housing.GetMaxHouseLevel)
					if ok and max then maxLevel = max end
				end

				if cachedLevel < maxLevel and C_Housing and C_Housing.GetHouseLevelFavorForLevel then
					local ok, needed = pcall(C_Housing.GetHouseLevelFavorForLevel, cachedLevel + 1)
					cachedMaxXP = (ok and needed) and needed or 0
				elseif C_Housing and C_Housing.GetHouseLevelFavorForLevel then

					local ok, needed = pcall(C_Housing.GetHouseLevelFavorForLevel, cachedLevel)
					cachedMaxXP = (ok and needed) and needed or 0
				end

				if footer:IsShown() then Refresh() end

			elseif event == "PLAYER_HOUSE_LIST_UPDATED" then

				cachedLevel = nil
				RequestHouseLevelFavor()
			end
		end)
	end

	do
		local hookSys = NS.Systems and NS.Systems.Endeavors
		if hookSys then
			local function WrapCallback(name)
				local prev = hookSys[name]
				hookSys[name] = function(...)
					if prev then prev(...) end
					if footer:IsShown() then Refresh() end
				end
			end
			WrapCallback("OnDataReady")
			WrapCallback("OnActivityLogReady")
			WrapCallback("OnHouseListUpdated")
		end
	end

	C_Timer.After(0.5, function()
		if C_Housing and C_Housing.GetPlayerOwnedHouses then
			pcall(C_Housing.GetPlayerOwnedHouses)
		end
	end)

	Refresh()
end

local origCreateShell = NS.UI.Layout and NS.UI.Layout.CreateShell
if origCreateShell then
	NS.UI.Layout.CreateShell = function(self, ...)
		local f = origCreateShell(self, ...)
		if f then AttachFooter(f) end
		return f
	end
end
