local _, NS = ...

NS.UI = NS.UI or {}
local WhatsNew = {}
NS.UI.WhatsNew = WhatsNew

local function Font(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
  NS.UI.Controls:TextColor(text, role or "text")
  return text
end

function WhatsNew:BuildContent(frame)
  if frame.contentBuilt then return end
  local content = frame.content
  local width = math.max(500, frame.scroll:GetWidth() - 4)
  content:SetWidth(width)
  local text = Font(content, "GameFontHighlight", "text")
  text:SetPoint("TOPLEFT", 12, -12)
  text:SetWidth(width - 26)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("TOP")
  text:SetWordWrap(true)
  text:SetText(NS.Systems.Changelog:GetText())
  content:SetHeight(math.max(1, text:GetStringHeight() + 24))
  frame.contentBuilt = true
end

function WhatsNew:Create()
  if self.frame then return self.frame end
  local controls = NS.UI.Controls
  local frame = controls:CreateDialog("HomeDecorWhatsNewDialog", "What's New", 680, 520, "whatsNew")
  local subtitle = Font(frame, "GameFontNormalSmall", "muted")
  subtitle:SetPoint("TOPLEFT", 20, -65)
  subtitle:SetText("Release notes from the HomeDecor changelog")
  local current = Font(frame, "GameFontNormalSmall", "accent")
  current:SetPoint("TOPRIGHT", -20, -65)
  current:SetText("Current: " .. NS.Systems.Changelog:GetCurrentVersion())
  frame.scroll = controls:CreateScrollFrame(frame)
  frame.scroll:SetPoint("TOPLEFT", 15, -86)
  frame.scroll:SetPoint("BOTTOMRIGHT", -31, 49)
  frame.content = CreateFrame("Frame", nil, frame.scroll)
  frame.content:SetSize(620, 1)
  controls:ConfigureScrollFrame(frame.scroll, frame.content, { step = 44 })
  frame.autoOpen = controls:CreateCheckButton(frame, "Automatically show major updates")
  frame.autoOpen:SetPoint("BOTTOMLEFT", 17, 13)
  frame.autoOpen:SetScript("OnClick", function(self) NS.Systems.Changelog:SetAutoOpen(self:GetChecked()) end)
  local close = controls:CreateButton(frame, "Got It", 90, 27)
  close:SetPoint("BOTTOMRIGHT", -16, 11)
  close:SetScript("OnClick", function() frame:Hide() end)
  frame:SetScript("OnShow", function()
    WhatsNew:BuildContent(frame)
    frame.autoOpen:SetChecked(NS.Systems.Changelog:IsAutoOpenEnabled())
    controls:ResetScrollFrame(frame.scroll, false)
    if frame.anchor then controls:SetButtonSelected(frame.anchor, true) end
  end)
  frame:SetScript("OnHide", function()
    NS.Systems.Changelog:MarkSeen()
    if frame.anchor then controls:SetButtonSelected(frame.anchor, false) end
    frame.anchor = nil
  end)
  self.frame = frame
  return frame
end

function WhatsNew:Show(anchor)
  local frame = self:Create()
  frame.anchor = anchor
  NS.UI.Controls:SetTransientAnchor(frame, anchor)
  frame:Show()
end

function WhatsNew:Hide()
  if self.frame then self.frame:Hide() end
end

function WhatsNew:Toggle(anchor)
  local frame = self:Create()
  if frame:IsShown() then frame:Hide() else self:Show(anchor) end
end

return WhatsNew
