local _, NS = ...

NS.UI = NS.UI or {}
local ListSelector = {}
NS.UI.ListSelector = ListSelector

local ROW_HEIGHT = 25
local ROW_POOL = 12
local MAX_HEIGHT = 320

function ListSelector:CreateRow(index)
  local frame = self.frame
  local row = NS.UI.Controls:CreateButton(frame.content, "", 210, 23)
  row:SetHeight(23)
  row:SetScript("OnClick", function(self)
    if not self.id then return end
    NS.Systems.Lists:SetActive(self.id)
    local callback = frame.callback
    local record = frame.record
    if callback then callback(self.id, record) end
    ListSelector:Render()
  end)
  NS.UI.Controls:ForwardScrollWheel(row, frame.scroll)
  frame.rows[index] = row
  return row
end

function ListSelector:Render()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local store = frame.store
  local first = math.max(1, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT) + 1)
  for rowIndex, row in ipairs(frame.rows) do
    local optionIndex = first + rowIndex - 1
    local id = store and store.order[optionIndex]
    local entry = id and store.entries[id]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((optionIndex - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((optionIndex - 1) * ROW_HEIGHT))
    row.id = id
    row:SetShown(entry ~= nil)
    if entry then row:SetText((frame.record and NS.Systems.Lists:Contains(frame.record, id) and "[x] " or "") .. tostring(entry.name or id)) end
  end
end

function ListSelector:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorListSelector", UIParent, "BackdropTemplate")
  frame:SetSize(270, 120)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(600)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.header)
  local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  heading:SetPoint("TOPLEFT", 12, -10)
  heading:SetText("Decor Lists")
  NS.UI.Controls:TextColor(heading, "accent")
  frame.heading = heading
  local input = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
  input:SetPoint("TOPLEFT", 12, -34)
  input:SetPoint("RIGHT", -78, 0)
  input:SetHeight(24)
  input:SetAutoFocus(false)
  input:SetTextInsets(8, 8, 0, 0)
  input:SetFontObject(GameFontHighlightSmall)
  NS.UI.Controls:Backdrop(input, NS.UI.Controls.colors.background, NS.UI.Controls.colors.border)
  local create = NS.UI.Controls:CreateButton(frame, "Create", 58, 24)
  create:SetPoint("LEFT", input, "RIGHT", 6, 0)
  local close = NS.UI.Controls:CreateCloseButton(frame, function() frame:Hide() end, 24, 22)
  close:SetPoint("TOPRIGHT", -6, -6)
  frame.skip = NS.UI.Controls:CreateButton(frame, "Done", 64, 20)
  frame.skip:SetPoint("TOPRIGHT", close, "TOPLEFT", -4, -1)
  frame.skip:SetScript("OnClick", function() frame:Hide() end)
  frame.skip:Hide()
  frame.scroll = NS.UI.Controls:CreateScrollFrame(frame)
  frame.scroll:SetPoint("TOPLEFT", 10, -64)
  frame.scroll:SetPoint("BOTTOMRIGHT", -26, 8)
  frame.content = CreateFrame("Frame", nil, frame.scroll)
  frame.content:SetSize(220, 1)
  NS.UI.Controls:ConfigureScrollFrame(frame.scroll, frame.content, { step = ROW_HEIGHT, onScroll = function() ListSelector:Render() end })
  frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.empty:SetPoint("CENTER", frame.scroll)
  frame.empty:SetText("No lists yet")
  NS.UI.Controls:TextColor(frame.empty, "muted")
  frame.input = input
  frame.rows = {}
  create:SetScript("OnClick", function()
    local entry, id = NS.Systems.Lists:Create(input:GetText())
    input:SetText("")
    local callback = frame.callback
    local record = frame.record
    if entry and callback then callback(id, record) end
    frame.store = NS.Systems.Lists:GetStore()
    local count = frame.store and #frame.store.order or 0
    frame.content:SetHeight(math.max(1, count * ROW_HEIGHT))
    frame.empty:SetShown(count == 0)
    ListSelector:Render()
  end)
  input:SetScript("OnEnterPressed", function() create:Click() end)
  input:SetScript("OnEscapePressed", function() frame:Hide() end)
  frame:HookScript("OnHide", function(self)
    self.callback = nil
    self.record = nil
    self._hdTransientAnchor = nil
    input:ClearFocus()
  end)
  NS.UI.Controls:RegisterTransientPopup(frame)
  frame:Hide()
  self.frame = frame
  for index = 1, ROW_POOL do self:CreateRow(index) end
  return frame
end

function ListSelector:Show(anchor, record, callback, heading)
  if not anchor then return end
  local frame = self:Create()
  if frame:IsShown() and frame._hdTransientAnchor == anchor then frame:Hide() return end
  frame.record = record
  frame.callback = callback
  frame.heading:SetText(heading or "Decor Lists")
  frame.skip:SetShown(heading ~= nil)
  NS.UI.Controls:SetTransientAnchor(frame, anchor)
  local store = NS.Systems.Lists:GetStore()
  frame.store = store
  local count = store and #store.order or 0

  local desiredHeight = 68 + math.max(1, count) * ROW_HEIGHT
  local screenHeight = UIParent:GetHeight() or 768
  local below = anchor:GetBottom() or screenHeight
  local above = screenHeight - (anchor:GetTop() or 0)
  local openAbove = below < math.min(desiredHeight, 140) and above > below
  local available = math.max(96, (openAbove and above or below) - 8)
  local height = math.min(desiredHeight, MAX_HEIGHT, available)
  local scrollable = desiredHeight > height
  frame:SetHeight(height)
  frame:ClearAllPoints()
  if openAbove then
    frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 2)
  else
    frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
  end
  frame.scroll:ClearAllPoints()
  frame.scroll:SetPoint("TOPLEFT", 10, -64)
  frame.scroll:SetPoint("BOTTOMRIGHT", scrollable and -18 or -10, 8)
  frame.content:SetWidth(math.max(1, frame:GetWidth() - (scrollable and 32 or 20)))
  frame.content:SetHeight(math.max(1, count * ROW_HEIGHT))
  local bar = frame.scroll.ScrollBar or frame.scroll.scrollBar
  if bar then bar:SetShown(scrollable) end
  frame.empty:SetShown(count == 0)
  frame:Show()
  if frame.Raise then frame:Raise() end
  NS.UI.Controls:ResetScrollFrame(frame.scroll, false)
  NS.UI.Controls:SyncScrollFrame(frame.scroll)
  self:Render()
  frame.input:SetFocus()
end

return ListSelector
