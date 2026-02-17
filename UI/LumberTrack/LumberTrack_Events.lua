local ADDON, NS = ...
NS.UI = NS.UI or {}

local Events = NS.UI.LumberTrackEvents or {}
NS.UI.LumberTrackEvents = Events

local Utils = NS.LT.Utils

local Render = NS.UI.LumberTrackRender
local oldCountsCache = {}
local lastCleanupTime = 0
local CLEANUP_INTERVAL = 60

local function ResetFarmingSession(ctx)
  local Farming = NS.UI.LumberTrackFarming
  local Rate = NS.UI.LumberTrackRate
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
    ctx.farmingPauseBtn.text:SetText("START")
    ctx.farmingPauseBtn.text:SetTextColor(0.30, 0.80, 0.40, 1)
  end

  if ctx.farmingStatsUpdate then
    ctx.farmingStatsUpdate()
  end
end

function Events:Attach(LumberTrack, ctx)
  local frame = ctx and ctx.frame
  if not frame or frame._lumberEventsAttached then return end
  frame._lumberEventsAttached = true

  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("BAG_UPDATE")
  frame:RegisterEvent("BAG_UPDATE_DELAYED")
  frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
  if C_EventUtils and C_EventUtils.IsEventValid then
    if C_EventUtils.IsEventValid("REAGENTBANK_UPDATE") then
      frame:RegisterEvent("REAGENTBANK_UPDATE")
    end
    if C_EventUtils.IsEventValid("PLAYERREAGENTBANKSLOTS_CHANGED") then
      frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
    end
    if C_EventUtils.IsEventValid("PLAYERBANKSLOTS_CHANGED") then
      frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    end
    if C_EventUtils.IsEventValid("MAIL_SEND_SUCCESS") then
      frame:RegisterEvent("MAIL_SEND_SUCCESS")
    end
    if C_EventUtils.IsEventValid("ITEM_REMOVED") then
      frame:RegisterEvent("ITEM_REMOVED")
    end
  else
    pcall(function() frame:RegisterEvent("REAGENTBANK_UPDATE") end)
    pcall(function() frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED") end)
    pcall(function() frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED") end)
    pcall(function() frame:RegisterEvent("MAIL_SEND_SUCCESS") end)
    pcall(function() frame:RegisterEvent("ITEM_REMOVED") end)
  end

  local pendingRecount = false
  local pendingRender = false

  local function QueueRecount()
    if pendingRecount then return end
    pendingRecount = true
    _G.C_Timer.After(0.3, function()
      pendingRecount = false
      if Render and Render.Recount then
        Render:Recount(ctx)
      end
      QueueRender()
    end)
  end

  function QueueRender(delay)
    if pendingRender then return end
    pendingRender = true
    _G.C_Timer.After(delay or 0.05, function()
      pendingRender = false
      if Render and Render.BuildList then Render:BuildList(ctx) end
      if Render and Render.LayoutRows then Render:LayoutRows(ctx) end
      if ctx.totalText then
        ctx.totalText:SetText("Lumber Total: " .. tostring(ctx.total or 0))
      end
    end)
  end

  local function QueueRefresh(delay)
    QueueRecount()
  end

  frame:SetScript("OnEvent", function(_, event, a1)
    if event == "PLAYER_ENTERING_WORLD" then
      ResetFarmingSession(ctx)
      QueueRecount()

    elseif event == "MAIL_SEND_SUCCESS"
        or event == "ITEM_REMOVED"
        or event == "REAGENTBANK_UPDATE"
        or event == "PLAYERREAGENTBANKSLOTS_CHANGED"
        or event == "PLAYERBANKSLOTS_CHANGED" then
      _G.C_Timer.After(0.4, function()
        if Render and Render.Recount then Render:Recount(ctx) end
        QueueRender()
      end)

    elseif event == "BAG_UPDATE_DELAYED" then
      QueueRecount()

    elseif event == "BAG_UPDATE" then
      local Rate = NS.UI.LumberTrackRate
      local Farming = NS.UI.LumberTrackFarming

      if Rate and not Rate.data then
        Rate.data = {}
      end

      Utils.Wipe(oldCountsCache)
      if ctx.counts then
        for itemID, count in pairs(ctx.counts) do
          oldCountsCache[itemID] = count
        end
      end

      local freshCounts = {}
      local freshTotal = 0
      if _G.C_Container and _G.C_Container.GetContainerNumSlots then
        for bag = 0, 5 do
          local slots = _G.C_Container.GetContainerNumSlots(bag) or 0
          for slot = 1, slots do
            local info = _G.C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID and ctx.lumberIDs and ctx.lumberIDs[info.itemID] then
              local c = tonumber(info.stackCount) or 1
              freshCounts[info.itemID] = (freshCounts[info.itemID] or 0) + c
              freshTotal = freshTotal + c
            end
          end
        end
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
      if Rate and Rate.data then
        for itemID, newCount in pairs(freshCounts) do
          local oldCount = oldCountsCache[itemID] or 0
          if newCount > oldCount then
            local gained = newCount - oldCount
            if gained > gainAmount then
              hasGain = true
              gainItemID = itemID
              gainAmount = gained
            end
          end
        end
      end

      if hasGain and gainItemID and ctx.farming and ctx.farming.active then
        local currentPrimaryLumber = ctx.farming.primaryLumberID
        if currentPrimaryLumber and gainItemID ~= currentPrimaryLumber then
          ResetFarmingSession(ctx)
          if Rate then
            for itemID, count in pairs(ctx.counts or {}) do
              if not Rate.data[itemID] then
                Rate:InitItem(itemID)
              end
              if itemID == gainItemID then
                Rate.data[itemID].lastCount = count - gainAmount
              else
                Rate.data[itemID].lastCount = count
              end
            end
          end
          if Farming and ctx.frame and ctx.frame._mode == "farming" then
            Farming:Start(ctx, gainAmount, gainItemID)
          end
        end
      end

      local db = ctx.GetDB and ctx.GetDB()
      if db and db.autoStartFarming and hasGain then
        local FarmingStats = NS.UI.LumberTrackFarmingStats
        if FarmingStats and FarmingStats.Show and not db.userClosedFarmingStats then
          FarmingStats:Show()
        end
        if Farming and ctx.farming and not ctx.farming.active then
          Farming:Start(ctx, gainAmount, gainItemID)
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
      elseif Rate and Rate.data then
        for itemID, newCount in pairs(freshCounts) do
          if not Rate.data[itemID] then
            Rate:InitItem(itemID)
          end
          Rate.data[itemID].lastCount = newCount
        end
      end

      local now = Utils.GetTime()
      if now - lastCleanupTime > CLEANUP_INTERVAL then
        lastCleanupTime = now
        if Rate and Rate.PeriodicCleanup then Rate:PeriodicCleanup() end
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
            for i = 1, math.min(#metaToRemove, 20) do ctx.meta[metaToRemove[i]] = nil end
          end
        end
      end

    elseif event == "GET_ITEM_INFO_RECEIVED" then
      if Render and Render.OnItemInfo then
        Render:OnItemInfo(ctx, a1)
      end
    end
  end)
end

return Events
