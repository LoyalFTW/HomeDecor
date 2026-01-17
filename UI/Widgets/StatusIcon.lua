local ADDON, NS = ...
NS.UI = NS.UI or {}
NS.UI.StatusIcon = NS.UI.StatusIcon or {}

local TEX_CHECK = "Interface/Buttons/UI-CheckBox-Check"
local TEX_ALLI  = "Interface\\Icons\\INV_BannerPVP_02"
local TEX_HORDE = "Interface\\Icons\\INV_BannerPVP_01"

function NS.UI.StatusIcon:Attach(parent, state, it)
    if not parent then return end

    if parent._kind == "header" then
        if parent._statusIcon then parent._statusIcon:Hide() end
        if parent._factionIcon then parent._factionIcon:Hide() end
        return
    end

    local check = parent._statusIcon
    if not check then
        check = parent:CreateTexture(nil, "OVERLAY")
        check:SetSize(16, 16)
        parent._statusIcon = check
    end

    check:ClearAllPoints()

    if parent._kind == "tile" then
        check:SetPoint("TOP", parent, "TOP", 0, -6)
    else
        check:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    end

    if state == "COLLECTED" then
        check:SetTexture(TEX_CHECK)
        check:SetVertexColor(0.2, 1, 0.2)
        check:Show()
    else
        check:Hide()
    end

    local faction =
        it and (
            it.faction or
            (it.source and it.source.faction)
        )

    if faction ~= "Alliance" and faction ~= "Horde" then
        if parent._factionIcon then parent._factionIcon:Hide() end
        return
    end

    local fic = parent._factionIcon
    if not fic then
        fic = parent:CreateTexture(nil, "OVERLAY")
        fic:SetSize(24, 24)
        parent._factionIcon = fic
    end

    fic:ClearAllPoints()

    if parent._kind == "list" then
        fic:SetPoint("LEFT", parent, "LEFT", 28, 0)
    else
        fic:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -6, -6)
    end

    fic:SetTexture(faction == "Alliance" and TEX_ALLI or TEX_HORDE)
    fic:Show()
end
