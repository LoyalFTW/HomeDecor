local _, NS = ...

NS.UI = NS.UI or {}
local ItemTooltip = {}
NS.UI.ItemTooltip = ItemTooltip

local function RequirementText(record)
  local text = NS.Systems.Requirements:Text(record)
  return text ~= "" and text or nil
end

local function FactionText(value)
  if type(value) ~= "table" then return value and tostring(value) or nil end
  local alliance, horde
  for _, faction in pairs(value) do
    if faction == "Alliance" then alliance = true elseif faction == "Horde" then horde = true end
  end
  if alliance and horde then return "Both" end
  if alliance then return "Alliance" end
  if horde then return "Horde" end
end

function ItemTooltip:Show(owner, record, mode)
  if not record or not _G.GameTooltip then return end
  local title, _, owned = NS.Systems.Housing:GetDisplay(record)
  local tooltip = _G.GameTooltip
  tooltip:SetOwner(owner, "ANCHOR_RIGHT")
  tooltip:AddLine(title, 1, 0.82, 0.18)
  tooltip:AddLine(owned and "Collected" or "Not collected", owned and 0.35 or 1, owned and 0.9 or 0.35, owned and 0.45 or 0.35)
  tooltip:AddLine(NS.Systems.Housing:IsDyeable(record) and "Dyeable" or "Not Dyeable", 0.4, 0.9, 1)
  local pricing = NS.Systems and NS.Systems.PriceSource
  local price, provider = pricing and pricing.GetItemPrice and pricing.GetItemPrice(record.itemID)
  if price then tooltip:AddLine("Market: " .. pricing.FormatGold(price, true) .. "  (" .. tostring(provider) .. ")", 1, 0.76, 0.08) end
  local source = record.sourceType and "Source: " .. tostring(record.sourceType) or nil
  if source then tooltip:AddLine(source, 0.8, 0.8, 0.8) end
  if record.sourceName or record.vendorName then tooltip:AddLine(tostring(record.sourceName or record.vendorName), 0.93, 0.91, 0.85) end
  if record.zone then tooltip:AddLine(tostring(record.zone), 0.8, 0.8, 0.8) end
  local faction = FactionText(record.faction)
  if faction then tooltip:AddLine("Faction: " .. faction, 0.8, 0.8, 0.8) end
  local class = NS.Systems.Housing:GetClassRestriction(record)
  if class then tooltip:AddLine("Class: " .. tostring(class), 0.49, 0.82, 1) end
  if record.raceRestriction then tooltip:AddLine("Race: " .. tostring(record.raceRestriction), 0.8, 0.8, 0.8) end
  if record.budgetCost then tooltip:AddLine("Budget: " .. tostring(record.budgetCost), 0.8, 0.8, 0.8) end
  if record.size then tooltip:AddLine("Size: " .. tostring(record.size), 0.8, 0.8, 0.8) end
  local cost = NS.Systems.Cost:Format(record)
  if cost then tooltip:AddLine("Price: " .. tostring(cost), 1, 0.76, 0.08) end
  if type(record.colors) == "table" and #record.colors > 0 then tooltip:AddLine("Colors: " .. table.concat(record.colors, ", "), 0.8, 0.8, 0.8, true) end
  local requirements = RequirementText(record)
  if requirements then tooltip:AddLine(requirements, 1, 0.7, 0.3) end
  if mode == "catalog" then
    local sourceCount, sourceLabel = NS.UI.ItemInteractions:GetSourceInfo(record)
    tooltip:AddLine("Left-click: Details / Preview", 0.65, 0.8, 1)
    tooltip:AddLine(sourceCount > 1 and ("Right-click: Choose " .. sourceLabel:lower()) or "Right-click: Open map", 0.65, 0.8, 1)
    tooltip:AddLine("Shift-click: Add to list", 0.65, 0.8, 1)
  elseif mode == "pricing" then
    tooltip:AddLine("Click: Preview decor", 0.65, 0.8, 1)
  else
    tooltip:AddLine("Left-click: Preview   Right-click: Map waypoint", 0.65, 0.8, 1)
  end
  if NS.Systems.Requirements:FirstOpenable(record) then
    tooltip:AddLine("Ctrl-click: Open requirement", 0.65, 0.8, 1)
  end
  tooltip:AddLine("Alt-click: Wowhead links", 0.65, 0.8, 1)
  tooltip:Show()
end

function ItemTooltip:Hide()
  if _G.GameTooltip then _G.GameTooltip:Hide() end
end
