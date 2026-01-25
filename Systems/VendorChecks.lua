local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local VendorChecks = {}
NS.Systems.VendorChecks = VendorChecks

local Collection = NS.Systems and NS.Systems.Collection

local npcItems = nil
local built = false

local CHECK_ATLAS = "common-icon-checkmark"
local CHECK_FALLBACK = "Interface\\RaidFrame\\ReadyCheck-Ready"

local function hdCanAccess(v)
  if v == nil then return false end
  if issecretvalue and issecretvalue(v) then return false end
  if canaccessvalue and not canaccessvalue(v) then return false end
  return true
end


local function getNpcIDFromGUID(guid)
  if not hdCanAccess(guid) then return nil end
  if type(guid) ~= "string" then
    local ok, s = pcall(tostring, guid)
    if not ok or not s or not hdCanAccess(s) then return nil end
    guid = s
  end
  local ok, unitType, _, _, _, _, npcID = pcall(strsplit, "-", guid)
  if not ok then return nil end
  if unitType ~= "Creature" and unitType ~= "Vehicle" and unitType ~= "Pet" then return nil end
  return npcID and tonumber(npcID) or nil
end

local function itemIDFromLink(link)
  if not hdCanAccess(link) then return nil end
  if type(link) ~= "string" then
    local ok, s = pcall(tostring, link)
    if not ok or not s then return nil end
    link = s
  end
  local ok, id = pcall(string.match, link, "item:(%d+)")
  if not ok then return nil end
  return id and tonumber(id) or nil
end

local function BuildIndex()
  npcItems = {}

  local vendors = NS.Data and NS.Data.Vendors
  if type(vendors) ~= "table" then
    built = true
    return
  end

  for _, exp in pairs(vendors) do
    for _, zone in pairs(exp or {}) do
      for _, vendor in ipairs(zone or {}) do
        local src = vendor and vendor.source
        local npcID = src and tonumber(src.id)
        if npcID then
          local map = npcItems[npcID]
          if not map then
            map = {}
            npcItems[npcID] = map
          end

          for _, it in ipairs(vendor.items or {}) do
            local itemID = it and it.source and tonumber(it.source.itemID)
            local decorID = it and tonumber(it.decorID)
            if itemID and decorID then
              map[itemID] = decorID
            end
          end
        end
      end
    end
  end

  built = true
end

function VendorChecks:Ensure()
  if not built then BuildIndex() end
end

local function HideMerchantCheckmarks()
  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  for i = 1, perPage do
    local button = _G["MerchantItem"..i.."ItemButton"]
    if button and button.hdCheckmark then
      button.hdCheckmark:Hide()
    end
  end
end

local function EnsureCheck(button)
  if button.hdCheckmark then return button.hdCheckmark end

  local t = button:CreateTexture(nil, "OVERLAY", nil, 7)
  t:SetSize(18, 18)
  t:SetPoint("BOTTOM", 0, -8) 

  if t.SetAtlas then
    t:SetAtlas(CHECK_ATLAS, true)
  else
    t:SetTexture(CHECK_FALLBACK)
  end

  t:Hide()
  button.hdCheckmark = t
  return t
end

local function UpdateMerchantChecks()
  if not MerchantFrame or not MerchantFrame:IsShown() then return end
  if not (Collection and Collection.IsCollected) then return end

  local guid = UnitGUID("npc")
  if not guid then return end

  local npcID = getNpcIDFromGUID(guid)
  if not npcID then return end

  VendorChecks:Ensure()

  local map = npcItems and npcItems[npcID]
  if not map then
    HideMerchantCheckmarks()
    return
  end

  local numMerchantItems = GetMerchantNumItems() or 0
  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  local page = (MerchantFrame and MerchantFrame.page) or 1

  for i = 1, perPage do
    local button = _G["MerchantItem"..i.."ItemButton"]
    if button and button:IsShown() then
      local check = EnsureCheck(button)

      local checked = false
      local index = (((page - 1) * perPage) + i)

      if index <= numMerchantItems then
        local link = GetMerchantItemLink(index)
        local itemID = itemIDFromLink(link)
        local decorID = itemID and map[itemID]
        if decorID then
          checked = Collection:IsCollected({ decorID = decorID, source = { type = "vendor" } }) and true or false
        end
      end

      check:SetShown(checked)
    end
  end
end

local function HookMerchantFrame()
  if not hooksecurefunc or not MerchantFrame_Update then return end

  hooksecurefunc("MerchantFrame_Update", function()
    UpdateMerchantChecks()
  end)

  if MerchantNextPageButton and MerchantNextPageButton.HookScript then
    MerchantNextPageButton:HookScript("OnClick", function()
      C_Timer.After(0, UpdateMerchantChecks)
    end)
  end
  if MerchantPrevPageButton and MerchantPrevPageButton.HookScript then
    MerchantPrevPageButton:HookScript("OnClick", function()
      C_Timer.After(0, UpdateMerchantChecks)
    end)
  end
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:RegisterEvent("MERCHANT_SHOW")
init:RegisterEvent("MERCHANT_UPDATE")
init:RegisterEvent("MERCHANT_CLOSED")
init:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")

init:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    HookMerchantFrame()
    return
  end

  if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
    C_Timer.After(0, UpdateMerchantChecks)
    return
  end

  if event == "MERCHANT_CLOSED" then
    HideMerchantCheckmarks()
    return
  end

  if event == "HOUSE_DECOR_ADDED_TO_CHEST" then
    if MerchantFrame and MerchantFrame:IsShown() then
      C_Timer.After(0, UpdateMerchantChecks)
    end
    return
  end
end)

return VendorChecks
