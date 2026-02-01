local ADDON, NS = ...
NS.UI = NS.UI or {}
local View = NS.UI.Viewer
local Frames = View.Frames

local function RS()
  return NS.UI and NS.UI.RowStyles
end

function Frames.CreateHeader(content)
  local h = CreateFrame("Button", nil, content, "BackdropTemplate")
  h._kind = "header"
  h:EnableMouse(true)
  h:RegisterForClicks("AnyUp")

  h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  h.text:SetPoint("TOPLEFT", 14, -6)

  h.count = h:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  h.count:SetPoint("TOPRIGHT", -44, -6)

  h.check = h:CreateTexture(nil, "OVERLAY")
  h.check:SetSize(14, 14)
  h.check:SetPoint("TOPRIGHT", -14, -6)
  h.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  h.check:Hide()

  local S = RS()
  if S then S:SkinHeader(h, 0.20) end

  return h
end

function Frames.CreateListRow(content)
  local r = CreateFrame("Frame", nil, content, "BackdropTemplate")
  r._kind = "list"
  r:EnableMouse(true)
  r:SetClipsChildren(true)

  r.accent = r:CreateTexture(nil, "BACKGROUND")
  r.accent:SetPoint("TOPLEFT", 0, 0)
  r.accent:SetPoint("BOTTOMLEFT", 0, 0)
  r.accent:SetWidth(3)

  r.textBg = r:CreateTexture(nil, "BACKGROUND")
  r.textBg:SetPoint("TOPLEFT", 58, -2)
  r.textBg:SetPoint("BOTTOMRIGHT", -2, 2)

  r.iconBG = CreateFrame("Frame", nil, r, "BackdropTemplate")
  r.iconBG:SetSize(44, 44)
  r.iconBG:SetPoint("LEFT", 10, 0)

  r.icon = r.iconBG:CreateTexture(nil, "ARTWORK")
  r.icon:SetPoint("TOPLEFT", 4, -4)
  r.icon:SetPoint("BOTTOMRIGHT", -4, 4)
  r.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

  r.checkFrame = CreateFrame("Frame", nil, r.iconBG)
  r.checkFrame:SetAllPoints(r.iconBG)
  r.checkFrame:SetFrameLevel(r.iconBG:GetFrameLevel() + 10)

  r.check = r.checkFrame:CreateTexture(nil, "OVERLAY")
  r.check:SetSize(22, 22)
  r.check:SetPoint("CENTER", r.icon, "CENTER", 0, 0)
  r.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  r.check:Hide()

  r.text = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  r.text:SetPoint("TOPLEFT", 64, -6)
  r.text:SetJustifyH("LEFT")
  r.text:SetWordWrap(false)
  r.text:SetMaxLines(1)

  r.meta = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.meta:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, -2)
  r.meta:SetJustifyH("LEFT")
  r.meta:SetWordWrap(false)
  r.meta:SetMaxLines(1)
  r.meta:Hide()

  r.div = r:CreateTexture(nil, "BORDER")
  r.div:Hide()

  r.req = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  r.req:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, -2)
  r.req:SetJustifyH("LEFT")
  r.req:SetWordWrap(false)
  r.req:SetMaxLines(1)
  r.req:Hide()

  r.rep = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  r.rep:SetPoint("TOPLEFT", r.req, "BOTTOMLEFT", 0, -1)
  r.rep:SetJustifyH("LEFT")
  r.rep:SetWordWrap(false)
  r.rep:SetMaxLines(1)
  r.rep:Hide()

  r.reqBtn = CreateFrame("Button", nil, r)
  r.reqBtn:Hide()
  r.reqBtn:EnableMouse(true)
  r.reqBtn:RegisterForClicks("AnyUp")

  local S = RS()
  if S then S:SkinListRow(r, 0.16) end

  return r
end

function Frames.CreateTile(content)
  local r = CreateFrame("Frame", nil, content, "BackdropTemplate")
  r._kind = "tile"
  r:EnableMouse(true)
  r:SetClipsChildren(true)

  r.media = CreateFrame("Frame", nil, r, "BackdropTemplate")
  r.media:SetPoint("TOPLEFT", 8, -8)
  r.media:SetPoint("TOPRIGHT", -8, -8)

  r.mediaBg = r.media:CreateTexture(nil, "BACKGROUND")
  r.mediaBg:SetAllPoints()

  r.textBg = r:CreateTexture(nil, "BACKGROUND")
  r.textBg:Hide()

  r.icon = r.media:CreateTexture(nil, "ARTWORK")
  r.icon:SetPoint("CENTER", 0, 0)

  r.checkFrame = CreateFrame("Frame", nil, r.media)
  r.checkFrame:SetAllPoints(r.media)
  r.checkFrame:SetFrameLevel(r.media:GetFrameLevel() + 10)

  r.check = r.checkFrame:CreateTexture(nil, "OVERLAY")
  r.check:SetSize(22, 22)
  r.check:SetPoint("CENTER", r.icon, "CENTER", 0, 0)
  r.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  r.check:Hide()

  r.div = r:CreateTexture(nil, "BORDER")

  r.textArea = CreateFrame("Frame", nil, r)
  r.textArea:SetClipsChildren(true)
  r.textArea:SetPoint("TOPLEFT", r.media, "BOTTOMLEFT", 0, -8)
  r.textArea:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", -6, 8)

  r.label = r.textArea:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  r.label:SetJustifyH("LEFT")
  r.label:SetWordWrap(true)
  r.label:SetMaxLines(2)

  r.note = r.textArea:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.note:SetJustifyH("LEFT")
  r.note:SetWordWrap(true)
  r.note:SetMaxLines(2)
  r.note:SetText("")
  r.note:Hide()

  r.titleDiv = r.textArea:CreateTexture(nil, "BORDER")
  r.titleDiv:Hide()

  r.meta = r.textArea:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.meta:SetJustifyH("LEFT")
  r.meta:SetWordWrap(false)
  r.meta:SetMaxLines(1)
  r.meta:Hide()

  r.timer = r.textArea:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.timer:SetJustifyH("RIGHT")
  r.timer:SetWordWrap(false)
  r.timer:SetMaxLines(1)
  r.timer:Hide()

  r.req = r.textArea:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  r.req:SetJustifyH("LEFT")
  r.req:SetWordWrap(false)
  r.req:SetMaxLines(1)
  r.req:SetText("")
  r.req:Hide()

  r.rep = r.textArea:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  r.rep:SetJustifyH("LEFT")
  r.rep:SetWordWrap(false)
  r.rep:SetMaxLines(1)
  r.rep:SetText("")
  r.rep:Hide()

  r.reqBtn = CreateFrame("Button", nil, r)
  r.reqBtn:Hide()
  r.reqBtn:EnableMouse(true)
  r.reqBtn:RegisterForClicks("AnyUp")

  local S = RS()
  if S then S:SkinTile(r, 0.16) end

  return r
end

return Frames
