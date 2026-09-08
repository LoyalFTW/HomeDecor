local _, NS = ...

NS.UI = NS.UI or {}
local VendorAssistant = {}
NS.UI.VendorAssistant = VendorAssistant

local ROW_HEIGHT = 46
local ROW_COUNT = 6
local QUESTION_MARK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local function MerchantItemID(index)
  if type(_G.GetMerchantItemID) ~= "function" then return nil end
  local ok, itemID = pcall(_G.GetMerchantItemID, index)
  return ok and tonumber(itemID) or nil
end

local function MerchantInfo(index)
  local api = _G.C_MerchantFrame and _G.C_MerchantFrame.GetItemInfo
  if type(api) == "function" then
    local ok, info = pcall(api, index)
    if ok and type(info) == "table" then return info end
  end
  if type(_G.GetMerchantItemInfo) ~= "function" then return nil end
  local ok, name, texture, price, quantity, numAvailable, isUsable, extendedCost = pcall(_G.GetMerchantItemInfo, index)
  if not ok then return nil end
  return { name = name, texture = texture, price = price, quantity = quantity, numAvailable = numAvailable, isUsable = isUsable, hasExtendedCost = extendedCost }
end

local function FormatGold(value)
  if value <= 0 then return nil end
  if type(_G.GetCoinTextureString) == "function" then return _G.GetCoinTextureString(value) end
  return tostring(value) .. " copper"
end

local function MerchantCosts(index, info, costCount)
  local costs = {}
  local price = info and tonumber(info.price) or 0
  if price > 0 then costs[#costs + 1] = { kind = "gold", amount = price, name = "gold" } end
  if costCount > 0 and type(_G.GetMerchantItemCostItem) ~= "function" then return nil end
  for costIndex = 1, costCount do
    local ok, texture, value, link, currencyName = pcall(_G.GetMerchantItemCostItem, index, costIndex)
    value = tonumber(value)
    if not ok or not value or value <= 0 or type(link) ~= "string" then return nil end
    local currencyID
    local currencyAPI = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyIDFromLink
    if currencyName and type(currencyAPI) == "function" then
      local idOK, id = pcall(currencyAPI, link)
      if idOK then currencyID = tonumber(id) end
    end
    if currencyID then
      costs[#costs + 1] = { kind = "currency", id = currencyID, amount = value, name = currencyName, icon = texture }
    else
      local itemID = tonumber(link:match("item:(%d+)"))
      if not itemID then return nil end
      local itemName = link:match("%[([^%]]+)%]") or "item " .. tostring(itemID)
      costs[#costs + 1] = { kind = "item", id = itemID, amount = value, name = itemName, icon = texture }
    end
  end
  return #costs > 0 and costs or nil
end

local function FormatCosts(costs)
  local parts = {}
  for _, cost in ipairs(costs or {}) do
    if cost.kind == "gold" then
      local text = FormatGold(cost.amount)
      if text then parts[#parts + 1] = text end
    else
      local icon = tonumber(cost.icon) and ("|T" .. tostring(cost.icon) .. ":14:14|t ") or ""
      parts[#parts + 1] = icon .. tostring(cost.amount) .. " " .. tostring(cost.name or cost.kind)
    end
  end
  return table.concat(parts, " + ")
end

local function ProfileState()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.vendorAssistant = type(profile.vendorAssistant) == "table" and profile.vendorAssistant or {}
  if profile.vendorAssistant.open == nil then profile.vendorAssistant.open = true end
  if profile.vendorAssistant.view ~= "shopping" then profile.vendorAssistant.view = "vendor" end
  return profile.vendorAssistant
end

local function CurrentNPCID()
  if not _G.UnitGUID or not _G.strsplit then return nil end
  local ok, guid = pcall(_G.UnitGUID, "npc")
  if not ok or type(guid) ~= "string" then return nil end
  if _G.issecretvalue and _G.issecretvalue(guid) then return nil end
  if _G.canaccessvalue and not _G.canaccessvalue(guid) then return nil end
  local splitOK, unitType, _, _, _, _, npcID = pcall(_G.strsplit, "-", guid)
  if not splitOK then return nil end
  if unitType ~= "Creature" and unitType ~= "Vehicle" then return nil end
  return tonumber(npcID)
end

local function RecordsForMerchant(npcID)
  local records = npcID and NS.Systems.VendorIndex:Get(npcID)
  if records and #records > 0 then return records end
  local out, seen = {}, {}
  local count = type(_G.GetMerchantNumItems) == "function" and tonumber(_G.GetMerchantNumItems()) or 0
  for index = 1, count do
    local itemID = MerchantItemID(index)
    local candidates = itemID and NS.Systems.VendorIndex:GetByItem(itemID)
    local record = itemID and NS.Systems.Lists:GetRecordByItem(itemID, nil, npcID) or nil
    if not record and candidates then
      record = candidates[1]
      for _, candidate in ipairs(candidates) do
        if npcID and tonumber(candidate.sourceID) == npcID then record = candidate break end
      end
    end
    local key = record and record.storageKey
    if key and not seen[key] then
      seen[key] = true
      out[#out + 1] = record
    end
  end
  return #out > 0 and out or nil
end

local function Preview(record)
  local itemID = record and (record.itemID or record.id)
  if itemID and _G.DressUpItemLink and pcall(_G.DressUpItemLink, "item:" .. tostring(itemID)) then return end
  NS.UI.CatalogView:Open("tracked")
  NS.UI.Inspector:Show(record)
end

function VendorAssistant:CreateRow(parent)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  NS.UI.Controls:Backdrop(row, NS.UI.Controls.colors.row, NS.UI.Controls.colors.border)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(30, 30)
  row.icon:SetPoint("LEFT", 7, 0)
  row.check = row:CreateTexture(nil, "OVERLAY")
  row.check:SetSize(15, 15)
  row.check:SetPoint("TOP", row.icon, "TOP", 0, 2)
  row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.check:Hide()
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -5)
  row.title:SetPoint("TOPRIGHT", -60, -5)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 5)
  row.meta:SetPoint("BOTTOMRIGHT", -60, 5)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetWordWrap(false)
  row.favorite = NS.UI.FavoriteStar:Create(row, 20)
  row.favorite:SetSize(22, 22)
  row.favorite:SetPoint("RIGHT", -6, 0)
  row.shopping = NS.UI.Controls:CreateButton(row, "+", 22, 22)
  row.shopping:SetPoint("RIGHT", row.favorite, "LEFT", -3, 0)
  row.shopping:SetScript("OnClick", function(self)
    local record = self:GetParent().record
    if not record then return end
    NS.UI.ListSelector:Show(self, record, function(id, selected)
      NS.Systems.Lists:Toggle(selected, id)
      VendorAssistant:Refresh()
      if NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
    end, "Choose Shopping Lists")
  end)
  row.shopping:SetScript("OnEnter", function(self)
    local record = self:GetParent().record
    if not record or not _G.GameTooltip then return end
    local existing = NS.Systems.Lists:GetRecordByItem(record.itemID, nil, CurrentNPCID())
    _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    _G.GameTooltip:SetText("Choose Shopping Lists")
    _G.GameTooltip:AddLine(existing and "This item is on the active list." or "This item is not on the active list.", 0.8, 0.8, 0.8)
    _G.GameTooltip:Show()
  end)
  row.shopping:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  row:SetScript("OnClick", function(self, button)
    if not self.record then return end
    if NS.UI.ItemInteractions:HandleClick(self.record) then return end
    if button == "RightButton" then
      NS.Systems.Navigation:Open(self.record)
    else
      Preview(self.record)
    end
  end)
  row:SetScript("OnEnter", function(self)
    if not self.record then return end
    NS.UI.ItemTooltip:Show(self, self.record, "vendor")
  end)
  row:SetScript("OnLeave", function() NS.UI.ItemTooltip:Hide() end)
  return row
end

function VendorAssistant:GetShoppingRecords()
  local list, listID = NS.Systems.Lists:GetActive()
  if not list then return {}, 0 end
  local npcID = CurrentNPCID()
  local records, quantity, seen = {}, 0, {}
  local count = type(_G.GetMerchantNumItems) == "function" and tonumber(_G.GetMerchantNumItems()) or 0
  for index = 1, count do
    local itemID = MerchantItemID(index)
    local record, needed = NS.Systems.Lists:GetRecordByItem(itemID, listID, npcID)
    local key = record and record.storageKey
    if key and needed > 0 and not seen[key] then
      seen[key] = true
      records[#records + 1] = record
      quantity = quantity + needed
    end
  end
  return records, quantity
end

function VendorAssistant:GetShoppingPurchase()
  local list, listID = NS.Systems.Lists:GetActive()
  if not list then return {}, nil, 0, {}, 0 end
  local npcID = CurrentNPCID()
  local rows, total, totals, totalByKey, skipped, seen = {}, 0, {}, {}, 0, {}
  local count = type(_G.GetMerchantNumItems) == "function" and tonumber(_G.GetMerchantNumItems()) or 0
  for index = 1, count do
    local itemID = MerchantItemID(index)
    local record, quantity = NS.Systems.Lists:GetRecordByItem(itemID, listID, npcID)
    if record and quantity > 0 and not seen[itemID] then
      seen[itemID] = true
      local info = MerchantInfo(index)
      local costOK, costCount = pcall(_G.GetMerchantItemCostInfo or function() return 0 end, index)
      costCount = costOK and tonumber(costCount) or 0
      local costs = MerchantCosts(index, info, costCount)
      if costs then
        rows[#rows + 1] = { index = index, itemID = itemID, record = record, quantity = quantity, costs = costs }
        total = total + quantity
        for _, cost in ipairs(costs) do
          local key = tostring(cost.kind) .. ":" .. tostring(cost.id or 0)
          local aggregate = totalByKey[key]
          if not aggregate then
            aggregate = { kind = cost.kind, id = cost.id, name = cost.name, icon = cost.icon, amount = 0 }
            totalByKey[key] = aggregate
            totals[#totals + 1] = aggregate
          end
          aggregate.amount = aggregate.amount + cost.amount * quantity
        end
      else
        skipped = skipped + 1
      end
    end
  end
  return rows, listID, total, totals, skipped
end

function VendorAssistant:Create()
  if self.frame then return self.frame end
  local tab = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
  tab:SetSize(28, 142)
  tab:SetPoint("TOPLEFT", _G.MerchantFrame or UIParent, "TOPRIGHT", 0, -50)
  tab:SetFrameStrata("DIALOG")
  tab:SetFrameLevel(((_G.MerchantFrame and _G.MerchantFrame:GetFrameLevel()) or 1) + 12)
  NS.UI.Controls:Backdrop(tab, NS.UI.Controls.colors.panel, NS.UI.Controls.colors.border)
  tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  tab.label:SetPoint("CENTER", 0, 8)
  tab.label:SetText("H\nO\nM\nE\n\nD\nE\nC\nO\nR")
  NS.UI.Controls:TextColor(tab.label, "accent")
  tab.arrow = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  tab.arrow:SetPoint("BOTTOM", 0, 5)
  tab:Hide()
  local frame = CreateFrame("Frame", "HomeDecorVendorAssistant", UIParent, "BackdropTemplate")
  frame:SetSize(330, 350)
  frame:SetPoint("TOPLEFT", tab, "TOPRIGHT", 0, 0)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(110)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.background, NS.UI.Controls.colors.border)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 14, -13)
  title:SetText("Home Decor")
  frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.count:SetPoint("TOPRIGHT", -48, -18)
  local close = NS.UI.Controls:CreateButton(frame, ">", 24, 24)
  close:SetPoint("TOPRIGHT", -10, -9)
  close:SetScript("OnClick", function() VendorAssistant:SetOpen(false) end)
  local vendorView = NS.UI.Controls:CreateButton(frame, "Vendor Items", 104, 22)
  vendorView:SetPoint("TOPLEFT", 12, -41)
  local shoppingView = NS.UI.Controls:CreateButton(frame, "Shopping List", 112, 22)
  shoppingView:SetPoint("LEFT", vendorView, "RIGHT", 5, 0)
  frame.viewTabs = { vendor = vendorView, shopping = shoppingView }
  local function SetView(view)
    local state = ProfileState()
    if not state then return end
    state.view = view == "shopping" and "shopping" or "vendor"
    NS.UI.Controls:ResetScrollFrame(frame.scroll, false)
    VendorAssistant:Refresh()
  end
  vendorView:SetScript("OnClick", function() SetView("vendor") end)
  shoppingView:SetScript("OnClick", function() SetView("shopping") end)
  local scroll = NS.UI.Controls:CreateScrollFrame(frame)
  scroll:SetPoint("TOPLEFT", 12, -71)
  scroll:SetPoint("BOTTOMRIGHT", -28, 46)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(280)
  content:SetHeight(1)
  NS.UI.Controls:ConfigureScrollFrame(scroll, content, { step = ROW_HEIGHT, onScroll = function() VendorAssistant:Refresh() end })
  frame.scroll = scroll
  frame.content = content
  frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.empty:SetPoint("TOPLEFT", scroll, "TOPLEFT", 15, -42)
  frame.empty:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -15, -42)
  frame.empty:SetJustifyH("CENTER")
  frame.empty:SetText("No active Shopping List items are sold here.")
  NS.UI.Controls:TextColor(frame.empty, "muted")
  frame.empty:Hide()
  local buyAll = NS.UI.Controls:CreateButton(frame, "Buy Shopping List", 126, 24)
  buyAll:SetPoint("BOTTOMLEFT", 12, 12)
  local shoppingStatus = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  shoppingStatus:SetPoint("LEFT", buyAll, "RIGHT", 8, 0)
  shoppingStatus:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
  shoppingStatus:SetJustifyH("LEFT")
  shoppingStatus:SetWordWrap(false)
  NS.UI.Controls:TextColor(shoppingStatus, "muted")
  frame.buyAll = buyAll
  frame.shoppingStatus = shoppingStatus
  frame.rows = {}
  for index = 1, ROW_COUNT do
    local row = self:CreateRow(content)
    NS.UI.Controls:ForwardScrollWheel(row, scroll)
    NS.UI.Controls:ForwardScrollWheel(row.shopping, scroll)
    NS.UI.Controls:ForwardScrollWheel(row.favorite, scroll)
    row:Hide()
    frame.rows[index] = row
  end
  if _G.StaticPopupDialogs and not _G.StaticPopupDialogs.HOMEDECOR_BUY_SHOPPING_LIST then
    _G.StaticPopupDialogs.HOMEDECOR_BUY_SHOPPING_LIST = {
      text = "Buy %s shopping-list item(s) for %s?",
      button1 = _G.ACCEPT,
      button2 = _G.CANCEL,
      timeout = 0,
      whileDead = false,
      hideOnEscape = true,
      OnAccept = function(_, data)
        local ok, err = NS.Systems.ShoppingBuyQueue:Start(data.rows, data.listID)
        if not ok and _G.DEFAULT_CHAT_FRAME then _G.DEFAULT_CHAT_FRAME:AddMessage("|cffff6666HomeDecor:|r " .. tostring(err)) end
      end,
    }
  end
  buyAll:SetScript("OnClick", function()
    local queue = NS.Systems.ShoppingBuyQueue
    if queue:IsRunning() then queue:Cancel("cancelled by player") return end
    local rows, listID, total, costs, skipped = VendorAssistant:GetShoppingPurchase()
    if total == 0 then return end
    if skipped > 0 and _G.DEFAULT_CHAT_FRAME then _G.DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor:|r " .. tostring(skipped) .. " shopping-list item(s) use an unsupported cost and will be skipped.") end
    _G.StaticPopup_Show("HOMEDECOR_BUY_SHOPPING_LIST", tostring(total), FormatCosts(costs), { rows = rows, listID = listID })
  end)
  frame:Hide()
  tab:SetScript("OnClick", function()
    local state = ProfileState()
    if state then VendorAssistant:SetOpen(not state.open) end
  end)
  tab:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Open or close Home Decor")
    GameTooltip:Show()
  end)
  tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
  self.tab = tab
  self.frame = frame
  return frame
end

function VendorAssistant:SetOpen(open)
  local state = ProfileState()
  if not state then return end
  state.open = open == true
  if self.tab then self.tab.arrow:SetText(state.open and ">" or "<") end
  if state.open and self.records then
    self.frame:Show()
    self:Refresh()
  elseif self.frame then
    self.frame:Hide()
  end
end

function VendorAssistant:Refresh()
  local frame = self.frame
  if not frame or not frame:IsShown() or not self.records then return end
  local state = ProfileState()
  local view = state and state.view or "vendor"
  local shoppingRecords, shoppingQuantity = self:GetShoppingRecords()
  local records = view == "shopping" and shoppingRecords or self.records
  NS.UI.Controls:SetButtonSelected(frame.viewTabs.vendor, view == "vendor")
  NS.UI.Controls:SetButtonSelected(frame.viewTabs.shopping, view == "shopping")
  local total = #records
  local ownedByIndex = {}
  local collected = 0
  for index = 1, total do
    local record = records[index]
    local owned = NS.Systems.Collection:IsItemOwned(record.itemID)
    if owned == nil then
      local _, _, displayOwned = NS.Systems.Housing:GetDisplay(record)
      owned = displayOwned == true
    end
    ownedByIndex[index] = owned
    if owned then collected = collected + 1 end
  end
  if view == "shopping" then
    frame.count:SetText(tostring(total) .. " items / " .. tostring(shoppingQuantity) .. " needed")
  else
    frame.count:SetText(tostring(collected) .. " / " .. tostring(total) .. " collected")
  end
  frame.empty:SetShown(view == "shopping" and total == 0)
  local purchaseRows, _, shoppingTotal, shoppingCosts, skipped = self:GetShoppingPurchase()
  local queue = NS.Systems.ShoppingBuyQueue
  if queue:IsRunning() then
    local bought, buyingTotal = queue:GetProgress()
    frame.buyAll:SetText("Stop " .. tostring(bought) .. " / " .. tostring(buyingTotal))
    frame.buyAll:SetEnabled(true)
    frame.shoppingStatus:SetText("Purchasing one at a time")
  else
    frame.buyAll:SetText("Buy Shopping List")
    frame.buyAll:SetEnabled(#purchaseRows > 0)
    local status = shoppingTotal > 0 and (tostring(shoppingTotal) .. " here") or "No list items here"
    local costText = FormatCosts(shoppingCosts)
    if costText ~= "" then status = status .. "  -  " .. costText end
    if skipped > 0 then status = status .. "  -  " .. tostring(skipped) .. " skipped" end
    frame.shoppingStatus:SetText(status)
  end
  frame.content:SetHeight(math.max(1, total * ROW_HEIGHT))
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  local visible = math.max(0, math.min(ROW_COUNT, total - first))
  local npcID = CurrentNPCID()
  for index = 1, visible do
    local record = records[first + index]
    local row = frame.rows[index]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((first + index - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((first + index - 1) * ROW_HEIGHT))
    row.record = record
    local title, icon = NS.Systems.Housing:GetDisplay(record)
    local owned = ownedByIndex[first + index]
    local placeholder = not icon or icon == QUESTION_MARK_ICON or tonumber(icon) == 134400
    row.icon:SetTexture(placeholder and nil or icon)
    row.icon:SetAlpha(placeholder and 0 or 1)
    row.check:SetShown(owned)
    row.title:SetText(title)
    local formatter = NS.Systems.Cost
    local cost = formatter and formatter.Format and formatter:Format(record) or nil
    local dyeLabel = NS.Systems.Housing:GetDyeableLabel(record)
    local _, needed = NS.Systems.Lists:GetRecordByItem(record.itemID, nil, npcID)
    local shoppingText = needed > 0 and ("Shopping x" .. tostring(needed) .. "  -  ") or ""
    row.meta:SetText(shoppingText .. (owned and "Collected" or "Not collected") .. (dyeLabel and "  -  " .. dyeLabel or "") .. (cost and "  -  " .. cost or ""))
    row.favorite:SetRecord(record)
    NS.UI.Controls:SetButtonSelected(row.shopping, needed > 0)
    row.shopping:SetEnabled(not queue:IsRunning())
    row:Show()
  end
  for index = visible + 1, ROW_COUNT do
    frame.rows[index].record = nil
    frame.rows[index]:Hide()
  end
end

NS.OnMessage("HOMEDECOR_SHOPPING_BUY_UPDATED", function()
  if VendorAssistant.frame and VendorAssistant.frame:IsShown() then VendorAssistant:Refresh() end
  if NS.UI and NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
end)

NS.OnMessage("HOMEDECOR_LISTS_UPDATED", function()
  if VendorAssistant.frame and VendorAssistant.frame:IsShown() then VendorAssistant:Refresh() end
end)

function VendorAssistant:ShowForCurrentVendor()
  if NS.Systems.Settings and not NS.Systems.Settings:Get("vendorAssistant") then
    self:Hide()
    return
  end
  local npcID = CurrentNPCID()
  local records = RecordsForMerchant(npcID)
  if not records or #records == 0 then
    self:Hide()
    return
  end
  local frame = self:Create()
  self.records = records
  NS.UI.Controls:ResetScrollFrame(frame.scroll, false)
  self.tab:Show()
  local state = ProfileState()
  self.tab.arrow:SetText(state and state.open and ">" or "<")
  if state and state.open then frame:Show() self:Refresh() else frame:Hide() end
end

function VendorAssistant:Hide()
  self.records = nil
  if self.tab then self.tab:Hide() end
  if self.frame then
    for index = 1, #self.frame.rows do
      self.frame.rows[index].record = nil
      self.frame.rows[index]:Hide()
    end
    self.frame:Hide()
  end
end

local events = CreateFrame("Frame")
events:RegisterEvent("MERCHANT_SHOW")
events:RegisterEvent("MERCHANT_UPDATE")
events:RegisterEvent("MERCHANT_CLOSED")
local queued = false
events:SetScript("OnEvent", function(_, event)
  if event == "MERCHANT_CLOSED" then
    queued = false
    VendorAssistant:Hide()
  else
    if queued then return end
    queued = true
    local function show()
      queued = false
      VendorAssistant:ShowForCurrentVendor()
    end
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0, show)
    else
      show()
    end
  end
end)
