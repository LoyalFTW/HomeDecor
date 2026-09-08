local _, NS = ...

local Favorites = { revision = 0 }
NS.Systems.Favorites = Favorites

function Favorites:Key(record)
  if not record then return nil end
  if record.favoriteKey then return record.favoriteKey end
  if record.itemID then return "item:" .. tostring(record.itemID) end
  if record.decorID then return "decor:" .. tostring(record.decorID) end
  local id = record.id
  if not id then return nil end
  return tostring(id) .. ":" .. tostring(record.sourceType or "") .. ":" .. tostring(record.sourceID or "")
end

function Favorites:IsFavorite(record)
  local profile = NS.Systems.Database:GetProfile()
  local key = self:Key(record)
  if not profile or not key then return false end
  local favorites = profile.favorites
  if favorites[key] == true or (record.storageKey and favorites[record.storageKey] == true) then return true end
  if record.itemID and (favorites[record.itemID] == true or favorites[tostring(record.itemID)] == true) then return true end
  if record.decorID and (favorites[record.decorID] == true or favorites[tostring(record.decorID)] == true) then return true end
  return false
end

function Favorites:Clear(record, profile)
  local favorites = profile.favorites
  favorites[self:Key(record)] = nil
  if record.storageKey then favorites[record.storageKey] = nil end
  if record.itemID then
    favorites[record.itemID] = nil
    favorites[tostring(record.itemID)] = nil
  end
  if record.decorID then
    favorites[record.decorID] = nil
    favorites[tostring(record.decorID)] = nil
  end
  local records = NS.Systems.Catalog.ordered or {}
  for index = 1, #records do
    local candidate = records[index]
    if (record.itemID and candidate.itemID == record.itemID) or (record.decorID and candidate.decorID == record.decorID) then
      favorites[self:Key(candidate)] = nil
      if candidate.storageKey then favorites[candidate.storageKey] = nil end
    end
  end
end

function Favorites:Refresh(record)
  if NS.UI and NS.UI.CatalogView then NS.UI.CatalogView:Refresh(false) end
  if NS.UI and NS.UI.Inspector and NS.UI.Inspector.record and record and NS.UI.Inspector.record.decorID == record.decorID then NS.UI.Inspector:Show(NS.UI.Inspector.record) end
  if NS.UI and NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
  if NS.UI and NS.UI.VendorAssistant then NS.UI.VendorAssistant:Refresh() end
  if NS.UI and NS.UI.VendorMarkers then NS.UI.VendorMarkers:Refresh() end
  if NS.UI and NS.UI.MapDirectory then NS.UI.MapDirectory:Refresh() end
  if NS.UI and NS.UI.Overview then NS.UI.Overview:Refresh() end
end

function Favorites:Toggle(record)
  local profile = NS.Systems.Database:GetProfile()
  local key = self:Key(record)
  if not profile or not key then return false end
  local active = self:IsFavorite(record)
  self:Clear(record, profile)
  if not active then profile.favorites[key] = true end
  self.revision = self.revision + 1
  self:Refresh(record)
  return not active
end
