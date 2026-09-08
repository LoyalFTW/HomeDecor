local _, NS = ...

NS.UI = NS.UI or {}
local Keybinds = {}
NS.UI.Keybinds = Keybinds

local MODIFIER_KEYS = {
  LALT = true,
  RALT = true,
  LCTRL = true,
  RCTRL = true,
  LSHIFT = true,
  RSHIFT = true,
  LMETA = true,
  RMETA = true,
}

local MOUSE_BUTTON_KEYS = {
  LeftButton = "BUTTON1",
  RightButton = "BUTTON2",
  MiddleButton = "BUTTON3",
}

local function DisplayKey(key)
  if not key or key == "" then return "Not Bound" end
  if GetBindingText then
    local text = GetBindingText(key, "KEY_")
    if text and text ~= "" then return text end
  end
  return key
end

local function BuildKey(key)
  local prefix = ""
  if IsAltKeyDown and IsAltKeyDown() then prefix = prefix .. "ALT-" end
  if IsControlKeyDown and IsControlKeyDown() then prefix = prefix .. "CTRL-" end
  if IsShiftKeyDown and IsShiftKeyDown() then prefix = prefix .. "SHIFT-" end
  if IsMetaKeyDown and IsMetaKeyDown() then prefix = prefix .. "META-" end
  return prefix .. key
end

local function QuickBarConflict(slot, key)
  local quickBar = NS.UI.QuickBar
  if not quickBar then return nil end
  for index = 1, 8 do
    if index ~= slot and quickBar:GetKeybind(index) == key then return index end
  end
end

function Keybinds:Create()
  if self.frame then return self.frame end
  local capture = CreateFrame("Frame", "HomeDecorKeybindCapture", UIParent, "BackdropTemplate")
  capture:SetAllPoints(UIParent)
  capture:SetFrameStrata("FULLSCREEN_DIALOG")
  capture:SetFrameLevel(500)
  capture:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  capture:SetBackdropColor(0, 0, 0, 0.55)
  capture:EnableMouse(true)
  capture:EnableMouseWheel(true)
  capture:EnableKeyboard(false)
  capture:SetPropagateKeyboardInput(true)
  capture:RegisterEvent("PLAYER_REGEN_DISABLED")

  local panel = CreateFrame("Frame", nil, capture, "BackdropTemplate")
  panel:SetSize(360, 176)
  panel:SetPoint("CENTER")
  NS.UI.Controls:Backdrop(panel, NS.UI.Controls.colors.background, NS.UI.Controls.colors.accent)
  panel:EnableMouse(false)

  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -22)
  title:SetText("Set Quick Bar Key")
  NS.UI.Controls:TextColor(title, "accent")

  local prompt = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  prompt:SetPoint("TOPLEFT", 24, -58)
  prompt:SetPoint("TOPRIGHT", -24, -58)
  prompt:SetJustifyH("CENTER")
  prompt:SetWordWrap(true)
  prompt:SetText("Press any key, mouse button, or scroll the mouse wheel. Modifiers may be held.")
  NS.UI.Controls:TextColor(prompt, "text")

  local status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  status:SetPoint("BOTTOMLEFT", 24, 22)
  status:SetPoint("BOTTOMRIGHT", -24, 22)
  status:SetJustifyH("CENTER")
  status:SetWordWrap(true)
  status:SetText("Escape cancels. Backspace clears the binding.")
  NS.UI.Controls:TextColor(status, "muted")

  capture.title = title
  capture.status = status
  capture.pendingKey = nil
  capture.slot = nil

  local function Finish()
    local changed = capture.changed
    capture.changed = nil
    capture.pendingKey = nil
    capture.slot = nil
    capture:Hide()
    if changed then changed() end
  end

  local function Save(key)
    if InCombatLockdown and InCombatLockdown() then
      capture.status:SetText("Quick Bar bindings cannot be changed during combat.")
      NS.UI.Controls:TextColor(capture.status, "danger")
      return
    end
    local conflictSlot = QuickBarConflict(capture.slot, key)
    local action = GetBindingAction and GetBindingAction(key) or ""
    local conflict = conflictSlot and ("Quick Bar Slot " .. tostring(conflictSlot)) or (action ~= "" and (GetBindingName and GetBindingName(action) or action) or nil)
    if conflict and capture.pendingKey ~= key then
      capture.pendingKey = key
      capture.status:SetText(DisplayKey(key) .. " is already assigned to " .. conflict .. ". Press it again to use it for this slot while the editor is open.")
      NS.UI.Controls:TextColor(capture.status, "highlight")
      return
    end
    if conflictSlot and NS.UI.QuickBar then NS.UI.QuickBar:SetKeybind(conflictSlot, "") end
    NS.UI.QuickBar:SetKeybind(capture.slot, key)
    Finish()
  end

  local function Capture(key)
    if key == "ESCAPE" then Finish() return end
    if key == "BACKSPACE" then NS.UI.QuickBar:SetKeybind(capture.slot, "") Finish() return end
    if MODIFIER_KEYS[key] or key == "UNKNOWN" then return end
    Save(BuildKey(key))
  end

  capture:SetScript("OnKeyDown", function(_, key) Capture(key) end)
  capture:SetScript("OnMouseDown", function(_, button)
    local number = button and button:match("^Button(%d+)$")
    Capture(MOUSE_BUTTON_KEYS[button] or (number and ("BUTTON" .. number)) or string.upper(button or "UNKNOWN"))
  end)
  capture:SetScript("OnMouseWheel", function(_, delta) Capture(delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN") end)
  capture:SetScript("OnEvent", function() Finish() end)
  capture:SetScript("OnShow", function()
    capture.pendingKey = nil
    capture.status:SetText("Escape cancels. Backspace clears the binding.")
    NS.UI.Controls:TextColor(capture.status, "muted")
    capture:EnableKeyboard(true)
    capture:EnableMouseWheel(true)
    capture:SetPropagateKeyboardInput(false)
  end)
  capture:SetScript("OnHide", function()
    capture.pendingKey = nil
    capture:EnableKeyboard(false)
    capture:EnableMouseWheel(false)
    capture:SetPropagateKeyboardInput(true)
  end)
  capture:Hide()
  self.frame = capture
  return capture
end

function Keybinds:CaptureQuickBar(slot, changed)
  if InCombatLockdown and InCombatLockdown() then
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffff6060HomeDecor:|r Quick Bar bindings cannot be changed during combat.") end
    return
  end
  local capture = self:Create()
  capture.slot = slot
  capture.changed = changed
  capture.title:SetText("Set Quick Bar Slot " .. tostring(slot))
  capture:Show()
end

function Keybinds:Cancel()
  if self.frame then
    self.frame.changed = nil
    self.frame.pendingKey = nil
    self.frame.slot = nil
    self.frame:Hide()
  end
end
