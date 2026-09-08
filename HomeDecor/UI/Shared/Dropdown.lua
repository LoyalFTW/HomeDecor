local _, NS = ...

NS.UI = NS.UI or {}
local Dropdown = {}
NS.UI.Dropdown = Dropdown

local ROW_HEIGHT = 24
local ROW_POOL = 15
local MAX_HEIGHT = 296
local MAX_WIDTH = 380
local VISIBLE_ROWS = 12

local function optionValue(option)
  return type(option) == "table" and option.value or option
end

local function optionLabel(option)
  if type(option) ~= "table" then return tostring(option) end
  return tostring(option.title or option.label or option.text or option.value or "")
end

function Dropdown:Hide()
  if self.frame then self.frame:Hide() end
end

function Dropdown:CreateRow(index)
  local frame = self.frame
  local row = NS.UI.Controls:CreateButton(frame, "", 130, ROW_HEIGHT)
  row:EnableMouse(true)
  row:RegisterForClicks("LeftButtonUp")
  row:SetFrameLevel(frame:GetFrameLevel() + 2)
  row.separator = row:CreateTexture(nil, "ARTWORK")
  row.separator:SetPoint("LEFT", 8, 0)
  row.separator:SetPoint("RIGHT", -8, 0)
  row.separator:SetHeight(1)
  local border = NS.UI.Controls.colors.border
  row.separator:SetColorTexture(border[1], border[2], border[3], 0.9)
  row.separator:Hide()
  row:SetScript("OnClick", function(self)
    if self.disabled then return end
    local callback = frame.callback
    local value = self.value
    Dropdown:Hide()
    if callback then callback(value) end
  end)
  row:SetScript("OnMouseWheel", function(_, delta) Dropdown:Scroll(delta) end)
  row:EnableMouseWheel(true)
  frame.rows[index] = row
  return row
end

function Dropdown:Render()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local values = frame.values or {}
  local first = math.max(1, tonumber(frame.first) or 1)
  local visible = math.max(1, tonumber(frame.visibleRows) or VISIBLE_ROWS)
  for rowIndex, row in ipairs(frame.rows) do
    local optionIndex = first + rowIndex - 1
    local option = rowIndex <= visible and values[optionIndex] or nil
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 4, -4 - ((rowIndex - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", -4, -4 - ((rowIndex - 1) * ROW_HEIGHT))
    row:SetShown(option ~= nil)
    if option ~= nil then
      local separator = type(option) == "table" and option.separator == true
      local title = type(option) == "table" and option.title
      local value = optionValue(option)
      local disabled = separator or title ~= nil or (type(option) == "table" and option.disabled == true)
      row.value = value
      row.disabled = disabled
      row:SetText(separator and "" or tostring(title or optionLabel(option)))
      row:SetEnabled(not disabled)
      row.separator:SetShown(separator)
      row:SetBackdropColor(0, 0, 0, separator and 0 or 0.01)
      row:SetBackdropBorderColor(0, 0, 0, 0)
      local font = row:GetFontString()
      if font then
        font:ClearAllPoints()
        font:SetJustifyH(title and "LEFT" or "CENTER")
        font:SetPoint(title and "LEFT" or "CENTER", title and 8 or 0, 0)
        NS.UI.Controls:TextColor(font, title and "accent" or "text", title and 0.9 or 1)
      end
      NS.UI.Controls:SetButtonSelected(row, not disabled and value == frame.selected)
    else
      row.value = nil
      row.separator:Hide()
    end
  end
end

function Dropdown:Scroll(delta)
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local count = #(frame.values or {})
  local visible = math.min(tonumber(frame.visibleRows) or VISIBLE_ROWS, count)
  local maximum = math.max(1, count - visible + 1)
  frame.first = math.max(1, math.min(maximum, (tonumber(frame.first) or 1) - (tonumber(delta) or 0)))
  self:Render()
end

function Dropdown:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorDropdown", UIParent, "BackdropTemplate")
  frame:SetFrameStrata("TOOLTIP")
  frame:SetFrameLevel(500)
  frame:SetToplevel(true)
  frame:EnableMouse(true)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.header)
  frame:EnableMouseWheel(true)
  frame:SetScript("OnMouseWheel", function(_, delta) Dropdown:Scroll(delta) end)
  frame.rows = {}
  frame.measure = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.measure:Hide()
  frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.empty:SetPoint("CENTER")
  frame.empty:SetText("No options")
  NS.UI.Controls:TextColor(frame.empty, "muted")
  frame:HookScript("OnHide", function(self)
    self.callback = nil
    self.values = nil
    self._hdTransientAnchor = nil
  end)
  NS.UI.Controls:RegisterTransientPopup(frame)
  frame:Hide()
  self.frame = frame
  for index = 1, ROW_POOL do self:CreateRow(index) end
  return frame
end

function Dropdown:Show(anchor, values, selected, callback)
  if not anchor then return end
  local frame = self:Create()
  if frame:IsShown() and frame._hdTransientAnchor == anchor then self:Hide() return end
  values = type(values) == "table" and values or {}
  frame.values = values
  frame.selected = selected
  frame.callback = callback
  frame.first = 1
  NS.UI.Controls:SetTransientAnchor(frame, anchor)

  local count = #values
  local widest = math.max(130, anchor:GetWidth() or 0)
  for index = 1, count do
    local option = values[index]
    frame.measure:SetText(optionLabel(option))
    widest = math.max(widest, (frame.measure:GetStringWidth() or 0) + 28)
  end

  local desiredHeight = math.max(32, math.min(count, VISIBLE_ROWS) * ROW_HEIGHT + 8)
  local screenHeight = UIParent:GetHeight() or 768
  local below = anchor:GetBottom() or screenHeight
  local above = screenHeight - (anchor:GetTop() or 0)
  local openAbove = below < math.min(desiredHeight, 120) and above > below
  local available = math.max(56, (openAbove and above or below) - 8)
  local height = math.min(desiredHeight, MAX_HEIGHT, available)
  frame.visibleRows = math.max(1, math.min(VISIBLE_ROWS, math.floor((height - 8) / ROW_HEIGHT)))
  local scrollable = count > frame.visibleRows
  local width = math.min(MAX_WIDTH, widest + (scrollable and 18 or 0))

  frame:SetSize(width, height)
  frame:ClearAllPoints()
  if openAbove then
    frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 2)
  else
    frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
  end
  frame.empty:SetShown(count == 0)
  frame:Show()
  self:Render()
end

return Dropdown
