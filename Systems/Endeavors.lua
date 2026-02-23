local ADDON, NS = ...
NS.Systems = NS.Systems or {}
local Endeavors = {}
NS.Systems.Endeavors = Endeavors
local COUPON_CURRENCY_ID       = 3363
local SCALE_CHANGE_CUTOFF      = 1769620000
local PRE_CAP_XP               = 1000
local CUMULATIVE_CAP_XP        = 2250
local FLOOR_COMPLETIONS        = 5
local REFRESH_DEBOUNCE_SEC     = 0.35
local FETCH_RETRY_DELAYS       = { 10, 30, 90, 300 }
local NON_REPEATABLE_TASKS = {
    ["Kill a Profession Rare"]                    = true,
    ["Home: Complete Weekly Neighborhood Quests"] = true,
    ["Champion a Faction Envoy"]                  = true,
}
local state = {
    houseList            = {},
    selectedHouseIndex   = 1,
    currentHouseGUID     = nil,
    houseListLoaded      = false,
    endeavorInfo         = {},
    tasks                = {},
    activityLog          = nil,
    activityLogLoaded    = false,
    activityLogTimestamp = nil,
    activityLogStale     = false,
    xpContexts           = {},
    activeGUID           = nil,
    fetchStatus          = { state = "pending", attempt = 0 },
    lastFetchTime        = 0,
    lastRequestTime      = 0,
    lastManualSelectTime = 0,
    lastKnownActiveGUID  = nil,
    pendingTaskCompletions   = {},
    retryTimer               = nil,
    refreshTimer             = nil,
    saveProgressTimer        = nil,
    couponRetryScheduled     = false,
    taskCompletionRetryGen   = 0,
}
local function DB()
    HomeDecorDB = HomeDecorDB or {}
    HomeDecorDB.endeavors = HomeDecorDB.endeavors or {}
    return HomeDecorDB.endeavors
end
local function DBScales()
    local db = DB()
    db.neighborhoodScales = db.neighborhoodScales or {}
    return db.neighborhoodScales
end
local function DBMyChars()
    local db = DB()
    db.myCharacters = db.myCharacters or {}
    return db.myCharacters
end
local function DBCouponGains()
    local db = DB()
    db.couponGains = db.couponGains or {}
    return db.couponGains
end
local function DBTaskCoupons()
    local db = DB()
    db.taskActualCoupons = db.taskActualCoupons or {}
    return db.taskActualCoupons
end
local function SaveScale(guid, scale)
    if not guid or not scale or scale <= 0 then return end
    DBScales()[guid] = { scale = scale, timestamp = time() }
end
local function LoadScale(guid)
    if not guid then return nil end
    local savedEntry = DBScales()[guid]
    return savedEntry and savedEntry.scale or nil
end
local function GetOrCreateContext(guid)
    if not guid then return nil end
    if not state.xpContexts[guid] then
        state.xpContexts[guid] = {
            scale           = LoadScale(guid) or 1,
            houseXP         = 0,
            playerContrib   = 0,
            accountCounts   = {},
            playerCounts    = {},
            lastKnownAmount = {},
            taskRules       = {},
        }
    end
    return state.xpContexts[guid]
end
local function IngestLiveTasks(guid, apiTasks, playerTotalContrib)
    if not guid or not apiTasks then return end
    local ctx = GetOrCreateContext(guid)
    if playerTotalContrib and playerTotalContrib > 0 then
        local pointSum = 0
        for _, task in ipairs(apiTasks) do
            pointSum = pointSum + (task.progressContributionAmount or 0)
        end
        if pointSum > 0 then
            local derivedScale = pointSum / playerTotalContrib
            if derivedScale > 0 and derivedScale < 1000 then
                ctx.scale = derivedScale
                SaveScale(guid, derivedScale)
            end
        end
    end
end
local function IngestActivityLog(guid, logData, myChars, currentPlayer)
    if not guid or not logData or not logData.taskActivity then return end
    local ctx = GetOrCreateContext(guid)
    local log = logData.taskActivity
    ctx.lastKnownAmount = {}
    for i = #log, 1, -1 do
        local entry = log[i]
        local amount = entry.amount or 0
        local completionTime = entry.completionTime or 0
        if amount > 0 and completionTime >= SCALE_CHANGE_CUTOFF then
            if not ctx.lastKnownAmount[entry.taskName] then
                ctx.lastKnownAmount[entry.taskName] = amount
            end
        end
    end
    local completionCount = {}
    local mostRecentByTask = {}
    for i = 1, #log do
        local entry = log[i]
        local taskName = entry.taskName
        if taskName then
            completionCount[taskName] = (completionCount[taskName] or 0) + 1
            local amount = entry.amount or 0
            local completionTime = entry.completionTime or 0
            if amount > 0 then
                local previous = mostRecentByTask[taskName]
                if not previous or completionTime > previous.time then
                    mostRecentByTask[taskName] = { amount = amount, time = completionTime }
                end
            end
        end
    end
    ctx.taskRules = {}
    for taskName, count in pairs(completionCount) do
        if count >= FLOOR_COMPLETIONS then
            local mostRecent = mostRecentByTask[taskName]
            if mostRecent then
                ctx.taskRules[taskName] = { atFloor = true, floorAmount = mostRecent.amount }
            end
        end
    end
    ctx.accountCounts = {}
    ctx.playerCounts  = {}
    for i = 1, #log do
        local entry = log[i]
        local taskID = entry.taskID
        local playerName = entry.playerName
        if taskID and playerName then
            if playerName == currentPlayer then
                ctx.playerCounts[taskID] = (ctx.playerCounts[taskID] or 0) + 1
            end
            if myChars[playerName] then
                ctx.accountCounts[taskID] = (ctx.accountCounts[taskID] or 0) + 1
            end
        end
    end
    local scale = ctx.scale
    if scale and scale > 0 then
        local preCapTotal, postCapTotal = 0, 0
        for i = 1, #log do
            local entry = log[i]
            if myChars[entry.playerName] then
                local taskName = entry.taskName
                local completionTime = entry.completionTime or 0
                if not NON_REPEATABLE_TASKS[taskName] then
                    local contribution = entry.amount or 0
                    if contribution == 0 and completionTime >= SCALE_CHANGE_CUTOFF and ctx.lastKnownAmount[taskName] then
                        contribution = ctx.lastKnownAmount[taskName]
                    end
                    if contribution > 0 then
                        local xp = contribution / scale
                        if completionTime < SCALE_CHANGE_CUTOFF then
                            preCapTotal = preCapTotal + xp
                        else
                            postCapTotal = postCapTotal + xp
                        end
                    end
                end
            end
        end
        local cappedPre  = math.min(preCapTotal, PRE_CAP_XP)
        local cappedPost = math.min(postCapTotal, CUMULATIVE_CAP_XP - cappedPre)
        ctx.houseXP = cappedPre + cappedPost
    end
    local playerTotal = 0
    for i = 1, #log do
        local entry = log[i]
        if entry.playerName == currentPlayer then
            local contribution = entry.amount or 0
            if contribution == 0 and ctx.lastKnownAmount[entry.taskName] then
                contribution = ctx.lastKnownAmount[entry.taskName]
            end
            playerTotal = playerTotal + contribution
        end
    end
    ctx.playerContrib = playerTotal
end
local function CalculateNextContribution(taskName, accountCompletions, guid)
    if not guid then return 0 end
    local ctx = GetOrCreateContext(guid)
    if not ctx then return 0 end
    local rules = ctx.taskRules and ctx.taskRules[taskName]
    if rules and rules.atFloor then
        return rules.floorAmount or 0
    end
    local lastKnown = ctx.lastKnownAmount and ctx.lastKnownAmount[taskName] or 0
    if lastKnown > 0 then
        local completions = math.min(accountCompletions or 0, FLOOR_COMPLETIONS)
        local decayFactor = math.max(0.5, 1 - (completions * 0.1))
        return math.floor(lastKnown * decayFactor + 0.5)
    end
    return 0
end
local function GetTaskRankings(tasks, guid)
    if not tasks or not guid then return {} end
    local ctx = GetOrCreateContext(guid)
    local rankedList = {}
    for _, task in ipairs(tasks) do
        if not task.completed and task.name then
            local completions = ctx.accountCounts and ctx.accountCounts[task.id] or 0
            local nextXP = CalculateNextContribution(task.name, completions, guid)
            table.insert(rankedList, { id = task.id, name = task.name, nextXP = nextXP })
        end
    end
    table.sort(rankedList, function(a, b) return a.nextXP > b.nextXP end)
    local rankByID = {}
    for i, entry in ipairs(rankedList) do
        rankByID[entry.id] = i
    end
    return rankByID
end
local function GetXPCapStatus(guid)
    if not guid then return nil end
    local ctx = GetOrCreateContext(guid)
    local currentXP = ctx.houseXP or 0
    local isPreCapped  = currentXP >= PRE_CAP_XP and currentXP < CUMULATIVE_CAP_XP
    local isPostCapped = currentXP >= CUMULATIVE_CAP_XP
    return {
        currentXP   = currentXP,
        preCap      = PRE_CAP_XP,
        postCap     = CUMULATIVE_CAP_XP,
        isPreCapped  = isPreCapped,
        isPostCapped = isPostCapped,
    }
end
local function GetTaskCouponReward(task)
    if not task.rewardQuestID or task.rewardQuestID == 0 then return 0, 0 end
    local baseReward = 0
    if C_QuestLog and C_QuestLog.GetQuestRewardCurrencies then
        local rewards = C_QuestLog.GetQuestRewardCurrencies(task.rewardQuestID)
        if rewards and #rewards > 0 then
            for _, reward in ipairs(rewards) do
                if reward.currencyID == COUPON_CURRENCY_ID then
                    baseReward = reward.totalRewardAmount or 0
                    break
                end
            end
        else
            return nil, nil
        end
    end
    local history = DBTaskCoupons()[task.taskName or ""]
    local actualReward = history and #history > 0 and history[#history].amount
    return actualReward or baseReward, baseReward
end
local function GetTaskProgress(task)
    if task.requirementsList and #task.requirementsList > 0 then
        local req = task.requirementsList[1]
        if req and req.requirementText then
            local current = req.requirementText:match("(%d+)%s*/%s*%d+")
            if current then return tonumber(current) or 0 end
        end
    end
    return task.completed and 1 or 0
end
local function GetTaskMax(task)
    if task.requirementsList and #task.requirementsList > 0 then
        local req = task.requirementsList[1]
        if req and req.requirementText then
            local maxVal = req.requirementText:match("%d+%s*/%s*(%d+)")
            if maxVal then return tonumber(maxVal) or 1 end
        end
    end
    return 1
end
local function ProcessInitiativeInfo(info)
    if not info then return end
    local daysRemaining = 0
    if info.duration and info.duration > 0 then
        daysRemaining = math.ceil(info.duration / 86400)
    end
    local milestones = {}
    local maxProgress = 0
    if info.milestones then
        for _, milestone in ipairs(info.milestones) do
            local threshold = milestone.requiredContributionAmount or 0
            maxProgress = math.max(maxProgress, threshold)
            table.insert(milestones, {
                threshold  = threshold,
                reached    = (info.currentProgress or 0) >= threshold,
                rewards    = milestone.rewards,
                orderIndex = milestone.milestoneOrderIndex or 0,
            })
        end
    end
    if maxProgress == 0 then maxProgress = info.progressRequired or 100 end
    state.endeavorInfo = {
        seasonName         = info.title or "Unknown Endeavor",
        description        = info.description,
        initiativeID       = info.initiativeID,
        daysRemaining      = daysRemaining,
        currentProgress    = info.currentProgress or 0,
        maxProgress        = maxProgress,
        milestones         = milestones,
        playerTotalContrib = info.playerTotalContribution or 0,
        neighborhoodGUID   = info.neighborhoodGUID,
    }
    local tasks = {}
    local hasMissingCoupons = false
    if info.tasks then
        for _, apiTask in ipairs(info.tasks) do
            if not apiTask.supersedes or apiTask.supersedes == 0 then
                local isRepeatable = apiTask.taskType and apiTask.taskType > 0
                local couponReward, couponBase = GetTaskCouponReward(apiTask)
                if couponReward == nil then
                    hasMissingCoupons = true
                    couponReward, couponBase = 0, 0
                end
                local ctx = state.currentHouseGUID and GetOrCreateContext(state.currentHouseGUID)
                local accountCount = ctx and ctx.accountCounts and ctx.accountCounts[apiTask.ID] or 0
                local playerCount  = ctx and ctx.playerCounts  and ctx.playerCounts[apiTask.ID]  or 0
                table.insert(tasks, {
                    id                 = apiTask.ID,
                    name               = apiTask.taskName,
                    description        = apiTask.description or "",
                    points             = apiTask.progressContributionAmount or 0,
                    completed          = apiTask.completed or false,
                    current            = GetTaskProgress(apiTask),
                    max                = GetTaskMax(apiTask),
                    isRepeatable       = isRepeatable,
                    tracked            = apiTask.tracked or false,
                    sortOrder          = apiTask.sortOrder or 999,
                    rewardQuestID      = apiTask.rewardQuestID,
                    timesCompleted     = apiTask.timesCompleted or 0,
                    couponReward       = couponReward,
                    couponBase         = couponBase,
                    accountCompletions = accountCount,
                    playerCompletions  = playerCount,
                })
            end
        end
        table.sort(tasks, function(a, b)
            if a.completed ~= b.completed then return not a.completed end
            return (a.sortOrder or 999) < (b.sortOrder or 999)
        end)
    end
    state.tasks = tasks
    if state.currentHouseGUID then
        IngestLiveTasks(state.currentHouseGUID, info.tasks or {}, info.playerTotalContribution or 0)
    end
    if hasMissingCoupons and not state.couponRetryScheduled then
        state.couponRetryScheduled = true
        C_Timer.After(2, function()
            state.couponRetryScheduled = false
            Endeavors:FetchData()
        end)
    end
    if Endeavors.OnDataReady then Endeavors.OnDataReady() end
end
function Endeavors:ValidateAPI()
    if not C_NeighborhoodInitiative then return "api_unavailable" end
    if not C_NeighborhoodInitiative.IsInitiativeEnabled() then return "disabled" end
    if not C_NeighborhoodInitiative.PlayerMeetsRequiredLevel() then return "low_level" end
    if not C_NeighborhoodInitiative.PlayerHasInitiativeAccess() then return "no_access" end
    return "ok"
end
function Endeavors:FetchData(attempt)
    attempt = attempt or 0
    local now = GetTime()
    if attempt == 0 and (now - state.lastFetchTime) < 1 then return end
    state.lastFetchTime = now
    if state.retryTimer then state.retryTimer:Cancel(); state.retryTimer = nil end
    state.fetchStatus.state   = attempt > 0 and "retrying" or "fetching"
    state.fetchStatus.attempt = attempt
    local apiStatus = self:ValidateAPI()
    if apiStatus ~= "ok" then return end
    local skipRequest = (now - state.lastRequestTime) < 2
    if not skipRequest then
        state.lastRequestTime = now
        C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
    end
    local info = C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo()
    if not info or not info.isLoaded then
        if state.houseListLoaded and attempt < #FETCH_RETRY_DELAYS then
            local delay = FETCH_RETRY_DELAYS[attempt + 1] or 30
            state.retryTimer = C_Timer.NewTimer(delay, function()
                state.retryTimer = nil
                C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
                self:RequestActivityLog()
                self:FetchData(attempt + 1)
            end)
        end
        return
    end
    state.fetchStatus.state = "loaded"
    local activeGUID = C_NeighborhoodInitiative.GetActiveNeighborhood and
                       C_NeighborhoodInitiative.GetActiveNeighborhood()
    if activeGUID and activeGUID ~= state.lastKnownActiveGUID then
        state.lastKnownActiveGUID = activeGUID
        if Endeavors.OnActiveNeighborhoodChanged then
            Endeavors.OnActiveNeighborhoodChanged()
        end
    end
    local dataGUID = info.neighborhoodGUID
    if dataGUID and state.houseList then
        local selectedGUID = state.houseList[state.selectedHouseIndex]
                             and state.houseList[state.selectedHouseIndex].neighborhoodGUID
        if dataGUID ~= selectedGUID then
            for i, house in ipairs(state.houseList) do
                if house.neighborhoodGUID == dataGUID then
                    state.selectedHouseIndex = i
                    state.currentHouseGUID   = house.houseGUID
                    DB().selectedHouseGUID   = house.houseGUID
                    break
                end
            end
        end
    end
    if dataGUID and activeGUID and dataGUID ~= activeGUID then
        state.tasks        = {}
        state.endeavorInfo = { seasonName = "Not Active Endeavor", daysRemaining = 0,
                               currentProgress = 0, maxProgress = 0, milestones = {} }
        state.activityLogLoaded = false
        if Endeavors.OnDataReady then Endeavors.OnDataReady() end
        return
    end
    if info.initiativeID == 0 then
        state.tasks        = {}
        state.endeavorInfo = { seasonName = "No Active Endeavor", daysRemaining = 0,
                               currentProgress = 0, maxProgress = 0, milestones = {} }
        if Endeavors.OnDataReady then Endeavors.OnDataReady() end
        return
    end
    ProcessInitiativeInfo(info)
end
function Endeavors:RequestActivityLog()
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RequestInitiativeActivityLog then
        C_NeighborhoodInitiative.RequestInitiativeActivityLog()
    end
end
function Endeavors:RefreshActivityLog()
    if not C_NeighborhoodInitiative then return end
    if not C_NeighborhoodInitiative.GetInitiativeActivityLogInfo then return end
    local activeGUID  = C_NeighborhoodInitiative.GetActiveNeighborhood and
                        C_NeighborhoodInitiative.GetActiveNeighborhood()
    local viewingGUID = self:GetViewingNeighborhoodGUID()
    if activeGUID and viewingGUID and activeGUID ~= viewingGUID then return end
    state.activityLog          = C_NeighborhoodInitiative.GetInitiativeActivityLogInfo()
    state.activityLogLoaded    = true
    state.activityLogTimestamp = time()
    state.activityLogStale     = false
    if state.currentHouseGUID and state.activityLog then
        local myChars = DBMyChars()
        local player  = UnitName("player") or ""
        IngestActivityLog(state.currentHouseGUID, state.activityLog, myChars, player)
        local ctx = GetOrCreateContext(state.currentHouseGUID)
        for _, task in ipairs(state.tasks) do
            if task.id then
                task.accountCompletions = ctx.accountCounts[task.id] or 0
                task.playerCompletions  = ctx.playerCounts[task.id]  or 0
            end
        end
    end
    if Endeavors.OnActivityLogReady then Endeavors.OnActivityLogReady() end
end
function Endeavors:QueueRefresh()
    if state.refreshTimer then state.refreshTimer:Cancel() end
    state.refreshTimer = C_Timer.NewTimer(REFRESH_DEBOUNCE_SEC, function()
        state.refreshTimer = nil
        self:FetchData()
    end)
end
function Endeavors:GetViewingNeighborhoodGUID()
    local house = state.houseList[state.selectedHouseIndex]
    return house and house.neighborhoodGUID or nil
end
function Endeavors:IsViewingActiveNeighborhood()
    if not C_NeighborhoodInitiative then return false end
    local activeGUID  = C_NeighborhoodInitiative.GetActiveNeighborhood
                        and C_NeighborhoodInitiative.GetActiveNeighborhood()
    local viewGUID    = self:GetViewingNeighborhoodGUID()
    return activeGUID and viewGUID and activeGUID == viewGUID or false
end
function Endeavors:SelectHouse(index)
    if not state.houseList or index < 1 or index > #state.houseList then return end
    local house = state.houseList[index]
    if not house or not house.neighborhoodGUID then return end
    if state.retryTimer then state.retryTimer:Cancel(); state.retryTimer = nil end
    state.selectedHouseIndex   = index
    state.currentHouseGUID     = house.houseGUID
    state.lastManualSelectTime = GetTime()
    DB().selectedHouseGUID     = house.houseGUID
    GetOrCreateContext(house.houseGUID)
    state.activeGUID = house.houseGUID
    state.tasks             = {}
    state.activityLogLoaded = false
    state.activityLog       = nil
    if C_NeighborhoodInitiative then
        C_NeighborhoodInitiative.SetViewingNeighborhood(house.neighborhoodGUID)
        C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
        self:RequestActivityLog()
        C_Timer.After(1.5, function()
            self:RefreshActivityLog()
            self:QueueRefresh()
        end)
    end
end
function Endeavors:SetAsActiveEndeavor()
    local house = state.houseList[state.selectedHouseIndex]
    if not house or not house.neighborhoodGUID then return end
    if not C_NeighborhoodInitiative or not C_NeighborhoodInitiative.SetActiveNeighborhood then return end
    C_NeighborhoodInitiative.SetActiveNeighborhood(house.neighborhoodGUID)
    state.currentHouseGUID  = house.houseGUID
    state.activityLogLoaded = false
    print("|cFF2aa198[HomeDecor Endeavors]|r Active Endeavor set to |cFFffd700" ..
          (house.houseName or "Unknown") .. "|r")
    C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
    self:RequestActivityLog()
    C_Timer.After(1.5, function()
        self:RefreshActivityLog()
        self:QueueRefresh()
    end)
    if Endeavors.OnActiveNeighborhoodChanged then Endeavors.OnActiveNeighborhoodChanged() end
end
function Endeavors:TrackTask(taskID)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.AddTrackedInitiativeTask then
        C_NeighborhoodInitiative.AddTrackedInitiativeTask(taskID)
    end
end
function Endeavors:UntrackTask(taskID)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RemoveTrackedInitiativeTask then
        C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(taskID)
    end
end
function Endeavors:IsTaskTracked(taskID)
    if not taskID or not C_NeighborhoodInitiative then return false end
    local tracked = C_NeighborhoodInitiative.GetTrackedInitiativeTasks and
                    C_NeighborhoodInitiative.GetTrackedInitiativeTasks()
    if tracked and tracked.trackedIDs then
        for _, id in ipairs(tracked.trackedIDs) do
            if id == taskID then return true end
        end
    end
    return false
end
function Endeavors:GetEndeavorInfo()          return state.endeavorInfo end
function Endeavors:GetHouseList()             return state.houseList end
function Endeavors:GetSelectedHouseIndex()    return state.selectedHouseIndex end
function Endeavors:GetFetchStatus()           return state.fetchStatus end
function Endeavors:IsActivityLogLoaded()      return state.activityLogLoaded end
function Endeavors:GetMyChars()               return DBMyChars() end
function Endeavors:GetActivityLogTimestamp()  return state.activityLogTimestamp end
function Endeavors:IsActivityLogStale()       return state.activityLogStale end
function Endeavors:GetTasks(sortBy, sortDesc)
    local tasks = state.tasks
    if not sortBy or sortBy == "default" then return tasks end
    local sorted = {}
    for i = 1, #tasks do sorted[i] = tasks[i] end
    local guid = state.currentHouseGUID
    local ctx  = guid and GetOrCreateContext(guid) or {}
    table.sort(sorted, function(a, b)
        if a.completed ~= b.completed then return not a.completed end
        local valA, valB
        if sortBy == "xp" then
            valA, valB = a.points or 0, b.points or 0
        elseif sortBy == "coupons" then
            valA, valB = a.couponReward or 0, b.couponReward or 0
        elseif sortBy == "name" then
            return sortDesc and (a.name or "") > (b.name or "") or (a.name or "") < (b.name or "")
        elseif sortBy == "progress" then
            local pctA = a.max > 0 and (a.current / a.max) or 0
            local pctB = b.max > 0 and (b.current / b.max) or 0
            valA, valB = pctA, pctB
        elseif sortBy == "nextXP" then
            local cntA = ctx.accountCounts and ctx.accountCounts[a.id] or 0
            local cntB = ctx.accountCounts and ctx.accountCounts[b.id] or 0
            valA = CalculateNextContribution(a.name, cntA, guid)
            valB = CalculateNextContribution(b.name, cntB, guid)
        else
            valA, valB = a.points or 0, b.points or 0
        end
        if sortDesc ~= false then return valA > valB else return valA < valB end
    end)
    return sorted
end
function Endeavors:GetTaskRankings()
    return GetTaskRankings(state.tasks, state.currentHouseGUID)
end
function Endeavors:GetNextXP(taskName, taskID)
    local ctx = state.currentHouseGUID and GetOrCreateContext(state.currentHouseGUID)
    if not ctx then return 0 end
    local completions = ctx.accountCounts and ctx.accountCounts[taskID] or 0
    return CalculateNextContribution(taskName, completions, state.currentHouseGUID)
end
function Endeavors:GetXPCapStatus()
    return GetXPCapStatus(state.currentHouseGUID)
end
function Endeavors:GetHouseXP()
    local ctx = state.currentHouseGUID and GetOrCreateContext(state.currentHouseGUID)
    return ctx and ctx.houseXP or 0
end
function Endeavors:GetPlayerContribution()
    local ctx = state.currentHouseGUID and GetOrCreateContext(state.currentHouseGUID)
    return ctx and ctx.playerContrib or 0
end
function Endeavors:GetCommunityCoupons()
    if not C_CurrencyInfo then return 0 end
    local info = C_CurrencyInfo.GetCurrencyInfo(COUPON_CURRENCY_ID)
    return info and info.quantity or 0
end
function Endeavors:GetCouponIconID()
    if not C_CurrencyInfo then return 134400 end
    local info = C_CurrencyInfo.GetCurrencyInfo(COUPON_CURRENCY_ID)
    return info and info.iconFileID and info.iconFileID > 0 and info.iconFileID or 134400
end
function Endeavors:GetLeaderboard(grouped)
    if not state.activityLog or not state.activityLog.taskActivity then return {} end
    local contributions = {}
    for _, entry in ipairs(state.activityLog.taskActivity) do
        local playerName = entry.playerName or "Unknown"
        local amount     = entry.amount or 0
        contributions[playerName] = (contributions[playerName] or 0) + amount
    end
    local myChars    = DBMyChars()
    local playerName = UnitName("player") or ""
    local sorted = {}
    for name, amount in pairs(contributions) do
        if amount > 0 then
            table.insert(sorted, {
                name     = name,
                amount   = amount,
                isPlayer = name == playerName,
                isMyChar = myChars[name] == true,
            })
        end
    end
    table.sort(sorted, function(a, b) return a.amount > b.amount end)
    for i, entry in ipairs(sorted) do
        entry.rank = i
    end
    return sorted
end
function Endeavors:GetActivityFeed(filterMeOnly, filterMyChars, filterTaskName)
    if not state.activityLog or not state.activityLog.taskActivity then return {} end
    local myChars    = DBMyChars()
    local playerName = UnitName("player") or ""
    local result     = {}
    for _, entry in ipairs(state.activityLog.taskActivity) do
        local entryPlayer = entry.playerName or ""
        local passesPlayerFilter
        if filterMeOnly then
            passesPlayerFilter = entryPlayer == playerName
        elseif filterMyChars then
            passesPlayerFilter = entryPlayer == playerName or myChars[entryPlayer]
        else
            passesPlayerFilter = true
        end
        local passesTaskFilter = not filterTaskName or entry.taskName == filterTaskName
        if passesPlayerFilter and passesTaskFilter then
            table.insert(result, entry)
        end
    end
    table.sort(result, function(a, b)
        return (a.completionTime or 0) > (b.completionTime or 0)
    end)
    return result
end
function Endeavors:GetTopTasks(n)
    if not state.activityLog or not state.activityLog.taskActivity then return {} end
    local counts = {}
    for _, entry in ipairs(state.activityLog.taskActivity) do
        local taskName = entry.taskName or "Unknown"
        counts[taskName] = (counts[taskName] or 0) + 1
    end
    local list = {}
    for taskName, count in pairs(counts) do
        table.insert(list, { name = taskName, count = count })
    end
    table.sort(list, function(a, b) return a.count > b.count end)
    local topList = {}
    for i = 1, math.min(n or 5, #list) do
        topList[i] = list[i]
    end
    return topList
end
function Endeavors:ExportActivityCSV()
    if not state.activityLog or not state.activityLog.taskActivity then return "" end
    local lines = { "playerName,taskName,taskID,amount,completionTime" }
    for _, entry in ipairs(state.activityLog.taskActivity) do
        local player  = (entry.playerName or "Unknown"):gsub(",", ";")
        local task    = (entry.taskName or "Unknown"):gsub(",", ";")
        local taskID  = entry.taskID or 0
        local amount  = entry.amount or 0
        local ts      = entry.completionTime and date("%Y-%m-%d %H:%M:%S", entry.completionTime) or ""
        table.insert(lines, string.format("%s,%s,%d,%.3f,%s", player, task, taskID, amount, ts))
    end
    return table.concat(lines, "\n")
end
function Endeavors:ExportLeaderboardCSV()
    local leaderboard = self:GetLeaderboard()
    if #leaderboard == 0 then return "" end
    local lines = { "Rank,Character,Contribution" }
    for _, row in ipairs(leaderboard) do
        local name = row.name:gsub(",", ";")
        table.insert(lines, string.format("%d,%s,%.1f", row.rank, name, row.amount))
    end
    return table.concat(lines, "\n")
end
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("NEIGHBORHOOD_INITIATIVE_UPDATED")
eventFrame:RegisterEvent("INITIATIVE_TASKS_TRACKED_UPDATED")
eventFrame:RegisterEvent("INITIATIVE_TASKS_TRACKED_LIST_CHANGED")
eventFrame:RegisterEvent("INITIATIVE_TASK_COMPLETED")
eventFrame:RegisterEvent("INITIATIVE_COMPLETED")
eventFrame:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
eventFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
pcall(function() eventFrame:RegisterEvent("INITIATIVE_ACTIVITY_LOG_UPDATED") end)
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local charName = UnitName("player")
        if charName then DBMyChars()[charName] = true end
        C_Timer.After(2, function()
            if C_Housing and C_Housing.GetPlayerOwnedHouses then
                C_Housing.GetPlayerOwnedHouses()
            end
        end)
    elseif event == "PLAYER_HOUSE_LIST_UPDATED" then
        local houseInfoList = ...
        state.houseList      = houseInfoList or {}
        state.houseListLoaded = true
        local recentManual = (GetTime() - state.lastManualSelectTime) < 2
        if recentManual then return end
        local selectedIndex, neighborhoodGUID = nil, nil
        local activeGUID = C_NeighborhoodInitiative and
                           C_NeighborhoodInitiative.GetActiveNeighborhood and
                           C_NeighborhoodInitiative.GetActiveNeighborhood()
        if activeGUID and houseInfoList then
            for i, house in ipairs(houseInfoList) do
                if house.neighborhoodGUID == activeGUID then
                    selectedIndex, neighborhoodGUID = i, activeGUID
                    break
                end
            end
        end
        if not selectedIndex then
            local savedGUID = DB().selectedHouseGUID
            if savedGUID and houseInfoList then
                for i, house in ipairs(houseInfoList) do
                    if house.houseGUID == savedGUID then
                        selectedIndex    = i
                        neighborhoodGUID = house.neighborhoodGUID
                        break
                    end
                end
            end
        end
        if not selectedIndex and houseInfoList and #houseInfoList > 0 then
            selectedIndex    = 1
            neighborhoodGUID = houseInfoList[1].neighborhoodGUID
        end
        if selectedIndex then
            state.selectedHouseIndex = selectedIndex
            state.currentHouseGUID   = houseInfoList[selectedIndex].houseGUID
            DB().selectedHouseGUID   = state.currentHouseGUID
            state.activeGUID         = state.currentHouseGUID
            GetOrCreateContext(state.currentHouseGUID)
        end
        if neighborhoodGUID and C_NeighborhoodInitiative then
            C_NeighborhoodInitiative.SetViewingNeighborhood(neighborhoodGUID)
            C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
            Endeavors:RequestActivityLog()
        end
        if Endeavors.OnHouseListUpdated then
            Endeavors.OnHouseListUpdated(state.houseList, state.selectedHouseIndex)
        end
    elseif event == "NEIGHBORHOOD_INITIATIVE_UPDATED"
        or event == "INITIATIVE_TASKS_TRACKED_UPDATED" then
        Endeavors:QueueRefresh()
    elseif event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
        if C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetTrackedInitiativeTasks then
            local tracked = C_NeighborhoodInitiative.GetTrackedInitiativeTasks()
            if tracked and tracked.trackedIDs then
                local trackedSet = {}
                for _, id in ipairs(tracked.trackedIDs) do trackedSet[id] = true end
                for _, task in ipairs(state.tasks) do
                    task.tracked = trackedSet[task.id] or false
                end
            end
        end
        if Endeavors.OnDataReady then Endeavors.OnDataReady() end
    elseif event == "INITIATIVE_TASK_COMPLETED" then
        local taskName = ...
        state.activityLogStale = true
        table.insert(state.pendingTaskCompletions, {
            taskName  = taskName,
            timestamp = time(),
        })
        Endeavors:RequestActivityLog()
        state.taskCompletionRetryGen = state.taskCompletionRetryGen + 1
        local retryGen = state.taskCompletionRetryGen
        for _, delay in ipairs({ 30, 90, 240 }) do
            C_Timer.After(delay, function()
                if state.taskCompletionRetryGen ~= retryGen then return end
                Endeavors:RequestActivityLog()
                Endeavors:RefreshActivityLog()
            end)
        end
        Endeavors:QueueRefresh()
    elseif event == "INITIATIVE_COMPLETED" then
        Endeavors:FetchData(true)
    elseif event == "INITIATIVE_ACTIVITY_LOG_UPDATED" then
        Endeavors:RefreshActivityLog()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyID, quantity, totalQuantity = ...
        if currencyID == COUPON_CURRENCY_ID and #state.pendingTaskCompletions > 0 then
            local gains       = DBCouponGains()
            local taskCoupons = DBTaskCoupons()
            local completion = table.remove(state.pendingTaskCompletions)
            if completion and quantity and quantity > 0 then
                table.insert(gains, {
                    taskName  = completion.taskName,
                    amount    = quantity,
                    character = UnitName("player") or "",
                    timestamp = time(),
                })
                while #gains > 500 do table.remove(gains, 1) end
                if completion.taskName then
                    taskCoupons[completion.taskName] = taskCoupons[completion.taskName] or {}
                    table.insert(taskCoupons[completion.taskName], {
                        amount    = quantity,
                        timestamp = time(),
                    })
                    local history = taskCoupons[completion.taskName]
                    while #history > 20 do table.remove(history, 1) end
                end
            end
        end
    end
end)
function Endeavors:Initialize()
end
return Endeavors
