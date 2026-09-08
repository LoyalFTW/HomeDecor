local _, NS = ...

NS.UI = NS.UI or {}
local TrackerPanel = {}
NS.UI.TrackerPanel = TrackerPanel

local ROW_HEIGHT = 42
local ROW_COUNT = 20
local FAVORITES_QUERY = { favoriteOnly = true }
local TrackerData = NS.UI.TrackerData
local TrackerOptions = NS.UI.TrackerOptions
local RequestRefresh = NS.Debounce(0.08, function()
  if TrackerPanel.frame then TrackerPanel.frame.viewSignature = nil end
  TrackerPanel:Refresh(false)
end)

local function CurrentArea()
  return TrackerData:GetCurrentArea()
end

local function GetTab()
  return TrackerData:GetTab()
end

local function SetTab(tab)
  TrackerData:SetTab(tab)
end

local function AreaKey(record)
  return TrackerData:GetAreaKey(record)
end

local function TransparencyAmount()
  return TrackerOptions:GetTransparency()
end

local function BackgroundAlpha(value, transparentValue)
  return TrackerOptions:GetAlpha(value, transparentValue)
end

local function IsComplete(record, tab)
  return TrackerData:IsComplete(record, tab)
end

local function ShoppingGroup(record)
  local sourceType = tostring(record and record.sourceType or ""):lower()
  if sourceType == "vendor" then
    local sourceID = tonumber(record.sourceID)
    local vendor = record.vendorName or record.sourceName or (sourceID and NS.Systems.NPCNames:Get(sourceID)) or "Unknown Vendor"
    local zone = type(record.zone) == "string" and record.zone ~= "" and record.zone or "Unknown Area"
    return "vendor:" .. tostring(sourceID or vendor), zone .. "  -  " .. tostring(vendor), "3:" .. zone .. ":" .. tostring(vendor)
  end
  if sourceType == "profession" then return "source:profession", "Crafting / Auction House", "2:crafting" end
  if sourceType == "quest" then return "source:quest", "Quest Rewards", "4:quests" end
  if sourceType == "drop" then return "source:drop", "Drops", "5:drops" end
  if sourceType == "achievement" then return "source:achievement", "Achievements", "6:achievements" end
  if sourceType == "event" then return "source:event", "Events", "7:events" end
  if sourceType == "pvp" then return "source:pvp", "PvP Vendors", "8:pvp" end
  if sourceType == "shop" then return "source:shop", "Shops", "9:shops" end
  return "source:wishlist", "Wishlist / Other Sources", "1:wishlist"
end

local function ViewItem(record)
  local itemID = record and (record.itemID or record.id)
  if itemID and _G.DressUpItemLink then
    local ok = pcall(_G.DressUpItemLink, "item:" .. tostring(itemID))
    if ok then return end
  end
  NS.UI.CatalogView:Open("tracked")
  NS.UI.Inspector:Show(record)
end

function TrackerPanel:CreateRow(parent, onMouseWheel)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  NS.UI.Controls:Backdrop(row, NS.UI.Controls.colors.row)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(26, 26)
  row.icon:SetPoint("LEFT", 7, 0)
  row.check = row:CreateTexture(nil, "OVERLAY")
  row.check:SetSize(15, 15)
  row.check:SetPoint("TOP", row.icon, "TOP", 0, 2)
  row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.check:Hide()
  row.favorite = NS.UI.FavoriteStar:Create(row, 20)
  row.favorite:SetPoint("RIGHT", -31, 0)
  row.remove = NS.UI.Controls:CreateButton(row, "X", 22, 22)
  row.remove:SetPoint("RIGHT", -5, 0)
  row.remove:SetScript("OnClick", function(self)
    local owner = self:GetParent()
    local record = owner.record
    if not record then return end
    local tab = GetTab()
    if tab == "area" then
      NS.UI.ListSelector:Show(self, record, function(id, selected)
        NS.Systems.Lists:Toggle(selected, id)
        TrackerPanel:Refresh(false)
      end)
    elseif tab == "favorites" then
      NS.Systems.Favorites:Toggle(record)
    elseif tab == "lists" then
      NS.Systems.Lists:Remove(record)
      TrackerPanel:Refresh(false)
    elseif tab == "blueprints" then
      NS.Systems.BlueprintList:Remove(record._blueprintCategory, record._blueprintKey)
      TrackerPanel:Refresh(false)
    end
  end)
  row.minus = NS.UI.Controls:CreateButton(row, "-", 22, 22)
  row.minus:SetPoint("RIGHT", -57, 0)
  row.minus:SetScript("OnClick", function(self)
    local record = self:GetParent().record
    if not record then return end
    local quantity = NS.Systems.Lists:GetQuantity(record)
    if quantity > 1 then NS.Systems.Lists:SetQuantity(record, quantity - 1) end
    TrackerPanel:Refresh(false)
  end)
  row.plus = NS.UI.Controls:CreateButton(row, "+", 22, 22)
  row.plus:SetPoint("RIGHT", -31, 0)
  row.plus:SetScript("OnClick", function(self)
    local record = self:GetParent().record
    if not record then return end
    NS.Systems.Lists:AdjustQuantity(record, 1)
    TrackerPanel:Refresh(false)
  end)
  row.quantity = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.quantity:SetPoint("RIGHT", row.minus, "LEFT", -5, 0)
  row.quantity:SetJustifyH("RIGHT")
  NS.UI.Controls:TextColor(row.quantity, "accent")
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -5)
  row.title:SetPoint("TOPRIGHT", -34, -5)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.headerCount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.headerCount:SetPoint("RIGHT", -8, 0)
  row.headerCount:SetJustifyH("RIGHT")
  row.headerCount:Hide()
  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 5)
  row.meta:SetPoint("BOTTOMRIGHT", -34, 5)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetWordWrap(false)
  row:SetScript("OnClick", function(self, button)
    if not self.record then return end
    if self.record.areaHeader or self.record.listHeader then
      local frame = TrackerPanel.frame
      if button == "RightButton" and self.record.listHeader and self.record.navigationRecord and self.record.navigationRecord.sourceType == "vendor" then
        NS.Systems.Navigation:Open(self.record.navigationRecord)
        return
      end
      if self.record.listHeader then
        frame.openListGroups[self.record.groupKey] = frame.openListGroups[self.record.groupKey] == false
      else
        frame.openAreaSources[self.record.areaKey] = not frame.openAreaSources[self.record.areaKey]
      end
      frame.viewSignature = nil
      TrackerPanel:Refresh(false)
      return
    end
    if NS.UI.ItemInteractions:HandleClick(self.record) then return end
    if button == "RightButton" then
      NS.Systems.Navigation:Open(self.record)
      return
    end
    ViewItem(self.record)
  end)
  row:SetScript("OnEnter", function(self)
    local color = NS.UI.Controls.colors.hover
    self:SetBackdropColor(color[1], color[2], color[3], BackgroundAlpha(color[4], 0.18))
    if self.record and self.record.listHeader and _G.GameTooltip then
      _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      _G.GameTooltip:SetText(self.record.title)
      local hint = self.record.navigationRecord and self.record.navigationRecord.sourceType == "vendor" and "Left-click to expand or collapse. Right-click to open the vendor on the map." or "Left-click to expand or collapse."
      _G.GameTooltip:AddLine(hint, 0.82, 0.82, 0.82, true)
      _G.GameTooltip:Show()
      return
    end
    if not self.record or self.record.areaHeader or self.record.listHeader then return end
    NS.UI.ItemTooltip:Show(self, self.record, "tracker")
  end)
  row:SetScript("OnLeave", function(self)
    local focused = self.record and self.record.areaHeader and TrackerPanel.frame and self.record.areaKey == TrackerPanel.frame.focusAreaKey
    local color = focused and NS.UI.Controls.colors.hover or self.record and (self.record.areaHeader or self.record.listHeader) and NS.UI.Controls.colors.header or NS.UI.Controls.colors.row
    self:SetBackdropColor(color[1], color[2], color[3], BackgroundAlpha(color[4], 0))
    NS.UI.ItemTooltip:Hide()
    if _G.GameTooltip then _G.GameTooltip:Hide() end
  end)
  row:EnableMouseWheel(true)
  row:SetScript("OnMouseWheel", onMouseWheel)
  row.favorite:EnableMouseWheel(true)
  row.favorite:SetScript("OnMouseWheel", onMouseWheel)
  row.remove:EnableMouseWheel(true)
  row.remove:SetScript("OnMouseWheel", onMouseWheel)
  row.minus:EnableMouseWheel(true)
  row.minus:SetScript("OnMouseWheel", onMouseWheel)
  row.plus:EnableMouseWheel(true)
  row.plus:SetScript("OnMouseWheel", onMouseWheel)
  return row
end

function TrackerPanel:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorTracker", UIParent, "BackdropTemplate")
  frame:Hide()
  frame:SetSize(350, 540)
  frame:SetPoint("RIGHT", -32, 0)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(100)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.Systems.Layout:Restore(frame, "tracker")
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.background)
  NS.UI.Controls:MakeMovable(frame, frame, "tracker")
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 12, -8)
  title:SetText("Decor Tracker")
  frame.titleText = title
  frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.count:SetPoint("TOPRIGHT", -82, -10)
  local close = NS.UI.Controls:CreateCloseButton(frame, function() frame:Hide() end, 20, 20)
  close:SetPoint("TOPRIGHT", -6, -5)
  frame.closeButton = close
  local settingsButton = NS.UI.Controls:CreateButton(frame, "", 20, 20)
  settingsButton:SetPoint("TOPRIGHT", close, "TOPLEFT", -4, 0)
  settingsButton.icon = settingsButton:CreateTexture(nil, "ARTWORK")
  settingsButton.icon:SetPoint("TOPLEFT", 2, -2)
  settingsButton.icon:SetPoint("BOTTOMRIGHT", -2, 2)
  settingsButton.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  frame.settingsButton = settingsButton
  local minimize = NS.UI.Controls:CreateButton(frame, "-", 20, 20)
  minimize:SetPoint("TOPRIGHT", settingsButton, "TOPLEFT", -4, 0)
  frame.minimizeButton = minimize
  frame.options = TrackerOptions:Create(frame, settingsButton, {
    onHideCompleted = function()
      frame.viewSignature = nil
      TrackerPanel:Refresh(true)
    end,
    onTransparency = function() TrackerPanel:ApplyAppearance() end,
  })
  frame.tabs = {}
  local function CreateTab(label, tab, anchor, width)
    local button = NS.UI.Controls:CreateButton(frame, label, width, 22)
    button:SetSize(width, 22)
    button:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, 0)
    button:SetScript("OnClick", function()
      NS.UI.Controls:CloseTransientPopups()
      if GetTab() == tab then return end
      SetTab(tab)
      TrackerPanel:Refresh(true)
    end)
    button.tab = tab
    frame.tabs[#frame.tabs + 1] = button
    return button
  end
  local areaTab = NS.UI.Controls:CreateButton(frame, "Area", 60, 22)
  areaTab:SetPoint("TOPLEFT", 12, -32)
  areaTab.tab = "area"
  areaTab:SetScript("OnClick", function()
    NS.UI.Controls:CloseTransientPopups()
    if GetTab() == "area" then return end
    SetTab("area")
    TrackerPanel:Refresh(true)
  end)
  frame.tabs[1] = areaTab
  CreateTab("Shopping List", "lists", areaTab, 110)
  CreateTab("Plans", "blueprints", frame.tabs[2], 60)
  CreateTab("Saved", "favorites", frame.tabs[3], 64)
  local search = NS.UI.Controls:CreateSearchBox(frame, {
    height = 20,
    placeholder = "Search",
    onChanged = function() TrackerPanel:Refresh(true) end,
  })
  search:SetPoint("TOPLEFT", 16, -60)
  search:SetPoint("TOPRIGHT", -32, -60)
  frame.search = search
  local areaBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  areaBar:SetPoint("TOPLEFT", 12, -86)
  areaBar:SetPoint("TOPRIGHT", -28, -86)
  areaBar:SetHeight(22)
  NS.UI.Controls:Backdrop(areaBar, NS.UI.Controls.colors.panel)
  local areaLabel = areaBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  areaLabel:SetPoint("RIGHT", -8, 0)
  areaLabel:SetJustifyH("RIGHT")
  local trackZone = NS.UI.Controls:CreateCheckButton(areaBar, "Track Current Zone")
  trackZone:SetSize(20, 20)
  trackZone:SetPoint("LEFT", 2, 0)
  NS.UI.Controls:TextColor(trackZone.label, "text")
  trackZone:SetScript("OnClick", function(self)
    NS.Systems.Settings:SetValue("trackerTrackCurrentZone", self:GetChecked() == true)
    if self:GetChecked() then
      local name, mapID, maps = CurrentArea()
      frame.areaName, frame.areaMapID, frame.areaMaps = name, mapID, maps
      frame.viewSignature = nil
      TrackerPanel:Refresh(true)
    end
  end)
  NS.UI.Controls:TextColor(areaLabel, "accent")
  frame.areaBar = areaBar
  frame.areaLabel = areaLabel
  frame.trackZone = trackZone
  local listBar = CreateFrame("Frame", nil, frame)
  listBar:SetPoint("TOPLEFT", 12, -86)
  listBar:SetPoint("TOPRIGHT", -28, -86)
  listBar:SetHeight(70)
  local selector = NS.UI.Controls:CreateButton(listBar, "", 186, 22)
  selector:SetPoint("TOPLEFT", 0, 0)
  selector:SetScript("OnClick", function(self)
    local store, profile = NS.Systems.Lists:GetStore()
    local options = {}
    for _, id in ipairs(store and store.order or {}) do
      local entry = store.entries[id]
      if entry then options[#options + 1] = { value = id, label = entry.name } end
    end
    options[#options + 1] = { value = "__new", label = "+ New Shopping List" }
    NS.UI.Dropdown:Show(self, options, profile and profile.ui and profile.ui.activeListID, function(value)
      if value == "__new" then NS.Systems.Lists:Create("New Shopping List") else NS.Systems.Lists:SetActive(value) end
      TrackerPanel:Refresh(true)
    end)
  end)
  local renameButton = NS.UI.Controls:CreateButton(listBar, "Rename", 56, 22)
  renameButton:SetPoint("LEFT", selector, "RIGHT", 4, 0)
  local clearButton = NS.UI.Controls:CreateButton(listBar, "Delete", 56, 22)
  clearButton:SetPoint("LEFT", renameButton, "RIGHT", 4, 0)
  clearButton:SetScript("OnClick", function()
    NS.Systems.Lists:DeleteActive()
    TrackerPanel:Refresh(true)
  end)
  local name = CreateFrame("EditBox", nil, listBar, "BackdropTemplate")
  name:SetPoint("TOPLEFT", 0, 0)
  name:SetPoint("RIGHT", clearButton, "LEFT", -4, 0)
  name:SetHeight(22)
  name:SetAutoFocus(false)
  name:SetTextInsets(8, 8, 0, 0)
  name:SetFontObject(GameFontHighlightSmall)
  NS.UI.Controls:Backdrop(name, NS.UI.Controls.colors.panel)
  name:SetScript("OnEnterPressed", function(self)
    NS.Systems.Lists:Rename(self:GetText())
    self:ClearFocus()
    TrackerPanel:Refresh(false)
  end)
  name:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    TrackerPanel:Refresh(false)
  end)
  name:Hide()
  renameButton:SetScript("OnClick", function()
    local entry = NS.Systems.Lists:GetActive()
    if not entry then return end
    selector:Hide()
    renameButton:Hide()
    name:SetText(entry.name)
    name:Show()
    name:SetFocus()
    name:HighlightText()
  end)
  name:SetScript("OnEditFocusLost", function(self)
    if not self:IsShown() then return end
    self:Hide()
    selector:Show()
    renameButton:Show()
  end)
  frame.listBar = listBar
  frame.listName = name
  frame.listSelector = selector
  frame.listRename = renameButton
  frame.listClear = clearButton
  local importButton = NS.UI.Controls:CreateButton(listBar, "Import", 72, 22)
  importButton:SetPoint("TOPLEFT", listBar, "TOPLEFT", 0, -26)
  local exportButton = NS.UI.Controls:CreateButton(listBar, "Export", 72, 22)
  exportButton:SetPoint("LEFT", importButton, "RIGHT", 4, 0)
  local listSource = listBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  listSource:SetPoint("TOPLEFT", listBar, "TOPLEFT", 0, -52)
  listSource:SetPoint("TOPRIGHT", listBar, "TOPRIGHT", 0, -52)
  listSource:SetJustifyH("LEFT")
  listSource:SetWordWrap(false)
  NS.UI.Controls:TextColor(listSource, "muted")
  frame.listImport = importButton
  frame.listExport = exportButton
  frame.listSource = listSource
  local transfer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  transfer:SetSize(500, 330)
  transfer:SetPoint("CENTER", frame, "CENTER", 0, 0)
  transfer:SetFrameStrata("DIALOG")
  transfer:SetFrameLevel(frame:GetFrameLevel() + 80)
  transfer:SetClampedToScreen(true)
  transfer:EnableMouse(true)
  transfer:Hide()
  NS.UI.Controls:Backdrop(transfer, NS.UI.Controls.colors.background)
  NS.UI.Controls:MakeMovable(transfer, transfer)
  local transferTitle = transfer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  transferTitle:SetPoint("TOPLEFT", 14, -12)
  NS.UI.Controls:TextColor(transferTitle, "accent")
  local transferHint = transfer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  transferHint:SetPoint("TOPLEFT", transferTitle, "BOTTOMLEFT", 0, -5)
  transferHint:SetPoint("TOPRIGHT", transfer, "TOPRIGHT", -44, -36)
  transferHint:SetJustifyH("LEFT")
  transferHint:SetWordWrap(false)
  NS.UI.Controls:TextColor(transferHint, "muted")
  local transferCloseX = NS.UI.Controls:CreateCloseButton(transfer, function() transfer:Hide() end, 22, 22)
  transferCloseX:SetPoint("TOPRIGHT", -10, -10)
  local editor = CreateFrame("Frame", nil, transfer, "BackdropTemplate")
  editor:SetPoint("TOPLEFT", 14, -62)
  editor:SetPoint("BOTTOMRIGHT", -14, 52)
  NS.UI.Controls:Backdrop(editor, NS.UI.Controls.colors.panel)
  local transferScroll = NS.UI.Controls:CreateScrollFrame(editor, "ScrollFrameTemplate")
  transferScroll:SetPoint("TOPLEFT", 7, -7)
  transferScroll:SetPoint("BOTTOMRIGHT", -21, 7)
  local transferBox = CreateFrame("EditBox", nil, transferScroll)
  transferBox:SetMultiLine(true)
  transferBox:SetMaxLetters(60000)
  transferBox:SetAutoFocus(false)
  transferBox:SetFontObject(GameFontHighlightSmall)
  transferBox:SetTextInsets(2, 2, 2, 2)
  NS.UI.Controls:TextColor(transferBox, "text")
  NS.UI.Controls:ConfigureScrollFrame(transferScroll, transferBox, { step = 48 })
  local function ResizeTransferBox()
    transferBox:SetWidth(math.max(1, (transferScroll:GetWidth() or 430) - 4))
    local fontString = transferBox.GetFontString and transferBox:GetFontString()
    local textHeight = fontString and fontString:GetStringHeight() or 1
    transferBox:SetHeight(math.max(1, transferScroll:GetHeight() or 1, textHeight + 14))
  end
  transferScroll:HookScript("OnSizeChanged", ResizeTransferBox)
  transferBox:SetScript("OnTextChanged", ResizeTransferBox)
  transferBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    transfer:Hide()
  end)
  transfer:SetScript("OnHide", function() transferBox:ClearFocus() end)
  local transferImport = NS.UI.Controls:CreateButton(transfer, "Import", 82, 24)
  transferImport:SetPoint("BOTTOMLEFT", 14, 14)
  local transferNative = NS.UI.Controls:CreateButton(transfer, "HomeDecor", 92, 24)
  transferNative:SetPoint("BOTTOMLEFT", 14, 14)
  local transferCompatible = NS.UI.Controls:CreateButton(transfer, "HDG / WoWDB", 106, 24)
  transferCompatible:SetPoint("LEFT", transferNative, "RIGHT", 6, 0)
  local transferSelect = NS.UI.Controls:CreateButton(transfer, "Select All", 82, 24)
  transferSelect:SetPoint("LEFT", transferCompatible, "RIGHT", 6, 0)
  local transferClose = NS.UI.Controls:CreateButton(transfer, "Close", 68, 24)
  transferClose:SetPoint("BOTTOMRIGHT", -14, 14)
  local function SetExportFormat(compatible)
    local textValue, err = NS.Systems.Lists:Export(nil, compatible)
    transferBox:SetText(textValue or "")
    local hint = compatible and "Compatible with Housing Decor Guide, housing.wowdb.com, and BlueprintBazaar." or "Full HomeDecor format with item, decor, source, quantity, and list details."
    if compatible and NS.Systems.Lists:Count() > 500 then hint = hint .. " HDG will read only the first 500 entries." end
    transferHint:SetText(textValue and hint or tostring(err))
    NS.UI.Controls:SetButtonSelected(transferNative, not compatible)
    NS.UI.Controls:SetButtonSelected(transferCompatible, compatible)
    ResizeTransferBox()
    NS.UI.Controls:ResetScrollFrame(transferScroll, false)
    transferBox:SetFocus()
    transferBox:HighlightText()
  end
  local function OpenTransfer(mode)
    local exporting = mode == "export"
    transferTitle:SetText(exporting and "Export Shopping List" or "Import Shopping List")
    transferImport:SetShown(not exporting)
    transferNative:SetShown(exporting)
    transferCompatible:SetShown(exporting)
    transferSelect:ClearAllPoints()
    if exporting then
      transferSelect:SetPoint("LEFT", transferCompatible, "RIGHT", 6, 0)
      SetExportFormat(false)
    else
      transferSelect:SetPoint("LEFT", transferImport, "RIGHT", 6, 0)
      transferHint:SetText("Paste a HomeDecor, Housing Decor Guide, housing.wowdb.com, or BlueprintBazaar list code.")
      transferBox:SetText("")
      ResizeTransferBox()
      NS.UI.Controls:ResetScrollFrame(transferScroll, false)
    end
    transfer:Show()
    transfer:Raise()
    transferBox:SetFocus()
    if exporting then transferBox:HighlightText() end
  end
  transferNative:SetScript("OnClick", function() SetExportFormat(false) end)
  transferCompatible:SetScript("OnClick", function() SetExportFormat(true) end)
  transferSelect:SetScript("OnClick", function()
    transferBox:SetFocus()
    transferBox:HighlightText()
  end)
  transferClose:SetScript("OnClick", function() transfer:Hide() end)
  transferImport:SetScript("OnClick", function()
    local result, err = NS.Systems.Lists:Import(transferBox:GetText())
    if not result then
      transferHint:SetText(tostring(err))
      return
    end
    transfer:Hide()
    frame.viewSignature = nil
    TrackerPanel:Refresh(true)
    if DEFAULT_CHAT_FRAME then
      local message = "Imported " .. tostring(result.count) .. " decor item"
      if result.count ~= 1 then message = message .. "s" end
      message = message .. " (" .. tostring(result.total) .. " total) into \"" .. tostring(result.entry.name) .. "\"."
      if result.unresolved > 0 then message = message .. " " .. tostring(result.unresolved) .. " could not be matched." end
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99HomeDecor:|r " .. message)
    end
  end)
  importButton:SetScript("OnClick", function() OpenTransfer("import") end)
  exportButton:SetScript("OnClick", function() OpenTransfer("export") end)
  frame.listTransfer = transfer
  local blueprintBar = CreateFrame("Frame", nil, frame)
  blueprintBar:SetPoint("TOPLEFT", 12, -86)
  blueprintBar:SetPoint("TOPRIGHT", -28, -86)
  blueprintBar:SetHeight(22)
  local blueprintSelector = NS.UI.Controls:CreateButton(blueprintBar, "", 130, 22)
  blueprintSelector:SetPoint("LEFT")
  blueprintSelector:SetScript("OnClick", function(self)
    local active = NS.Systems.BlueprintList:GetActive()
    local options = {}
    for _, category in ipairs(NS.Systems.BlueprintList:GetCategories()) do options[#options + 1] = { value = category.name, label = category.name } end
    NS.UI.Dropdown:Show(self, options, active and active.name, function(value)
      NS.Systems.BlueprintList:SetActive(value)
      TrackerPanel:Refresh(true)
    end)
  end)
  local blueprintRename = NS.UI.Controls:CreateButton(blueprintBar, "Rename", 54, 22)
  blueprintRename:SetPoint("LEFT", blueprintSelector, "RIGHT", 4, 0)
  local blueprintClear = NS.UI.Controls:CreateButton(blueprintBar, "Clear", 50, 22)
  blueprintClear:SetPoint("LEFT", blueprintRename, "RIGHT", 4, 0)
  blueprintClear:SetScript("OnClick", function()
    NS.Systems.BlueprintList:DeleteActive()
    TrackerPanel:Refresh(true)
  end)
  local blueprintOpen = NS.UI.Controls:CreateButton(blueprintBar, "Plan", 50, 22)
  blueprintOpen:SetPoint("LEFT", blueprintClear, "RIGHT", 4, 0)
  blueprintOpen:SetScript("OnClick", function()
    local category = NS.Systems.BlueprintList:GetActive()
    local layout = category and (NS.Systems.Architect:FindLayoutByID(category.layoutID) or NS.Systems.Architect:FindLayoutByName(category.name))
    if layout then
      NS.Systems.Architect:SetActiveLayout(layout.id)
      NS.UI.CatalogView:Open("architect")
    end
  end)
  local blueprintName = CreateFrame("EditBox", nil, blueprintBar, "BackdropTemplate")
  blueprintName:SetPoint("LEFT")
  blueprintName:SetPoint("RIGHT", blueprintClear, "LEFT", -4, 0)
  blueprintName:SetHeight(22)
  blueprintName:SetAutoFocus(false)
  blueprintName:SetTextInsets(8, 8, 0, 0)
  blueprintName:SetFontObject(GameFontHighlightSmall)
  NS.UI.Controls:Backdrop(blueprintName, NS.UI.Controls.colors.panel)
  blueprintName:Hide()
  blueprintRename:SetScript("OnClick", function()
    local active = NS.Systems.BlueprintList:GetActive()
    if not active then return end
    blueprintSelector:Hide()
    blueprintRename:Hide()
    blueprintName:SetText(active.name)
    blueprintName:Show()
    blueprintName:SetFocus()
    blueprintName:HighlightText()
  end)
  blueprintName:SetScript("OnEnterPressed", function(self)
    NS.Systems.BlueprintList:RenameActive(self:GetText())
    self:ClearFocus()
    TrackerPanel:Refresh(false)
  end)
  blueprintName:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    TrackerPanel:Refresh(false)
  end)
  blueprintName:SetScript("OnEditFocusLost", function(self)
    if not self:IsShown() then return end
    self:Hide()
    blueprintSelector:Show()
    blueprintRename:Show()
  end)
  frame.blueprintOpen = blueprintOpen
  frame.blueprintBar = blueprintBar
  frame.blueprintName = blueprintName
  frame.blueprintSelector = blueprintSelector
  frame.blueprintRename = blueprintRename
  frame.blueprintClear = blueprintClear
  local scroll = NS.UI.Controls:CreateScrollFrame(frame)
  scroll:SetPoint("TOPLEFT", 12, -94)
  scroll:SetPoint("BOTTOMRIGHT", -28, 12)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(300)
  content:SetHeight(1)
  NS.UI.Controls:ConfigureScrollFrame(scroll, content, { step = ROW_HEIGHT, forwardContent = false, onScroll = function() TrackerPanel:RenderRows() end })
  frame.scroll = scroll
  frame.content = content
  frame.rows = {}
  frame.openAreaSources = {}
  frame.openListGroups = {}
  frame.areaGroups = {}
  frame.areaGroupPool = {}
  frame.areaItemRanks = {}
  frame.viewModel = {}
  local function OnTrackerMouseWheel(_, delta)
    local current = scroll:GetVerticalScroll() or 0
    local offset = NS.UI.Controls:SetScrollOffset(scroll, current - (tonumber(delta) or 0) * ROW_HEIGHT, false)
    if offset ~= current then TrackerPanel:RenderRows() end
  end
  scroll:SetScript("OnMouseWheel", OnTrackerMouseWheel)
  content:SetScript("OnMouseWheel", OnTrackerMouseWheel)
  for index = 1, ROW_COUNT do
    local row = self:CreateRow(content, OnTrackerMouseWheel)
    row:Hide()
    frame.rows[index] = row
  end
  frame:SetScript("OnShow", function()
    if NS.UI.CatalogView and NS.UI.CatalogView.frame then NS.UI.Controls:SetButtonSelected(NS.UI.CatalogView.frame.trackerButton, true) end
    TrackerPanel:ApplyAppearance()
    TrackerPanel:Refresh(true)
  end)
  frame:SetScript("OnHide", function()
    NS.UI.Controls:CloseTransientPopups()
    transfer:Hide()
    if NS.UI.CatalogView and NS.UI.CatalogView.frame then NS.UI.Controls:SetButtonSelected(NS.UI.CatalogView.frame.trackerButton, false) end
    for index = 1, #frame.rows do
      frame.rows[index].record = nil
      frame.rows[index]:Hide()
    end
  end)
  frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.empty:SetPoint("CENTER", frame.scroll)
  frame.empty:SetText("Nothing is saved in this tracker view yet.")
  NS.UI.Controls:TextColor(frame.empty, "muted")
  local grip = NS.UI.Controls:CreateResizeGrip(frame, 18)
  grip:SetPoint("BOTTOMRIGHT", -1, 1)
  frame.resizeGrip = grip
  NS.UI.Controls:MakeResizable(frame, grip, {
    key = "trackerSize",
    minWidth = 350,
    minHeight = 300,
    maxWidth = 700,
    maxHeight = 850,
    onChanged = function()
      content:SetWidth(math.max(1, scroll:GetWidth() - 10))
      NS.UI.Controls:SetScrollOffset(scroll, scroll:GetVerticalScroll() or 0, false)
      if TrackerPanel.frame then TrackerPanel:RenderRows() end
    end,
  })
  NS.UI.Controls:MakeMinimizable(frame, minimize, {
    key = "trackerMinimized",
    height = 28,
    regions = { frame.count, frame.tabs[1], frame.tabs[2], frame.tabs[3], frame.tabs[4], search, areaBar, listBar, blueprintBar, scroll, frame.empty, grip },
    onChanged = function(minimized) grip:SetShown(not minimized) end,
  })
  frame:HookScript("OnSizeChanged", function()
    if not frame._hdMinimized then
      content:SetWidth(math.max(1, scroll:GetWidth() - 10))
      NS.UI.Controls:SetScrollOffset(scroll, scroll:GetVerticalScroll() or 0, false)
    end
  end)
  content:SetWidth(math.max(1, scroll:GetWidth() - 10))
  NS.Systems.BlueprintList:RegisterListener(self, function()
    if frame:IsShown() and GetTab() == "blueprints" then RequestRefresh() end
  end)
  NS.Systems.ItemResolver:Subscribe(self, function()
    if frame:IsShown() then RequestRefresh() end
  end)
  self.frame = frame
  return frame
end

function TrackerPanel:ApplyAppearance()
  TrackerOptions:Apply(self.frame, function() self:RenderRows() end)
end

function TrackerPanel:RenderRows()
  local frame = self.frame
  if not frame or not frame:IsShown() or type(frame.viewModel) ~= "table" then return end
  local tab = GetTab()
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  local used = 0
  local last = math.min(#frame.viewModel, first + ROW_COUNT)
  for absolute = first + 1, last do
    used = used + 1
    local row = frame.rows[used]
    local record = frame.viewModel[absolute]
    if record.areaHeader or record.listHeader then
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
      row:SetPoint("TOPRIGHT", 0, -((absolute - 1) * ROW_HEIGHT))
      row.record = record
      local focused = record.areaHeader and record.areaKey == frame.focusAreaKey
      local expanded = record.listHeader and frame.openListGroups[record.groupKey] ~= false or record.areaHeader and frame.openAreaSources[record.areaKey]
      local header = focused and NS.UI.Controls.colors.hover or NS.UI.Controls.colors.header
      local accent = NS.UI.Controls.colors.accent
      local border = NS.UI.Controls.colors.border
      row:SetBackdropColor(header[1], header[2], header[3], BackgroundAlpha(header[4], 0))
      row:SetBackdropBorderColor(focused and accent[1] or border[1], focused and accent[2] or border[2], focused and accent[3] or border[3], BackgroundAlpha(focused and 0.9 or 0.55, 0))
      row.icon:ClearAllPoints()
      row.icon:SetPoint("LEFT", 8, 0)
      row.icon:SetSize(22, 22)
      row.icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
      row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
      row.icon:SetAlpha(1 - TransparencyAmount())
      row.check:Hide()
      row.favorite:SetRecord(nil)
      row.favorite:Hide()
      row.remove:Hide()
      row.minus:Hide()
      row.plus:Hide()
      row.quantity:Hide()
      row.title:ClearAllPoints()
      row.title:SetPoint("LEFT", row.icon, "RIGHT", 7, 0)
      row.title:SetPoint("RIGHT", record.listHeader and -132 or -62, 0)
      row.title:SetText((expanded and "-  " or "+  ") .. record.title)
      NS.UI.Controls:TextColor(row.title, "accent")
      if record.listHeader then
        row.headerCount:SetText(tostring(record.total or 0) .. " item" .. ((record.total or 0) == 1 and "" or "s") .. " / " .. tostring(record.quantity or 0) .. " needed")
      else
        row.headerCount:SetText(tostring(record.total or 0) .. ((record.total or 0) == 1 and " item" or " items"))
      end
      NS.UI.Controls:TextColor(row.headerCount, focused and "accent" or "muted")
      row.headerCount:Show()
      row.meta:Hide()
      row:Show()
    else
    local shoppingQuantity = tab == "lists" and NS.Systems.Lists:GetQuantity(record) or nil
    local quantity = tab == "blueprints" and math.max(1, tonumber(record.needed) or 1) or nil
    local have = quantity and math.max(0, tonumber(record.have) or 0) or nil
    if quantity and record.itemID and C_Item and C_Item.GetItemCount then
      local ok, count = pcall(C_Item.GetItemCount, record.itemID, true, false, true, true)
      if ok and tonumber(count) then have = math.max(0, tonumber(count)) end
    end
    local owned = quantity and have >= quantity or nil
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((absolute - 1) * ROW_HEIGHT))
    row.record = record
    local rowColor = NS.UI.Controls.colors.row
    local border = NS.UI.Controls.colors.border
    row:SetBackdropColor(rowColor[1], rowColor[2], rowColor[3], BackgroundAlpha(rowColor[4], 0))
    row:SetBackdropBorderColor(border[1], border[2], border[3], BackgroundAlpha(0.3, 0))
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", tab == "area" and 10 or 7, 0)
    row.icon:SetSize(26, 26)
    row.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    row.icon:SetAlpha(1 - TransparencyAmount())
    row.headerCount:Hide()
    row.title:ClearAllPoints()
    row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -3)
    row.title:SetPoint("TOPRIGHT", tab == "lists" and -112 or -58, -3)
    row.meta:ClearAllPoints()
    row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 3)
    row.meta:SetPoint("BOTTOMRIGHT", tab == "lists" and -112 or -58, 3)
    row.meta:Show()
    local title, icon, displayOwned = NS.Systems.Housing:GetDisplay(record)
    row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    if shoppingQuantity then owned = false elseif quantity then owned = owned == true else owned = displayOwned == true end
    row.check:SetShown(owned)
    row.remove:Show()
    row.minus:SetShown(tab == "lists")
    row.plus:SetShown(tab == "lists")
    row.quantity:SetShown(tab == "lists")
    local shoppingLocked = tab == "lists" and NS.Systems.ShoppingBuyQueue:IsRunning()
    if shoppingQuantity then
      row.quantity:SetText("x" .. tostring(shoppingQuantity))
      row.minus:SetEnabled(not shoppingLocked and shoppingQuantity > 1)
      row.plus:SetEnabled(not shoppingLocked and shoppingQuantity < 9999)
    end
    row.check:SetAlpha(1 - TransparencyAmount())
    row.favorite:SetAlpha(1 - TransparencyAmount())
    row.remove:SetAlpha(1 - TransparencyAmount())
    row.minus:SetAlpha(1 - TransparencyAmount())
    row.plus:SetAlpha(1 - TransparencyAmount())
    row.favorite:EnableMouse(TransparencyAmount() < 0.98)
    row.remove:EnableMouse(TransparencyAmount() < 0.98)
    row.minus:EnableMouse(TransparencyAmount() < 0.98)
    row.plus:EnableMouse(TransparencyAmount() < 0.98)
    row.remove:SetEnabled(not shoppingLocked)
    if tab == "lists" then
      row.favorite:SetRecord(nil)
    else
      row.favorite:SetRecord(record)
    end
    row.remove:SetText(tab == "area" and "+" or "X")
    NS.UI.Controls:SetButtonSelected(row.remove, tab == "area" and NS.Systems.Lists:Contains(record))
    row.title:SetText(title)
    NS.UI.Controls:TextColor(row.title, owned and "muted" or "text")
    local parts = frame.metaParts or {}
    frame.metaParts = parts
    wipe(parts)
    if tab == "area" then parts[#parts + 1] = owned and "Collected" or "Not collected" end
    if record.zone and record.zone ~= "" then parts[#parts + 1] = record.zone end
    if tab ~= "area" and record.sourceType and record.sourceType ~= "" then parts[#parts + 1] = record.sourceType end
    local meta = table.concat(parts, "  -  ")
    local dyeLabel = NS.Systems.Housing:GetDyeableLabel(record)
    if dyeLabel then meta = meta ~= "" and (dyeLabel .. "  -  " .. meta) or dyeLabel end
    if quantity then
      local quantityText = (owned and "Complete " or "Have ") .. tostring(have) .. " / " .. tostring(quantity)
      meta = meta ~= "" and (quantityText .. "  -  " .. meta) or quantityText
    end
    row.meta:SetText(meta)
    row:Show()
    end
  end
  for index = used + 1, #frame.rows do
    local row = frame.rows[index]
    row.record = nil
    row.favorite:SetRecord(nil)
    row:Hide()
  end
end

function TrackerPanel:Refresh(resetScroll)
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  if frame.refreshing then return end
  frame.refreshing = true
  if resetScroll then NS.UI.Controls:ResetScrollFrame(frame.scroll, false) end
  local tab = GetTab()
  local query = FAVORITES_QUERY
  local search = frame.search:GetText()
  query.search = search
  frame.viewModel = frame.viewModel or {}
  local activeList, activeListID = NS.Systems.Lists:GetActive()
  local activeBlueprint = NS.Systems.BlueprintList:GetActive()
  local currentName, currentMapID, currentMaps = CurrentArea()
  local trackCurrentZone = NS.Systems.Settings:GetValue("trackerTrackCurrentZone", true) == true
  if trackCurrentZone or not frame.areaMaps then frame.areaName, frame.areaMapID, frame.areaMaps = currentName, currentMapID, currentMaps end
  local areaName, areaMapID, areaMaps = frame.areaName, frame.areaMapID, frame.areaMaps
  local hideCompleted = NS.Systems.Settings:GetValue("trackerHideCompleted", false) == true
  local signature = table.concat({ tab, search or "", tostring(hideCompleted), tostring(areaMapID or ""), tostring(NS.Systems.Catalog.revision or 0), tostring(NS.Systems.Tracker.revision or 0), tostring(NS.Systems.Favorites.revision or 0), tostring(NS.Systems.Lists.revision or 0), tostring(NS.Systems.BlueprintList.revision or 0), tostring(activeListID or ""), tostring(activeBlueprint and activeBlueprint.name or "") }, "|")
  if frame.viewSignature ~= signature then
    wipe(frame.viewModel)
    if tab == "area" then
      local lowered = tostring(search or ""):lower()
      wipe(frame.areaGroups)
      local groupCount = 0
      for _, record in ipairs(NS.Systems.Catalog.ordered) do
        local mapID = tonumber(record.mapID)
        if mapID and areaMaps[mapID] then
          local sourceID = tonumber(record.sourceID)
          local areaKey = AreaKey(record)
          local group = frame.areaGroups[areaKey]
          if not group then
            groupCount = groupCount + 1
            group = frame.areaGroupPool[groupCount]
            if not group then group = { items = {}, seen = {} } frame.areaGroupPool[groupCount] = group end
            wipe(group.items)
            wipe(group.seen)
            group.areaHeader = true
            group.areaKey = areaKey
            group.sourceID = sourceID
            group.sourceType = record.sourceType
            group.title = record.vendorName
            if type(group.title) ~= "string" or group.title == "" then group.title = sourceID and NS.Systems.NPCNames:Get(sourceID) or nil end
            if type(group.title) ~= "string" or group.title == "" then group.title = record.sourceType == "vendor" and ("Vendor #" .. tostring(sourceID or "Unknown")) or tostring(record.sourceType or "Other Source") end
            group.total = 0
            frame.areaGroups[areaKey] = group
          end
          local recordKey = record.favoriteKey or record.storageKey or record.decorID or record.itemID or record.id or record
          if (not hideCompleted or not IsComplete(record, tab)) and not group.seen[recordKey] and (lowered == "" or group.title:lower():find(lowered, 1, true) or NS.Systems.SearchIndex:Matches(record, lowered)) then
            group.seen[recordKey] = true
            group.items[#group.items + 1] = record
            group.total = group.total + 1
          end
        end
      end
      local ordered = frame.areaGroupOrder or {}
      frame.areaGroupOrder = ordered
      wipe(ordered)
      for _, group in pairs(frame.areaGroups) do if group.total > 0 then ordered[#ordered + 1] = group end end
      table.sort(ordered, function(left, right)
        local leftFocused = left.areaKey == frame.focusAreaKey
        local rightFocused = right.areaKey == frame.focusAreaKey
        if leftFocused ~= rightFocused then return leftFocused end
        return left.title < right.title
      end)
      frame.areaItemTotal = 0
      for _, group in ipairs(ordered) do
        frame.viewModel[#frame.viewModel + 1] = group
        frame.areaItemTotal = frame.areaItemTotal + group.total
        if frame.openAreaSources[group.areaKey] then
          local ranks = frame.areaItemRanks[group.areaKey]
          if not ranks then ranks = {} frame.areaItemRanks[group.areaKey] = ranks end
          local ranked = next(ranks) ~= nil
          local nextRank = 1
          for _, rank in pairs(ranks) do nextRank = math.max(nextRank, rank + 1) end
          table.sort(group.items, function(left, right)
            local leftOwned = NS.Systems.Collection:IsOwned(left)
            local rightOwned = NS.Systems.Collection:IsOwned(right)
            if leftOwned ~= rightOwned then return leftOwned end
            local leftKey = tostring(left.storageKey or left.decorID or left.itemID or left.id or "")
            local rightKey = tostring(right.storageKey or right.decorID or right.itemID or right.id or "")
            if ranked then
              local leftRank = ranks[leftKey] or math.huge
              local rightRank = ranks[rightKey] or math.huge
              if leftRank ~= rightRank then return leftRank < rightRank end
            end
            local leftTitle = NS.Systems.Housing:GetSearchName(left)
            local rightTitle = NS.Systems.Housing:GetSearchName(right)
            if leftTitle ~= rightTitle then return leftTitle < rightTitle end
            return leftKey < rightKey
          end)
          for _, record in ipairs(group.items) do
            local key = tostring(record.storageKey or record.decorID or record.itemID or record.id or "")
            if ranks[key] == nil then ranks[key] = nextRank nextRank = nextRank + 1 end
            frame.viewModel[#frame.viewModel + 1] = record
          end
        end
      end
    elseif tab == "favorites" then
      NS.Systems.Pipeline:ForEach(query, function(record)
        if not hideCompleted or not IsComplete(record, tab) then frame.viewModel[#frame.viewModel + 1] = record end
      end)
    elseif tab == "lists" then
      local lowered = tostring(search or ""):lower()
      local groups = frame.listGroups or {}
      local ordered = frame.listGroupOrder or {}
      frame.listGroups = groups
      frame.listGroupOrder = ordered
      wipe(groups)
      wipe(ordered)
      for key in pairs(activeList and activeList.keys or {}) do
        local record = NS.Systems.Catalog.byID[key]
        if record and NS.Systems.SearchIndex:Matches(record, lowered) then
          local groupKey, title, sortKey = ShoppingGroup(record)
          local group = groups[groupKey]
          if not group then
            group = { listHeader = true, groupKey = groupKey, title = title, sortKey = sortKey, total = 0, quantity = 0, items = {}, navigationRecord = record }
            groups[groupKey] = group
            ordered[#ordered + 1] = group
          end
          group.total = group.total + 1
          group.quantity = group.quantity + NS.Systems.Lists:GetQuantity(record)
          group.items[#group.items + 1] = record
        end
      end
      table.sort(ordered, function(left, right) return left.sortKey < right.sortKey end)
      for _, group in ipairs(ordered) do
        table.sort(group.items, function(left, right) return tostring(left.title or left.name or "") < tostring(right.title or right.name or "") end)
        frame.viewModel[#frame.viewModel + 1] = group
        if frame.openListGroups[group.groupKey] ~= false then
          for _, record in ipairs(group.items) do frame.viewModel[#frame.viewModel + 1] = record end
        end
      end
    elseif tab == "blueprints" then
      local lowered = tostring(search or ""):lower()
      for _, record in ipairs(activeBlueprint and activeBlueprint.items or {}) do
        local name = tostring(record.title or record.name or ""):lower()
        if (not hideCompleted or not IsComplete(record, tab)) and (lowered == "" or name:find(lowered, 1, true)) then frame.viewModel[#frame.viewModel + 1] = record end
      end
    end
    if tab ~= "area" and tab ~= "lists" then table.sort(frame.viewModel, function(left, right) return tostring(left.title or left.name or "") < tostring(right.title or right.name or "") end) end
    frame.viewSignature = signature
  end
  local total = #frame.viewModel
  if tab == "lists" then
    frame.count:SetText(tostring(NS.Systems.Lists:Count()) .. " items / " .. tostring(NS.Systems.Lists:GetTotalQuantity()) .. " needed")
  else
    frame.count:SetText(tostring(tab == "area" and (frame.areaItemTotal or 0) or total) .. " items")
  end
  for index = 1, #frame.tabs do
    local button = frame.tabs[index]
    button:SetEnabled(true)
    NS.UI.Controls:SetButtonSelected(button, button.tab == tab)
  end
  frame.listBar:SetShown(tab == "lists")
  frame.blueprintBar:SetShown(tab == "blueprints")
  frame.areaBar:SetShown(tab == "area")
  frame.trackZone:SetChecked(trackCurrentZone)
  frame.areaLabel:SetText(areaName)
  frame.areaMapID = areaMapID
  frame.scroll:ClearAllPoints()
  frame.scroll:SetPoint("TOPLEFT", 12, tab == "lists" and -160 or (tab == "area" or tab == "blueprints") and -112 or -86)
  frame.scroll:SetPoint("BOTTOMRIGHT", -28, 12)
  local entry = tab == "lists" and activeList or nil
  frame.listName:SetEnabled(entry ~= nil)
  if not frame.listName:IsShown() then
    frame.listSelector:SetText((entry and entry.name or "Select a list") .. "  v")
    frame.listSelector:Show()
    frame.listRename:Show()
  end
  local shoppingLocked = NS.Systems.ShoppingBuyQueue:IsRunning()
  frame.listSelector:SetEnabled(not shoppingLocked)
  frame.listRename:SetEnabled(entry ~= nil and not shoppingLocked)
  frame.listClear:SetEnabled(entry ~= nil and not shoppingLocked)
  frame.listImport:SetEnabled(not shoppingLocked)
  frame.listExport:SetEnabled(entry ~= nil and NS.Systems.Lists:Count() > 0)
  local listMeta = entry and entry.meta or nil
  local sourceParts = {}
  if listMeta and listMeta.source and listMeta.source ~= "" then sourceParts[#sourceParts + 1] = tostring(listMeta.source) end
  if listMeta and listMeta.author and listMeta.author ~= "" then sourceParts[#sourceParts + 1] = tostring(listMeta.author) end
  if listMeta and listMeta.date and listMeta.date ~= "" then sourceParts[#sourceParts + 1] = tostring(listMeta.date) end
  frame.listSource:SetText(#sourceParts > 0 and table.concat(sourceParts, "  -  ") or "HomeDecor shopping list")
  local blueprint = tab == "blueprints" and activeBlueprint or nil
  frame.blueprintName:SetEnabled(blueprint ~= nil)
  if not frame.blueprintName:IsShown() then
    frame.blueprintSelector:SetText((blueprint and blueprint.name or "Select a plan") .. "  v")
    frame.blueprintSelector:Show()
    frame.blueprintRename:Show()
  end
  frame.blueprintRename:SetEnabled(blueprint ~= nil)
  frame.blueprintClear:SetEnabled(blueprint ~= nil)
  frame.blueprintOpen:SetEnabled(blueprint and (NS.Systems.Architect:FindLayoutByID(blueprint.layoutID) or NS.Systems.Architect:FindLayoutByName(blueprint.name)) ~= nil)
  frame.content:SetHeight(math.max(1, total * ROW_HEIGHT))
  frame.empty:SetText(tab == "area" and ("No mapped decor sources found in " .. areaName .. ".") or tab == "lists" and "This shopping list is empty. Add decor or import a list." or tab == "blueprints" and "No plan requirements are being tracked yet." or "No saved decor is being tracked yet.")
  frame.empty:SetShown(total == 0)
  NS.UI.Controls:SetScrollOffset(frame.scroll, frame.scroll:GetVerticalScroll() or 0, false)
  self:RenderRows()
  frame.refreshing = nil
end

function TrackerPanel:Toggle()
  local frame = self:Create()
  NS.UI.Controls:ToggleFrame(frame)
end

function TrackerPanel:OpenArea(record)
  if not record then return end
  SetTab("area")
  local frame = self:Create()
  local areaName, areaMapID, areaMaps = CurrentArea()
  frame.areaName, frame.areaMapID, frame.areaMaps = areaName, areaMapID, areaMaps
  local areaKey = AreaKey(record)
  wipe(frame.openAreaSources)
  frame.focusAreaKey = areaKey
  frame.openAreaSources[areaKey] = true
  if frame.search:GetText() ~= "" then frame.search:SetText("") end
  frame.viewSignature = nil
  frame:Show()
  self:Refresh(true)
  for index = 1, #frame.viewModel do
    local entry = frame.viewModel[index]
    if entry.areaHeader and entry.areaKey == areaKey then
      NS.UI.Controls:SetScrollOffset(frame.scroll, (index - 1) * ROW_HEIGHT, false)
      self:RenderRows()
      break
    end
  end
  frame:Raise()
end

local AreaRefresh = NS.Debounce(0.15, function()
  local frame = TrackerPanel.frame
  if not frame or not frame:IsShown() or GetTab() ~= "area" then return end
  if not NS.Systems.Settings:GetValue("trackerTrackCurrentZone", true) then return end
  local _, mapID = CurrentArea()
  if tonumber(mapID) ~= tonumber(frame.areaMapID) then RequestRefresh() end
end)

NS.SafeRegisterEvent(TrackerPanel, "ZONE_CHANGED_NEW_AREA", AreaRefresh)
NS.SafeRegisterEvent(TrackerPanel, "ZONE_CHANGED", AreaRefresh)
NS.SafeRegisterEvent(TrackerPanel, "ZONE_CHANGED_INDOORS", AreaRefresh)
