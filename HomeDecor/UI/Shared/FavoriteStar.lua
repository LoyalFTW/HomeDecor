local _, NS = ...

NS.UI = NS.UI or {}
local FavoriteStar = {}
NS.UI.FavoriteStar = FavoriteStar

function FavoriteStar:Apply(texture, active)
  texture:SetAtlas(active and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off", true)
  texture:SetAlpha(active and 1 or 0.55)
end

function FavoriteStar:Create(parent, size, onChanged)
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(size or 20, size or 20)
  button.icon = button:CreateTexture(nil, "OVERLAY")
  button.icon:SetAllPoints()
  button:SetScript("OnClick", function(self)
    if self.record then
      NS.Systems.Favorites:Toggle(self.record)
      FavoriteStar:Apply(self.icon, NS.Systems.Favorites:IsFavorite(self.record))
      if onChanged then
        onChanged(self.record)
      elseif NS.UI.CatalogView and NS.UI.CatalogView.frame and NS.UI.CatalogView.frame:IsShown() and NS.UI.CatalogView.Refresh then
        NS.UI.CatalogView:Refresh()
      end
    end
  end)
  button:SetScript("OnEnter", function(self)
    if not self.record or not _G.GameTooltip then return end
    _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    _G.GameTooltip:SetText(NS.Systems.Favorites:IsFavorite(self.record) and "Remove from Saved Items" or "Add to Saved Items")
    _G.GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  button.SetRecord = function(self, record)
    self.record = record
    if record then
      FavoriteStar:Apply(self.icon, NS.Systems.Favorites:IsFavorite(record))
      self:Show()
    else
      self:Hide()
    end
  end
  button:SetRecord(nil)
  return button
end
