local _, NS = ...

local EditorTools = {}
NS.Systems.EditorTools = EditorTools

local DEFAULTS = {
  clipboard = true,
  batchPlace = true,
  batchRotate = true,
  batchStep = 15,
  lock = true,
  locks = {},
  keybinds = {
    copy = "CTRL-C",
    cut = "CTRL-X",
    paste = "CTRL-V",
    duplicate = "CTRL-D",
    lock = "L",
  },
}

local clipboard
local keyOwner
local keyButtons
local lastPlacedRecordID
local batchCount = 0
local resettingLock = false
local initialized = false

local function Copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, child in pairs(value) do result[key] = Copy(child) end
  return result
end

local function Merge(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" then
      if type(target[key]) ~= "table" then target[key] = Copy(value) else Merge(target[key], value) end
    elseif target[key] == nil then
      target[key] = value
    end
  end
end

local function Store()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return DEFAULTS end
  if type(profile.editorTools) ~= "table" then profile.editorTools = {} end
  if profile.editorToolsMigrationVersion ~= 1 then
    if type(profile.editMode) == "table" then
      for _, key in ipairs({ "clipboard", "batchPlace", "batchRotate", "batchStep", "lock", "locks", "keybinds" }) do
        if profile.editMode[key] ~= nil then profile.editorTools[key] = Copy(profile.editMode[key]) end
      end
    end
    profile.editorToolsMigrationVersion = 1
  end
  Merge(profile.editorTools, DEFAULTS)
  return profile.editorTools
end

local function Enabled(feature)
  if not NS.Systems.Settings:GetValue("editorFeatures", true) then return false end
  return Store()[feature] ~= false
end

local function SafeValue(fn, ...)
  if type(fn) ~= "function" then return nil end
  local ok, value = pcall(fn, ...)
  return ok and value or nil
end

local function Invoke(fn, ...)
  if type(fn) ~= "function" then return false end
  return pcall(fn, ...)
end

local function IsEditorActive()
  if _G.HouseEditorFrame and _G.HouseEditorFrame:IsShown() then return true end
  return SafeValue(_G.C_HouseEditor and _G.C_HouseEditor.IsHouseEditorActive) == true
end

local function GetMode()
  return SafeValue(_G.C_HouseEditor and _G.C_HouseEditor.GetActiveHouseEditorMode)
end

local function IsBasicMode()
  return GetMode() == (_G.Enum and _G.Enum.HouseEditorMode and _G.Enum.HouseEditorMode.BasicDecor)
end

local function IsHoveringDecor()
  return SafeValue(_G.C_HousingDecor and _G.C_HousingDecor.IsHoveringDecor) == true
end

local function DecorInfo(info)
  if not info or not info.decorID then return nil end
  return { guid = info.decorGUID, recordID = info.decorID, name = info.name }
end

local function GetHoveredInfo()
  if not IsHoveringDecor() then return nil end
  return DecorInfo(SafeValue(_G.C_HousingDecor and _G.C_HousingDecor.GetHoveredDecorInfo))
end

local function GetSelectedInfo()
  local info = SafeValue(_G.C_HousingBasicMode and _G.C_HousingBasicMode.GetSelectedDecorInfo)
  if not info or not info.decorID then info = SafeValue(_G.C_HousingExpertMode and _G.C_HousingExpertMode.GetSelectedDecorInfo) end
  return DecorInfo(info)
end

local function GetTargetInfo()
  return GetHoveredInfo() or GetSelectedInfo()
end

local function CancelEditing()
  Invoke(_G.C_HousingBasicMode and _G.C_HousingBasicMode.CancelActiveEditing)
  Invoke(_G.C_HousingExpertMode and _G.C_HousingExpertMode.CancelActiveEditing)
end

local function BounceMode()
  if not IsEditorActive() then return end
  local current = GetMode()
  local basic = _G.Enum and _G.Enum.HouseEditorMode and _G.Enum.HouseEditorMode.BasicDecor
  local expert = _G.Enum and _G.Enum.HouseEditorMode and _G.Enum.HouseEditorMode.ExpertDecor
  local alternate = current == basic and expert or basic
  local success = _G.Enum and _G.Enum.HousingResult and _G.Enum.HousingResult.Success
  local available = alternate and SafeValue(_G.C_HouseEditor and _G.C_HouseEditor.GetHouseEditorModeAvailability, alternate) == success
  _G.C_Timer.After(0, function()
    if available then
      Invoke(_G.C_HouseEditor and _G.C_HouseEditor.ActivateHouseEditorMode, alternate)
      _G.C_Timer.After(0, function() Invoke(_G.C_HouseEditor and _G.C_HouseEditor.ActivateHouseEditorMode, current) end)
    else
      Invoke(_G.C_HouseEditor and _G.C_HouseEditor.ActivateHouseEditorMode, current)
    end
  end)
end

local function RemoveSelected()
  if SafeValue(_G.C_HousingBasicMode and _G.C_HousingBasicMode.IsDecorSelected) == true then
    return Invoke(_G.C_HousingBasicMode.RemoveSelectedDecor)
  end
  if SafeValue(_G.C_HousingExpertMode and _G.C_HousingExpertMode.IsDecorSelected) == true then
    return Invoke(_G.C_HousingExpertMode.RemoveSelectedDecor)
  end
  return false
end

local function GetEntry(recordID)
  if not recordID then return nil end
  return NS.Systems.Housing:GetEntry({ decorID = recordID })
end

local function BeginPlacement(recordID, switchMode, onDone)
  if not recordID or not IsEditorActive() then if onDone then onDone(false) end return false end
  local function Place()
    CancelEditing()
    local entry = GetEntry(recordID)
    local quantity = entry and ((entry.quantity or 0) + (entry.remainingRedeemable or 0)) or 0
    if not entry or not entry.entryID or quantity <= 0 then if onDone then onDone(false) end return end
    local ok = Invoke(_G.C_HousingBasicMode and _G.C_HousingBasicMode.StartPlacingNewDecor, entry.entryID)
    if onDone then onDone(ok) end
  end
  if switchMode and not IsBasicMode() then
    local basicMode = _G.Enum and _G.Enum.HouseEditorMode and _G.Enum.HouseEditorMode.BasicDecor
    Invoke(_G.C_HouseEditor and _G.C_HouseEditor.ActivateHouseEditorMode, basicMode)
    _G.C_Timer.After(0.22, Place)
  else
    _G.C_Timer.After(0.05, Place)
  end
  return true
end

local function PrintResult(action, info)
  if _G.DEFAULT_CHAT_FRAME then
    _G.DEFAULT_CHAT_FRAME:AddMessage("|cffffd100HomeDecor:|r " .. action .. ": " .. (info and info.name or "Unknown"))
  end
end

function EditorTools:Copy()
  if not Enabled("clipboard") or not IsEditorActive() then return false end
  local info = GetTargetInfo()
  if not info then return false end
  clipboard = info
  PrintResult("Copied", info)
  return true
end

function EditorTools:Cut()
  if not Enabled("clipboard") or not IsEditorActive() then return false end
  local info = GetSelectedInfo()
  if not info then return false end
  clipboard = info
  local removed = RemoveSelected()
  if removed then PrintResult("Cut", info) end
  return removed
end

function EditorTools:Paste()
  if not Enabled("clipboard") or not clipboard or not IsEditorActive() then return false end
  local info = clipboard
  return BeginPlacement(info.recordID, true, function(ok) if ok then PrintResult("Pasted", info) end end)
end

function EditorTools:Duplicate()
  if not Enabled("clipboard") or not IsEditorActive() then return false end
  local info = GetTargetInfo()
  if not info then return false end
  return BeginPlacement(info.recordID, true, function(ok) if ok then PrintResult("Duplicated", info) end end)
end

local function LockStore()
  local store = Store()
  store.locks = type(store.locks) == "table" and store.locks or {}
  return store.locks
end

function EditorTools:ToggleLock()
  if not Enabled("lock") or not IsEditorActive() then return false end
  local info = GetHoveredInfo() or GetSelectedInfo()
  if not info or not info.guid then return false end
  local locks = LockStore()
  if locks[info.guid] then
    locks[info.guid] = nil
    PrintResult("Unlocked", info)
  else
    locks[info.guid] = { name = info.name or "Unknown", timestamp = time() }
    PrintResult("Locked", info)
  end
  return true
end

local function EnsureLockPopup()
  local name = "HOMEDECOR_EDITOR_LOCKED"
  if _G.StaticPopupDialogs[name] then return name end
  _G.StaticPopupDialogs[name] = {
    text = "This decoration is locked:\n\n|cffffd100%s|r\n\nWhat do you want to do?",
    button1 = "Edit Anyway",
    button2 = CANCEL,
    button3 = "Unlock",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    selectCallbackByIndex = true,
    OnButton1 = function() end,
    OnButton2 = function() CancelEditing() end,
    OnButton3 = function(_, data)
      if not data then return end
      local lock = LockStore()[data]
      LockStore()[data] = nil
      PrintResult("Unlocked", { name = lock and lock.name })
    end,
  }
  return name
end

function EditorTools:OnSelected(hasSelected)
  if not hasSelected or not Enabled("lock") or resettingLock then return end
  local info = GetSelectedInfo()
  if not info or not info.guid then return end
  if not LockStore()[info.guid] then return end
  CancelEditing()
  resettingLock = true
  BounceMode()
  _G.C_Timer.After(0.25, function() resettingLock = false end)
  if _G.PlaySound then _G.PlaySound(_G.SOUNDKIT and _G.SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST or 857) end
  _G.StaticPopup_Show(EnsureLockPopup(), info.name or "Unknown", nil, info.guid)
end

function EditorTools:OnPlacementStarted(entryID)
  if type(entryID) == "table" and entryID.recordID then lastPlacedRecordID = entryID.recordID end
end

function EditorTools:OnPlacementSuccess(decorGUID)
  if not Enabled("batchPlace") then batchCount = 0 return end
  local recordID = lastPlacedRecordID
  local info = decorGUID and SafeValue(_G.C_HousingDecor and _G.C_HousingDecor.GetDecorInstanceInfoForGUID, decorGUID)
  if info and info.decorID then recordID = info.decorID end
  if not recordID or not (_G.IsControlKeyDown and _G.IsControlKeyDown()) then batchCount = 0 return end
  batchCount = batchCount + 1
  local count = batchCount
  BeginPlacement(recordID, false, function(ok)
    if not ok or not Enabled("batchRotate") then return end
    _G.C_Timer.After(0.1, function()
      local degrees = (count * (tonumber(Store().batchStep) or 15)) % 360
      local steps = math.floor((degrees + 7.5) / 15)
      for _ = 1, steps do Invoke(_G.C_HousingBasicMode and _G.C_HousingBasicMode.RotateDecor, 1) end
    end)
  end)
end

local function CreateKeyButton(name, action)
  local button = CreateFrame("Button", name, keyOwner, "SecureActionButtonTemplate")
  button:SetScript("OnClick", function() EditorTools[action](EditorTools) end)
  return button
end

local function EnsureKeys()
  if keyOwner then return end
  keyOwner = CreateFrame("Frame", "HomeDecorEditorToolsKeyOwner", UIParent)
  keyButtons = {
    copy = CreateKeyButton("HomeDecorEditorCopy", "Copy"),
    cut = CreateKeyButton("HomeDecorEditorCut", "Cut"),
    paste = CreateKeyButton("HomeDecorEditorPaste", "Paste"),
    duplicate = CreateKeyButton("HomeDecorEditorDuplicate", "Duplicate"),
    lock = CreateKeyButton("HomeDecorEditorLock", "ToggleLock"),
  }
end

function EditorTools:DisableKeys()
  if keyOwner then pcall(_G.ClearOverrideBindings, keyOwner) end
end

function EditorTools:EnableKeys()
  if not IsEditorActive() or not NS.Systems.Settings:GetValue("editorFeatures", true) then self:DisableKeys() return end
  if _G.InCombatLockdown and _G.InCombatLockdown() then return end
  local focus = _G.GetCurrentKeyBoardFocus and _G.GetCurrentKeyBoardFocus()
  if focus and focus.GetObjectType and focus:GetObjectType() == "EditBox" then self:DisableKeys() return end
  EnsureKeys()
  pcall(_G.ClearOverrideBindings, keyOwner)
  local store = Store()
  for action, button in pairs(keyButtons) do
    local feature = action == "lock" and "lock" or "clipboard"
    local key = store.keybinds[action]
    if Enabled(feature) and key and key ~= "" then pcall(_G.SetOverrideBindingClick, keyOwner, true, key, button:GetName()) end
  end
end

function EditorTools:Sync()
  if IsEditorActive() and NS.Systems.Settings:GetValue("editorFeatures", true) then self:EnableKeys() else self:DisableKeys() end
end

function EditorTools:Init()
  if initialized then return end
  initialized = true
  Store()
  if _G.hooksecurefunc and _G.C_HousingBasicMode and _G.C_HousingBasicMode.StartPlacingNewDecor then
    pcall(_G.hooksecurefunc, _G.C_HousingBasicMode, "StartPlacingNewDecor", function(entryID) EditorTools:OnPlacementStarted(entryID) end)
  end
  NS.SafeRegisterEvent(self, "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED", function(hasSelected) EditorTools:OnSelected(hasSelected) end)
  NS.SafeRegisterEvent(self, "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED", function(hasSelected) EditorTools:OnSelected(hasSelected) end)
  NS.SafeRegisterEvent(self, "HOUSING_DECOR_PLACE_SUCCESS", function(decorGUID) EditorTools:OnPlacementSuccess(decorGUID) end)
  NS.SafeRegisterEvent(self, "HOUSE_EDITOR_MODE_CHANGED", function() _G.C_Timer.After(0, function() EditorTools:Sync() end) end)
  self:Sync()
end
