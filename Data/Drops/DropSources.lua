local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Drops = NS.Data.Drops or {}

-- Flat mapping: decorID -> { "Mob A", "Mob B", ... }
-- Used by UI\Widgets\DropPanel.lua to show "Drops From (N)" without tooltips or per-mob dropdowns.
NS.Data.DropSources = NS.Data.DropSources or {}

local function AddMob(decorID, name)
  if not decorID or not name or name == "" then return end
  local t = NS.Data.DropSources[decorID]
  if not t then
    t = {}
    NS.Data.DropSources[decorID] = t
  end
  for _, v in ipairs(t) do
    if v == name then return end
  end
  t[#t+1] = name
end

local function IsLeaf(v)
  return type(v) == "table" and v.decorID ~= nil
end

-- Walk any nested structure and:
-- 1) Collect mob names into DropSources
-- 2) Collapse multiple leaves that share the same decorID into a single leaf
--    (keeps one entry in the UI, but preserves the full mob list)
local function NormalizeDropNode(node)
  if type(node) ~= "table" then return end

  -- Array/list: normalize leaves within the list
  if node[1] ~= nil then
    local seen = {}
    local out = {}

    for _, v in ipairs(node) do
      if IsLeaf(v) then
        local did = v.decorID

        -- Collect mob name from common fields
        local src = v.source
        local mob = (src and (src.npc or src.mob or src.name)) or v.npc or v.mob
        if mob then
          AddMob(did, mob)
        end

        -- Keep ONE representative leaf per decorID
        if not seen[did] then
          seen[did] = v
          out[#out+1] = v
        else
          -- If the existing representative is missing title/type, and this leaf has it, prefer it.
          local cur = seen[did]
          if (cur.title == nil or cur.title == "") and v.title and v.title ~= "" then
            seen[did] = v
            out[#out] = v
          end
          if (cur.decorType == nil or cur.decorType == "") and v.decorType and v.decorType ~= "" then
            cur.decorType = v.decorType
          end
        end
      elseif type(v) == "table" then
        NormalizeDropNode(v)
        out[#out+1] = v
      else
        out[#out+1] = v
      end
    end

    -- If we collapsed anything, rewrite the node in place
    if #out > 0 then
      for i = 1, math.max(#node, #out) do
        node[i] = out[i]
      end
    end
    return
  end

  -- Map/table: recurse into children
  for _, v in pairs(node) do
    NormalizeDropNode(v)
  end
end

local function SortLists()
  for _, list in pairs(NS.Data.DropSources) do
    if type(list) == "table" then
      table.sort(list, function(a,b) return tostring(a) < tostring(b) end)
    end
  end
end

local function Build()
  -- Scan and normalize the entire drops dataset
  NormalizeDropNode(NS.Data.Drops)
  SortLists()
end

-- Run after all XML scripts have loaded.
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
  if name ~= ADDON then return end
  if C_Timer and C_Timer.After then
    C_Timer.After(0, Build)
  else
    Build()
  end
end)
