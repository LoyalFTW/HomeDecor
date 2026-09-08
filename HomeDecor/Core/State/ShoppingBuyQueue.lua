local _, NS = ...

local ShoppingBuyQueue = { running = false, purchased = 0, total = 0, generation = 0 }
NS.Systems.ShoppingBuyQueue = ShoppingBuyQueue

local MAX_PURCHASES = 500

local function BagCount(itemID)
  if not itemID or not _G.C_Item or not _G.C_Item.GetItemCount then return 0 end
  local ok, count = pcall(_G.C_Item.GetItemCount, itemID, true, false, true, true)
  return ok and tonumber(count) or 0
end

local function HousingCount(itemID)
  local api = _G.C_HousingCatalog and _G.C_HousingCatalog.GetCatalogEntryInfoByItem
  if type(api) ~= "function" then return 0 end
  local ok, info = pcall(api, itemID, true)
  if not ok or type(info) ~= "table" then ok, info = pcall(api, itemID) end
  if not ok or type(info) ~= "table" then return 0 end
  return (tonumber(info.totalNumStored or info.quantity) or 0) + (tonumber(info.remainingRedeemable) or 0) + (tonumber(info.totalNumPlaced or info.numPlaced) or 0)
end

local function Balance(cost)
  if cost.kind == "gold" then return type(_G.GetMoney) == "function" and tonumber(_G.GetMoney()) or 0 end
  if cost.kind == "currency" then
    local api = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfo
    if type(api) ~= "function" then return 0 end
    local ok, info = pcall(api, cost.id)
    return ok and type(info) == "table" and tonumber(info.quantity) or 0
  end
  if cost.kind == "item" and _G.C_Item and type(_G.C_Item.GetItemCount) == "function" then
    local ok, count = pcall(_G.C_Item.GetItemCount, cost.id, false, false, true, false)
    return ok and tonumber(count) or 0
  end
  return 0
end

local function Notify(state, reason)
  NS.SendMessage("HOMEDECOR_SHOPPING_BUY_UPDATED", state, ShoppingBuyQueue.purchased, ShoppingBuyQueue.total, reason)
end

local function Chat(message, errorMessage)
  if not _G.DEFAULT_CHAT_FRAME then return end
  local color = errorMessage and "|cffff6666" or "|cff33ff99"
  _G.DEFAULT_CHAT_FRAME:AddMessage(color .. "HomeDecor:|r " .. tostring(message))
end

function ShoppingBuyQueue:IsRunning()
  return self.running == true
end

function ShoppingBuyQueue:GetProgress()
  return self.purchased or 0, self.total or 0
end

function ShoppingBuyQueue:Cancel(reason)
  if not self.running then return false end
  self.running = false
  self.awaiting = false
  self.generation = self.generation + 1
  reason = reason or "cancelled"
  Notify("stopped", reason)
  Chat("Shopping purchase stopped: " .. reason .. " (" .. tostring(self.purchased) .. " of " .. tostring(self.total) .. " bought).", true)
  return true
end

function ShoppingBuyQueue:Finish()
  self.running = false
  self.awaiting = false
  self.generation = self.generation + 1
  Notify("finished")
  Chat("Bought " .. tostring(self.purchased) .. " shopping-list item" .. (self.purchased == 1 and "." or "s."))
end

function ShoppingBuyQueue:Confirm()
  if not self.running or not self.awaiting or not self.current then return end
  local unit = self.current
  self.awaiting = false
  self.current = nil
  self.purchased = self.purchased + 1
  if not NS.Systems.Lists:AdjustQuantity(unit.record, -1, self.listID) then self:Cancel("the shopping list changed") return end
  Notify("progress")
  if _G.C_Timer and _G.C_Timer.After then
    _G.C_Timer.After(0.3, function() ShoppingBuyQueue:BuyNext() end)
  else
    self:BuyNext()
  end
end

function ShoppingBuyQueue:CheckArrival()
  if not self.running or not self.awaiting or not self.current then return end
  local unit = self.current
  if BagCount(unit.itemID) > unit.bagBefore or HousingCount(unit.itemID) > unit.housingBefore then self:Confirm() end
end

function ShoppingBuyQueue:BuyNext()
  if not self.running or self.awaiting then return end
  if not _G.MerchantFrame or not _G.MerchantFrame:IsShown() then self:Cancel("the vendor closed") return end
  local nextIndex = self.purchased + 1
  if nextIndex > self.total then self:Finish() return end
  local unit = self.units[nextIndex]
  if not unit then self:Finish() return end
  unit.bagBefore = BagCount(unit.itemID)
  unit.housingBefore = HousingCount(unit.itemID)
  self.current = unit
  self.awaiting = true
  self.generation = self.generation + 1
  local generation = self.generation
  local ok = type(_G.BuyMerchantItem) == "function" and pcall(_G.BuyMerchantItem, unit.index, 1)
  if not ok then self:Cancel("the purchase could not be started") return end
  if _G.C_Timer and _G.C_Timer.After then
    local function Poll()
      if not ShoppingBuyQueue.running or not ShoppingBuyQueue.awaiting or ShoppingBuyQueue.generation ~= generation then return end
      ShoppingBuyQueue:CheckArrival()
      if ShoppingBuyQueue.running and ShoppingBuyQueue.awaiting and ShoppingBuyQueue.generation == generation then _G.C_Timer.After(0.2, Poll) end
    end
    _G.C_Timer.After(0.2, Poll)
    _G.C_Timer.After(8, function()
      if not ShoppingBuyQueue.running or not ShoppingBuyQueue.awaiting or ShoppingBuyQueue.generation ~= generation then return end
      ShoppingBuyQueue:CheckArrival()
      if ShoppingBuyQueue.running and ShoppingBuyQueue.awaiting and ShoppingBuyQueue.generation == generation then ShoppingBuyQueue:Cancel("the last item was not confirmed") end
    end)
  end
end

function ShoppingBuyQueue:Start(rows, listID)
  if self.running then return false, "A shopping purchase is already running." end
  if not _G.MerchantFrame or not _G.MerchantFrame:IsShown() then return false, "Open a vendor first." end
  local units = {}
  local totals = {}
  for _, row in ipairs(type(rows) == "table" and rows or {}) do
    local quantity = math.max(0, math.floor(tonumber(row.quantity) or 0))
    if quantity > 0 and row.record and tonumber(row.index) then
      if type(row.costs) ~= "table" or #row.costs == 0 then
        return false, "Some selected items use an unsupported cost."
      end
      for _, cost in ipairs(row.costs) do
        local amount = math.max(0, tonumber(cost.amount) or 0) * quantity
        local key = tostring(cost.kind) .. ":" .. tostring(cost.id or 0)
        local total = totals[key]
        if not total then
          total = { kind = cost.kind, id = cost.id, name = cost.name, amount = 0 }
          totals[key] = total
        end
        total.amount = total.amount + amount
      end
      for _ = 1, quantity do
        if #units >= MAX_PURCHASES then return false, "Buy All is limited to 500 items at a time." end
        units[#units + 1] = { index = tonumber(row.index), itemID = tonumber(row.itemID), record = row.record }
      end
    end
  end
  if #units == 0 then return false, "This vendor has no supported items from the active shopping list." end
  for _, cost in pairs(totals) do
    local balance = Balance(cost)
    if cost.amount > balance then return false, "Not enough " .. tostring(cost.name or cost.kind) .. " (need " .. tostring(cost.amount) .. ", have " .. tostring(balance) .. ")." end
  end
  self.units = units
  self.listID = listID
  self.total = #units
  self.purchased = 0
  self.running = true
  self.awaiting = false
  self.generation = self.generation + 1
  Notify("started")
  self:BuyNext()
  return true
end

local eventOwner = {}
NS.SafeRegisterEvent(eventOwner, "HOUSING_STORAGE_ENTRY_UPDATED", function() ShoppingBuyQueue:CheckArrival() end)
NS.SafeRegisterEvent(eventOwner, "HOUSING_STORAGE_UPDATED", function() ShoppingBuyQueue:CheckArrival() end)
NS.SafeRegisterEvent(eventOwner, "NEW_HOUSING_ITEM_ACQUIRED", function() ShoppingBuyQueue:CheckArrival() end)
NS.SafeRegisterEvent(eventOwner, "BAG_UPDATE_DELAYED", function() ShoppingBuyQueue:CheckArrival() end)
NS.SafeRegisterEvent(eventOwner, "MERCHANT_CLOSED", function()
  if ShoppingBuyQueue.running then ShoppingBuyQueue:Cancel("the vendor closed") end
end)
