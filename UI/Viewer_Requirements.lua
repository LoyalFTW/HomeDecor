local ADDON, NS = ...

local M = {}
NS.UI.ViewerRequirements = M

local function _reqResolveFaction(it)
    if not it then return nil end
    local f = (it.source and it.source.faction) or it.faction
    if not f then return nil end
    if type(f) == "table" then
        local a, h = false, false
        for _, v in pairs(f) do
            if v == "Alliance" then a = true end
            if v == "Horde" then h = true end
        end
        if a and h then return "Both" end
        if a then return "Alliance" end
        if h then return "Horde" end
        return nil
    end
    if f == "Alliance" or f == "Horde" or f == "Neutral" or f == "Both" then
        return f
    end
    return tostring(f)
end

local function _reqVendorInfo(it)
    if not it then return nil, nil end
    local v = it._navVendor or it.vendor
    if type(v) ~= "table" then return nil, nil end
    local src = v.source
    local name = v.title or v.name or v.vendorName or (src and (src.vendor or src.vendorName or src.npc))
    local zone = v.zone or (src and src.zone) or it.zone or (it.source and it.source.zone)
    return name, zone
end

local function _reqAddKey(k, v)
    if v and v ~= "" then
        GameTooltip:AddDoubleLine(k, tostring(v), 0.8,0.8,0.8, 0.8,0.8,0.8)
    end
end

function M.GetRequirementLink(it)
    if not it then return nil end

    local r = it.requirements
    if not r and it.decorID then
        local DecorIndex = NS.Systems and NS.Systems.DecorIndex
        local entry = DecorIndex and DecorIndex[it.decorID]
        local item  = entry and entry.item
        r = item and item.requirements or nil
    end
    if not r then return nil end

    if r.quest and r.quest.id then
        return { kind = "quest", id = r.quest.id, text = r.quest.title }
    end
    if r.achievement and r.achievement.id then
        return { kind = "achievement", id = r.achievement.id, text = r.achievement.title }
    end
    return nil
end

function M.BuildDisplay(req, hover)
    if not req then return "" end
    local sym = (req.kind == "quest") and "!" or "*"
    local symCol = "|cffffd100" .. sym .. "|r "
    local txtCol = hover and "|cfffff2a0" or "|cffffffff"
    return symCol .. txtCol .. (req.text or "") .. "|r"
end

function M.ShowTooltip(owner, it, req)
    if not owner or not req then return end

    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    if req.kind == "achievement" then
        local link = req.id and GetAchievementLink and GetAchievementLink(req.id)
        if link then
            GameTooltip:SetHyperlink(link)
        else
            GameTooltip:AddLine(req.text or "Achievement", 1,1,1)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("[Achievement]", 0.6, 0.8, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
        GameTooltip:AddLine("Right Click: Vendor Location", 0.8,0.8,0.8)
        GameTooltip:AddLine("Ctrl + Click: View Achievement", 0.8,0.8,0.8)
        GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)

        local n, z = _reqVendorInfo(it)
        _reqAddKey("Vendor", n)
        _reqAddKey("Zone", z)
        _reqAddKey("Faction", _reqResolveFaction(it))
        GameTooltip:Show()
        return
    end

    if req.kind == "quest" then
        if req.id then
            GameTooltip:SetHyperlink("quest:" .. tostring(req.id))
        else
            GameTooltip:AddLine(req.text or "Quest", 1,1,1)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("[Quest]", 0.6, 0.8, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
        GameTooltip:AddLine("Right Click: Vendor Location", 0.8,0.8,0.8)
        GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)

        local titleObj = _G.GameTooltipTextLeft1
        local questTitle = titleObj and titleObj:GetText()
        if questTitle and questTitle:lower():find("decor treasure hunt", 1, true) then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(
                "There are many versions of the Decor Treasure Hunt quest.",
                1, 0.2, 0.2, true
            )
            GameTooltip:AddLine(
                "Use Ctrl+Click to open the correct WoWHead link.",
                1, 0.2, 0.2, true
            )
        end

        local n, z = _reqVendorInfo(it)
        _reqAddKey("Vendor", n)
        _reqAddKey("Zone", z)
        _reqAddKey("Faction", _reqResolveFaction(it))
        GameTooltip:Show()
        return
    end
end

return M
