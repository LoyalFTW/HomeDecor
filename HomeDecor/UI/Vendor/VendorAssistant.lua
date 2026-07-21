local ADDON, NS = ...

NS.UI = NS.UI or {}
local Assistant = NS.UI.VendorAssistant or {}
NS.UI.VendorAssistant = Assistant

local L = NS.L
local CreateFrame = _G.CreateFrame
local MerchantFrame = _G.MerchantFrame
local UIParent = _G.UIParent
local GetItemInfo = _G.GetItemInfo
local GetMerchantNumItems = _G.GetMerchantNumItems
local GetMerchantItemInfo = _G.GetMerchantItemInfo
local GetMerchantItemID = _G.GetMerchantItemID
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemCostInfo = _G.GetMerchantItemCostInfo
local GetMerchantItemCostItem = _G.GetMerchantItemCostItem
local GetCoinTextureString = _G.GetCoinTextureString
local UnitGUID = _G.UnitGUID
local strsplit = _G.strsplit
local GetTime = _G.GetTime
local C_Timer = _G.C_Timer
local unpack = _G.unpack or table.unpack

local Controls = NS.UI.Controls
local RowStyles = NS.UI.RowStyles
local MapUtil = NS.UI.MapPopupUtil
local Favorite = NS.UI.FavoriteStar
local IA = NS.UI.ItemInteractions

local DRAWER_W = 320
local DRAWER_H = 408
local TAB_W = 28
local TAB_H = 208
local ANIM_TIME = 0.16

local FILTERS = {
  { key = "missing", label = "VENDOR_ASSISTANT_MISSING" },
  { key = "saved", label = "VENDOR_ASSISTANT_SAVED" },
}

local function Theme()
  return NS.UI and NS.UI.Theme and NS.UI.Theme.colors or {}
end

local function ProfileState()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.vendor = profile.vendor or {}
  profile.vendor.assistant = profile.vendor.assistant or {}
  local state = profile.vendor.assistant
  if state.drawerStyle == nil then
    state.open = false
    state.drawerStyle = true
  elseif state.open == nil then
    state.open = false
  end
  if state.filter ~= "saved" and state.filter ~= "missing" then
    state.filter = "missing"
  end
  if state.compactRows == nil then state.compactRows = true end
  if state.showPrices == nil then state.showPrices = true end
  return state
end

local function ItemIDFromLink(link)
  if type(link) ~= "string" then return nil end
  local id = link:match("item:(%d+)")
  return id and tonumber(id) or nil
end

local function MerchantItemID(index)
  if GetMerchantItemID then
    local ok, itemID = pcall(GetMerchantItemID, index)
    if ok and tonumber(itemID) then return tonumber(itemID) end
  end
  return GetMerchantItemLink and ItemIDFromLink(GetMerchantItemLink(index)) or nil
end

local function CurrentNPCID()
  if not UnitGUID then return nil end
  local ok, guid = pcall(UnitGUID, "npc")
  if not ok or type(guid) ~= "string" then return nil end
  if _G.issecretvalue and _G.issecretvalue(guid) then return nil end
  local unitType, _, _, _, _, npcID = strsplit("-", guid)
  if unitType ~= "Creature" and unitType ~= "Vehicle" then return nil end
  return tonumber(npcID)
end

local function IsSaved(itemID)
  if Favorite and Favorite.IsFavorite then
    return Favorite:IsFavorite(itemID)
  end
  local favorites = NS.db and NS.db.profile and NS.db.profile.favorites
  return favorites and favorites[itemID] and true or false
end

local function SetStarTexture(texture, active)
  if texture.SetAtlas then
    texture:SetAtlas(active and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off", true)
  else
    texture:SetTexture("Interface\\Common\\ReputationStar")
  end
  texture:SetVertexColor(1, active and 0.84 or 0.78, active and 0.24 or 0.64, 1)
  texture:SetAlpha(active and 1 or 0.62)
end

local function ToggleSaved(itemID)
  local saved
  if Favorite and Favorite.Toggle then
    saved = Favorite:Toggle(itemID)
  else
    local favorites = NS.db and NS.db.profile and NS.db.profile.favorites
    if not favorites then return false end
    favorites[itemID] = not favorites[itemID]
    if not favorites[itemID] then favorites[itemID] = nil end
    saved = favorites[itemID] and true or false
  end

  local tracker = NS.UI and NS.UI.Tracker
  if tracker and tracker.frame and tracker.frame.RequestRefresh then
    tracker.frame:RequestRefresh("saved")
  end
  local main = NS.UI and NS.UI.MainFrame
  if main and main.view and main.view.RequestRender then
    main.view:RequestRender(false)
  end
  return saved
end

local function IsCollected(item)
  if MapUtil and MapUtil.IsCollected then
    return MapUtil.IsCollected(item.decorID)
  end
  local collection = NS.Systems and NS.Systems.Collection
  if collection and collection.IsCollected then
    local ok, value = pcall(collection.IsCollected, collection, { decorID = item.decorID })
    return ok and value and true or false
  end
  return false
end

local function LiveMerchantItems()
  local byItem = {}
  local total = GetMerchantNumItems and GetMerchantNumItems() or 0
  for index = 1, total do
    local itemID = MerchantItemID(index)
    if itemID then
      local price, extendedCost = 0, false
      if GetMerchantItemInfo then
        local ok, _, _, livePrice, _, _, _, liveExtended = pcall(GetMerchantItemInfo, index)
        if ok then
          price = tonumber(livePrice) or 0
          extendedCost = liveExtended and true or false
        end
      end
      byItem[itemID] = {
        index = index,
        price = price,
        extendedCost = extendedCost,
      }
    end
  end
  return byItem
end

local function AddExtendedCosts(target, merchantIndex)
  if not (GetMerchantItemCostInfo and GetMerchantItemCostItem) then return end
  local ok, count = pcall(GetMerchantItemCostInfo, merchantIndex)
  count = ok and tonumber(count) or 0
  for costIndex = 1, count do
    local costOK, _, amount, link, currencyName = pcall(GetMerchantItemCostItem, merchantIndex, costIndex)
    if costOK then
      amount = tonumber(amount) or 0
      local name = currencyName
      if (not name or name == "") and link and GetItemInfo then
        name = GetItemInfo(link)
      end
      name = name or L["CURRENCY"] or "Currency"
      target[name] = (target[name] or 0) + amount
    end
  end
end

local function CostText(live)
  if not live then return "" end
  local parts = {}
  if live.price and live.price > 0 and GetCoinTextureString then
    parts[#parts + 1] = GetCoinTextureString(live.price)
  end
  if live.extendedCost and GetMerchantItemCostInfo and GetMerchantItemCostItem then
    local extended = {}
    AddExtendedCosts(extended, live.index)
    for name, amount in pairs(extended) do
      parts[#parts + 1] = tostring(amount) .. " " .. tostring(name)
    end
  end
  return table.concat(parts, " + ")
end

local function NewButton(parent, label)
  local T = Theme()
  local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
  button:SetHeight(24)
  if Controls and Controls.Backdrop then
    Controls:Backdrop(button, T.panel, T.border)
    Controls:ApplyHover(button, T.panel, T.hover, T.border, T.accentSoft)
  end
  button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  button.text:SetPoint("CENTER")
  button.text:SetText(label)
  return button
end

local function DecorLine(parent, y)
  local T = Theme()
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetHeight(1)
  line:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
  line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, y)
  local accent = T.accent or { 0.90, 0.72, 0.18, 1 }
  line:SetColorTexture(accent[1], accent[2], accent[3], 0.34)
  return line
end

local function NewOptionCheckbox(parent, label, y, getValue, setValue)
  local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  check:SetSize(22, 22)
  check:SetPoint("TOPLEFT", 10, y)
  check.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  check.label:SetPoint("LEFT", check, "RIGHT", 3, 0)
  check.label:SetText(label)
  check:SetScript("OnShow", function(self) self:SetChecked(getValue() and true or false) end)
  check:SetScript("OnClick", function(self)
    setValue(self:GetChecked() and true or false)
    Assistant:RefreshRows()
  end)
  return check
end

function Assistant:SetDrawerOpen(open, animate)
  local frame = self.frame
  local state = ProfileState()
  if not (frame and state) then return end
  open = open and true or false
  state.open = open
  if not open and frame.settings then frame.settings:Hide() end

  frame:SetScript("OnUpdate", nil)
  local fromWidth = frame:IsShown() and (frame:GetWidth() or 1) or 1
  local toWidth = open and DRAWER_W or 1
  if open then
    frame:Show()
    frame:Raise()
    self:RefreshRows()
  end

  local function finish()
    frame:SetWidth(toWidth)
    frame:SetAlpha(open and 1 or 0)
    if open then self:RefreshRows() end
    if not open then frame:Hide() end
    if self.tab and self.tab.arrow then self.tab.arrow:SetText(open and ">" or "<") end
  end

  if not animate or not GetTime then
    finish()
    return
  end

  local startTime = GetTime()
  frame:SetAlpha(open and 0.92 or 1)
  frame:SetScript("OnUpdate", function(self)
    local progress = math.min(1, (GetTime() - startTime) / ANIM_TIME)
    local eased = 1 - ((1 - progress) * (1 - progress))
    self:SetWidth(fromWidth + ((toWidth - fromWidth) * eased))
    self:SetAlpha(open and (0.92 + 0.08 * eased) or (1 - 0.18 * eased))
    if progress >= 1 then
      self:SetScript("OnUpdate", nil)
      finish()
    end
  end)
end

function Assistant:Ensure()
  if self.frame or not MerchantFrame then return end
  local T = Theme()
  local accent = T.accent or { 0.90, 0.72, 0.18, 1 }
  local text = T.text or { 0.92, 0.92, 0.92, 1 }
  local muted = T.textMuted or { 0.65, 0.65, 0.68, 1 }

  local tab = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
  tab:SetSize(TAB_W, TAB_H)
  tab:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 0, -50)
  tab:SetFrameStrata("DIALOG")
  tab:SetFrameLevel((MerchantFrame:GetFrameLevel() or 1) + 12)
  tab:Hide()
  if Controls and Controls.Backdrop then
    Controls:Backdrop(tab, T.header or T.panel, T.border)
    Controls:ApplyHover(tab, T.header or T.panel, T.hover, T.border, T.accentSoft)
  end
  local glow = tab:CreateTexture(nil, "ARTWORK")
  glow:SetPoint("LEFT", 1, 0)
  glow:SetSize(2, TAB_H - 8)
  glow:SetColorTexture(accent[1], accent[2], accent[3], 0.9)
  tab.glow = glow

  tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  tab.label:SetPoint("CENTER", -1, 0)
  tab.label:SetJustifyH("CENTER")
  tab.label:SetText("H\nO\nM\nE\nD\nE\nC\nO\nR")
  Controls:TextColor(tab.label, "accent")

  tab.arrow = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  tab.arrow:SetPoint("BOTTOM", 0, 7)
  tab.arrow:SetText("<")
  Controls:TextColor(tab.arrow, "text", 0.8)

  tab:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["VENDOR_ASSISTANT_TOGGLE"] or "Open HomeDecor vendor drawer")
    GameTooltip:Show()
  end)
  tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
  tab:SetScript("OnClick", function()
    local state = ProfileState()
    if not state then return end
    Assistant:SetDrawerOpen(not state.open, true)
  end)
  self.tab = tab

  local frame = CreateFrame("Frame", "HomeDecorVendorAssistant", UIParent, "BackdropTemplate")
  frame:SetSize(DRAWER_W, DRAWER_H)
  frame:SetPoint("TOPLEFT", tab, "TOPRIGHT", 0, 0)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(tab:GetFrameLevel() - 1)
  frame:SetClampedToScreen(true)
  frame:SetClipsChildren(true)
  frame:Hide()
  if Controls and Controls.Backdrop then Controls:Backdrop(frame, T.panel, T.border) end

  local inner = CreateFrame("Frame", nil, frame)
  inner:SetSize(DRAWER_W, DRAWER_H)
  inner:SetPoint("TOPLEFT")
  frame.inner = inner

  local header = CreateFrame("Frame", nil, inner, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 6, -6)
  header:SetPoint("TOPRIGHT", -6, -6)
  header:SetHeight(46)
  if RowStyles and RowStyles.SkinTrackerHeader then
    RowStyles:SkinTrackerHeader(header, 0)
  elseif Controls and Controls.Backdrop then
    Controls:Backdrop(header, T.header, T.border)
  end

  header.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  header.title:SetPoint("TOPLEFT", 12, -7)
  header.title:SetText("HomeDecor")
  Controls:TextColor(header.title, "accent")

  header.sub = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  header.sub:SetPoint("TOPLEFT", header.title, "BOTTOMLEFT", 0, -1)
  header.sub:SetText(L["VENDOR_ASSISTANT_SUBTITLE"] or "Decor shopping list")
  Controls:TextColor(header.sub, "textMuted")

  header.close = NewButton(header, ">")
  header.close:SetSize(24, 24)
  header.close:SetPoint("RIGHT", -8, 0)
  header.close:SetScript("OnClick", function() Assistant:SetDrawerOpen(false, true) end)

  header.settings = CreateFrame("Button", nil, header, "BackdropTemplate")
  header.settings:SetSize(24, 24)
  header.settings:SetPoint("RIGHT", header.close, "LEFT", -5, 0)
  if Controls and Controls.Backdrop then
    Controls:Backdrop(header.settings, T.panel, T.border)
    Controls:ApplyHover(header.settings, T.panel, T.hover, T.border, T.accentSoft)
  end
  header.settings.icon = header.settings:CreateTexture(nil, "OVERLAY")
  header.settings.icon:SetSize(14, 14)
  header.settings.icon:SetPoint("CENTER")
  header.settings.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  if Controls and Controls.TextureColor then Controls:TextureColor(header.settings.icon, "accent") end
  header.settings:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["VENDOR_ASSISTANT_OPTIONS"] or "Drawer Options")
    GameTooltip:Show()
  end)
  header.settings:SetScript("OnLeave", function() GameTooltip:Hide() end)

  local settings = CreateFrame("Frame", nil, inner, "BackdropTemplate")
  settings:SetSize(190, 82)
  settings:SetPoint("TOPRIGHT", header.settings, "BOTTOMRIGHT", 0, -5)
  settings:SetFrameLevel(frame:GetFrameLevel() + 20)
  settings:Hide()
  if Controls and Controls.Backdrop then Controls:Backdrop(settings, T.panel, T.border) end
  settings.title = settings:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  settings.title:SetPoint("TOPLEFT", 12, -9)
  settings.title:SetText(L["VENDOR_ASSISTANT_OPTIONS"] or "Drawer Options")
  Controls:TextColor(settings.title, "accent")
  NewOptionCheckbox(settings, L["VENDOR_ASSISTANT_COMPACT_ROWS"] or "Compact item rows", -26,
    function() local state = ProfileState(); return state and state.compactRows end,
    function(value) local state = ProfileState(); if state then state.compactRows = value end end)
  NewOptionCheckbox(settings, L["VENDOR_ASSISTANT_SHOW_PRICES"] or "Show prices", -50,
    function() local state = ProfileState(); return state and state.showPrices end,
    function(value) local state = ProfileState(); if state then state.showPrices = value end end)
  header.settings:SetScript("OnClick", function()
    settings:SetShown(not settings:IsShown())
  end)

  local cards = CreateFrame("Frame", nil, inner)
  cards:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
  cards:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -6)
  cards:SetHeight(36)

  local function MakeMetric(anchor, title)
    local card = CreateFrame("Frame", nil, cards, "BackdropTemplate")
    card:SetSize(91, 34)
    card:SetPoint("LEFT", anchor, anchor == cards and "LEFT" or "RIGHT", anchor == cards and 0 or 6, 0)
    if Controls and Controls.Backdrop then Controls:Backdrop(card, T.row, T.border) end
    card.title = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    card.title:SetPoint("TOPLEFT", 7, -4)
    card.title:SetText(title)
    Controls:TextColor(card.title, "textMuted")
    card.value = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.value:SetPoint("BOTTOMLEFT", 7, 3)
    Controls:TextColor(card.value, "accent")
    return card
  end

  cards.missing = MakeMetric(cards, L["VENDOR_ASSISTANT_MISSING"] or "Missing")
  cards.saved = MakeMetric(cards.missing, L["VENDOR_ASSISTANT_SAVED"] or "Saved")
  cards.total = MakeMetric(cards.saved, "Vendor")

  local filterBar = CreateFrame("Frame", nil, inner)
  filterBar:SetPoint("TOPLEFT", cards, "BOTTOMLEFT", 0, -5)
  filterBar:SetPoint("TOPRIGHT", cards, "BOTTOMRIGHT", 0, -5)
  filterBar:SetHeight(24)
  frame.filterButtons = {}
  for index, info in ipairs(FILTERS) do
    local button = NewButton(filterBar, L[info.label] or info.key)
    button:SetSize(91, 23)
    if index == 1 then
      button:SetPoint("LEFT", 0, 0)
    else
      button:SetPoint("LEFT", frame.filterButtons[index - 1], "RIGHT", 6, 0)
    end
    button.filterKey = info.key
    button:SetScript("OnClick", function()
      local state = ProfileState()
      if not state then return end
      state.filter = info.key
      Assistant:RefreshRows()
    end)
    frame.filterButtons[index] = button
  end
  DecorLine(inner, -120)

  local scroll = CreateFrame("ScrollFrame", nil, inner, "ScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", filterBar, "BOTTOMLEFT", 0, -11)
  scroll:SetPoint("BOTTOMRIGHT", inner, "BOTTOMRIGHT", -26, 38)
  if Controls and Controls.SkinScrollFrame then Controls:SkinScrollFrame(scroll) end

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)

  local empty = inner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  empty:SetPoint("CENTER", scroll, "CENTER", 0, 12)
  empty:SetWidth(260)
  empty:SetJustifyH("CENTER")
  Controls:TextColor(empty, "textMuted")
  empty:Hide()

  local total = inner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  total:SetPoint("BOTTOMLEFT", inner, "BOTTOMLEFT", 12, 12)
  total:SetPoint("RIGHT", inner, "RIGHT", -12, 0)
  total:SetJustifyH("LEFT")
  Controls:TextColor(total, "text")
  DecorLine(inner, -378)

  frame.header = header
  frame.settings = settings
  frame.cards = cards
  frame.scroll = scroll
  frame.content = content
  frame.empty = empty
  frame.total = total
  frame.rows = {}
  self.frame = frame
end

function Assistant:AcquireRow(index)
  local frame = self.frame
  local row = frame.rows[index]
  if row then return row end
  local T = Theme()
  local muted = T.textMuted or { 0.65, 0.65, 0.68, 1 }

  row = CreateFrame("Button", nil, frame.content, "BackdropTemplate")
  row:SetHeight(42)
  row:RegisterForClicks("AnyUp")
  if RowStyles and RowStyles.SkinTrackerItem then
    RowStyles:SkinTrackerItem(row, 0.14)
  elseif Controls and Controls.Backdrop then
    Controls:Backdrop(row, T.row, T.border)
  end

  row.media = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.media:SetSize(32, 32)
  row.media:SetPoint("LEFT", 6, 0)
  if Controls and Controls.Backdrop then Controls:Backdrop(row.media, T.iconBG or T.row, T.border) end

  row.icon = row.media:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(27, 27)
  row.icon:SetPoint("CENTER")
  row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  row.check = row.media:CreateTexture(nil, "OVERLAY", nil, 7)
  row.check:SetSize(13, 13)
  row.check:SetPoint("BOTTOMLEFT", 1, 1)
  if row.check.SetAtlas then row.check:SetAtlas("common-icon-checkmark", true) end
  row.check:SetVertexColor(0.75, 0.95, 0.75, 0.95)

  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.media, "TOPRIGHT", 8, -5)
  row.title:SetPoint("RIGHT", row, "RIGHT", -34, 0)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.title:SetMaxLines(1)

  row.cost = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.cost:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -1)
  row.cost:SetPoint("RIGHT", row, "RIGHT", -34, 0)
  row.cost:SetJustifyH("LEFT")
  Controls:TextColor(row.cost, "textMuted")

  row.star = CreateFrame("Button", nil, row)
  row.star:SetSize(20, 20)
  row.star:SetPoint("RIGHT", -7, 0)
  row.star.texture = row.star:CreateTexture(nil, "OVERLAY")
  row.star.texture:SetAllPoints()
  row.star:SetScript("OnClick", function(self)
    if not self.itemID then return end
    ToggleSaved(self.itemID)
    Assistant:RefreshRows()
  end)
  row.star:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["VENDOR_ASSISTANT_SAVED_HINT"] or "Click to add or remove from Saved Items.")
    GameTooltip:Show()
  end)
  row.star:SetScript("OnLeave", function() GameTooltip:Hide() end)

  frame.rows[index] = row
  return row
end

function Assistant:RefreshRows()
  local frame = self.frame
  local state = ProfileState()
  if not frame or not frame:IsShown() or not state or not state.open then return end
  local items = self.items or {}
  local liveByItem = self.liveByItem or {}
  local visible = {}
  local missing, saved = 0, 0
  local compact = state.compactRows ~= false
  local showPrices = state.showPrices ~= false
  local rowHeight = compact and 42 or 52
  local mediaSize = compact and 32 or 40
  local iconSize = compact and 27 or 34
  local step = rowHeight + (compact and 4 or 5)
  if Controls and Controls.SyncScrollChildWidth then
    Controls:SyncScrollChildWidth(frame.scroll, frame.content)
  end

  for _, item in ipairs(items) do
    item.collected = IsCollected(item)
    item.saved = IsSaved(item.itemID)
    if not item.collected then missing = missing + 1 end
    if item.saved then saved = saved + 1 end
    if (state.filter == "missing" and not item.collected)
      or (state.filter == "saved" and item.saved)
    then
      visible[#visible + 1] = item
    end
  end

  frame.cards.missing.value:SetText(tostring(missing))
  frame.cards.saved.value:SetText(tostring(saved))
  frame.cards.total.value:SetText(tostring(#items))
  for _, button in ipairs(frame.filterButtons) do
    local selected = button.filterKey == state.filter
    Controls:TextColor(button.text, selected and "accent" or "textMuted")
    if RowStyles and RowStyles.SetSelected then
      RowStyles:SetSelected(button, selected, 0.24)
    end
  end

  table.sort(visible, function(a, b)
    if a.saved ~= b.saved then return a.saved end
    return tostring(a.title or a.itemID):lower() < tostring(b.title or b.itemID):lower()
  end)

  local totalGold = 0
  local totalExtended = {}
  local y = 0
  for index, item in ipairs(visible) do
    local row = self:AcquireRow(index)
    local data = MapUtil and MapUtil.GetItemData and MapUtil.GetItemData(item.itemID) or nil
    local live = liveByItem[item.itemID]
    row.star.itemID = item.itemID
    SetStarTexture(row.star.texture, item.saved)
    row:SetHeight(rowHeight)
    row.media:SetSize(mediaSize, mediaSize)
    row.icon:SetSize(iconSize, iconSize)
    row.icon:SetTexture((data and data.icon) or "Interface\\Icons\\INV_Misc_QuestionMark")
    row.title:ClearAllPoints()
    if showPrices then
      row.title:SetPoint("TOPLEFT", row.media, "TOPRIGHT", compact and 8 or 10, compact and -5 or -8)
    else
      row.title:SetPoint("LEFT", row.media, "RIGHT", compact and 8 or 10, 0)
    end
    row.title:SetPoint("RIGHT", row, "RIGHT", -34, 0)
    row.title:SetText((data and data.name) or item.title or ("Item " .. tostring(item.itemID)))
    Controls:TextColor(row.title, "text")
    if data and MapUtil and MapUtil.GetQualityColor then
      row.title:SetTextColor(MapUtil.GetQualityColor(data.quality))
    end
    row.check:SetShown(item.collected)
    row:SetAlpha(item.collected and 0.68 or 1)
    row.cost:SetText(CostText(live))
    row.cost:SetShown(showPrices)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -y)
    row:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -y)
    row:Show()
    if IA and IA.Bind then IA:Bind(row, item, item.navVendor) end
    y = y + step
    if live then
      totalGold = totalGold + (tonumber(live.price) or 0)
      if live.extendedCost then AddExtendedCosts(totalExtended, live.index) end
    end
  end
  for index = #visible + 1, #frame.rows do
    frame.rows[index]:Hide()
  end

  frame.content:SetHeight(math.max(1, y))
  frame.empty:SetText(state.filter == "saved"
    and (L["VENDOR_ASSISTANT_EMPTY_SAVED"] or "Star missing decor to save it here.")
    or (L["VENDOR_ASSISTANT_EMPTY_MISSING"] or "Nothing missing from this vendor."))
  frame.empty:SetShown(#visible == 0)

  local totalParts = {}
  if totalGold > 0 and GetCoinTextureString then
    totalParts[#totalParts + 1] = GetCoinTextureString(totalGold)
  end
  for name, amount in pairs(totalExtended) do
    totalParts[#totalParts + 1] = tostring(amount) .. " " .. tostring(name)
  end
  local totalText = #totalParts > 0 and table.concat(totalParts, " + ") or "-"
  frame.total:SetText((L["VENDOR_ASSISTANT_TOTAL"] or "Shopping total:") .. "  " .. totalText)
  frame.total:SetShown(showPrices)
end

function Assistant:Refresh()
  if not MerchantFrame or not MerchantFrame:IsShown() then
    self:Hide()
    return
  end
  self:Ensure()
  if not self.frame then return end

  local npcID = CurrentNPCID()
  local items = npcID and MapUtil and MapUtil.GetVendorItems and MapUtil.GetVendorItems(npcID) or {}
  if type(items) ~= "table" or #items == 0 then
    self:Hide()
    return
  end

  self.npcID = npcID
  self.items = items
  self.liveByItem = LiveMerchantItems()
  self.tab:Show()

  local state = ProfileState()
  if not state then return end
  if state.open then
    if not self.frame:IsShown() then
      self:SetDrawerOpen(true, false)
    else
      self:RefreshRows()
    end
  else
    self.frame:Hide()
    self.tab.arrow:SetText("<")
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(0.2, function()
      if Assistant.frame and Assistant.frame:IsShown() and Assistant.npcID == npcID then
        Assistant:RefreshRows()
      end
    end)
  end
end

function Assistant:Hide()
  if self.frame then
    self.frame:SetScript("OnUpdate", nil)
    self.frame:Hide()
  end
  if self.tab then self.tab:Hide() end
  self.items = nil
  self.liveByItem = nil
  self.npcID = nil
end

return Assistant
