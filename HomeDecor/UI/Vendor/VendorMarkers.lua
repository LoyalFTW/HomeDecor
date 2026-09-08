local _, NS = ...

NS.UI = NS.UI or {}
local VendorMarkers = {}
NS.UI.VendorMarkers = VendorMarkers

local function ItemID(index)
  if _G.GetMerchantItemID then
    local ok, itemID = pcall(_G.GetMerchantItemID, index)
    if ok and tonumber(itemID) then return tonumber(itemID) end
  end
  local link = _G.GetMerchantItemLink and _G.GetMerchantItemLink(index)
  local itemID = type(link) == "string" and link:match("item:(%d+)")
  return tonumber(itemID)
end

local function MerchantButton(index)
  return _G["MerchantItem" .. tostring(index) .. "ItemButton"]
    or _G["MerchantItem" .. tostring(index)]
    or _G["MerchantFrameItem" .. tostring(index)]
end

function VendorMarkers:Ensure(button)
  if button.hdRebuildMarker then return button.hdRebuildMarker end
  local marker = button:CreateTexture(nil, "OVERLAY", nil, 7)
  marker:SetSize(14, 14)
  marker:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 1, 1)
  if marker.SetAtlas then
    marker:SetAtlas("common-icon-checkmark", true)
  else
    marker:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  end
  marker:SetVertexColor(0.4, 0.95, 0.5, 1)
  marker:Hide()
  local favorite = NS.UI.FavoriteStar:Create(button, 16)
  favorite:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 2)
  marker.favorite = favorite
  button.hdRebuildMarker = marker
  return marker
end

function VendorMarkers:HideAll()
  local perPage = _G.MERCHANT_ITEMS_PER_PAGE or 10
  for index = 1, perPage do
    local button = MerchantButton(index)
    local marker = button and button.hdRebuildMarker
    if marker then
      marker:Hide()
      marker.favorite:Hide()
    end
  end
end

function VendorMarkers:Refresh()
  if NS.Systems.Settings and not NS.Systems.Settings:GetValue("vendorMarkers", true) then
    self:HideAll()
    return
  end
  local merchant = _G.MerchantFrame
  if not merchant or not merchant:IsShown() then
    self:HideAll()
    return
  end
  local perPage = _G.MERCHANT_ITEMS_PER_PAGE or 10
  local page = merchant.page or 1
  local total = _G.GetMerchantNumItems and _G.GetMerchantNumItems() or 0
  local missingItemID = false
  for index = 1, perPage do
    local button = MerchantButton(index)
    if button then
      local marker = self:Ensure(button)
      local merchantIndex = (page - 1) * perPage + index
      local itemID = index <= total and ItemID(merchantIndex) or nil
      if index <= total and not itemID then missingItemID = true end
      local records = itemID and NS.Systems.VendorIndex:GetByItem(itemID) or nil
      if records then
        local owned = NS.Systems.Collection:IsItemOwned(itemID)
        if owned == nil then
          owned = false
          for recordIndex = 1, #records do
            local _, _, isOwned = NS.Systems.Housing:GetDisplay(records[recordIndex])
            owned = owned or isOwned
          end
        end
        marker:SetVertexColor(0.4, 0.95, 0.5, 1)
        marker:SetShown(owned)
        marker.favorite:SetRecord(records[1])
      else
        marker:Hide()
        marker.favorite:SetRecord(nil)
      end
    end
  end
  if not missingItemID then self.retryCount = 0 end
  if missingItemID and (self.retryCount or 0) < 3 and not self.retryPending and _G.C_Timer and _G.C_Timer.After then
    self.retryCount = (self.retryCount or 0) + 1
    self.retryPending = true
    _G.C_Timer.After(0.15, function()
      VendorMarkers.retryPending = false
      VendorMarkers:Refresh()
    end)
  end
end

function VendorMarkers:Debug()
  local merchant = _G.MerchantFrame
  local perPage = _G.MERCHANT_ITEMS_PER_PAGE or 10
  local page = merchant and merchant.page or 1
  local total = _G.GetMerchantNumItems and _G.GetMerchantNumItems() or 0
  local buttons, known, owned = 0, 0, 0
  for index = 1, perPage do
    if MerchantButton(index) then buttons = buttons + 1 end
    local records = index <= total and NS.Systems.VendorIndex:GetByItem(ItemID((page - 1) * perPage + index)) or nil
    if records then
      known = known + 1
      if NS.Systems.Collection:IsItemOwned(ItemID((page - 1) * perPage + index)) then owned = owned + 1 end
    end
  end
  if _G.DEFAULT_CHAT_FRAME then
    _G.DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffed9f2fHomeDecor|r vendor rows %d | known decor %d | collected %d | merchant items %d", buttons, known, owned, total))
  end
end

local events = CreateFrame("Frame")
events:RegisterEvent("MERCHANT_SHOW")
events:RegisterEvent("MERCHANT_UPDATE")
events:RegisterEvent("MERCHANT_CLOSED")
local queued = false
local function QueueRefresh()
  if queued then return end
  queued = true
  local function refresh()
    queued = false
    VendorMarkers:Refresh()
  end
  if _G.C_Timer and _G.C_Timer.After then
    _G.C_Timer.After(0, refresh)
  else
    refresh()
  end
end
events:SetScript("OnEvent", function(_, event)
  if event == "MERCHANT_CLOSED" then
    queued = false
    VendorMarkers.retryPending = false
    VendorMarkers.retryCount = 0
    VendorMarkers:HideAll()
    return
  end
  VendorMarkers.retryCount = 0
  QueueRefresh()
end)

if _G.hooksecurefunc and _G.MerchantFrame_Update then
  _G.hooksecurefunc("MerchantFrame_Update", QueueRefresh)
end
if _G.hooksecurefunc and _G.MerchantFrame_UpdateMerchantInfo then
  _G.hooksecurefunc("MerchantFrame_UpdateMerchantInfo", QueueRefresh)
end
