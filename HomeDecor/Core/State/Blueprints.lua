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

local function notify()
  if Blueprints.OnLibraryChanged then Blueprints.OnLibraryChanged() end
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

local function summaryFromInfo(info, req)
  local summary = {
    type = Blueprints:GetTypeLabel(info and info.shareCode),
    rooms = 0,
    decor = 0,
    dyes = 0,
    fixtures = 0,
    missing = req.acquirableMissingQty,
    missingAll = req.missingQty,
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
  local costs = info and (info.budgetCosts or info.budgetCostMap or info.budgetCostInfo)
  if type(costs) == "table" then
    local total = 0
    local function walk(value)
      if type(value) ~= "table" then return end
      if tonumber(value.cost) then total = total + math.max(0, tonumber(value.cost) or 0) end
      for _, child in pairs(value) do
        if type(child) == "table" then walk(child) end
      end
    end
    walk(costs)
    summary.budget = total
  end
  return summary
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
  self.lastRequestedRecID = rec.id
  if rec.status == "checking" then return true end
  rec.status = "checking"
  rec.error = nil
  rec.requestedAt = GetTime and GetTime() or 0
  _G.C_HousingBlueprint.RequestBlueprintContents(rec.code)
  notify()
  return true
end

function Blueprints:GetRequirements(id)
  local rec = self:GetByID(id)
  return rec and rec.requirements
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
  rec.requirements = requirementsFromInfo(info)
  rec.contents = true
  rec.status = "ready"
  rec.error = nil
  rec.type = self:GetTypeLabel(code)
  rec.summary = summaryFromInfo(info, rec.requirements)
  rec.updated = time and time() or rec.updated
  local queued, reveal = rec.previewQueued, rec.previewReveal
  rec.previewQueued, rec.previewReveal = nil, nil
  notify()
  if queued then
    local layout, err = self:BuildArchitectPreview(rec)
    if NS.SendMessage then NS.SendMessage("HOMEDECOR_ARCHITECT_BLUEPRINT_READY", layout, rec, err, reveal) end
  end
end

function Blueprints:OnContentsFailure(code, reason)
  local rec = self:GetByCode(code)
  if not rec then return end
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
end

return Blueprints
