local ADDON, NS = ...
NS.UI = NS.UI or {}

local View = NS.UI.Viewer
if not View then return end

local Render = View.Render
if not Render then return end

local D = View.Data
local U = View.Util
local S = View.Search
local R = View.Requirements

local C_Timer = _G.C_Timer
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetTime = _G.GetTime

local TT = NS.UI.Tooltips
local Favorite = NS.UI.FavoriteStar
local StatusIcon = NS.UI.StatusIcon
local ProgressBar = NS.UI.ProgressBar
local DropPanel = NS.UI.DropPanel
local HeaderCtrl = NS.UI.HeaderController
local FiltersSys = NS.Systems and NS.Systems.Filters
local Collection = NS.Systems and NS.Systems.Collection
local RS = NS.UI.RowStyles
local IA = NS.UI.ItemInteractions

local TEX_ALLI = D and D.TEX_ALLI
local TEX_HORDE = D and D.TEX_HORDE

local ResolveAchievementDecor = (D and D.ResolveAchievementDecor) or function(x) return x end
local AttachVendorCtx = (D and D.AttachVendorCtx) or (S and S.AttachVendorCtx)
local GetDecorIcon = D and D.GetDecorIcon
local GetDecorName = D and D.GetDecorName
local NormalizeExpansionNode = D and D.NormalizeExpansionNode
local GetExpansionOrder = D and D.GetExpansionOrder
local getActiveData = D and D.GetActiveData
local keyExp = D and D.KeyExp
local keyZone = D and D.KeyZone
local keyVendor = D and D.KeyVendor
local ResolveVendorTitle = D and D.ResolveVendorTitle


local DB = U and U.DB
local Passes = U and U.Passes
local IsCollectedSafe = U and U.IsCollectedSafe
local GetStateSafe = U and U.GetStateSafe
local GetItemID = U and U.GetItemID
local trim = U and U.Trim
local copyShallow = U and U.CopyShallow
local clamp = U and U.Clamp
local ClampScroll = U and U.ClampScroll

local BuildGlobalSearchResults = S and S.BuildGlobalSearchResults
local CollectAllFavorites = S and S.CollectAllFavorites

local ShowWowheadLinks = R and R.ShowWowheadLinks
local BuildWowheadQuestURL = R and R.BuildWowheadQuestURL
local BuildWowheadAchievementURL = R and R.BuildWowheadAchievementURL
local GetRequirementLink = R and R.GetRequirementLink
local BuildReqDisplay = R and R.BuildReqDisplay
local GetRepRequirement = R and R.GetRepRequirement
local BuildRepDisplay = R and R.BuildRepDisplay

local floor = math.floor
local function Pixel(v) return v and floor(v + 0.5) or 0 end

local function wipeTable(t)
  if type(t) ~= "table" then return end
  for k in pairs(t) do t[k] = nil end
end

local ROW_GAP, LIST_H, LIST_GAP, PAD_TOP, PAD_BOTTOM = 8, 84, 6, 10, 12

local tileW, tileH, tileGap, iconSize = 180, 156, 16, 64

local function countItems(items, vendorCtx)
  local total, collected = 0, 0

  local function countOne(it, vctx)
    if not it then return end
    local rit = it
    if vctx and AttachVendorCtx then AttachVendorCtx(rit, vctx) end
    rit = ResolveAchievementDecor(rit)
    if Passes and Passes(rit) then
      total = total + 1
      if IsCollectedSafe and IsCollectedSafe(rit) then collected = collected + 1 end
    end
  end

  if vendorCtx then
    for _, it in ipairs(items or {}) do countOne(it, vendorCtx) end
    return collected, total
  end

  for _, it in ipairs(items or {}) do
    local src = it and it.source
    if type(it) == "table" and src and src.type == "vendor" and type(it.items) == "table" then
      for _, leaf in ipairs(it.items) do countOne(leaf, it) end
    else
      countOne(it, nil)
    end
  end

  return collected, total
end

local function findFirstVisible(entries, y)
  if not entries then return 1 end
  local lo, hi = 1, #entries
  local res = hi + 1
  while lo <= hi do
    local mid = floor((lo + hi) / 2)
    local e = entries[mid]
    local bottom = (e.y or 0) + (e.h or 0)
    if bottom >= y then
      res = mid
      hi = mid - 1
    else
      lo = mid + 1
    end
  end
  return res
end

local function applyFactionBadge(fr, it, size)
  if not (fr and it and fr.factionIcon) then return end
  local fac = it.faction or (it.source and it.source.faction)
  local icon = (fac == "Alliance") and TEX_ALLI or (fac == "Horde") and TEX_HORDE or nil

  fr.factionIcon:ClearAllPoints()
  fr.factionIcon:SetPoint("TOPRIGHT", (fr.media or fr), "TOPRIGHT", -8, -8)
  if fr.factionIcon.SetSize then fr.factionIcon:SetSize(size or 16, size or 16) end

  if icon and fr.factionIcon.SetTexture then
    fr.factionIcon:SetTexture(icon)
    fr.factionIcon:Show()
  else
    fr.factionIcon:Hide()
  end

  if fr._statusIcon and fr._statusIcon.GetTexture then
    local t = fr._statusIcon:GetTexture()
    if t == TEX_ALLI or t == TEX_HORDE then fr._statusIcon:Hide() end
  end
end

local function setupFavoriteHover(btn)
  if not (btn and btn.HookScript) or btn.favHoverBound then return end
  btn.favHoverBound = true
  btn:HookScript("OnEnter", function(b)
    if b.SetAlpha then b:SetAlpha(1.0) end
    if b.SetScale then b:SetScale(1.12) end
  end)
  btn:HookScript("OnLeave", function(b)
    if b.SetAlpha then b:SetAlpha(0.85) end
    if b.SetScale then b:SetScale(1.0) end
  end)
end

local function reqEnter(btn)
  local row = btn and btn:GetParent()
  local req = row and row.req and row.req._req
  if not req then return end
  if row.req and BuildReqDisplay then row.req:SetText(BuildReqDisplay(req, true)) end
  if TT and TT.ShowRequirement then TT:ShowRequirement(btn, req) end
end

local function reqLeave(btn)
  local row = btn and btn:GetParent()
  local req = row and row.req and row.req._req
  if not req then return end
  if row.req and BuildReqDisplay then row.req:SetText(BuildReqDisplay(req, false)) end
  if GameTooltip then GameTooltip:Hide() end
end

local function reqClick(btn)
  local row = btn and btn:GetParent()
  local req = row and row.req and row.req._req
  if not req then return end
  if not (ShowWowheadLinks and BuildWowheadQuestURL and BuildWowheadAchievementURL) then return end
  local url = (req.kind == "quest") and BuildWowheadQuestURL(req.id) or BuildWowheadAchievementURL(req.id)
  ShowWowheadLinks({ { label = "Link", url = url } })
end

local function bindReqButton(btn)
  if btn and not btn.reqScriptsBound then
    btn.reqScriptsBound = true
    btn:SetScript("OnEnter", reqEnter)
    btn:SetScript("OnLeave", reqLeave)
    btn:SetScript("OnClick", reqClick)
  end
end

local function headerClick(self)
  local f = self and self._owner
  if not f then return end
  local entry = self._entry
  if not entry or not entry.payload or not entry.payload.key then return end

  if entry.payload.vendor then
    entry.payload.vendor._uiOpen = not entry.payload.vendor._uiOpen
    if f.Render then f:Render() end
    return
  end

  local sf = f._scrollFrame
  local content = f._scrollContent
  if not sf or not content then return end

  local preScroll = sf:GetVerticalScroll() or 0
  local anchorY = entry.y or 0
  local anchorOff = anchorY - preScroll

  if not (HeaderCtrl and HeaderCtrl.Toggle) then return end

  local kind = entry.clickKind
  if kind ~= nil then
    kind = tostring(kind):lower()
    if kind:find("vendor", 1, true) then
      kind = "vendor"
    elseif kind:find("zone", 1, true) then
      kind = "zone"
    elseif kind:find("event", 1, true) then
      kind = "event"
    else
      kind = "exp"
    end
  end

  HeaderCtrl:Toggle(kind, entry.payload.key)
  if f.Render then f:Render() end

  local newY = anchorY
  local map = f._headerYByKey
  if map and map[entry.payload.key] then
    newY = map[entry.payload.key]
  end

  if ClampScroll then
    sf:SetVerticalScroll(ClampScroll(sf, content, newY - anchorOff))
  end
end

function Render:Create(parent)


local NS = NS
local View = NS.UI and NS.UI.Viewer
local D = View and View.Data
local U = View and View.Util
local S = View and View.Search
local R = View and View.Requirements

local C_Timer = _G.C_Timer
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime

local TT = NS.UI and NS.UI.Tooltips
local Favorite = NS.UI and NS.UI.FavoriteStar
local StatusIcon = NS.UI and NS.UI.StatusIcon
local ProgressBar = NS.UI and NS.UI.ProgressBar
local DropPanel = NS.UI and NS.UI.DropPanel
local HeaderCtrl = NS.UI and NS.UI.HeaderController
local FiltersSys = NS.Systems and NS.Systems.Filters
local Collection = NS.Systems and NS.Systems.Collection
local RS = NS.UI and NS.UI.RowStyles
local IA = NS.UI and NS.UI.ItemInteractions

local TEX_ALLI = D and D.TEX_ALLI
local TEX_HORDE = D and D.TEX_HORDE

local ResolveAchievementDecor = (D and D.ResolveAchievementDecor) or function(x) return x end
local AttachVendorCtx = (D and D.AttachVendorCtx) or (S and S.AttachVendorCtx)
local GetDecorIcon = D and D.GetDecorIcon
local GetDecorName = D and D.GetDecorName
local NormalizeExpansionNode = D and D.NormalizeExpansionNode
local GetExpansionOrder = D and D.GetExpansionOrder
local getActiveData = D and D.GetActiveData
local keyExp = D and D.KeyExp
local keyZone = D and D.KeyZone
local keyVendor = D and D.KeyVendor
local ResolveVendorTitle = D and D.ResolveVendorTitle

local DB = U and U.DB
local Passes = U and U.Passes
local IsCollectedSafe = U and U.IsCollectedSafe
local GetStateSafe = U and U.GetStateSafe
local GetItemID = U and U.GetItemID
local trim = U and U.Trim
local copyShallow = U and U.CopyShallow
local clamp = U and U.Clamp
local ClampScroll = U and U.ClampScroll

local BuildGlobalSearchResults = S and S.BuildGlobalSearchResults
local CollectAllFavorites = S and S.CollectAllFavorites

local ShowWowheadLinks = R and R.ShowWowheadLinks
local BuildWowheadQuestURL = R and R.BuildWowheadQuestURL
local BuildWowheadAchievementURL = R and R.BuildWowheadAchievementURL
local GetRequirementLink = R and R.GetRequirementLink
local BuildReqDisplay = R and R.BuildReqDisplay
local GetRepRequirement = R and R.GetRepRequirement
local BuildRepDisplay = R and R.BuildRepDisplay

local floor = math.floor
local function Pixel(v) return v and floor(v + 0.5) or 0 end

local ROW_GAP, LIST_H, LIST_GAP, PAD_TOP, PAD_BOTTOM = 8, 84, 6, 10, 12
local tileW, tileH, tileGap, iconSize = 180, 156, 16, 64
  local f = CreateFrame("Frame", nil, parent)
  f:SetAllPoints()
  f._suspendRender = false

  parent:HookScript("OnDragStart", function() f._suspendRender = true end)
  parent:HookScript("OnDragStop", function()
    f._suspendRender = false
    if f.Render then f:Render() end
  end)

  local function QueueRender(delay)
    if f._renderTimer and f._renderTimer.Cancel then
      f._renderTimer:Cancel()
      f._renderTimer = nil
    end
    local d = tonumber(delay) or 0
    if d < 0 then d = 0 end
    f._renderTimer = C_Timer.NewTimer(d, function()
      f._renderTimer = nil
      if not f or not f.IsShown or not f:IsShown() then return end
      if f.Render then f:Render() end
    end)
  end

  local collectionQueued = false
  function f:RequestCollectionRefresh()
    if collectionQueued then return end
    collectionQueued = true
    C_Timer.After(0, function()
      collectionQueued = false
      QueueRender(0)
    end)
  end

  function f:RefreshDecor(decorID)
    if not decorID then return end
    for i = 1, #self._active do
      local fr = self._active[i]
      local e = fr and fr._entry
      if e and e.kind ~= "header" then
        local it = ResolveAchievementDecor(e.it)
        if it and it.decorID == decorID then
          local state = GetStateSafe and GetStateSafe(it)
          if StatusIcon and StatusIcon.Attach then
            StatusIcon:Attach(fr, state, it)
            if fr._kind == "list" and fr._statusIcon and fr._statusIcon.GetTexture then
              local t = fr._statusIcon:GetTexture()
              if t == "Interface\\RaidFrame\\ReadyCheck-Ready" or t == TEX_ALLI or t == TEX_HORDE then
                fr._statusIcon:Hide()
              end
            end
          end
          applyFactionBadge(fr, it, 16)
        end
      end
    end
  end

  local sf = CreateFrame("ScrollFrame", nil, f, "ScrollFrameTemplate")
  if NS.UI and NS.UI.Controls and NS.UI.Controls.SkinScrollFrame then
    NS.UI.Controls:SkinScrollFrame(sf)
  end
  sf:SetPoint("TOPLEFT", 8, -52)
  sf:SetPoint("BOTTOMRIGHT", -28, 8)

  local content = CreateFrame("Frame", nil, sf)
  content:SetPoint("TOPLEFT", 0, 0)
  sf:SetScrollChild(content)

  f._scrollFrame = sf
  f._scrollContent = content

  sf:SetScript("OnSizeChanged", function(_, w)
    content:SetWidth((w or 0) - 18)
    if not f or not f.UpdateVisible then return end

    f._resizeToken = (f._resizeToken or 0) + 1
    local tok = f._resizeToken

    C_Timer.After(0, function()
      if not f or tok ~= f._resizeToken then return end
      if f.ReflowWidth then pcall(f.ReflowWidth, f) end
      f:UpdateVisible()
    end)

    C_Timer.After(0.12, function()
      if not f or tok ~= f._resizeToken then return end
      if f.Render then f:Render() end
    end)
  end)

  sf:SetScript("OnVerticalScroll", function()
    if f.UpdateVisible then f:UpdateVisible() end
  end)

  if Collection and Collection.OnChange then
    local fullQueued, lastAny, lastFull = false, 0, 0
    local lastDecor = {}

    local function QueueOneFullRender()
      if fullQueued then return end
      fullQueued = true
      C_Timer.After(0.35, function()
        fullQueued = false
        if not f or not f.IsShown or not f:IsShown() then return end
        if f.RequestCollectionRefresh then f:RequestCollectionRefresh() end
      end)
    end

    Collection:OnChange(function(payload)
      if not f or not f.IsShown or not f:IsShown() then return end
      local now = GetTime and GetTime() or 0

      if payload and payload.decorID and f.RefreshDecor then
        local did = payload.decorID
        local last = lastDecor[did]
        if not last or (now - last) > 0.25 then
          lastDecor[did] = now
          f:RefreshDecor(did)
        end
        if (now - lastFull) > 1.0 then
          lastFull = now
          QueueOneFullRender()
        end
        return
      end

      if (now - lastAny) < 1.0 then return end
      lastAny = now
      if f.RequestCollectionRefresh then f:RequestCollectionRefresh() end
    end)
  end

  f._poolHeader, f._poolList, f._poolTile, f._active = {}, {}, {}, {}

  local function ClearPooledArtifacts(fr)
    if not fr then return end
    if fr._dropBadge then fr._dropBadge:Hide() end
    if fr._fav then
      fr._fav:Hide()
      if fr._fav.SetScale then fr._fav:SetScale(1.0) end
      if fr._fav.SetAlpha then fr._fav:SetAlpha(0.85) end
    end
    if fr.factionIcon then fr.factionIcon:Hide() end
    if fr._statusIcon then fr._statusIcon:Hide() end
    if fr._status then fr._status:Hide() end
    if fr.bar then fr.bar:Hide() end
    if fr.req then fr.req:Hide() end
    if fr.reqBtn then fr.reqBtn:Hide() end
    if fr.rep then fr.rep:Hide() end
  end

  local function ReleaseFrame(frame)
    if not frame then return end
    ClearPooledArtifacts(frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame._entry = nil
    frame:SetParent(content)
  end

  function f:ReleaseAll()
    for i = 1, #self._active do
      local fr = self._active[i]
      ReleaseFrame(fr)
      if fr._kind == "header" then
        self._poolHeader[#self._poolHeader + 1] = fr
      elseif fr._kind == "tile" then
        self._poolTile[#self._poolTile + 1] = fr
      else
        self._poolList[#self._poolList + 1] = fr
      end
    end
    wipeTable(self._active)
  end

  local Frames = View.Frames
  local function CreateHeader() return Frames.CreateHeader(content) end
  local function CreateListRow() return Frames.CreateListRow(content) end
  local function CreateTile() return Frames.CreateTile(content) end

  local function Acquire(kind)
    local fr
    if kind == "header" then
      fr = table.remove(f._poolHeader)
      if not fr then fr = CreateHeader() end
    elseif kind == "tile" then
      fr = table.remove(f._poolTile)
      if not fr then fr = CreateTile() end
    else
      fr = table.remove(f._poolList)
      if not fr then fr = CreateListRow() end
    end
    fr._owner = f
    fr:Show()
    f._active[#f._active + 1] = fr
    return fr
  end

  local function getAvailableWidth(indent)
    return math.max(0, (content:GetWidth() or 0) - indent - 8)
  end

  local lastGridAvail, lastGridCols, lastGridStartX
  local function computeGrid(indent)
    local avail = getAvailableWidth(indent)
    if lastGridAvail and math.abs(avail - lastGridAvail) < 4 then
      return lastGridCols, lastGridStartX
    end
    lastGridAvail = avail

    local minTileW, maxTileW = 150, 240
    local minCols, maxCols = 2, 6
    local gap = 14

    local est = floor((avail + gap) / (minTileW + gap))
    local cols = clamp and clamp(est, minCols, maxCols) or est
    if cols < minCols then cols = minCols end
    if cols > maxCols then cols = maxCols end

    local w = floor((avail - (cols - 1) * gap) / cols)
    if clamp then w = clamp(w, minTileW, maxTileW) end

    while cols < maxCols do
      local w2 = floor((avail - cols * gap) / (cols + 1))
      if w2 >= minTileW then
        cols = cols + 1
        w = clamp and clamp(w2, minTileW, maxTileW) or w2
      else
        break
      end
    end

    tileW = w
    tileGap = gap
    tileH = floor(tileW * 0.95) + 58
    iconSize = clamp and clamp(floor(tileW * 0.42), 56, 86) or floor(tileW * 0.42)

    local total = cols * tileW + (cols - 1) * tileGap
    local startX = indent + math.max(0, (avail - total) / 2)

    lastGridCols = cols
    lastGridStartX = startX
    return cols, startX
  end

  function f:RebuildEntries()
    local db = DB and DB()
    if not db then self.entries = {}; return end

    local ui = db.ui or {}
    if FiltersSys and FiltersSys.EnsureDefaults then FiltersSys:EnsureDefaults(db) end

    local entries = self.entries or {}
    wipeTable(entries)
    self.entries = entries

    local headerY = self._headerYByKey or {}
    wipeTable(headerY)
    self._headerYByKey = headerY

    local y = PAD_TOP
    local cat = ui.activeCategory or "Achievements"
    local viewMode = ui.viewMode or "Icon"

    local function addHeader(indent, height, label, cur, max, expandedState, clickKind, payload)
      cur = cur or 0
      max = max or 0
      if max <= 0 then return end
      local y0 = y
      entries[#entries + 1] = {
        kind = "header",
        clickKind = clickKind,
        payload = payload,
        indent = indent,
        x = indent,
        y = y0,
        w = (content:GetWidth() or 0) - indent - 8,
        h = height,
        label = label,
        cur = cur,
        max = max,
        expanded = expandedState and true or false,
      }
      if payload and payload.key then headerY[payload.key] = y0 end
      y = y0 + height + ROW_GAP
    end

    local function addListItem(indent, it, nav)
      entries[#entries + 1] = {
        kind = "list",
        x = indent,
        y = y,
        w = (content:GetWidth() or 0) - indent - 8,
        h = LIST_H,
        indent = indent,
        it = it,
        nav = nav,
      }
      y = y + LIST_H + LIST_GAP
    end

    local function addTile(indent, it, nav, col, startX)
      entries[#entries + 1] = {
        kind = "tile",
        x = startX + col * (tileW + tileGap),
        y = y,
        w = tileW,
        h = tileH,
        indent = indent,
        it = it,
        nav = nav,
      }
    end

    local q = trim and trim(ui.search) or (ui.search or "")
    local fdb = db.filters or {}
    local searching = (q ~= "")
    local flatMode =
      (q ~= "") or
      (fdb and ((fdb.subcategory and fdb.subcategory ~= "ALL") or (fdb.category and fdb.category ~= "ALL")))

    if flatMode then
      local results = BuildGlobalSearchResults and BuildGlobalSearchResults(ui, db) or {}
      if viewMode == "Icon" then
        local cols, startX = computeGrid(12)
        local col = 0
        for _, it in ipairs(results) do
          addTile(12, it, it and (it.vendor or it.source) or nil, col, startX)
          col = col + 1
          if col >= cols then
            col = 0
            y = y + tileH + tileGap
          end
        end
        if col > 0 then y = y + tileH + tileGap end
      else
        for _, it in ipairs(results) do addListItem(12, it, it and (it.vendor or it.source) or nil) end
      end
      self.totalHeight = y + PAD_BOTTOM
      return
    end

    if cat == "Saved Items" then
      local favs = CollectAllFavorites and CollectAllFavorites(db) or {}
      if viewMode == "Icon" then
        local cols, startX = computeGrid(12)
        local col = 0
        for _, it in ipairs(favs) do
          if not (FiltersSys and FiltersSys.Passes) or FiltersSys:Passes(it, ui, db) then
            addTile(12, it, it and (it.vendor or it.source) or nil, col, startX)
            col = col + 1
            if col >= cols then
              col = 0
              y = y + tileH + tileGap
            end
          end
        end
        if col > 0 then y = y + tileH + tileGap end
      else
        for _, it in ipairs(favs) do
          if not (FiltersSys and FiltersSys.Passes) or FiltersSys:Passes(it, ui, db) then
            addListItem(12, it, it and (it.vendor or it.source) or nil)
          end
        end
      end
      self.totalHeight = y + PAD_BOTTOM
      return
    end

    if cat == "Events" then
      local Ev = NS.Systems and NS.Systems.Events
      local list = {}
      if Ev and Ev.GetActive then
        local v = Ev:GetActive()
        if type(v) == "table" then list = v end
      elseif NS.Data and type(NS.Data.Events) == "table" then
        list = NS.Data.Events
      end

      if #list == 0 then
        addListItem(12, {
          title = "No active events",
          decorType = "Event items will appear here while active",
          source = { type = "event", icon = "Interface\\Icons\\INV_Misc_PocketWatch_01" },
        }, nil)
        self.totalHeight = y + PAD_BOTTOM
        return
      end

      local function mergeItemSource(ev, it)
        if type(it) ~= "table" then return end
        it.source = it.source or {}
        if type(ev) == "table" and type(ev.source) == "table" then
          for k, v in pairs(ev.source) do
            if it.source[k] == nil then it.source[k] = v end
          end
        end
        if it.source and it.source.type == nil then it.source.type = "event" end
      end

      local function isEventOpen(key)
        if searching then return true end
        if HeaderCtrl and HeaderCtrl.IsOpen then
          local v = HeaderCtrl:IsOpen("event", key)
          if v ~= nil then return v and true or false end
        end
        return true
      end

      for _, ev in ipairs(list) do
        local eTitle = ev.title or ev.name or "Event"
        local evKey = "event:" .. tostring(ev.id or ev.key or eTitle)

        local ttext = ev.timeText
        if (not ttext or ttext == "") and Ev and Ev.GetTimeText and (ev._endsEpoch or ev.endsAt) then
          ttext = Ev:GetTimeText(ev._endsEpoch or ev.endsAt)
        end

        local label = eTitle
        if ttext and ttext ~= "" then
          label = label .. "  |cff9fb0c5" .. ttext .. "|r"
        end

        local open = isEventOpen(evKey)

        local group = {}
        local cEv, tEv = 0, 0

        if type(ev.items) == "table" then
          for _, it0 in ipairs(ev.items) do
            if type(it0) == "table" then
              local it = copyShallow and copyShallow(it0) or it0
              it._isEventTimed = true
              it._eventTitle = eTitle

              mergeItemSource(ev, it)

              if not it.title or it.title == "" then
                local nm = (it.decorID and GetDecorName and GetDecorName(it.decorID)) or nil
                if not nm or nm == "" then
                  it.title = "Decor #" .. tostring(it.decorID or it.itemID or "?")
                else
                  it.title = nm
                end
              end
              if viewMode == "Icon" then it.decorType = eTitle end

              if not (FiltersSys and FiltersSys.Passes) or FiltersSys:Passes(it, ui, db) then
                if Passes and Passes(it) then
                  tEv = tEv + 1
                  if IsCollectedSafe and IsCollectedSafe(it) then cEv = cEv + 1 end
                end
                group[#group + 1] = it
              end
            end
          end
        end

        addHeader(12, 44, label, cEv, tEv, open, "event", { key = evKey, event = ev })

        if open and #group > 0 then
          if viewMode == "Icon" then
            local cols, startX = computeGrid(28)
            local col = 0
            for _, it in ipairs(group) do
              if col >= cols then
                col = 0
                y = y + tileH + tileGap
              end
              addTile(28, it, ev, col, startX)
              col = col + 1
            end
            if col > 0 then y = y + tileH + tileGap end
          else
            for _, it in ipairs(group) do addListItem(28, it, ev) end
          end
        end
      end

      self.totalHeight = y + PAD_BOTTOM
      return
    end

    local data = getActiveData and getActiveData(ui)
    if not data then
      self.totalHeight = y + PAD_BOTTOM
      return
    end

    local expOrder = GetExpansionOrder and GetExpansionOrder(data) or {}
    for _, exp in ipairs(expOrder) do
      local zones = NormalizeExpansionNode and NormalizeExpansionNode(data[exp]) or {}
      local eCollected, eTotal = 0, 0

      for _, items in pairs(zones) do
        local c, t = countItems(items)
        eCollected = eCollected + c
        eTotal = eTotal + t
      end

      local eKey = keyExp and keyExp(cat, exp) or (cat .. ":" .. tostring(exp))
      local expOpen = searching or (HeaderCtrl and HeaderCtrl.IsOpen and HeaderCtrl:IsOpen("exp", eKey))

      addHeader(12, 44, exp, eCollected, eTotal, expOpen, "exp", { key = eKey })

      if expOpen then
        for zone, items in pairs(zones) do
          local zCollected, zTotal = countItems(items)
          local zKey = keyZone and keyZone(cat, exp, zone) or (cat .. ":" .. tostring(exp) .. ":" .. tostring(zone))
          local zoneOpen = searching or (HeaderCtrl and HeaderCtrl.IsOpen and HeaderCtrl:IsOpen("zone", zKey))

          addHeader(28, 36, zone, zCollected, zTotal, zoneOpen, "zone", { key = zKey })

          if zoneOpen then
            if viewMode == "Icon" then
              for _, it in ipairs(items) do
                if it.source and it.source.type == "vendor" and it.items then
                  local vCollected, vTotal = countItems(it.items, it)
                  local vendorKeyId = (it.source and it.source.id) or it.npcID or it.id or it.title or 0
                  local vKey = keyVendor and keyVendor(cat, exp, zone, vendorKeyId) or (tostring(vendorKeyId))

                  local vTitle = (ResolveVendorTitle and ResolveVendorTitle(it)) or it.title
if not vTitle or vTitle == "" then
  local vid = (it.source and it.source.id) or it.npcID or it.id
  vTitle = vid and ("Vendor #" .. tostring(vid)) or "Vendor"
end
addHeader(44, 30, "[Vendor] " .. vTitle, vCollected, vTotal, (it._uiOpen and true or false), "vendor", { key = vKey, vendor = it })
if it._uiOpen then
                    local vCols, vStartX = computeGrid(44)
                    local vCol = 0
                    for _, vit in ipairs(it.items) do
                      local rit = copyShallow and copyShallow(vit) or vit
                      rit.source = vit.source and (copyShallow and copyShallow(vit.source) or vit.source) or {}
                      rit._expansion = exp
                      rit._navZoneKey = zone
                      if AttachVendorCtx then AttachVendorCtx(rit, it) end
                      rit = ResolveAchievementDecor(rit)

                      if Passes and Passes(rit) then
                        entries[#entries + 1] = {
                          kind = "tile",
                          x = vStartX + vCol * (tileW + tileGap),
                          y = y,
                          w = tileW,
                          h = tileH,
                          indent = 44,
                          it = rit,
                          nav = it,
                        }
                        vCol = vCol + 1
                        if vCol >= vCols then
                          vCol = 0
                          y = y + tileH + tileGap
                        end
                      end
                    end
                    if vCol > 0 then y = y + tileH + tileGap end
                  end
                end
              end

              local cols, startX = computeGrid(28)
              local col = 0
              for _, it in ipairs(items) do
                if not (it.source and it.source.type == "vendor" and it.items) then
                  local rit = it
                  local st = rit and rit.source and rit.source.type
                  if st == "achievement" or st == "quest" or st == "pvp" then
                    rit = copyShallow and copyShallow(rit) or rit
                    if it.source then rit.source = copyShallow and copyShallow(it.source) or it.source end
                    rit._expansion = exp
                    rit._navZoneKey = zone
                    rit = ResolveAchievementDecor(rit)
                  end
                  if Passes and Passes(rit) then
                    addTile(44, rit, rit.vendor, col, startX)
                    col = col + 1
                    if col >= cols then
                      col = 0
                      y = y + tileH + tileGap
                    end
                  end
                end
              end
              if col > 0 then y = y + tileH + tileGap end
            else
              for _, it in ipairs(items) do
                if it.source and it.source.type == "vendor" and it.items then
                  local vCollected, vTotal = countItems(it.items, it)
                  local vendorKeyId = (it.source and it.source.id) or it.npcID or it.id or it.title or 0
                  local vKey = keyVendor and keyVendor(cat, exp, zone, vendorKeyId) or (tostring(vendorKeyId))

                  local vTitle = (ResolveVendorTitle and ResolveVendorTitle(it)) or it.title
if not vTitle or vTitle == "" then
  local vid = (it.source and it.source.id) or it.npcID or it.id
  vTitle = vid and ("Vendor #" .. tostring(vid)) or "Vendor"
end
addHeader(44, 30, "[Vendor] " .. vTitle, vCollected, vTotal, (it._uiOpen and true or false), "vendor", { key = vKey, vendor = it })

                  if it._uiOpen then
                    for _, vit in ipairs(it.items) do
                      local rit = copyShallow and copyShallow(vit) or vit
                      rit.source = vit.source and (copyShallow and copyShallow(vit.source) or vit.source) or {}
                      rit._expansion = exp
                      rit._navZoneKey = zone
                      if AttachVendorCtx then AttachVendorCtx(rit, it) end
                      rit = ResolveAchievementDecor(rit)
                      if Passes and Passes(rit) then addListItem(44, rit, it) end
                    end
                  end
                end
              end

              for _, it in ipairs(items) do
                if not (it.source and it.source.type == "vendor" and it.items) then
                  local rit = it
                  local st = rit and rit.source and rit.source.type
                  if st == "achievement" or st == "quest" or st == "pvp" then
                    rit = copyShallow and copyShallow(rit) or rit
                    if it.source then rit.source = copyShallow and copyShallow(it.source) or it.source end
                    rit._expansion = exp
                    rit._navZoneKey = zone
                    rit = ResolveAchievementDecor(rit)
                  end
                  if Passes and Passes(rit) then addListItem(28, rit, rit.vendor) end
                end
              end
            end
          end
        end
      end
    end

    self.totalHeight = y + PAD_BOTTOM
  end

  function f:UpdateVisible()
    if self._suspendRender or not self.entries then return end

    local db = DB and DB()
    local ui = (db and db.ui) or {}
    local viewMode = ui.viewMode or "Icon"
    local scrollY = sf:GetVerticalScroll() or 0

    if self._lastScrollY == scrollY and self._lastCount == #self.entries and self._lastViewMode == viewMode then
      return
    end
    self._lastScrollY, self._lastCount, self._lastViewMode = scrollY, #self.entries, viewMode

    self:ReleaseAll()

    local viewH = sf:GetHeight() or 0
    local top = scrollY - 200
    local bottom = scrollY + viewH + 200

    local entries = self.entries
    local startIdx = findFirstVisible(entries, top)

    for i = startIdx, #entries do
      local e = entries[i]
      if (e.y or 0) > bottom then break end
      local eBottom = (e.y or 0) + (e.h or 0)

      if eBottom >= top then
        local fr = Acquire(e.kind == "tile" and "tile" or e.kind == "header" and "header" or "list")
        fr._entry = e
        fr:ClearAllPoints()
        fr:SetPoint("TOPLEFT", Pixel(e.x), -Pixel(e.y))
        fr:SetSize(Pixel(e.w), Pixel(e.h))

        if e.kind == "header" then
          if RS and RS.Reset then RS:Reset(fr) end
          if fr.headerTex and fr.headerTex.SetVertexColor then fr.headerTex:SetVertexColor(1, 1, 1, 1) end
          if fr.headerTex and fr.headerTex.SetAlpha then fr.headerTex:SetAlpha(1) end
          if fr.headerHover and fr.headerHover.Hide then fr.headerHover:Hide() end
          fr:SetHeight(e.h)

          if fr and (not fr.headerAligned or fr.headerAlignedH ~= e.h) then
            fr.headerAligned = true
            fr.headerAlignedH = e.h
            local yOff = (e.h and e.h >= 44) and -9 or -6
            if fr.text then fr.text:ClearAllPoints(); fr.text:SetPoint("TOPLEFT", 14, yOff) end
            if fr.count then fr.count:ClearAllPoints(); fr.count:SetPoint("TOPRIGHT", -44, yOff) end
            if fr.check then fr.check:ClearAllPoints(); fr.check:SetPoint("TOPRIGHT", -14, yOff) end
          end

          if fr.text then fr.text:SetText(e.label or "") end
          if fr.count then fr.count:SetText((e.cur or 0) .. " / " .. (e.max or 0)) end

          local complete = (e.max and e.max > 0 and (e.cur or 0) >= (e.max or 0))
          if fr.check then if complete then fr.check:Show() else fr.check:Hide() end end

          if ProgressBar and e.max and e.max > 0 then
            if not fr.bar then
              fr.bar = ProgressBar:Create(fr, 140)
              fr.bar:SetPoint("BOTTOMLEFT", fr, "BOTTOMLEFT", 14, 5)
            end
            fr.bar:Show()
            fr.bar:SetProgress(e.cur or 0, e.max or 0)
          elseif fr.bar then
            fr.bar:Hide()
          end

          if not fr.headerScriptsBound then
            fr.headerScriptsBound = true
            fr:SetScript("OnClick", headerClick)
            fr:SetScript("OnMouseUp", nil)
          end
        elseif e.kind == "tile" then
          local it = ResolveAchievementDecor(e.it)
          local state = GetStateSafe and GetStateSafe(it)
          local w, h = e.w or tileW, e.h or tileH

          if fr.media then
            fr.media:SetHeight(floor(h * 0.52))
            if fr.icon then
              fr.icon:SetSize(iconSize, iconSize)
              local s = it and it.source
              local tex = s and s.icon
              fr.icon:SetTexture(tex or (it and it.decorID and GetDecorIcon and GetDecorIcon(it.decorID)) or "Interface\\Icons\\INV_Misc_QuestionMark")
            end

            if fr.div then
              fr.div:ClearAllPoints()
              fr.div:SetPoint("TOPLEFT", fr.media, "BOTTOMLEFT", 0, -6)
              fr.div:SetPoint("TOPRIGHT", fr.media, "BOTTOMRIGHT", 0, -6)
              fr.div:SetHeight(1)
              fr.div:Show()
            end

            local textArea = fr.textArea or fr

            local Ev = NS.Systems and NS.Systems.Events
            local timerText = ""
            if it and it._isEventTimed and (it._eventEndTime or it._eventEndTime == 0) and Ev and Ev.GetTimeText then
              timerText = Ev:GetTimeText(it._eventEndTime)
            end

            if fr.timer then
              fr.timer:ClearAllPoints()
              local anchorFrame = fr.media or textArea
              if fr.timer.GetParent and fr.timer:GetParent() ~= fr then fr.timer:SetParent(fr) end
              fr.timer:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT", -6, -6)
              if fr.timer.SetWidth then fr.timer:SetWidth(110) end
              if timerText ~= "" then
                fr.timer:SetText("|cffcfd6df" .. timerText .. "|r")
                fr.timer:Show()
              else
                fr.timer:Hide()
              end
            end

            if fr.label then
              fr.label:ClearAllPoints()
              fr.label:SetPoint("TOPLEFT", textArea, "TOPLEFT", 0, 0)
              fr.label:SetPoint("TOPRIGHT", textArea, "TOPRIGHT", 0, 0)

              local name = it and (it.title or (it.decorID and GetDecorName and GetDecorName(it.decorID)))
              if not name or name == "" then name = "Decor #" .. tostring(it and (it.decorID or it.itemID) or "?") end
              fr.label:SetText(name)
              if fr.label.SetWidth then fr.label:SetWidth(math.max(0, w - 20)) end

              if fr.note then
                local noteText = (it and it.source and type(it.source.note) == "string" and it.source.note ~= "" and it.source.note) or nil
                if noteText then
                  fr.note:ClearAllPoints()
                  fr.note:SetPoint("TOPLEFT", fr.label, "BOTTOMLEFT", 0, -2)
                  fr.note:SetPoint("TOPRIGHT", fr.label, "BOTTOMRIGHT", 0, -2)
                  fr.note:SetText("|cff9fb0c5" .. noteText .. "|r")
                  fr.note:Show()
                else
                  fr.note:SetText("")
                  fr.note:Hide()
                end
              end
            end

            if fr.titleDiv and fr.label then
              fr.titleDiv:ClearAllPoints()
              local anchor = (fr.note and fr.note:IsShown()) and fr.note or fr.label
              fr.titleDiv:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
              fr.titleDiv:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
              fr.titleDiv:SetHeight(1)
              fr.titleDiv:Show()
            end

            if fr.textBg and fr.div then
              fr.textBg:ClearAllPoints()
              fr.textBg:SetPoint("TOPLEFT", fr.div, "BOTTOMLEFT", -8, -2)
              fr.textBg:SetPoint("BOTTOMRIGHT", -8, 8)
              fr.textBg:Show()
            end

            if it and (not it.decorTypeBreadcrumb or it.decorTypeBreadcrumb == "") and D and D.ApplyDecorBreadcrumb then
              D.ApplyDecorBreadcrumb(it)
            end

            local metaText = it and (it.decorTypeBreadcrumb or "Uncategorized") or "Uncategorized"
            if fr.meta then
              fr.meta:ClearAllPoints()
              if metaText ~= "" and fr.label then
                local a = (fr.titleDiv and fr.titleDiv:IsShown()) and fr.titleDiv or fr.label
                fr.meta:SetPoint("TOPLEFT", a, "BOTTOMLEFT", 0, -6)
                fr.meta:SetPoint("TOPRIGHT", textArea, "TOPRIGHT", 0, -6)
                fr.meta:SetText("|cff9aa0a6" .. metaText .. "|r")
                if fr.meta.SetWidth then fr.meta:SetWidth(math.max(0, w - 12)) end
                fr.meta:Show()
              else
                fr.meta:Hide()
              end
            end
          end

          local req = GetRequirementLink and GetRequirementLink(it)
          local rep = GetRepRequirement and GetRepRequirement(it)
          local haveReq = (req and fr.req and fr.reqBtn)
          local haveRep = (rep and fr.rep)
          local anchor = (fr.meta and fr.meta:IsShown() and fr.meta) or fr.label

          if haveReq and BuildReqDisplay then
            fr.req:ClearAllPoints()
            fr.req:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
            fr.req:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -8)
            fr.req._req = req
            fr.req:SetText(BuildReqDisplay(req, false))
            fr.req:Show()

            fr.reqBtn:ClearAllPoints()
            fr.reqBtn:SetPoint("TOPLEFT", fr.req, "TOPLEFT", -2, 2)
            fr.reqBtn:SetPoint("BOTTOMRIGHT", fr.req, "BOTTOMRIGHT", 2, -2)
            fr.reqBtn:SetFrameStrata(fr:GetFrameStrata())
            fr.reqBtn:SetFrameLevel((fr:GetFrameLevel() or 1) + 10)
            fr.reqBtn:Show()
            bindReqButton(fr.reqBtn)
          else
            if fr.req then fr.req:Hide() end
            if fr.reqBtn then fr.reqBtn:Hide() end
          end

          if haveRep and BuildRepDisplay then
            fr.rep:ClearAllPoints()
            if haveReq and fr.req and fr.req:IsShown() then
              fr.rep:SetPoint("TOPLEFT", fr.req, "BOTTOMLEFT", 0, -6)
              fr.rep:SetPoint("TOPRIGHT", fr.req, "BOTTOMRIGHT", 0, -6)
            else
              fr.rep:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
              fr.rep:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -8)
            end
            fr.rep:SetText(BuildRepDisplay(rep, false))
            fr.rep:Show()
          else
            if fr.rep then fr.rep:Hide() end
          end

          if StatusIcon and StatusIcon.Attach then StatusIcon:Attach(fr, state, it) end
          applyFactionBadge(fr, it, 24)

          if Favorite and Favorite.Attach then
            local id = GetItemID and GetItemID(it)
            if fr._fav and fr._fav.SetItemID then
              fr._fav:SetItemID(id)
            else
              if fr._fav then fr._fav:Hide() end
              fr._fav = Favorite:Attach(fr, id, function() f:Render() end)
            end

            if fr._fav then
              fr._fav:ClearAllPoints()
              local favAnchor = (fr._kind == "list" and fr.iconBG) or (fr.media or fr)
              if fr._kind == "list" and fr.iconBG then
                fr._fav:SetPoint("TOPLEFT", favAnchor, "TOPLEFT", 2, -2)
                if fr._fav.SetSize then fr._fav:SetSize(18, 18) end
              else
                fr._fav:SetPoint("TOPLEFT", favAnchor, "TOPLEFT", 8, -8)
                if fr._fav.SetSize then fr._fav:SetSize(20, 20) end
              end
              if fr._fav.SetFrameLevel then fr._fav:SetFrameLevel((fr:GetFrameLevel() or 1) + 20) end
              if fr._fav.SetAlpha then fr._fav:SetAlpha(0.85) end
              setupFavoriteHover(fr._fav)
            end
          end

          if TT and TT.Attach then TT:Attach(fr, it) end

          local showDropsBadge = (ui.activeCategory == "Drops") or ((it and it.source and it.source.type) == "drop")
          if showDropsBadge and DropPanel and DropPanel.AttachBadge then
            DropPanel:AttachBadge(fr, it, "tile")
          elseif fr._dropBadge then
            fr._dropBadge:Hide()
          end

          fr:SetScript("OnMouseUp", function(_, btn)
            if IA and IA.HandleMouseUp then
              IA:HandleMouseUp(it, btn, e.nav)
            end
          end)
        else
          local it = ResolveAchievementDecor(e.it)
          local state = GetStateSafe and GetStateSafe(it)

          if fr.text then
            local title = it and (it.title or (it.decorID and GetDecorName and GetDecorName(it.decorID)))
            if not title or title == "" then title = "Decor #" .. tostring(it and (it.decorID or it.itemID) or "?") end
            fr.text:SetText(title)
            fr.text:SetWidth(math.max(0, (e.w or 0) - 96))
          end

          if fr.icon then
            local s = it and it.source
            local tex = s and s.icon
            fr.icon:SetTexture(tex or (it and it.decorID and GetDecorIcon and GetDecorIcon(it.decorID)) or "Interface\\Icons\\INV_Misc_QuestionMark")
          end

          local collected = (state and ((type(state) == "table" and state.collected) or state == true)) and true or false
          if fr.check then if collected then fr.check:Show() else fr.check:Hide() end end

          local req = GetRequirementLink and GetRequirementLink(it)
          local rep = GetRepRequirement and GetRepRequirement(it)
          local maxW = (e.w or 0) - 96

          if it and (not it.decorTypeBreadcrumb or it.decorTypeBreadcrumb == "") and D and D.ApplyDecorBreadcrumb then
            D.ApplyDecorBreadcrumb(it)
          end

          local metaText = it and (it.decorTypeBreadcrumb or it.decorType or it.subcategory or "Uncategorized") or "Uncategorized"
          if fr.meta then
            fr.meta:ClearAllPoints()
            if metaText ~= "" then
              fr.meta:SetPoint("TOPLEFT", fr.text, "BOTTOMLEFT", 0, -2)
              fr.meta:SetWidth(maxW)
              fr.meta:SetHeight(16)
              fr.meta:SetText("|cff9aa0a6" .. metaText .. "|r")
              fr.meta:Show()
            else
              fr.meta:Hide()
            end
          end

          local anchor = (fr.meta and fr.meta:IsShown()) and fr.meta or fr.text
          local haveReq = (req and fr.req and fr.reqBtn)
          local haveRep = (rep and fr.rep)

          if fr.div then
            if metaText ~= "" or haveReq or haveRep then
              fr.div:ClearAllPoints()
              fr.div:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
              fr.div:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
              fr.div:SetHeight(1)
              fr.div:Show()
            else
              fr.div:Hide()
            end
          end

          if haveReq and BuildReqDisplay then
            fr.req:Show()
            fr.req:ClearAllPoints()
            fr.req:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
            fr.req:SetWidth(maxW)
            fr.req:SetHeight(18)
            fr.req._req = req
            fr.req:SetText(BuildReqDisplay(req, false))

            fr.reqBtn:ClearAllPoints()
            fr.reqBtn:SetPoint("TOPLEFT", fr.req, "TOPLEFT", -2, 2)
            fr.reqBtn:SetPoint("BOTTOMRIGHT", fr.req, "BOTTOMRIGHT", 2, -2)
            fr.reqBtn:SetFrameStrata(fr:GetFrameStrata())
            fr.reqBtn:SetFrameLevel((fr:GetFrameLevel() or 1) + 10)
            fr.reqBtn:Show()
            bindReqButton(fr.reqBtn)
          else
            if fr.req then fr.req:Hide() end
            if fr.reqBtn then fr.reqBtn:Hide() end
          end

          if haveRep and BuildRepDisplay then
            fr.rep:Show()
            fr.rep:ClearAllPoints()
            if haveReq and fr.req and fr.req:IsShown() then
              fr.rep:SetPoint("TOPLEFT", fr.req, "BOTTOMLEFT", 0, -1)
            else
              fr.rep:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
            end
            fr.rep:SetWidth(maxW)
            fr.rep:SetHeight(18)
            fr.rep:SetText(BuildRepDisplay(rep, false))
          else
            if fr.rep then fr.rep:Hide() end
          end

          if StatusIcon and StatusIcon.Attach then StatusIcon:Attach(fr, state, it) end
          applyFactionBadge(fr, it, 16)

          if Favorite and Favorite.Attach then
            local id = GetItemID and GetItemID(it)
            if fr._fav and fr._fav.SetItemID then
              fr._fav:SetItemID(id)
            else
              if fr._fav then fr._fav:Hide() end
              fr._fav = Favorite:Attach(fr, id, function() f:Render() end)
            end
            if fr._fav and fr._fav.SetPoint then
              fr._fav:ClearAllPoints()
              fr._fav:SetPoint("TOPRIGHT", (fr.media or fr), "TOPRIGHT", -8, -8)
              if fr._fav.SetFrameLevel then fr._fav:SetFrameLevel((fr:GetFrameLevel() or 1) + 20) end
              if fr._fav.SetAlpha then fr._fav:SetAlpha(0.85) end
              setupFavoriteHover(fr._fav)
            end
          end

          if TT and TT.Attach then TT:Attach(fr, it) end

          local showDropsBadge = (ui.activeCategory == "Drops") or ((it and it.source and it.source.type) == "drop")
          if showDropsBadge and DropPanel and DropPanel.AttachBadge then
            DropPanel:AttachBadge(fr, it, "list")
          elseif fr._dropBadge then
            fr._dropBadge:Hide()
          end

          fr:SetScript("OnMouseUp", function(_, btn)
            if IA and IA.HandleMouseUp then
              IA:HandleMouseUp(it, btn, e.nav)
            end
          end)
        end
      end
    end

    content:SetHeight(self.totalHeight or 0)
  end

  function f:Render()
    if self._suspendRender then return end
    self._lastScrollY, self._lastCount, self._lastViewMode = nil, nil, nil
    self:RebuildEntries()
    content:SetHeight(self.totalHeight or 0)
    self:UpdateVisible()
  end

  f.scrollFrame = sf
  f.content = content
  return f
end

View.Create = function(self, parent) return Render:Create(parent) end
return Render