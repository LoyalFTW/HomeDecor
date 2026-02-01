local _, NS = ...
NS.UI = NS.UI or {}

local Tracker = NS.UI.Tracker or {}
NS.UI.Tracker = Tracker

local Render = NS.UI.TrackerRender or {}
NS.UI.TrackerRender = Render
Tracker.Render = Render

local Rows = NS.UI.TrackerRows
local U = NS.UI.TrackerUtil
local IA = NS.UI.ItemInteractions
local Map = NS.Systems and NS.Systems.MapTracker

local wipe = _G.wipe or function(t) for k in pairs(t) do t[k] = nil end end
local max = math.max

local function GetZone()
  if Map and Map.GetCurrentZone then
    local name, mapID = Map:GetCurrentZone()
    if name or mapID then
      return name or ((GetRealZoneText and GetRealZoneText()) or ""), mapID
    end
  end
  return (GetRealZoneText and GetRealZoneText()) or "", nil
end

local function VendorKey(v)
  if type(v) ~= "table" then return "vendor:0" end
  local src = v.source
  return "vendor:" .. tostring((src and src.id) or v.npcID or v.id or "")
    .. ":" .. tostring(v.worldmap or (src and src.worldmap) or "")
    .. ":" .. tostring(v.title or "")
end

local function IsValid(it)
  if type(it) ~= "table" then return false end
  local did = tonumber(it.decorID)
  local iid = tonumber((it.source and it.source.itemID) or it.itemID or it.id)
  if did == 0 or iid == 0 then return false end
  if did and did < 0 then return false end
  if iid and iid < 0 then return false end
  if (did and did > 0) then return true end
  local title = it.title
  if type(title) ~= "string" then return false end
  return title:gsub("%s+", "") ~= ""
end

local function FetchZoneVendors()
  if not (Map and Map.GetVendorsForCurrentZone) then
    return {}
  end

  local prof = NS.Addon and NS.Addon.db and NS.Addon.db.profile
  local ui = prof and prof.ui
  local prevCat, prevSearch
  if ui then
    prevCat, prevSearch = ui.activeCategory, ui.search
    ui.activeCategory, ui.search = nil, ""
  end

  local vendors = Map:GetVendorsForCurrentZone() or {}

  if ui then
    ui.activeCategory, ui.search = prevCat, prevSearch
  end

  if type(vendors) == "table" and #vendors == 0 then
    local flat
    for _, set in pairs(vendors) do
      if type(set) == "table" then
        for _, v in ipairs(set) do
          flat = flat or {}
          flat[#flat + 1] = v
        end
      end
    end
    if flat and #flat > 0 then
      vendors = flat
    end
  end

  return vendors
end

local function SetArrow(tex, open)
  if tex and tex.SetRotation then
    tex:SetRotation(open and -1.5708 or 0)
  end
end

local function ItemFaction(it)
  local f = it and (it.faction or (it.source and it.source.faction))
  if f == "Alliance" or f == "Horde" then
    return f
  end
end

function Render:Attach(_, ctx)
  local frame = ctx.frame
  local trackCB = ctx.trackCB
  local overall = ctx.overallRow
  local content = ctx.content

  Rows:InitPools(frame, content)

  local GetDecorIcon = U and U.GetDecorIcon
  local GetDecorName = U and U.GetDecorName
  local IsCollected = U and U.IsCollectedSafe
  local GetReqLines = U and U.GetAQAndRepLines

  frame._collectedCache = frame._collectedCache or {}
  frame._scratchVisible = frame._scratchVisible or {}
  frame._openVendors = frame._openVendors or {}

  function frame:Refresh()
    local tracking = trackCB:GetChecked() and true or false
    local zoneName, zoneMapID = tracking and GetZone() or ((GetRealZoneText and GetRealZoneText()) or ""), nil

    frame._lastZoneName, frame._lastZoneMapID = zoneName, zoneMapID
    overall.zone:SetText(zoneName or "")

    if zoneName ~= frame._shownZoneName then
      frame._shownZoneName = zoneName
      Rows:StopPulse(overall.zone)
    end

    if frame._collapsed then return end

    Rows:ReleaseAll(frame)
    if frame._SyncContentWidth then
      frame:_SyncContentWidth()
    end

    local vendors = tracking and FetchZoneVendors() or {}
    local cAll, tAll = 0, 0

    overall.count:SetText("")
    if overall.bar then
      overall.bar:Hide()
    end

    local collectedCache = frame._collectedCache
    wipe(collectedCache)

    local visible = frame._scratchVisible
    local y = 0

    for _, v in ipairs(vendors) do
      local items = (type(v) == "table" and type(v.items) == "table") and v.items or nil
      if items then
        wipe(visible)
        local cV, tV = 0, 0

        for _, it in ipairs(items) do
          if IsValid(it) then
            local did = it.decorID or it.id or tostring(it)
            local collected = collectedCache[did]
            if collected == nil then
              collected = IsCollected and IsCollected(it) or false
              collectedCache[did] = collected
            end
            if not (frame._hideCompleted and collected) then
              tV = tV + 1
              if collected then
                cV = cV + 1
              end
              visible[#visible + 1] = it
            end
          end
        end

        if tV > 0 then
          local vKey = VendorKey(v)
          local open = (frame._openVendors[vKey] == true)

          cAll = cAll + cV
          tAll = tAll + tV

          local vr = Rows:Acquire(frame, "vendor")
          vr:SetPoint("TOPLEFT", 0, -y)
          vr:SetPoint("TOPRIGHT", 0, -y)
          vr.label:SetText((v.title and v.title ~= "" and v.title) or "Vendor")
          vr.count:SetText(cV .. " / " .. tV)
          if vr.bar then
            vr.bar:SetProgress(cV, tV)
            vr.bar:Show()
          end
          SetArrow(vr.arrow, open)

          vr._owner, vr._vKey = frame, vKey
          if not vr.__hdVendorClick then
            vr.__hdVendorClick = true
            vr:SetScript("OnClick", function(self)
              local owner, key = self._owner, self._vKey
              if not owner or not key then return end
              owner._openVendors[key] = not (owner._openVendors[key] == true)
              owner:RequestRefresh("toggle")
            end)
          end

          y = y + (vr:GetHeight() or 34) + 8

          if open then
            for i = 1, #visible do
              local it = visible[i]
              local did = it.decorID or it.id or tostring(it)
              local collected = collectedCache[did]

              local ir = Rows:Acquire(frame, "item")
              ir:SetPoint("TOPLEFT", 0, -y)
              ir:SetPoint("TOPRIGHT", 0, -y)

              local title = it.title
              if (not title or title == "") and GetDecorName and it.decorID then
                title = GetDecorName(it.decorID)
              end
              if not title or title == "" then
                title = "Decor " .. tostring(it.decorID or "")
              end
              ir.title:SetText(title)

              if ir.icon then
                ir.icon:SetTexture((GetDecorIcon and GetDecorIcon(it.decorID)) or "Interface\\Icons\\INV_Misc_QuestionMark")
              end

              local aq, rep = nil, nil
              if GetReqLines then
                aq, rep = GetReqLines(it)
              end
              if aq then
                ir.reqAQ:SetText(aq)
                ir.reqAQ:Show()
              else
                ir.reqAQ:Hide()
              end
              if rep then
                ir.reqRep:SetText(rep)
                ir.reqRep:Show()
              else
                ir.reqRep:Hide()
              end

              if collected then
                ir.check:Show()
              else
                ir.check:Hide()
              end

              local fac = ItemFaction(it)
              if fac == "Alliance" then
                ir.faction:SetTexture(ir._texAlliance)
                ir.faction:Show()
              elseif fac == "Horde" then
                ir.faction:SetTexture(ir._texHorde)
                ir.faction:Show()
              else
                ir.faction:Hide()
              end

              if IA and IA.Bind then
                IA:Bind(ir, it, it._navVendor or it.vendor or v)
              end

              y = y + (ir:GetHeight() or 54) + 8
            end
          end
        end
      end
    end

    overall.count:SetText(tAll > 0 and (cAll .. " / " .. tAll) or "")
    if overall.bar and tAll > 0 then
      overall.bar:SetProgress(cAll, tAll)
      overall.bar:Show()
    elseif overall.bar then
      overall.bar:Hide()
    end

    content:SetHeight(max(1, y))
    if frame._SyncBarsToWidth then
      frame:_SyncBarsToWidth()
    end
    if frame._ApplyPanelsAlpha then
      frame:_ApplyPanelsAlpha(frame._bgAlpha, false)
    end
  end

  trackCB:SetScript("OnClick", function()
    local checked = trackCB:GetChecked() and true or false
    local db = ctx.GetDB and ctx.GetDB() or nil
    if db then
      db.trackZone = checked
    end
    if Map and Map.Enable then
      Map:Enable(checked)
    end
    frame:RequestRefresh("trackzone")
  end)
end

return Render
