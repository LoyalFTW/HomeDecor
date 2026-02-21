local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}
local DecorAH = {}
NS.UI.DecorAH = DecorAH
local DH = DecorAH

local C = NS.UI.Controls
local C_Timer = C_Timer
local Theme = NS.UI.Theme
local T = (Theme and Theme.colors) or {}
local PriceSource = NS.Systems.PriceSource
local AuctionScan = NS.Systems.AuctionScan
local function RecipeTracker() return NS.Systems.RecipeTracker end

NS.DecorAH = NS.DecorAH or {}
local function GetQueue() return NS.DecorAH.Queue end
local function GetFavorites() return NS.DecorAH.Favorites end
local function GetHistory() return NS.DecorAH.History end
local function GetExport() return NS.DecorAH.Export end
local function GetSales() return NS.DecorAH.Sales end
local Queue
local Favorites
local History
local Export
local Sales
local CreateFrame = CreateFrame
local format = string.format
local tinsert = table.insert
local tremove = table.remove
local sort = table.sort
local floor = math.floor

local ROW_H = 28
local MIN_W, MIN_H = 720, 420
local MAX_W, MAX_H = 1400, 900
local DEFAULT_W, DEFAULT_H = 920, 580

local LUMBER_IDS = {
  [245586]=true, [242691]=true, [251762]=true, [251764]=true, [251763]=true,
  [251766]=true, [251767]=true, [251768]=true, [251772]=true, [251773]=true,
  [248012]=true, [256963]=true,
}
local LUMBER_NAMES = {
  [245586]="Ironwood", [242691]="Olemba", [251762]="Coldwind", [251764]="Ashwood",
  [251763]="Bamboo", [251766]="Shadowmoon", [251767]="Fel-Touched", [251768]="Darkpine",
  [251772]="Arden", [251773]="Dragonpine", [248012]="Dornic Fir", [256963]="Thalassian",
}

local COLS = {
  { key = "star",       label = "",           x = 0,   w = 20,  align = "LEFT" },
  { key = "name",       label = "Name",       x = 26,  w = 220, align = "LEFT", flex = true },
  { key = "profession", label = "Profession", x = 254, w = 88,  align = "LEFT", optional = true, priority = 1 },
  { key = "expansion",  label = "Expansion",  x = 350, w = 78,  align = "LEFT", optional = true, priority = 5 },
  { key = "crafter",    label = "Crafter",    x = 436, w = 80,  align = "LEFT", optional = true, priority = 4 },
  { key = "lumberType", label = "Lumber",     x = 524, w = 88,  align = "LEFT", priority = 2 },
  { key = "cost",       label = "Cost",       x = 620, w = 72,  align = "LEFT", priority = 3 },
  { key = "sell",       label = "Sell",       x = 700, w = 72,  align = "LEFT" },
  { key = "profit",     label = "Profit",     x = 780, w = 78,  align = "LEFT" },
  { key = "ppl",        label = "Per Lbr",   x = 866, w = 68,  align = "LEFT" },
  { key = "margin",     label = "Margin",     x = 942, w = 60,  align = "LEFT", optional = true, priority = 6 },
}

local COLS_BY_KEY = {}
for _, col in ipairs(COLS) do
  COLS_BY_KEY[col.key] = col
end

local function GetVisibleColumns(availWidth)
  local essential = { "star", "name", "lumberType", "cost", "sell", "profit", "ppl" }
  local essentialSet = {}
  for _, k in ipairs(essential) do essentialSet[k] = true end

  for _, col in ipairs(COLS) do
    col._visible = false
    col._displayX = nil
  end

  for _, col in ipairs(COLS) do
    if essentialSet[col.key] then col._visible = true end
  end

  local prioritized = {}
  for _, col in ipairs(COLS) do
    if col.priority and not essentialSet[col.key] then
      tinsert(prioritized, col)
    end
  end
  sort(prioritized, function(a, b) return (a.priority or 99) < (b.priority or 99) end)

  local usedWidth = 0
  for _, col in ipairs(COLS) do
    if col._visible and col.key ~= "name" then usedWidth = usedWidth + col.w + 8 end
  end

  for _, col in ipairs(prioritized) do
    if availWidth >= usedWidth + col.w + 8 + 120 then
      col._visible = true
      usedWidth = usedWidth + col.w + 8
    end
  end

  local currentX = 0
  for _, col in ipairs(COLS) do
    if col._visible then
      col._displayX = currentX
      if col.flex then
        col.w = math.max(140, availWidth - usedWidth - 8)
      end
      currentX = currentX + col.w + 8
    end
  end

  return COLS
end

local function GetColX(col)
  return col._displayX or col.x
end

local frame
local scrollFrame
local scrollChild
local sourceButtons = {}
local searchBox
local professionDropdown
local expansionDropdown
local lumberTypeDropdown
local knownOnlyCheck
local altProfessionsCheck
local recipeCountLabel
local sortCol = "profit"
local sortRev = true
local headerButtons = {}
local rowPool = {}
local activeRows = {}
local dataRows = {}
local dataRowsDirty = true
local cachedCurrentRecipes = nil
local preferredSource
local contentWidth = 840

local function GetDB()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  profile.decorAH.window = profile.decorAH.window or {}
  return profile.decorAH
end

local function Backdrop(f, bg, border)
  if C and C.Backdrop then C:Backdrop(f, bg or T.panel, border or T.border) end
end

local function Hover(btn, a, b)
  if C and C.ApplyHover then C:ApplyHover(btn, a or T.panel, b or T.hover) end
end

local function NewFS(parent, template)
  return parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
end

local pendingItemNames = {}
local _invalidateDataRows
local _refreshTable

local function ItemName(itemID)
  if not itemID then return "?" end

  local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
  if name and name ~= "" then return name end

  if C_Item and C_Item.RequestLoadItemDataByID then
    C_Item.RequestLoadItemDataByID(itemID)
    pendingItemNames[itemID] = true
  end
  return nil
end

local itemLoadFrame = CreateFrame("Frame")
local _itemLoadDebounce = nil
itemLoadFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
itemLoadFrame:SetScript("OnEvent", function(_, _, itemID, success)
  if success and pendingItemNames[itemID] then
    pendingItemNames[itemID] = nil

    if frame and frame:IsShown() then
      if _itemLoadDebounce then _itemLoadDebounce:Cancel() end
      _itemLoadDebounce = C_Timer.NewTimer(0.3, function()
        _itemLoadDebounce = nil
        if frame and frame:IsShown() then
          if _invalidateDataRows then _invalidateDataRows() end
          if _refreshTable then _refreshTable() end
        end
      end)
    end
  end
end)

local reagentCache = {}

local function GetReagentsForEntry(entry)
  if not entry then return nil end

  if entry.reagents and type(entry.reagents) == "table" and #entry.reagents > 0 then
    return entry.reagents
  end
  local skillID = entry.source and entry.source.skillID
  if not skillID then return nil end
  if reagentCache[skillID] ~= nil then return reagentCache[skillID] end

  reagentCache[skillID] = false
  return nil
end

local function RefreshReagentCacheForSkills(skillIDs)
  if not C_TradeSkillUI or not C_TradeSkillUI.GetRecipeSchematic then return end
  local updated = false
  for _, skillID in ipairs(skillIDs) do
    if not reagentCache[skillID] or reagentCache[skillID] == false then
      local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, skillID, false)
      if ok and schematic and schematic.reagentSlotSchematics and #schematic.reagentSlotSchematics > 0 then
        local reagents = {}
        for _, slot in ipairs(schematic.reagentSlotSchematics) do
          if slot.reagents and slot.reagents[1] and slot.reagents[1].itemID then
            tinsert(reagents, { itemID = slot.reagents[1].itemID, count = slot.quantityRequired or 1 })
          end
        end
        reagentCache[skillID] = reagents
        updated = true
      end
    end
  end
  return updated
end
DecorAH._refreshReagentCache = RefreshReagentCacheForSkills

local function BuildDataRows()
  if not dataRowsDirty then return end
  dataRowsDirty = false
  dataRows = {}
  cachedCurrentRecipes = nil

  local Data = NS.Data
  if not Data or not Data.Professions then return end

  local rt = RecipeTracker()
  local currentRecipes = {}
  if rt then
    currentRecipes = rt:GetCurrentCharacterRecipes() or {}
    cachedCurrentRecipes = currentRecipes
  end

  local flat = {}
  local seen = {}
  for profName, expansions in pairs(Data.Professions) do
    if type(expansions) == "table" then
      for expName, list in pairs(expansions) do
        if type(list) == "table" then
          for _, entry in ipairs(list) do
            if type(entry) == "table" and entry.source and entry.source.itemID then
              local itemID  = entry.source.itemID
              local decorID = entry.decorID
              local dedupKey = profName .. "|" .. expName .. "|" .. (decorID or itemID)
              if not seen[dedupKey] then
                seen[dedupKey] = true
                flat[#flat + 1] = { entry = entry, profName = profName, expName = expName, itemID = itemID }
              end
            end
          end
        end
      end
    end
  end

  local myName  = UnitName and UnitName("player") or "Me"
  local AP      = NS.UI and NS.UI.AltsProfessions

  for _, fd in ipairs(flat) do
    local entry   = fd.entry
    local profName = fd.profName
    local expName  = fd.expName
    local itemID   = fd.itemID

    local cost, lumberCount  = 0, 0
    local lumberTypeID, lumberTypeName = nil, nil

    local reagents = GetReagentsForEntry(entry)
    if reagents then
      for _, r in ipairs(reagents) do
        local rid = r.itemID
        local qty = r.count or r.qty or r.amount or 1
        if LUMBER_IDS[rid] then
          lumberTypeID   = rid
          lumberTypeName = LUMBER_NAMES[rid] or ItemName(rid)
          lumberCount    = lumberCount + qty
        end
        local p = PriceSource and PriceSource.GetItemPrice(rid) or nil
        if p then cost = cost + p * qty end
      end
    end

    local sell, src = nil, nil
    if PriceSource then sell, src = PriceSource.GetItemPrice(itemID) end
    local profit = sell ~= nil and (sell - cost) or nil
    local margin = (sell and sell > 0 and profit ~= nil) and ((profit / sell) * 100) or nil
    local ppl    = (profit ~= nil and lumberCount > 0) and (profit / lumberCount) or nil
    local name   = entry.title or ItemName(itemID) or ("Item %d"):format(itemID)

    local known, knownByAlt, crafterName = nil, false, nil
    local skillID = entry.source and entry.source.skillID

    if skillID then
      if C_TradeSkillUI and C_TradeSkillUI.IsRecipeLearned then
        known = C_TradeSkillUI.IsRecipeLearned(skillID)
      elseif C_TradeSkillUI and C_TradeSkillUI.IsRecipeKnown then
        known = C_TradeSkillUI.IsRecipeKnown(skillID)
      elseif C_Professions and C_Professions.IsRecipeKnown then
        known = C_Professions.IsRecipeKnown(skillID)
      end
      if known == nil and currentRecipes[skillID] then known = true end
    end

    if rt and skillID then
      local altKnown, altCharKey = rt:IsRecipeKnownByAnyAlt(skillID)
      knownByAlt = altKnown
      if altKnown and altCharKey then
        crafterName = (AP and AP.FormatCharName and AP.FormatCharName(altCharKey))
                   or altCharKey:match("^(.+)%-") or altCharKey
      end
    end
    if known then crafterName = myName end

    dataRows[#dataRows + 1] = {
      itemID         = itemID,
      name           = name,
      profession     = profName,
      expansion      = expName,
      cost           = cost,
      sell           = sell,
      profit         = profit,
      margin         = margin,
      ppl            = ppl,
      lumberCount    = lumberCount,
      priceSource    = src,
      known          = known,
      knownByAlt     = knownByAlt,
      crafter        = crafterName,
      lumberType     = lumberTypeID,
      lumberTypeName = lumberTypeName,
      entry          = entry,
      reagents       = reagents,
    }
  end
end

local function InvalidateDataRows()
  dataRowsDirty = true
  cachedCurrentRecipes = nil
  cachedFilteredDirty = true
  cachedFiltered = nil
end
_invalidateDataRows = InvalidateDataRows

local InvalidateFilteredCache

local function ApplyFiltersAndSort(filterProf, filterExp, filterLumber, filterSearch, knownOnly, altProfsOnly)
  local out = {}
  local search = (filterSearch or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

  for _, row in ipairs(dataRows) do
    local include = true

    if filterProf and filterProf ~= "All" and row.profession ~= filterProf then
      include = false
    elseif filterExp and filterExp ~= "All" and row.expansion ~= filterExp then
      include = false
    elseif filterLumber and filterLumber ~= "All" and (row.lumberTypeName or "") ~= filterLumber then
      include = false
    elseif search ~= "" and not (row.name and row.name:lower():find(search, 1, true)) then
      include = false
    elseif knownOnly and altProfsOnly then
      if not row.known and not row.knownByAlt then
        include = false
      end
    elseif knownOnly and not row.known then
      include = false
    elseif altProfsOnly and not row.knownByAlt then
      include = false
    end

    if include then
      tinsert(out, row)
    end
  end

  local favSet = {}
  local FavMod = Favorites or NS.DecorAH and NS.DecorAH.Favorites
  if FavMod then
    for _, row in ipairs(out) do
      if row.itemID and not favSet[row.itemID] then
        favSet[row.itemID] = FavMod.IsFavorite(row.itemID) or false
      end
    end
  end

  local key = sortCol
  local rev = sortRev
  sort(out, function(a, b)
    local aFav = favSet[a.itemID] or false
    local bFav = favSet[b.itemID] or false

    if aFav and not bFav then return true end
    if bFav and not aFav then return false end

    local av, bv
    if key == "name" then
      av, bv = a.name or "", b.name or ""
    elseif key == "profession" then
      av, bv = a.profession or "", b.profession or ""
    elseif key == "expansion" then
      av, bv = a.expansion or "", b.expansion or ""
    elseif key == "lumberType" then
      av, bv = a.lumberTypeName or "", b.lumberTypeName or ""
    elseif key == "cost" then
      av, bv = a.cost or 0, b.cost or 0
    elseif key == "sell" then
      av, bv = a.sell or 0, b.sell or 0
    elseif key == "profit" then
      av, bv = a.profit or -1e9, b.profit or -1e9
    elseif key == "ppl" then
      av, bv = a.ppl or -1e9, b.ppl or -1e9
    elseif key == "margin" then
      av, bv = a.margin or -1e9, b.margin or -1e9
    else
      av, bv = a.profit or -1e9, b.profit or -1e9
    end

    if rev then
      return av > bv
    else
      return av < bv
    end
  end)

  return out
end
local function AcquireRow()
  local row = tremove(rowPool)
  if not row then
    row = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")
    row:SetHeight(ROW_H)
    Backdrop(row, T.row, nil)
    row:SetBackdropColor(0, 0, 0, 0)
    Hover(row, T.row, T.hover)

    row.cells = {}
    for i, col in ipairs(COLS) do
      if col.key == "star" then
        local tex = row:CreateTexture(nil, "ARTWORK")
        tex:SetSize(14, 14)
        tex:SetPoint("LEFT", GetColX(col) + 3, 0)
        if tex.SetAtlas then
          tex:SetAtlas("auctionhouse-icon-favorite-off", false)
          tex:SetSize(14, 14)
        end
        tex:SetAlpha(0.5)
        row.cells[col.key] = tex
        tex._colKey = col.key
        tex._isTexture = true
      else
        local fs = NewFS(row, "GameFontNormal")
        fs:SetPoint("LEFT", GetColX(col) + 2, 0)
        fs:SetWidth(col.w - 4)
        fs:SetJustifyH(col.align or "LEFT")
        if col.key == "name" then fs:SetWordWrap(false) end
        row.cells[col.key] = fs
        fs._colKey = col.key
      end
    end

    row:SetScript("OnEnter", function(self)
      if self.itemID and GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemID)

        if self.itemData and self.itemData.reagents and #self.itemData.reagents > 0 then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(L["DECOR_AH_MATERIALS_COLON"], 0.9, 0.72, 0.18)

          local totalCost = self.itemData.cost or 0

          for _, r in ipairs(self.itemData.reagents) do
            local price = PriceSource and PriceSource.GetItemPrice(r.itemID)
            local qty = r.count or 1
            local itemCost = (price or 0) * qty
            local pct = totalCost > 0 and (itemCost / totalCost * 100) or 0

            local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(r.itemID) or "Unknown"
            GameTooltip:AddDoubleLine(
              string.format("%dx %s", qty, name),
              string.format("%.0f%%", pct),
              1, 1, 1,
              pct > 50 and 0.8 or 0.65, pct > 50 and 0.3 or 0.65, pct > 50 and 0.3 or 0.68
            )
          end
        end

        if History and self.itemID then
          local avgProfit, minProfit, maxProfit = History.GetAverageProfit(self.itemID, 7)
          if avgProfit then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("7-Day Average:", 0.65, 0.65, 0.68)
            GameTooltip:AddLine(PriceSource and PriceSource.FormatGold(avgProfit) or tostring(avgProfit), 1, 1, 1)
          end

          local trend = History.GetProfitTrend(self.itemID, 7)
          if trend then
            local trendText = trend == "increasing" and "↑ Increasing"
              or trend == "decreasing" and "↓ Decreasing"
              or "Stable"
            local trendColor = trend == "increasing" and {0.3, 0.8, 0.4}
              or trend == "decreasing" and {0.8, 0.3, 0.3}
              or {0.7, 0.7, 0.7}
            GameTooltip:AddLine(trendText, unpack(trendColor))
          end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffaaaaaa[Left Click]|r  View Item",      1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Star]|r         Favorite",      1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Right Click]|r Add to Queue",   1, 1, 1)
        GameTooltip:Show()
      end
    end)
    row:SetScript("OnLeave", function()
      if GameTooltip then GameTooltip:Hide() end
    end)

    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, button)
      local mouseX = GetCursorPosition() / self:GetEffectiveScale()
      local selfX = self:GetLeft()

      if button == "RightButton" then
        if self.itemData and Queue then
          local data = self.itemData
          Queue.AddToQueue(data.itemID, data.name, 1, data.profit, data.reagents)
          if DecorAH._updateQueueCount then DecorAH._updateQueueCount() end
        end
        return
      end

      if button == "LeftButton" then
        local starCol = COLS_BY_KEY["star"]
        if starCol then
          local starLeft = selfX + GetColX(starCol)
          local starRight = starLeft + starCol.w
          if mouseX >= starLeft and mouseX <= starRight then
            if Favorites and self.itemID then
              Favorites.ToggleFavorite(self.itemID)
              InvalidateFilteredCache()
              if DecorAH._refreshTable then DecorAH._refreshTable() end
            end
            return
          end
        end

        local IA = NS.UI and NS.UI.ItemInteractions
        if IA and self.itemData then
          local it = {
            itemID = self.itemData.itemID,
            id     = self.itemData.itemID,
            title  = self.itemData.name,
            source = { type = "profession", itemID = self.itemData.itemID },
          }
          IA:HandleMouseUp(it, "LeftButton")
        end
      end
    end)
  end
  row:Show()
  row:ClearAllPoints()
  tinsert(activeRows, row)
  return row
end

local function ReleaseAllRows()
  for _, r in ipairs(activeRows) do
    r:Hide()
    r:ClearAllPoints()
    tinsert(rowPool, r)
  end
  activeRows = {}
end

local cachedFiltered = nil
local cachedFilteredDirty = true

InvalidateFilteredCache = function()
  cachedFilteredDirty = true
end

local function RenderVisibleRows()
  if not frame or not scrollChild then return end
  if not cachedFiltered then return end

  local filtered = cachedFiltered
  local scrollOffset = scrollFrame and scrollFrame.GetVerticalScroll and scrollFrame:GetVerticalScroll() or 0
  local viewH        = (scrollFrame and scrollFrame.GetHeight and scrollFrame:GetHeight()) or 400
  local OVERSCAN     = ROW_H * 4

  local firstIdx = math.max(1,         math.floor((scrollOffset - OVERSCAN) / ROW_H) + 1)
  local lastIdx  = math.min(#filtered, math.ceil ((scrollOffset + viewH + OVERSCAN) / ROW_H))

  ReleaseAllRows()
  local accent, success, danger, muted = T.accent, T.success, T.danger, T.textMuted

  for i = firstIdx, lastIdx do
    local rowData = filtered[i]
    local row = AcquireRow()
    local y = -(i - 1) * ROW_H
    row:SetPoint("TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", 0, y)
    row.itemID   = rowData.itemID
    row.itemData = rowData

    local c = row.cells
    for key, cell in pairs(c) do
      local col = COLS_BY_KEY[key]
      if col then
        if col._visible then
          cell:Show()
          cell:ClearAllPoints()
          if cell._isTexture then
            cell:SetPoint("LEFT", GetColX(col) + 3, 0)
          else
            cell:SetPoint("LEFT", GetColX(col) + 2, 0)
          end
        else
          cell:Hide()
        end
      end
    end

    if c.star and c.star:IsShown() then
      local isFav = Favorites and Favorites.IsFavorite(rowData.itemID)
      if c.star._isTexture then
        if c.star.SetAtlas then
          c.star:SetAtlas(isFav and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off", false)
            c.star:SetSize(14, 14)
        end
        c.star:SetAlpha(isFav and 1 or 0.5)
      else
        c.star:SetText(isFav and "+" or "-")
        c.star:SetTextColor(unpack(isFav and (accent or {0.9,0.72,0.18,1}) or (muted or {0.65,0.65,0.68,1})))
      end
    end
    if c.name and c.name:IsShown() then
      c.name:SetText(rowData.name or "?")
      c.name:SetTextColor(unpack(accent or {0.9,0.72,0.18,1}))
    end
    if c.profession and c.profession:IsShown() then
      c.profession:SetText(rowData.profession or "")
      c.profession:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
    end
    if c.expansion and c.expansion:IsShown() then
      c.expansion:SetText(rowData.expansion or "")
      c.expansion:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
    end
    if c.lumberType and c.lumberType:IsShown() then
      c.lumberType:SetText(rowData.lumberTypeName or "-")
      c.lumberType:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
    end
    if c.name and c.name:IsShown() and contentWidth > 0 then
      local lastCol = COLS[#COLS]
      local nameW = contentWidth - GetColX(lastCol) - lastCol.w - 16
      if nameW > 80 then c.name:SetWidth(nameW) end
    end
    if c.cost and c.cost:IsShown() then
      c.cost:SetText(PriceSource and PriceSource.FormatGold(rowData.cost) or "?")
      c.cost:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
    end
    if c.sell and c.sell:IsShown() then
      c.sell:SetText(PriceSource and PriceSource.FormatGold(rowData.sell) or "?")
      c.sell:SetTextColor(unpack(accent or {0.9,0.72,0.18,1}))
    end
    if c.profit and c.profit:IsShown() then
      if rowData.profit ~= nil then
        local color = (rowData.profit >= 0) and (success or {0.3,0.8,0.4,1}) or (danger or {0.8,0.28,0.28,1})
        c.profit:SetTextColor(unpack(color))
        c.profit:SetText(PriceSource and PriceSource.FormatGold(rowData.profit) or "?")
      else
        c.profit:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
        c.profit:SetText("?")
      end
    end
    if c.ppl and c.ppl:IsShown() then
      if rowData.ppl ~= nil then
        local color = (rowData.ppl >= 0) and (success or {0.3,0.8,0.4,1}) or (danger or {0.8,0.28,0.28,1})
        c.ppl:SetTextColor(unpack(color))
        c.ppl:SetText(PriceSource and PriceSource.FormatGold(rowData.ppl) or "?")
      else
        c.ppl:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
        c.ppl:SetText("-")
      end
    end
    if c.crafter and c.crafter:IsShown() then
      if rowData.crafter then
        local color = rowData.known and (T.text or {0.92,0.92,0.92,1}) or (muted or {0.65,0.65,0.68,1})
        c.crafter:SetTextColor(unpack(color))
        c.crafter:SetText(rowData.crafter)
      else
        c.crafter:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
        c.crafter:SetText("-")
      end
    end
    if c.margin and c.margin:IsShown() then
      if rowData.margin ~= nil then
        local color = (rowData.margin >= 0) and (success or {0.3,0.8,0.4,1}) or (danger or {0.8,0.28,0.28,1})
        c.margin:SetTextColor(unpack(color))
        c.margin:SetText(format("%.0f%%", rowData.margin))
      else
        c.margin:SetTextColor(unpack(muted or {0.65,0.65,0.68,1}))
        c.margin:SetText("-")
      end
    end
  end
end

local function RefreshTable()
  if not frame or not scrollChild then return end
  if not frame:IsShown() then return end

  GetVisibleColumns(contentWidth)

  for _, btn in ipairs(headerButtons) do
    if btn and btn._col then
      local col = btn._col
      if col._visible then
        btn:Show()
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", GetColX(col), 0)
      else
        btn:Hide()
      end
    end
  end

  local filterProf   = (professionDropdown  and professionDropdown.GetValue  and professionDropdown:GetValue())  or "All"
  local filterExp    = (expansionDropdown   and expansionDropdown.GetValue   and expansionDropdown:GetValue())   or "All"
  local filterLumber = (lumberTypeDropdown  and lumberTypeDropdown.GetValue  and lumberTypeDropdown:GetValue())  or "All"
  local filterSearch = (searchBox and searchBox.GetText and searchBox:GetText()) or ""
  local knownOnly    = (knownOnlyCheck    and knownOnlyCheck.checked)
  local altProfsOnly = (altProfessionsCheck and altProfessionsCheck.checked)

  if cachedFilteredDirty or not cachedFiltered then
    cachedFilteredDirty = false

    BuildDataRows()

    if History then
      if not DecorAH._lastHistoryRecord then DecorAH._lastHistoryRecord = 0 end
      if time() - DecorAH._lastHistoryRecord > 3600 then
        History.RecordBulkSnapshot(dataRows)
        DecorAH._lastHistoryRecord = time()
      end
    end

    if Favorites then
      local alerts = Favorites.CheckAlerts(dataRows)
      for _, alert in ipairs(alerts) do
      end
    end

    if (knownOnly or altProfsOnly) and RecipeTracker() then
      local allChars = RecipeTracker():GetAllCharacters()
      local hasData, recipeCount = false, 0
      for _, charData in pairs(allChars) do
        if charData.recipes and next(charData.recipes) then
          hasData = true
          for _ in pairs(charData.recipes) do recipeCount = recipeCount + 1 end
        end
      end
      if not DecorAH._lastFilterWarning then DecorAH._lastFilterWarning = 0 end
      local now = time()
      if not hasData and (now - DecorAH._lastFilterWarning) > 30 then
        DecorAH._lastFilterWarning = now
      elseif hasData and recipeCount < 50 and (now - DecorAH._lastFilterWarning) > 30 then
        DecorAH._lastFilterWarning = now
      end
    end

    cachedFiltered = ApplyFiltersAndSort(filterProf, filterExp, filterLumber, filterSearch, knownOnly, altProfsOnly)
  end

  local filtered = cachedFiltered

  if recipeCountLabel then
    if knownOnly or altProfsOnly then
      recipeCountLabel:SetText(format("%d / %d recipes", #filtered, #dataRows))
      recipeCountLabel:SetTextColor(unpack(T.accent or {0.9,0.72,0.18,1}))
    else
      recipeCountLabel:SetText(format("%d recipes", #dataRows))
      recipeCountLabel:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))
    end
  end

  scrollChild:SetHeight(math.max(#filtered * ROW_H, 1))

  if #filtered == 0 then
    if not DecorAH._emptyLabel then
      DecorAH._emptyLabel = NewFS(scrollChild, "GameFontNormalLarge")
      DecorAH._emptyLabel:SetPoint("CENTER", scrollChild, "TOP", 0, -100)
      DecorAH._emptyLabel:SetTextColor(unpack(T.textMuted or {0.65,0.65,0.68,1}))
    end
    local msg = "No items found"
    if knownOnly then
      msg = "No known recipes found\n\n|cff888888Open profession window to scan|r"
    elseif altProfsOnly then
      msg = "No alt recipes found\n\n|cff888888Log into alts and open professions to scan|r"
    elseif filterSearch ~= "" then
      msg = "No items match your search"
    end
    DecorAH._emptyLabel:SetText(msg)
    DecorAH._emptyLabel:Show()
    ReleaseAllRows()
    return
  else
    if DecorAH._emptyLabel then DecorAH._emptyLabel:Hide() end
  end

  RenderVisibleRows()
end

DecorAH._refreshTable  = RefreshTable
DecorAH._invalidate    = InvalidateDataRows
DecorAH._invalidFilter = InvalidateFilteredCache
_refreshTable = RefreshTable

local function RefreshSourceHighlights()
  for src, btn in pairs(sourceButtons) do
    if btn and btn.UpdateHighlight then btn:UpdateHighlight() end
  end
end

local function CreateHeaderRow(parent, y)
  local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 0, y)
  header:SetPoint("TOPRIGHT", 0, y)
  header:SetHeight(ROW_H)
  header:SetFrameLevel(parent:GetFrameLevel() + 2)
  Backdrop(header, T.header, T.border)

  for i, col in ipairs(COLS) do
    local btn = CreateFrame("Button", nil, header)
    btn:SetPoint("LEFT", GetColX(col), 0)
    btn:SetSize(col.w, ROW_H)
    btn.colKey = col.key
    btn.colLabel = col.label
    btn.colAlign = col.align
    btn._col = col

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(unpack(T.accentSoft or { 0.90, 0.72, 0.18, 0.28 }))
    highlight:SetBlendMode("ADD")
    btn._highlight = highlight

    btn:SetScript("OnClick", function(self)
      if sortCol == self.colKey then
        sortRev = not sortRev
      else
        sortCol = self.colKey
        sortRev = (self.colKey == "name" or self.colKey == "profession" or self.colKey == "expansion" or self.colKey == "lumberType") and false or true
      end
      for _, b in ipairs(headerButtons) do
        if b and b.UpdateSortIndicator then b:UpdateSortIndicator() end
      end
      InvalidateFilteredCache()
      RefreshTable()
    end)
    btn.UpdateSortIndicator = function(self)
      local fs = self._sortText
      if not fs then return end
      if sortCol ~= self.colKey then
        fs:SetText("")
        fs:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
        return
      end
      fs:SetText(sortRev and " ^" or " v")
      fs:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
    end
    local label = NewFS(btn, "GameFontNormal")
    label:SetJustifyH(col.align or "LEFT")
    label:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
    btn._label = label

    local sortText = NewFS(btn, "GameFontNormalSmall")
    sortText:SetText("")
    btn._sortText = sortText

    if col.align == "RIGHT" then
      label:SetPoint("RIGHT", -2, 0)
      label:SetPoint("LEFT", 16, 0)
      sortText:SetPoint("RIGHT", label, "LEFT", -2, 0)
    elseif col.align == "CENTER" then
      label:SetPoint("CENTER", 0, 0)
      sortText:SetPoint("LEFT", label, "RIGHT", 2, 0)
    else
      label:SetPoint("LEFT", 2, 0)
      label:SetPoint("RIGHT", -16, 0)
      sortText:SetPoint("LEFT", label, "RIGHT", 2, 0)
    end
    label:SetText(col.label)
    tinsert(headerButtons, btn)
  end
end

SLASH_DECORGALLERY1 = "/gallery"
SlashCmdList["DECORGALLERY"] = function()
  if NS.DecorAH and NS.DecorAH.Gallery then
    NS.DecorAH.Gallery:Toggle()
  end
end

function DH:Create(parentFrame, embedded)
  if frame then return end

  local g = GetDB()
  local win = g and g.window or {}

  self._embedded = embedded

  local canvas

  if embedded and parentFrame then
    frame = CreateFrame("Frame", "HomeDecorDecorAH", parentFrame)
    frame:SetAllPoints(parentFrame)
    frame._embedded = true
    self.frame = frame
    canvas = frame

    frame:SetScript("OnSizeChanged", function(self)
      if scrollFrame then
        C_Timer.After(0.05, function()
          if not scrollFrame then return end
          local sw = scrollFrame:GetWidth() or 400
          contentWidth = math.max(400, sw - 4)
          if scrollChild then
            scrollChild:SetWidth(contentWidth + 20)
          end
          RefreshTable()
        end)
      end
    end)
  else
    local w = (win.width and win.width >= MIN_W and win.width <= MAX_W) and win.width or DEFAULT_W
    local h = (win.height and win.height >= MIN_H and win.height <= MAX_H) and win.height or DEFAULT_H
    w = math.min(math.max(w, MIN_W), MAX_W)
    h = math.min(math.max(h, MIN_H), MAX_H)

    frame = CreateFrame("Frame", "HomeDecorDecorAH", UIParent, "BackdropTemplate")
    frame:SetSize(w, h)
    frame:SetPoint(win.point or "CENTER", UIParent, win.relPoint or "CENTER", win.x or 0, win.y or 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(50)
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame._embedded = false
    self.frame = frame

    frame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8x8",
      edgeFile = "Interface\\Buttons\\WHITE8x8",
      tile = false,
      edgeSize = 2,
      insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(0.045, 0.045, 0.05, 1.0)
    frame:SetBackdropBorderColor(0.35, 0.35, 0.40, 1.0)

    local shadow = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow:SetColorTexture(0, 0, 0, 0.7)
    shadow:SetPoint("TOPLEFT", -4, 4)
    shadow:SetPoint("BOTTOMRIGHT", 4, -4)

    local function saveWindow()
      local g = GetDB()
      if g and g.window and frame then
        local point, _, relPoint, x, y = frame:GetPoint()
        g.window.point = point
        g.window.relPoint = relPoint
        g.window.x = x
        g.window.y = y
        g.window.width = frame:GetWidth()
        g.window.height = frame:GetHeight()
      end
    end

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
      self:StopMovingOrSizing()
      saveWindow()
    end)

    local BASE_CANVAS_W, BASE_CANVAS_H = 920, 580
    canvas = CreateFrame("Frame", nil, frame)
    canvas:SetSize(BASE_CANVAS_W, BASE_CANVAS_H)
    canvas._baseW = BASE_CANVAS_W
    canvas._baseH = BASE_CANVAS_H
    canvas:SetPoint("CENTER")
    frame.canvas = canvas

    local function ApplyCanvasScale()
      if not frame or not frame.canvas then return end
      local c = frame.canvas
      local bw = c._baseW or BASE_CANVAS_W
      local bh = c._baseH or BASE_CANVAS_H
      local w = frame:GetWidth() or bw
      local h = frame:GetHeight() or bh
      local sx, sy = w / bw, h / bh
      local s = math.min(sx, sy)
      if s < 0.70 then s = 0.70 end
      if s > 1.35 then s = 1.35 end
      c:SetScale(s)
      c:ClearAllPoints()
      c:SetPoint("CENTER")
      contentWidth = math.max(100, (bw - 40))
      if scrollChild then
        scrollChild:SetWidth(contentWidth + 20)
      end
      C_Timer.After(0, RefreshTable)
    end

    frame:SetScript("OnSizeChanged", function(self)
      ApplyCanvasScale()
    end)
  end

  if not embedded then
    local title = NewFS(canvas, "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText(L["DECOR_PRICING"])
    title:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))

    local closeBtn = CreateFrame("Button", nil, canvas, "BackdropTemplate")
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", -10, -10)
    Backdrop(closeBtn, T.panel, T.border)
    Hover(closeBtn)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetSize(14, 14)
    closeIcon:SetPoint("CENTER")
    closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeIcon:SetVertexColor(1, 0.82, 0.2, 1)
    closeBtn:SetScript("OnClick", function() DH:Hide() end)
  end

  local topBar = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  if embedded then
    topBar:SetPoint("TOPLEFT", canvas, "TOPLEFT", 8, -52)
    topBar:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -8, -52)
  else
    topBar:SetPoint("TOPLEFT", 0, -44)
    topBar:SetPoint("TOPRIGHT", 0, -44)
  end
  topBar:SetHeight(40)
  topBar:SetFrameLevel(canvas:GetFrameLevel() + 5)
  Backdrop(topBar, T.header, T.border)

  local sourceLabel = NewFS(topBar, "GameFontNormal")
  sourceLabel:SetPoint("LEFT", 14, 0)
  sourceLabel:SetText(L["DECOR_AH_USE_PRICES_FROM"])
  sourceLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

  local sources = PriceSource and PriceSource.GetAvailableSources and PriceSource.GetAvailableSources() or { "Scan" }
  preferredSource = PriceSource and PriceSource.GetPreferredSource()
  if not preferredSource or preferredSource == "" then
    preferredSource = sources[1]
    if PriceSource then PriceSource.SetPreferredSource(preferredSource) end
  end

  local function MakeSourceButton(parent, label, srcKey, tooltip)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(82, 26)
    btn:SetFrameLevel(parent:GetFrameLevel() + 1)
    Backdrop(btn, T.panel, T.border)
    Hover(btn)
    btn._label = label
    btn._srcKey = srcKey
    btn._tooltip = tooltip
    local fs = NewFS(btn, "GameFontNormal")
    fs:SetPoint("CENTER")
    fs:SetText(label)
    fs:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    btn:SetScript("OnClick", function()
      preferredSource = srcKey
      if PriceSource then
        PriceSource.SetPreferredSource(srcKey)
        if PriceSource.FlushPriceCache then PriceSource.FlushPriceCache() end
      end
      RefreshSourceHighlights()
      InvalidateDataRows()
      C_Timer.After(0, RefreshTable)
    end)
    btn.UpdateHighlight = function(self)
      local active = (PriceSource and PriceSource.GetPreferredSource()) == self._srcKey
      self:SetBackdropColor(unpack(active and (T.accentDark or T.panel) or T.panel))
      fs:SetTextColor(unpack(active and (T.accent or { 0.9, 0.72, 0.18, 1 }) or T.text))
    end
    btn:SetScript("OnEnter", function(self)
      if self._tooltip and GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self._tooltip)
        GameTooltip:Show()
      end
      if btn.UpdateHighlight then btn:UpdateHighlight() end
    end)
    btn:SetScript("OnLeave", function()
      if GameTooltip then GameTooltip:Hide() end
      if btn.UpdateHighlight then btn:UpdateHighlight() end
    end)
    sourceButtons[srcKey] = btn
    return btn
  end

  local srcX = 120
  local sourceNames = { TSM = "TSM", Auctionator = "Auctionator" }
  local sourceTips = {
    TSM = "Use TSM market data. No AH scan needed.",
    Auctionator = "Use Auctionator's last scan. Run a full scan in Auctionator to refresh.",
  }
  for _, key in ipairs(sources) do
    local lbl = sourceNames[key] or key
    local tip = sourceTips[key] or ("Use " .. lbl .. " prices.")
    local b = MakeSourceButton(topBar, lbl, key, tip)
    b:SetPoint("LEFT", srcX, 0)
    srcX = srcX + 88
  end

  local scanTimeText = NewFS(topBar, "GameFontNormal")
  scanTimeText:SetPoint("LEFT", srcX + 12, 0)
  scanTimeText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

  local scanTimeButton = CreateFrame("Button", nil, topBar)
  scanTimeButton:SetAllPoints(scanTimeText)
  scanTimeButton:SetScript("OnEnter", function()
    if GameTooltip then
      GameTooltip:SetOwner(scanTimeButton, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["DECOR_AH_LAST_SCAN"])
      if AuctionScan and AuctionScan.IsAuctionatorAvailable and AuctionScan.IsAuctionatorAvailable() then
        GameTooltip:AddLine(L["DECOR_AH_CLICK_MARK_SCANNED"], 1, 1, 1, true)
        GameTooltip:AddLine(L["DECOR_AH_OPENS_AH"], 0.65, 0.65, 0.68, true)
      else
        GameTooltip:AddLine(L["DECOR_AH_INSTALL_TIP"], 1, 1, 1, true)
      end
      GameTooltip:Show()
    end
    scanTimeText:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
  end)
  scanTimeButton:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
    local lastScan = PriceSource and PriceSource.GetLastAuctionatorScanTime and PriceSource.GetLastAuctionatorScanTime()
    if lastScan and (time() - lastScan) < 60 then
      scanTimeText:SetTextColor(unpack(T.success or { 0.3, 0.8, 0.4, 1 }))
    else
      scanTimeText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
    end
  end)

  local function UpdateScanTimeDisplay()
    local src = PriceSource and PriceSource.GetPreferredSource and PriceSource.GetPreferredSource()
    if src == "TSM" then
      scanTimeText:SetText("")
      return
    end

    if not AuctionScan or not AuctionScan.IsAuctionatorAvailable or not AuctionScan.IsAuctionatorAvailable() then
      scanTimeText:SetText(L["DECOR_AH_INSTALL_AUCTIONATOR"])
      scanTimeText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
      return
    end

    local lastScan = PriceSource and PriceSource.GetLastAuctionatorScanTime and PriceSource.GetLastAuctionatorScanTime()
    if lastScan then
      local ago = time() - lastScan
      local timeStr
      if ago < 60 then
        timeStr = L["DECOR_AH_JUST_SCANNED"]
        scanTimeText:SetTextColor(unpack(T.success or { 0.3, 0.8, 0.4, 1 }))
      elseif ago < 3600 then
        timeStr = format(L["DECOR_AH_SCANNED_MIN_AGO"], floor(ago / 60))
        scanTimeText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
      else
        timeStr = format(L["DECOR_AH_SCANNED_HOURS_AGO"], floor(ago / 3600))
        scanTimeText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
      end
      scanTimeText:SetText(timeStr)
    else
      scanTimeText:SetText(L["DECOR_AH_RUN_FULL_SCAN"])
      scanTimeText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
    end
  end

  scanTimeButton:SetScript("OnClick", function()
    if PriceSource and PriceSource.SetLastAuctionatorScanTime then
      PriceSource.SetLastAuctionatorScanTime(time())
    end
    UpdateScanTimeDisplay()
    RefreshTable()
  end)

  UpdateScanTimeDisplay()
  local scanTicker = C_Timer.NewTicker(30, UpdateScanTimeDisplay)

  NS.UI.DecorAH._updateScanTime = UpdateScanTimeDisplay

  local queueBtn = CreateFrame("Button", nil, topBar, "BackdropTemplate")
  queueBtn:SetSize(100, 26)
  queueBtn:SetPoint("RIGHT", -12, 0)
  queueBtn:SetFrameLevel(topBar:GetFrameLevel() + 1)
  Backdrop(queueBtn, T.panel, T.border)
  Hover(queueBtn, T.panel, T.hover)
  local queueBtnText = NewFS(queueBtn, "GameFontNormal")
  queueBtnText:SetPoint("CENTER")
  queueBtnText:SetText(L["DECOR_AH_QUEUE_ZERO"])
  queueBtnText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
  queueBtn:SetScript("OnClick", function()
    if DecorAH._queueFrame and DecorAH._queueFrame:IsShown() then
      DecorAH._queueFrame:Hide()
    else
      DH:ShowQueueFrame()
    end
  end)
  queueBtn:SetScript("OnEnter", function()
    if GameTooltip then
      GameTooltip:SetOwner(queueBtn, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["DECOR_AH_CRAFTING_QUEUE"])
      GameTooltip:AddLine(L["DECOR_AH_RIGHTCLICK_ADD_QUEUE"], 1, 1, 1, true)
      GameTooltip:AddLine(L["DECOR_AH_VIEW_MATERIALS"], 0.65, 0.65, 0.68, true)
      GameTooltip:Show()
    end
  end)
  queueBtn:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)

  local salesBtn = CreateFrame("Button", nil, topBar, "BackdropTemplate")
  salesBtn:SetSize(80, 26)
  salesBtn:SetPoint("RIGHT", queueBtn, "LEFT", -5, 0)
  salesBtn:SetFrameLevel(topBar:GetFrameLevel() + 1)
  Backdrop(salesBtn, T.panel, T.border)
  Hover(salesBtn, T.panel, T.hover)
  local salesBtnText = NewFS(salesBtn, "GameFontNormal")
  salesBtnText:SetPoint("CENTER")
  salesBtnText:SetText(L["DECOR_AH_SALES"])
  salesBtnText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
  salesBtn:SetScript("OnClick", function()
    if NS.UI.DecorAH_SalesUI and NS.UI.DecorAH_SalesUI.ToggleSalesPanel then
      NS.UI.DecorAH_SalesUI.ToggleSalesPanel()
    end
  end)
  salesBtn:SetScript("OnEnter", function()
    if GameTooltip then
      GameTooltip:SetOwner(salesBtn, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["DECOR_AH_SALES_TRACKER"], 1, 1, 1)
      GameTooltip:AddLine(L["DECOR_AH_VIEW_SOLD"], nil, nil, nil, true)
      GameTooltip:AddLine(" ", nil, nil, nil, true)
      GameTooltip:AddLine(L["DECOR_AH_TRACKS_MAIL"], 0.7, 0.7, 0.7, true)
      GameTooltip:Show()
    end
  end)
  salesBtn:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  frame.salesBtn = salesBtn

  local function UpdateQueueCount()
    if Queue then
      local size = Queue.GetQueueSize()
      queueBtnText:SetText(format(L["DECOR_AH_QUEUE_COUNT"], size))
    end
  end

  DecorAH._updateQueueCount = UpdateQueueCount
  UpdateQueueCount()

  RefreshSourceHighlights()
  local filterRow = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  if embedded then
    filterRow:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -98)
    filterRow:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -14, -98)
  else
    filterRow:SetPoint("TOPLEFT", 14, -90)
    filterRow:SetPoint("TOPRIGHT", -14, -90)
  end
  filterRow:SetHeight(32)
  Backdrop(filterRow, T.panel, nil)

  local profs = { "All", "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring" }
  local expansions = { "All", "Midnight", "Khaz Algar", "Dragon Isles", "Shadowlands", "Kul Tiran", "Legion", "Draenor", "Pandaria", "Cataclysm", "Northrend", "Outland", "Classic" }
  local lumberTypes = { "All" }
  for _, name in pairs(LUMBER_NAMES) do
    tinsert(lumberTypes, name)
  end
  sort(lumberTypes, function(a, b)
    if a == "All" then return true end
    if b == "All" then return false end
    return a < b
  end)

  local MENU_ITEM_H = 26
  local function MakeDropdown(parent, options, default, width, onChange)
    local dd = CreateFrame("Button", nil, parent, "BackdropTemplate")
    dd:SetSize(width or 100, 30)
    Backdrop(dd, T.row or T.panel, T.border)
    Hover(dd)
    dd._value = default or options[1]
    dd._options = options
    dd.text = NewFS(dd, "GameFontNormal")
    dd.text:SetPoint("LEFT", 8, 0)
    dd.text:SetPoint("RIGHT", -24, 0)
    dd.text:SetJustifyH("LEFT")
    dd.text:SetText(dd._value)
    dd.text:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    local arrow = dd:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetText("v")
    arrow:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
    dd.GetValue = function(self) return self._value end
    dd.SetValue = function(self, v)
      self._value = v
      self.text:SetText(v)
      if onChange then onChange(v) end
    end
    dd:SetScript("OnClick", function(self)
      if self._menu and self._menu:IsShown() then self._menu:Hide(); return end
      local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
      menu:SetFrameStrata("FULLSCREEN_DIALOG")
      menu:SetSize(width or 100, #options * MENU_ITEM_H + 6)
      menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
      Backdrop(menu, T.bg, T.border)
      for i, opt in ipairs(options) do
        local btn = CreateFrame("Button", nil, menu, "BackdropTemplate")
        btn:SetPoint("TOPLEFT", 3, -3 - (i - 1) * MENU_ITEM_H)
        btn:SetPoint("TOPRIGHT", -3, -3 - (i - 1) * MENU_ITEM_H)
        btn:SetHeight(MENU_ITEM_H)
        Backdrop(btn, T.panel, nil)
        btn:SetScript("OnEnter", function() btn:SetBackdropColor(unpack(T.hover or { 0.17, 0.17, 0.2, 1 })) end)
        btn:SetScript("OnLeave", function() btn:SetBackdropColor(0, 0, 0, 0) end)
        local fs = NewFS(btn, "GameFontNormal")
        fs:SetPoint("LEFT", 6, 0)
        fs:SetText(opt)
        fs:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
        btn:SetScript("OnClick", function()
          dd:SetValue(opt)
          InvalidateFilteredCache()
          RefreshTable()
          menu:Hide()
        end)
      end
      menu:SetScript("OnHide", function() if dd._menu == menu then dd._menu = nil end end)
      dd._menu = menu
      menu:Show()
    end)
    return dd
  end

  local profLabel = NewFS(filterRow, "GameFontNormal")
  profLabel:SetPoint("LEFT", 8, 0)
  profLabel:SetText(L["DECOR_AH_PROFESSION_COLON"])
  profLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
  professionDropdown = MakeDropdown(filterRow, profs, L["FILTER_ALL"], 124, nil)
  professionDropdown:SetPoint("LEFT", profLabel, "RIGHT", 6, 0)

  local expLabel = NewFS(filterRow, "GameFontNormal")
  expLabel:SetPoint("LEFT", professionDropdown, "RIGHT", 14, 0)
  expLabel:SetText(L["DECOR_AH_EXPANSION_COLON"])
  expLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
  expansionDropdown = MakeDropdown(filterRow, expansions, L["FILTER_ALL"], 108, nil)
  expansionDropdown:SetPoint("LEFT", expLabel, "RIGHT", 6, 0)

  local lumberLabel = NewFS(filterRow, "GameFontNormal")
  lumberLabel:SetPoint("LEFT", expansionDropdown, "RIGHT", 14, 0)
  lumberLabel:SetText(L["DECOR_AH_LUMBER_COLON"])
  lumberLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
  lumberTypeDropdown = MakeDropdown(filterRow, lumberTypes, L["FILTER_ALL"], 100, nil)
  lumberTypeDropdown:SetPoint("LEFT", lumberLabel, "RIGHT", 6, 0)

  local filterRow2 = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  if embedded then
    filterRow2:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -134)
    filterRow2:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -14, -134)
  else
    filterRow2:SetPoint("TOPLEFT", 14, -126)
    filterRow2:SetPoint("TOPRIGHT", -14, -126)
  end
  filterRow2:SetHeight(28)
  Backdrop(filterRow2, T.panel, nil)

  local function MakeCheck(parent, label, xAnchor, xOff)
    local chk = CreateFrame("Button", nil, parent)
    chk:SetSize(22, 22)
    if xAnchor then
      chk:SetPoint("LEFT", xAnchor, "RIGHT", xOff, 0)
    else
      chk:SetPoint("LEFT", xOff or 8, 0)
    end
    chk.checked = false
    local tex = chk:CreateTexture(nil, "ARTWORK")
    tex:SetSize(16, 16)
    tex:SetPoint("LEFT", 0, 0)
    tex:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    local fs = NewFS(chk, "GameFontNormal")
    fs:SetPoint("LEFT", 22, 0)
    fs:SetText(label)
    fs:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    chk:SetScript("OnClick", function(self)
      self.checked = not self.checked
      tex:SetTexture(self.checked and "Interface\\Buttons\\UI-CheckBox-Check" or "Interface\\Buttons\\UI-CheckBox-Up")
      InvalidateFilteredCache()
      RefreshTable()
    end)
    return chk
  end

  local searchLabel = NewFS(filterRow2, "GameFontNormal")
  searchLabel:SetPoint("LEFT", 8, 0)
  searchLabel:SetText(L["DECOR_AH_SEARCH_COLON"])
  searchLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
  searchBox = CreateFrame("EditBox", nil, filterRow2, "BackdropTemplate")
  searchBox:SetSize(120, 22)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 6, 0)
  Backdrop(searchBox, T.row or T.panel, T.border)
  searchBox:SetAutoFocus(false)
  searchBox:SetFontObject("GameFontNormal")
  searchBox:SetTextInsets(6, 6, 0, 0)
  searchBox:SetScript("OnTextChanged", function() InvalidateFilteredCache(); RefreshTable() end)
  searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

  knownOnlyCheck = MakeCheck(filterRow2, "Known only", searchBox, 14)
  altProfessionsCheck = MakeCheck(filterRow2, "Alt Professions", knownOnlyCheck, 100)

  recipeCountLabel = NewFS(filterRow2, "GameFontNormal")
  recipeCountLabel:SetPoint("RIGHT", -8, 0)
  recipeCountLabel:SetJustifyH("RIGHT")
  recipeCountLabel:SetText("0 / 0 recipes")
  recipeCountLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

  local headerY = embedded and (-134 - 28 - 4) or (-126 - 28 - 4)
  CreateHeaderRow(canvas, headerY)
  for _, b in ipairs(headerButtons) do
    if b.UpdateSortIndicator then b:UpdateSortIndicator() end
  end

  local scrollBottom, scrollRight = 14, 14
  scrollFrame = CreateFrame("ScrollFrame", nil, canvas, "ScrollFrameTemplate")
  if embedded then
    scrollFrame:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, headerY - ROW_H)
    scrollFrame:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -scrollRight - 24, scrollBottom + 24)
  else
    scrollFrame:SetPoint("TOPLEFT", 14, headerY - ROW_H)
    scrollFrame:SetPoint("BOTTOMRIGHT", -scrollRight - 24, scrollBottom + 24)
  end
  scrollChild = CreateFrame("Frame", nil, scrollFrame)
  contentWidth = (scrollFrame:GetWidth() or 400) - 4
  scrollChild:SetSize(contentWidth + 20, 1)
  scrollFrame:SetScrollChild(scrollChild)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end

  local _scrollDebounce = nil
  scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    self:SetVerticalScroll(offset)
    if _scrollDebounce then _scrollDebounce:Cancel() end
    _scrollDebounce = C_Timer.NewTimer(0.04, function()
      _scrollDebounce = nil
      RenderVisibleRows()
    end)
  end)

  if embedded then
    frame:SetScript("OnShow", function(self)
      C_Timer.After(0.1, function()
        if not self or not self:IsShown() or not scrollFrame then return end
        local sw = scrollFrame:GetWidth() or 400
        contentWidth = math.max(400, sw - 4)
        if scrollChild then
          scrollChild:SetWidth(contentWidth + 20)
        end
        RefreshTable()
      end)
    end)
  end

  if not embedded then
    local SCALE_MIN_S, SCALE_MAX_S = 0, 200
    local scaleToWidth = function(s)
      s = math.max(SCALE_MIN_S, math.min(SCALE_MAX_S, s))
      return MIN_W + (s / SCALE_MAX_S) * (MAX_W - MIN_W)
    end
    local widthToScale = function(w)
      w = math.max(MIN_W, math.min(MAX_W, w))
      return (w - MIN_W) / (MAX_W - MIN_W) * SCALE_MAX_S
    end
    local scaleHolder = CreateFrame("Frame", nil, canvas)
    scaleHolder:SetSize(200, 22)
    scaleHolder:SetPoint("TOPRIGHT", -14, -8)
    local scaleLabel = NewFS(scaleHolder, "GameFontNormal")
    scaleLabel:SetPoint("LEFT", 0, 0)
    scaleLabel:SetText(L["SCALE"])
    scaleLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
  local sliderBG = CreateFrame("Frame", nil, scaleHolder, "BackdropTemplate")
  Backdrop(sliderBG, T.panel, T.border)
  sliderBG:SetPoint("LEFT", scaleLabel, "RIGHT", 6, 0)
  sliderBG:SetSize(100, 18)
  local slider = CreateFrame("Slider", nil, sliderBG)
  slider:SetAllPoints(sliderBG)
  slider:SetMinMaxValues(SCALE_MIN_S, SCALE_MAX_S)
  slider:SetValueStep(10)
  slider:SetObeyStepOnDrag(true)
  slider:SetOrientation("HORIZONTAL")
  slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  local thumb = slider:GetThumbTexture()
  if thumb then thumb:Hide() end
  local fill = sliderBG:CreateTexture(nil, "ARTWORK")
  fill:SetPoint("LEFT", 4, 0)
  fill:SetHeight(12)
  fill:SetColorTexture(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
  local valueBox = CreateFrame("Frame", nil, scaleHolder, "BackdropTemplate")
  Backdrop(valueBox, T.panel, T.border)
  valueBox:SetPoint("LEFT", sliderBG, "RIGHT", 6, 0)
  valueBox:SetSize(40, 18)
  local valueText = NewFS(valueBox, "GameFontNormal")
  valueText:SetPoint("CENTER", 0, 0)
  local function setScaleVisual(s)
    s = math.max(SCALE_MIN_S, math.min(SCALE_MAX_S, s))
    local pct = s / SCALE_MAX_S
    fill:SetWidth((sliderBG:GetWidth() - 8) * pct)
    valueText:SetText(floor(s))
  end
  local function applyScaleFromSlider(s)
    s = floor(s / 10) * 10
    s = math.max(SCALE_MIN_S, math.min(SCALE_MAX_S, s))
    setScaleVisual(s)
    local newW = floor(scaleToWidth(s))
    local newH = floor(BASE_CANVAS_H * (newW / BASE_CANVAS_W))
    newH = math.max(MIN_H, math.min(MAX_H, newH))
    frame:SetSize(newW, newH)
    local g = GetDB()
    if g and g.window then
      g.window.width = newW
      g.window.height = newH
    end
    ApplyCanvasScale()
  end
  slider:SetValue(widthToScale(w))
  setScaleVisual(widthToScale(w))
  slider:SetScript("OnValueChanged", function(_, v)
    setScaleVisual(math.max(SCALE_MIN_S, math.min(SCALE_MAX_S, v)))
  end)
  slider:SetScript("OnMouseUp", function(self)
    applyScaleFromSlider(self:GetValue())
  end)
  Hover(sliderBG, T.panel, T.hover)
  Hover(valueBox, T.panel, T.hover)

  local resizeGrip = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  resizeGrip:SetSize(24, 24)
  resizeGrip:SetPoint("BOTTOMRIGHT", 0, 0)
  resizeGrip:SetFrameLevel(frame:GetFrameLevel() + 4)
  resizeGrip:EnableMouse(true)
  resizeGrip:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" then return end
    self._resizing = true
    self._startW = frame:GetWidth()
    self._startH = frame:GetHeight()
    self._startX = GetCursorPosition()
    self._startY = select(2, GetCursorPosition())
  end)
  resizeGrip:SetScript("OnMouseUp", function(self, button)
    if button ~= "LeftButton" then return end
    self._resizing = nil
    saveWindow()
    if slider and slider.SetValue then slider:SetValue(widthToScale(frame:GetWidth())) end
    if setScaleVisual then setScaleVisual(widthToScale(frame:GetWidth())) end
  end)
  resizeGrip:SetScript("OnUpdate", function(self)
    if not self._resizing then return end
    local x, y = GetCursorPosition(), select(2, GetCursorPosition())
    local scale = frame:GetEffectiveScale() or 1
    local dx = (x - (self._startX or 0)) / scale
    local dy = ((self._startY or 0) - y) / scale
    local newW = math.min(MAX_W, math.max(MIN_W, (self._startW or 0) + dx))
    local newH = math.min(MAX_H, math.max(MIN_H, (self._startH or 0) + dy))
    frame:SetSize(newW, newH)
  end)
  local gripTex = resizeGrip:CreateTexture(nil, "ARTWORK")
  gripTex:SetPoint("BOTTOMRIGHT", -2, 2)
  gripTex:SetSize(16, 16)
  gripTex:SetTexture("Interface\\Cursor\\SizeNWSE")
  gripTex:SetAlpha(0.6)
    resizeGrip:SetScript("OnEnter", function() gripTex:SetAlpha(1) end)
    resizeGrip:SetScript("OnLeave", function()
      if not resizeGrip._resizing then gripTex:SetAlpha(0.6) end
    end)

    ApplyCanvasScale()
  end

  local ahEventFrame = CreateFrame("Frame")
  ahEventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
  ahEventFrame:SetScript("OnEvent", function()
    if not Queue or not Auctionator then return end

    local materials = Queue.GetTotalMaterials()
    if materials and next(materials) then
      C_Timer.After(1.5, function()
        DH:SendToAuctionator()
      end)
    end
  end)

  if not embedded then
    frame:Hide()
  end

  if NS.UI.DecorAH_SalesUI and NS.UI.DecorAH_SalesUI.Initialize then
    NS.UI.DecorAH_SalesUI.Initialize()
  end
end

function DH:ShowQueueFrame()

  local QueuePanel = NS.UI.DecorAH_Queue
  if QueuePanel and QueuePanel.Toggle then
    QueuePanel:Toggle()
    return
  end

  if not Queue and not NS.DecorAH.Queue then
    return
  end

  if DecorAH._queueFrame and DecorAH._queueFrame:IsShown() then
    DecorAH._queueFrame:Hide()
    return
  end

  if not DecorAH._queueFrame then
    local qf = CreateFrame("Frame", "HomeDecorQueueFrame", UIParent, "BackdropTemplate")
    qf:SetSize(400, 550)
    qf:SetPoint("RIGHT", UIParent, "RIGHT", -50, 0)
    qf:SetFrameStrata("DIALOG")
    qf:SetMovable(true)
    qf:EnableMouse(true)
    qf:RegisterForDrag("LeftButton")
    qf:SetScript("OnDragStart", function(self) self:StartMoving() end)
    qf:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    qf:SetClampedToScreen(true)
    Backdrop(qf, T.bg, T.border)

    local title = NewFS(qf, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["DECOR_AH_CRAFTING_QUEUE"])
    title:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))

    local closeBtn = CreateFrame("Button", nil, qf, "BackdropTemplate")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -12, -12)
    Backdrop(closeBtn, T.panel, T.border)
    Hover(closeBtn, T.panel, T.hover)
    local closeText = NewFS(closeBtn, "GameFontNormal")
    closeText:SetPoint("CENTER")
    closeText:SetText("X")
    closeText:SetTextColor(unpack(T.danger or { 0.8, 0.28, 0.28, 1 }))
    closeBtn:SetScript("OnClick", function() qf:Hide() end)

    local clearBtn = CreateFrame("Button", nil, qf, "BackdropTemplate")
    clearBtn:SetSize(70, 24)
    clearBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -8, 0)
    Backdrop(clearBtn, T.panel, T.border)
    Hover(clearBtn, T.panel, T.hover)
    local clearText = NewFS(clearBtn, "GameFontNormal")
    clearText:SetPoint("CENTER")
    clearText:SetText(L["DECOR_AH_CLEAR_ALL"])
    clearText:SetTextColor(unpack(T.danger or { 0.8, 0.28, 0.28, 1 }))
    clearBtn:SetScript("OnClick", function()
      if Queue then
        Queue.ClearQueue()
        DH:RefreshQueueFrame()
        if DecorAH._updateQueueCount then DecorAH._updateQueueCount() end
      end
    end)

    local scrollFrame = CreateFrame("ScrollFrame", nil, qf, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 180)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    local scrollWidth = scrollFrame:GetWidth() or 400
    scrollChild:SetSize(scrollWidth - 20, 400)
    scrollFrame:SetScrollChild(scrollChild)
    if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end
    qf.scrollChild = scrollChild
    qf.scrollFrame = scrollFrame
    qf.queueRows = {}

    local matPanel = CreateFrame("Frame", nil, qf, "BackdropTemplate")
    matPanel:SetPoint("BOTTOMLEFT", 16, 50)
    matPanel:SetPoint("BOTTOMRIGHT", -16, 50)
    matPanel:SetHeight(120)
    Backdrop(matPanel, T.panel, nil)

    local matTitle = NewFS(matPanel, "GameFontNormal")
    matTitle:SetPoint("TOPLEFT", 8, -8)
    matTitle:SetText(L["DECOR_AH_TOTAL_MATERIALS"])
    matTitle:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

    local matText = NewFS(matPanel, "GameFontNormalSmall")
    matText:SetPoint("TOPLEFT", 8, -28)
    matText:SetPoint("BOTTOMRIGHT", -8, 8)
    matText:SetJustifyH("LEFT")
    matText:SetJustifyV("TOP")
    matText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    qf.matText = matText

    local exportBtn = CreateFrame("Button", nil, qf, "BackdropTemplate")
    exportBtn:SetSize(90, 28)
    exportBtn:SetPoint("BOTTOMLEFT", 16, 12)
    Backdrop(exportBtn, T.accentDark or T.panel, T.border)
    Hover(exportBtn, T.accentDark, T.accentSoft)
    local exportText = NewFS(exportBtn, "GameFontNormal")
    exportText:SetPoint("CENTER")
    exportText:SetText(L["DECOR_AH_EXPORT"])
    exportText:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
    exportBtn:SetScript("OnClick", function() DH:ShowExportPopup() end)

    local importBtn = CreateFrame("Button", nil, qf, "BackdropTemplate")
    importBtn:SetSize(90, 28)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 8, 0)
    Backdrop(importBtn, T.panel, T.border)
    Hover(importBtn, T.panel, T.hover)
    local importText = NewFS(importBtn, "GameFontNormal")
    importText:SetPoint("CENTER")
    importText:SetText(L["DECOR_AH_IMPORT"])
    importText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    importBtn:SetScript("OnClick", function() DH:ShowImportPopup() end)

    if Auctionator and Auctionator.API and Auctionator.API.v1 then
      local sendBtn = CreateFrame("Button", nil, qf, "BackdropTemplate")
      sendBtn:SetSize(130, 28)
      sendBtn:SetPoint("BOTTOMRIGHT", -16, 12)
      Backdrop(sendBtn, T.accentDark or T.panel, T.border)
      Hover(sendBtn, T.accentDark, T.accentSoft)
      local sendText = NewFS(sendBtn, "GameFontNormal")
      sendText:SetPoint("CENTER")
      sendText:SetText("→ Auctionator")
      sendText:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
      sendBtn:SetScript("OnClick", function() DH:SendToAuctionator() end)
      sendBtn:SetScript("OnEnter", function(self)
        if GameTooltip then
          GameTooltip:SetOwner(self, "ANCHOR_TOP")
          GameTooltip:SetText(L["DECOR_AH_CREATE_AUCTIONATOR"])
          GameTooltip:AddLine(L["DECOR_AH_CREATES_SHOPPING_LIST"], 1, 1, 1, true)
          GameTooltip:Show()
        end
      end)
      sendBtn:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
      end)
    end

    DecorAH._queueFrame = qf
  end

  DH:RefreshQueueFrame()
  DecorAH._queueFrame:Show()
end

function DH:RefreshQueueFrame()
  if not DecorAH._queueFrame or not Queue then return end

  local qf = DecorAH._queueFrame
  local queue = Queue.GetQueue()
  local scrollChild = qf.scrollChild
  local scrollFrame = qf.scrollFrame

  if scrollFrame then
    local scrollWidth = scrollFrame:GetWidth() or 400
    scrollChild:SetWidth(scrollWidth - 20)
  end

  for _, row in ipairs(qf.queueRows or {}) do
    row:Hide()
  end

  if not qf.emptyMessage then
    qf.emptyMessage = CreateFrame("Frame", nil, scrollChild)
    qf.emptyMessage:SetPoint("TOPLEFT", 20, -20)
    qf.emptyMessage:SetPoint("TOPRIGHT", -20, -20)
    qf.emptyMessage:SetHeight(200)

    local icon = qf.emptyMessage:CreateTexture(nil, "ARTWORK")
    icon:SetSize(48, 48)
    icon:SetPoint("TOP", 0, -10)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    icon:SetVertexColor(0.6, 0.6, 0.6, 0.8)

    local text = NewFS(qf.emptyMessage, "GameFontNormalLarge")
    text:SetPoint("TOP", icon, "BOTTOM", 0, -10)
    text:SetText(L["DECOR_AH_QUEUE_EMPTY"])
    text:SetTextColor(0.6, 0.6, 0.6, 1)

    local hint = NewFS(qf.emptyMessage, "GameFontNormal")
    hint:SetPoint("TOP", text, "BOTTOM", 0, -8)
    hint:SetWidth(300)
    hint:SetWordWrap(true)
    hint:SetJustifyH("CENTER")
    hint:SetText(L["DECOR_AH_QUEUE_EMPTY_HINT"])
    hint:SetTextColor(0.5, 0.5, 0.5, 1)
  end

  if #queue == 0 then
    qf.emptyMessage:Show()
    scrollChild:SetHeight(400)
  else
    qf.emptyMessage:Hide()
  end

  local y = 0
  local ROW_H = 36

  for i, entry in ipairs(queue) do
    local row = qf.queueRows[i]

    if not row then
      row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
      row:SetHeight(ROW_H)
      Backdrop(row, T.row, nil)

      row.name = NewFS(row, "GameFontNormal")
      row.name:SetPoint("LEFT", 8, 0)
      row.name:SetPoint("RIGHT", -160, 0)
      row.name:SetJustifyH("LEFT")
      row.name:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))

      row.decreaseBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
      row.decreaseBtn:SetSize(24, 24)
      row.decreaseBtn:SetPoint("RIGHT", -98, 0)
      Backdrop(row.decreaseBtn, T.panel, T.border)
      Hover(row.decreaseBtn, T.panel, T.hover)
      row.decreaseBtn.text = NewFS(row.decreaseBtn, "GameFontNormal")
      row.decreaseBtn.text:SetPoint("CENTER")
      row.decreaseBtn.text:SetText("-")

      row.countText = NewFS(row, "GameFontNormal")
      row.countText:SetPoint("RIGHT", -60, 0)
      row.countText:SetWidth(28)
      row.countText:SetJustifyH("CENTER")

      row.increaseBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
      row.increaseBtn:SetSize(24, 24)
      row.increaseBtn:SetPoint("RIGHT", -32, 0)
      Backdrop(row.increaseBtn, T.panel, T.border)
      Hover(row.increaseBtn, T.panel, T.hover)
      row.increaseBtn.text = NewFS(row.increaseBtn, "GameFontNormal")
      row.increaseBtn.text:SetPoint("CENTER")
      row.increaseBtn.text:SetText("+")

      row.removeBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
      row.removeBtn:SetSize(24, 24)
      row.removeBtn:SetPoint("RIGHT", -4, 0)
      Backdrop(row.removeBtn, T.panel, T.border)
      Hover(row.removeBtn, T.panel, T.hover)
      row.removeBtn.text = NewFS(row.removeBtn, "GameFontNormal")
      row.removeBtn.text:SetPoint("CENTER")
      row.removeBtn.text:SetText("X")
      row.removeBtn.text:SetTextColor(unpack(T.danger or { 0.8, 0.28, 0.28, 1 }))

      table.insert(qf.queueRows, row)
    end

    row:SetPoint("TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", 0, y)
    row.name:SetText(entry.name or L["UNKNOWN"])
    row.countText:SetText(tostring(entry.count or 1))

    row.decreaseBtn:SetScript("OnClick", function()
      local newCount = math.max(1, (entry.count or 1) - 1)
      Queue.UpdateCount(i, newCount)
      DH:RefreshQueueFrame()
    end)

    row.increaseBtn:SetScript("OnClick", function()
      local newCount = (entry.count or 1) + 1
      Queue.UpdateCount(i, newCount)
      DH:RefreshQueueFrame()
    end)

    row.removeBtn:SetScript("OnClick", function()
      Queue.RemoveFromQueue(i)
      DH:RefreshQueueFrame()
      if DecorAH._updateQueueCount then DecorAH._updateQueueCount() end
    end)

    row:Show()
    y = y - ROW_H
  end

  scrollChild:SetHeight(math.abs(y))

  if GoblinExport and qf.matText then
    local materials = Queue.GetTotalMaterials()
    local text = GoblinExport.GenerateTextList(materials)
    if text == "" or text == "Shopping List:\n\n" then
      qf.matText:SetText("(queue is empty)")
      qf.matText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
    else
      text = text:gsub("^Shopping List:%s*\n", "")
      qf.matText:SetText(text)
      qf.matText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    end
  end
end

function DH:ShowExportPopup()
  if not Queue or not GoblinExport then return end

  local materials = Queue.GetTotalMaterials()
  local textList = GoblinExport.GenerateTextList(materials)

  if textList == "" or textList == "Shopping List:\n\n" then
    return
  end

  local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  popup:SetSize(500, 600)
  popup:SetPoint("CENTER")
  popup:SetFrameStrata("FULLSCREEN")
  Backdrop(popup, T.bg, T.border)

  local title = NewFS(popup, "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -16)
  title:SetText(L["DECOR_AH_EXPORT_SHOPPING_LIST"])
  title:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))

  local formatLabel = NewFS(popup, "GameFontNormal")
  formatLabel:SetPoint("TOP", title, "BOTTOM", 0, -12)
  formatLabel:SetText(L["DECOR_AH_EXPORT_FORMAT_COLON"])
  formatLabel:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

  local currentFormat = "Text"
  local formatButtons = {}

  local function UpdateFormatDisplay(format)
    currentFormat = format
    local exportText
    if format == "TSM" then
      exportText = GoblinExport.GenerateTSMList(materials)
    elseif format == "Auctionator" then
      exportText = GoblinExport.GenerateAuctionatorList(materials, "HomeDecor")
    else
      exportText = textList
    end
    editBox:SetText(exportText)
    editBox:HighlightText()

    for fmt, btn in pairs(formatButtons) do
      local isActive = (fmt == format)
      btn:SetBackdropColor(unpack(isActive and (T.accentDark or T.panel) or T.panel))
      btn.text:SetTextColor(unpack(isActive and (T.accent or { 0.9, 0.72, 0.18, 1 }) or T.text))
    end
  end

  local function MakeFormatButton(label, format, x)
    local btn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    btn:SetSize(90, 28)
    btn:SetPoint("TOP", formatLabel, "BOTTOM", x, -8)
    Backdrop(btn, T.panel, T.border)
    Hover(btn)
    local fs = NewFS(btn, "GameFontNormal")
    fs:SetPoint("CENTER")
    fs:SetText(label)
    fs:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
    btn.text = fs
    btn:SetScript("OnClick", function() UpdateFormatDisplay(format) end)
    formatButtons[format] = btn
    return btn
  end

  MakeFormatButton("Text", "Text", -110)
  MakeFormatButton("TSM", "TSM", 0)
  MakeFormatButton("Auctionator", "Auctionator", 110)

  local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "ScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 16, -110)
  scrollFrame:SetPoint("BOTTOMRIGHT", -32, 50)

  editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetMultiLine(true)
  editBox:SetFontObject("ChatFontNormal")
  editBox:SetWidth(scrollFrame:GetWidth() - 20)
  editBox:SetAutoFocus(true)
  editBox:SetText(textList)
  editBox:HighlightText()
  scrollFrame:SetScrollChild(editBox)

  if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end

  UpdateFormatDisplay("Text")

  local closeBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
  closeBtn:SetSize(100, 30)
  closeBtn:SetPoint("BOTTOM", 0, 12)
  Backdrop(closeBtn, T.panel, T.border)
  Hover(closeBtn, T.panel, T.hover)
  local closeText = NewFS(closeBtn, "GameFontNormal")
  closeText:SetPoint("CENTER")
  closeText:SetText(L["DECOR_AH_CLOSE"])
  closeBtn:SetScript("OnClick", function() popup:Hide() end)

  popup:Show()
end

function DH:ShowImportPopup()
  if not Queue then return end

  local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  popup:SetSize(450, 550)
  popup:SetPoint("CENTER")
  popup:SetFrameStrata("FULLSCREEN")
  Backdrop(popup, T.bg, T.border)

  local title = NewFS(popup, "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -16)
  title:SetText(L["DECOR_AH_IMPORT_TITLE"])
  title:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))

  local instructions = NewFS(popup, "GameFontNormal")
  instructions:SetPoint("TOP", title, "BOTTOM", 0, -8)
  instructions:SetText(L["DECOR_AH_PASTE_LIST"])
  instructions:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

  local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "ScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 16, -80)
  scrollFrame:SetPoint("BOTTOMRIGHT", -32, 90)

  local editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetMultiLine(true)
  editBox:SetFontObject("ChatFontNormal")
  editBox:SetWidth(scrollFrame:GetWidth() - 20)
  editBox:SetAutoFocus(true)
  scrollFrame:SetScrollChild(editBox)

  if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end

  local importBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
  importBtn:SetSize(100, 30)
  importBtn:SetPoint("BOTTOM", 0, 50)
  Backdrop(importBtn, T.accentDark or T.panel, T.border)
  Hover(importBtn, T.accentDark, T.accentSoft)
  local importText = NewFS(importBtn, "GameFontNormal")
  importText:SetPoint("CENTER")
  importText:SetText(L["DECOR_AH_IMPORT"])
  importText:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
  importBtn:SetScript("OnClick", function()
    local text = editBox:GetText()
    if not text or text == "" then
      return
    end

    local imported = 0
    local failed = 0

    for line in text:gmatch("[^\r\n]+") do
      line = line:match("^%s*(.-)%s*$")

      if line ~= "" then
        local itemID = nil

        local idMatch = line:match("i:(%d+)") or line:match("^(%d+)$")
        if idMatch then
          itemID = tonumber(idMatch)
        else
          if C_Item and C_Item.GetItemIDForItemInfo then
            itemID = C_Item.GetItemIDForItemInfo(line)
          end
        end

        if itemID then
          local name = C_Item.GetItemNameByID(itemID) or ("Item " .. itemID)
          Queue.AddToQueue(itemID, name, 1, 0, {})
          imported = imported + 1
        else
          failed = failed + 1
        end
      end
    end

    if imported > 0 then
      local msg = "|cffFFD200Imported " .. imported .. " items!|r"
      if failed > 0 then
        msg = msg .. " |cffFF8800(" .. failed .. " failed)|r"
      end
      popup:Hide()
      DH:RefreshQueueFrame()
      if DecorAH._updateQueueCount then DecorAH._updateQueueCount() end
    else
    end
  end)

  local closeBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
  closeBtn:SetSize(100, 30)
  closeBtn:SetPoint("BOTTOM", 0, 12)
  Backdrop(closeBtn, T.panel, T.border)
  Hover(closeBtn, T.panel, T.hover)
  local closeText = NewFS(closeBtn, "GameFontNormal")
  closeText:SetPoint("CENTER")
  closeText:SetText(L["DECOR_AH_CANCEL"])
  closeBtn:SetScript("OnClick", function() popup:Hide() end)

  popup:Show()
end

function DH:SendToAuctionator()
  if not Queue or not GoblinExport then
    return
  end

  if not Auctionator or not Auctionator.API or not Auctionator.API.v1 then
    return
  end

  local materials = Queue.GetTotalMaterials()
  if not materials or not next(materials) then
    return
  end

  local lumberIDs = {
    [194039] = true,
    [194040] = true,
    [194041] = true,
    [194556] = true,
    [194557] = true,
    [194558] = true,
    [199849] = true,
    [199850] = true,
    [199851] = true,
    [205367] = true,
    [205368] = true,
    [205369] = true,
    [222408] = true,
    [222412] = true,
    [222413] = true,
  }

  local tradeableMaterials = {}
  local filteredCount = 0
  for itemID, count in pairs(materials) do
    if not lumberIDs[itemID] then
      tradeableMaterials[itemID] = count
    else
      filteredCount = filteredCount + 1
    end
  end

  if not next(tradeableMaterials) then
    return
  end

  local success, msg = GoblinExport.CreateAuctionatorShoppingList(tradeableMaterials, "HomeDecor")

  if success then
    local filterMsg = filteredCount > 0 and string.format(" (%d lumber items excluded)", filteredCount) or ""
  else
  end
end

function DH:CreateEmbedded(parentFrame)
  if frame then
    frame:Hide()
    frame = nil
  end

  self:Create(parentFrame, true)
end

function DH:Show()
  if PriceSource and PriceSource.AutoDetectSource then
    PriceSource.AutoDetectSource()
  end

  if not frame and not self._embedded then
    self:Create()
  end
  if not frame then return end

  frame:Show()
  if self._updateScanTime then self._updateScanTime() end

  InvalidateDataRows()
  C_Timer.After(0, function()
    if frame and frame:IsShown() then
      RefreshTable()
    end
  end)
end

function DH:Hide()
  if frame then frame:Hide() end
end

function DH:Toggle()
  if not frame then self:Create() end
  if frame and frame:IsShown() then
    self:Hide()
  else
    self:Show()
  end
end

function DH:Refresh()
  if dataRowsDirty then
    if frame and frame:IsShown() then
      RefreshTable()
    end
  else
    if frame and frame:IsShown() then
      C_Timer.After(0, function()
        if frame and frame:IsShown() then
          RenderVisibleRows()
        end
      end)
    end
  end
end

local _dahCollectionHooked = false
local function HookDecorAHCollection()
  if _dahCollectionHooked then return end
  local Collection = NS.Systems and NS.Systems.Collection
  if not Collection or not Collection.RegisterListener then return end
  Collection:RegisterListener(function()
    local dh = NS.UI and NS.UI.DecorAH
    if dh and frame and frame:IsShown() then
      InvalidateDataRows()
      RefreshTable()
    end
  end)
  _dahCollectionHooked = true
end

C_Timer.After(0.1, function()
  Queue = NS.DecorAH.Queue
  Favorites = NS.DecorAH.Favorites
  History = NS.DecorAH.History
  Export = NS.DecorAH.Export
  Sales = NS.DecorAH.Sales
  HookDecorAHCollection()
end)

return DH