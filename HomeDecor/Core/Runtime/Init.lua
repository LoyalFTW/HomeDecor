local _, NS = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")
frame:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")
frame:RegisterEvent("HOUSING_STORAGE_ENTRY_UPDATED")
frame:RegisterEvent("HOUSING_STORAGE_UPDATED")
frame:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED")
frame:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
local collectionRefreshQueued = false
local function RefreshCollection()
  collectionRefreshQueued = false
  NS.Systems.Collection:Invalidate()
  NS.Systems.Housing:InvalidateOwnership()
  if NS.UI and NS.UI.CatalogView then NS.UI.CatalogView:InvalidateDisplay() end
  if NS.UI and NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
  if NS.UI and NS.UI.VendorAssistant then NS.UI.VendorAssistant:Refresh() end
  if NS.UI and NS.UI.VendorMarkers then NS.UI.VendorMarkers:Refresh() end
  if NS.UI and NS.UI.MapDirectory then NS.UI.MapDirectory:Refresh() end
  if NS.UI and NS.UI.Overview then NS.UI.Overview:Refresh() end
end

local function QueueCollectionRefresh()
  if collectionRefreshQueued then return end
  collectionRefreshQueued = true
  if _G.C_Timer and _G.C_Timer.After then
    _G.C_Timer.After(0.1, RefreshCollection)
  else
    RefreshCollection()
  end
end

NS.SafeRegisterEvent(frame, "HOUSING_COLLECTION_UPDATED", QueueCollectionRefresh)
NS.SafeRegisterEvent(frame, "HOUSING_DECOR_ITEM_LEARNED", QueueCollectionRefresh)
NS.SafeRegisterEvent(frame, "QUEST_TURNED_IN", QueueCollectionRefresh)
NS.SafeRegisterEvent(frame, "ACHIEVEMENT_EARNED", QueueCollectionRefresh)
NS.SafeRegisterEvent(frame, "BAG_UPDATE_DELAYED", function()
  if (_G.MerchantFrame and _G.MerchantFrame:IsShown()) or (NS.UI and NS.UI.CatalogView and NS.UI.CatalogView.frame and NS.UI.CatalogView.frame:IsShown()) then
    QueueCollectionRefresh()
  end
end)

NS.OnMessage("HOMEDECOR_COLLECTION_UPDATED", function()
  if NS.UI and NS.UI.CatalogView then NS.UI.CatalogView:InvalidateDisplay() end
  if NS.UI and NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
  if NS.UI and NS.UI.VendorAssistant then NS.UI.VendorAssistant:Refresh() end
  if NS.UI and NS.UI.VendorMarkers then NS.UI.VendorMarkers:Refresh() end
  if NS.UI and NS.UI.MapDirectory then NS.UI.MapDirectory:Refresh() end
  if NS.UI and NS.UI.Controls and NS.UI.Controls.CollectGarbageIncrementally then NS.UI.Controls:CollectGarbageIncrementally() end
end)

NS.OnMessage("HOMEDECOR_CATALOG_UPDATED", function()
  if NS.UI and NS.UI.CatalogView then NS.UI.CatalogView:InvalidateDisplay() end
  if NS.UI and NS.UI.Controls and NS.UI.Controls.CollectGarbageIncrementally then NS.UI.Controls:CollectGarbageIncrementally() end
end)

frame:SetScript("OnEvent", function(_, event, name, reason)
  if event == "ADDON_LOADED" then
    if name == NS.Name then
      NS.Systems.Database:Load()
      if NS.UI and NS.UI.Controls then NS.UI.Controls:ApplyAppearance() end
      NS.Systems.SourceAdapter:LoadAll()
    elseif NS.Systems.SourceAdapter then
      NS.Systems.SourceAdapter:OnAddonLoaded(name)
      if name == "Blizzard_WorldMap" then
        NS.Systems.MapPins:Attach()
        NS.Systems.MapPins:RequestRefresh()
      end
    end
  elseif event == "PLAYER_LOGIN" and NS.Systems.SourceAdapter then
    local profile = NS.Systems.Database:GetProfile()
    local legacy = profile
    if NS.Systems.MarketHistory then NS.Systems.MarketHistory:Compact() end
    if NS.UI and NS.UI.Controls and NS.UI.Controls.CollectGarbageIncrementally then NS.UI.Controls:CollectGarbageIncrementally() end
    if legacy and profile and not profile.legacyMigrationVersion then NS.Systems.SourceAdapter:LoadAll() end
    NS.Systems.SourceAdapter:ImportAvailable()
    NS.Systems.LegacyMigration:Import()
    NS.Systems.LegacyMigration:CompactDatabase()
    NS.Systems.MapPins:RebuildTrackedIndex()
    NS.Systems.VendorIndex:Rebuild()
    NS.Systems.MapPins:Attach()
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0.25, function() NS.Systems.Collection:RequestSnapshot() end)
    else
      NS.Systems.Collection:RequestSnapshot()
    end
    if NS.UI and NS.UI.MinimapLauncher then NS.UI.MinimapLauncher:Init() end
    if NS.UI and NS.UI.Settings and type(NS.UI.Settings.EnsureOptions) == "function" then NS.UI.Settings:EnsureOptions() end
    if NS.UI and NS.UI.QuickBar then
      NS.UI.QuickBar:WireEditor()
      NS.UI.QuickBar:BeginEditorWatch()
    end
    if NS.Systems.EditorTools then NS.Systems.EditorTools:Init() end
    if NS.Systems.AddonConflict then NS.Systems.AddonConflict:Init() end
  elseif event == "HOUSE_DECOR_ADDED_TO_CHEST" or event == "HOUSING_DECOR_PLACE_SUCCESS" or event == "HOUSING_STORAGE_ENTRY_UPDATED" or event == "HOUSING_STORAGE_UPDATED" or event == "NEW_HOUSING_ITEM_ACQUIRED" then
    QueueCollectionRefresh()
    if (event == "HOUSE_DECOR_ADDED_TO_CHEST" or event == "HOUSING_DECOR_PLACE_SUCCESS") and NS.UI and NS.UI.QuickBar then NS.UI.QuickBar:OnPlacementSuccess() end
  elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0, function()
        if NS.UI and NS.UI.QuickBar then
          NS.UI.QuickBar:WireEditor()
          NS.UI.QuickBar:BeginEditorWatch()
          NS.UI.QuickBar:SyncEditor()
        end
      end)
    elseif NS.UI and NS.UI.QuickBar then
      NS.UI.QuickBar:WireEditor()
      NS.UI.QuickBar:BeginEditorWatch()
      NS.UI.QuickBar:SyncEditor()
    end
  elseif NS.UI and NS.UI.CatalogView and NS.UI.CatalogView.InvalidateDisplay then
    NS.UI.CatalogView:InvalidateDisplay()
    NS.Systems.MapPins:RequestRefresh()
  end
end)
