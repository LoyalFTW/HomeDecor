local ADDON, NS = ...

local registry = _G.HomeDecorDataBundles or {}
_G.HomeDecorDataBundles = registry

registry[ADDON] = {
  Vendors = NS.Data and NS.Data.Vendors,
}
