local _, NS = ...

local GatherTracker = { revision = 0 }
NS.Systems.GatherTracker = GatherTracker

local KNOWN_LUMBER = {
  [242691] = "Olemba Lumber",
  [245586] = "Ironwood Lumber",
  [248012] = "Dornic Fir Lumber",
  [251762] = "Coldwind Lumber",
  [251763] = "Bamboo Lumber",
  [251764] = "Ashwood Lumber",
  [251766] = "Shadowmoon Lumber",
  [251767] = "Fel-Touched Lumber",
  [251768] = "Darkpine Lumber",
  [251772] = "Arden Lumber",
  [251773] = "Dragonpine Lumber",
  [256963] = "Thalassian Lumber",
}

local function Accessible(value)
  if value == nil then return nil end
  if issecretvalue and issecretvalue(value) then return nil end
  if canaccessvalue and not canaccessvalue(value) then return nil end
  return value
end

local function Now()
  return GetServerTime and GetServerTime() or time()
end

local function CharacterKey()
  local name = Accessible(UnitName and UnitName("player"))
  local realm = Accessible(GetRealmName and GetRealmName())
  if type(name) ~= "string" or name == "" then return nil end
  if type(realm) ~= "string" or realm == "" then realm = "Unknown" end
  return name .. "-" .. realm:gsub("%s+", "")
end

local function State()
  local profile = NS.Systems.Database:GetProfile()
  return profile and profile.gatherTracker
end

local function ItemKind(itemID, name, classID, subclassID)
  if KNOWN_LUMBER[itemID] then return "lumber" end
  local lower = type(name) == "string" and name:lower() or ""
  if lower:find("lumber", 1, true) or lower:find("timber", 1, true) or lower:find("plank", 1, true) then return "lumber" end
  local tradegoods = Enum and Enum.ItemClass and Enum.ItemClass.Tradegoods or 7
  local metal = Enum and Enum.ItemTradegoodsSubclass and Enum.ItemTradegoodsSubclass.MetalAndStone or 7
  local herb = Enum and Enum.ItemTradegoodsSubclass and Enum.ItemTradegoodsSubclass.Herb or 9
  if classID == tradegoods and subclassID == metal then return "ore" end
  if classID == tradegoods and subclassID == herb then return "herb" end
  return nil
end

local function ItemMeta(itemID)
  local name = KNOWN_LUMBER[itemID]
  local icon
  local classID, subclassID
  if C_Item and C_Item.GetItemInfoInstant then
    local ok, _, _, _, _, instantIcon, valueClass, valueSubclass = pcall(C_Item.GetItemInfoInstant, itemID)
    if ok then
      icon = icon or Accessible(instantIcon)
      classID = tonumber(Accessible(valueClass))
      subclassID = tonumber(Accessible(valueSubclass))
    end
  elseif GetItemInfoInstant then
    local ok, _, _, _, _, instantIcon, valueClass, valueSubclass = pcall(GetItemInfoInstant, itemID)
    if ok then
      icon = icon or Accessible(instantIcon)
      classID = tonumber(Accessible(valueClass))
      subclassID = tonumber(Accessible(valueSubclass))
    end
  end
  return name, icon, classID, subclassID
end

local function ItemCount(itemID, includeBank, includeAccount)
  if not C_Item or not C_Item.GetItemCount then return 0 end
  local ok, value = pcall(C_Item.GetItemCount, itemID, includeBank == true, false, includeBank == true, includeAccount == true)
  return ok and tonumber(Accessible(value)) or 0
end

function GatherTracker:GetState()
  return State()
end

function GatherTracker:GetSettings()
  local settings = State().settings
  settings.scope = settings.scope == "character" and "character" or "account"
  if settings.kind ~= "lumber" and settings.kind ~= "ore" and settings.kind ~= "herb" then settings.kind = "all" end
  settings.search = type(settings.search) == "string" and settings.search or ""
  settings.sort = type(settings.sort) == "string" and settings.sort or "countDesc"
  settings.hideZero = settings.hideZero == true
  settings.trackLumber = settings.trackLumber ~= false
  settings.trackOre = settings.trackOre ~= false
  settings.trackHerbs = settings.trackHerbs ~= false
  settings.autoFarm = settings.autoFarm ~= false
  settings.autoStart = settings.autoFarm
  settings.focusByKind = type(settings.focusByKind) == "table" and settings.focusByKind or {}
  settings.farmerCompact = settings.farmerCompact == true
  settings.hudEnabled = settings.hudEnabled == true
  settings.hudLocked = settings.hudLocked == true
  settings.hudSize = math.max(280, math.min(620, tonumber(settings.hudSize) or 420))
  return settings
end

function GatherTracker:IsKindEnabled(kind)
  local settings = self:GetSettings()
  if kind == "lumber" then return settings.trackLumber end
  if kind == "ore" then return settings.trackOre end
  if kind == "herb" then return settings.trackHerbs end
  return false
end

function GatherTracker:GetCurrentKey()
  return CharacterKey()
end

function GatherTracker:EnsureKnownItems()
  local state = State()
  for itemID, fallback in pairs(KNOWN_LUMBER) do
    local item = state.items[tostring(itemID)]
    if not item then item = {} state.items[tostring(itemID)] = item end
    item.itemID = itemID
    item.kind = "lumber"
    item.name = item.name or fallback
  end
end

function GatherTracker:ObserveItem(itemID)
  itemID = tonumber(itemID)
  if not itemID then return nil end
  local name, icon, classID, subclassID = ItemMeta(itemID)
  local kind = ItemKind(itemID, name, classID, subclassID)
  if not kind then return nil end
  name = NS.Systems.ItemResolver:GetName(itemID, name)
  icon = icon or NS.Systems.ItemResolver:GetIcon(itemID)
  local state = State()
  local key = tostring(itemID)
  local item = state.items[key]
  if not item then item = {} state.items[key] = item end
  item.itemID = itemID
  item.kind = kind
  if type(name) == "string" and name ~= "" then item.name = name end
  if icon then item.icon = icon end
  return item
end

function GatherTracker:ImportLegacy()
  local state = State()
  if not state or state.legacyImported then return end
  local legacy = _G.HomeDecorDB
  local oldProfile = NS.Systems.Database:GetProfile()
  local old = oldProfile and (oldProfile.gatherTrack or oldProfile.lumberTrack)
  local settings = state.settings
  if type(old) == "table" then
    settings.hideZero = old.hideZero == true
    settings.search = type(old.search) == "string" and old.search or settings.search
    settings.scope = old.accountWide == false and "character" or "account"
    settings.trackLumber = old.trackLumber ~= false
    settings.trackOre = old.trackOre ~= false
    settings.trackHerbs = old.trackHerbs ~= false
    settings.autoFarm = old.autoStartFarming ~= false
    local kinds = (old.trackLumber ~= false and 1 or 0) + (old.trackOre == true and 1 or 0) + (old.trackHerbs == true and 1 or 0)
    if kinds == 1 then
      settings.kind = old.trackOre == true and "ore" or old.trackHerbs == true and "herb" or "lumber"
    else
      settings.kind = "all"
    end
    local goal = math.max(0, math.floor(tonumber(old.goal) or 0))
    if goal > 0 and old.autoGoal ~= true then
      for itemID in pairs(KNOWN_LUMBER) do state.goals[tostring(itemID)] = state.goals[tostring(itemID)] or goal end
    end
  end
  local account = legacy and legacy.global and legacy.global.gatherTrackAccount
  for key, counts in pairs(type(account) == "table" and account.characterData or {}) do
    local character = state.characters[key] or { counts = {}, personal = {}, bank = {}, updated = 0 }
    character.counts = character.counts or {}
    character.personal = character.personal or {}
    character.bank = character.bank or {}
    for itemID, count in pairs(type(counts) == "table" and counts or {}) do
      itemID = tonumber(itemID)
      count = math.max(0, tonumber(count) or 0)
      if itemID and self:ObserveItem(itemID) then
        character.personal[tostring(itemID)] = count
        character.counts[tostring(itemID)] = count
      end
    end
    state.characters[key] = character
  end
  for key, counts in pairs(type(account) == "table" and account.bankData or {}) do
    local character = state.characters[key] or { counts = {}, personal = {}, bank = {}, updated = 0 }
    character.counts = character.counts or {}
    character.personal = character.personal or {}
    character.bank = character.bank or {}
    for itemID, count in pairs(type(counts) == "table" and counts or {}) do
      itemID = tonumber(itemID)
      count = math.max(0, tonumber(count) or 0)
      if itemID and self:ObserveItem(itemID) then character.bank[tostring(itemID)] = count end
    end
    state.characters[key] = character
  end
  state.legacyImported = true
end

function GatherTracker:ScanBags()
  local state = State()
  if not state then return false end
  self:ImportLegacy()
  self:EnsureKnownItems()
  local key = CharacterKey()
  if not key then return false end
  local counts = self.scanCounts or {}
  self.scanCounts = counts
  wipe(counts)
  if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo then
    local lastBag = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5
    for bag = 0, lastBag do
      local ok, slots = pcall(C_Container.GetContainerNumSlots, bag)
      slots = ok and tonumber(Accessible(slots)) or 0
      for slot = 1, slots do
        local infoOK, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
        info = infoOK and Accessible(info) or nil
        local itemID = info and tonumber(Accessible(info.itemID))
        if itemID and self:ObserveItem(itemID) then counts[itemID] = (counts[itemID] or 0) + (tonumber(Accessible(info.stackCount)) or 1) end
      end
    end
  end
  local character = state.characters[key]
  if not character then character = { counts = {}, personal = {}, updated = 0 } state.characters[key] = character end
  character.counts = character.counts or {}
  character.personal = character.personal or {}
  local session = state.session
  session.gained = session.gained or {}
  state.recent = state.recent or {}
  local previousCounts = self.lastBagCounts or {}
  self.lastBagCounts = previousCounts
  local canTrackGains = self.bagSnapshotReady == true and not self.bankOpen and not self.mailOpen and Now() >= (tonumber(self.suppressGainsUntil) or 0)
  local gains = self.pendingGains or {}
  self.pendingGains = gains
  wipe(gains)
  local hasGain = false
  for itemKey, item in pairs(state.items) do
    local itemID = tonumber(item.itemID or itemKey)
    if itemID then
      local current = counts[itemID] or 0
      local gained = canTrackGains and math.max(0, current - (tonumber(previousCounts[itemID]) or 0)) or 0
      if gained > 0 and self:IsKindEnabled(item.kind) then gains[itemID] = gained hasGain = true end
      character.counts[tostring(itemID)] = current
      character.personal[tostring(itemID)] = current
    end
  end
  if hasGain and not session.active and self:GetSettings().autoFarm then
    session.active = true
    session.started = Now() - math.max(0, tonumber(session.elapsed) or 0)
  end
  for itemID, gained in pairs(gains) do
    local item = state.items[tostring(itemID)]
    if item and item.kind then state.recent[item.kind] = { itemID = itemID, amount = gained, at = Now() } end
  end
  if session.active then
    for itemID, gained in pairs(gains) do session.gained[tostring(itemID)] = (tonumber(session.gained[tostring(itemID)]) or 0) + gained end
  end
  wipe(previousCounts)
  for itemID, count in pairs(counts) do previousCounts[itemID] = count end
  self.bagSnapshotReady = true
  character.updated = Now()
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_GATHER_UPDATED")
  return true
end

function GatherTracker:SetFocusItem(kind, itemID)
  if kind ~= "lumber" and kind ~= "ore" and kind ~= "herb" then return end
  local focus = self:GetSettings().focusByKind
  itemID = tonumber(itemID)
  focus[kind] = itemID and itemID > 0 and itemID or nil
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_GATHER_UPDATED")
end

function GatherTracker:GetKindStats(kind)
  local state = State()
  local settings = self:GetSettings()
  local itemID = tonumber(settings.focusByKind[kind])
  if not itemID then itemID = tonumber(state.recent and state.recent[kind] and state.recent[kind].itemID) end
  if not itemID then
    local bestGain, bestCount = 0, 0
    for key, item in pairs(state.items or {}) do
      if item.kind == kind then
        local candidate = tonumber(item.itemID or key)
        local gain = candidate and self:GetSessionGain(candidate) or 0
        local count = candidate and self:GetCount(candidate, "character") or 0
        if candidate and (gain > bestGain or (gain == bestGain and count > bestCount)) then itemID = candidate bestGain = gain bestCount = count end
      end
    end
  end
  if not itemID then return { kind = kind, bagCount = 0, sessionCount = 0, rate = 0, recentAmount = 0, automatic = settings.focusByKind[kind] == nil } end
  local item = state.items[tostring(itemID)] or {}
  local recent = state.recent and state.recent[kind]
  return {
    kind = kind,
    itemID = itemID,
    name = NS.Systems.ItemResolver:GetName(itemID, item.name or ("Item " .. itemID)),
    icon = item.icon or NS.Systems.ItemResolver:GetIcon(itemID),
    bagCount = self:GetCount(itemID, "character"),
    overallCount = self:GetCount(itemID, "account"),
    sessionCount = self:GetSessionGain(itemID),
    rate = self:GetRate(itemID),
    recentAmount = recent and tonumber(recent.itemID) == itemID and (tonumber(recent.amount) or 0) or 0,
    automatic = settings.focusByKind[kind] == nil,
  }
end

function GatherTracker:GetKindOptions(kind)
  local options = { { label = "Auto: latest gathered", value = 0 } }
  local state = State()
  for key, item in pairs(state.items or {}) do
    if item.kind == kind then
      local itemID = tonumber(item.itemID or key)
      if itemID then options[#options + 1] = { label = NS.Systems.ItemResolver:GetName(itemID, item.name or ("Item " .. itemID)), value = itemID } end
    end
  end
  table.sort(options, function(left, right)
    if left.value == 0 then return true end
    if right.value == 0 then return false end
    return left.label < right.label
  end)
  return options
end

function GatherTracker:GetCount(itemID, scope)
  itemID = tonumber(itemID)
  if not itemID then return 0 end
  local cache = self.countCache or {}
  self.countCache = cache
  if self.countCacheRevision ~= self.revision then wipe(cache) self.countCacheRevision = self.revision end
  local cacheKey = tostring(scope or "account") .. ":" .. tostring(itemID)
  if cache[cacheKey] ~= nil then return cache[cacheKey] end
  local state = State()
  local currentKey = CharacterKey()
  local current = currentKey and state.characters[currentKey]
  if scope == "character" then
    local value = current and tonumber(current.counts[tostring(itemID)]) or 0
    cache[cacheKey] = value
    return value
  end
  local saved = 0
  for key, character in pairs(state.characters) do
    saved = saved + (tonumber(character.personal and character.personal[tostring(itemID)]) or tonumber(character.counts and character.counts[tostring(itemID)]) or 0)
    if key ~= currentKey then saved = saved + (tonumber(character.bank and character.bank[tostring(itemID)]) or 0) end
  end
  local livePersonal = ItemCount(itemID, false, false)
  local liveAccount = ItemCount(itemID, true, true)
  local value = math.max(0, saved + math.max(0, liveAccount - livePersonal))
  cache[cacheKey] = value
  return value
end

function GatherTracker:GetSessionGain(itemID)
  local session = State().session
  return tonumber(session.gained and session.gained[tostring(itemID)]) or 0
end

function GatherTracker:GetSessionElapsed()
  local session = State().session
  if not session.active or not session.started or session.started <= 0 then return tonumber(session.elapsed) or 0 end
  return math.max(0, Now() - session.started)
end

function GatherTracker:GetRate(itemID)
  local elapsed = self:GetSessionElapsed()
  return elapsed > 0 and self:GetSessionGain(itemID) * 3600 / elapsed or 0
end

function GatherTracker:SetGoal(itemID, value)
  local state = State()
  value = math.max(0, math.floor(tonumber(value) or 0))
  state.goals[tostring(itemID)] = value > 0 and value or nil
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_GATHER_UPDATED")
end

function GatherTracker:StartSession()
  local state = State()
  local session = state.session
  local elapsed = math.max(0, tonumber(session.elapsed) or 0)
  session.active = false
  self:ScanBags()
  session.active = true
  session.started = Now() - elapsed
  session.elapsed = elapsed
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_GATHER_UPDATED")
end

function GatherTracker:StopSession()
  local session = State().session
  session.elapsed = self:GetSessionElapsed()
  session.active = false
  session.started = 0
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_GATHER_UPDATED")
end

function GatherTracker:ResetSession()
  local state = State()
  local session = state.session
  session.active = false
  session.started = 0
  session.elapsed = 0
  wipe(session.gained)
  state.recent = state.recent or {}
  wipe(state.recent)
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_GATHER_UPDATED")
end

local QueueScan = NS.Debounce(0.12, function() GatherTracker:ScanBags() end)

NS.SafeRegisterEvent(GatherTracker, "PLAYER_LOGIN", function() C_Timer.After(0.8, QueueScan) end)
NS.SafeRegisterEvent(GatherTracker, "BAG_UPDATE_DELAYED", QueueScan)
NS.SafeRegisterEvent(GatherTracker, "BANKFRAME_OPENED", QueueScan)
NS.SafeRegisterEvent(GatherTracker, "BANKFRAME_OPENED", function() GatherTracker.bankOpen = true GatherTracker.suppressGainsUntil = Now() + 60 end)
NS.SafeRegisterEvent(GatherTracker, "BANKFRAME_CLOSED", function() GatherTracker.bankOpen = nil GatherTracker.suppressGainsUntil = Now() + 2 QueueScan() end)
NS.SafeRegisterEvent(GatherTracker, "MAIL_SHOW", function() GatherTracker.mailOpen = true GatherTracker.suppressGainsUntil = Now() + 60 end)
NS.SafeRegisterEvent(GatherTracker, "MAIL_CLOSED", function() GatherTracker.mailOpen = nil GatherTracker.suppressGainsUntil = Now() + 2 QueueScan() end)
NS.SafeRegisterEvent(GatherTracker, "PLAYERBANKSLOTS_CHANGED", QueueScan)
NS.SafeRegisterEvent(GatherTracker, "PLAYERREAGENTBANKSLOTS_CHANGED", QueueScan)
NS.SafeRegisterEvent(GatherTracker, "REAGENTBANK_UPDATE", QueueScan)
NS.SafeRegisterEvent(GatherTracker, "ACCOUNT_BANK_TAB_SLOTS_CHANGED", QueueScan)
NS.SafeRegisterEvent(GatherTracker, "PLAYER_LOGOUT", function()
  local session = State().session
  if session.active then session.elapsed = GatherTracker:GetSessionElapsed() session.active = false session.started = 0 end
end)

return GatherTracker
