local ADDON, NS = ...

local CraftingQueue = {}
NS.Systems.CraftingQueue = CraftingQueue

local function State()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.decorPricing = profile.decorPricing or {}
  profile.decorPricing.queue = profile.decorPricing.queue or {}
  profile.decorPricing.queueItems = profile.decorPricing.queueItems or {}
  return profile.decorPricing
end

local function ItemName(itemID, fallback)
  return NS.Systems.ItemResolver:GetName(itemID, fallback)
end

function CraftingQueue:GetSize()
  local state = State()
  local total = 0
  for _, quantity in pairs(state and state.queue or {}) do total = total + math.max(0, tonumber(quantity) or 0) end
  return total
end

function CraftingQueue:Add(entry, quantity, materials)
  if not entry or not entry.itemID then return false end
  local state = State()
  if not state then return false end
  local key = tostring(entry.itemID)
  local current = tonumber(state.queue[key]) or 0
  local nextQuantity = math.max(0, current + (tonumber(quantity) or 1))
  state.queue[key] = nextQuantity > 0 and nextQuantity or nil
  if nextQuantity <= 0 then
    state.queueItems[key] = nil
    return true
  end
  local snapshot = state.queueItems[key] or {}
  snapshot.itemID = tonumber(entry.itemID)
  snapshot.name = entry.name or snapshot.name
  snapshot.profession = entry.profession or snapshot.profession
  snapshot.expansion = entry.expansion or snapshot.expansion
  snapshot.profit = entry.profit
  snapshot.cost = entry.cost
  snapshot.sell = entry.sell
  if type(materials) == "table" then
    snapshot.materials = {}
    for index, material in ipairs(materials) do
      snapshot.materials[index] = {
        itemID = tonumber(material.itemID or material.id),
        count = tonumber(material.count or material.qty or material.amount) or 1,
      }
    end
  end
  state.queueItems[key] = snapshot
  return true
end

function CraftingQueue:SetQuantity(itemID, quantity)
  local state = State()
  if not state then return false end
  local key = tostring(itemID)
  quantity = math.max(0, tonumber(quantity) or 0)
  state.queue[key] = quantity > 0 and quantity or nil
  if quantity <= 0 then state.queueItems[key] = nil end
  return true
end

function CraftingQueue:Clear()
  local state = State()
  if not state then return end
  wipe(state.queue)
  wipe(state.queueItems)
end

function CraftingQueue:GetItems()
  local state = State()
  local items = {}
  for key, quantity in pairs(state and state.queue or {}) do
    quantity = tonumber(quantity) or 0
    if quantity > 0 then
      local itemID = tonumber(key)
      local saved = state.queueItems[key] or {}
      items[#items + 1] = {
        itemID = itemID,
        name = ItemName(itemID, saved.name),
        profession = saved.profession,
        expansion = saved.expansion,
        profit = saved.profit,
        cost = saved.cost,
        sell = saved.sell,
        materials = saved.materials or {},
        quantity = quantity,
      }
    end
  end
  table.sort(items, function(a, b) return (a.name or "") < (b.name or "") end)
  return items
end

function CraftingQueue:GetMaterials()
  local totals = {}
  for _, item in ipairs(self:GetItems()) do
    for _, material in ipairs(item.materials) do
      local itemID = tonumber(material.itemID)
      if itemID then totals[itemID] = (totals[itemID] or 0) + (tonumber(material.count) or 1) * item.quantity end
    end
  end
  return totals
end

function CraftingQueue:GetTotals()
  local profit = 0
  local cost = 0
  local missing = 0
  local source = NS.Systems.PriceSource
  for _, item in ipairs(self:GetItems()) do profit = profit + (tonumber(item.profit) or 0) * item.quantity end
  for itemID, quantity in pairs(self:GetMaterials()) do
    local price = source and source.GetItemPrice and source.GetItemPrice(itemID)
    if price then cost = cost + price * quantity else missing = missing + 1 end
  end
  return profit, cost, missing
end

function CraftingQueue:GetMaterialRows()
  local rows = {}
  local source = NS.Systems.PriceSource
  for itemID, quantity in pairs(self:GetMaterials()) do
    local price = source and source.GetItemPrice and source.GetItemPrice(itemID)
    rows[#rows + 1] = { itemID = itemID, quantity = quantity, name = ItemName(itemID), price = price, total = price and price * quantity or nil }
  end
  table.sort(rows, function(a, b) return a.name < b.name end)
  return rows
end

function CraftingQueue:GenerateText(formatName)
  local materials = self:GetMaterialRows()
  local lines = {}
  if formatName == "TSM" then
    for _, material in ipairs(materials) do lines[#lines + 1] = "i:" .. tostring(material.itemID) end
  elseif formatName == "Auctionator" then
    lines[1] = "HomeDecor"
    for _, material in ipairs(materials) do lines[#lines + 1] = '^"' .. material.name .. '";;;;;;;;;;;#;;' .. tostring(material.quantity) end
  else
    lines[1] = "HomeDecor Shopping List"
    lines[2] = ""
    for _, material in ipairs(materials) do lines[#lines + 1] = tostring(material.quantity) .. "x " .. material.name end
  end
  return table.concat(lines, formatName == "Auctionator" and "" or "\n")
end

function CraftingQueue:CreateAuctionatorList()
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if not api or type(api.CreateShoppingList) ~= "function" then return false, "Auctionator is not available" end
  local terms = {}
  local unresolved = 0
  for _, material in ipairs(self:GetMaterialRows()) do
    if material.name == "Loading..." then
      unresolved = unresolved + 1
    else
      local value = material.name
      if type(api.ConvertToSearchString) == "function" then
        local ok, converted = pcall(api.ConvertToSearchString, ADDON, { searchString = material.name, isExact = true, quantity = material.quantity })
        if ok and converted then value = converted end
      end
      terms[#terms + 1] = value
    end
  end
  if unresolved > 0 then return false, "Waiting for " .. tostring(unresolved) .. " material name(s)" end
  if #terms == 0 then return false, "The queue has no materials" end
  local ok = pcall(api.CreateShoppingList, ADDON, "HomeDecor", terms)
  return ok, ok and ("Created an Auctionator list with " .. tostring(#terms) .. " materials") or "Auctionator could not create the list"
end

return CraftingQueue
