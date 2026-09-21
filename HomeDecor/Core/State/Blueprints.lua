local ADDON, NS = ...

NS.Systems = NS.Systems or {}

local Blueprints = {}
NS.Systems.Blueprints = Blueprints

local CONTENT_LABELS = {
  [1] = "House Type",
  [2] = "Rooms",
  [3] = "Decor",
  [4] = "Dyes",
  [5] = "Fixtures",
}

local BUDGET_LABELS = {
  [0] = "Rooms",
  [1] = "Decor",
  [2] = "Pets",
}

local REQUIREMENT_FLAGS = {
  { value = 1, label = "Insufficient placement budget" },
  { value = 2, label = "Missing room" },
  { value = 4, label = "Missing fixture" },
  { value = 8, label = "Missing decor" },
  { value = 16, label = "Missing dye" },
  { value = 32, label = "Exterior faction does not match" },
  { value = 64, label = "House type is locked" },
  { value = 128, label = "House size is too small" },
}

local EXPORT_KIND = {
  full = "House",
  room = "Room",
  interior = "Interior",
  exterior = "Exterior",
}

local function trim(value)
  if type(value) ~= "string" then return "" end
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function copyEntry(entry, contentType)
  local total = math.max(0, tonumber(entry and (entry.total or entry.quantity or entry.count)) or 0)
  local missing = math.max(0, tonumber(entry and (entry.numMissing or entry.missing)) or 0)
  return {
    contentType = contentType,
    recordID = tonumber(entry and (entry.recordID or entry.recordId or entry.id)),
    name = entry and (entry.name or entry.displayName) or "Requirement",
    total = total,
    numMissing = missing,
    invalid = entry and entry.invalid and true or false,
    tooltip = entry and entry.tooltip or nil,
  }
end

local function profile()
  local p = NS.Systems.Database:GetProfile()
  if not p then return nil end
  p.blueprints = p.blueprints or { nextID = 1, saved = {} }
  p.blueprints.nextID = tonumber(p.blueprints.nextID) or 1
  p.blueprints.saved = p.blueprints.saved or {}
  return p.blueprints
end

local function notify(rec)
  if Blueprints.OnLibraryChanged then Blueprints.OnLibraryChanged() end
  if NS.SendMessage then NS.SendMessage("HOMEDECOR_BLUEPRINTS_UPDATED", rec) end
end

local function chat(message, danger)
  if not message or not DEFAULT_CHAT_FRAME then return end
  local color = danger and "|cffff6666" or "|cff33ff99"
  DEFAULT_CHAT_FRAME:AddMessage(color .. "HomeDecor Blueprints:|r " .. tostring(message))
end

local function resultText(result, fallback)
  local map = _G.HousingResultToErrorText
  return map and map[result] or fallback
end

local function getEnum(kind)
  local enum = _G.Enum and _G.Enum.HousingBlueprintType
  local key = EXPORT_KIND[kind]
  return enum and key and enum[key]
end

local function resolveItemID(contentType, recordID)
  if contentType == 4 then return recordID end
  if contentType ~= 3 then return nil end
  local index = NS.Systems and NS.Systems.GlobalIndex
  if index and index.Ensure then index:Ensure() end
  local item = index and index.byItemID and index.byItemID[recordID]
  local source = item and item.source
  local itemID = tonumber(item and (item.itemID or (source and (source.itemID or source.itemId))))
  if itemID then return itemID end
  local Catalog = NS.Systems and NS.Systems.Catalog
  for _, record in ipairs((Catalog and Catalog.ordered) or {}) do
    if tonumber(record.decorID) == tonumber(recordID) then
      return tonumber(record.itemID)
    end
  end
end

local function requirementsFromInfo(info)
  local req = { groups = {}, items = {}, missingQty = 0, missingItems = 0, acquirableMissingQty = 0 }
  for _, sourceGroup in ipairs((info and info.contentGroups) or {}) do
    local contentType = tonumber(sourceGroup.contentType)
    local group = {
      contentType = contentType,
      label = CONTENT_LABELS[contentType] or "Other",
      items = {},
      total = 0,
      missingQty = 0,
      invalidCount = 0,
    }
    for _, sourceEntry in ipairs(sourceGroup.entries or {}) do
      local entry = copyEntry(sourceEntry, contentType)
      entry.itemID = resolveItemID(contentType, entry.recordID)
      entry.have = math.max(0, entry.total - entry.numMissing)
      entry.needed = entry.total
      entry.missing = entry.numMissing
      entry.kind = group.label
      group.items[#group.items + 1] = entry
      req.items[#req.items + 1] = entry
      group.total = group.total + entry.total
      group.missingQty = group.missingQty + entry.numMissing
      if entry.invalid then group.invalidCount = group.invalidCount + 1 end
      req.missingQty = req.missingQty + entry.numMissing
      if entry.numMissing > 0 then req.missingItems = req.missingItems + 1 end
      if contentType == 3 or contentType == 4 then
        req.acquirableMissingQty = req.acquirableMissingQty + entry.numMissing
      end
    end
    if #group.items > 0 then req.groups[#req.groups + 1] = group end
  end
  return req
end

local function hasFlag(flags, value)
  flags = math.max(0, tonumber(flags) or 0)
  value = math.max(1, tonumber(value) or 1)
  if _G.bit and type(_G.bit.band) == "function" then return _G.bit.band(flags, value) ~= 0 end
  return math.floor(flags / value) % 2 == 1
end

local function requirementProblems(flags)
  local problems = {}
  for _, entry in ipairs(REQUIREMENT_FLAGS) do
    if hasFlag(flags, entry.value) then problems[#problems + 1] = entry.label end
  end
  return problems
end

local function copyBudgets(source, scope)
  local result = {}
  for key, value in pairs(type(source) == "table" and source or {}) do
    if type(value) == "table" then
      local budgetType = tonumber(value.budgetType)
      if budgetType == nil then budgetType = tonumber(key) end
      local cost = math.max(0, tonumber(value.cost) or 0)
      local current = tonumber(value.current)
      local maximum = tonumber(value.max)
      local projected = current and current + cost or nil
      result[#result + 1] = {
        scope = scope,
        budgetType = budgetType,
        label = BUDGET_LABELS[budgetType] or ("Budget " .. tostring(budgetType or "?")),
        cost = cost,
        current = current,
        maximum = maximum,
        projected = projected,
        excess = projected and maximum and math.max(0, projected - maximum) or 0,
      }
    end
  end
  table.sort(result, function(a, b) return (a.budgetType or 99) < (b.budgetType or 99) end)
  return result
end

local function summaryFromInfo(info, req)
  local summary = {
    type = Blueprints:GetTypeLabel(info and info.shareCode),
    rooms = 0,
    decor = 0,
    dyes = 0,
    fixtures = 0,
    missing = req.acquirableMissingQty,
    missingAll = req.missingQty,
    unmetRequirementFlags = tonumber(info and info.unmetRequirementFlags) or 0,
    blockingRequirementFlags = tonumber(info and info.blockingRequirementFlags) or 0,
    hasArchitectRooms = false,
  }
  for _, group in ipairs(req.groups) do
    if group.contentType == 2 then summary.rooms = summary.rooms + group.total end
    if group.contentType == 3 then summary.decor = summary.decor + group.total end
    if group.contentType == 4 then summary.dyes = summary.dyes + group.total end
    if group.contentType == 5 then summary.fixtures = summary.fixtures + group.total end
  end
  summary.hasArchitectRooms = summary.rooms > 0
  summary.problems = requirementProblems(summary.unmetRequirementFlags)
  summary.blockers = requirementProblems(summary.blockingRequirementFlags)
  summary.ready = summary.blockingRequirementFlags == 0
  summary.budgets = { interior = {}, exterior = {} }
  local budgetInfo = info and info.budgetInfo
  if type(budgetInfo) == "table" then
    summary.budgets.interior = copyBudgets(budgetInfo.interiorBudgets, "Interior")
    summary.budgets.exterior = copyBudgets(budgetInfo.exteriorBudgets, "Exterior")
    local total = 0
    for _, scope in ipairs({ summary.budgets.interior, summary.budgets.exterior }) do
      for _, budget in ipairs(scope) do total = total + budget.cost end
    end
    summary.budget = total
  end
  return summary
end

local function normalizeHouses(houses)
  if type(houses) ~= "table" then return {} end
  if type(houses.houseInfoList) == "table" then houses = houses.houseInfoList end
  if type(houses.houseInfos) == "table" then houses = houses.houseInfos end
  local result = {}
  for _, house in ipairs(houses) do
    if type(house) == "table" and house.houseGUID then result[#result + 1] = house end
  end
  return result
end

local function houseLabel(house, index)
  return house and (house.houseName or house.neighborhoodName or house.ownerName) or ("House " .. tostring(index or ""))
end

function Blueprints:IsClientSupported()
  local api = _G.C_HousingBlueprint
  return api and type(api.IsShareCodeValid) == "function" and type(api.RequestBlueprintContents) == "function"
end

function Blueprints:GetAvailability()
  local api = _G.C_HousingBlueprint
  local supported = self:IsClientSupported()
  local success = _G.Enum and _G.Enum.HousingResult and _G.Enum.HousingResult.Success or 0
  local exportReady = false
  if supported and type(api.GetExportAvailability) == "function" then
    local ok, result = pcall(api.GetExportAvailability)
    exportReady = ok and result == success
  elseif supported and type(api.ExportBlueprint) == "function" then
    exportReady = true
  end
  return { supported = supported and true or false, import = supported and true or false, export = exportReady }
end

function Blueprints:GetDB()
  return profile()
end

function Blueprints:GetSaved()
  local db = profile()
  local saved = db and db.saved or {}
  table.sort(saved, function(a, b)
    return (tonumber(a.updated) or tonumber(a.created) or 0) > (tonumber(b.updated) or tonumber(b.created) or 0)
  end)
  return saved
end

function Blueprints:GetByCode(code)
  code = trim(code)
  for _, rec in ipairs(self:GetSaved()) do
    if rec.code == code then return rec end
  end
end

function Blueprints:GetByID(id)
  local numericID = tonumber(id)
  for _, rec in ipairs(self:GetSaved()) do
    if numericID and tonumber(rec.id) == numericID then return rec end
    if type(id) == "string" and rec.code == id then return rec end
  end
end

function Blueprints:GetActive()
  local db = profile()
  return db and self:GetByID(db.activeID)
end

function Blueprints:SetActive(id)
  local db = profile()
  local rec = self:GetByID(id)
  if db and rec then db.activeID = rec.id end
  return rec
end

function Blueprints:GetTypeLabel(code)
  local api = _G.C_HousingBlueprint
  local enum = _G.Enum and _G.Enum.HousingBlueprintType
  if not (api and enum and type(api.GetBlueprintTypeForCode) == "function" and code) then return "Blueprint" end
  local ok, value = pcall(api.GetBlueprintTypeForCode, code)
  if not ok then return "Blueprint" end
  for _, key in ipairs({ "House", "Room", "Interior", "Exterior" }) do
    if enum[key] == value then return key end
  end
  return "Blueprint"
end

function Blueprints:SaveCode(code, name)
  code = trim(code)
  if code == "" then return nil, "Paste an official blueprint code first." end
  if not self:IsClientSupported() then return nil, "Official blueprint codes require the current housing blueprint API." end
  local ok, valid = pcall(_G.C_HousingBlueprint.IsShareCodeValid, code)
  if not ok or not valid then return nil, "That official blueprint code is not valid." end
  local db = profile()
  if not db then return nil, "Blueprint storage is not ready yet." end
  local rec = self:GetByCode(code)
  if not rec then
    rec = { id = db.nextID, code = code, created = time and time() or 0 }
    db.nextID = db.nextID + 1
    db.saved[#db.saved + 1] = rec
  end
  rec.name = trim(name) ~= "" and trim(name) or rec.name or "Imported Blueprint"
  rec.type = self:GetTypeLabel(code)
  rec.updated = time and time() or rec.created
  db.activeID = rec.id
  notify()
  return rec
end

function Blueprints:RequestCollection()
  if not self:IsClientSupported() then return false, "Blueprint support is not available on this client." end
  local api = _G.C_HousingBlueprint
  if type(api.RequestBlueprintCollection) ~= "function" then return false, "The blueprint catalog API is unavailable." end
  api.RequestBlueprintCollection()
  return true
end

function Blueprints:RequestContents(id)
  local rec = self:GetByID(id)
  if not rec then return false, "Select or paste a blueprint first." end
  if not self:IsClientSupported() then return false, "Blueprint support is not available on this client." end
  if self.fitQueue then return false, "Wait for the current house check to finish." end
  self.fitQueue = nil
  self.activeFitRequest = nil
  self.lastRequestedRecID = rec.id
  if rec.status == "checking" then return true end
  rec.status = "checking"
  rec.error = nil
  rec.requestedAt = GetTime and GetTime() or 0
  if NS.Systems.BlueprintList then NS.Systems.BlueprintList:OnRequestStarted(rec.code) end
  _G.C_HousingBlueprint.RequestBlueprintContents(rec.code)
  notify()
  return true
end

function Blueprints:GetRequirements(id)
  local rec = self:GetByID(id)
  return rec and rec.requirements
end

function Blueprints:GetOwnedHouses()
  if self.cachedHouses and #self.cachedHouses > 0 then return self.cachedHouses end
  local endeavors = NS.Systems and NS.Systems.Endeavors
  local houses = endeavors and endeavors.GetHouses and normalizeHouses(endeavors:GetHouses()) or {}
  if #houses > 0 then self.cachedHouses = houses end
  return houses
end

function Blueprints:GetHouseFit(id, houseGUID)
  local rec = self:GetByID(id)
  return rec and rec.houseFits and rec.houseFits[houseGUID] or nil
end

function Blueprints:BeginNextHouseFit()
  local queue = self.fitQueue
  if not queue then return end
  queue.index = queue.index + 1
  local house = queue.houses[queue.index]
  local rec = self:GetByID(queue.recID)
  if not rec or not house then
    if rec then rec.fitStatus = "ready" end
    self.activeFitRequest = nil
    self.lastRequestedRecID = nil
    self.fitQueue = nil
    notify(rec)
    if NS.Systems.BlueprintList then NS.Systems.BlueprintList:RetryPending() end
    return
  end
  self.activeFitRequest = { recID = rec.id, houseGUID = house.houseGUID }
  local fit = rec.houseFits[house.houseGUID]
  fit.status = "checking"
  rec.fitStatus = "checking"
  rec.fitProgress = queue.index
  rec.fitTotal = #queue.houses
  self.lastRequestedRecID = rec.id
  if NS.Systems.BlueprintList then NS.Systems.BlueprintList:OnRequestStarted(rec.code, house.houseGUID) end
  local ok = pcall(_G.C_HousingBlueprint.RequestBlueprintContentsForContext, rec.code, house.houseGUID)
  if not ok then
    fit.status = "error"
    fit.error = "This house could not be checked."
    self.activeFitRequest = nil
    self:BeginNextHouseFit()
    return
  end
  local request = self.activeFitRequest
  C_Timer.After(12, function()
    if Blueprints.activeFitRequest ~= request then return end
    local current = Blueprints:GetByID(request.recID)
    local currentFit = current and current.houseFits and current.houseFits[request.houseGUID]
    if currentFit then
      currentFit.status = "error"
      currentFit.error = "The server did not answer this house check."
    end
    Blueprints.activeFitRequest = nil
    notify(current)
    Blueprints:BeginNextHouseFit()
  end)
  notify(rec)
end

function Blueprints:RequestHouseFits(id)
  local rec = self:GetByID(id)
  if not rec then return false, "Select or paste a blueprint first." end
  if rec.status == "checking" then return false, "Wait for the blueprint inspection to finish." end
  local api = _G.C_HousingBlueprint
  if not (api and type(api.RequestBlueprintContentsForContext) == "function") then return false, "Per-house blueprint checks require the 12.1 housing API." end
  if self.fitQueue then return false, "A blueprint house check is already running." end
  local houses = self:GetOwnedHouses()
  if #houses == 0 then
    self.pendingHouseFitRecID = rec.id
    if _G.C_Housing and type(_G.C_Housing.GetPlayerOwnedHouses) == "function" then pcall(_G.C_Housing.GetPlayerOwnedHouses) end
    rec.fitStatus = "loadingHouses"
    notify(rec)
    return true
  end
  rec.houseFits = rec.houseFits or {}
  for index, house in ipairs(houses) do
    local fit = rec.houseFits[house.houseGUID] or {}
    fit.houseGUID = house.houseGUID
    fit.houseName = houseLabel(house, index)
    fit.neighborhoodName = house.neighborhoodName
    fit.status = "queued"
    fit.error = nil
    rec.houseFits[house.houseGUID] = fit
  end
  if not rec.selectedHouseGUID or not rec.houseFits[rec.selectedHouseGUID] then rec.selectedHouseGUID = houses[1].houseGUID end
  self.fitQueue = { recID = rec.id, houses = houses, index = 0 }
  self.activeFitRequest = nil
  self:BeginNextHouseFit()
  return true
end

function Blueprints:RequestHouseFit(id, houseGUID)
  local rec = self:GetByID(id)
  if not rec or not houseGUID then return false end
  if rec.status == "checking" or self.fitQueue then return false end
  local api = _G.C_HousingBlueprint
  if not (api and type(api.RequestBlueprintContentsForContext) == "function") then return false end
  rec.houseFits = rec.houseFits or {}
  rec.houseFits[houseGUID] = rec.houseFits[houseGUID] or { houseGUID = houseGUID }
  self.fitQueue = { recID = rec.id, houses = { { houseGUID = houseGUID } }, index = 0 }
  self:BeginNextHouseFit()
  return true
end

function Blueprints:GetHyperlink(code)
  local api = _G.C_HousingBlueprint
  if not (api and type(api.GetBlueprintHyperlink) == "function") then return nil end
  local ok, link = pcall(api.GetBlueprintHyperlink, code)
  return ok and link or nil
end

function Blueprints:Import(id)
  local rec = self:GetByID(id)
  if not rec then return false, "Select or paste a blueprint first." end
  if _G.C_AddOns and type(_G.C_AddOns.LoadAddOn) == "function" then pcall(_G.C_AddOns.LoadAddOn, "Blizzard_HousingBlueprint") end
  if _G.HousingFramesUtil and type(_G.HousingFramesUtil.ShowBlueprintImport) == "function" then
    _G.HousingFramesUtil.ShowBlueprintImport(rec.code)
    return true
  end
  return false, "Blizzard's blueprint import window is not available here." 
end

function Blueprints:Export(kind, name)
  if not self:IsClientSupported() then return false, "Blueprint export is not available on this client." end
  local api = _G.C_HousingBlueprint
  local enumValue = getEnum(kind)
  if enumValue == nil or type(api.ExportBlueprint) ~= "function" then return false, "That blueprint export type is unavailable." end
  name = trim(name)
  if name == "" then name = "HomeDecor Blueprint" end
  local availability = self:GetAvailability()
  if not availability.export then
    local result = type(api.GetExportAvailability) == "function" and api.GetExportAvailability() or nil
    return false, resultText(result, "Visit your house before saving a blueprint.")
  end
  self.pendingExportName = name
  api.ExportBlueprint(enumValue, name)
  return true
end

function Blueprints:CanExportRoom(roomGUID)
  local api = _G.C_HousingBlueprint
  if not (api and type(api.ExportRoomBlueprint) == "function" and type(api.CanExportRoom) == "function") then
    return false, "Room blueprint export requires the 12.1 housing API."
  end
  if not roomGUID then return false, "Select a captured room first." end
  local success = _G.Enum and _G.Enum.HousingResult and _G.Enum.HousingResult.Success or 0
  if type(api.GetExportAvailability) == "function" then
    local ok, result = pcall(api.GetExportAvailability)
    if not ok or result ~= success then return false, resultText(result, "Room blueprints cannot be saved here.") end
  end
  local ok, canExport = pcall(api.CanExportRoom, roomGUID)
  if not ok or not canExport then return false, "This room cannot currently be exported." end
  return true
end

function Blueprints:ExportRoom(name, roomGUID)
  local ready, reason = self:CanExportRoom(roomGUID)
  if not ready then return false, reason end
  name = trim(name)
  if name == "" then name = "HomeDecor Room" end
  self.pendingExportName = name
  local ok = pcall(_G.C_HousingBlueprint.ExportRoomBlueprint, name, roomGUID)
  if not ok then
    self.pendingExportName = nil
    return false, "The room blueprint export could not be started."
  end
  return true
end

function Blueprints:Delete(id)
  local db = profile()
  local rec = self:GetByID(id)
  if not (db and rec) then return false, "Select a blueprint first." end
  if rec.blueprintID and _G.C_HousingBlueprint and type(_G.C_HousingBlueprint.DeleteBlueprint) == "function" then
    _G.C_HousingBlueprint.DeleteBlueprint(rec.blueprintID)
    return true
  end
  for i, saved in ipairs(db.saved) do
    if saved == rec then table.remove(db.saved, i) break end
  end
  db.activeID = db.saved[1] and db.saved[1].id or nil
  notify()
  return true
end

function Blueprints:BuildArchitectPreview(rec)
  rec = self:GetByID(rec and rec.id or rec)
  if not (rec and rec.requirements) then return nil, "Inspect the blueprint before opening it in Architect." end
  local architect = NS.Systems and NS.Systems.Architect
  if not architect then return nil, "Architect is not available." end
  local layout
  for _, candidate in ipairs((architect:GetDB() and architect:GetDB().layouts) or {}) do
    if candidate.blueprintCode == rec.code then layout = candidate break end
  end
  if not layout then layout = architect:CreateLayout((rec.name or "Blueprint") .. " Preview") end
  if not layout then return nil, "Architect could not create a blueprint preview." end
  layout.name = (rec.name or "Blueprint") .. " Preview"
  layout.blueprintCode = rec.code
  layout.blueprintPreview = true
  layout.blueprintRequirements = rec.requirements
  layout.blueprintBaseRequirements = rec.requirements
  layout.rooms = {}
  local x, y, rowHeight = 2, 2, 0
  for _, group in ipairs(rec.requirements.groups or {}) do
    if group.contentType == 2 then
      for _, entry in ipairs(group.items or {}) do
        for _ = 1, math.max(0, tonumber(entry.total) or 0) do
          local template = architect.GetRoomTemplate and architect:GetRoomTemplate(entry.recordID)
          if not template and architect.GetRoomTemplate then template = architect:GetRoomTemplate(entry.name) end
          local roomSource = template or entry.name or "Blueprint Room"
          local w, h = tonumber(template and template.w) or 5, tonumber(template and template.h) or 4
          if x + w > 22 then x, y, rowHeight = 2, y + rowHeight + 2, 0 end
          local room = architect:AddRoomAt(layout, roomSource, x, y, 1)
          if room then room.roomTypeId = entry.recordID end
          x = x + w + 2
          rowHeight = math.max(rowHeight, h)
        end
      end
    end
  end
  architect:NormalizeLayout(layout)
  architect:SetActiveLayout(layout.id)
  return layout
end

function Blueprints:QueueArchitectPreview(id, reveal)
  local rec = self:GetByID(id)
  if not rec then return nil, "Select or paste a blueprint first." end
  if rec.requirements then return self:BuildArchitectPreview(rec) end
  rec.previewQueued = true
  rec.previewReveal = reveal and true or false
  local ok, err = self:RequestContents(rec.id)
  if not ok then return nil, err end
  return nil, nil, true
end

function Blueprints:OpenInArchitect(id)
  local rec = self:GetByID(id)
  return self:BuildArchitectPreview(rec)
end

function Blueprints:OnCollectionReceived(collection)
  local db = profile()
  if not db then return end
  for _, group in ipairs((collection and collection.groups) or {}) do
    for _, entry in ipairs(group.entries or {}) do
      local code = trim(entry.shareCode or entry.code)
      if code ~= "" then
        local rec = self:GetByCode(code)
        if not rec then
          rec = { id = db.nextID, code = code, created = time and time() or 0 }
          db.nextID = db.nextID + 1
          db.saved[#db.saved + 1] = rec
        end
        rec.name = entry.name or rec.name or "Saved Blueprint"
        rec.blueprintID = entry.blueprintID or entry.id or rec.blueprintID
        rec.isAutoSave = entry.isAutoSave and true or false
        rec.type = self:GetTypeLabel(code)
        rec.updated = time and time() or rec.created
      end
    end
  end
  db.collectionUpdated = time and time() or true
  if not db.activeID and db.saved[1] then db.activeID = db.saved[1].id end
  notify()
end

function Blueprints:OnContentsReceived(info)
  local code = trim(info and info.shareCode)
  if code == "" then return end
  local rec = self:GetByCode(code)
  if not rec then
    -- Blizzard can echo the share code back in a slightly different form
    -- than what was submitted (e.g. re-encoded), so an exact-string match
    -- can miss the record we just named. Prefer the record that actually
    -- triggered the in-flight request over a loose "any pending" scan,
    -- since stale "checking" records from earlier attempts can linger.
    local lastID = self.lastRequestedRecID
    if lastID then
      rec = self:GetByID(lastID)
    end
    if rec then rec.code = code end
  end
  self.lastRequestedRecID = nil
  if not rec then return end
  local activeFit = self.activeFitRequest
  if activeFit and activeFit.recID == rec.id then
    rec.houseFits = rec.houseFits or {}
    local fit = rec.houseFits[activeFit.houseGUID] or { houseGUID = activeFit.houseGUID }
    fit.requirements = requirementsFromInfo(info)
    fit.summary = summaryFromInfo(info, fit.requirements)
    fit.status = "ready"
    fit.error = nil
    fit.updated = time and time() or 0
    rec.houseFits[activeFit.houseGUID] = fit
    self.activeFitRequest = nil
    if NS.Systems.BlueprintList then NS.Systems.BlueprintList:OnBlueprintUpdated(rec, fit) end
    notify(rec)
    self:BeginNextHouseFit()
    return
  end
  rec.requirements = requirementsFromInfo(info)
  rec.contents = true
  rec.status = "ready"
  rec.error = nil
  rec.type = self:GetTypeLabel(code)
  rec.summary = summaryFromInfo(info, rec.requirements)
  rec.updated = time and time() or rec.updated
  if NS.Systems.BlueprintList then NS.Systems.BlueprintList:OnBlueprintUpdated(rec) end
  local queued, reveal = rec.previewQueued, rec.previewReveal
  rec.previewQueued, rec.previewReveal = nil, nil
  notify(rec)
  if NS.Systems.BlueprintList then NS.Systems.BlueprintList:RetryPending() end
  if queued then
    local layout, err = self:BuildArchitectPreview(rec)
    if NS.SendMessage then NS.SendMessage("HOMEDECOR_ARCHITECT_BLUEPRINT_READY", layout, rec, err, reveal) end
  end
end

function Blueprints:OnContentsFailure(code, reason)
  local rec = self:GetByCode(code)
  local activeFit = self.activeFitRequest
  if not rec and activeFit then rec = self:GetByID(activeFit.recID) end
  if not rec then return end
  if activeFit and activeFit.recID == rec.id then
    local fit = rec.houseFits and rec.houseFits[activeFit.houseGUID]
    if fit then
      fit.status = "error"
      fit.error = resultText(reason, "This house could not be checked.")
    end
    self.activeFitRequest = nil
    notify(rec)
    self:BeginNextHouseFit()
    return
  end
  rec.status = "error"
  rec.error = resultText(reason, "The blueprint contents could not be loaded.")
  rec.previewQueued, rec.previewReveal = nil, nil
  notify()
end

function Blueprints:OnExportSuccess(code)
  local rec = self:SaveCode(code, self.pendingExportName or "HomeDecor Blueprint")
  self.pendingExportName = nil
  if rec then
    self:RequestContents(rec.id)
    self:RequestCollection()
    chat("Blueprint saved and ready to share.")
  end
end

function Blueprints:OnExportFailure(reason)
  self.pendingExportName = nil
  chat(resultText(reason, "The blueprint could not be saved here."), true)
end

if NS.SafeRegisterEvent then
  NS.SafeRegisterEvent(Blueprints, "HOUSING_BLUEPRINT_COLLECTION_RECEIVED", function(collection) Blueprints:OnCollectionReceived(collection) end)
  NS.SafeRegisterEvent(Blueprints, "HOUSING_BLUEPRINT_CONTENTS_RECEIVED", function(info) Blueprints:OnContentsReceived(info) end)
  NS.SafeRegisterEvent(Blueprints, "HOUSING_BLUEPRINT_CONTENTS_FAILURE", function(code, reason) Blueprints:OnContentsFailure(code, reason) end)
  NS.SafeRegisterEvent(Blueprints, "HOUSING_BLUEPRINT_EXPORT_SUCCESS", function(code) Blueprints:OnExportSuccess(code) end)
  NS.SafeRegisterEvent(Blueprints, "HOUSING_BLUEPRINT_EXPORT_FAILURE", function(reason) Blueprints:OnExportFailure(reason) end)
  NS.SafeRegisterEvent(Blueprints, "HOUSING_BLUEPRINT_DELETE_SUCCESS", function() Blueprints:RequestCollection() end)
  NS.SafeRegisterEvent(Blueprints, "PLAYER_HOUSE_LIST_UPDATED", function(houses)
    local normalized = normalizeHouses(houses)
    if #normalized > 0 then Blueprints.cachedHouses = normalized end
    local recID = Blueprints.pendingHouseFitRecID
    Blueprints.pendingHouseFitRecID = nil
    if recID and #normalized > 0 then
      Blueprints:RequestHouseFits(recID)
    elseif recID then
      local rec = Blueprints:GetByID(recID)
      if rec then
        rec.fitStatus = "error"
        notify(rec)
      end
    end
  end)
end

return Blueprints
