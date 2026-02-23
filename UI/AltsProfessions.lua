local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}

local SmartProfs = {}
NS.UI.AltsProfessions = SmartProfs

local C           = NS.UI.Controls
local Theme       = NS.UI.Theme
local T           = (Theme and Theme.colors) or {}
local PriceSource = NS.Systems.PriceSource

local CreateFrame = CreateFrame
local format      = string.format
local tinsert     = table.insert
local sort        = table.sort
local pairs       = pairs
local ipairs      = ipairs

local IA, TT

local PROFESSIONS = {
  "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering",
  "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring",
}

local EXPANSIONS = {
  "Classic", "Outland", "Northrend", "Cataclysm", "Pandaria",
  "Draenor", "Legion", "Kul Tiran", "Shadowlands", "Dragon Isles", "Khaz Algar", "Midnight",
}

local EXPANSION_ABBREV = {
  Classic       = "Classic",  Outland        = "TBC",   Northrend      = "WotLK",
  Cataclysm     = "Cata",     Pandaria        = "MoP",   Draenor        = "WoD",
  Legion        = "Legion",   ["Kul Tiran"]  = "BfA",   Shadowlands    = "SL",
  ["Dragon Isles"] = "DF",    ["Khaz Algar"] = "TWW",   Midnight       = "Mid",
}

local EXPANSION_ALT_KEYS = {
  ["Dragon Isles"] = {"Dragon"}, ["Kul Tiran"]  = {"Kul"},
  ["Khaz Algar"]   = {"Khaz"},   ["Draenor"]    = {"Warlords"},
  ["Pandaria"]     = {"Pandaren"}, ["Midnight"] = {"Midnight"},
}

local LUMBER_IDS = {
  [245586]=true, [242691]=true, [251762]=true, [251764]=true, [251763]=true,
  [251766]=true, [251767]=true, [251768]=true, [251772]=true, [251773]=true,
  [248012]=true, [256963]=true,
}

local CLASS_COLORS = {
  WARRIOR={0.78,0.61,0.43}, PALADIN={0.96,0.55,0.73},    HUNTER={0.67,0.83,0.45},
  ROGUE={1.0,0.96,0.41},    PRIEST={1.0,1.0,1.0},         DEATHKNIGHT={0.77,0.12,0.23},
  SHAMAN={0.0,0.44,0.87},   MAGE={0.41,0.8,0.94},         WARLOCK={0.58,0.51,0.79},
  MONK={0.0,1.0,0.59},      DRUID={1.0,0.49,0.04},        DEMONHUNTER={0.64,0.19,0.79},
  EVOKER={0.2,0.58,0.5},
}

local QUALITY_COLORS = {
  [0]={0.62,0.62,0.62}, [1]={1,1,1},          [2]={0.12,1,0},
  [3]={0,0.44,0.87},    [4]={0.64,0.21,0.93}, [5]={1,0.5,0},
}

local ROW_H     = 28
local CARD_H    = 76
local PAD       = 6
local LEFT_PCT  = 0.26
local TAB_W     = 44
local MAX_CARDS = 40

local selectedProfession  = "Alchemy"
local selectedExpansion   = "Dragon Isles"
local profitFilter        = "profitable"
local sortOrder           = "profit-desc"
local openTrainerDropdown = nil

local skillCraftersCache = nil
local skillCraftersDirty = true

local function GetSkillCrafters()
  if skillCraftersCache and not skillCraftersDirty then return skillCraftersCache end
  skillCraftersDirty = false
  local RT  = NS.Systems.RecipeTracker
  local out = {}
  if RT then
    for charKey, charData in pairs(RT:GetAllCharacters()) do
      if charData.professions then
        for _, pd in pairs(charData.professions) do
          if pd.recipes then
            for recipeID in pairs(pd.recipes) do
              if not out[recipeID] then out[recipeID] = {} end
              out[recipeID][#out[recipeID]+1] = charKey
            end
          end
        end
      end
    end
  end
  skillCraftersCache = out
  return out
end

local itemListCache = {}
local profitCache   = {}

local function InvalidateItemCache()
  skillCraftersDirty = true
  itemListCache = {}
  profitCache   = {}
end
NS.AltsProfessionsInvalidate = InvalidateItemCache

local function Label(parent, tmpl)
  return parent:CreateFontString(nil, "OVERLAY", tmpl or "GameFontNormal")
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

local function ProfitColor(profit)
  if not profit then return T.placeholder or {0.52,0.52,0.55,1} end
  if profit >= 30000 then return T.success  or {0.30,0.80,0.40,1} end
  if profit >= 5000  then return T.accent   or {0.90,0.72,0.18,1} end
  if profit >= 0     then return T.warning  or {0.85,0.55,0.22,1} end
  return T.danger or {0.80,0.28,0.28,1}
end

local function ApplyBackdrop(f, bg, border)
  if not f or not f.SetBackdrop then return end
  f:SetBackdrop({ bgFile="Interface/Buttons/WHITE8X8", edgeFile="Interface/Buttons/WHITE8X8", edgeSize=1 })
  f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
  if border then f:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1) end
end

local function GetProfessionItems(profName, expansion)
  local key = profName.."|"..expansion
  if itemListCache[key] then return itemListCache[key] end

  local items, seen = {}, {}
  local profData = NS.Data and NS.Data.Professions and NS.Data.Professions[profName]
  if not profData then itemListCache[key] = items; return items end

  local lists = {}
  if profData[expansion] then tinsert(lists, profData[expansion]) end
  for _, alt in ipairs(EXPANSION_ALT_KEYS[expansion] or {}) do
    if profData[alt] then tinsert(lists, profData[alt]) end
  end
  if #lists == 0 then itemListCache[key] = items; return items end

  local crafters = GetSkillCrafters()

  for _, list in ipairs(lists) do
    for _, d in ipairs(list) do
      if d.decorID and d.source and d.source.itemID and not seen[d.decorID] then
        seen[d.decorID] = true
        local itemID  = d.source.itemID
        local skillID = d.source.skillID
        local mkt, src = PriceSource.GetItemPrice(itemID)

        local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
        local _, _, quality = GetItemInfoInstant(itemID)
        quality = quality or 1
        if not name or name == "" then
          name = "Item #"..itemID
        end

        local knownCrafters = (skillID and crafters[skillID]) or {}
        local cost, lumber  = 0, 0
        if d.reagents then
          for _, r in ipairs(d.reagents) do
            local qty = r.count or r.qty or r.amount or 1
            if LUMBER_IDS[r.itemID] then lumber = lumber + qty end
            local p = PriceSource.GetItemPrice(r.itemID)
            if p then cost = cost + p * qty end
          end
        end
        if cost == 0 and mkt then cost = mkt * 0.4 end

        local profit = mkt and (mkt - cost) or nil
        local ppl    = (profit and lumber > 0) and (profit / lumber) or nil

        tinsert(items, {
          itemID      = itemID,
          skillID     = skillID,
          decorID     = d.decorID,
          name        = d.title or name or "Unknown",
          quality     = quality or 1,
          marketPrice = mkt,
          craftCost   = cost,
          profit      = profit,
          lumberCount = lumber,
          ppl         = ppl,
          priceSource = src,
          canCraft    = #knownCrafters > 0,
          crafters    = knownCrafters,
        })
      end
    end
  end

  itemListCache[key] = items
  return items
end

local function HasProfession(profName)
  local RT = NS.Systems.RecipeTracker
  if not RT then return false end
  for _, charData in pairs(RT:GetAllCharacters() or {}) do
    local p = charData.professionSkills and charData.professionSkills[profName]
    if p then
      for _, sd in pairs(p) do
        if sd and (sd.current or sd.max) then return true end
      end
    end
  end
  return false
end

local function TotalProfit(profName)
  if profitCache[profName] ~= nil then
    return profitCache[profName] or nil
  end
  local total, found = 0, false
  for _, exp in ipairs(EXPANSIONS) do
    for _, item in ipairs(GetProfessionItems(profName, exp)) do
      if item.profit then total = total + item.profit; found = true end
    end
  end
  local result = found and total or false
  profitCache[profName] = result
  return result or nil
end

local function FilterItems(items)
  local out = {}
  for _, item in ipairs(items) do
    local ok = false
    if     profitFilter == "all"        then ok = true
    elseif profitFilter == "withdata"   then ok = item.profit ~= nil
    elseif profitFilter == "profitable" then ok = item.profit and item.profit > 1000
    elseif profitFilter == "high"       then ok = item.profit and item.profit > 10000
    elseif profitFilter == "mega"       then ok = item.profit and item.profit > 30000
    elseif profitFilter == "cancraft"   then ok = item.canCraft == true
    end
    if ok then tinsert(out, item) end
  end
  return out
end

local function SortItems(items)
  sort(items, function(a, b)
    if sortOrder == "profit-desc" then
      if not a.profit then return false end
      if not b.profit then return true end
      return a.profit > b.profit
    elseif sortOrder == "profit-asc" then
      if not a.profit then return false end
      if not b.profit then return true end
      return a.profit < b.profit
    elseif sortOrder == "margin-desc" then
      if not a.profit or not b.profit then return a.profit ~= nil end
      return (a.profit / a.craftCost) > (b.profit / b.craftCost)
    elseif sortOrder == "name" then
      return (a.name or "") < (b.name or "")
    end
    return false
  end)
end

local function MakeDropdown(parent, options, default, width, onChange)
  local ITEM_H = 22
  local dd = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
  dd:SetSize(width, 22)
  ApplyBackdrop(dd, T.row or {0.13,0.13,0.15,1}, T.border or {0.24,0.24,0.28,1})

  local valueTxt = Label(dd, "GameFontNormalSmall")
  valueTxt:SetPoint("LEFT", 6, 0)
  valueTxt:SetPoint("RIGHT", -16, 0)
  valueTxt:SetJustifyH("LEFT")
  valueTxt:SetTextColor(unpack(T.text or {0.92,0.92,0.92,1}))

  local arrowTxt = Label(dd, "GameFontNormalSmall")
  arrowTxt:SetPoint("RIGHT", -4, 0)
  arrowTxt:SetText("v")
  arrowTxt:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))

  dd.value = default or options[1]
  valueTxt:SetText(dd.value)

  dd.GetValue = function(s) return s.value end
  dd.SetValue = function(s, v)
    s.value = v
    valueTxt:SetText(v)
    if onChange then onChange(v) end
  end

  dd:SetScript("OnEnter", function()
    if dd.SetBackdropColor then dd:SetBackdropColor(unpack(T.hover or {0.17,0.17,0.20,1})) end
  end)
  dd:SetScript("OnLeave", function()
    if dd.SetBackdropColor then dd:SetBackdropColor(unpack(T.row or {0.13,0.13,0.15,1})) end
  end)
  dd:SetScript("OnClick", function(self)
    if self.menu and self.menu:IsShown() then self.menu:Hide(); return end

    local menu = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetSize(width, #options * ITEM_H + 4)
    menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
    ApplyBackdrop(menu, T.bg or {0.045,0.045,0.05,1}, T.border or {0.24,0.24,0.28,1})

    for i, opt in ipairs(options) do
      local row = CreateFrame("Button", nil, menu, BackdropTemplateMixin and "BackdropTemplate")
      row:SetPoint("TOPLEFT",   2, -2 - (i-1)*ITEM_H)
      row:SetPoint("TOPRIGHT", -2, -2 - (i-1)*ITEM_H)
      row:SetHeight(ITEM_H)
      ApplyBackdrop(row, T.panel or {0.095,0.095,0.11,1}, nil)
      local rowTxt = Label(row, "GameFontNormalSmall")
      rowTxt:SetPoint("LEFT", 6, 0)
      rowTxt:SetText(opt)
      rowTxt:SetTextColor(unpack(T.text or {0.92,0.92,0.92,1}))
      row:SetScript("OnEnter", function()
        if row.SetBackdropColor then row:SetBackdropColor(unpack(T.hover or {0.17,0.17,0.20,1})) end
      end)
      row:SetScript("OnLeave", function()
        if row.SetBackdropColor then row:SetBackdropColor(unpack(T.panel or {0.095,0.095,0.11,1})) end
      end)
      row:SetScript("OnClick", function() dd:SetValue(opt); menu:Hide() end)
    end

    local catcher = CreateFrame("Frame", nil, UIParent)
    catcher:EnableMouse(true)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("DIALOG")
    catcher:SetFrameLevel(menu:GetFrameLevel() - 1)
    catcher:SetScript("OnMouseDown", function() menu:Hide(); catcher:Hide() end)
    menu:HookScript("OnHide", function() catcher:Hide() end)

    menu:SetScript("OnHide", function() if dd.menu == menu then dd.menu = nil end end)
    dd.menu = menu
    menu:Show()
  end)

  return dd
end

function SmartProfs:Create(parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetAllPoints(parent)
  self.frame = frame

  local controls = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  controls:SetPoint("TOPLEFT",  frame, "TOPLEFT",   PAD, -52)
  controls:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PAD, -52)
  controls:SetHeight(28)
  ApplyBackdrop(controls, T.header or {0.075,0.075,0.085,1}, T.border or {0.24,0.24,0.28,1})

  local filterLbl = Label(controls, "GameFontNormalSmall")
  filterLbl:SetPoint("LEFT", 8, 0)
  filterLbl:SetText(L["ALTS_SHOW"])
  filterLbl:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))

  local filterOptions = {"All Items","With Price Data","Profitable Only","High (>100g)","Mega (>300g)","Can Craft"}
  local filterValues  = {"all","withdata","profitable","high","mega","cancraft"}
  local filterDD = MakeDropdown(controls, filterOptions, "Profitable Only", 140, function(v)
    for i, t in ipairs(filterOptions) do
      if t == v then profitFilter = filterValues[i]; self:RefreshDetailPanel(); break end
    end
  end)
  filterDD:SetPoint("LEFT", filterLbl, "RIGHT", 6, 0)
  self.profitFilterDD = filterDD

  local sortLbl = Label(controls, "GameFontNormalSmall")
  sortLbl:SetPoint("LEFT", filterDD, "RIGHT", 14, 0)
  sortLbl:SetText(L["ALTS_SORT"])
  sortLbl:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))

  local sortOptions = {"Profit High-Low","Profit Low-High","Margin High-Low","Name A-Z"}
  local sortValues  = {"profit-desc","profit-asc","margin-desc","name"}
  local sortDD = MakeDropdown(controls, sortOptions, "Profit High-Low", 140, function(v)
    for i, t in ipairs(sortOptions) do
      if t == v then sortOrder = sortValues[i]; self:RefreshDetailPanel(); break end
    end
  end)
  sortDD:SetPoint("LEFT", sortLbl, "RIGHT", 6, 0)
  self.sortDD = sortDD

  local leftPanel = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  leftPanel:SetPoint("TOPLEFT",    controls, "BOTTOMLEFT",  0, -PAD)
  leftPanel:SetPoint("BOTTOMLEFT", frame,    "BOTTOMLEFT", PAD, PAD)
  ApplyBackdrop(leftPanel, T.panel or {0.095,0.095,0.11,1}, T.border or {0.24,0.24,0.28,1})

  local rightPanel = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  rightPanel:SetPoint("TOPRIGHT",    controls, "BOTTOMRIGHT", 0,    -PAD)
  rightPanel:SetPoint("BOTTOMRIGHT", frame,    "BOTTOMRIGHT", -PAD,  PAD)
  ApplyBackdrop(rightPanel, T.panel or {0.095,0.095,0.11,1}, T.border or {0.24,0.24,0.28,1})

  local function UpdateSplit()
    local fw = frame:GetWidth()
    if not fw or fw < 10 then return end
    leftPanel:SetWidth(math.floor(fw * LEFT_PCT) - PAD * 2)
    rightPanel:ClearAllPoints()
    rightPanel:SetPoint("TOPLEFT",     leftPanel, "TOPRIGHT",     PAD,   0)
    rightPanel:SetPoint("TOPRIGHT",    controls,  "BOTTOMRIGHT",  0,    -PAD)
    rightPanel:SetPoint("BOTTOMRIGHT", frame,     "BOTTOMRIGHT", -PAD,   PAD)
  end
  frame:HookScript("OnSizeChanged", UpdateSplit)
  C_Timer.After(0, UpdateSplit)

  self.controlsFrame = controls
  self.leftPanel     = leftPanel
  self.rightPanel    = rightPanel

  rightPanel:HookScript("OnSizeChanged", function()
    if self.expansionTabs then self:RefreshDetailPanel() end
  end)

  local profScroll = CreateFrame("ScrollFrame", nil, leftPanel, "ScrollFrameTemplate")
  if C and C.SkinScrollFrame then C:SkinScrollFrame(profScroll) end
  profScroll:SetPoint("TOPLEFT",     leftPanel, "TOPLEFT",     6,  -6)
  profScroll:SetPoint("BOTTOMRIGHT", leftPanel, "BOTTOMRIGHT", -24, 12)
  local profContent = CreateFrame("Frame", nil, profScroll)
  profContent:SetSize(1, 1)
  profScroll:SetScrollChild(profContent)
  profScroll:HookScript("OnSizeChanged", function(sf, w) profContent:SetWidth(w) end)
  self.professionContent = profContent

  local detailScroll = CreateFrame("ScrollFrame", nil, rightPanel, "ScrollFrameTemplate")
  if C and C.SkinScrollFrame then C:SkinScrollFrame(detailScroll) end
  detailScroll:SetPoint("TOPLEFT",     rightPanel, "TOPLEFT",     6,  -6)
  detailScroll:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT", -24, 12)
  local detailContent = CreateFrame("Frame", nil, detailScroll)
  detailContent:SetSize(1, 1)
  detailScroll:SetScrollChild(detailContent)
  detailScroll:HookScript("OnSizeChanged", function(sf, w) detailContent:SetWidth(w) end)
  self.detailScroll  = detailScroll
  self.detailContent = detailContent

  self:BuildProfessionList()
  self:BuildDetailPanel()
  self:RefreshProfessionList()
  self:RefreshDetailPanel()

  return frame
end

function SmartProfs:BuildProfessionList()
  if not self.professionContent then return end
  local pc = self.professionContent
  self.profBtns = {}
  local y = 0
  for _, profName in ipairs(PROFESSIONS) do
    local btn = CreateFrame("Button", nil, pc, BackdropTemplateMixin and "BackdropTemplate")
    btn:SetPoint("TOPLEFT",  0, -y)
    btn:SetPoint("TOPRIGHT", 0, -y)
    btn:SetHeight(ROW_H)
    btn:SetScript("OnClick", function()
      selectedProfession = profName
      self:RefreshProfessionList()
      self:RefreshDetailPanel()
    end)

    local accentBar = btn:CreateTexture(nil, "ARTWORK")
    accentBar:SetWidth(2)
    accentBar:SetPoint("TOPLEFT",    btn, "TOPLEFT",    0, -2)
    accentBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0,  2)
    accentBar:SetColorTexture(unpack(T.accent or {0.90,0.72,0.18,1}))
    accentBar:Hide()

    local nameTxt = Label(btn, "GameFontNormalSmall")
    nameTxt:SetPoint("LEFT",  6, 0)
    nameTxt:SetPoint("RIGHT", -58, 0)
    nameTxt:SetJustifyH("LEFT")
    nameTxt:SetText(profName)

    local profitTxt = Label(btn, "GameFontNormalSmall")
    profitTxt:SetPoint("RIGHT", -4, 0)
    profitTxt:SetJustifyH("RIGHT")

    btn.accentBar = accentBar
    btn.nameTxt   = nameTxt
    btn.profitTxt = profitTxt
    btn.profName  = profName
    self.profBtns[#self.profBtns+1] = btn
    y = y + ROW_H + 1
  end
  pc:SetHeight(y)
end

function SmartProfs:RefreshProfessionList()
  if not self.profBtns then return end
  for _, btn in ipairs(self.profBtns) do
    local profName = btn.profName
    local has      = HasProfession(profName)
    local profit   = TotalProfit(profName)
    local selected = profName == selectedProfession

    if selected then
      ApplyBackdrop(btn, T.accentSoft or {0.90,0.72,0.18,0.28}, T.accent or {0.90,0.72,0.18,1})
      btn.accentBar:Show()
      btn.nameTxt:SetTextColor(unpack(T.accentBright or {1,0.95,0.6,1}))
    else
      ApplyBackdrop(btn, T.row or {0.13,0.13,0.15,1}, T.border or {0.24,0.24,0.28,1})
      btn.accentBar:Hide()
      btn.nameTxt:SetTextColor(unpack(has and (T.text or {0.92,0.92,0.92,1}) or (T.textMuted or {0.65,0.65,0.68,1})))
      btn:SetScript("OnEnter", function()
        if btn.SetBackdropColor then btn:SetBackdropColor(unpack(T.hover or {0.17,0.17,0.20,1})) end
      end)
      btn:SetScript("OnLeave", function()
        if btn.SetBackdropColor then btn:SetBackdropColor(unpack(T.row or {0.13,0.13,0.15,1})) end
      end)
    end

    if profit then
      local c = ProfitColor(profit)
      btn.profitTxt:SetText(FormatGold(profit))
      btn.profitTxt:SetTextColor(c[1], c[2], c[3], 1)
    else
      btn.profitTxt:SetText("--")
      btn.profitTxt:SetTextColor(unpack(T.placeholder or {0.52,0.52,0.55,1}))
    end
  end
end

function SmartProfs:BuildDetailPanel()
  if not self.detailContent then return end
  local dc = self.detailContent

  local header = Label(dc, "GameFontNormalSmall")
  header:SetPoint("TOPLEFT", 4, -4)
  header:SetTextColor(unpack(T.accent or {0.90,0.72,0.18,1}))
  self.detailHeader = header

  local noLearnedMsg = Label(dc, "GameFontNormalSmall")
  noLearnedMsg:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
  noLearnedMsg:SetText(L["ALTS_NOT_LEARNED"])
  noLearnedMsg:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))
  noLearnedMsg:Hide()
  self.noLearnedMsg = noLearnedMsg

  self.expansionTabs = {}
  for i, expansion in ipairs(EXPANSIONS) do
    local tab = CreateFrame("Button", nil, dc, BackdropTemplateMixin and "BackdropTemplate")
    tab:SetSize(TAB_W, 18)
    tab:SetScript("OnClick", function()
      selectedExpansion = expansion
      self:RefreshDetailPanel()
    end)
    local tabTxt = Label(tab, "GameFontNormalSmall")
    tabTxt:SetPoint("CENTER")
    tabTxt:SetText(EXPANSION_ABBREV[expansion])
    tab.expansion = expansion
    tab.labelTxt  = tabTxt
    self.expansionTabs[i] = tab
  end

  local emptyMsg = Label(self.detailScroll, "GameFontNormal")
  emptyMsg:SetPoint("CENTER", self.detailScroll, "CENTER", 0, -20)
  emptyMsg:SetText(L["ALTS_NO_ITEMS_MATCH"])
  emptyMsg:SetTextColor(unpack(T.placeholder or {0.52,0.52,0.55,1}))
  emptyMsg:Hide()
  self.emptyMsg = emptyMsg

  local noDataMsg = Label(self.detailScroll, "GameFontNormalLarge")
  noDataMsg:SetPoint("CENTER", self.detailScroll, "CENTER", 0, -20)
  noDataMsg:SetText(L["ALTS_NO_RECIPES_YET"])
  noDataMsg:SetTextColor(unpack(T.accent or {0.90,0.72,0.18,1}))
  noDataMsg:SetJustifyH("CENTER")
  noDataMsg:Hide()
  self.noDataMsg = noDataMsg

  self.itemCards = {}
  local iconSize = CARD_H - 10

  for i = 1, MAX_CARDS do
    local card = CreateFrame("Button", nil, dc, BackdropTemplateMixin and "BackdropTemplate")
    card:SetHeight(CARD_H)
    card:RegisterForClicks("AnyUp")
    card:Hide()

    local qualityBar = card:CreateTexture(nil, "ARTWORK")
    qualityBar:SetWidth(2)
    qualityBar:SetPoint("TOPLEFT",    card, "TOPLEFT",    0, -2)
    qualityBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 0,  2)

    local iconBtn = CreateFrame("Button", nil, card)
    iconBtn:SetSize(iconSize, iconSize)
    iconBtn:SetPoint("LEFT", 6, 0)
    local iconTex = iconBtn:CreateTexture(nil, "ARTWORK")
    iconTex:SetAllPoints()
    iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local nameTxt = Label(card, "GameFontNormal")
    nameTxt:SetPoint("TOPLEFT",  iconBtn, "TOPRIGHT", 7, -3)
    nameTxt:SetPoint("TOPRIGHT", card,    "TOPRIGHT", -4, -3)
    nameTxt:SetJustifyH("LEFT")
    nameTxt:SetWordWrap(false)

    local mktLbl = Label(card, "GameFontNormalSmall")
    mktLbl:SetPoint("BOTTOMLEFT", iconBtn, "BOTTOMRIGHT", 7, 30)
    mktLbl:SetText(L["ALTS_MKT"])
    mktLbl:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))

    local mktTxt = Label(card, "GameFontNormal")
    mktTxt:SetPoint("BOTTOMLEFT", mktLbl, "BOTTOMRIGHT", 3, 0)
    mktTxt:SetJustifyH("LEFT")

    local costLbl = Label(card, "GameFontNormalSmall")
    costLbl:SetPoint("BOTTOMLEFT", mktTxt, "BOTTOMRIGHT", 12, 0)
    costLbl:SetText(L["ALTS_COST"])
    costLbl:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))

    local costTxt = Label(card, "GameFontNormal")
    costTxt:SetPoint("BOTTOMLEFT", costLbl, "BOTTOMRIGHT", 3, 0)
    costTxt:SetJustifyH("LEFT")

    local profitTxt = Label(card, "GameFontNormal")
    profitTxt:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -8, 28)
    profitTxt:SetJustifyH("RIGHT")

    local pplTxt = Label(card, "GameFontNormalSmall")
    pplTxt:SetPoint("BOTTOMRIGHT", profitTxt, "TOPRIGHT", 0, 2)
    pplTxt:SetJustifyH("RIGHT")
    pplTxt:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))

    local crafterTxt = Label(card, "GameFontNormalSmall")
    crafterTxt:SetPoint("TOPRIGHT", card, "TOPRIGHT", -6, -4)
    crafterTxt:SetJustifyH("RIGHT")

    local FACTION_COLORS = {
      Alliance = {0.41, 0.69, 1.00, 1},
      Horde    = {1.00, 0.38, 0.38, 1},
      Neutral  = {0.90, 0.72, 0.18, 1},
    }
    local FACTION_BADGE_BG = {
      Alliance = {0.20, 0.40, 0.80, 0.88},
      Horde    = {0.70, 0.12, 0.12, 0.88},
      Neutral  = {0.50, 0.38, 0.06, 0.88},
    }
    local FACTION_LETTER = { Alliance="A", Horde="H", Neutral="N" }
    local DD_ROW_H = 34

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

    local trainerBtn = CreateFrame("Button", nil, card, BackdropTemplateMixin and "BackdropTemplate")
    ApplyBackdrop(trainerBtn,
      T.header and {T.header[1], T.header[2], T.header[3], 0.90} or {0.06, 0.05, 0.02, 0.90},
      T.accent  and {T.accent[1],  T.accent[2],  T.accent[3],  0.30} or {0.90, 0.72, 0.18, 0.30})
    trainerBtn:SetPoint("BOTTOMLEFT",  card, "BOTTOMLEFT",  2, 2)
    trainerBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -2, 2)
    trainerBtn:SetHeight(20)
    trainerBtn:Hide()

    local pinIcon = Label(trainerBtn, "GameFontNormalSmall")
    pinIcon:SetPoint("LEFT", trainerBtn, "LEFT", 8, 0)
    pinIcon:SetText("|TInterface\\WorldMap\\WorldMapPartyIcon:12:12:0:0|t")

    local findTxt = Label(trainerBtn, "GameFontNormalSmall")
    findTxt:SetPoint("LEFT", trainerBtn, "LEFT", 26, 0)
    findTxt:SetText(L["ALTS_FIND_TRAINER"])
    findTxt:SetTextColor(unpack(T.accent or {0.90, 0.72, 0.18, 1}))

    local arrowTxt = Label(trainerBtn, "GameFontNormalSmall")
    arrowTxt:SetPoint("RIGHT", trainerBtn, "RIGHT", -8, 0)
    arrowTxt:SetJustifyH("RIGHT")
    arrowTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
    trainerBtn.arrowTxt = arrowTxt

    local dropdown = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    ApplyBackdrop(dropdown,
      T.bg and {T.bg[1], T.bg[2], T.bg[3], 0.97} or {0.045, 0.045, 0.05, 0.97},
      T.border or {0.24, 0.24, 0.28, 1})
    dropdown:SetFrameStrata("FULLSCREEN_DIALOG")
    dropdown:SetFrameLevel(600)
    dropdown:Hide()
    dropdown.rows = {}

    local function RebuildDropdown(trainers)
      for _, r in ipairs(dropdown.rows) do r:Hide() end
      dropdown.rows = {}
      dropdown:SetWidth(240)

      for ri, td in ipairs(trainers) do
        local row = CreateFrame("Button", nil, dropdown, BackdropTemplateMixin and "BackdropTemplate")
        ApplyBackdrop(row, T.panel and {T.panel[1], T.panel[2], T.panel[3], 0.92} or {0.09, 0.09, 0.11, 0.92}, nil)
        row:SetPoint("TOPLEFT",  dropdown, "TOPLEFT",   4, -4 - (ri-1)*(DD_ROW_H+2))
        row:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", -4, -4 - (ri-1)*(DD_ROW_H+2))
        row:SetHeight(DD_ROW_H)

        local fbar = row:CreateTexture(nil, "ARTWORK")
        fbar:SetWidth(3)
        fbar:SetPoint("TOPLEFT",    row, "TOPLEFT",    0, -1)
        fbar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0,  1)
        fbar:SetColorTexture(unpack(FACTION_COLORS[td.faction] or FACTION_COLORS.Neutral))

        local badge = CreateFrame("Frame", nil, row, BackdropTemplateMixin and "BackdropTemplate")
        local bgcol = FACTION_BADGE_BG[td.faction] or FACTION_BADGE_BG.Neutral
        ApplyBackdrop(badge, {bgcol[1], bgcol[2], bgcol[3], bgcol[4]}, nil)
        badge:SetSize(20, 14)
        badge:SetPoint("LEFT", row, "LEFT", 8, 2)
        local badgeTxt = badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        badgeTxt:SetPoint("CENTER")
        badgeTxt:SetText(FACTION_LETTER[td.faction] or "N")
        badgeTxt:SetTextColor(1, 1, 1, 1)

        local NPCNames    = NS.Systems and NS.Systems.NPCNames
        local npcNameTxt  = Label(row, "GameFontNormal")
        npcNameTxt:SetPoint("LEFT",  row, "LEFT",  32,  4)
        npcNameTxt:SetPoint("RIGHT", row, "RIGHT", -6,  4)
        npcNameTxt:SetJustifyH("LEFT")
        npcNameTxt:SetWordWrap(false)
        npcNameTxt:SetTextColor(unpack(T.text or {0.92, 0.92, 0.92, 1}))

        local fallback = td.name or ("NPC #"..tostring(td.id))
        local function SetName(n) if npcNameTxt then npcNameTxt:SetText(n or fallback) end end
        SetName((NPCNames and NPCNames.Get(td.id, function(_, n) SetName(n) end)) or fallback)

        local zoneTxt = Label(row, "GameFontNormalSmall")
        zoneTxt:SetPoint("LEFT",  row, "LEFT",  32, -9)
        zoneTxt:SetPoint("RIGHT", row, "RIGHT", -6, -9)
        zoneTxt:SetJustifyH("LEFT")
        zoneTxt:SetWordWrap(false)
        zoneTxt:SetTextColor(unpack(T.textMuted or {0.65, 0.65, 0.68, 1}))
        zoneTxt:SetText(td.zone .. (td.note and ("  ("..td.note..")") or ""))

        row:SetScript("OnEnter", function()
          if row.SetBackdropColor then row:SetBackdropColor(unpack(T.hover or {0.17,0.17,0.20,1})) end
        end)
        row:SetScript("OnLeave", function()
          if row.SetBackdropColor then row:SetBackdropColor(unpack(T.panel or {0.09,0.09,0.11,0.92})) end
        end)
        row:SetScript("OnClick", function() dropdown:Hide(); OpenTrainerMap(td.worldmap) end)

        dropdown.rows[#dropdown.rows+1] = row
      end

      dropdown:SetHeight(4 + #trainers * (DD_ROW_H + 2) + 4)
    end

    trainerBtn:SetScript("OnEnter", function()
      if trainerBtn.SetBackdropColor then
        trainerBtn:SetBackdropColor(unpack(T.hover or {0.17, 0.17, 0.20, 1}))
      end
      local tds = trainerBtn.trainers
      if not (tds and #tds > 0) then return end
      GameTooltip:SetOwner(trainerBtn, "ANCHOR_TOP")
      GameTooltip:ClearLines()
      GameTooltip:AddLine(L["ALTS_TRAINER_LOCATIONS_TIP"], unpack(T.accent or {0.90, 0.72, 0.18, 1}))
      for _, td in ipairs(tds) do
        local col = FACTION_COLORS[td.faction] or FACTION_COLORS.Neutral
        GameTooltip:AddLine(("[%s] %s"):format(td.faction:sub(1,1), td.name), col[1], col[2], col[3])
        GameTooltip:AddLine("   "..td.zone..(td.note and ("  ("..td.note..")") or ""), 0.65, 0.65, 0.68)
      end
      GameTooltip:AddLine(#tds == 1 and "|cffaaaaaa[Click]|r Open Map & Set Waypoint"
                                     or "|cffaaaaaa[Click]|r Choose trainer", 1, 1, 1)
      GameTooltip:Show()
    end)
    trainerBtn:SetScript("OnLeave", function()
      GameTooltip:Hide()
      if trainerBtn.SetBackdropColor then
        trainerBtn:SetBackdropColor(
          T.header and T.header[1] or 0.06,
          T.header and T.header[2] or 0.05,
          T.header and T.header[3] or 0.02,
          0.90)
      end
    end)
    trainerBtn:SetScript("OnClick", function()
      if dropdown:IsShown() then dropdown:Hide(); return end

      local tds = trainerBtn.trainers
      if not tds or #tds == 0 then return end
      if #tds == 1 then OpenTrainerMap(tds[1].worldmap); return end

      if openTrainerDropdown and openTrainerDropdown ~= dropdown then
        openTrainerDropdown:Hide()
      end
      RebuildDropdown(tds)
      dropdown:ClearAllPoints()
      dropdown:SetPoint("BOTTOMRIGHT", trainerBtn, "TOPRIGHT", 0, 2)
      dropdown:Show()
      dropdown:Raise()
      openTrainerDropdown = dropdown
    end)

    dropdown:SetScript("OnLeave", function()
      C_Timer.After(0.15, function()
        if not MouseIsOver(dropdown) and not MouseIsOver(trainerBtn) then dropdown:Hide() end
      end)
    end)
    dropdown:SetScript("OnShow", function()
      dropdown:SetScript("OnUpdate", function()
        if not card:IsVisible() then dropdown:Hide() end
      end)
    end)
    dropdown:SetScript("OnHide", function()
      dropdown:SetScript("OnUpdate", nil)
      if openTrainerDropdown == dropdown then openTrainerDropdown = nil end
    end)

    card.qualityBar = qualityBar
    card.iconBtn    = iconBtn
    card.iconTex    = iconTex
    card.nameTxt    = nameTxt
    card.mktTxt     = mktTxt
    card.costTxt    = costTxt
    card.profitTxt  = profitTxt
    card.pplTxt     = pplTxt
    card.crafterTxt = crafterTxt
    card.trainerBtn = trainerBtn
    self.itemCards[i] = card
  end
end

function SmartProfs:RefreshDetailPanel()
  if not self.detailContent then return end
  local dc = self.detailContent

  local tabStripW  = self.rightPanel and self.rightPanel:GetWidth() or 400
  local totalTabW  = #EXPANSIONS * (TAB_W + 2)
  local tabOffsetX = (tabStripW - totalTabW) / 2
  local tabY = -4

  if self.expansionTabs then
    for i, tab in ipairs(self.expansionTabs) do
      tab:ClearAllPoints()
      tab:SetPoint("TOPLEFT", dc, "TOPLEFT", tabOffsetX + (i-1) * (TAB_W + 2), tabY)

      local active = tab.expansion == selectedExpansion
      if active then
        ApplyBackdrop(tab, T.accentDark or {0.28,0.24,0.10,0.95}, T.accent or {0.90,0.72,0.18,1})
        tab.labelTxt:SetTextColor(unpack(T.accentBright or {1,0.95,0.6,1}))
      else
        ApplyBackdrop(tab, T.row or {0.13,0.13,0.15,1}, T.border or {0.24,0.24,0.28,1})
        tab.labelTxt:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))
        tab:SetScript("OnEnter", function()
          if tab.SetBackdropColor then tab:SetBackdropColor(unpack(T.hover or {0.17,0.17,0.20,1})) end
        end)
        tab:SetScript("OnLeave", function()
          if tab.SetBackdropColor then tab:SetBackdropColor(unpack(T.row or {0.13,0.13,0.15,1})) end
        end)
      end
    end
  end

  local rawItems = GetProfessionItems(selectedProfession, selectedExpansion)
  local items = FilterItems(rawItems)
  SortItems(items)
  local RT = NS.Systems.RecipeTracker

  self.noDataMsg:SetShown(#rawItems == 0)
  self.emptyMsg:SetShown(#rawItems > 0 and #items == 0)

  local cardY = tabY - 24

  for i, card in ipairs(self.itemCards) do
    local item = items[i]
    if item then
      card:Show()
      card:ClearAllPoints()
      card:SetPoint("TOPLEFT",  4, cardY)
      card:SetPoint("TOPRIGHT", -4, cardY)

      local qc    = QUALITY_COLORS[item.quality] or QUALITY_COLORS[1]
      local alpha = item.canCraft and 1.0 or 0.45

      if item.canCraft then
        local a = T.accent or {0.90,0.72,0.18}
        ApplyBackdrop(card, T.row or {0.13,0.13,0.15,1}, {a[1],a[2],a[3],0.3})
      else
        ApplyBackdrop(card, T.panel or {0.095,0.095,0.11,1}, T.border or {0.24,0.24,0.28,1})
      end

      local itemData = {
        itemID = item.itemID, id = item.itemID, title = item.name,
        source = { type="profession", itemID=item.itemID, skillID=item.skillID, id=item.skillID },
      }
      IA = IA or (NS.UI and NS.UI.ItemInteractions)
      TT = TT or (NS.UI and NS.UI.Tooltips)

      card:SetScript("OnEnter", function()
        if card.SetBackdropColor then card:SetBackdropColor(unpack(T.hover or {0.17,0.17,0.20,1})) end
        GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetItemByID(item.itemID)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffaaaaaa[Left Click]|r View Item",     1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Alt+Click]|r  Wowhead",       1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Right Click]|r Set Waypoint", 1, 1, 1)
        GameTooltip:Show()
      end)
      card:SetScript("OnLeave", function()
        local bg = item.canCraft and (T.row or {0.13,0.13,0.15,1}) or (T.panel or {0.095,0.095,0.11,1})
        if card.SetBackdropColor then card:SetBackdropColor(unpack(bg)) end
        GameTooltip:Hide()
      end)
      card:SetScript("OnMouseUp", function(_, btn)
        if IA then IA:HandleMouseUp(itemData, btn) end
      end)

      card.qualityBar:SetColorTexture(qc[1], qc[2], qc[3], alpha)

      local tex = GetItemIcon(item.itemID)
      card.iconTex:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")
      card.iconTex:SetDesaturated(not item.canCraft)
      card.iconTex:SetAlpha(alpha)
      local cid = item.itemID
      card.iconBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(card.iconBtn, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(cid)
        GameTooltip:Show()
      end)

      card.nameTxt:SetText(item.name)
      card.nameTxt:SetTextColor(qc[1]*alpha, qc[2]*alpha, qc[3]*alpha, 1)

      card.mktTxt:SetText(item.marketPrice and FormatGold(item.marketPrice) or "--")
      card.mktTxt:SetTextColor(unpack(T.text or {0.92,0.92,0.92,1}))
      card.mktTxt:SetAlpha(alpha)

      card.costTxt:SetText(FormatGold(item.craftCost))
      card.costTxt:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))
      card.costTxt:SetAlpha(alpha)

      if item.profit then
        local pc   = ProfitColor(item.profit)
        local sign = item.profit >= 0 and "+" or ""
        card.profitTxt:SetText(sign..FormatGold(item.profit))
        card.profitTxt:SetTextColor(pc[1]*alpha, pc[2]*alpha, pc[3]*alpha, 1)
      else
        card.profitTxt:SetText("--")
        card.profitTxt:SetTextColor(unpack(T.placeholder or {0.52,0.52,0.55,1}))
      end

      if item.ppl then
        local pc = ProfitColor(item.ppl)
        card.pplTxt:SetText(FormatGold(item.ppl).."/lbr")
        card.pplTxt:SetTextColor(pc[1]*alpha, pc[2]*alpha, pc[3]*alpha, 0.85)
      else
        card.pplTxt:SetText("")
      end

      local charCrafters = item.crafters or {}
      if item.canCraft and #charCrafters > 0 and RT then
        local charName = SmartProfs.FormatCharName(charCrafters[1])
        local suffix   = #charCrafters > 1 and (" +"..tostring(#charCrafters-1)) or ""
        local cd = RT:GetCharacterData(charCrafters[1])
        local cc = cd and CLASS_COLORS[cd.class] or {0.65,0.65,0.68}
        card.crafterTxt:SetText(charName..suffix)
        card.crafterTxt:SetTextColor(cc[1], cc[2], cc[3], 1)
      else
        card.crafterTxt:SetText("")
      end

      if card.trainerBtn then
        local entries = NS.Data and NS.Data.Trainers
                     and NS.Data.Trainers[selectedProfession]
                     and NS.Data.Trainers[selectedProfession][selectedExpansion]
                     or {}
        if #entries > 0 then
          local NPCNames    = NS.Systems and NS.Systems.NPCNames
          local trainerList = {}
          for _, entry in ipairs(entries) do
            local src  = entry.source
            local live = NPCNames and NPCNames.Get(src.id)
            trainerList[#trainerList+1] = {
              id       = src.id,
              faction  = src.faction or "Neutral",
              name     = live or src.name or ("NPC #"..tostring(src.id)),
              zone     = src.zone or "",
              worldmap = src.worldmap,
              note     = src.note,
            }
          end
          card.trainerBtn.trainers = trainerList
          card.trainerBtn.arrowTxt:SetText(#trainerList > 1 and "v" or "")
          card.trainerBtn:Show()
        else
          card.trainerBtn:Hide()
        end
      end

      cardY = cardY - (CARD_H + 2)
    else
      card:Hide()
    end
  end

  self.detailContent:SetHeight(math.abs(cardY) + 10)
end

function SmartProfs.FormatCharName(charKey)
  if not charKey then return "" end
  return charKey:match("^(.+)%-") or charKey
end

function SmartProfs:Show()
  if self.activateOpps then self.activateOpps() end
end

function SmartProfs:Refresh()
  self:RefreshProfessionList()
  self:RefreshDetailPanel()
end

local collectionHooked = false
local function HookCollectionRefresh()
  if collectionHooked then return end
  local Collection = NS.Systems and NS.Systems.Collection
  if not Collection or not Collection.RegisterListener then return end
  Collection:RegisterListener(function()
    local ap = NS.UI and NS.UI.AltsProfessions
    if ap and ap.frame and ap.frame:IsShown() then ap:Refresh() end
  end)
  collectionHooked = true
end
if C_Timer and C_Timer.After then C_Timer.After(0, HookCollectionRefresh) end

function SmartProfs:OnScanComplete()
  InvalidateItemCache()
  if self.frame and self.frame:IsShown() then
    self:Refresh()
    if self.oppsFrame and self.oppsFrame:IsShown() then
      self:RefreshOppsGrid()
    end
  end
end

return SmartProfs
