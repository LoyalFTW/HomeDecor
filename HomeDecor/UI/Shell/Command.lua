local _, NS = ...

SLASH_HOMEDECOR1 = "/hd"
SLASH_HOMEDECOR2 = "/homedecor"
SLASH_HOMEDECOR3 = "/hdr"
SlashCmdList.HOMEDECOR = function(message)
  local command = tostring(message or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if command == "track" or command == "tracked" then
    NS.UI.CatalogView:Open("tracked")
  elseif command == "favorites" or command == "favourites" then
    NS.UI.CatalogView:Open("favorites")
  elseif command == "catalog" or command == "all" then
    NS.UI.CatalogView:Open("catalog")
  elseif command == "quickbar" then
    NS.UI.QuickBar:Toggle()
  elseif command == "tracker" then
    NS.UI.TrackerPanel:Toggle()
  elseif command == "gather" or command == "gathertracker" then
    NS.UI.GatherTracker:Toggle()
  elseif command == "settings" then
    NS.UI.Settings:Toggle()
  elseif command == "minimap" then
    local profile = NS.Systems.Database:GetProfile()
    local hide = not (profile.minimap and profile.minimap.hide)
    NS.UI.MinimapLauncher:SetMinimapHidden(hide)
    print(hide and "HomeDecor: Minimap button hidden." or "HomeDecor: Minimap button shown.")
  elseif command == "overview" or command == "stats" then
    NS.UI.Overview:Toggle()
  elseif command == "map" or command == "locations" then
    NS.UI.MapDirectory:Toggle()
  elseif command == "architect" then
    NS.UI.Architect:Toggle()
  elseif command == "pricing" or command == "prices" then
    NS.UI.DecorPricing:Toggle()
  elseif command == "community" then
    NS.UI.Community:Toggle()
  elseif command == "changelog" or command == "new" or command == "whatsnew" then
    NS.UI.WhatsNew:Toggle()
  elseif command == "debug" then
    NS.Systems.Diagnostics:Print()
  elseif command == "debug vendor" then
    NS.UI.VendorMarkers:Debug()
  elseif command == "debug reset" then
    NS.Systems.Diagnostics:Reset()
  elseif command == "debug trace on" then
    NS.Systems.Diagnostics:StartTrace()
  elseif command == "debug trace off" then
    NS.Systems.Diagnostics:StopTrace()
  elseif command == "debug trace reset" then
    NS.Systems.Diagnostics:ClearTrace()
  elseif command == "debug trace" then
    NS.Systems.Diagnostics:PrintTrace()
  else
    NS.UI.CatalogView:Toggle()
  end
end
