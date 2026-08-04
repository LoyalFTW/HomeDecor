local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.Blueprints = NS.UI.Blueprints or {}

local UI = NS.UI.Blueprints
local max = math.max
local format = string.format

local function System()
  return NS.Systems and NS.Systems.Blueprints
end

local function Theme()
  return NS.UI.Theme and NS.UI.Theme.colors or {}
end

local function Ctl()
  return NS.UI.Controls
end

local function Backdrop(frame, bg, border)
  local C = Ctl()
  if C and C.Backdrop then C:Backdrop(frame, bg, border) end
end

local function TextColor(fs, role, alpha)
  local C = Ctl()
  if C and C.TextColor then C:TextColor(fs, role, alpha) end
end

local function Solid(tex, role, alpha)
  local C = Ctl()
  if C and C.SolidColor then C:SolidColor(tex, role, alpha) end
end

local function Hover(btn, normal, hover)
  local C = Ctl()
  if C and C.ApplyHover then C:ApplyHover(btn, normal, hover) end
end

local function FS(parent, template)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
  TextColor(fs, "text")
  return fs
end

local function trim(s)
  if type(s) ~= "string" then return "" end
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function chat(msg)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Blueprints:|r " .. tostring(msg or ""))
  end
end

local function MakeButton(parent, text, width)
  local T = Theme()
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(width or 96, 26)
  Backdrop(b, T.panel or { 0.09, 0.09, 0.11, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })
  Hover(b, T.panel, T.hover)
  if Ctl() and Ctl().SkinButton then Ctl():SkinButton(b, true) end
  b.text = FS(b, "GameFontNormalSmall")
  b.text:SetPoint("CENTER")
  b.text:SetText(text)
  TextColor(b.text, "text")
  return b
end

local function MakeInput(parent)
  local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  edit:SetAutoFocus(false)
  edit:SetHeight(28)
  edit:SetTextInsets(10, 10, 0, 0)
  edit:SetFontObject("GameFontHighlightSmall")
  edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  return edit
end

local function MakeScroll(parent)
  local sf = CreateFrame("ScrollFrame", nil, parent, "ScrollFrameTemplate")
  sf:SetPoint("TOPLEFT")
  sf:SetPoint("BOTTOMRIGHT", -24, 0)
  if Ctl() and Ctl().SkinScrollFrame then Ctl():SkinScrollFrame(sf) end
  local content = CreateFrame("Frame", nil, sf)
  content:SetSize(1, 1)
  sf:SetScrollChild(content)
  sf:SetScript("OnSizeChanged", function(s, w) content:SetWidth(max(1, w)) end)
  return sf, content
end

local function MakeHeader(parent, title, subtitle)
  local T = Theme()
  local hdr = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  hdr:SetPoint("TOPLEFT")
  hdr:SetPoint("TOPRIGHT")
  hdr:SetHeight(58)
  Backdrop(hdr, T.header or { 0.07, 0.07, 0.08, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })

  local titleFS = FS(hdr, "GameFontNormalLarge")
  titleFS:SetPoint("LEFT", 16, 7)
  titleFS:SetText(title)
  TextColor(titleFS, "accent")

  local subFS = FS(hdr, "GameFontHighlightSmall")
  subFS:SetPoint("TOPLEFT", titleFS, "BOTTOMLEFT", 0, -3)
  subFS:SetText(subtitle)
  TextColor(subFS, "textMuted")

  local line = hdr:CreateTexture(nil, "ARTWORK")
  line:SetPoint("BOTTOMLEFT")
  line:SetPoint("BOTTOMRIGHT")
  line:SetHeight(1)
  Solid(line, "accent", 0.35)

  return hdr
end

local function FormatDate(ts)
  ts = tonumber(ts)
  if not ts or ts <= 0 or not date then return "" end
  return date("%Y-%m-%d", ts)
end

local function KindLabel(kind)
  kind = tostring(kind or "")
  if kind == "" then return "Unknown type" end
  return kind:gsub("_", " ")
end

local function AvailabilityText()
  local sys = System()
  if not sys then return "Blueprint support is not loaded." end
  local a = sys:GetAvailability()
  if not a.supported then return "12.1 blueprint APIs are not available on this client yet." end
  local bits = {}
  bits[#bits + 1] = a.import and "Import ready" or "Import locked"
  bits[#bits + 1] = a.export and "Export ready" or "Export locked"
  return table.concat(bits, "  |  ")
end

local function StatusText(rec)
  if not rec then return "No blueprint selected." end
  if rec.status == "checking" then return "Inspecting..." end
  if rec.status == "error" then return "Error: " .. tostring(rec.error or "request failed") end
  if rec.summary then return "Contents cached" end
  return "Saved code"
end

function UI:Create(parent)
  if self.panel then return self.panel end

  local T = Theme()
  local panel = CreateFrame("Frame", "HomeDecorBlueprintsPanel", parent, "BackdropTemplate")
  panel:SetAllPoints()
  self.panel = panel

  local bg = panel:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  Solid(bg, "bg")

  local header = MakeHeader(panel, "Blueprints", "Save official codes, inspect every requirement, and preview the required room set in Architect")

  local body = CreateFrame("Frame", nil, panel)
  body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
  body:SetPoint("BOTTOMRIGHT")

  local left = CreateFrame("Frame", nil, body, "BackdropTemplate")
  left:SetPoint("TOPLEFT", 12, -12)
  left:SetPoint("BOTTOMLEFT", 12, 12)
  left:SetWidth(270)
  Backdrop(left, T.panel or { 0.09, 0.09, 0.11, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })
  panel.left = left

  local right = CreateFrame("Frame", nil, body, "BackdropTemplate")
  right:SetPoint("TOPLEFT", left, "TOPRIGHT", 10, 0)
  right:SetPoint("BOTTOMRIGHT", -12, 12)
  Backdrop(right, T.panel or { 0.09, 0.09, 0.11, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })
  panel.right = right

  local leftTitle = FS(left, "GameFontNormal")
  leftTitle:SetPoint("TOPLEFT", 12, -12)
  leftTitle:SetText("Saved Codes")
  TextColor(leftTitle, "accent")

  local refreshBtn = MakeButton(left, "Refresh", 74)
  refreshBtn:SetPoint("TOPRIGHT", -12, -8)
  refreshBtn:SetScript("OnClick", function()
    local sys = System()
    local ok, err = sys and sys:RequestCollection()
    if not ok and err then chat(err) end
    self:Refresh()
  end)

  local listFrame = CreateFrame("Frame", nil, left)
  listFrame:SetPoint("TOPLEFT", 8, -44)
  listFrame:SetPoint("BOTTOMRIGHT", -6, 120)
  local sf, listContent = MakeScroll(listFrame)
  panel.listScroll = sf
  panel.listContent = listContent
  panel.rows = {}

  local codeLabel = FS(left, "GameFontHighlightSmall")
  codeLabel:SetPoint("BOTTOMLEFT", 12, 86)
  codeLabel:SetText("Import Code")
  TextColor(codeLabel, "textMuted")

  local codeEdit = MakeInput(left)
  codeEdit:SetPoint("TOPLEFT", codeLabel, "BOTTOMLEFT", -4, -4)
  codeEdit:SetPoint("RIGHT", -12, 0)
  panel.codeEdit = codeEdit

  local nameEdit = MakeInput(left)
  nameEdit:SetPoint("TOPLEFT", codeEdit, "BOTTOMLEFT", 0, -8)
  nameEdit:SetPoint("RIGHT", -88, 0)
  nameEdit:SetText("Saved Blueprint")
  panel.nameEdit = nameEdit

  local saveBtn = MakeButton(left, "Save", 70)
  saveBtn:SetPoint("LEFT", nameEdit, "RIGHT", 8, 0)
  saveBtn:SetScript("OnClick", function()
    local sys = System()
    local rec, err = sys and sys:SaveCode(codeEdit:GetText(), nameEdit:GetText())
    if rec then
      local _, previewErr = sys:QueueArchitectPreview(rec.id, false)
      if previewErr then chat(previewErr) end
    elseif err then
      chat(err)
    end
    self:Refresh()
  end)

  local detailTitle = FS(right, "GameFontNormalLarge")
  detailTitle:SetPoint("TOPLEFT", 16, -16)
  detailTitle:SetPoint("RIGHT", -16, 0)
  detailTitle:SetJustifyH("LEFT")
  detailTitle:SetText("No Blueprint Selected")
  TextColor(detailTitle, "accent")
  panel.detailTitle = detailTitle

  local detailStatus = FS(right, "GameFontHighlightSmall")
  detailStatus:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
  detailStatus:SetPoint("RIGHT", -16, 0)
  detailStatus:SetText("")
  TextColor(detailStatus, "textMuted")
  panel.detailStatus = detailStatus

  local divider = right:CreateTexture(nil, "ARTWORK")
  divider:SetPoint("TOPLEFT", 16, -66)
  divider:SetPoint("TOPRIGHT", -16, -66)
  divider:SetHeight(1)
  Solid(divider, "accent", 0.30)

  local stats = {}
  local statLabels = {
    { "type", "Type" },
    { "rooms", "Rooms" },
    { "decor", "Decor" },
    { "missing", "Missing" },
    { "budget", "Budget" },
  }
  for i, info in ipairs(statLabels) do
    local box = CreateFrame("Frame", nil, right, "BackdropTemplate")
    box:SetSize(104, 54)
    box:SetPoint("TOPLEFT", 16 + ((i - 1) * 112), -82)
    Backdrop(box, T.row or { 0.13, 0.13, 0.15, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })

    local label = FS(box, "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", 8, -8)
    label:SetText(info[2])
    TextColor(label, "textMuted")

    local value = FS(box, "GameFontNormal")
    value:SetPoint("BOTTOMLEFT", 8, 9)
    value:SetPoint("RIGHT", -8, 0)
    value:SetJustifyH("LEFT")
    value:SetText("-")
    TextColor(value, "text")
    stats[info[1]] = value
  end
  panel.stats = stats

  local actions = CreateFrame("Frame", nil, right)
  actions:SetPoint("TOPLEFT", 16, -152)
  actions:SetPoint("RIGHT", -16, 0)
  actions:SetHeight(30)
  panel.actions = actions

  local inspectBtn = MakeButton(actions, "Inspect", 86)
  inspectBtn:SetPoint("LEFT")
  inspectBtn:SetScript("OnClick", function()
    local sys = System()
    local rec = sys and sys:GetActive()
    local ok, err = sys and sys:RequestContents(rec and rec.id)
    if not ok and err then chat(err) end
    self:Refresh()
  end)
  panel.inspectBtn = inspectBtn

  local importBtn = MakeButton(actions, "Import", 82)
  importBtn:SetPoint("LEFT", inspectBtn, "RIGHT", 8, 0)
  importBtn:SetScript("OnClick", function()
    local sys = System()
    local rec = sys and sys:GetActive()
    local ok, err = sys and sys:Import(rec and rec.id)
    if not ok and err then chat(err) end
  end)
  panel.importBtn = importBtn

  local architectBtn = MakeButton(actions, "Architect", 92)
  architectBtn:SetPoint("LEFT", importBtn, "RIGHT", 8, 0)
  architectBtn:SetScript("OnClick", function()
    local sys = System()
    local rec = sys and sys:GetActive()
    local layout, err = sys and sys:OpenInArchitect(rec and rec.id)
    if not layout and err then chat(err); return end
    local db = NS.db and NS.db.profile
    if db and db.ui then db.ui.activeCategory = "Architect" end
    if NS.UI and NS.UI.MainFrame and NS.UI.MainFrame.SelectCategory then
      NS.UI.MainFrame.SelectCategory("Architect")
    elseif NS.UI and NS.UI.ArchitectPanel then
      NS.UI.ArchitectPanel:Show()
    end
  end)
  panel.architectBtn = architectBtn

  local linkBtn = MakeButton(actions, "Link", 70)
  linkBtn:SetPoint("LEFT", architectBtn, "RIGHT", 8, 0)
  linkBtn:SetScript("OnClick", function()
    local sys = System()
    local rec = sys and sys:GetActive()
    local link = rec and sys:GetHyperlink(rec.code)
    if link then
      ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
      ChatEdit_InsertLink(link)
    else
      chat("This PTR build did not return a blueprint chat link.")
    end
  end)
  panel.linkBtn = linkBtn

  local deleteBtn = MakeButton(actions, "Delete", 74)
  deleteBtn:SetPoint("RIGHT")
  deleteBtn:SetScript("OnClick", function()
    local sys = System()
    local rec = sys and sys:GetActive()
    local ok, err = sys and sys:Delete(rec and rec.id)
    if not ok and err then chat(err) end
    self:Refresh()
  end)
  panel.deleteBtn = deleteBtn

  local exportTitle = FS(right, "GameFontNormal")
  exportTitle:SetPoint("TOPLEFT", actions, "BOTTOMLEFT", 0, -22)
  exportTitle:SetText("Export Current House")
  TextColor(exportTitle, "accent")

  local exportName = MakeInput(right)
  exportName:SetPoint("TOPLEFT", exportTitle, "BOTTOMLEFT", -4, -8)
  exportName:SetPoint("RIGHT", -16, 0)
  exportName:SetText((System() and System():GetDB() and System():GetDB().exportName) or "HomeDecor Blueprint")
  panel.exportName = exportName

  local exportBtns = CreateFrame("Frame", nil, right)
  exportBtns:SetPoint("TOPLEFT", exportName, "BOTTOMLEFT", 0, -8)
  exportBtns:SetPoint("RIGHT", -16, 0)
  exportBtns:SetHeight(28)
  panel.exportBtns = exportBtns

  local function export(kind)
    local sys = System()
    local db = sys and sys:GetDB()
    if db then db.exportName = exportName:GetText() end
    local ok, err = sys and sys:Export(kind, exportName:GetText())
    if not ok and err then chat(err) end
  end

  local fullBtn = MakeButton(exportBtns, "Full House", 94)
  fullBtn:SetPoint("LEFT")
  fullBtn:SetScript("OnClick", function() export("full") end)
  local interiorBtn = MakeButton(exportBtns, "Interior", 82)
  interiorBtn:SetPoint("LEFT", fullBtn, "RIGHT", 8, 0)
  interiorBtn:SetScript("OnClick", function() export("interior") end)
  local exteriorBtn = MakeButton(exportBtns, "Exterior", 82)
  exteriorBtn:SetPoint("LEFT", interiorBtn, "RIGHT", 8, 0)
  exteriorBtn:SetScript("OnClick", function() export("exterior") end)
  panel.exportButtons = { fullBtn, interiorBtn, exteriorBtn }

  local notes = FS(right, "GameFontHighlightSmall")
  notes:SetPoint("TOPLEFT", exportBtns, "BOTTOMLEFT", 0, -18)
  notes:SetPoint("RIGHT", -16, 0)
  notes:SetJustifyH("LEFT")
  notes:SetText("Counts and missing status come directly from Blizzard for your current house. Architect can preview the required room set; Blizzard does not expose the blueprint's exact room coordinates to addons.")
  notes:SetWordWrap(true)
  TextColor(notes, "textMuted")
  panel.notes = notes

  local reqTitle = FS(right, "GameFontNormal")
  reqTitle:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -18)
  reqTitle:SetText("Blueprint Requirements")
  TextColor(reqTitle, "accent")
  panel.reqTitle = reqTitle

  local reqFrame = CreateFrame("Frame", nil, right, "BackdropTemplate")
  reqFrame:SetPoint("TOPLEFT", reqTitle, "BOTTOMLEFT", 0, -8)
  reqFrame:SetPoint("BOTTOMRIGHT", -16, 16)
  Backdrop(reqFrame, T.row or { 0.13, 0.13, 0.15, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })
  local reqScroll, reqContent = MakeScroll(reqFrame)
  reqScroll:SetPoint("TOPLEFT", 8, -8)
  reqScroll:SetPoint("BOTTOMRIGHT", -22, 8)
  panel.reqScroll = reqScroll
  panel.reqContent = reqContent
  panel.reqRows = {}

  function panel:Refresh()
    UI:Refresh()
  end

  local sys = System()
  if sys then
    sys.OnLibraryChanged = function()
      if panel:IsShown() then UI:Refresh() end
    end
    local db = sys:GetDB()
    if sys:IsClientSupported() and not (db and db.collectionUpdated) then
      sys:RequestCollection()
    end
  end

  self:Refresh()
  return panel
end

function UI:AcquireRow(i)
  local panel = self.panel
  local row = panel.rows[i]
  if row then return row end

  local T = Theme()
  row = CreateFrame("Button", nil, panel.listContent, "BackdropTemplate")
  row:SetHeight(48)
  Backdrop(row, T.row or { 0.13, 0.13, 0.15, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })
  Hover(row, T.row, T.hover)
  if Ctl() and Ctl().SkinButton then Ctl():SkinButton(row, true) end

  row.name = FS(row, "GameFontNormalSmall")
  row.name:SetPoint("TOPLEFT", 10, -8)
  row.name:SetPoint("RIGHT", -8, 0)
  row.name:SetJustifyH("LEFT")
  TextColor(row.name, "text")

  row.meta = FS(row, "GameFontHighlightSmall")
  row.meta:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -4)
  row.meta:SetPoint("RIGHT", -8, 0)
  row.meta:SetJustifyH("LEFT")
  TextColor(row.meta, "textMuted")

  row:SetScript("OnClick", function(self)
    local sys = System()
    if sys and self.rec then sys:SetActive(self.rec.id) end
    UI:Refresh()
  end)

  panel.rows[i] = row
  return row
end

function UI:AcquireReqRow(i)
  local panel = self.panel
  local row = panel.reqRows[i]
  if row then return row end

  row = CreateFrame("Frame", nil, panel.reqContent)
  row:SetHeight(30)

  row.name = FS(row, "GameFontHighlightSmall")
  row.name:SetPoint("LEFT", 8, 0)
  row.name:SetPoint("RIGHT", -156, 0)
  row.name:SetJustifyH("LEFT")
  TextColor(row.name, "text")

  row.count = FS(row, "GameFontHighlightSmall")
  row.count:SetPoint("RIGHT", -78, 0)
  row.count:SetWidth(70)
  row.count:SetJustifyH("RIGHT")
  TextColor(row.count, "textMuted")

  row.state = FS(row, "GameFontHighlightSmall")
  row.state:SetPoint("RIGHT", -8, 0)
  row.state:SetWidth(62)
  row.state:SetJustifyH("RIGHT")
  TextColor(row.state, "textMuted")

  row.line = row:CreateTexture(nil, "ARTWORK")
  row.line:SetPoint("BOTTOMLEFT", 6, 0)
  row.line:SetPoint("BOTTOMRIGHT", -6, 0)
  row.line:SetHeight(1)
  Solid(row.line, "border", 0.45)

  panel.reqRows[i] = row
  return row
end

function UI:Refresh()
  local panel = self.panel
  if not panel then return end
  local sys = System()
  local saved = sys and sys:GetSaved() or {}
  local active = sys and sys:GetActive() or nil

  local width = max(1, (panel.listScroll:GetWidth() or 240) - 4)
  local y = 0
  for i, rec in ipairs(saved) do
    local row = self:AcquireRow(i)
    row.rec = rec
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", panel.listContent, "TOPLEFT", 0, y)
    row:SetWidth(width)
    row:Show()
    row.name:SetText(rec.name or "Saved Blueprint")
    row.meta:SetText((rec.summary and "Inspected" or StatusText(rec)) .. "  |  " .. FormatDate(rec.updated or rec.created))
    if Ctl() and Ctl().SetSelected then
      Ctl():SetSelected(row, active and rec.id == active.id, Theme().row, Theme().accentSoft or Theme().row)
    end
    y = y - 52
  end
  for i = #saved + 1, #panel.rows do
    panel.rows[i]:Hide()
    panel.rows[i].rec = nil
  end
  panel.listContent:SetHeight(max(1, -y + 8))

  local availability = AvailabilityText()
  if active then
    panel.detailTitle:SetText(active.name or "Saved Blueprint")
    panel.detailStatus:SetText(StatusText(active) .. "  |  " .. availability)
    panel.codeEdit:SetText(active.code or "")
    if not panel.nameEdit:HasFocus() then panel.nameEdit:SetText(active.name or "") end
  else
    panel.detailTitle:SetText("No Blueprint Selected")
    panel.detailStatus:SetText(availability)
  end

  local s = active and active.summary or nil
  panel.stats.type:SetText(KindLabel(s and s.type))
  panel.stats.rooms:SetText(tostring(s and s.rooms or "-"))
  panel.stats.decor:SetText(tostring(s and s.decor or "-"))
  panel.stats.missing:SetText(tostring(s and s.missing or "-"))
  panel.stats.budget:SetText(tostring(s and s.budget or "-"))

  local req = sys and active and sys:GetRequirements(active.id) or nil
  if req and #req.items > 0 then
    panel.reqTitle:SetText(format("Blueprint Requirements  (%d missing)", req.missingQty or 0))
  elseif active and active.contents then
    panel.reqTitle:SetText("Blueprint Requirements  (none)")
  else
    panel.reqTitle:SetText("Blueprint Requirements  (inspect a code first)")
  end

  local reqWidth = max(1, (panel.reqScroll:GetWidth() or 420) - 4)
  local reqY = 0
  local items = req and req.items or {}
  for i, item in ipairs(items) do
    local row = self:AcquireReqRow(i)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", panel.reqContent, "TOPLEFT", 0, reqY)
    row:SetWidth(reqWidth)
    row:Show()
    row.name:SetText((item.kind and (item.kind .. ": ") or "") .. (item.name or "Requirement"))
    row.count:SetText(format("%d / %d", tonumber(item.have) or 0, tonumber(item.needed) or 0))
    if item.invalid then
      row.state:SetText("Invalid")
      TextColor(row.state, "danger")
      TextColor(row.name, "text")
    elseif (tonumber(item.missing) or 0) > 0 then
      row.state:SetText("Missing")
      TextColor(row.state, "danger")
      TextColor(row.name, "text")
    else
      row.state:SetText("Owned")
      TextColor(row.state, "success")
      TextColor(row.name, "textMuted")
    end
    reqY = reqY - 30
  end
  for i = #items + 1, #panel.reqRows do
    panel.reqRows[i]:Hide()
  end
  panel.reqContent:SetHeight(max(1, -reqY + 8))

  local a = sys and sys:GetAvailability() or {}
  local hasActive = active ~= nil
  panel.inspectBtn:SetEnabled(hasActive and a.supported)
  panel.importBtn:SetEnabled(hasActive and a.import)
  panel.linkBtn:SetEnabled(hasActive and a.supported)
  panel.deleteBtn:SetEnabled(hasActive)
  panel.architectBtn:SetEnabled(hasActive and active.summary and active.summary.hasArchitectRooms)
  for _, btn in ipairs(panel.exportButtons or {}) do
    btn:SetEnabled(a.export)
  end
end

return UI
