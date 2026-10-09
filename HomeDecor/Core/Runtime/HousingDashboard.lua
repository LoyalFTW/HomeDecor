local _, NS = ...

local HousingDashboard = {}
NS.Systems.HousingDashboard = HousingDashboard

function HousingDashboard:SyncHouseList()
  local dashboard = _G.HousingDashboardFrame
  local houseInfo = dashboard and dashboard.HouseInfoContent
  local dropdown = houseInfo and houseInfo.HouseDropdown
  local content = houseInfo and houseInfo.ContentFrame
  local initiatives = content and content.InitiativesFrame
  local houses = dropdown and dropdown.playerHouseList
  if not initiatives or initiatives.playerHouseList ~= nil or type(houses) ~= "table" then return end
  if type(houseInfo.OnHouseListUpdated) ~= "function" then return end
  houseInfo:OnHouseListUpdated(houses)
  local selected = dropdown.selectedHouseID
  if selected and houses[selected] and type(houseInfo.OnHouseSelected) == "function" then
    houseInfo:OnHouseSelected(selected)
  end
end

function HousingDashboard:Attach()
  local dashboard = _G.HousingDashboardFrame
  local houseInfo = dashboard and dashboard.HouseInfoContent
  local dropdown = houseInfo and houseInfo.HouseDropdown
  if not dropdown then return end
  if self.dropdown ~= dropdown and type(dropdown.LoadHouses) == "function" and type(_G.hooksecurefunc) == "function" then
    _G.hooksecurefunc(dropdown, "LoadHouses", function() HousingDashboard:SyncHouseList() end)
    self.dropdown = dropdown
  end
  self:SyncHouseList()
end

NS.RegisterEvent(HousingDashboard, "ADDON_LOADED", function(name)
  if name == "Blizzard_HousingDashboard" then HousingDashboard:Attach() end
end)

HousingDashboard:Attach()

return HousingDashboard
