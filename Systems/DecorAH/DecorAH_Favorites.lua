local ADDON, NS = ...
NS.DecorAH = NS.DecorAH or {}
local Favorites = NS.DecorAH.Favorites or {}
NS.DecorAH.Favorites = Favorites

local function db()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  profile.decorAH.favorites = profile.decorAH.favorites or {}
  profile.decorAH.priceAlerts = profile.decorAH.priceAlerts or {}
  return profile.decorAH
end

function Favorites.ToggleFavorite(itemID)
  if not itemID then return false end
  local g = db()
  if not g then return false end

  g.favorites[itemID] = not g.favorites[itemID]
  return g.favorites[itemID] and true or false
end

function Favorites.IsFavorite(itemID)
  if not itemID then return false end
  local g = db()
  if not g or not g.favorites then return false end
  return g.favorites[itemID] and true or false
end

function Favorites.GetFavorites()
  local g = db()
  if not g or not g.favorites then return {} end

  local favorites = {}
  for itemID, isFav in pairs(g.favorites) do
    if isFav then
      table.insert(favorites, itemID)
    end
  end

  return favorites
end

function Favorites.SetPriceAlert(itemID, targetProfit)
  if not itemID then return false end
  local g = db()
  if not g then return false end

  g.priceAlerts[itemID] = targetProfit or 0
  return true
end

function Favorites.RemovePriceAlert(itemID)
  if not itemID then return end
  local g = db()
  if not g or not g.priceAlerts then return end

  g.priceAlerts[itemID] = nil
end

function Favorites.GetPriceAlert(itemID)
  if not itemID then return nil end
  local g = db()
  if not g or not g.priceAlerts then return nil end

  return g.priceAlerts[itemID]
end

function Favorites.CheckAlerts(currentData)
  local g = db()
  if not g or not g.priceAlerts then return {} end

  local alerts = {}

  for _, data in ipairs(currentData or {}) do
    local itemID = data.itemID
    local profit = data.profit
    local targetProfit = g.priceAlerts[itemID]

    if targetProfit and profit and profit >= targetProfit then
      table.insert(alerts, {
        itemID = itemID,
        name = data.name or "Unknown",
        profit = profit,
        targetProfit = targetProfit,
      })
    end
  end

  return alerts
end

function Favorites.ClearFavorites()
  local g = db()
  if not g then return end
  g.favorites = {}
end

function Favorites.ClearAlerts()
  local g = db()
  if not g then return end
  g.priceAlerts = {}
end

return GF
