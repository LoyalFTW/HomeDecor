local ADDON, NS = ...
local TT = {}
NS.UI.Tooltips = TT

local function Own(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
end

local function Hide()
    GameTooltip:Hide()
end

local function AddLabel(text)
    if text then GameTooltip:AddLine(text, 0.6, 0.8, 1) end
end

local function AddKey(k, v)
    if v and v ~= "" then
        GameTooltip:AddDoubleLine(k, tostring(v), 0.8,0.8,0.8, 0.8,0.8,0.8)
    end
end

local function ShowItem(itemID)
    if not itemID then return false end
    GameTooltip:SetHyperlink("item:" .. itemID)
    return true
end

local function ShowAchievement(id)
    local link = id and GetAchievementLink and GetAchievementLink(id)
    if not link then return false end
    GameTooltip:SetHyperlink(link)
    return true
end

local function ShowQuest(id)
    if not id then return false end
    GameTooltip:SetHyperlink("quest:" .. id)
    return true
end

local function ShowSpell(spellID)
    if not spellID then return false end
    GameTooltip:SetSpellByID(spellID)
    return true
end

local function ResolveFaction(data)
    local f = (data.source and data.source.faction) or data.faction
    if not f then return nil end
    if type(f) == "table" then
        local a,h=false,false
        for _,v in pairs(f) do
            if v=="Alliance" then a=true end
            if v=="Horde" then h=true end
        end
        if a and h then return "Both" end
        if a then return "Alliance" end
        if h then return "Horde" end
    end
    if f=="Alliance" or f=="Horde" or f=="Neutral" or f=="Both" then
        return f
    end
    return tostring(f)
end

local function VendorInfo(data)
    if data._navVendor then
        return data._navVendor.title, data._navVendor.zone
    end
    local s = data.source or {}
    return s.vendor or s.vendorName or s.npc, s.zone or data.zone
end

local function CollectDropNPCs(data)
    local out, seen = {}, {}

    if type(data._dropSources) == "table" then
        for _, src in ipairs(data._dropSources) do
            local name = src.npc or src.name
            if name and not seen[name] then
                seen[name] = true
                out[#out+1] = name
            end
        end
    end

    local s = data.source or {}

    if s.mobSet and s._mobSets and s._mobSets[s.mobSet] then
        for _, mob in pairs(s._mobSets[s.mobSet]) do
            if mob.name and not seen[mob.name] then
                seen[mob.name] = true
                out[#out+1] = mob.name
            end
        end
    end

    if type(s.mobs) == "table" then
        for _, mob in pairs(s.mobs) do
            if mob.name and not seen[mob.name] then
                seen[mob.name] = true
                out[#out+1] = mob.name
            end
        end
    end

    if #out == 0 and s.npc then
        out[#out+1] = s.npc
    end

    table.sort(out)
    return (#out > 0) and out or nil
end

local function ProfessionSpellID(data)
    local s=data.source or {}
    return tonumber(s.spellID) or tonumber(s.skillID) or tonumber(s.recipeID)
        or tonumber(data.spellID) or tonumber(data.skillID) or tonumber(data.recipeID)
end

function TT:Attach(frame, data)
    if not frame or not data then return end
    frame:EnableMouse(true)

    frame:SetScript("OnEnter", function()
        Own(frame)
        local s = data.source or {}
        local t = s.type

        if data.type=="vendor" and data.items then
            GameTooltip:AddLine(data.title or "Vendor",1,1,1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
            GameTooltip:AddLine("Right Click: Vendor Location", 0.8,0.8,0.8)
            GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)
            AddKey("Zone", data.zone)
            AddKey("Faction", ResolveFaction(data))
            GameTooltip:Show(); return
        end

        if t=="vendor" then
            if ShowItem(data.id or s.itemID) then
                AddLabel("[Vendor Item]")
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
                GameTooltip:AddLine("Right Click: Vendor Location", 0.8,0.8,0.8)
                GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)
                local n,z = VendorInfo(data)
                AddKey("Vendor", n)
                AddKey("Zone", z)
                AddKey("Faction", ResolveFaction(data))
                GameTooltip:Show(); return
            end
        end

        if t=="drop" then
            ShowItem(s.itemID)
            AddLabel("[Drop]")
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
            GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)

            local list = CollectDropNPCs(data)
            if list then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Drops From:",0.9,0.9,0.9)
                for _,n in ipairs(list) do
                    GameTooltip:AddLine("* "..n,1,0.82,0)
                end
            end

            AddKey("Zone", s.zone)
            AddKey("Faction", ResolveFaction(data))
            GameTooltip:Show(); return
        end

        if t=="pvp" then
            ShowItem(s.itemID or data.id)
            AddLabel("[PvP]")
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
                GameTooltip:AddLine("Right Click: Vendor Location", 0.8,0.8,0.8)
                GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)
            local n,z = VendorInfo(data)
            AddKey("Vendor", n)
            AddKey("Zone", z)
            AddKey("Faction", ResolveFaction(data))
            GameTooltip:Show(); return
        end

        if t=="profession" then
            local sid = ProfessionSpellID(data)
            if ShowSpell(sid) then
                AddLabel("[Profession]")
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
                AddKey("Zone", s.zone)
                AddKey("Faction", ResolveFaction(data))
                GameTooltip:Show(); return
            end
        end
		
        if t=="achievement" and s.id then
            if ShowAchievement(s.id) then
                AddLabel("[Achievement]")
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Left Click: View Item", 0.8,0.8,0.8)
                GameTooltip:AddLine("Right Click: Vendor Location", 0.8,0.8,0.8)
                GameTooltip:AddLine("Ctrl + Click: View Achievement", 0.8,0.8,0.8)
                GameTooltip:AddLine("Alt + Click: Wowhead Link", 0.8,0.8,0.8)
                local n,z = VendorInfo(data)
                AddKey("Vendor", n)
                AddKey("Zone", z)
                AddKey("Faction", ResolveFaction(data))
                GameTooltip:Show(); return
            end
        end

		if t=="quest" and s.id then
			if ShowQuest(s.id) then
				AddLabel("[Quest]")
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

        local n, z = VendorInfo(data)
        if n then AddKey("Vendor", n) end
        if z then AddKey("Zone", z) end
        local f = ResolveFaction(data)
        if f then AddKey("Faction", f) end

        GameTooltip:Show()
        return
    end
end


        if data.title then GameTooltip:AddLine(data.title,1,1,1) end
        AddKey("Zone", s.zone)
        AddKey("Faction", ResolveFaction(data))
        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", Hide)
end

return TT
