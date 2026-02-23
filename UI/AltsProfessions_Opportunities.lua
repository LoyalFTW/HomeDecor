local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}

local SmartProfs = NS.UI.AltsProfessions
if not SmartProfs then return end

local C           = NS.UI.Controls
local Theme       = NS.UI.Theme
local T           = (Theme and Theme.colors) or {}
local PriceSource = NS.Systems and NS.Systems.PriceSource

local CreateFrame = CreateFrame
local format      = string.format
local tinsert     = table.insert
local sort        = table.sort
local pairs       = pairs
local ipairs      = ipairs

local PROFESSIONS = {
  "Alchemy", "Blacksmithing", "Cooking", "Enchanting",
  "Engineering", "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring",
}

local EXPANSION_ABBREVS = {
  "Classic", "TBC", "WotLK", "Cata", "MoP",
  "WoD", "Legion", "BfA", "SL", "DF", "TWW", "Mid",
}

local EXP_TO_SKILL_KEY = {
  Classic="Classic", TBC="TBC",    WotLK="WotLK",
  Cata="Cata",       MoP="MoP",    WoD="WoD",
  Legion="Legion",   BfA="BfA",    SL="SL",
  DF="DF",           TWW="TWW",    Mid="Mid",
}

local EXP_TO_SCANNER_KEY = {
  Classic="Classic",       TBC="Outland",      WotLK="Northrend",
  Cata="Cataclysm",        MoP="Pandaria",     WoD="Draenor",
  Legion="Legion",         BfA="Kul Tiran",    SL="Shadowlands",
  DF="Dragon Isles",       TWW="Khaz Algar",   Mid="Midnight",
}

local EXP_TO_DATA_KEY = {
  Classic="Classic",       TBC="Outland",      WotLK="Northrend",
  Cata="Cataclysm",        MoP="Pandaria",     WoD="Draenor",
  Legion="Legion",         BfA="Kul Tiran",    SL="Shadowlands",
  DF="Dragon Isles",       TWW="Khaz Algar",   Mid="Midnight",
}

local DATA_ALT_KEYS = {
  ["Dragon Isles"] = {"Dragon"}, ["Kul Tiran"]  = {"Kul"},
  ["Khaz Algar"]   = {"Khaz"},   ["Draenor"]    = {"Warlords"},
  ["Pandaria"]     = {"Pandaren"}, ["Midnight"] = {"Midnight"},
}

local CLOSE_THRESHOLD = 50
local NUM_EXPANSIONS  = 12

local TBTN_H   = 32
local TBTN_GAP = 6

local PW   = 110
local CW   = 63
local GAP  = 2
local CH   = 22
local RH   = 38
local RGAP = 2

local function ComputeColWidths(contentW)
  local avail = contentW - GAP * (NUM_EXPANSIONS - 1)
  local newPW = math.floor(avail * 0.17)
  local newCW = math.floor((avail - newPW) / NUM_EXPANSIONS)
  return newPW, newCW
end

local CELL_BG = {
  ready = {0.08, 0.32, 0.08, 0.92},
  close = {0.36, 0.18, 0.03, 0.92},
  far   = {0.06, 0.05, 0.02, 0.82},
  empty = {0.05, 0.04, 0.02, 0.72},
}
local CELL_BD = {
  ready = {0.22, 0.74, 0.22, 0.72},
  close = {0.90, 0.60, 0.14, 0.65},
  far   = {0.20, 0.16, 0.06, 0.52},
  empty = {0.12, 0.10, 0.04, 0.45},
  sel   = {1.00, 0.84, 0.20, 1.00},
}
local CELL_TC = {
  ready = {0.42, 0.96, 0.42, 1},
  close = {1.00, 0.75, 0.28, 1},
  far   = {0.72, 0.67, 0.52, 1},
  empty = {0.45, 0.43, 0.38, 0.90},
}

local ACCENT = T.accent or {1, 0.82, 0.2, 1}
local BORDER = T.border  or {0.2, 0.18, 0.08, 0.8}

local function ApplyBackdrop(f, bg, border)
  if not f or not f.SetBackdrop then return end
  f:SetBackdrop({
    bgFile   = "Interface/Buttons/WHITE8X8",
    edgeFile = border and "Interface/Buttons/WHITE8X8" or nil,
    edgeSize = border and 1 or 0,
  })
  f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
  if border then f:SetBackdropBorderColor(border[1], border[2], border[3], border[4]) end
end

local function FormatGold(copper)
  if not copper or copper == 0 then return "0g" end
  local sign = copper < 0 and "-" or ""
  copper = math.abs(copper)
  local g = copper / 10000
  if g >= 1000 then return sign..format("%.1fk", g/1000) end
  if g >= 1    then return sign..format("%.0fg", g) end
  return sign..format("%.0fs", copper/100)
end

local function GetAltsForCell(profName, expAbbrev)
  local PS = NS.Systems and NS.Systems.ProfessionScanner
  local PT = NS.Systems and NS.Systems.ProfessionTracker

  local scannerKey = EXP_TO_SCANNER_KEY[expAbbrev]
  local trackerKey = EXP_TO_SKILL_KEY[expAbbrev]
  if not scannerKey and not trackerKey then return {} end

  local out  = {}
  local seen = {}

  if PS and scannerKey then
    for charKey, charData in pairs(PS:GetAllCharacters() or {}) do
      if not seen[charKey] then
        local pData = charData.professions and charData.professions[profName]
        local sd    = pData and pData.skillLevels and pData.skillLevels[scannerKey]
        if sd then
          seen[charKey] = true
          local cur  = sd.current or 0
          local max  = math.max(1, sd.max or 1)
          local need = max - cur
          tinsert(out, {
            name    = SmartProfs.FormatCharName(charKey),
            current = cur,
            max     = max,
            pct     = math.min(1, cur / max),
            status  = cur >= max           and "ready"
                   or need <= CLOSE_THRESHOLD and "close"
                   or "far",
          })
        end
      end
    end
  end

  if PT and trackerKey then
    for charKey, charData in pairs(PT:GetAllCharacters() or {}) do
      if not seen[charKey] then
        local pData = charData.professions and charData.professions[profName]
        local sd    = pData and pData.skillLevels and pData.skillLevels[trackerKey]
        if sd then
          seen[charKey] = true
          local cur  = sd.current or 0
          local max  = math.max(1, sd.max or 1)
          local need = max - cur
          tinsert(out, {
            name    = SmartProfs.FormatCharName(charKey),
            current = cur,
            max     = max,
            pct     = math.min(1, cur / max),
            status  = cur >= max              and "ready"
                   or need <= CLOSE_THRESHOLD and "close"
                   or "far",
          })
        end
      end
    end
  end

  sort(out, function(a, b)
    local rank = {ready=0, close=1, far=2}
    if rank[a.status] ~= rank[b.status] then return rank[a.status] < rank[b.status] end
    return a.current > b.current
  end)
  return out
end

local function CellStatus(alts)
  if #alts == 0 then return "empty" end
  for _, a in ipairs(alts) do if a.status == "ready" then return "ready" end end
  for _, a in ipairs(alts) do if a.status == "close" then return "close" end end
  return "far"
end

local function GetRecipes(profName, expAbbrev)
  local dk = EXP_TO_DATA_KEY[expAbbrev]
  if not dk then return {} end
  local pd = NS.Data and NS.Data.Professions and NS.Data.Professions[profName]
  if not pd then return {} end

  local lists = {}
  if pd[dk] then tinsert(lists, pd[dk]) end
  for _, ak in ipairs(DATA_ALT_KEYS[dk] or {}) do
    if pd[ak] then tinsert(lists, pd[ak]) end
  end

  local seen, out = {}, {}
  for _, list in ipairs(lists) do
    for _, entry in ipairs(list) do
      if entry.source and entry.source.itemID and not seen[entry.source.itemID] then
        seen[entry.source.itemID] = true
        local id  = entry.source.itemID
        local mkt = PriceSource and PriceSource.GetItemPrice(id) or nil

        local name = entry.title
        if not name or name == "" then
          name = GetItemInfo(id)
          if not name then
            if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
            name = (GetItemInfoInstant and GetItemInfoInstant(id)) or ("Item #"..id)
          end
        end

        tinsert(out, { name=name, itemID=id, profit=mkt and (mkt * 0.6) or nil })
      end
    end
  end

  sort(out, function(a, b)
    if a.profit and b.profit then return a.profit > b.profit end
    return a.profit ~= nil
  end)
  return out
end

function SmartProfs:UpdateGridLayout(contentW)
  if not self.cells or not contentW or contentW < 50 then return end
  local newPW, newCW = ComputeColWidths(contentW)

  if self.colHeaders then
    for ci, h in ipairs(self.colHeaders) do
      h:ClearAllPoints()
      h:SetPoint("CENTER", h:GetParent(), "LEFT", newPW + (ci-1)*(newCW+GAP) + math.floor(newCW/2), 0)
    end
  end

  if self.rowLabels then
    for _, lbl in ipairs(self.rowLabels) do
      lbl:ClearAllPoints()
      lbl:SetPoint("RIGHT", lbl:GetParent(), "LEFT", newPW - 4, 0)
      lbl:SetWidth(newPW - 8)
    end
  end

  for ri = 1, #self.cells do
    for ci = 1, #(self.cells[ri] or {}) do
      local cell = self.cells[ri][ci]
      if cell then
        cell:SetSize(newCW, RH)
        cell:ClearAllPoints()
        cell:SetPoint("TOPLEFT", cell:GetParent(), "TOPLEFT", newPW + (ci-1)*(newCW+GAP), 0)
        if cell.subTxt then cell.subTxt:SetWidth(newCW - 4) end
      end
    end
  end
end

function SmartProfs:BuildOppsFrame()
  if self.oppsFrame then return end

  local opps = CreateFrame("Frame", nil, self.frame)
  opps:SetClipsChildren(true)
  opps:Hide()
  opps:SetPoint("TOPLEFT",     self.frame, "TOPLEFT",      10, -48)
  opps:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -10,  10)
  self.oppsFrame = opps

  local scroll = CreateFrame("ScrollFrame", nil, opps, "ScrollFrameTemplate")
  if C and C.SkinScrollFrame then C:SkinScrollFrame(scroll) end
  scroll:SetPoint("TOPLEFT",     opps, "TOPLEFT",      6,  -6)
  scroll:SetPoint("BOTTOMRIGHT", opps, "BOTTOMRIGHT", -24,  12)
  self.oppsScroll = scroll

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)
  scroll:SetScript("OnSizeChanged", function(sf, w)
    content:SetWidth(w)
    if self.UpdateGridLayout then self:UpdateGridLayout(w) end
  end)
  self.oppsContent = content

  local strip = CreateFrame("Frame", nil, content, BackdropTemplateMixin and "BackdropTemplate")
  ApplyBackdrop(strip, {0.04, 0.04, 0.06, 0.80}, T.border or {0.24, 0.24, 0.28, 1})
  strip:SetPoint("TOPLEFT",  content, "TOPLEFT",  0, 0)
  strip:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
  strip:SetHeight(36)

  local function StatPair(xOff, labelTxt, col)
    local val = strip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    val:SetPoint("LEFT", strip, "LEFT", xOff, 6)
    val:SetTextColor(col[1], col[2], col[3], 1)
    local lbl = strip:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("LEFT", strip, "LEFT", xOff, -7)
    lbl:SetText(labelTxt)
    lbl:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
    return val
  end
  self.readyCount = StatPair(14,  "READY NOW",       CELL_TC.ready)
  self.closeCount = StatPair(130, L["ALTS_CLOSE_SKL"], CELL_TC.close)

  local hint = strip:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  hint:SetPoint("RIGHT", strip, "RIGHT", -10, 0)
  hint:SetText(L["ALTS_CLICK_CELL_HINT"])
  hint:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))

  local headerRow = CreateFrame("Frame", nil, content)
  headerRow:SetPoint("TOPLEFT",  strip, "BOTTOMLEFT",  0, -4)
  headerRow:SetPoint("TOPRIGHT", strip, "BOTTOMRIGHT", 0, -4)
  headerRow:SetHeight(CH)

  self.colHeaders = {}
  for ci, ab in ipairs(EXPANSION_ABBREVS) do
    local xCenter = PW + (ci-1)*(CW+GAP) + math.floor(CW/2)
    local h = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h:SetPoint("CENTER", headerRow, "LEFT", xCenter, 0)
    h:SetText(ab)
    h:SetTextColor(1, 0.84, 0.4, 1)
    self.colHeaders[ci] = h
  end

  self.cells     = {}
  self.rowLabels = {}
  local prevAnchor = headerRow

  for ri, prof in ipairs(PROFESSIONS) do
    local row = CreateFrame("Frame", nil, content)
    row:SetPoint("TOPLEFT",  prevAnchor, "BOTTOMLEFT",  0, -RGAP)
    row:SetPoint("TOPRIGHT", prevAnchor, "BOTTOMRIGHT", 0, -RGAP)
    row:SetHeight(RH)

    local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("RIGHT", row, "LEFT", PW - 4, 0)
    lbl:SetWidth(PW - 8)
    lbl:SetText(prof)
    lbl:SetJustifyH("RIGHT")
    lbl:SetTextColor(1, 0.92, 0.7, 1)
    self.rowLabels[ri] = lbl

    self.cells[ri] = {}
    for ci, ab in ipairs(EXPANSION_ABBREVS) do
      local cell = CreateFrame("Button", nil, row, BackdropTemplateMixin and "BackdropTemplate")
      cell:SetSize(CW, RH)
      cell:SetPoint("TOPLEFT", row, "TOPLEFT", PW + (ci-1)*(CW+GAP), 0)
      ApplyBackdrop(cell, CELL_BG.empty, CELL_BD.empty)

      local topTxt = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      topTxt:SetPoint("TOP", cell, "TOP", 0, -5)
      topTxt:SetText("--")
      topTxt:SetTextColor(unpack(CELL_TC.empty))

      local subTxt = cell:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      subTxt:SetPoint("BOTTOM", cell, "BOTTOM", 0, 5)
      subTxt:SetWidth(CW - 4)
      subTxt:SetJustifyH("CENTER")
      subTxt:SetFont(STANDARD_TEXT_FONT or "Fonts/FRIZQT__.TTF", 11)
      subTxt:SetTextColor(unpack(CELL_TC.empty))

      cell.prof   = prof
      cell.exp    = ab
      cell.topTxt = topTxt
      cell.subTxt = subTxt
      cell.status = "empty"

      cell:SetScript("OnClick", function(b) self:CellClick(b) end)
      cell:SetScript("OnEnter", function(b)
        if not b.selected and b.SetBackdropBorderColor then
          b:SetBackdropBorderColor(unpack(CELL_BD.sel))
        end
      end)
      cell:SetScript("OnLeave", function(b)
        if not b.selected then self:ApplyCellColors(b) end
      end)

      self.cells[ri][ci] = cell
    end

    prevAnchor = row
  end

  local legend = CreateFrame("Frame", nil, content)
  legend:SetPoint("TOPLEFT",  prevAnchor, "BOTTOMLEFT",  0, -6)
  legend:SetPoint("TOPRIGHT", prevAnchor, "BOTTOMRIGHT", 0, -6)
  legend:SetHeight(14)

  local function LegendDot(xOff, r, g, b, txt)
    local dot = legend:CreateTexture(nil, "ARTWORK")
    dot:SetSize(8, 8)
    dot:SetPoint("LEFT", legend, "LEFT", PW + xOff, 0)
    dot:SetColorTexture(r, g, b, 0.9)
    local label = legend:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", legend, "LEFT", PW + xOff + 11, 0)
    label:SetText(txt)
    label:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
  end
  LegendDot(0, 0.22, 0.74, 0.22, L["ALTS_LEGEND_READY"])
  LegendDot(72, 0.90, 0.60, 0.14, L["ALTS_LEGEND_CLOSE"])
  LegendDot(178, 0.26, 0.20, 0.07, L["ALTS_LEGEND_FAR"])
  LegendDot(240, 0.10, 0.08, 0.04, L["ALTS_LEGEND_NONE"])

  local det = CreateFrame("Frame", nil, content, BackdropTemplateMixin and "BackdropTemplate")
  ApplyBackdrop(det, T.panel and {T.panel[1], T.panel[2], T.panel[3], 0.97} or {0.07, 0.07, 0.09, 0.97}, T.border or BORDER)
  det:SetPoint("TOPLEFT",  legend, "BOTTOMLEFT",  0, -8)
  det:SetPoint("TOPRIGHT", legend, "BOTTOMRIGHT", 0, -8)
  det:SetHeight(274)
  det:Hide()
  self.detPanel = det

  local function UpdateContentHeight()
    local h = 36 + 4 + CH + #PROFESSIONS * (RH + RGAP) + 6 + 14 + 8
    if det:IsShown() then h = h + 274 + 8 end
    content:SetHeight(h + 10)
  end
  det:SetScript("OnShow", UpdateContentHeight)
  det:SetScript("OnHide", UpdateContentHeight)
  UpdateContentHeight()

  local detHeader = CreateFrame("Frame", nil, det, BackdropTemplateMixin and "BackdropTemplate")
  ApplyBackdrop(detHeader, T.header and {T.header[1], T.header[2], T.header[3], 0.95} or {0.05, 0.05, 0.07, 0.95}, T.border or BORDER)
  detHeader:SetPoint("TOPLEFT",  det, "TOPLEFT",  0, 0)
  detHeader:SetPoint("TOPRIGHT", det, "TOPRIGHT", 0, 0)
  detHeader:SetHeight(28)

  local detTitle = detHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  detTitle:SetPoint("LEFT", detHeader, "LEFT", 10, 0)
  detTitle:SetTextColor(unpack(ACCENT))
  self.detTitle = detTitle

  local closeBtn = CreateFrame("Button", nil, detHeader, BackdropTemplateMixin and "BackdropTemplate")
  ApplyBackdrop(closeBtn, T.panel and {T.panel[1], T.panel[2], T.panel[3], 0.9} or {0.07, 0.07, 0.09, 0.9}, T.border or BORDER)
  closeBtn:SetSize(20, 20)
  closeBtn:SetPoint("RIGHT", detHeader, "RIGHT", -5, 0)
  local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  closeTxt:SetPoint("CENTER")
  closeTxt:SetText("x")
  closeTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
  closeBtn:SetScript("OnClick", function() self:CloseDetail() end)

  local altCol = CreateFrame("Frame", nil, det)
  altCol:SetPoint("TOPLEFT",    det, "TOPLEFT",    0, -28)
  altCol:SetPoint("BOTTOMLEFT", det, "BOTTOMLEFT", 0,   0)
  altCol:SetWidth(280)
  self.altCol = altCol

  local altColLbl = altCol:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  altColLbl:SetPoint("TOPLEFT", altCol, "TOPLEFT", 6, -5)
  altColLbl:SetText(L["ALTS_YOUR_ALTS"])
  altColLbl:SetTextColor(unpack(T.accent or {0.90, 0.72, 0.18, 1}))

  local recipeCol = CreateFrame("Frame", nil, det)
  recipeCol:SetPoint("TOPLEFT",     altCol, "TOPRIGHT",    1, 0)
  recipeCol:SetPoint("BOTTOMRIGHT", det,    "BOTTOMRIGHT", 0, 0)
  self.recipeCol = recipeCol

  local recipeColLbl = recipeCol:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  recipeColLbl:SetPoint("TOPLEFT", recipeCol, "TOPLEFT", 6, -5)
  recipeColLbl:SetText(L["ALTS_PROFITABLE_RECIPES"])
  recipeColLbl:SetTextColor(unpack(T.accent or {0.90, 0.72, 0.18, 1}))

  self.altRows = {}
  for i = 1, 8 do
    local row = CreateFrame("Frame", nil, altCol, BackdropTemplateMixin and "BackdropTemplate")
    ApplyBackdrop(row, {0, 0, 0, 0.22}, {0.12, 0.10, 0.04, 0.40})
    row:SetPoint("TOPLEFT",  altCol, "TOPLEFT",   4, -20 - (i-1)*22)
    row:SetPoint("TOPRIGHT", altCol, "TOPRIGHT", -4, -20 - (i-1)*22)
    row:SetHeight(20)
    row:Hide()

    local nameTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameTxt:SetPoint("LEFT", row, "LEFT", 6, 3)
    nameTxt:SetWidth(95)

    local skillTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    skillTxt:SetPoint("RIGHT", row, "RIGHT", -6, 3)
    skillTxt:SetJustifyH("RIGHT")

    local barBg = row:CreateTexture(nil, "BACKGROUND")
    barBg:SetColorTexture(0.07, 0.05, 0.02, 0.9)
    barBg:SetPoint("BOTTOMLEFT",  row, "BOTTOMLEFT",  6, 3)
    barBg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 3)
    barBg:SetHeight(3)

    local barFill = row:CreateTexture(nil, "ARTWORK")
    barFill:SetPoint("BOTTOMLEFT", barBg, "BOTTOMLEFT", 0, 0)
    barFill:SetHeight(3)

    local statusTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusTxt:SetPoint("RIGHT", row, "RIGHT", -6, -5)
    statusTxt:SetJustifyH("RIGHT")
    statusTxt:SetFont(STANDARD_TEXT_FONT or "Fonts/FRIZQT__.TTF", 10)

    row.nameTxt   = nameTxt
    row.skillTxt  = skillTxt
    row.barFill   = barFill
    row.statusTxt = statusTxt
    self.altRows[i] = row
  end

  self.recipeRows = {}
  for i = 1, 10 do
    local row = CreateFrame("Frame", nil, recipeCol, BackdropTemplateMixin and "BackdropTemplate")
    ApplyBackdrop(row, {0, 0, 0, 0.22}, {0.12, 0.10, 0.04, 0.40})
    row:SetPoint("TOPLEFT",  recipeCol, "TOPLEFT",   4, -20 - (i-1)*20)
    row:SetPoint("TOPRIGHT", recipeCol, "TOPRIGHT", -4, -20 - (i-1)*20)
    row:SetHeight(18)
    row:Hide()

    local bulletTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bulletTxt:SetPoint("LEFT", row, "LEFT", 4, 0)
    bulletTxt:SetWidth(12)

    local nameTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameTxt:SetPoint("LEFT", row, "LEFT", 18, 0)
    nameTxt:SetWidth(230)

    local profitTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profitTxt:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    profitTxt:SetJustifyH("RIGHT")

    row.bulletTxt = bulletTxt
    row.nameTxt   = nameTxt
    row.profitTxt = profitTxt
    self.recipeRows[i] = row
  end

  local trainerStrip = CreateFrame("Frame", nil, det, BackdropTemplateMixin and "BackdropTemplate")
  ApplyBackdrop(trainerStrip, T.header and {T.header[1], T.header[2], T.header[3], 0.92} or {0.05, 0.05, 0.07, 0.92}, T.border or BORDER)
  trainerStrip:SetPoint("BOTTOMLEFT",  det, "BOTTOMLEFT",  0, 0)
  trainerStrip:SetPoint("BOTTOMRIGHT", det, "BOTTOMRIGHT", 0, 0)
  trainerStrip:SetHeight(60)
  self.trainerStrip = trainerStrip

  local trainerLbl = trainerStrip:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  trainerLbl:SetPoint("TOPLEFT", trainerStrip, "TOPLEFT", 10, -5)
  trainerLbl:SetText(L["ALTS_TRAINER_LOCATIONS"])
  trainerLbl:SetTextColor(unpack(T.accent or {0.90, 0.72, 0.18, 1}))

  local TBTN_W = 210
  local FACTION_COLORS = {
    Alliance = {0.41, 0.69, 1.00, 1},
    Horde    = {1.00, 0.38, 0.38, 1},
    Neutral  = {0.90, 0.72, 0.18, 1},
  }
  local FACTION_BADGE_BG = {
    Alliance = {0.20, 0.40, 0.80, 0.90},
    Horde    = {0.70, 0.12, 0.12, 0.90},
    Neutral  = {0.50, 0.38, 0.06, 0.90},
  }

  local function OpenTrainerMap(worldmap)
    if not worldmap then return end
    local mapID, wx, wy = worldmap:match("^(%d+):(%d+):(%d+)$")
    mapID = tonumber(mapID); wx = tonumber(wx); wy = tonumber(wy)
    if not mapID then return end
    if C_Map and C_Map.OpenWorldMap then C_Map.OpenWorldMap(mapID) end
    C_Timer.After(0, function()
      if UiMapPoint and C_Map and C_Map.SetUserWaypoint and C_SuperTrack then
        local pt = UiMapPoint.CreateFromCoordinates(mapID, wx/10000, wy/10000)
        if pt then C_Map.SetUserWaypoint(pt); C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
      end
    end)
  end
  self.OpenTrainerMap = OpenTrainerMap

  self.trainerBtns = {}
  for ti = 1, 4 do
    local baseBG = T.panel and {T.panel[1]+0.03, T.panel[2]+0.03, T.panel[3]+0.04, 0.95}
                            or {0.11, 0.11, 0.14, 0.95}
    local btn = CreateFrame("Button", nil, trainerStrip, BackdropTemplateMixin and "BackdropTemplate")
    ApplyBackdrop(btn, baseBG, T.border or BORDER)
    btn:SetSize(TBTN_W, TBTN_H)
    btn:SetPoint("BOTTOMLEFT", trainerStrip, "BOTTOMLEFT", 10 + (ti-1)*(TBTN_W+TBTN_GAP), 4)
    btn:Hide()

    local fbar = btn:CreateTexture(nil, "ARTWORK")
    fbar:SetWidth(3)
    fbar:SetPoint("TOPLEFT",    btn, "TOPLEFT",    0, -1)
    fbar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0,  1)
    fbar:SetColorTexture(0.90, 0.72, 0.18, 1)

    local badge = CreateFrame("Frame", nil, btn, BackdropTemplateMixin and "BackdropTemplate")
    ApplyBackdrop(badge, {0.50, 0.38, 0.06, 0.90}, nil)
    badge:SetSize(22, 16)
    badge:SetPoint("LEFT", btn, "LEFT", 8, 0)
    local badgeTxt = badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    badgeTxt:SetPoint("CENTER")
    badgeTxt:SetText("N")
    badgeTxt:SetTextColor(1, 1, 1, 1)

    local nameTxt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameTxt:SetPoint("LEFT",  btn, "LEFT",  34,  1)
    nameTxt:SetPoint("RIGHT", btn, "RIGHT", -8,  1)
    nameTxt:SetJustifyH("LEFT")
    nameTxt:SetWordWrap(false)
    nameTxt:SetTextColor(unpack(T.text or {0.92, 0.92, 0.92, 1}))

    local zoneTxt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zoneTxt:SetPoint("LEFT",  btn, "LEFT",  34, -9)
    zoneTxt:SetPoint("RIGHT", btn, "RIGHT", -8, -9)
    zoneTxt:SetJustifyH("LEFT")
    zoneTxt:SetWordWrap(false)
    zoneTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))

    btn:SetScript("OnEnter", function()
      if btn.SetBackdropColor then btn:SetBackdropColor(unpack(T.hover or {0.17, 0.17, 0.20, 1})) end
      local td = btn.trainerData
      if not td then return end
      GameTooltip:SetOwner(btn, "ANCHOR_TOP")
      GameTooltip:ClearLines()
      GameTooltip:AddLine(td.name, 1, 1, 1)
      GameTooltip:AddLine(td.faction.."  |cffaaaaaa"..td.zone.."|r", 1, 1, 1)
      if td.note then GameTooltip:AddLine("("..td.note..")", 0.75, 0.75, 0.75) end
      GameTooltip:AddLine("|cffaaaaaa[Click]|r Set Waypoint & Open Map", 1, 1, 1)
      GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
      if btn.SetBackdropColor then btn:SetBackdropColor(unpack(baseBG)) end
      GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", function()
      if btn.trainerData then OpenTrainerMap(btn.trainerData.worldmap) end
    end)

    btn.fbar      = fbar
    btn.badge     = badge
    btn.badgeTxt  = badgeTxt
    btn.nameTxt   = nameTxt
    btn.zoneTxt   = zoneTxt
    btn.baseBG    = baseBG
    self.trainerBtns[ti] = btn
  end
end

function SmartProfs:ApplyCellColors(cell)
  local s = cell.status or "empty"
  if cell.SetBackdropColor then
    cell:SetBackdropColor(      unpack(CELL_BG[s] or CELL_BG.empty))
    cell:SetBackdropBorderColor(unpack(CELL_BD[s] or CELL_BD.empty))
  end
end

function SmartProfs:RefreshOppsGrid()
  if not self.cells then return end
  local ready, close = 0, 0

  for ri, prof in ipairs(PROFESSIONS) do
    for ci, ab in ipairs(EXPANSION_ABBREVS) do
      local cell = self.cells[ri] and self.cells[ri][ci]
      if cell then
        local alts   = GetAltsForCell(prof, ab)
        local status = CellStatus(alts)
        cell.status  = status
        cell.alts    = alts

        if status == "empty" then
          cell.topTxt:SetText("--")
          cell.topTxt:SetTextColor(unpack(CELL_TC.empty))
          cell.subTxt:SetText("")
          cell:Disable()
        else
          cell:Enable()
          local best  = alts[1]
          local short = best.name:sub(1, 7)

          cell.topTxt:SetText(best.current.."/"..best.max)
          cell.topTxt:SetTextColor(unpack(CELL_TC[status] or CELL_TC.far))

          if status == "ready" then
            cell.subTxt:SetText(short)
            cell.subTxt:SetTextColor(0.30, 0.68, 0.30, 1)
            ready = ready + 1
          elseif status == "close" then
            cell.subTxt:SetText("-"..(best.max - best.current).." "..short)
            cell.subTxt:SetTextColor(0.78, 0.50, 0.14, 1)
            close = close + 1
          else
            cell.subTxt:SetText(short)
            cell.subTxt:SetTextColor(0.72, 0.67, 0.52, 1)
          end
        end
        self:ApplyCellColors(cell)
      end
    end
  end

  if self.readyCount then self.readyCount:SetText(tostring(ready)) end
  if self.closeCount then self.closeCount:SetText(tostring(close)) end
end

function SmartProfs:CellClick(cell)
  if self.selectedCell and self.selectedCell ~= cell then
    self.selectedCell.selected = false
    self:ApplyCellColors(self.selectedCell)
  end
  if self.selectedCell == cell then
    self.selectedCell  = nil
    cell.selected      = false
    self:ApplyCellColors(cell)
    if self.detPanel then self.detPanel:Hide() end
    return
  end
  self.selectedCell = cell
  cell.selected     = true
  if cell.SetBackdropBorderColor then cell:SetBackdropBorderColor(unpack(CELL_BD.sel)) end
  self:PopulateDetail(cell.prof, cell.exp, cell.alts or {})
end

function SmartProfs:CloseDetail()
  if self.selectedCell then
    self.selectedCell.selected = false
    self:ApplyCellColors(self.selectedCell)
    self.selectedCell = nil
  end
  if self.detPanel then self.detPanel:Hide() end
end

function SmartProfs:PopulateDetail(prof, ab, alts)
  if not self.detPanel then return end
  if self.detTitle then self.detTitle:SetText(prof.."  -  "..ab) end

  for i, row in ipairs(self.altRows) do
    local a = alts[i]
    if a then
      row:Show()
      local col = CELL_TC[a.status] or CELL_TC.far
      row.nameTxt:SetText(a.name)
      row.nameTxt:SetTextColor(unpack(col))
      row.skillTxt:SetText(a.current.."/"..a.max)
      row.skillTxt:SetTextColor(unpack(col))

      if a.status == "ready" then
        row.barFill:SetColorTexture(0.20, 0.72, 0.20, 0.9)
        row.statusTxt:SetText("ready")
        row.statusTxt:SetTextColor(0.28, 0.70, 0.28, 1)
      elseif a.status == "close" then
        row.barFill:SetColorTexture(0.82, 0.44, 0.10, 0.9)
        row.statusTxt:SetText((a.max - a.current).." needed")
        row.statusTxt:SetTextColor(0.80, 0.52, 0.14, 1)
      else
        row.barFill:SetColorTexture(0.26, 0.20, 0.07, 0.7)
        row.statusTxt:SetText((a.max - a.current).." needed")
        row.statusTxt:SetTextColor(0.68, 0.58, 0.32, 1)
      end

      local pct = a.pct
      C_Timer.After(0, function()
        if row:IsShown() then
          local w = row:GetWidth() - 12
          if w and w > 0 then row.barFill:SetWidth(math.max(1, w * pct)) end
        end
      end)
    else
      row:Hide()
    end
  end

  local recipes = GetRecipes(prof, ab)
  for i, row in ipairs(self.recipeRows) do
    local rec = recipes[i]
    if rec then
      row:Show()
      row.bulletTxt:SetText("-")
      row.bulletTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
      row.nameTxt:SetText(rec.name)
      row.nameTxt:SetTextColor(unpack(T.text or {0.92, 0.92, 0.92, 1}))
      if rec.profit then
        row.profitTxt:SetText("+"..FormatGold(rec.profit))
        row.profitTxt:SetTextColor(unpack(T.accent or {0.90, 0.72, 0.18, 1}))
      else
        row.profitTxt:SetText("--")
        row.profitTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
      end
    else
      row:Hide()
    end
  end

  if self.trainerBtns then
    local dataKey = EXP_TO_DATA_KEY[ab]
    local trainers = NS.Data and NS.Data.Trainers
                  and NS.Data.Trainers[prof]
                  and dataKey and NS.Data.Trainers[prof][dataKey]
                  or {}

    local FACTION_LETTER = { Alliance="A", Horde="H", Neutral="N" }
    local FACTION_COLORS = {
      Alliance = {0.41, 0.69, 1.00, 1},
      Horde    = {1.00, 0.38, 0.38, 1},
      Neutral  = {0.90, 0.72, 0.18, 1},
    }
    local FACTION_BADGE_BG = {
      Alliance = {0.20, 0.40, 0.80, 0.90},
      Horde    = {0.70, 0.12, 0.12, 0.90},
      Neutral  = {0.50, 0.38, 0.06, 0.90},
    }
    local NPCNames = NS.Systems and NS.Systems.NPCNames

    local ti = 1
    for _, entry in ipairs(trainers) do
      local btn = self.trainerBtns[ti]
      if not btn then break end
      local src    = entry.source
      local fac    = src.faction or "Neutral"
      local col    = FACTION_COLORS[fac]    or FACTION_COLORS.Neutral
      local bgcol  = FACTION_BADGE_BG[fac]  or FACTION_BADGE_BG.Neutral
      local npcID  = src.id
      local fallback = src.name or ("NPC #"..tostring(npcID))

      if btn.fbar     then btn.fbar:SetColorTexture(unpack(col)) end
      if btn.badge    then ApplyBackdrop(btn.badge, {bgcol[1], bgcol[2], bgcol[3], bgcol[4]}, nil) end
      if btn.badgeTxt then btn.badgeTxt:SetText(FACTION_LETTER[fac] or "N"); btn.badgeTxt:SetTextColor(1,1,1,1) end
      if btn.zoneTxt  then btn.zoneTxt:SetText(src.zone or "") end

      local function ApplyName(name)
        local display = name or fallback
        if btn.nameTxt    then btn.nameTxt:SetText(display) end
        if btn.trainerData then btn.trainerData.name = display end
      end
      ApplyName(NPCNames and NPCNames.Get(npcID, function(_, n) ApplyName(n) end))

      btn.trainerData = {
        name     = fallback,
        faction  = fac,
        zone     = src.zone or "",
        worldmap = src.worldmap,
        note     = src.note,
      }
      btn:Show()
      ti = ti + 1
    end
    for i = ti, #self.trainerBtns do self.trainerBtns[i]:Hide() end

    local visCount = ti - 1
    if visCount > 0 and self.trainerStrip then
      local stripW = self.trainerStrip:GetWidth() or 0
      if stripW > 0 then
        local btnW = math.max(120, math.min(280, math.floor((stripW - 20 - TBTN_GAP * (visCount-1)) / visCount)))
        for bi = 1, visCount do
          local b = self.trainerBtns[bi]
          b:SetSize(btnW, TBTN_H)
          b:ClearAllPoints()
          b:SetPoint("BOTTOMLEFT", self.trainerStrip, "BOTTOMLEFT", 10 + (bi-1)*(btnW+TBTN_GAP), 6)
        end
      end
    end

    if self.trainerStrip then self.trainerStrip:SetShown(#trainers > 0) end
  end

  self.detPanel:Show()

  C_Timer.After(0.05, function()
    if self.oppsScroll and self.detPanel and self.detPanel:IsShown() then
      self.oppsScroll:SetVerticalScroll(self.oppsScroll:GetVerticalScrollRange())
    end
  end)
end

local origCreate = SmartProfs.Create

function SmartProfs:Create(parent)
  local ret = origCreate(self, parent)

  self:BuildOppsFrame()

  local hdr = CreateFrame("Frame", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate")
  hdr:SetPoint("TOPLEFT",  self.frame, "TOPLEFT",  0, -16)
  hdr:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, -16)
  hdr:SetHeight(32)
  ApplyBackdrop(hdr,
    T.header and {T.header[1], T.header[2], T.header[3], 0.97} or {0.075, 0.075, 0.085, 0.97},
    T.accent  and {T.accent[1],  T.accent[2],  T.accent[3],  0.40} or {0.90,  0.72,  0.18,  0.40})

  local stripe = hdr:CreateTexture(nil, "ARTWORK")
  stripe:SetSize(3, 20)
  stripe:SetPoint("LEFT", hdr, "LEFT", 10, 0)
  stripe:SetColorTexture(unpack(T.accent or {0.90, 0.72, 0.18, 1}))

  local sectionLbl = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sectionLbl:SetPoint("LEFT", stripe, "RIGHT", 8, 0)
  sectionLbl:SetText(L["ALTS_SECTION_LABEL"])
  sectionLbl:SetTextColor(unpack(T.accentBright or {1, 0.95, 0.6, 1}))

  local TAB_W, TAB_H = 130, 28

  local function MakeTab(label)
    local btn = CreateFrame("Button", nil, hdr, BackdropTemplateMixin and "BackdropTemplate")
    btn:SetSize(TAB_W, TAB_H)
    ApplyBackdrop(btn,
      T.panel  and {T.panel[1],  T.panel[2],  T.panel[3],  0.92} or {0.095, 0.095, 0.11, 0.92},
      T.border and {T.border[1], T.border[2], T.border[3], 0.70} or {0.24,  0.24,  0.28, 0.70})
    if C and C.SkinButton then C:SkinButton(btn, true) end

    btn:SetScript("OnEnter", function()
      if not btn.active and btn.SetBackdropColor then
        btn:SetBackdropColor(unpack(T.hover or {0.17, 0.17, 0.20, 1}))
      end
    end)
    btn:SetScript("OnLeave", function()
      if not btn.active and btn.SetBackdropColor then
        btn:SetBackdropColor(unpack(T.panel or {0.095, 0.095, 0.11, 0.92}))
      end
    end)

    local labelTxt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelTxt:SetPoint("CENTER", btn, "CENTER", 0, 0)
    labelTxt:SetText(label)
    labelTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
    btn.labelTxt = labelTxt

    local underline = btn:CreateTexture(nil, "OVERLAY")
    underline:SetHeight(2)
    underline:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  1, 0)
    underline:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 0)
    underline:SetColorTexture(unpack(T.accent or {0.90, 0.72, 0.18, 1}))
    underline:Hide()
    btn.underline = underline

    return btn
  end

  local oppsTab    = MakeTab("Opportunities")
  local trackerTab = MakeTab("Item Tracker")
  oppsTab:SetPoint("RIGHT",    trackerTab, "LEFT",  -4, 0)
  trackerTab:SetPoint("RIGHT", hdr,        "RIGHT", -6, 0)

  local function SetTabActive(btn, active)
    btn.active = active
    if active then
      ApplyBackdrop(btn,
        T.accentDark and {T.accentDark[1], T.accentDark[2], T.accentDark[3], 0.95} or {0.28, 0.24, 0.10, 0.95},
        T.accent     and {T.accent[1],     T.accent[2],     T.accent[3],     0.85} or {0.90, 0.72, 0.18, 0.85})
      btn.labelTxt:SetTextColor(unpack(T.accentBright or {1, 0.95, 0.6, 1}))
      btn.underline:Show()
    else
      ApplyBackdrop(btn,
        T.panel  and {T.panel[1],  T.panel[2],  T.panel[3],  0.92} or {0.095, 0.095, 0.11, 0.92},
        T.border and {T.border[1], T.border[2], T.border[3], 0.70} or {0.24,  0.24,  0.28, 0.70})
      btn.labelTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
      btn.underline:Hide()
    end
  end

  local function ActivateTracker()
    if self.controlsFrame then self.controlsFrame:Show() end
    if self.leftPanel      then self.leftPanel:Show()    end
    if self.rightPanel     then self.rightPanel:Show()   end
    if self.oppsFrame      then self.oppsFrame:Hide()    end
    SetTabActive(trackerTab, true)
    SetTabActive(oppsTab,    false)
  end

  local function DoOppsLayout()
    if not self.oppsFrame or not self.oppsFrame:IsShown() then return end
    local w = self.oppsScroll and self.oppsScroll:GetWidth()
    if w and w > 50 then
      self:UpdateGridLayout(w)
      self:RefreshOppsGrid()
    else
      C_Timer.After(0, function()
        if self.oppsFrame and self.oppsFrame:IsShown() then
          local w2 = self.oppsScroll and self.oppsScroll:GetWidth()
          if w2 and w2 > 50 then self:UpdateGridLayout(w2) end
          self:RefreshOppsGrid()
        end
      end)
    end
  end

  local function ActivateOpps()
    if self.controlsFrame then self.controlsFrame:Hide() end
    if self.leftPanel      then self.leftPanel:Hide()    end
    if self.rightPanel     then self.rightPanel:Hide()   end
    if not self.oppsFrame  then self:BuildOppsFrame()    end
    if self.oppsFrame      then self.oppsFrame:Show(); DoOppsLayout() end
    SetTabActive(oppsTab,    true)
    SetTabActive(trackerTab, false)
  end

  trackerTab:SetScript("OnClick", ActivateTracker)
  oppsTab:SetScript("OnClick",    ActivateOpps)

  self.activateOpps    = ActivateOpps
  self.activateTracker = ActivateTracker

  if self.controlsFrame then self.controlsFrame:Hide() end
  if self.leftPanel      then self.leftPanel:Hide()    end
  if self.rightPanel     then self.rightPanel:Hide()   end
  SetTabActive(oppsTab,    true)
  SetTabActive(trackerTab, false)

  self.frame:HookScript("OnShow", function()
    if self.activateOpps then self.activateOpps() end
  end)

  return ret
end

local origRefresh = SmartProfs.Refresh
function SmartProfs:Refresh()
  origRefresh(self)
  if self.oppsFrame and self.oppsFrame:IsShown() then
    self:RefreshOppsGrid()
  end
end

return SmartProfs
