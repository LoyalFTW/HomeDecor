local ADDON, NS = ...
NS.UI = NS.UI or {}
local Star = {}
NS.UI.FavoriteStar = Star

local ATLAS_ON  = "auctionhouse-icon-favorite"
local ATLAS_OFF = "auctionhouse-icon-favorite-off"

-- Listener support so the Tracker can refresh when favorites change
local _listeners = {}

function Star:RegisterListener(fn)
    if type(fn) == "function" then
        _listeners[#_listeners + 1] = fn
    end
end

local function NotifyListeners()
    for i = 1, #_listeners do
        local ok, err = pcall(_listeners[i])
        if not ok then
            -- silently swallow errors so one bad listener can't break others
        end
    end
end

local function getDB()
    return NS.db and NS.db.profile and NS.db.profile.favorites
end

local function isFav(id)
    local db = getDB()
    return db and db[id]
end

local function toggle(id)
    local db = getDB()
    if not db then return end
    db[id] = not db[id]
end

local function apply(tex, on)
    if tex.SetAtlas then
        tex:SetAtlas(on and ATLAS_ON or ATLAS_OFF, true)
    end
    tex:SetAlpha(on and 1 or 0.5)
end

function Star:Attach(parent, itemID, onChanged)
    if not parent or not itemID then return end
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(20, 20)

    local tex = b:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()

    local function refresh()
        apply(tex, isFav(itemID))
    end

    b:SetScript("OnClick", function()
        toggle(itemID)
        refresh()
        NotifyListeners()
        if onChanged then onChanged(itemID) end
    end)

    refresh()
    b.Refresh = refresh
    return b
end

return Star
