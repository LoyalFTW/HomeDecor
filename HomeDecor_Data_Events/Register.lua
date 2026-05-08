local ADDON, NS = ...

local registry = _G.HomeDecorDataBundles or {}
_G.HomeDecorDataBundles = registry

registry[ADDON] = {
  Events = NS.Data and NS.Data.Events,
}
