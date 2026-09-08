local _, NS = ...

NS.UI = NS.UI or {}
local MapDirectory = NS.UI.MapDirectory or { records = {}, openSources = {} }
NS.UI.MapDirectory = MapDirectory

function MapDirectory:Hide()
  NS.UI.Controls:CloseTransientPopups()
  if self.frame then self.frame:Hide() end
end

function MapDirectory:Toggle()
  NS.UI.Controls:CloseTransientPopups()
  local frame = self:Create()
  if frame:IsShown() then frame:Hide() else self:Open() end
end

return MapDirectory
