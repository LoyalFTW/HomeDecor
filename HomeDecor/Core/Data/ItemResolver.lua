local _, NS = ...

local ItemResolver = {}
NS.Systems.ItemResolver = ItemResolver

local names = {}
local icons = {}
local pending = {}
local retries = {}
local listeners = setmetatable({}, { __mode = "k" })
local cached = {}
local cacheOrder = {}
local cacheHead = 1
local cacheSize = 0
local CACHE_CAPACITY = 512

local function Remember(itemID)
  if cached[itemID] then return end
  if cacheSize >= CACHE_CAPACITY then
    local expired = cacheOrder[cacheHead]
    cached[expired] = nil
    names[expired] = nil
    icons[expired] = nil
    pending[expired] = nil
    retries[expired] = nil
    cacheOrder[cacheHead] = itemID
    cacheHead = cacheHead + 1
    if cacheHead > CACHE_CAPACITY then cacheHead = 1 end
  else
    cacheSize = cacheSize + 1
    cacheOrder[cacheSize] = itemID
  end
  cached[itemID] = true
end

local function Accessible(value)
  if value == nil then return false end
  if issecretvalue and issecretvalue(value) then return false end
  if canaccessvalue and not canaccessvalue(value) then return false end
  return true
end

local function ResolveName(itemID)
  local cached = names[itemID]
  if cached then return cached end
  local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
  if not Accessible(name) then name = nil end
  if not name and GetItemInfo then
    name = GetItemInfo(itemID)
    if not Accessible(name) then name = nil end
  end
  if type(name) == "string" and name ~= "" then
    Remember(itemID)
    names[itemID] = name
    pending[itemID] = nil
    retries[itemID] = nil
    return name
  end
  return nil
end

local function Request(itemID, force)
  if not itemID or (pending[itemID] and not force) or (retries[itemID] or 0) > 3 then return end
  Remember(itemID)
  pending[itemID] = true
  if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, itemID) end
end

local function Notify(itemID, name)
  for owner, callback in pairs(listeners) do pcall(callback, owner, itemID, name) end
end

function ItemResolver:GetName(itemID, fallback)
  itemID = tonumber(itemID)
  if not itemID then return fallback or "Unknown Item" end
  local name = ResolveName(itemID)
  if name then return name end
  Request(itemID)
  if type(fallback) == "string" and fallback ~= "" and not fallback:match("^Item %d+$") then return fallback end
  return "Loading..."
end

function ItemResolver:GetIcon(itemID)
  itemID = tonumber(itemID)
  if not itemID then return "Interface\\Icons\\INV_Misc_QuestionMark" end
  if icons[itemID] then return icons[itemID] end
  local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID)
  if not Accessible(icon) then icon = nil end
  if not icon and GetItemIcon then icon = GetItemIcon(itemID) end
  if not Accessible(icon) then icon = nil end
  if icon then
    Remember(itemID)
    icons[itemID] = icon
  end
  if not icon then Request(itemID) end
  return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function ItemResolver:Subscribe(owner, callback)
  if owner and type(callback) == "function" then listeners[owner] = callback end
end

function ItemResolver:Unsubscribe(owner)
  listeners[owner] = nil
end

function ItemResolver:Invalidate(itemID)
  if itemID then
    local id = tonumber(itemID)
    names[id] = nil
    icons[id] = nil
    pending[id] = nil
    retries[id] = nil
  else
    wipe(names)
    wipe(icons)
    wipe(pending)
    wipe(retries)
    wipe(cached)
    wipe(cacheOrder)
    cacheHead = 1
    cacheSize = 0
  end
end

local function OnItemData(itemID, success)
  itemID = tonumber(itemID)
  if not itemID or not pending[itemID] then return end
  C_Timer.After(success == false and 0.25 or 0, function()
    local name = ResolveName(itemID)
    if name then
      Notify(itemID, name)
      return
    end
    retries[itemID] = (retries[itemID] or 0) + 1
    if retries[itemID] <= 3 then
      Request(itemID, true)
    else
      pending[itemID] = nil
      Notify(itemID, nil)
    end
  end)
end

NS.SafeRegisterEvent(ItemResolver, "ITEM_DATA_LOAD_RESULT", OnItemData)
NS.SafeRegisterEvent(ItemResolver, "GET_ITEM_INFO_RECEIVED", OnItemData)

return ItemResolver
