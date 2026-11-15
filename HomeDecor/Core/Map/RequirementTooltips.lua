local _, NS = ...

local RequirementTooltips = {}
NS.Systems.RequirementTooltips = RequirementTooltips

local function ItemTitle(record)
  local housing = NS.Systems.Housing
  if housing and housing.GetDisplay then
    local value = housing:GetDisplay(record)
    if value and value ~= "" then return value end
  end
  return record.title or (record.itemID and ("Item " .. tostring(record.itemID))) or "Unknown decor"
end

local function RequirementLines(record)
  local requirements = NS.Systems.Requirements
  if not requirements or not requirements.Get then return nil end
  local values = requirements:Get(record)
  if not values or #values == 0 then return nil end
  local lines = {}
  for index = 1, #values do
    local value = values[index]
    if value.met ~= true then
      local text = tostring(value.title or value.id or "Requirement")
      if value.standing then text = text .. " - " .. tostring(value.standing) end
      lines[#lines + 1] = { text = text, locked = value.met == false }
    end
  end
  return #lines > 0 and lines or nil
end

local function AppendRequirements(tooltip)
  if not tooltip or not tooltip.GetOwner or not _G.IsShiftKeyDown or not _G.IsShiftKeyDown() then return end
  local owner = tooltip:GetOwner()
  local record = owner and owner.record
  if not record or record.sourceType ~= "vendor" then return end
  local npcID = tonumber(record.sourceID)
  if not npcID then return end
  local collection = NS.Systems.Collection
  local pipeline = NS.Systems.Pipeline
  if not collection or not pipeline then return end
  local entries = {}
  local seen = {}
  pipeline:ForEach(nil, function(candidate)
    if candidate.sourceType ~= "vendor" or tonumber(candidate.sourceID) ~= npcID then return end
    local key = tostring(candidate.decorID or candidate.itemID or candidate.id or "")
    if key == "" or seen[key] or collection:IsOwned(candidate) then return end
    seen[key] = true
    local lines = RequirementLines(candidate)
    if lines then entries[#entries + 1] = { title = ItemTitle(candidate), lines = lines } end
  end)
  if #entries == 0 then return end
  table.sort(entries, function(left, right) return left.title < right.title end)
  tooltip:AddLine(" ", 0, 0, 0)
  tooltip:AddLine("Requirements", 1, 0.82, 0)
  for index = 1, math.min(#entries, 12) do
    local entry = entries[index]
    tooltip:AddLine(entry.title, 1, 1, 1)
    for lineIndex = 1, #entry.lines do
      local line = entry.lines[lineIndex]
      if line.locked then
        tooltip:AddLine("  Locked: " .. line.text, 1, 0.35, 0.35, true)
      else
        tooltip:AddLine("  Check requirement: " .. line.text, 1, 0.72, 0.25, true)
      end
    end
  end
  if #entries > 12 then tooltip:AddLine("+" .. tostring(#entries - 12) .. " more with requirements", 0.8, 0.8, 0.8) end
end

function RequirementTooltips:Initialize()
  if self.initialized or not _G.GameTooltip or not _G.GameTooltip.HookScript then return end
  self.initialized = true
  _G.GameTooltip:HookScript("OnShow", AppendRequirements)
end

RequirementTooltips:Initialize()
