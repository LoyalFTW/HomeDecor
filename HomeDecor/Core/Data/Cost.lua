local _, NS = ...

local Cost = {}
NS.Systems.Cost = Cost

local function FormatEntry(currency, currencyType, itemID)
  local amount = tonumber(currency) or currency
  if currencyType == "money" and type(amount) == "number" and _G.GetCoinTextureString then
    return _G.GetCoinTextureString(amount)
  end
  if itemID then
    local name = NS.Systems.ItemResolver and NS.Systems.ItemResolver:GetName(tonumber(itemID))
    if name == "Loading..." then name = nil end
    return tostring(amount) .. " " .. tostring(name or ("Item #" .. tostring(itemID)))
  end
  local currencyID = tonumber(currencyType)
  local info = currencyID and _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfo(currencyID)
  local name = info and info.name or currencyType
  return tostring(amount) .. (name and " " .. tostring(name) or "")
end

function Cost:Format(record)
  if not record then return nil end
  if type(record.costs) == "table" and #record.costs > 0 then
    local values = {}
    for index = 1, #record.costs do
      local cost = record.costs[index]
      if type(cost) == "table" and cost.currency ~= nil then
        values[#values + 1] = FormatEntry(cost.currency, cost.currencytype or cost.currencyType, cost.itemID)
      end
    end
    if #values > 0 then return table.concat(values, " + ") end
  end
  if record.currency == nil then return nil end
  return FormatEntry(record.currency, record.currencyType)
end
