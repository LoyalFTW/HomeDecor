local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}

local Events = NS.UI.GatherTrackEvents or {}
NS.UI.GatherTrackEvents = Events

local Utils = NS.GT.Utils

local Render = NS.UI.GatherTrackRender
local oldCountsCache = {}
local lastCleanupTime = 0
local CLEANUP_INTERVAL = 60

local function ResetFarmingSession(ctx)
  local Farming = NS.UI.GatherTrackFarming
  local Rate = NS.UI.GatherTrackRate
  if not ctx then return end

  if Farming then
    Farming:Stop(ctx)
  end

  if ctx.farming then
    ctx.farming.active = false
    ctx.farming.startTime = 0
    ctx.farming.startTotal = 0
    ctx.farming.totalGained = 0
    ctx.farming.perSecond = 0
    ctx.farming.perMinute = 0
    ctx.farming.efficiency = 0
    ctx.farming.primaryLumberID = nil
    ctx.farming.paused = false
    ctx.farming.pauseTime = 0
    ctx.farming.totalPausedTime = 0
    ctx.farming.topItems = {}
  end

  if Rate then
    Rate:Clear()
  end

  if ctx.farmingPauseBtn then
    ctx.farmingPauseBtn.text:SetText(L["LUMBER_BTN_START"])
    ctx.farmingPauseBtn.text:SetTextColor(0.30, 0.80, 0.40, 1)
  end

  if ctx.farmingStatsUpdate then
    ctx.farmingStatsUpdate()
  end
end

function Events:Attach(GatherTrack, ctx)
  local frame = ctx and ctx.frame
  if not frame or frame._lumberEventsAttached then return end
  frame._lumberEventsAttached = true

  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("BAG_UPDATE")
  frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

  local safeEvents = {
    "BAG_UPDATE_DELAYED",
    "PLAYERBANKSLOTS_CHANGED",
    "PLAYERREAGENTBANKSLOTS_CHANGED",
    "REAGENTBANK_UPDATE",
    "MAIL_SEND_SUCCESS",
    "ITEM_REMOVED",
    "ACCOUNT_BANK_SLOTS_CHANGED",
  }
  for _, evt in ipairs(safeEvents) do
    if C_EventUtils and C_EventUtils.IsEventValid and C_EventUtils.IsEventValid(evt) then
      frame:RegisterEvent(evt)
    else
      pcall(function() frame:RegisterEvent(evt) end)
    end
  end

  local pending = false
  local function QueueRefresh(delay)
    if pending then return end
    pending = true
    _G.C_Timer.After(delay or 0.05, function()
      pending = false
      if Render and Render.Refresh then
        Render:Refresh(ctx)
      end
    end)
  end

  local pendingRecount = false
  local function QueueRecount(delay)
    if pendingRecount then return end
    pendingRecount = true
    _G.C_Timer.After(delay or 0.4, function()
      pendingRecount = false
      if Render and Render.Refresh then
        Render:Refresh(ctx)
      end
    end)
  end

  local suppressFarming = false
  local suppressUntil = 0
  local function SetSuppressed(duration)
    suppressFarming = true
    suppressUntil = GetTime() + (duration or 5)
  end
  local function IsSuppressed()
    if suppressFarming then
      if GetTime() < suppressUntil then
        return true
      end
      suppressFarming = false
    end
    return false
  end

  frame:RegisterEvent("BANKFRAME_OPENED")
  frame:RegisterEvent("BANKFRAME_CLOSED")
  frame:RegisterEvent("MAIL_SHOW")
  frame:RegisterEvent("MAIL_CLOSED")

  frame:SetScript("OnEvent", function(_, event, a1)
    if event == "PLAYER_ENTERING_WORLD" then
      ResetFarmingSession(ctx)
      local db = Utils.GetDB()
      if db and db.hideInInstance then
        local inInstance = IsInInstance and IsInInstance()
        local LumberList = NS.UI.GatherTrackList
        if inInstance then
          if LumberList and LumberList.frame then LumberList.frame:Hide() end
        else
          if LumberList and LumberList.frame and db.lumberListOpen then LumberList.frame:Show() end
        end
      end
      QueueRefresh(0.25)

    elseif event == "BANKFRAME_OPENED" then
      local AccountWide = NS.UI.GatherTrackAccountWide
      if AccountWide and AccountWide.SetWarbandDataLoaded then
        AccountWide:SetWarbandDataLoaded()
      end
      SetSuppressed(60)

    elseif event == "BANKFRAME_CLOSED" then
      SetSuppressed(5)

    elseif event == "MAIL_SHOW" then
      SetSuppressed(60)

    elseif event == "MAIL_CLOSED" then
      SetSuppressed(5)

    elseif event == "BAG_UPDATE_DELAYED"
        or event == "PLAYERBANKSLOTS_CHANGED"
        or event == "PLAYERREAGENTBANKSLOTS_CHANGED"
        or event == "REAGENTBANK_UPDATE"
        or event == "MAIL_SEND_SUCCESS"
        or event == "ITEM_REMOVED"
        or event == "ACCOUNT_BANK_SLOTS_CHANGED" then
      if event == "ACCOUNT_BANK_SLOTS_CHANGED" then
        SetSuppressed(5)
        local AccountWide = NS.UI.GatherTrackAccountWide
        if AccountWide and AccountWide.SetWarbandDataLoaded then
          AccountWide:SetWarbandDataLoaded()
        end
      end
      QueueRecount()

    elseif event == "BAG_UPDATE" then
      local Rate = NS.UI.GatherTrackRate
      local Farming = NS.UI.GatherTrackFarming
      local GatherFarming = NS.UI and NS.UI.GatherTrackMiniFarming
      local GatherFarmingPanels = NS.UI and NS.UI.GatherTrackMiniFarmingPanels

      if Rate and not Rate.data then
        Rate.data = {}
      end

      Utils.Wipe(oldCountsCache)
      if ctx.counts then
        for itemID, count in pairs(ctx.counts) do
          oldCountsCache[itemID] = count
        end
      end

      if Render and Render.Recount then
        Render:Recount(ctx)
      end

      if Rate and ctx.counts then
        for itemID, count in pairs(ctx.counts) do
          if not Rate.data[itemID] then
            Rate:InitItem(itemID)
            Rate.data[itemID].lastCount = oldCountsCache[itemID] or count
          end
        end
      end

      local hasGain, gainItemID, gainAmount = false, nil, 0
      local gainedItems = {}
      if Rate and Rate.data and ctx.counts then
        for itemID, newCount in pairs(ctx.counts) do
          local data = Rate.data[itemID]
          if data and data.lastCount and newCount > data.lastCount then
            local gained = newCount - data.lastCount
            gainedItems[#gainedItems + 1] = {
              itemID = itemID,
              amount = gained,
            }
            if gained > gainAmount then
              hasGain = true
              gainItemID = itemID
              gainAmount = gained
            end
          end
        end
      end

      local primaryGainKind = nil
      for _, gain in ipairs(gainedItems) do
        local itemID = gain.itemID
        local amount = gain.amount
        local meta = ctx and ctx.meta and ctx.meta[itemID]
        if itemID and amount and amount > 0 and meta and Utils and Utils.GetTrackedGatheringKind then
          local gainKind = Utils.GetTrackedGatheringKind(meta.name, meta.classID, meta.subclassID)
          if gainKind then
            ctx.recentByKind = ctx.recentByKind or {}
            ctx.recentByKind[gainKind] = itemID
            gain.kind = gainKind
            if itemID == gainItemID then
              primaryGainKind = gainKind
            end
          end
        end
      end

      local db = ctx.GetDB and ctx.GetDB()
      if db and db.autoStartFarming and hasGain and primaryGainKind and not IsSuppressed() then
        local isEnabled = Utils and Utils.IsGatheringKindEnabled and Utils.IsGatheringKindEnabled(primaryGainKind, ctx)
        if isEnabled then
          if GatherFarming and GatherFarming.EnsureSession and GatherFarming.Start then
            local session = GatherFarming:EnsureSession(primaryGainKind)
            if session then
              if not session.active then
                GatherFarming:Start(primaryGainKind, ctx)
              elseif session.paused and GatherFarming.TogglePause then
                GatherFarming:TogglePause(primaryGainKind)
              end
            end
          end

          if GatherFarmingPanels and GatherFarmingPanels.Show then
            GatherFarmingPanels:Show(primaryGainKind)
          end
        end
      end

      if GatherFarming and GatherFarming.RecordGain then
        for _, gain in ipairs(gainedItems) do
          local gainKind = gain.kind
          if gainKind and Utils and Utils.IsGatheringKindEnabled and Utils.IsGatheringKindEnabled(gainKind, ctx) then
            GatherFarming:RecordGain(gainKind, gain.itemID, gain.amount, ctx)
          end
        end
      end

      if Rate and Rate.CheckGains and ctx.counts and ctx.farming and ctx.farming.active then
        if not ctx.farming.paused then
          Rate:CheckGains(ctx.counts)
          if not ctx.farming.primaryLumberID and hasGain and gainItemID then
            ctx.farming.primaryLumberID = gainItemID
            if ctx.counts[gainItemID] then
              local currentItemCount = tonumber(ctx.counts[gainItemID]) or 0
              ctx.farming.startTotal = currentItemCount - gainAmount
              ctx.farming.totalGained = gainAmount
            end
          end
        else
          if hasGain and Farming then
            Farming:Resume(ctx)
            Rate:CheckGains(ctx.counts)
          else
            for itemID, newCount in pairs(ctx.counts) do
              if Rate.data and Rate.data[itemID] then
                Rate.data[itemID].lastCount = newCount
              end
            end
          end
        end
        if Farming and Farming.Update then
          Farming:Update(ctx)
        end
        if ctx.farmingStatsUpdate then
          ctx.farmingStatsUpdate()
        end
      elseif Rate and Rate.data and ctx.counts then
        for itemID, newCount in pairs(ctx.counts) do
          if not Rate.data[itemID] then
            Rate:InitItem(itemID)
          end
          Rate.data[itemID].lastCount = newCount
        end
      end

      if Render then
        if Render.BuildList then
          Render:BuildList(ctx)
        end
        if Render.LayoutRows then
          Render:LayoutRows(ctx)
        end
      end

      if ctx.totalText then
        ctx.totalText:SetText(L["LUMBER_TOTAL"] .. tostring(ctx.total or 0))
      end

      if ctx.bagCounter then
        local Counter = NS.UI.GatherTrackCounter
        if Counter and Counter.SetCount then
          Counter:SetCount(ctx.bagCounter, ctx.total or 0)
        end
      end

      local now = Utils.GetTime()
      if now - lastCleanupTime > CLEANUP_INTERVAL then
        lastCleanupTime = now
        if Rate and Rate.PeriodicCleanup then
          Rate:PeriodicCleanup()
        end
        if ctx.meta and ctx.counts then
          local metaToRemove = {}
          for itemID in pairs(ctx.meta) do
            local inBags = ctx.counts[itemID] and ctx.counts[itemID] > 0
            local isKnownLumber = ctx.lumberIDs and ctx.lumberIDs[itemID]
            if not inBags and not isKnownLumber then
              metaToRemove[#metaToRemove + 1] = itemID
            end
          end
          if #metaToRemove > 50 then
            for i = 1, math.min(#metaToRemove, 20) do
              ctx.meta[metaToRemove[i]] = nil
            end
          end
        end
      end
      QueueRefresh(0.05)

    elseif event == "GET_ITEM_INFO_RECEIVED" then
      if Render and Render.OnItemInfo then
        Render:OnItemInfo(ctx, a1)
      end
    end
  end)
end

return Events
