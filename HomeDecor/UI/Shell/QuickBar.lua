local _, NS = ...

NS.UI = NS.UI or {}
local QuickBar = {}
NS.UI.QuickBar = QuickBar

local SLOTS = 8
local PAGES = 9
local DEFAULT_KEYS = { "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8" }
local savedModeBarPoints
local editorSessionSeconds = 0
local editorTotalSeconds = 0

local function Store()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.quickBar = profile.quickBar or { page = 1, pages = {} }
  profile.quickBar.pages = profile.quickBar.pages or {}
  profile.quickBar.keybinds = profile.quickBar.keybinds or {}
  return profile.quickBar
end

local function KeyForSlot(slot)
  local store = Store()
  local key = store and store.keybinds and store.keybinds[slot]
  if key == nil then return DEFAULT_KEYS[slot] end
  return key
end

local function IsEditorActive()
  if _G.HouseEditorFrame and _G.HouseEditorFrame:IsShown() then return true end
  return _G.C_HouseEditor and _G.C_HouseEditor.IsHouseEditorActive and _G.C_HouseEditor.IsHouseEditorActive() or false
end

local function GetHeldDecor()
  local api = _G.C_HousingDecor
  local info = api and api.GetSelectedDecorInfo and api.GetSelectedDecorInfo()
  if not info and _G.C_HousingBasicMode and _G.C_HousingBasicMode.GetSelectedDecorInfo then info = _G.C_HousingBasicMode.GetSelectedDecorInfo() end
  if not info and _G.C_HousingExpertMode and _G.C_HousingExpertMode.GetSelectedDecorInfo then info = _G.C_HousingExpertMode.GetSelectedDecorInfo() end
  return info and info.decorID or nil
end

local function CancelHeldDecor()
  if _G.C_HousingBasicMode and _G.C_HousingBasicMode.CancelActiveEditing then pcall(_G.C_HousingBasicMode.CancelActiveEditing) end
  if _G.C_HousingExpertMode and _G.C_HousingExpertMode.CancelActiveEditing then pcall(_G.C_HousingExpertMode.CancelActiveEditing) end
end

local function PlaceDecor(recordID)
  if not IsEditorActive() or not recordID then return false end
  local info = NS.Systems.Housing:GetEntry({ decorID = recordID })
  if not info or not info.entryID then return false end
  local quantity = (info.quantity or 0) + (info.remainingRedeemable or 0)
  if quantity <= 0 then return false end
  if _G.C_HousingBasicMode and _G.C_HousingBasicMode.StartPlacingNewDecor then
    local ok = pcall(_G.C_HousingBasicMode.StartPlacingNewDecor, info.entryID)
    if ok then QuickBar.lastPlaced = recordID end
    return ok
  end
  return false
end

local function GetQuantity(recordID)
  local info = recordID and NS.Systems.Housing:GetEntry({ decorID = recordID })
  return info and ((info.quantity or 0) + (info.remainingRedeemable or 0)) or 0
end

local function SetAtlas(texture, atlas)
  if texture and texture.SetAtlas then pcall(texture.SetAtlas, texture, atlas) end
end

local function SavePoints(frame)
  local points = {}
  for index = 1, frame:GetNumPoints() do
    local point, relative, relativePoint, x, y = frame:GetPoint(index)
    points[index] = { point, relative, relativePoint, x, y }
  end
  return points
end

local function RestorePoints(frame, points)
  if not frame or not points then return end
  frame:ClearAllPoints()
  for _, point in ipairs(points) do frame:SetPoint(unpack(point)) end
end

local function FormatDuration(seconds)
  seconds = math.max(0, math.floor(tonumber(seconds) or 0))
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  if hours > 0 then return string.format("%d:%02d:%02d", hours, minutes, secs) end
  return string.format("%02d:%02d", minutes, secs)
end

local function GetClockText()
  local source = NS.Systems.Settings:GetValue("editorClockSource", "auto")
  local format = NS.Systems.Settings:GetValue("editorClockFormat", "auto")
  local useLocal = source == "local" or (source == "auto" and _G.C_CVar and _G.C_CVar.GetCVarBool and _G.C_CVar.GetCVarBool("timeMgrUseLocalTime"))
  local use24 = format == "24" or (format == "auto" and _G.C_CVar and _G.C_CVar.GetCVarBool and _G.C_CVar.GetCVarBool("timeMgrUseMilitaryTime"))
  local hour, minute
  if useLocal then
    hour = tonumber(date("%H")) or 0
    minute = tonumber(date("%M")) or 0
  else
    hour, minute = GetGameTime()
  end
  if use24 then return string.format("%02d:%02d", hour, minute) end
  local suffix = hour >= 12 and "PM" or "AM"
  hour = hour % 12
  if hour == 0 then hour = 12 end
  return string.format("%d:%02d %s", hour, minute, suffix)
end

function QuickBar:GetPage()
  local store = Store()
  return store and store.page or 1
end

function QuickBar:GetSlot(slot)
  local store = Store()
  if not store then return nil end
  local page = store.pages[store.page]
  return page and page[slot] or nil
end

function QuickBar:SetSlot(slot, recordID)
  local store = Store()
  if not store then return end
  local page = store.pages[store.page] or {}
  store.pages[store.page] = page
  page[slot] = recordID
  self:Refresh()
end

function QuickBar:SetPage(page)
  local store = Store()
  if not store then return end
  store.page = math.max(1, math.min(PAGES, page))
  self:Refresh()
end

function QuickBar:GetRecent()
  local store = Store()
  return store and store.recent or nil
end

function QuickBar:OnPlacementSuccess()
  local store = Store()
  if not store or not self.lastPlaced then return end
  store.recent = self.lastPlaced
  self.lastPlaced = nil
  self:Refresh()
end

function QuickBar:ActivateSlot(slot)
  if not IsEditorActive() then return end
  local recordID = self:GetSlot(slot)
  if recordID then
    PlaceDecor(recordID)
    return
  end
  local held = GetHeldDecor()
  if held then
    self:SetSlot(slot, held)
    CancelHeldDecor()
  end
end

function QuickBar:EnableKeys()
  if not IsEditorActive() or (_G.InCombatLockdown and _G.InCombatLockdown()) then return end
  local focus = _G.GetCurrentKeyBoardFocus and _G.GetCurrentKeyBoardFocus()
  if focus and focus.GetObjectType and focus:GetObjectType() == "EditBox" then
    self:DisableKeys()
    return
  end
  if not self.keyOwner then
    self.keyOwner = CreateFrame("Frame", "HomeDecorQuickBarKeyOwner", UIParent)
    self.keyButtons = {}
    for slot = 1, SLOTS do
      local button = CreateFrame("Button", "HomeDecorQuickBarKey" .. tostring(slot), self.keyOwner, "SecureActionButtonTemplate")
      button.slot = slot
      button:SetScript("OnClick", function(self) QuickBar:ActivateSlot(self.slot) end)
      self.keyButtons[slot] = button
    end
  end
  pcall(_G.ClearOverrideBindings, self.keyOwner)
  for slot = 1, SLOTS do
    local key = KeyForSlot(slot)
    if key and key ~= "" then pcall(_G.SetOverrideBindingClick, self.keyOwner, false, key, self.keyButtons[slot]:GetName()) end
  end
end

function QuickBar:DisableKeys()
  if self.keyOwner then pcall(_G.ClearOverrideBindings, self.keyOwner) end
end

function QuickBar:CreateButton(parent, slot)
  local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
  button:SetSize(72, 72)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  NS.UI.Controls:Backdrop(button, NS.UI.Controls.colors.row, NS.UI.Controls.colors.border)
  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetPoint("TOPLEFT", 5, -5)
  button.icon:SetPoint("BOTTOMRIGHT", -5, 5)
  button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  button.empty = button:CreateTexture(nil, "BACKGROUND")
  button.empty:SetPoint("TOPLEFT", 5, -5)
  button.empty:SetPoint("BOTTOMRIGHT", -5, 5)
  button.empty:SetColorTexture(0.08, 0.08, 0.07, 0.8)
  SetAtlas(button.empty, "ui-hud-minimap-housing-indoor-static-bg")
  button.empty:SetAlpha(0.5)
  button.key = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  button.key:SetPoint("TOPRIGHT", -4, -4)
  button.key:SetText(slot > 0 and KeyForSlot(slot) or "")
  NS.UI.Controls:TextColor(button.key, "muted")
  button.qty = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  button.qty:SetPoint("BOTTOMRIGHT", -4, 4)
  button.slot = slot
  button:SetScript("OnClick", function(self, mouseButton)
    if not IsEditorActive() then return end
    if mouseButton == "RightButton" then
      QuickBar:SetSlot(self.slot, nil)
      return
    end
    QuickBar:ActivateSlot(self.slot)
  end)
  button:SetScript("OnEnter", function(self)
    local recordID = QuickBar:GetSlot(self.slot)
    if not _G.GameTooltip then return end
    _G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
    if recordID then
      local title = NS.Systems.Housing:GetDisplay({ decorID = recordID })
      _G.GameTooltip:SetText(title)
      _G.GameTooltip:AddLine("Left-click: Place decor", 0.8, 0.8, 0.8)
      _G.GameTooltip:AddLine("Right-click: Clear slot", 0.8, 0.8, 0.8)
    else
      _G.GameTooltip:SetText("Empty slot")
      _G.GameTooltip:AddLine("Select decor in the editor, then left-click to assign", 0.8, 0.8, 0.8, true)
    end
    _G.GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  return button
end

function QuickBar:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorQuickBar", UIParent, "BackdropTemplate")
  frame:SetSize(744, 88)
  frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 4)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.background, NS.UI.Controls.colors.border)
  frame.recent = self:CreateButton(frame, 0)
  frame.recent:SetPoint("LEFT", 10, 0)
  frame.recent.label = frame.recent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.recent.label:SetPoint("TOPLEFT", 4, -4)
  frame.recent.label:SetText("Recent")
  NS.UI.Controls:TextColor(frame.recent.label, "accent")
  frame.recent:SetScript("OnClick", function(_, mouseButton)
    if mouseButton == "RightButton" then
      local store = Store()
      if store then store.recent = nil end
      QuickBar:Refresh()
      return
    end
    PlaceDecor(QuickBar:GetRecent())
  end)
  frame.recent:SetScript("OnEnter", function(self)
    if not _G.GameTooltip then return end
    _G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
    local recordID = QuickBar:GetRecent()
    if recordID then
      local title = NS.Systems.Housing:GetDisplay({ decorID = recordID })
      _G.GameTooltip:SetText("Recent: " .. title)
      _G.GameTooltip:AddLine("Left-click: Place decor", 0.8, 0.8, 0.8)
      _G.GameTooltip:AddLine("Right-click: Clear recent", 0.8, 0.8, 0.8)
    else
      _G.GameTooltip:SetText("Recent placement")
    end
    _G.GameTooltip:Show()
  end)
  local previous = CreateFrame("Button", nil, frame)
  previous:SetSize(22, 20)
  previous:SetPoint("BOTTOMRIGHT", -8, 7)
  previous:SetScript("OnClick", function() QuickBar:SetPage(QuickBar:GetPage() > 1 and QuickBar:GetPage() - 1 or PAGES) end)
  previous.texture = previous:CreateTexture(nil, "ARTWORK")
  previous.texture:SetAllPoints()
  SetAtlas(previous.texture, "ui-hud-actionbar-pagedownarrow-up")
  local next = CreateFrame("Button", nil, frame)
  next:SetSize(22, 20)
  next:SetPoint("TOPRIGHT", -8, -7)
  next:SetScript("OnClick", function() QuickBar:SetPage(QuickBar:GetPage() < PAGES and QuickBar:GetPage() + 1 or 1) end)
  next.texture = next:CreateTexture(nil, "ARTWORK")
  next.texture:SetAllPoints()
  SetAtlas(next.texture, "ui-hud-actionbar-pageuparrow-up")
  frame.page = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.page:SetPoint("RIGHT", -9, 0)
  frame.page:SetJustifyH("CENTER")
  frame.buttons = {}
  for slot = 1, SLOTS do
    local button = self:CreateButton(frame, slot)
    button:SetPoint("LEFT", 98 + (slot - 1) * 76, 0)
    frame.buttons[slot] = button
  end
  frame:SetScript("OnShow", function()
    QuickBar:Refresh()
    QuickBar:EnableKeys()
  end)
  frame:SetScript("OnHide", function() QuickBar:DisableKeys() end)
  frame:Hide()
  self.frame = frame
  self:CreateEditorHUD()
  self:CreateEditorClock()
  return frame
end

function QuickBar:Refresh()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  frame.page:SetText(tostring(self:GetPage()) .. "\n/\n" .. tostring(PAGES))
  for slot = 1, SLOTS do
    local recordID = self:GetSlot(slot)
    local button = frame.buttons[slot]
    if recordID then
      local _, icon = NS.Systems.Housing:GetDisplay({ decorID = recordID })
      button.icon:SetTexture(icon)
      button.icon:Show()
      button.empty:Hide()
      local quantity = GetQuantity(recordID)
      button.qty:SetText(tostring(quantity))
      button.qty:SetTextColor(quantity > 0 and 1 or 1, quantity > 0 and 1 or 0.3, quantity > 0 and 1 or 0.3)
      button.qty:Show()
      local border = quantity > 0 and NS.UI.Controls.colors.accent or NS.UI.Controls.colors.danger
      button:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
    else
      button.icon:Hide()
      button.empty:Show()
      button.qty:Hide()
      local border = NS.UI.Controls.colors.border
      button:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
    end
  end
  local recent = self:GetRecent()
  if recent then
    local _, icon = NS.Systems.Housing:GetDisplay({ decorID = recent })
    frame.recent.icon:SetTexture(icon)
    frame.recent.icon:Show()
    frame.recent.empty:Hide()
    local quantity = GetQuantity(recent)
    frame.recent.qty:SetText(tostring(quantity))
    frame.recent.qty:SetTextColor(1, quantity > 0 and 1 or 0.3, quantity > 0 and 1 or 0.3)
    frame.recent.qty:Show()
    local border = quantity > 0 and NS.UI.Controls.colors.accent or NS.UI.Controls.colors.danger
    frame.recent:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
  else
    frame.recent.icon:Hide()
    frame.recent.empty:Show()
    frame.recent.qty:Hide()
    local border = NS.UI.Controls.colors.border
    frame.recent:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
  end
end

function QuickBar:CreateEditorHUD()
  if self.hud then return self.hud end
  local basic = _G.HouseEditorFrame and _G.HouseEditorFrame.BasicDecorModeFrame
  local instructions = basic and basic.Instructions
  if not instructions then return nil end
  local root = CreateFrame("Frame", "HomeDecorEditorHints", basic)
  root:SetSize(420, 272)
  root:SetPoint("TOPRIGHT", instructions, "BOTTOMRIGHT", 0, -4)
  local hints = {
    { "Copy", (CTRL_KEY_TEXT or "Ctrl") .. "+C" },
    { "Cut", (CTRL_KEY_TEXT or "Ctrl") .. "+X" },
    { "Paste", (CTRL_KEY_TEXT or "Ctrl") .. "+V" },
    { "Duplicate", (CTRL_KEY_TEXT or "Ctrl") .. "+D" },
    { "Batch Place", CTRL_KEY_TEXT or "Ctrl" },
    { "Lock / Unlock", "L" },
  }
  root.lines = {}
  local previous
  for index, hint in ipairs(hints) do
    local line = CreateFrame("Frame", nil, root)
    line:SetSize(420, 44)
    if previous then
      line:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT")
    else
      line:SetPoint("TOPRIGHT")
    end
    local key = line:CreateTexture(nil, "BACKGROUND")
    SetAtlas(key, "housing-hotkey-icon-key-9slice")
    key:SetSize(math.max(54, 24 + (#hint[2] * 10)), 40)
    key:SetPoint("RIGHT")
    local keyText = line:CreateFontString(nil, "ARTWORK", "Number16Font")
    keyText:SetPoint("CENTER", key)
    keyText:SetText(hint[2])
    local label = line:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    label:SetPoint("RIGHT", key, "LEFT", -10, 0)
    label:SetText(hint[1])
    root.lines[index] = line
    previous = line
  end
  root:Hide()
  self.hud = root
  return root
end

function QuickBar:CreateEditorClock()
  if self.clock then return self.clock end
  local controls = _G.HousingControlsFrame
  local owner = controls and controls.OwnerControlFrame
  if not owner then return nil end
  local anchor = owner.HouseEditorButton or owner
  local clock = CreateFrame("Button", "HomeDecorEditorClock", owner, "BackdropTemplate")
  clock:SetSize(108, 28)
  clock:SetPoint("TOP", anchor, "BOTTOM", 0, -5)
  clock:SetFrameLevel(owner:GetFrameLevel() + 20)
  clock:RegisterForClicks("RightButtonUp")
  NS.UI.Controls:Backdrop(clock, { 0.055, 0.045, 0.035, 0.92 }, { 0.72, 0.52, 0.25, 0.9 })
  clock.icon = clock:CreateTexture(nil, "ARTWORK")
  clock.icon:SetSize(16, 16)
  clock.icon:SetPoint("LEFT", 8, 0)
  clock.icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
  clock.text = clock:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  clock.text:SetPoint("LEFT", clock.icon, "RIGHT", 5, 0)
  clock.text:SetPoint("RIGHT", -7, 0)
  clock.text:SetTextColor(1, 0.86, 0.62)
  clock.showSession = NS.Systems.Settings:GetValue("editorClockDisplay", "clock") == "session"
  clock:SetScript("OnClick", function(self)
    self.showSession = not self.showSession
    NS.Systems.Settings:SetValue("editorClockDisplay", self.showSession and "session" or "clock")
    self.text:SetText(self.showSession and FormatDuration(editorSessionSeconds) or GetClockText())
  end)
  clock:SetScript("OnEnter", function(self)
    if not _G.GameTooltip then return end
    _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    _G.GameTooltip:SetText("Editor Clock & Timer")
    _G.GameTooltip:AddDoubleLine("This session", FormatDuration(editorSessionSeconds), 1, 0.82, 0, 1, 1, 1)
    _G.GameTooltip:AddDoubleLine("All sessions", FormatDuration(editorTotalSeconds), 1, 0.82, 0, 1, 1, 1)
    _G.GameTooltip:AddLine("Right-click to switch clock/timer", 0.75, 0.75, 0.75)
    _G.GameTooltip:Show()
  end)
  clock:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  clock:SetScript("OnUpdate", function(self, elapsed)
    editorSessionSeconds = editorSessionSeconds + elapsed
    editorTotalSeconds = editorTotalSeconds + elapsed
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 1 then return end
    self.elapsed = 0
    self.text:SetText(self.showSession and FormatDuration(editorSessionSeconds) or GetClockText())
    local profile = NS.Systems.Database:GetProfile()
    if profile then profile.editorTimeSeconds = math.floor(editorTotalSeconds) end
  end)
  local profile = NS.Systems.Database:GetProfile()
  editorTotalSeconds = profile and tonumber(profile.editorTimeSeconds) or 0
  clock.text:SetText(clock.showSession and FormatDuration(editorSessionSeconds) or GetClockText())
  clock:Hide()
  self.clock = clock
  return clock
end

function QuickBar:ApplyEditorLayout()
  if not NS.Systems.Settings:GetValue("editorFeatures", true) then return end
  local frame = self.frame
  local modeBar = _G.HouseEditorFrame and _G.HouseEditorFrame.ModeBar
  if frame and not frame:IsShown() and modeBar and savedModeBarPoints then RestorePoints(modeBar, savedModeBarPoints) end
  if frame and frame:IsShown() and modeBar then
    if not savedModeBarPoints then savedModeBarPoints = SavePoints(modeBar) end
    modeBar:ClearAllPoints()
    modeBar:SetPoint("BOTTOM", frame, "TOP", 0, 2)
  end
  local hud = self:CreateEditorHUD()
  if hud then hud:SetShown(NS.Systems.Settings:GetValue("editorHints", true)) end
  local clock = self:CreateEditorClock()
  if clock then
    clock.showSession = NS.Systems.Settings:GetValue("editorClockDisplay", "clock") == "session"
    clock.text:SetText(clock.showSession and FormatDuration(editorSessionSeconds) or GetClockText())
    clock:SetShown(NS.Systems.Settings:GetValue("editorClock", true))
  end
end

function QuickBar:RestoreEditorLayout()
  local modeBar = _G.HouseEditorFrame and _G.HouseEditorFrame.ModeBar
  if modeBar and savedModeBarPoints then RestorePoints(modeBar, savedModeBarPoints) end
  if self.hud then self.hud:Hide() end
  if self.clock then self.clock:Hide() end
  editorSessionSeconds = 0
end

function QuickBar:Toggle()
  local frame = self:Create()
  frame:SetShown(not frame:IsShown())
end

function QuickBar:ResetEditorTime()
  editorSessionSeconds = 0
  editorTotalSeconds = 0
  local profile = NS.Systems.Database:GetProfile()
  if profile then profile.editorTimeSeconds = 0 end
  if self.clock then self.clock.text:SetText(self.clock.showSession and FormatDuration(0) or GetClockText()) end
end

function QuickBar:SetKeybind(slot, key)
  local store = Store()
  if not store or not DEFAULT_KEYS[slot] then return end
  store.keybinds[slot] = key or ""
  if self.frame and self.frame.buttons[slot] then self.frame.buttons[slot].key:SetText(KeyForSlot(slot)) end
  self:DisableKeys()
  self:EnableKeys()
end

function QuickBar:GetKeybind(slot)
  return KeyForSlot(slot)
end

function QuickBar:SyncEditor()
  if NS.Systems.Settings and not NS.Systems.Settings:GetValue("editorFeatures", true) then
    self:RestoreEditorLayout()
    if self.frame then self.frame:Hide() end
  elseif IsEditorActive() then
    local frame = self:Create()
    if _G.HouseEditorFrame then
      frame:SetParent(_G.HouseEditorFrame)
      frame:SetFrameStrata("FULLSCREEN_DIALOG")
      frame:SetFrameLevel(100)
    end
    frame:SetShown(NS.Systems.Settings:Get("quickBar"))
    self:ApplyEditorLayout()
  elseif self.frame then
    self:RestoreEditorLayout()
    self.frame:Hide()
    self.frame:SetParent(UIParent)
  end
  if NS.Systems.EditorTools then NS.Systems.EditorTools:Sync() end
end

function QuickBar:WireEditor()
  local editor = _G.HouseEditorFrame
  if self.editorWired or not editor then return false end
  self.editorWired = true
  editor:HookScript("OnShow", function() QuickBar:SyncEditor() end)
  editor:HookScript("OnHide", function() QuickBar:SyncEditor() end)
  self:SyncEditor()
  return true
end

function QuickBar:BeginEditorWatch()
  if self.editorWired or self.editorWatch then return end
  local watch = CreateFrame("Frame")
  self.editorWatch = watch
  watch:SetScript("OnUpdate", function()
    if QuickBar:WireEditor() then
      watch:SetScript("OnUpdate", nil)
      QuickBar.editorWatch = nil
    end
  end)
end
