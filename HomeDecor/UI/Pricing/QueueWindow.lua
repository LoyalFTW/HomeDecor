local _, NS = ...

NS.UI = NS.UI or {}
local QueueWindow = {}
NS.UI.QueueWindow = QueueWindow

local ROW_HEIGHT = 62
local ROW_COUNT = 6

local function Controls()
  return NS.UI.Controls
end

local function Font(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  Controls():TextColor(text, role or "text")
  return text
end

local function Button(parent, label, width, height)
  return Controls():CreateButton(parent, label, width, height)
end

local function Backdrop(frame, background, border)
  Controls():Backdrop(frame, background, border)
end

local function FormatMoney(value)
  local source = NS.Systems.PriceSource
  return source and source.FormatGold and source.FormatGold(value) or tostring(value or 0)
end

local function ItemIcon(itemID)
  return NS.Systems.ItemResolver:GetIcon(itemID)
end

function QueueWindow:NotifyChanged()
  local pricing = NS.UI.DecorPricing
  if pricing then
    pricing:UpdateQueueButton()
    pricing:UpdateMetrics()
    pricing:UpdateInspector()
    pricing:Render()
  end
end

function QueueWindow:ShowExport(formatName)
  local frame = self:Create()
  frame.exportTitle:SetText(formatName .. " Shopping List")
  frame.exportEdit:SetText(NS.Systems.CraftingQueue:GenerateText(formatName))
  frame.exportPopup:Show()
  frame.exportEdit:SetFocus()
  frame.exportEdit:HighlightText()
end

function QueueWindow:Render()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local items = self.items or {}
  frame.content:SetHeight(math.max(1, #items * ROW_HEIGHT))
  local maximum = math.max(0, frame.content:GetHeight() - frame.scroll:GetHeight())
  if frame.scroll:GetVerticalScroll() > maximum then Controls():SetScrollOffset(frame.scroll, maximum, false) end
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  for rowIndex, row in ipairs(frame.rows) do
    local absolute = first + rowIndex
    local item = items[absolute]
    row.item = item
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetPoint("RIGHT", -2, 0)
    row:SetShown(item ~= nil)
    if item then
      row.icon:SetTexture(ItemIcon(item.itemID))
      row.name:SetText(item.name)
      row.meta:SetText((item.profession or "Recipe") .. "  |  Profit " .. FormatMoney((item.profit or 0) * item.quantity))
      row.quantity:SetText(tostring(item.quantity))
    end
  end
  frame.empty:SetShown(#items == 0)
end

function QueueWindow:Refresh()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local queue = NS.Systems.CraftingQueue
  local items = queue:GetItems()
  self.items = items
  frame.count:SetText(tostring(queue:GetSize()))
  local materials = queue:GetMaterialRows()
  local lines = {}
  for _, material in ipairs(materials) do
    lines[#lines + 1] = tostring(material.quantity) .. "x " .. material.name .. "    " .. (material.total and FormatMoney(material.total) or "No price")
  end
  frame.materials:SetText(#lines > 0 and table.concat(lines, "\n") or "(empty queue)")
  frame.materialContent:SetHeight(math.max(1, frame.materials:GetStringHeight() + 8))
  local profit, cost, missing = queue:GetTotals()
  frame.profit:SetText(FormatMoney(profit))
  frame.cost:SetText(FormatMoney(cost))
  frame.missing:SetText(missing > 0 and (tostring(missing) .. " material price(s) unavailable") or (tostring(#materials) .. " unique materials"))
  Controls():TextColor(frame.missing, missing > 0 and "danger" or "success")
  self:Render()
end

function QueueWindow:Create()
  if self.frame then return self.frame end
  local colors = Controls().colors
  local frame = CreateFrame("Frame", "HomeDecorQueueWindow", UIParent, "BackdropTemplate")
  frame:SetSize(430, 570)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(120)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  Backdrop(frame, colors.background, colors.border)
  NS.Systems.Layout:Restore(frame, "craftingQueue")
  Controls():MakeMovable(frame, frame, "craftingQueue")

  local title = Font(frame, "GameFontNormalLarge", "accent")
  title:SetPoint("TOPLEFT", 16, -14)
  title:SetText("Crafting Queue")
  frame.count = Font(frame, "GameFontNormal", "accent")
  frame.count:SetPoint("LEFT", title, "RIGHT", 12, 0)
  local close = Controls():CreateCloseButton(frame, function() frame:Hide() end)
  close:SetPoint("TOPRIGHT", -10, -9)
  local clear = Button(frame, "Clear", 70, 26)
  clear:SetPoint("RIGHT", close, "LEFT", -8, 0)
  clear:SetScript("OnClick", function() NS.Systems.CraftingQueue:Clear() QueueWindow:NotifyChanged() QueueWindow:Refresh() end)

  local listPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  listPanel:SetPoint("TOPLEFT", 12, -48)
  listPanel:SetPoint("TOPRIGHT", -12, -48)
  listPanel:SetHeight(292)
  Backdrop(listPanel, colors.header, colors.border)
  frame.scroll = Controls():CreateScrollFrame(listPanel)
  frame.scroll:SetPoint("TOPLEFT", 6, -6)
  frame.scroll:SetPoint("BOTTOMRIGHT", -22, 6)
  frame.content = CreateFrame("Frame", nil, frame.scroll)
  frame.content:SetSize(370, 1)
  Controls():ConfigureScrollFrame(frame.scroll, frame.content, { step = ROW_HEIGHT, onScroll = function() QueueWindow:Render() end })
  frame.rows = {}
  for index = 1, ROW_COUNT do
    local row = CreateFrame("Frame", nil, frame.content, "BackdropTemplate")
    row:SetHeight(ROW_HEIGHT - 3)
    Backdrop(row, colors.row, colors.border)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(38, 38)
    row.icon:SetPoint("LEFT", 8, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    row.name = Font(row, "GameFontNormal", "text")
    row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -3)
    row.name:SetPoint("RIGHT", -116, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.meta = Font(row, "GameFontNormalSmall", "muted")
    row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 3)
    row.minus = Button(row, "-", 25, 24)
    row.minus:SetPoint("RIGHT", -108, 0)
    row.quantity = Font(row, "GameFontNormal", "accent")
    row.quantity:SetPoint("LEFT", row.minus, "RIGHT", 5, 0)
    row.quantity:SetWidth(24)
    row.quantity:SetJustifyH("CENTER")
    row.plus = Button(row, "+", 25, 24)
    row.plus:SetPoint("LEFT", row.quantity, "RIGHT", 5, 0)
    row.remove = Button(row, "X", 24, 24)
    row.remove:SetPoint("RIGHT", -4, 0)
    row.minus:SetScript("OnClick", function(self)
      local item = self:GetParent().item
      if item then NS.Systems.CraftingQueue:SetQuantity(item.itemID, item.quantity - 1) QueueWindow:NotifyChanged() QueueWindow:Refresh() end
    end)
    row.plus:SetScript("OnClick", function(self)
      local item = self:GetParent().item
      if item then NS.Systems.CraftingQueue:SetQuantity(item.itemID, item.quantity + 1) QueueWindow:NotifyChanged() QueueWindow:Refresh() end
    end)
    row.remove:SetScript("OnClick", function(self)
      local item = self:GetParent().item
      if item then NS.Systems.CraftingQueue:SetQuantity(item.itemID, 0) QueueWindow:NotifyChanged() QueueWindow:Refresh() end
    end)
    Controls():ForwardScrollWheel(row, frame.scroll)
    frame.rows[index] = row
  end
  frame.empty = Font(listPanel, "GameFontHighlight", "muted")
  frame.empty:SetPoint("CENTER")
  frame.empty:SetText("Add recipes from the pricing list to build a crafting queue.")
  frame.empty:SetWidth(330)
  frame.empty:SetJustifyH("CENTER")

  local summary = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  summary:SetPoint("TOPLEFT", listPanel, "BOTTOMLEFT", 0, -10)
  summary:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 48)
  Backdrop(summary, colors.header, colors.border)
  local summaryTitle = Font(summary, "GameFontNormal", "accent")
  summaryTitle:SetPoint("TOPLEFT", 10, -10)
  summaryTitle:SetText("Materials Summary")
  frame.missing = Font(summary, "GameFontNormalSmall", "muted")
  frame.missing:SetPoint("TOPRIGHT", -10, -11)
  local stats = Font(summary, "GameFontNormalSmall", "muted")
  stats:SetPoint("TOPLEFT", 10, -32)
  stats:SetText("Estimated profit\nMaterial cost")
  stats:SetSpacing(5)
  frame.profit = Font(summary, "GameFontNormalSmall", "success")
  frame.profit:SetPoint("TOPRIGHT", -10, -32)
  frame.cost = Font(summary, "GameFontNormalSmall", "text")
  frame.cost:SetPoint("TOPRIGHT", -10, -51)
  frame.materialScroll = Controls():CreateScrollFrame(summary)
  frame.materialScroll:SetPoint("TOPLEFT", 8, -76)
  frame.materialScroll:SetPoint("BOTTOMRIGHT", -22, 8)
  frame.materialContent = CreateFrame("Frame", nil, frame.materialScroll)
  frame.materialContent:SetSize(350, 1)
  Controls():ConfigureScrollFrame(frame.materialScroll, frame.materialContent, { step = 48 })
  frame.materials = Font(frame.materialContent, "GameFontNormalSmall", "text")
  frame.materials:SetPoint("TOPLEFT", 2, -2)
  frame.materials:SetPoint("RIGHT", -2, 0)
  frame.materials:SetJustifyH("LEFT")

  local auctionator = Button(frame, "Auctionator", 108, 28)
  auctionator:SetPoint("BOTTOMLEFT", 12, 11)
  auctionator:SetScript("OnClick", function()
    local ok, message = NS.Systems.CraftingQueue:CreateAuctionatorList()
    frame.status:SetText(message)
    Controls():TextColor(frame.status, ok and "success" or "danger")
  end)
  local tsm = Button(frame, "TSM", 82, 28)
  tsm:SetPoint("LEFT", auctionator, "RIGHT", 7, 0)
  tsm:SetScript("OnClick", function() QueueWindow:ShowExport("TSM") end)
  local export = Button(frame, "Export List", 104, 28)
  export:SetPoint("BOTTOMRIGHT", -12, 11)
  export:SetScript("OnClick", function() QueueWindow:ShowExport("Text") end)
  frame.status = Font(frame, "GameFontNormalSmall", "muted")
  frame.status:SetPoint("LEFT", tsm, "RIGHT", 7, 0)
  frame.status:SetPoint("RIGHT", export, "LEFT", -7, 0)
  frame.status:SetJustifyH("CENTER")

  frame.exportPopup = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.exportPopup:SetPoint("TOPLEFT", 18, -56)
  frame.exportPopup:SetPoint("BOTTOMRIGHT", -18, 56)
  frame.exportPopup:SetFrameLevel(frame:GetFrameLevel() + 20)
  Backdrop(frame.exportPopup, colors.panel, colors.border)
  frame.exportTitle = Font(frame.exportPopup, "GameFontNormalLarge", "accent")
  frame.exportTitle:SetPoint("TOPLEFT", 12, -12)
  local exportClose = Button(frame.exportPopup, "Close", 70, 25)
  exportClose:SetPoint("TOPRIGHT", -10, -9)
  exportClose:SetScript("OnClick", function() frame.exportPopup:Hide() end)
  frame.exportEdit = CreateFrame("EditBox", nil, frame.exportPopup, "BackdropTemplate")
  frame.exportEdit:SetPoint("TOPLEFT", 12, -48)
  frame.exportEdit:SetPoint("BOTTOMRIGHT", -12, 12)
  frame.exportEdit:SetMultiLine(true)
  frame.exportEdit:SetAutoFocus(false)
  frame.exportEdit:SetFontObject(GameFontHighlightSmall)
  frame.exportEdit:SetTextInsets(8, 8, 8, 8)
  Backdrop(frame.exportEdit, colors.background, colors.border)
  frame.exportEdit:SetScript("OnEscapePressed", function() frame.exportPopup:Hide() end)
  frame.exportPopup:Hide()

  frame:SetScript("OnShow", function() QueueWindow:Refresh() if NS.UI.DecorPricing then NS.UI.DecorPricing:UpdateQueueButton() end end)
  frame:SetScript("OnHide", function() frame.exportPopup:Hide() if NS.UI.DecorPricing then NS.UI.DecorPricing:UpdateQueueButton() end end)
  self.frame = frame
  frame:Hide()
  return frame
end

function QueueWindow:Toggle()
  local frame = self:Create()
  Controls():ToggleFrame(frame, function() self:Refresh() end)
end

NS.Systems.ItemResolver:Subscribe(QueueWindow, function()
  if QueueWindow.frame and QueueWindow.frame:IsShown() then QueueWindow:Refresh() end
end)

return QueueWindow
