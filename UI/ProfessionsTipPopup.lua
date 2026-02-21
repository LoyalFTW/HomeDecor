local ADDON, NS = ...

local C = NS.UI and NS.UI.Controls
local T = NS.UI and NS.UI.Theme and NS.UI.Theme.colors
local L = NS.L
if not C or not T then return end

local Popup

local function CreatePopup()
  if Popup then return Popup end

  local p = CreateFrame("Frame", "HomeDecorProfessionsTipPopup", UIParent, "BackdropTemplate")
  Popup = p

  p:SetSize(460, 160)
  p:SetPoint("CENTER")
  p:SetFrameStrata("FULLSCREEN_DIALOG")
  p:SetFrameLevel(9999)
  p:SetToplevel(true)
  p:SetClampedToScreen(true)

  C:Backdrop(p, T.panel, T.border)

  p:EnableMouse(true)
  p:SetMovable(true)
  p:RegisterForDrag("LeftButton")
  p:SetScript("OnDragStart", p.StartMoving)
  p:SetScript("OnDragStop", p.StopMovingOrSizing)

  local header = CreateFrame("Frame", nil, p, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 6, -6)
  header:SetPoint("TOPRIGHT", -6, -6)
  header:SetHeight(36)
  C:Backdrop(header, T.header, T.border)

  header.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  header.title:SetPoint("CENTER")
  header.title:SetText(L["PROF_TIP_TITLE"])
  header.title:SetTextColor(unpack(T.accent))

  local body = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  body:SetPoint("TOPLEFT", 20, -58)
  body:SetPoint("TOPRIGHT", -20, -58)
  body:SetJustifyH("CENTER")
  body:SetJustifyV("TOP")
  body:SetWordWrap(true)
  body:SetText(L["PROF_TIP_MESSAGE"])

  local okBtn = CreateFrame("Button", nil, p, "BackdropTemplate")
  C:Backdrop(okBtn, T.panel, T.border)
  okBtn:SetSize(80, 26)
  okBtn:SetPoint("BOTTOM", 0, 14)
  C:ApplyHover(okBtn, T.panel, T.hover)

  okBtn.text = okBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  okBtn.text:SetPoint("CENTER")
  okBtn.text:SetText(L["PROF_TIP_OK"])

  okBtn:SetScript("OnClick", function()
    if NS.db and NS.db.global then NS.db.global.seenProfTip = true end
    p:Hide()
  end)

  p:SetPropagateKeyboardInput(true)
  p:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
      if NS.db and NS.db.global then NS.db.global.seenProfTip = true end
      self:Hide()
      self:SetPropagateKeyboardInput(false)
    end
  end)

  p:Hide()
  return p
end

function NS.UI:ShowProfessionsTipPopup()
  if NS.db and NS.db.global and NS.db.global.seenProfTip then return end
  CreatePopup():Show()
end
