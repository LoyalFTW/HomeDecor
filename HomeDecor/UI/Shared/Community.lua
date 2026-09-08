local _, NS = ...

NS.UI = NS.UI or {}
local Community = {}
NS.UI.Community = Community

local links = {
  { title = "Join our Discord community", url = "https://discord.gg/G2gCV9Zc57" },
  { title = "Support development (Buy Me a Coffee)", url = "https://buymeacoffee.com/azroaddons" },
  { title = "Donate via PayPal", url = "https://www.paypal.com/donate/?business=Jhookftw1@hotmail.com" },
  { title = "Share HomeDecor", url = "https://www.curseforge.com/wow/addons/home-decor" },
}

local function Font(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
  NS.UI.Controls:TextColor(text, role or "text")
  return text
end

local function CreateLink(frame, info, index)
  local controls = NS.UI.Controls
  local y = -72 - ((index - 1) * 62)
  local title = Font(frame, "GameFontNormal", "text")
  title:SetPoint("TOPLEFT", 18, y)
  title:SetText(info.title)
  local edit = controls:CreateReadOnlyEditBox(frame, info.url)
  edit:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  edit:SetPoint("RIGHT", frame, "RIGHT", -18, 0)
  edit:SetScript("OnEscapePressed", function() frame:Hide() end)
  edit:SetScript("OnEnterPressed", function() frame:Hide() end)
  return edit
end

function Community:Create()
  if self.frame then return self.frame end
  local controls = NS.UI.Controls
  local frame = controls:CreateDialog("HomeDecorCommunityDialog", "Community", 560, 360, "community")
  frame.links = {}
  for index, info in ipairs(links) do frame.links[index] = CreateLink(frame, info, index) end
  local hint = Font(frame, "GameFontNormalSmall", "muted")
  hint:SetPoint("BOTTOMLEFT", 18, 14)
  hint:SetText("Click a link, then press Ctrl+C to copy it.")
  frame:SetScript("OnShow", function()
    if frame.anchor then controls:SetButtonSelected(frame.anchor, true) end
  end)
  frame:SetScript("OnHide", function()
    if frame.anchor then controls:SetButtonSelected(frame.anchor, false) end
    frame.anchor = nil
  end)
  self.frame = frame
  return frame
end

function Community:Show(anchor)
  local frame = self:Create()
  frame.anchor = anchor
  NS.UI.Controls:SetTransientAnchor(frame, anchor)
  frame:Show()
end

function Community:Hide()
  if self.frame then self.frame:Hide() end
end

function Community:Toggle(anchor)
  local frame = self:Create()
  if frame:IsShown() then frame:Hide() else self:Show(anchor) end
end

return Community
