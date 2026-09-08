local _, NS = ...

local Endeavors = {}
NS.Systems.Endeavors = Endeavors

local COUPON_CURRENCY_ID = 3363
local RETRY_DELAYS = { 0.5, 1.5, 3, 8 }
local state = {
  houses = {},
  selectedHouseIndex = 1,
  info = {},
  tasks = {},
  activity = {},
  leaderboard = {},
  taskStats = {},
  loaded = false,
  activityLoaded = false,
  status = "pending",
  generation = 0,
  lastCouponQuantity = nil,
  pendingCompletions = {},
}

local function Profile()
  local profile = NS.Systems.Database and NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.endeavors = profile.endeavors or {}
  local settings = profile.endeavors
  settings.myCharacters = settings.myCharacters or {}
  settings.couponGains = settings.couponGains or {}
  settings.taskActualCoupons = settings.taskActualCoupons or {}
  if type(settings.sort) ~= "table" then settings.sort = { key = "default", descending = false } end
  if type(settings.activitySort) ~= "table" then settings.activitySort = { key = "time", descending = true } end
  if type(settings.leaderboardSort) ~= "table" then settings.leaderboardSort = { key = "amount", descending = true } end
  if type(settings.couponSort) ~= "table" then settings.couponSort = { key = "time", descending = true } end
  settings.sort.key = settings.sort.key or "default"
  settings.sort.descending = settings.sort.descending == true
  settings.activitySort.key = settings.activitySort.key or "time"
  settings.activitySort.descending = settings.activitySort.descending ~= false
  settings.leaderboardSort.key = settings.leaderboardSort.key or "amount"
  settings.leaderboardSort.descending = settings.leaderboardSort.descending ~= false
  settings.couponSort.key = settings.couponSort.key or "time"
  settings.couponSort.descending = settings.couponSort.descending ~= false
  return settings
end

local function Notify(reason)
  NS.SendMessage("HOMEDECOR_ENDEAVORS_UPDATED", reason)
end

local function API()
  return _G.C_NeighborhoodInitiative
end

local function SafeCall(func, ...)
  if type(func) ~= "function" then return nil end
  local ok, result = pcall(func, ...)
  if ok then return result end
  return nil
end

local function NormalizeHouses(houses)
  if type(houses) ~= "table" then return {} end
  if type(houses.houseInfoList) == "table" then houses = houses.houseInfoList end
  local result = {}
  for _, house in ipairs(houses) do
    if type(house) == "table" and house.houseGUID and house.neighborhoodGUID then result[#result + 1] = house end
  end
  return result
end

local function HouseLabel(house, index)
  if not house then return "House " .. tostring(index or "") end
  return house.houseName or house.neighborhoodName or house.ownerName or ("House " .. tostring(index or ""))
end

local function GetProgress(task)
  local current = 0
  local maximum = 0
  for _, criteria in ipairs(task.criteriaList or {}) do
    local value = tonumber(criteria.quantity or criteria.currentValue or criteria.currentQuantity or criteria.value) or 0
    local required = tonumber(criteria.requiredQuantity or criteria.requiredValue or criteria.maxQuantity or criteria.maxValue) or 0
    current = current + value
    maximum = maximum + required
  end
  if maximum > 0 then return current, maximum end
  for _, requirement in ipairs(task.requirementsList or {}) do
    local text = requirement.requirementText or requirement.text
    if type(text) == "string" then
      local value, required = text:match("(%d+)%s*/%s*(%d+)")
      if value and required then return tonumber(value) or 0, tonumber(required) or 1 end
    end
  end
  return task.completed and 1 or 0, 1
end

local function GetCouponReward(task)
  local questID = tonumber(task.rewardQuestID)
  if not questID or questID <= 0 then return 0 end
  local settings = Profile()
  local history = settings and settings.taskActualCoupons[task.taskName or ""]
  if history and #history > 0 then return tonumber(history[#history].amount) or 0 end
  local rewards = _G.C_QuestLog and SafeCall(_G.C_QuestLog.GetQuestRewardCurrencies, questID)
  for _, reward in ipairs(rewards or {}) do
    if tonumber(reward.currencyID) == COUPON_CURRENCY_ID then return tonumber(reward.totalRewardAmount) or 0 end
  end
  if _G.C_TaskQuest and _G.C_TaskQuest.RequestPreloadRewardData then SafeCall(_G.C_TaskQuest.RequestPreloadRewardData, questID) end
  return 0
end

local function RebuildActivityModels()
  wipe(state.taskStats)
  local totals = {}
  local settings = Profile()
  local myCharacters = settings and settings.myCharacters or {}
  local player = UnitName and UnitName("player") or ""
  for _, entry in ipairs(state.activity) do
    local taskID = tonumber(entry.taskID)
    local amount = tonumber(entry.amount) or 0
    local name = entry.playerName or "Unknown"
    local stats = taskID and state.taskStats[taskID]
    if taskID and not stats then
      stats = { accountCompletions = 0, playerCompletions = 0, lastAmount = 0, lastTime = 0 }
      state.taskStats[taskID] = stats
    end
    if stats then
      if name == player or myCharacters[name] then stats.accountCompletions = stats.accountCompletions + 1 end
      if name == player then stats.playerCompletions = stats.playerCompletions + 1 end
      if amount > 0 and (tonumber(entry.completionTime) or 0) >= stats.lastTime then
        stats.lastAmount = amount
        stats.lastTime = tonumber(entry.completionTime) or 0
      end
    end
    totals[name] = (totals[name] or 0) + amount
  end
  wipe(state.leaderboard)
  for name, amount in pairs(totals) do
    state.leaderboard[#state.leaderboard + 1] = {
      name = name,
      amount = amount,
      isPlayer = name == player,
      isMyCharacter = name == player or myCharacters[name] == true,
    }
  end
  table.sort(state.leaderboard, function(a, b)
    if a.amount == b.amount then return a.name < b.name end
    return a.amount > b.amount
  end)
  for index, entry in ipairs(state.leaderboard) do entry.rank = index end
end

local function RebuildTasks(apiTasks)
  local tracked = {}
  local api = API()
  local trackedInfo = api and SafeCall(api.GetTrackedInitiativeTasks)
  for _, id in ipairs(trackedInfo and trackedInfo.trackedIDs or {}) do tracked[tonumber(id)] = true end
  wipe(state.tasks)
  for _, task in ipairs(apiTasks or {}) do
    if not task.supersedes or task.supersedes == 0 then
      local current, maximum = GetProgress(task)
      local id = tonumber(task.ID)
      local stats = id and state.taskStats[id] or {}
      local lastAmount = tonumber(stats.lastAmount) or 0
      local completions = tonumber(stats.accountCompletions) or 0
      local nextContribution = lastAmount > 0 and math.floor(lastAmount * math.max(0.5, 1 - math.min(5, completions) * 0.1) + 0.5) or tonumber(task.progressContributionAmount) or 0
      state.tasks[#state.tasks + 1] = {
        id = id,
        name = task.taskName or ("Task " .. tostring(id or "")),
        description = task.description or "",
        current = current,
        maximum = maximum,
        progress = maximum > 0 and current / maximum or 0,
        points = tonumber(task.progressContributionAmount) or 0,
        coupons = GetCouponReward(task),
        nextContribution = nextContribution,
        completed = task.completed == true,
        inProgress = task.inProgress == true,
        repeatable = tonumber(task.taskType) and tonumber(task.taskType) > 0 or false,
        tracked = tracked[id] == true or task.tracked == true,
        timesCompleted = tonumber(task.timesCompleted) or 0,
        accountCompletions = completions,
        playerCompletions = tonumber(stats.playerCompletions) or 0,
        sortOrder = tonumber(task.sortOrder) or 0,
        rewardQuestID = tonumber(task.rewardQuestID),
      }
    end
  end
end

local function ProcessInfo(info)
  state.loaded = true
  state.status = "ready"
  local milestones = {}
  local maximum = tonumber(info.progressRequired) or 0
  for _, milestone in ipairs(info.milestones or {}) do
    local threshold = tonumber(milestone.requiredContributionAmount) or 0
    if threshold > maximum then maximum = threshold end
    milestones[#milestones + 1] = {
      threshold = threshold,
      reached = (tonumber(info.currentProgress) or 0) >= threshold,
      rewards = milestone.rewards or {},
      order = tonumber(milestone.milestoneOrderIndex) or 0,
    }
  end
  table.sort(milestones, function(a, b) return a.order < b.order end)
  state.info = {
    title = info.title or "Neighborhood Endeavor",
    description = info.description or "",
    initiativeID = tonumber(info.initiativeID),
    currentCycleID = tonumber(info.currentCycleID),
    currentProgress = tonumber(info.currentProgress) or 0,
    maximumProgress = maximum > 0 and maximum or 1,
    playerContribution = tonumber(info.playerTotalContribution) or 0,
    secondsRemaining = tonumber(info.duration) or 0,
    daysRemaining = math.max(0, math.ceil((tonumber(info.duration) or 0) / 86400)),
    neighborhoodGUID = info.neighborhoodGUID,
    milestones = milestones,
  }
  RebuildTasks(info.tasks)
end

function Endeavors:GetSettings()
  return Profile()
end

function Endeavors:GetState()
  return state
end

function Endeavors:GetHouses()
  return state.houses
end

function Endeavors:GetSelectedHouseIndex()
  return state.selectedHouseIndex
end

function Endeavors:GetSelectedHouse()
  return state.houses[state.selectedHouseIndex]
end

function Endeavors:GetActiveNeighborhoodGUID()
  local api = API()
  return api and SafeCall(api.GetActiveNeighborhood) or nil
end

function Endeavors:IsSelectedHouseActive()
  local house = self:GetSelectedHouse()
  local active = self:GetActiveNeighborhoodGUID()
  return house and active and house.neighborhoodGUID == active or false
end

function Endeavors:RequestHouseList()
  if _G.C_Housing and _G.C_Housing.GetPlayerOwnedHouses then SafeCall(_G.C_Housing.GetPlayerOwnedHouses) end
end

function Endeavors:SelectHouse(index)
  index = tonumber(index)
  local house = index and state.houses[index]
  if not house then return false end
  state.selectedHouseIndex = index
  local settings = Profile()
  if settings then settings.selectedHouseGUID = house.houseGUID end
  local api = API()
  if api then
    SafeCall(api.SetViewingNeighborhood, house.neighborhoodGUID)
    SafeCall(api.RequestNeighborhoodInitiativeInfo)
  end
  state.loaded = false
  state.activityLoaded = false
  state.status = "loading"
  self:Fetch(true)
  self:RequestActivityLog()
  Notify("house")
  return true
end

function Endeavors:SetSelectedHouseActive()
  local house = self:GetSelectedHouse()
  local api = API()
  if not house or not api or type(api.SetActiveNeighborhood) ~= "function" then return false end
  SafeCall(api.SetActiveNeighborhood, house.neighborhoodGUID)
  SafeCall(api.SetViewingNeighborhood, house.neighborhoodGUID)
  SafeCall(api.RequestNeighborhoodInitiativeInfo)
  self:Fetch(true)
  self:RequestActivityLog()
  Notify("active")
  return true
end

function Endeavors:Fetch(force)
  local api = API()
  if not api then
    state.status = "unsupported"
    Notify("unsupported")
    return false
  end
  if api.IsInitiativeEnabled and SafeCall(api.IsInitiativeEnabled) == false then
    state.status = "disabled"
    Notify("disabled")
    return false
  end
  if api.PlayerHasInitiativeAccess and SafeCall(api.PlayerHasInitiativeAccess) == false then
    state.status = "locked"
    Notify("locked")
    return false
  end
  if force then SafeCall(api.RequestNeighborhoodInitiativeInfo) end
  local info = SafeCall(api.GetNeighborhoodInitiativeInfo)
  if info and info.isLoaded then
    ProcessInfo(info)
    Notify("data")
    return true
  end
  state.status = "loading"
  state.loaded = false
  SafeCall(api.RequestNeighborhoodInitiativeInfo)
  state.generation = state.generation + 1
  local generation = state.generation
  for attempt, delay in ipairs(RETRY_DELAYS) do
    C_Timer.After(delay, function()
      if generation ~= state.generation or state.loaded then return end
      local retryInfo = SafeCall(api.GetNeighborhoodInitiativeInfo)
      if retryInfo and retryInfo.isLoaded then
        ProcessInfo(retryInfo)
        Notify("data")
      elseif attempt == #RETRY_DELAYS then
        state.status = "unavailable"
        Notify("unavailable")
      else
        SafeCall(api.RequestNeighborhoodInitiativeInfo)
      end
    end)
  end
  Notify("loading")
  return false
end

function Endeavors:RequestActivityLog()
  local api = API()
  if api then SafeCall(api.RequestInitiativeActivityLog) end
end

function Endeavors:RefreshActivityLog()
  local api = API()
  local info = api and SafeCall(api.GetInitiativeActivityLogInfo)
  if not info or not info.isLoaded then
    state.activityLoaded = false
    return false
  end
  wipe(state.activity)
  for _, entry in ipairs(info.taskActivity or {}) do state.activity[#state.activity + 1] = entry end
  state.activityLoaded = true
  state.activityNextUpdate = tonumber(info.nextUpdateTime)
  state.activityNeighborhoodGUID = info.neighborhoodGUID
  RebuildActivityModels()
  if state.loaded then RebuildTasks((SafeCall(api.GetNeighborhoodInitiativeInfo) or {}).tasks) end
  Notify("activity")
  return true
end

function Endeavors:TrackTask(taskID, tracked)
  local api = API()
  if not api or not taskID then return end
  if tracked then SafeCall(api.AddTrackedInitiativeTask, taskID) else SafeCall(api.RemoveTrackedInitiativeTask, taskID) end
  for _, task in ipairs(state.tasks) do if task.id == taskID then task.tracked = tracked == true end end
  Notify("tracking")
end

function Endeavors:GetTasks()
  return state.tasks
end

function Endeavors:GetActivity()
  return state.activity
end

function Endeavors:GetLeaderboard()
  return state.leaderboard
end

function Endeavors:GetCouponGains()
  local settings = Profile()
  return settings and settings.couponGains or {}
end

function Endeavors:GetCouponInfo()
  local info = _G.C_CurrencyInfo and SafeCall(_G.C_CurrencyInfo.GetCurrencyInfo, COUPON_CURRENCY_ID)
  return info and tonumber(info.quantity) or 0, info and info.iconFileID or 134400
end

function Endeavors:GetAvailableHouseXP()
  local api = API()
  return api and tonumber(SafeCall(api.GetAvailableHouseXP)) or 0
end

function Endeavors:GetRequiredLevel()
  local api = API()
  return api and tonumber(SafeCall(api.GetRequiredLevel)) or nil
end

function Endeavors:OnHouseListUpdated(houses)
  local normalized = NormalizeHouses(houses)
  if #normalized == 0 then return end
  wipe(state.houses)
  for _, house in ipairs(normalized) do state.houses[#state.houses + 1] = house end
  local settings = Profile()
  local saved = settings and settings.selectedHouseGUID
  local active = self:GetActiveNeighborhoodGUID()
  local selected = 1
  for index, house in ipairs(state.houses) do
    if house.houseGUID == saved or not saved and active and house.neighborhoodGUID == active then selected = index break end
  end
  state.selectedHouseIndex = selected
  local house = state.houses[selected]
  if settings then settings.selectedHouseGUID = house.houseGUID end
  local api = API()
  if api then SafeCall(api.SetViewingNeighborhood, house.neighborhoodGUID) end
  self:Fetch(true)
  self:RequestActivityLog()
  Notify("houses")
end

function Endeavors:OnTrackedChanged(taskID, added)
  for _, task in ipairs(state.tasks) do if task.id == tonumber(taskID) then task.tracked = added == true end end
  Notify("tracking")
end

function Endeavors:OnTaskCompleted(taskName)
  state.pendingCompletions[#state.pendingCompletions + 1] = { taskName = taskName or "Completed task", time = time() }
  self:Fetch(true)
  self:RequestActivityLog()
end

function Endeavors:OnCurrencyChanged(currencyID)
  if currencyID and tonumber(currencyID) ~= COUPON_CURRENCY_ID then return end
  local quantity = self:GetCouponInfo()
  if state.lastCouponQuantity == nil then
    state.lastCouponQuantity = quantity
    return
  end
  local change = quantity - state.lastCouponQuantity
  state.lastCouponQuantity = quantity
  if change <= 0 or #state.pendingCompletions == 0 then return end
  local completion = table.remove(state.pendingCompletions, 1)
  local gains = self:GetCouponGains()
  gains[#gains + 1] = {
    taskName = completion.taskName,
    amount = change,
    character = UnitName and UnitName("player") or "",
    timestamp = time(),
  }
  while #gains > 300 do table.remove(gains, 1) end
  local settings = Profile()
  if settings and completion.taskName then
    local history = settings.taskActualCoupons[completion.taskName] or {}
    settings.taskActualCoupons[completion.taskName] = history
    history[#history + 1] = { amount = change, timestamp = time() }
    while #history > 20 do table.remove(history, 1) end
  end
  Notify("coupons")
end

NS.RegisterEvent(Endeavors, "PLAYER_ENTERING_WORLD", function()
  local settings = Profile()
  local player = UnitName and UnitName("player")
  if settings and player then settings.myCharacters[player] = true end
  local quantity = Endeavors:GetCouponInfo()
  state.lastCouponQuantity = quantity
  C_Timer.After(1, function() Endeavors:RequestHouseList() end)
end)
NS.RegisterEvent(Endeavors, "PLAYER_HOUSE_LIST_UPDATED", function(houses) Endeavors:OnHouseListUpdated(houses) end)
NS.RegisterEvent(Endeavors, "NEIGHBORHOOD_INITIATIVE_UPDATED", function() Endeavors:Fetch() end)
NS.RegisterEvent(Endeavors, "INITIATIVE_TASKS_TRACKED_UPDATED", function() Endeavors:Fetch() end)
NS.RegisterEvent(Endeavors, "INITIATIVE_TASKS_TRACKED_LIST_CHANGED", function(taskID, added) Endeavors:OnTrackedChanged(taskID, added) end)
NS.RegisterEvent(Endeavors, "INITIATIVE_TASK_COMPLETED", function(taskName) Endeavors:OnTaskCompleted(taskName) end)
NS.RegisterEvent(Endeavors, "INITIATIVE_COMPLETED", function() Endeavors:Fetch(true) end)
NS.RegisterEvent(Endeavors, "CURRENCY_DISPLAY_UPDATE", function(currencyID) Endeavors:OnCurrencyChanged(currencyID) end)
NS.SafeRegisterEvent(Endeavors, "INITIATIVE_ACTIVITY_LOG_UPDATED", function() Endeavors:RefreshActivityLog() end)

return Endeavors
