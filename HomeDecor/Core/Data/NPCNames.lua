local _, NS = ...

local NPCNames = { cache = {}, order = {}, head = 1, size = 0 }
NS.Systems.NPCNames = NPCNames

local CAPACITY = 120

local function Accessible(value)
  if value == nil then return false end
  local secret = _G.issecretvalue
  if secret then
    local ok, result = pcall(secret, value)
    if not ok or result then return false end
  end
  local access = _G.canaccessvalue
  if access then
    local ok, result = pcall(access, value)
    if not ok or not result then return false end
  end
  return true
end

local function Clean(value)
  if not Accessible(value) or type(value) ~= "string" then return nil end
  local ok, result = pcall(function(text) return text:gsub("^%s+", ""):gsub("%s+$", "") end, value)
  if not ok or result == "" then return nil end
  return result
end

local function Put(self, id, name)
  if self.cache[id] ~= nil then
    self.cache[id] = name
    return
  end
  if self.size >= CAPACITY then
    local expired = self.order[self.head]
    self.cache[expired] = nil
    self.order[self.head] = id
    self.head = self.head + 1
    if self.head > CAPACITY then self.head = 1 end
  else
    self.size = self.size + 1
    self.order[self.size] = id
  end
  self.cache[id] = name
end

function NPCNames:Get(npcID)
  npcID = tonumber(npcID)
  if not npcID then return nil end
  local cached = self.cache[npcID]
  if cached ~= nil then return cached or nil end
  local name
  local api = _G.C_CreatureInfo and _G.C_CreatureInfo.GetCreatureInfo
  if api then
    local ok, value = pcall(function()
      local info = api(npcID)
      return info and info.name
    end)
    if ok then name = Clean(value) end
  end
  if not name and _G.C_TooltipInfo and _G.C_TooltipInfo.GetHyperlink then
    local link = "unit:Creature-0-0-0-0-" .. tostring(npcID) .. "-0000000000"
    local ok, value = pcall(function()
      local info = _G.C_TooltipInfo.GetHyperlink(link)
      local line = info and info.lines and info.lines[1]
      return line and (line.leftText or line.text)
    end)
    if ok then name = Clean(value) end
  end
  Put(self, npcID, name or false)
  return name
end
