local ADDON, NS = ...

local registry = _G.HomeDecorDataBundles or {}
_G.HomeDecorDataBundles = registry

registry[ADDON] = {
  Drops = NS.Data and NS.Data.Drops,
  Shops = NS.Data and NS.Data.Shops,
  Treasures = NS.Data and NS.Data.Treasures,
}
