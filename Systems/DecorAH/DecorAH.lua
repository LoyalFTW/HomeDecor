local ADDON, NS = ...
NS.DecorAH = NS.DecorAH or {}
local DecorAH = NS.DecorAH

DecorAH.Sales = DecorAH.Sales or {}
DecorAH.Queue = DecorAH.Queue or {}
DecorAH.History = DecorAH.History or {}
DecorAH.Favorites = DecorAH.Favorites or {}
DecorAH.Export = DecorAH.Export or {}

function DecorAH:GetDB()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  return profile.decorAH
end

function DecorAH:Initialize()
  if self.Sales and self.Sales.Initialize then
    local ok, err = pcall(function() self.Sales.Initialize() end)
    if not ok then
    end
  else
  end
end

return DecorAH