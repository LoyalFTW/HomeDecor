local ADDON, NS = ...
NS.DecorAH = NS.DecorAH or {}
local Export = NS.DecorAH.Export or {}
NS.DecorAH.Export = Export

local DecorAH_Queue = NS.DecorAH and NS.DecorAH.Queue
local PriceSource = NS.Systems.PriceSource

function Export.GenerateTSMList(materials, listName)
  if not materials or type(materials) ~= "table" then return "" end

  listName = listName or "HomeDecor Crafting"
  local items = {}

  for itemID, count in pairs(materials) do
    table.insert(items, tostring(itemID))
  end

  if #items == 0 then
    return ""
  end

  table.sort(items)
  local str = table.concat(items, "\n")

  return str
end

function Export.GenerateAuctionatorList(materials, listName)
  if not materials or type(materials) ~= "table" then return "" end

  listName = listName or "HomeDecor"
  local items = {}

  for itemID, count in pairs(materials) do
    local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
    if name and name ~= "" then
      table.insert(items, {name = name, count = count})
    end
  end

  table.sort(items, function(a, b) return a.name < b.name end)

  local exportStr = listName
  for _, item in ipairs(items) do
    exportStr = exportStr .. '^"' .. item.name .. '";;;;;;;;;;;#;;' .. item.count
  end

  return exportStr
end

function Export.CreateAuctionatorShoppingList(materials, listName)
  if not materials or type(materials) ~= "table" then
    return false, "No materials provided"
  end

  if not Auctionator or not Auctionator.API or not Auctionator.API.v1 then
    return false, "Auctionator not installed or API not available"
  end

  listName = listName or "HomeDecor"
  local callerID = "HomeDecor"

  local hasQuantitySupport = Auctionator.API.v1.ConvertToSearchString ~= nil

  local searchStrings = {}
  local addedCount = 0

  for itemID, count in pairs(materials) do
    local itemName = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
    if itemName and itemName ~= "" then
      local searchString
      if hasQuantitySupport then
        local term = {
          searchString = itemName,
          isExact = true,
          quantity = count,
        }
        searchString = Auctionator.API.v1.ConvertToSearchString(callerID, term)
      else
        searchString = itemName
      end
      table.insert(searchStrings, searchString)
      addedCount = addedCount + 1
    end
  end

  if addedCount == 0 then
    return false, "No valid items to add"
  end

  local success = pcall(function()
    Auctionator.API.v1.CreateShoppingList(callerID, listName, searchStrings)
  end)

  if success then
    local qtyText = hasQuantitySupport and " with quantities" or ""
    return true, string.format("Added %d items%s to Auctionator list '%s'", addedCount, qtyText, listName)
  else
    return false, "Failed to create Auctionator shopping list"
  end
end

function Export.ExportQueueToTSM()
  if not DecorAH_Queue then
    return false, "DecorAH_Queue not available"
  end

  if not TSM_API then
    return false, "TSM not installed"
  end

  local materials = DecorAH_Queue.GetTotalMaterials()
  local listString = Export.GenerateTSMList(materials, "HomeDecor Queue")

  if listString == "" then
    return false, "No materials in queue"
  end

  return true, listString
end

function Export.ExportQueueToAuctionator()
  if not DecorAH_Queue then
    return false, "DecorAH_Queue not available"
  end

  local materials = DecorAH_Queue.GetTotalMaterials()

  if not materials or not next(materials) then
    return false, "No materials in queue"
  end

  if Auctionator and Auctionator.API and Auctionator.API.v1 then
    return Export.CreateAuctionatorShoppingList(materials, "HomeDecor")
  else
    local listString = Export.GenerateAuctionatorList(materials, "HomeDecor")
    if listString == "" or listString == "HomeDecor" then
      return false, "No materials to export"
    end
    return true, listString
  end
end

function Export.GenerateTextList(materials)
  if not materials or type(materials) ~= "table" then return "" end

  local lines = {}
  local itemNames = {}

  for itemID, count in pairs(materials) do
    local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
    if name and name ~= "" then
      table.insert(itemNames, {name = name, count = count, itemID = itemID})
    end
  end

  table.sort(itemNames, function(a, b) return a.name < b.name end)

  table.insert(lines, "Shopping List:")
  table.insert(lines, "")

  for _, item in ipairs(itemNames) do
    local price = PriceSource and PriceSource.GetItemPrice(item.itemID)
    local priceStr = ""

    if price and price > 0 then
      local totalPrice = price * item.count
      priceStr = string.format(" (%s)",
        PriceSource.FormatGold and PriceSource.FormatGold(totalPrice) or tostring(totalPrice))
    end

    table.insert(lines, string.format("%dx %s%s", item.count, item.name, priceStr))
  end

  return table.concat(lines, "\n")
end

function Export.ExportSingleItem(itemID, materials, count)
  if not materials then return "" end

  count = count or 1
  local matTable = {}

  for _, mat in ipairs(materials) do
    local matID = mat.itemID or mat.id
    local matCount = (mat.count or mat.qty or mat.amount or 1) * count
    matTable[matID] = (matTable[matID] or 0) + matCount
  end

  return Export.GenerateTextList(matTable)
end

function Export.CalculateTotalCost(materials)
  local totalCost = 0
  local withPrice = 0
  local withoutPrice = 0

  for itemID, count in pairs(materials or {}) do
    local price = PriceSource and PriceSource.GetItemPrice(itemID)

    if price and price > 0 then
      totalCost = totalCost + (price * count)
      withPrice = withPrice + 1
    else
      withoutPrice = withoutPrice + 1
    end
  end

  return totalCost, withPrice, withoutPrice
end

return Export
