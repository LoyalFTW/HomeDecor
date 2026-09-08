local _, NS = ...

local MarketData = {}
NS.Systems.MarketData = MarketData

local LUMBER_NAMES = {
  [245586] = "Ironwood",
  [242691] = "Olemba",
  [251762] = "Coldwind",
  [251764] = "Ashwood",
  [251763] = "Bamboo",
  [251766] = "Shadowmoon",
  [251767] = "Fel-Touched",
  [251768] = "Darkpine",
  [251772] = "Arden",
  [251773] = "Dragonpine",
  [248012] = "Dornic Fir",
  [256963] = "Thalassian",
}

local reagentCache = {}
local emptyReagents = {}
local candidates
local candidatesRevision
local priceCache = {}
local priceCacheSignature
local warmToken = 0
local warmRunning = false

local function PriceKey(candidate)
  if not candidate then return nil end
  return tostring(candidate.itemID or "") .. ":" .. tostring(candidate.skillID or "")
end

local function PriceSignature()
  local source = NS.Systems.PriceSource
  local revision = source and source.GetRevision and source.GetRevision() or 0
  local preferred = source and source.GetPreferredSource and source.GetPreferredSource() or "auto"
  return tostring(revision) .. ":" .. tostring(preferred or "auto")
end

local function PreparePriceCache()
  local signature = PriceSignature()
  if priceCacheSignature ~= signature then
    wipe(priceCache)
    priceCacheSignature = signature
  end
  return signature
end

function MarketData:GetLumberNames()
  return LUMBER_NAMES
end

function MarketData:GetReagents(entry)
  if type(entry) ~= "table" then return {} end
  if type(entry.reagents) == "table" and #entry.reagents > 0 then return entry.reagents end
  local skillID = entry.skillID or (entry.source and entry.source.skillID)
  if not skillID then return {} end
  if reagentCache[skillID] ~= nil then return reagentCache[skillID] or emptyReagents end
  local reagents = {}
  if C_TradeSkillUI and C_TradeSkillUI.GetRecipeSchematic then
    local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, skillID, false)
    if ok and schematic and schematic.reagentSlotSchematics then
      for _, slot in ipairs(schematic.reagentSlotSchematics) do
        local reagent = slot.reagents and slot.reagents[1]
        if reagent and reagent.itemID then reagents[#reagents + 1] = { itemID = reagent.itemID, count = slot.quantityRequired or 1 } end
      end
    end
  end
  reagentCache[skillID] = #reagents > 0 and reagents or false
  return #reagents > 0 and reagents or emptyReagents
end

function MarketData:InvalidateRecipes()
  wipe(reagentCache)
end

function MarketData:InvalidatePrices()
  wipe(priceCache)
  priceCacheSignature = PriceSignature()
  warmToken = warmToken + 1
  warmRunning = false
end

function MarketData:GetCachedPrice(candidate)
  PreparePriceCache()
  local key = PriceKey(candidate)
  return key and priceCache[key] or nil
end

function MarketData:BuildCandidates()
  local catalog = NS.Systems.Catalog
  local revision = catalog and catalog.revision or 0
  if candidates and candidatesRevision == revision then return candidates end
  candidates = {}
  candidatesRevision = revision
  local seen = {}
  for _, entry in ipairs(catalog and catalog.ordered or {}) do
    if entry.sourceType == "profession" or entry.category == "Professions" then
      local itemID = tonumber(entry.itemID)
      local skillID = tonumber(entry.skillID)
      local profession = entry.profession or "Other"
      local expansion = entry.expansion or "Other"
      local key = tostring(profession) .. "|" .. tostring(expansion) .. "|" .. tostring(entry.decorID or itemID)
      if itemID and itemID > 0 and not seen[key] then
        seen[key] = true
        candidates[#candidates + 1] = { entry = entry, itemID = itemID, skillID = skillID, profession = profession, expansion = expansion }
      end
    end
  end
  return candidates
end

function MarketData:Price(candidate, result)
  local source = NS.Systems.PriceSource
  local reagents = self:GetReagents(candidate.entry)
  local totalCost = 0
  local missingPrices = 0
  local lumberCount = 0
  local lumberName
  for _, reagent in ipairs(reagents) do
    local reagentID = tonumber(reagent.itemID)
    local quantity = tonumber(reagent.count or reagent.qty or reagent.amount) or 1
    local price = source and source.GetItemPrice and source.GetItemPrice(reagentID)
    if price then totalCost = totalCost + price * quantity else missingPrices = missingPrices + 1 end
    if LUMBER_NAMES[reagentID] then lumberName = LUMBER_NAMES[reagentID] lumberCount = lumberCount + quantity end
  end
  local estimatedCost = #reagents > 0 and missingPrices < #reagents and totalCost or nil
  local sell, provider = source and source.GetItemPrice and source.GetItemPrice(candidate.itemID)
  local profit = sell and estimatedCost and sell - estimatedCost or nil
  local margin = sell and sell > 0 and profit and profit / sell * 100 or nil
  local ppl = profit and lumberCount > 0 and profit / lumberCount or nil
  local fallback = candidate.entry.title
  if type(fallback) ~= "string" or fallback == "" then fallback = nil end
  if not fallback and NS.Systems.Housing and NS.Systems.Housing.GetDisplay then
    local displayName = NS.Systems.Housing:GetDisplay(candidate.entry)
    if displayName and issecretvalue and issecretvalue(displayName) then displayName = nil end
    if displayName and canaccessvalue and not canaccessvalue(displayName) then displayName = nil end
    if type(displayName) == "string" and displayName ~= "" and not displayName:match("^Decor #%d+$") then fallback = displayName end
  end
  local name = NS.Systems.ItemResolver:GetName(candidate.itemID, fallback)
  local knowledge = NS.Systems.RecipeKnowledge
  local known = knowledge and knowledge:IsCurrentKnown(candidate.skillID) or false
  if candidate.skillID then
    local knownOK, liveKnown
    if C_TradeSkillUI and C_TradeSkillUI.IsRecipeLearned then
      knownOK, liveKnown = pcall(C_TradeSkillUI.IsRecipeLearned, candidate.skillID)
    elseif C_TradeSkillUI and C_TradeSkillUI.IsRecipeKnown then
      knownOK, liveKnown = pcall(C_TradeSkillUI.IsRecipeKnown, candidate.skillID)
    elseif C_Professions and C_Professions.IsRecipeKnown then
      knownOK, liveKnown = pcall(C_Professions.IsRecipeKnown, candidate.skillID)
    end
    if knownOK and liveKnown == true then known = true end
    if known and knowledge then knowledge:Observe(candidate.skillID, true) end
  end
  local crafters = {}
  local altKnown = false
  if knowledge then crafters, altKnown = knowledge:GetCrafters(candidate.skillID) end
  result = result or {}
  wipe(result)
  result.entry = candidate.entry
  result.itemID = candidate.itemID
  result.skillID = candidate.skillID
  result.name = name
  result.searchName = name:lower()
  result.profession = candidate.profession
  result.expansion = candidate.expansion
  result.crafter = #crafters > 0 and table.concat(crafters, ", ") or "-"
  result.known = known
  result.altKnown = altKnown == true
  result.lumber = lumberName or "-"
  result.lumberCount = lumberCount
  result.cost = estimatedCost
  result.sell = sell
  result.profit = profit
  result.ppl = ppl
  result.margin = margin
  result.provider = provider
  result.missingPrices = missingPrices
  result.noSchematic = #reagents == 0
  PreparePriceCache()
  priceCache[PriceKey(candidate)] = result
  return result
end


function MarketData:WarmPrices()
  if warmRunning then return end
  local source = NS.Systems.PriceSource
  local available = source and source.GetAvailableSources and source.GetAvailableSources() or {}
  if #available == 0 then return end
  PreparePriceCache()
  local list = self:BuildCandidates()
  warmToken = warmToken + 1
  local token = warmToken
  local index = 1
  warmRunning = true
  local function step()
    if token ~= warmToken then return end
    local started = debugprofilestop and debugprofilestop()
    local processed = 0
    while index <= #list do
      local candidate = list[index]
      if not MarketData:GetCachedPrice(candidate) then
        MarketData:Price(candidate, {})
        processed = processed + 1
      end
      index = index + 1
      if processed >= 4 then break end
      if started and debugprofilestop() - started >= 2 then break end
    end
    if index <= #list then
      C_Timer.After(0, step)
    else
      warmRunning = false
      NS.SendMessage("HOMEDECOR_PRICE_CACHE_READY")
    end
  end
  step()
end

local function QueueWarmPrices()
  C_Timer.After(1, function() MarketData:WarmPrices() end)
end

NS.SafeRegisterEvent(MarketData, "PLAYER_LOGIN", QueueWarmPrices)
NS.SafeRegisterEvent(MarketData, "ADDON_LOADED", function(name)
  if name == "Auctionator" or name == "TradeSkillMaster" or name == "TSM_AppHelper" then QueueWarmPrices() end
end)
NS.OnMessage("HOMEDECOR_CATALOG_UPDATED", QueueWarmPrices)

return MarketData
