local ADDON, NS = ...
local Star = {}
NS.UI.FavoriteStar = Star

local ATLAS_ON  = "auctionhouse-icon-favorite"
local ATLAS_OFF = "auctionhouse-icon-favorite-off"

local TEX_ON  = "Interface/Common/ReputationStar"
local TEX_OFF = "Interface/Buttons/UI-EmptySlot"

local function getFavTable()
    local db = NS.db and NS.db.profile
    if not db then return nil end
    db.favorites = db.favorites or {}
    return db.favorites
end

local function isFav(id)
    local fav = getFavTable()
    return fav and fav[id]
end

local function toggle(id)
    local fav = getFavTable()
    if not fav then return end
    fav[id] = not fav[id]
end

local function apply(icon, on)
    if icon.SetAtlas then
        icon:SetAtlas(on and ATLAS_ON or ATLAS_OFF, true)
    else
        icon:SetTexture(on and TEX_ON or TEX_OFF)
    end
    icon:SetVertexColor(1, 1, 1, on and 1 or 0.55)
end

function Star:Attach(parent, itemID, onChanged)
    if not parent or not itemID then return end

    local b = CreateFrame("Button", nil, parent)
    b:SetSize(18, 18)

    local tex = b:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()

    local function refresh()
        apply(tex, isFav(itemID))
    end

    refresh()

    b:SetScript("OnClick", function()
        toggle(itemID)
        refresh()
        if onChanged then onChanged(itemID) end
    end)

    b.Refresh = refresh
    return b
end

return Star
