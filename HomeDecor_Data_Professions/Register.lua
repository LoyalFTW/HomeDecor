local ADDON, NS = ...

local registry = _G.HomeDecorDataBundles or {}
_G.HomeDecorDataBundles = registry

registry[ADDON] = {
  Professions = NS.Data and NS.Data.Professions,
  Prof_Reagents = NS.Data and NS.Data.Prof_Reagents,
}
