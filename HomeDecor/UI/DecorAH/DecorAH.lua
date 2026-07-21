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

local ROW_H = 32
local MIN_W, MIN_H = 980, 560
local MAX_W, MAX_H = 1400, 900
local DEFAULT_W, DEFAULT_H = 1180, 680

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
  { key = "star",       label = "",           w = 22, align = "CENTER" },
  { key = "icon",       label = "",           w = 28, align = "CENTER" },
  { key = "name",       label = "Name",       w = 180, align = "LEFT", flex = true },
  { key = "profession", label = "Profession", w = 92, align = "LEFT" },
  { key = "crafter",    label = "Craft",      w = 54, align = "LEFT" },
  { key = "lumberType", label = "Lumber",     w = 78, align = "LEFT" },
  { key = "cost",       label = "Cost",       w = 62, align = "RIGHT" },
  { key = "sell",       label = "Sell",       w = 62, align = "RIGHT" },
  { key = "profit",     label = "Profit",     w = 70, align = "RIGHT" },
  { key = "ppl",        label = "Per Lbr",    w = 70, align = "RIGHT" },
  { key = "margin",     label = "%",          w = 46, align = "RIGHT" },
  { key = "expansion",  label = "Exp.",       w = 58, align = "LEFT", optional = true, priority = 1 },
}

local COLS_BY_KEY = {}
for _, col in ipairs(COLS) do
  COLS_BY_KEY[col.key] = col
end

local function GetVisibleColumns(availWidth)
  local essential = { "star", "icon", "name", "profession", "crafter", "lumberType", "cost", "sell", "profit", "ppl", "margin" }
  local essentialSet = {}
  for _, k in ipairs(essential) do essentialSet[k] = true end

  for _, col in ipairs(COLS) do
    col._visible = false
    col._displayX = nil
    col.w = col._baseW or col.w
    col._baseW = col.w
  end

  for _, col in ipairs(COLS) do
    if essentialSet[col.key] then col._visible = true end
  end

  local prioritized = {}
  for _, col in ipairs(COLS) do
    if col.optional and col.priority and not essentialSet[col.key] then
      tinsert(prioritized, col)
    end
  end
  sort(prioritized, function(a, b) return (a.priority or 99) < (b.priority or 99) end)

  local usedWidth = 0
  local visibleCount = 0
  for _, col in ipairs(COLS) do
    if col._visible then
      visibleCount = visibleCount + 1
      if col.key ~= "name" then usedWidth = usedWidth + col.w end
    end
  end
  usedWidth = usedWidth + math.max(0, visibleCount - 1) * 4

  for _, col in ipairs(prioritized) do
    if availWidth >= usedWidth + col.w + 4 + 220 then
      col._visible = true
      usedWidth = usedWidth + col.w + 4
    end
  end

  local currentX = 0
  for _, col in ipairs(COLS) do
    if col._visible then
      col._displayX = currentX
      if col.flex then
        col.w = math.max(130, availWidth - usedWidth)
      end
      currentX = currentX + col.w + 4
    end
  end

  return COLS
end

local function GetColX(col)
  return col._displayX or col.x or 0
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
local selectedItemData = nil
local detailPanel
local detailWidgets = {}
local UpdateDetailPanel
local RenderVisibleRows
local selectedQueueQty = 1
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
local itemNameCache = {}
local invalidateDataRowsFn
local refreshTableFn
local itemNameRefreshPending = false

local function RequestItemName(itemID, force)
  if not itemID or (pendingItemNames[itemID] and not force) then return end
  pendingItemNames[itemID] = true
  if C_Item and C_Item.RequestLoadItemDataByID then
    pcall(C_Item.RequestLoadItemDataByID, itemID)
  end
end

local function ResolveItemNameNow(itemID)
  if not itemID then return nil end
  local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
  if (not name or name == "") and GetItemInfo then
    name = GetItemInfo(itemID)
  end
  if name and name ~= "" then
    itemNameCache[itemID] = name
    pendingItemNames[itemID] = nil
    return name
  end
end

local function ScheduleItemNameRefresh()
  if itemNameRefreshPending then return end
  itemNameRefreshPending = true
  C_Timer.After(0, function()
    itemNameRefreshPending = false
    if invalidateDataRowsFn then invalidateDataRowsFn() end
    if frame and frame:IsShown() and refreshTableFn then
      refreshTableFn()
    end
  end)
end

local function ItemName(itemID)
  if not itemID then return "?" end
  local cached = itemNameCache[itemID]
  if cached and cached ~= "" then return cached end
  local name = ResolveItemNameNow(itemID)
  if name then return name end
  RequestItemName(itemID)
  return nil
end

local function ItemIcon(itemID)
  if not itemID then return "Interface\\Icons\\INV_Misc_QuestionMark" end
  if C_Item and C_Item.GetItemIconByID then
    local ok, icon = pcall(C_Item.GetItemIconByID, itemID)
    if ok and icon then return icon end
  end
  if GetItemIcon then
    local ok, icon = pcall(GetItemIcon, itemID)
    if ok and icon then return icon end
  end
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function FormatMoney(value)
  if value == nil then return "---" end
  return PriceSource and PriceSource.FormatGold and PriceSource.FormatGold(value) or tostring(value)
end

local function ProfitColor(value)
  if value == nil then return "textMuted" end
  return value >= 0 and "success" or "danger"
end

local itemLoadFrame = CreateFrame("Frame")
itemLoadFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
itemLoadFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
itemLoadFrame:SetScript("OnEvent", function(_, event, itemID, success)
  if not itemID or not pendingItemNames[itemID] or success == false then return end
  if ResolveItemNameNow(itemID) then
    ScheduleItemNameRefresh()
    return
  end

  C_Timer.After(0, function()
    if ResolveItemNameNow(itemID) then
      ScheduleItemNameRefresh()
    elseif event == "GET_ITEM_INFO_RECEIVED" then
      RequestItemName(itemID, true)
    end
  end)
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
  if not C_TradeSkillUI or not C_TradeSkillUI.GetRecipeSchematic then
    reagentCache[skillID] = {}
    return {}
  end
  local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, skillID, false)
  if not ok or not schematic or not schematic.reagentSlotSchematics or #schematic.reagentSlotSchematics == 0 then
    reagentCache[skillID] = {}
    return {}
  end
  local reagents = {}
  for _, slot in ipairs(schematic.reagentSlotSchematics) do
    if slot.reagents and slot.reagents[1] and slot.reagents[1].itemID then
      tinsert(reagents, { itemID = slot.reagents[1].itemID, count = slot.quantityRequired or 1 })
    end
  end
  reagentCache[skillID] = reagents
  return reagents
end

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
    local title = entry.title
    if type(title) == "string" then
      title = title:gsub("^%s+", ""):gsub("%s+$", "")
      if title == "" then title = nil end
    end
    local name   = ItemName(itemID) or title or ("Item %d"):format(itemID)
    local searchName = type(name) == "string" and name:lower() or ""

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
      searchName     = searchName,
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
invalidateDataRowsFn = InvalidateDataRows

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
    elseif search ~= "" and not ((row.searchName or ""):find(search, 1, true)) then
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
    elseif key == "crafter" then
      av, bv = a.crafter or "", b.crafter or ""
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

    row.itemIconBG = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.itemIconBG:SetSize(28, 28)
    Backdrop(row.itemIconBG, T.iconBG or T.panel, T.border)

    row.itemIcon = row.itemIconBG:CreateTexture(nil, "ARTWORK")
    row.itemIcon:SetPoint("CENTER")
    row.itemIcon:SetSize(24, 24)
    row.itemIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

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

            local name = ItemName(r.itemID) or "Unknown"
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
        GameTooltip:AddLine("|cffaaaaaa[Left Click]|r  Select",        1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Shift Click]|r View Item",     1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Star]|r        Favorite",      1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa[Right Click]|r Add to Queue",  1, 1, 1)
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
        local Q = Queue or GetQueue()
        if self.itemData and Q then
          local data = self.itemData
          Q.AddToQueue(data.itemID, data.name, 1, data.profit, data.reagents)
          if DecorAH._updateQueueCount then DecorAH._updateQueueCount() end
          local QP = NS.UI and NS.UI.DecorAH_Queue
          if QP and QP.frame and QP.frame:IsShown() then QP:Refresh() end
        end
        return
      end

      if button == "LeftButton" then
        local starCol = COLS_BY_KEY["star"]
        if starCol then
          local starLeft = selfX + GetColX(starCol)
          local starRight = starLeft + starCol.w
          if mouseX >= starLeft and mouseX <= starRight then
            local F = Favorites or GetFavorites()
            if F and self.itemID then
              F.ToggleFavorite(self.itemID)
              InvalidateFilteredCache()
              if DecorAH.refreshTableFn then DecorAH.refreshTableFn() end
            end
            return
          end
        end

        UpdateDetailPanel(self.itemData)
        if C_Timer and C_Timer.After then
          C_Timer.After(0, function()
            if frame and frame:IsShown() and RenderVisibleRows then RenderVisibleRows() end
          end)
        elseif RenderVisibleRows then
          RenderVisibleRows()
        end

        local IA = NS.UI and NS.UI.ItemInteractions
        if IA and self.itemData and IsShiftKeyDown and IsShiftKeyDown() then
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
local searchRefreshTimer = nil

InvalidateFilteredCache = function()
  cachedFilteredDirty = true
end

UpdateDetailPanel = function(data)
  selectedItemData = data or selectedItemData
  if not detailPanel or not detailWidgets then return end

  local w = detailWidgets
  data = selectedItemData

  if not data then
    if w.name then w.name:SetText("Select a recipe") end
    if w.meta then w.meta:SetText("Click a pricing row to inspect materials and queue actions.") end
    if w.icon then w.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end
    if w.profit then w.profit:SetText("") end
    if w.cost then w.cost:SetText("") end
    if w.sell then w.sell:SetText("") end
    if w.materials then
      for _, row in ipairs(w.materials) do row:Hide() end
    end
    if w.materialContent then w.materialContent:SetHeight(1) end
    if w.materialScroll and w.materialScroll.SetVerticalScroll then w.materialScroll:SetVerticalScroll(0) end
    if w.starIcon then
      if w.starIcon.SetAtlas then w.starIcon:SetAtlas("auctionhouse-icon-favorite-off", false) end
      w.starIcon:SetAlpha(0.5)
    end
    return
  end

  if w.starIcon then
    local F = Favorites or GetFavorites()
    local fav = F and F.IsFavorite and F.IsFavorite(data.itemID)
    if w.starIcon.SetAtlas then
      w.starIcon:SetAtlas(fav and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off", false)
    end
    w.starIcon:SetAlpha(fav and 1 or 0.55)
  end

  if w.icon then w.icon:SetTexture(ItemIcon(data.itemID)) end
  if w.name then
    w.name:SetText(data.name or ("Item " .. tostring(data.itemID or "?")))
    C:TextColor(w.name, "accent")
  end
  if w.meta then
    local parts = {}
    if data.profession and data.profession ~= "" then parts[#parts + 1] = data.profession end
    if data.expansion and data.expansion ~= "" then parts[#parts + 1] = data.expansion end
    if data.lumberTypeName and data.lumberTypeName ~= "" then parts[#parts + 1] = "Lumber: " .. data.lumberTypeName end
    w.meta:SetText(table.concat(parts, "\n"))
  end

  local queueQty = math.max(1, tonumber(selectedQueueQty) or 1)
  local totalCost = data.cost and (data.cost * queueQty) or nil
  local totalSell = data.sell and (data.sell * queueQty) or nil
  local totalProfit = data.profit and (data.profit * queueQty) or nil

  if w.cost then w.cost:SetText(FormatMoney(totalCost)) end
  if w.sell then w.sell:SetText(FormatMoney(totalSell)) end
  if w.profit then
    local profitText = FormatMoney(totalProfit)
    if data.margin ~= nil then profitText = profitText .. " (" .. format("%.0f%%", data.margin) .. ")" end
    w.profit:SetText(profitText)
    C:TextColor(w.profit, ProfitColor(totalProfit))
  end

  if w.materials then
    local reagents = data.reagents or {}
    local function ensureMaterialRow(i)
      if w.materials[i] then return w.materials[i] end
      local parent = w.materialContent or detailPanel
      local row = CreateFrame("Frame", nil, parent)
      row:SetHeight(24)
      if i == 1 then
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
      else
        row:SetPoint("TOPLEFT", w.materials[i - 1], "BOTTOMLEFT", 0, -2)
      end
      row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)

      row.icon = row:CreateTexture(nil, "ARTWORK")
      row.icon:SetSize(20, 20)
      row.icon:SetPoint("LEFT", 0, 0)
      row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

      row.name = NewFS(row, "GameFontNormalSmall")
      row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
      row.name:SetPoint("RIGHT", -78, 0)
      row.name:SetJustifyH("LEFT")
      C:TextColor(row.name, "text")

      row.cost = NewFS(row, "GameFontNormalSmall")
      row.cost:SetPoint("RIGHT", 0, 0)
      row.cost:SetWidth(74)
      row.cost:SetJustifyH("RIGHT")
      C:TextColor(row.cost, "textMuted")

      w.materials[i] = row
      return row
    end

    for i = 1, #reagents do
      ensureMaterialRow(i)
    end

    for i, row in ipairs(w.materials) do
      local reagent = reagents[i]
      if reagent then
        local price = PriceSource and PriceSource.GetItemPrice and PriceSource.GetItemPrice(reagent.itemID)
        local qty = (reagent.count or reagent.qty or reagent.amount or 1) * queueQty
        if row.icon then row.icon:SetTexture(ItemIcon(reagent.itemID)) end
        if row.name then row.name:SetText((ItemName(reagent.itemID) or ("Item " .. tostring(reagent.itemID))) .. "  x" .. tostring(qty)) end
        if row.cost then row.cost:SetText(price and FormatMoney(price * qty) or "---") end
        row:Show()
      else
        row:Hide()
      end
    end
    if w.materialContent then
      local sw = w.materialScroll and w.materialScroll.GetWidth and w.materialScroll:GetWidth()
      if sw and sw > 20 then w.materialContent:SetWidth(sw - 4) end
      w.materialContent:SetHeight(math.max(1, (#reagents * 26) - 2))
    end
    if w.materialScroll and w.materialScroll.SetVerticalScroll then
      w.materialScroll:SetVerticalScroll(0)
    end
  end
end

RenderVisibleRows = function()
  if not frame or not scrollChild then return end
  if not cachedFiltered then return end

  local filtered = cachedFiltered
  local scrollOffset = scrollFrame and scrollFrame.GetVerticalScroll and scrollFrame:GetVerticalScroll() or 0
  local viewH        = (scrollFrame and scrollFrame.GetHeight and scrollFrame:GetHeight()) or 400
  local OVERSCAN     = ROW_H * 4

  local firstIdx = math.max(1,         math.floor((scrollOffset - OVERSCAN) / ROW_H) + 1)
  local lastIdx  = math.min(#filtered, math.ceil ((scrollOffset + viewH + OVERSCAN) / ROW_H))

  ReleaseAllRows()

  for i = firstIdx, lastIdx do
    local rowData = filtered[i]
    local row = AcquireRow()
    local y = -(i - 1) * ROW_H
    row:SetPoint("TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", 0, y)
    row.itemID   = rowData.itemID
    row.itemData = rowData
    if row.SetBackdropColor then
      if selectedItemData and selectedItemData.itemID == rowData.itemID then
        row:SetBackdropColor(unpack(T.accentDark or { 0.28, 0.24, 0.10, 1 }))
      elseif (i % 2) == 0 then
        row:SetBackdropColor(unpack(T.rowBG or { 0.05, 0.07, 0.09, 0.55 }))
      else
        row:SetBackdropColor(0, 0, 0, 0.18)
      end
    end

    local c = row.cells
    if row.itemIconBG then
      local iconCol = COLS_BY_KEY.icon or COLS_BY_KEY.name
      row.itemIconBG:ClearAllPoints()
      row.itemIconBG:SetPoint("LEFT", GetColX(iconCol) + 2, 0)
      row.itemIconBG:Show()
      if row.itemIcon then row.itemIcon:SetTexture(ItemIcon(rowData.itemID)) end
    end
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
            cell:SetWidth(math.max(10, col.w - 4))
          end
        else
          cell:Hide()
        end
      end
    end

    if c.star and c.star:IsShown() then
      local F = Favorites or GetFavorites()
      local isFav = F and F.IsFavorite and F.IsFavorite(rowData.itemID)
      if c.star._isTexture then
        if c.star.SetAtlas then
          c.star:SetAtlas(isFav and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off", false)
            c.star:SetSize(14, 14)
        end
        c.star:SetAlpha(isFav and 1 or 0.5)
      else
        c.star:SetText(isFav and "+" or "-")
        C:TextColor(c.star, isFav and "accent" or "textMuted")
      end
    end
    if c.name and c.name:IsShown() then
      c.name:SetText(rowData.name or "?")
      C:TextColor(c.name, "accent")
      c.name:ClearAllPoints()
      c.name:SetPoint("LEFT", GetColX(COLS_BY_KEY.name) + 2, 0)
      c.name:SetWidth(math.max(80, (COLS_BY_KEY.name.w or 180) - 4))
    end
    if c.icon then
      c.icon:Hide()
    end
    if c.profession and c.profession:IsShown() then
      c.profession:SetText(rowData.profession or "")
      C:TextColor(c.profession, "textMuted")
    end
    if c.expansion and c.expansion:IsShown() then
      c.expansion:SetText(rowData.expansion or "")
      C:TextColor(c.expansion, "textMuted")
    end
    if c.lumberType and c.lumberType:IsShown() then
      c.lumberType:SetText(rowData.lumberTypeName or "-")
      C:TextColor(c.lumberType, "textMuted")
    end
    if c.cost and c.cost:IsShown() then
      c.cost:SetText(PriceSource and PriceSource.FormatGold(rowData.cost) or "?")
      C:TextColor(c.cost, "textMuted")
    end
    if c.sell and c.sell:IsShown() then
      c.sell:SetText(PriceSource and PriceSource.FormatGold(rowData.sell) or "?")
      C:TextColor(c.sell, "accent")
    end
    if c.profit and c.profit:IsShown() then
      if rowData.profit ~= nil then
        local role = (rowData.profit >= 0) and "success" or "danger"
        C:TextColor(c.profit, role)
        c.profit:SetText(PriceSource and PriceSource.FormatGold(rowData.profit) or "?")
      else
        C:TextColor(c.profit, "textMuted")
        c.profit:SetText("?")
      end
    end
    if c.ppl and c.ppl:IsShown() then
      if rowData.ppl ~= nil then
        local role = (rowData.ppl >= 0) and "success" or "danger"
        C:TextColor(c.ppl, role)
        c.ppl:SetText(PriceSource and PriceSource.FormatGold(rowData.ppl) or "?")
      else
        C:TextColor(c.ppl, "textMuted")
        c.ppl:SetText("-")
      end
    end
    if c.crafter and c.crafter:IsShown() then
      if rowData.crafter then
        local role = rowData.known and "text" or "textMuted"
        C:TextColor(c.crafter, role)
        c.crafter:SetText(rowData.crafter)
      else
        C:TextColor(c.crafter, "textMuted")
        c.crafter:SetText("-")
      end
    end
    if c.margin and c.margin:IsShown() then
      if rowData.margin ~= nil then
        local role = (rowData.margin >= 0) and "success" or "danger"
        C:TextColor(c.margin, role)
        c.margin:SetText(format("%.0f%%", rowData.margin))
      else
        C:TextColor(c.margin, "textMuted")
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
        btn:SetSize(col.w, ROW_H)
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
    local didRebuildData = dataRowsDirty

    BuildDataRows()

    if didRebuildData and History then
      if not DecorAH._lastHistoryRecord then DecorAH._lastHistoryRecord = 0 end
      if time() - DecorAH._lastHistoryRecord > 3600 then
        History.RecordBulkSnapshot(dataRows)
        DecorAH._lastHistoryRecord = time()
      end
    end

    if didRebuildData and Favorites then
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
      C:TextColor(recipeCountLabel, "accent")
    else
      recipeCountLabel:SetText(format("%d recipes", #dataRows))
      C:TextColor(recipeCountLabel, "textMuted")
    end
  end

  scrollChild:SetHeight(math.max(#filtered * ROW_H, 1))
  if selectedItemData then UpdateDetailPanel(selectedItemData) end

  if #filtered == 0 then
    if not DecorAH._emptyLabel then
      DecorAH._emptyLabel = NewFS(scrollChild, "GameFontNormalLarge")
      DecorAH._emptyLabel:SetPoint("CENTER", scrollChild, "TOP", 0, -100)
      C:TextColor(DecorAH._emptyLabel, "textMuted")
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

DecorAH.refreshTableFn  = RefreshTable
DecorAH._invalidate    = InvalidateDataRows
DecorAH._invalidFilter = InvalidateFilteredCache
refreshTableFn = RefreshTable

local function QueueSearchRefresh()
  InvalidateFilteredCache()

  if searchRefreshTimer and searchRefreshTimer.Cancel then
    searchRefreshTimer:Cancel()
  end

  if C_Timer and C_Timer.NewTimer then
    searchRefreshTimer = C_Timer.NewTimer(0.12, function()
      searchRefreshTimer = nil
      RefreshTable()
    end)
  else
    RefreshTable()
  end
end

local function RefreshSourceHighlights()
  for src, btn in pairs(sourceButtons) do
    if btn and btn.UpdateHighlight then btn:UpdateHighlight() end
  end
end

local function CreateHeaderRow(parent, y)
  local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 0, y)
  if detailPanel then
    header:SetPoint("TOPRIGHT", detailPanel, "TOPLEFT", -4, 0)
  else
    header:SetPoint("TOPRIGHT", 0, y)
  end
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
        sortRev = (self.colKey == "name" or self.colKey == "profession" or self.colKey == "expansion" or self.colKey == "lumberType" or self.colKey == "crafter") and false or true
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
        C:TextColor(fs, "textMuted")
        return
      end
      fs:SetText(sortRev and " ^" or " v")
      C:TextColor(fs, "accent")
    end
    local label = NewFS(btn, "GameFontNormal")
    label:SetJustifyH(col.align or "LEFT")
    C:TextColor(label, "accent")
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

  sourceButtons = {}
  headerButtons = {}
  rowPool = {}
  activeRows = {}
  selectedItemData = nil
  selectedQueueQty = 1
  detailPanel = nil
  detailWidgets = {}

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

    Backdrop(frame, T.bg, T.border)

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
      local sw = scrollFrame and scrollFrame.GetWidth and scrollFrame:GetWidth()
      contentWidth = math.max(100, (sw and sw > 0 and (sw - 4)) or (bw - 340))
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
    C:TextColor(title, "accent")

    local closeBtn = CreateFrame("Button", nil, canvas, "BackdropTemplate")
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", -10, -10)
    Backdrop(closeBtn, T.panel, T.border)
    Hover(closeBtn)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetSize(14, 14)
    closeIcon:SetPoint("CENTER")
    closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
    if C and C.TextureColor then C:TextureColor(closeIcon, "accent") end
    closeBtn:SetScript("OnClick", function() DH:Hide() end)
  end

  local topBar = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  if embedded then
    topBar:SetPoint("TOPLEFT", canvas, "TOPLEFT", 8, -16)
    topBar:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -8, -16)
  else
    topBar:SetPoint("TOPLEFT", 0, -44)
    topBar:SetPoint("TOPRIGHT", 0, -44)
  end
  topBar:SetHeight(34)
  topBar:SetFrameLevel(canvas:GetFrameLevel() + 5)
  Backdrop(topBar, T.header, T.border)

  local sourceLabel = NewFS(topBar, "GameFontNormal")
  sourceLabel:SetPoint("LEFT", 14, 0)
  sourceLabel:SetText("Prices:")
  C:TextColor(sourceLabel, "textMuted")

  local sources = PriceSource and PriceSource.GetAvailableSources and PriceSource.GetAvailableSources() or { "Scan" }
  preferredSource = PriceSource and PriceSource.GetPreferredSource()
  if not preferredSource or preferredSource == "" then
    preferredSource = sources[1]
    if PriceSource then PriceSource.SetPreferredSource(preferredSource) end
  end

  local function MakeSourceButton(parent, label, srcKey, tooltip)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(86, 24)
    btn:SetFrameLevel(parent:GetFrameLevel() + 1)
    Backdrop(btn, T.panel, T.border)
    Hover(btn)
    btn._label = label
    btn._srcKey = srcKey
    btn._tooltip = tooltip
    local fs = NewFS(btn, "GameFontNormal")
    fs:SetPoint("CENTER")
    fs:SetText(label)
    C:TextColor(fs, "text")
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
      C:TextColor(fs, active and "accent" or "text")
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

  local srcX = 62
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
  C:TextColor(scanTimeText, "textMuted")

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
    C:TextColor(scanTimeText, "accent")
  end)
  scanTimeButton:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
    local lastScan = PriceSource and PriceSource.GetLastAuctionatorScanTime and PriceSource.GetLastAuctionatorScanTime()
    if lastScan and (time() - lastScan) < 60 then
      C:TextColor(scanTimeText, "success")
    else
      C:TextColor(scanTimeText, "textMuted")
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
      C:TextColor(scanTimeText, "textMuted")
      return
    end

    local lastScan = PriceSource and PriceSource.GetLastAuctionatorScanTime and PriceSource.GetLastAuctionatorScanTime()
    if lastScan then
      local ago = time() - lastScan
      local timeStr
      if ago < 60 then
        timeStr = L["DECOR_AH_JUST_SCANNED"]
        C:TextColor(scanTimeText, "success")
      elseif ago < 3600 then
        timeStr = format(L["DECOR_AH_SCANNED_MIN_AGO"], floor(ago / 60))
        C:TextColor(scanTimeText, "textMuted")
      else
        timeStr = format(L["DECOR_AH_SCANNED_HOURS_AGO"], floor(ago / 3600))
        C:TextColor(scanTimeText, "textMuted")
      end
      scanTimeText:SetText(timeStr)
    else
      scanTimeText:SetText(L["DECOR_AH_RUN_FULL_SCAN"])
      C:TextColor(scanTimeText, "textMuted")
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
  queueBtn:SetSize(94, 24)
  queueBtn:SetPoint("RIGHT", -12, 0)
  queueBtn:SetFrameLevel(topBar:GetFrameLevel() + 1)
  Backdrop(queueBtn, T.panel, T.border)
  Hover(queueBtn, T.panel, T.hover)
  local queueBtnText = NewFS(queueBtn, "GameFontNormal")
  queueBtnText:SetPoint("CENTER")
  queueBtnText:SetText(L["DECOR_AH_QUEUE_ZERO"])
  C:TextColor(queueBtnText, "text")
  queueBtn:SetScript("OnClick", function()
    DH:ShowQueueFrame()
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
  salesBtn:SetSize(76, 24)
  salesBtn:SetPoint("RIGHT", queueBtn, "LEFT", -5, 0)
  salesBtn:SetFrameLevel(topBar:GetFrameLevel() + 1)
  Backdrop(salesBtn, T.panel, T.border)
  Hover(salesBtn, T.panel, T.hover)
  local salesBtnText = NewFS(salesBtn, "GameFontNormal")
  salesBtnText:SetPoint("CENTER")
  salesBtnText:SetText(L["DECOR_AH_SALES"])
  C:TextColor(salesBtnText, "text")
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
    filterRow:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -56)
    filterRow:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -14, -56)
  else
    filterRow:SetPoint("TOPLEFT", 14, -82)
    filterRow:SetPoint("TOPRIGHT", -14, -82)
  end
  filterRow:SetHeight(28)
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
    dd:SetSize(width or 100, 24)
    Backdrop(dd, T.row or T.panel, T.border)
    Hover(dd)
    dd._value = default or options[1]
    dd._options = options
    dd.text = NewFS(dd, "GameFontNormal")
    dd.text:SetPoint("LEFT", 8, 0)
    dd.text:SetPoint("RIGHT", -24, 0)
    dd.text:SetJustifyH("LEFT")
    dd.text:SetText(dd._value)
    C:TextColor(dd.text, "text")
    local arrow = dd:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetText("v")
    C:TextColor(arrow, "textMuted")
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
        NS.UI.Util.BindBackgroundHover(btn, T.hover or { 0.17, 0.17, 0.2, 1 }, { 0, 0, 0, 0 })
        local fs = NewFS(btn, "GameFontNormal")
        fs:SetPoint("LEFT", 6, 0)
        fs:SetText(opt)
        C:TextColor(fs, "text")
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
  C:TextColor(profLabel, "textMuted")
  professionDropdown = MakeDropdown(filterRow, profs, L["FILTER_ALL"], 126, nil)
  professionDropdown:SetPoint("LEFT", profLabel, "RIGHT", 6, 0)

  local expLabel = NewFS(filterRow, "GameFontNormal")
  expLabel:SetPoint("LEFT", professionDropdown, "RIGHT", 14, 0)
  expLabel:SetText(L["DECOR_AH_EXPANSION_COLON"])
  C:TextColor(expLabel, "textMuted")
  expansionDropdown = MakeDropdown(filterRow, expansions, L["FILTER_ALL"], 126, nil)
  expansionDropdown:SetPoint("LEFT", expLabel, "RIGHT", 6, 0)

  local lumberLabel = NewFS(filterRow, "GameFontNormal")
  lumberLabel:SetPoint("LEFT", expansionDropdown, "RIGHT", 14, 0)
  lumberLabel:SetText(L["DECOR_AH_LUMBER_COLON"])
  C:TextColor(lumberLabel, "textMuted")
  lumberTypeDropdown = MakeDropdown(filterRow, lumberTypes, L["FILTER_ALL"], 108, nil)
  lumberTypeDropdown:SetPoint("LEFT", lumberLabel, "RIGHT", 6, 0)

  local filterRow2 = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  if embedded then
    filterRow2:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -86)
    filterRow2:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -14, -86)
  else
    filterRow2:SetPoint("TOPLEFT", 14, -112)
    filterRow2:SetPoint("TOPRIGHT", -14, -112)
  end
  filterRow2:SetHeight(24)
  Backdrop(filterRow2, T.panel, nil)

  local function MakeCheck(parent, label, xAnchor, xOff)
    local chk = CreateFrame("Button", nil, parent)
    chk:SetSize(20, 20)
    if xAnchor then
      chk:SetPoint("LEFT", xAnchor, "RIGHT", xOff, 0)
    else
      chk:SetPoint("LEFT", xOff or 8, 0)
    end
    chk.checked = false
    local tex = chk:CreateTexture(nil, "ARTWORK")
    tex:SetSize(14, 14)
    tex:SetPoint("LEFT", 0, 0)
    tex:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    local fs = NewFS(chk, "GameFontNormal")
    fs:SetPoint("LEFT", 22, 0)
    fs:SetText(label)
    C:TextColor(fs, "text")
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
  C:TextColor(searchLabel, "textMuted")
  searchBox = CreateFrame("EditBox", nil, filterRow2, "BackdropTemplate")
  searchBox:SetSize(178, 20)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 6, 0)
  Backdrop(searchBox, T.row or T.panel, T.border)
  searchBox:SetAutoFocus(false)
  searchBox:SetFontObject("GameFontNormal")
  searchBox:SetTextInsets(6, 6, 0, 0)
  searchBox:SetScript("OnTextChanged", QueueSearchRefresh)
  searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

  knownOnlyCheck = MakeCheck(filterRow2, "Known", searchBox, 14)
  altProfessionsCheck = MakeCheck(filterRow2, "Alts", knownOnlyCheck, 74)

  recipeCountLabel = NewFS(filterRow2, "GameFontNormal")
  recipeCountLabel:SetPoint("RIGHT", -8, 0)
  recipeCountLabel:SetJustifyH("RIGHT")
  recipeCountLabel:SetText("0 / 0 recipes")
  C:TextColor(recipeCountLabel, "textMuted")

  local inspectorW = 260
  local headerY = embedded and -116 or -144

  detailPanel = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  detailPanel:SetWidth(inspectorW)
  detailPanel:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -8, headerY)
  detailPanel:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -8, 14)
  detailPanel:SetFrameLevel(canvas:GetFrameLevel() + 4)
  Backdrop(detailPanel, T.panel, T.border)

  local detailTitle = NewFS(detailPanel, "GameFontNormal")
  detailTitle:SetPoint("TOPLEFT", 12, -10)
  detailTitle:SetText("Selected Item")
  C:TextColor(detailTitle, "accent")

  local detailStar = CreateFrame("Button", nil, detailPanel)
  detailStar:SetSize(24, 24)
  detailStar:SetPoint("TOPRIGHT", -8, -6)
  detailStar.icon = detailStar:CreateTexture(nil, "ARTWORK")
  detailStar.icon:SetSize(16, 16)
  detailStar.icon:SetPoint("CENTER")
  if detailStar.icon.SetAtlas then
    detailStar.icon:SetAtlas("auctionhouse-icon-favorite-off", false)
  else
    detailStar.icon:SetTexture("Interface\\Common\\ReputationStar")
  end
  if C and C.TextureColor then C:TextureColor(detailStar.icon, "accent") end
  detailWidgets.starIcon = detailStar.icon
  detailStar:SetScript("OnClick", function()
    local F = Favorites or GetFavorites()
    if F and selectedItemData and selectedItemData.itemID then
      F.ToggleFavorite(selectedItemData.itemID)
      InvalidateFilteredCache()
      UpdateDetailPanel(selectedItemData)
      RefreshTable()
    end
  end)
  detailStar:SetScript("OnEnter", function(self)
    if GameTooltip then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["DECOR_AH_CLICK_STAR"] or "Click star to favorite")
      GameTooltip:Show()
    end
  end)
  detailStar:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)

  local iconBox = CreateFrame("Frame", nil, detailPanel, "BackdropTemplate")
  iconBox:SetSize(50, 50)
  iconBox:SetPoint("TOPLEFT", 12, -34)
  Backdrop(iconBox, T.iconBG or T.row, T.border)

  detailWidgets.icon = iconBox:CreateTexture(nil, "ARTWORK")
  detailWidgets.icon:SetPoint("CENTER")
  detailWidgets.icon:SetSize(42, 42)
  detailWidgets.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  detailWidgets.name = NewFS(detailPanel, "GameFontNormal")
  detailWidgets.name:SetPoint("TOPLEFT", iconBox, "TOPRIGHT", 10, -2)
  detailWidgets.name:SetPoint("RIGHT", -12, 0)
  detailWidgets.name:SetJustifyH("LEFT")

  detailWidgets.meta = NewFS(detailPanel, "GameFontNormalSmall")
  detailWidgets.meta:SetPoint("TOPLEFT", detailWidgets.name, "BOTTOMLEFT", 0, -6)
  detailWidgets.meta:SetPoint("RIGHT", -12, 0)
  detailWidgets.meta:SetJustifyH("LEFT")
  C:TextColor(detailWidgets.meta, "textMuted")

  local div1 = detailPanel:CreateTexture(nil, "ARTWORK")
  div1:SetHeight(1)
  div1:SetPoint("TOPLEFT", 12, -96)
  div1:SetPoint("TOPRIGHT", -12, -96)
  div1:SetColorTexture(unpack(T.border or { 0.24, 0.24, 0.28, 1 }))

  local matsTitle = NewFS(detailPanel, "GameFontNormal")
  matsTitle:SetPoint("TOPLEFT", 12, -112)
  matsTitle:SetText(L["DECOR_AH_MATERIALS_COLON"] or "Materials:")
  C:TextColor(matsTitle, "accent")

  detailWidgets.materials = {}
  detailWidgets.materialScroll = CreateFrame("ScrollFrame", nil, detailPanel, "ScrollFrameTemplate")
  detailWidgets.materialScroll:SetPoint("TOPLEFT", 12, -134)
  detailWidgets.materialScroll:SetPoint("TOPRIGHT", -28, -134)
  detailWidgets.materialScroll:SetHeight(132)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(detailWidgets.materialScroll) end

  detailWidgets.materialContent = CreateFrame("Frame", nil, detailWidgets.materialScroll)
  detailWidgets.materialContent:SetSize(inspectorW - 50, 1)
  detailWidgets.materialScroll:SetScrollChild(detailWidgets.materialContent)
  detailWidgets.materialScroll:SetScript("OnMouseWheel", function(self, delta)
    local cur = self:GetVerticalScroll() or 0
    local maxScroll = self.GetVerticalScrollRange and self:GetVerticalScrollRange() or 0
    local nextScroll = cur - (delta * 26)
    if nextScroll < 0 then nextScroll = 0 end
    if nextScroll > maxScroll then nextScroll = maxScroll end
    self:SetVerticalScroll(nextScroll)
  end)

  local div2 = detailPanel:CreateTexture(nil, "ARTWORK")
  div2:SetHeight(1)
  div2:SetPoint("TOPLEFT", 12, -278)
  div2:SetPoint("TOPRIGHT", -12, -278)
  div2:SetColorTexture(unpack(T.border or { 0.24, 0.24, 0.28, 1 }))

  local estTitle = NewFS(detailPanel, "GameFontNormal")
  estTitle:SetPoint("TOPLEFT", 12, -292)
  estTitle:SetText("Estimated Profit")
  C:TextColor(estTitle, "accent")

  local costLabel = NewFS(detailPanel, "GameFontNormalSmall")
  costLabel:SetPoint("TOPLEFT", 12, -316)
  costLabel:SetText(L["DECOR_AH_COST_COLON"] or "Cost:")
  C:TextColor(costLabel, "textMuted")
  detailWidgets.cost = NewFS(detailPanel, "GameFontNormalSmall")
  detailWidgets.cost:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", -12, -316)
  detailWidgets.cost:SetJustifyH("RIGHT")

  local sellLabel = NewFS(detailPanel, "GameFontNormalSmall")
  sellLabel:SetPoint("TOPLEFT", 12, -336)
  sellLabel:SetText("Sell:")
  C:TextColor(sellLabel, "textMuted")
  detailWidgets.sell = NewFS(detailPanel, "GameFontNormalSmall")
  detailWidgets.sell:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", -12, -336)
  detailWidgets.sell:SetJustifyH("RIGHT")

  local profitLabel = NewFS(detailPanel, "GameFontNormal")
  profitLabel:SetPoint("TOPLEFT", 12, -362)
  profitLabel:SetText(L["DECOR_AH_PROFIT_COLON"] or "Profit:")
  C:TextColor(profitLabel, "success")
  detailWidgets.profit = NewFS(detailPanel, "GameFontNormal")
  detailWidgets.profit:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", -12, -362)
  detailWidgets.profit:SetJustifyH("RIGHT")

  local function DetailButton(label, y, role, onClick)
    local btn = CreateFrame("Button", nil, detailPanel, "BackdropTemplate")
    btn:SetPoint("BOTTOMLEFT", 12, y)
    btn:SetPoint("BOTTOMRIGHT", -12, y)
    btn:SetHeight(28)
    Backdrop(btn, role == "primary" and (T.accentDark or T.row) or T.row, T.border)
    Hover(btn, role == "primary" and (T.accentDark or T.row) or T.row, T.hover)
    local fs = NewFS(btn, "GameFontNormal")
    fs:SetPoint("CENTER")
    fs:SetText(label)
    C:TextColor(fs, role == "primary" and "accentBright" or "text")
    btn:SetScript("OnClick", onClick)
    return btn
  end

  local qtyBox = CreateFrame("Frame", nil, detailPanel, "BackdropTemplate")
  qtyBox:SetPoint("BOTTOMLEFT", 12, 74)
  qtyBox:SetPoint("BOTTOMRIGHT", -12, 74)
  qtyBox:SetHeight(24)
  Backdrop(qtyBox, T.row or T.panel, T.border)

  local qtyLabel = NewFS(qtyBox, "GameFontNormalSmall")
  qtyLabel:SetPoint("LEFT", 8, 0)
  qtyLabel:SetText("Queue Qty")
  C:TextColor(qtyLabel, "textMuted")

  local qtyMinus = CreateFrame("Button", nil, qtyBox, "BackdropTemplate")
  qtyMinus:SetSize(22, 18)
  qtyMinus:SetPoint("RIGHT", -72, 0)
  Backdrop(qtyMinus, T.panel, T.border)
  Hover(qtyMinus, T.panel, T.hover)
  qtyMinus.text = NewFS(qtyMinus, "GameFontNormal")
  qtyMinus.text:SetPoint("CENTER")
  qtyMinus.text:SetText("-")

  local qtyText = NewFS(qtyBox, "GameFontNormal")
  qtyText:SetPoint("RIGHT", -38, 0)
  qtyText:SetWidth(26)
  qtyText:SetJustifyH("CENTER")
  qtyText:SetText(tostring(selectedQueueQty))
  detailWidgets.qtyText = qtyText

  local qtyPlus = CreateFrame("Button", nil, qtyBox, "BackdropTemplate")
  qtyPlus:SetSize(22, 18)
  qtyPlus:SetPoint("RIGHT", -8, 0)
  Backdrop(qtyPlus, T.panel, T.border)
  Hover(qtyPlus, T.panel, T.hover)
  qtyPlus.text = NewFS(qtyPlus, "GameFontNormal")
  qtyPlus.text:SetPoint("CENTER")
  qtyPlus.text:SetText("+")

  local function SetQueueQty(v)
    selectedQueueQty = math.max(1, math.min(99, tonumber(v) or 1))
    if detailWidgets.qtyText then detailWidgets.qtyText:SetText(tostring(selectedQueueQty)) end
    if selectedItemData then UpdateDetailPanel(selectedItemData) end
  end
  qtyMinus:SetScript("OnClick", function() SetQueueQty(selectedQueueQty - 1) end)
  qtyPlus:SetScript("OnClick", function() SetQueueQty(selectedQueueQty + 1) end)

  DetailButton("Add to Queue", 42, "primary", function()
    local Q = Queue or GetQueue()
    if selectedItemData and Q then
      Q.AddToQueue(selectedItemData.itemID, selectedItemData.name, selectedQueueQty, selectedItemData.profit, selectedItemData.reagents)
      if DecorAH._updateQueueCount then DecorAH._updateQueueCount() end
      local QP = NS.UI and NS.UI.DecorAH_Queue
      if QP and QP.frame and QP.frame:IsShown() then QP:Refresh() end
    end
  end)

  DetailButton(L["DECOR_AH_EXPORT"] or "Export", 8, nil, function()
    local ExportMod = GetExport()
    if selectedItemData and ExportMod and ExportMod.ExportSingleItem then
      local txt = ExportMod.ExportSingleItem(selectedItemData.itemID, selectedItemData.reagents, 1)
      if DEFAULT_CHAT_FRAME and txt and txt ~= "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor export:|r " .. txt:gsub("\n", "  "))
      end
    end
  end)

  UpdateDetailPanel(nil)

  CreateHeaderRow(canvas, headerY)
  for _, b in ipairs(headerButtons) do
    if b.UpdateSortIndicator then b:UpdateSortIndicator() end
  end

  local scrollBottom, scrollRight = 14, 4
  scrollFrame = CreateFrame("ScrollFrame", nil, canvas, "ScrollFrameTemplate")
  if embedded then
    scrollFrame:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, headerY - ROW_H)
    scrollFrame:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMLEFT", -scrollRight - 18, 0)
  else
    scrollFrame:SetPoint("TOPLEFT", 14, headerY - ROW_H)
    scrollFrame:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMLEFT", -scrollRight - 18, 0)
  end
  scrollChild = CreateFrame("Frame", nil, scrollFrame)
  contentWidth = (scrollFrame:GetWidth() or 400) - 4
  scrollChild:SetSize(contentWidth + 20, 1)
  scrollFrame:SetScrollChild(scrollChild)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end

  local scrollDebounce = nil
  scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    self:SetVerticalScroll(offset)
    if scrollDebounce then scrollDebounce:Cancel() end
    scrollDebounce = C_Timer.NewTimer(0.04, function()
      scrollDebounce = nil
      RenderVisibleRows()
    end)
  end)

  if embedded then
    frame:SetScript("OnShow", function(self)
      InvalidateDataRows()
      C_Timer.After(0, function()
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
    C:TextColor(scaleLabel, "textMuted")
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
  if C and C.SolidColor then
    C:SolidColor(fill, "accent")
  else
    fill:SetColorTexture(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
  end
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

local dahCollectionHooked = false
local function HookDecorAHCollection()
  if dahCollectionHooked then return end
  local Collection = NS.Systems and NS.Systems.Collection
  if not Collection or not Collection.RegisterListener then return end
  Collection:RegisterListener(function()
    local dh = NS.UI and NS.UI.DecorAH
    if dh and frame and frame:IsShown() then
      InvalidateDataRows()
      RefreshTable()
    end
  end)
  dahCollectionHooked = true
end

C_Timer.After(0.1, function()
  Queue = NS.DecorAH.Queue
  Favorites = NS.DecorAH.Favorites
  History = NS.DecorAH.History
  Export = NS.DecorAH.Export
  Sales = NS.DecorAH.Sales
  HookDecorAHCollection()
  if Sales and Sales.Initialize then
    Sales.Initialize()
  end
end)

return DH
