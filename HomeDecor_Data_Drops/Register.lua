local ADDON, NS = ...

local registry = _G.HomeDecorDataBundles or {}
_G.HomeDecorDataBundles = registry

registry[ADDON] = {
  Drops = NS.Data and NS.Data.Drops,
}
