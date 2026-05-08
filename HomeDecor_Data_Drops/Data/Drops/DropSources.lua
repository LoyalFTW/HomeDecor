local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Drops = NS.Data.Drops or {}

local function IsLeaf(v)
  return type(v) == "table" and v.decorID ~= nil
end

local function NormalizeDropNode(node)
  if type(node) ~= "table" then return end

  if node[1] ~= nil then
    local seen = {}
    local out = {}

    for _, v in ipairs(node) do
      if IsLeaf(v) then
        if not seen[v.decorID] then
          seen[v.decorID] = v
          out[#out+1] = v
        else

          local cur = seen[v.decorID]
          if (cur.title == nil or cur.title == "") and v.title and v.title ~= "" then
            seen[v.decorID] = v
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

    if #out > 0 then
      for i = 1, math.max(#node, #out) do
        node[i] = out[i]
      end
    end
    return
  end

  for _, v in pairs(node) do
    NormalizeDropNode(v)
  end
end

local function Build()
  NormalizeDropNode(NS.Data.Drops)
end

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
