local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local Events = NS.Systems.Events or {}
NS.Systems.Events = Events

local MONTH = { jan=1, feb=2, mar=3, apr=4, may=5, jun=6, jul=7, aug=8, sep=9, oct=10, nov=11, dec=12 }
local MONTH_NAME = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local time = _G.time
local date = _G.date
local type = type
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local floor = math.floor
local sort = table.sort
local concat = table.concat

local function Now()
  local CalendarAPI = _G.C_DateAndTime
  if CalendarAPI and CalendarAPI.GetCurrentCalendarTime then
    local ok, cal = pcall(CalendarAPI.GetCurrentCalendarTime)
    if ok and type(cal) == "table" and cal.year and cal.month and (cal.monthDay or cal.day) then
      local epoch = time({
        year = cal.year,
        month = cal.month,
        day = cal.monthDay or cal.day,
        hour = cal.hour or 0,
        min = cal.minute or 0,
        sec = 0,
      })
      if epoch then return epoch end
    end
  end

  return time()
end

local function Wipe(t)
  if type(t) ~= "table" then return end
  for k in pairs(t) do t[k] = nil end
end

local function MonthNumber(mon)
  if type(mon) ~= "string" then return nil end
  return MONTH[mon:lower():sub(1, 3)]
end

local function Cache(self)
  local c = self.cache
  if c then return c end
  c = {
    flat = { ready = false, list = {} },
    status = { nextCheck = 0, sig = nil, hasActive = false, events = {}, parts = {} },
  }
  self.cache = c
  return c
end

local function DateParts(mon, day, year)
  local m = MonthNumber(mon)
  local d = tonumber(day)
  local y = tonumber(year)
  if not m or not d then return nil end
  return { month = m, day = d, year = y, hasYear = y ~= nil }
end

local function DateEpoch(parts, defaultYear, isEnd)
  if type(parts) ~= "table" then return nil end
  return time({
    year = parts.year or defaultYear,
    month = parts.month,
    day = parts.day,
    hour = isEnd and 23 or 0,
    min = isEnd and 59 or 0,
    sec = isEnd and 59 or 0,
  })
end

local function ShiftYear(epoch, delta)
  if type(epoch) ~= "number" then return nil end
  local t = date("*t", epoch)
  if type(t) ~= "table" then return nil end
  t.year = (t.year or 0) + (delta or 0)
  return time(t)
end

local function FormatRemaining(sec)
  sec = tonumber(sec) or 0
  if sec < 0 then sec = 0 end
  local d = floor(sec / 86400); sec = sec - d * 86400
  local h = floor(sec / 3600); sec = sec - h * 3600
  local m = floor(sec / 60)
  if d > 0 then return tostring(d) .. "d " .. tostring(h) .. "h" end
  if h > 0 then return tostring(h) .. "h " .. tostring(m) .. "m" end
  return tostring(m) .. "m"
end

local function EventLabel(ev)
  if type(ev) ~= "table" then return "Event" end
  local source = ev.source
  local label = ev.title or ev.name or (source and (source.name or source.zone or source.title))
  if type(label) == "string" and label ~= "" then return label end
  return "Event"
end

local function EventItemLabel(it)
  local source = it and it.source
  local label = source and (source.name or source.zone or source.title)
  if type(label) == "string" and label ~= "" then return label end
  return "Event"
end

local function IsEventItem(t)
  return type(t) == "table"
    and t.decorID ~= nil
    and type(t.source) == "table"
    and t.source.type == "event"
end

local function IsEventLeaf(t)
  return type(t) == "table" and type(t.items) == "table" and (t.title or t.name or t.source)
end

local function AddEventItem(out, it)
  out._eventGroups = out._eventGroups or {}

  local label = EventItemLabel(it)
  local itemSource = it.source
  local ev = out._eventGroups[label]
  if not ev then
    ev = {
      title = label,
      name = label,
      source = {
        type = "event",
        name = label,
        zone = itemSource and itemSource.zone,
      },
      items = {},
    }
    if type(itemSource) == "table" then
      ev.startsOn = itemSource.startsOn or itemSource.startOn or itemSource.startDate or itemSource.starts or itemSource.addOn
      ev.endsOn = itemSource.endsOn or itemSource.endOn or itemSource.endDate or itemSource.ends or itemSource.finish or itemSource["end"]
      ev.year = itemSource.year
      ev.endYear = itemSource.endYear
      ev.source.startsOn = ev.startsOn
      ev.source.endsOn = ev.endsOn
      ev.source.year = ev.year
      ev.source.endYear = ev.endYear
    end
    out._eventGroups[label] = ev
    out[#out + 1] = ev
  end

  ev.items[#ev.items + 1] = it
end

local function Flatten(root, out, visited, depth)
  if type(root) ~= "table" then return end
  if visited[root] then return end
  visited[root] = true

  depth = (depth or 0) + 1
  if depth > 12 then return end

  if IsEventItem(root) then
    AddEventItem(out, root)
    return
  end

  if IsEventLeaf(root) then
    out[#out + 1] = root
    return
  end

  local nums
  for k, v in pairs(root) do
    if type(k) == "number" and k >= 1 and floor(k) == k and type(v) == "table" then
      nums = nums or {}
      nums[#nums + 1] = k
    end
  end
  if nums then
    sort(nums)
    for i = 1, #nums do Flatten(root[nums[i]], out, visited, depth) end
  end

  for k, v in pairs(root) do
    if type(k) ~= "number" and type(v) == "table" then
      Flatten(v, out, visited, depth)
    end
  end
end

local function CandidateTexts(ev)
  local source = ev and ev.source
  return {
    ev and ev.dateRange,
    ev and ev.dates,
    ev and ev.date,
    ev and ev.duration,
    ev and ev.schedule,
    ev and ev.availability,
    ev and ev.window,
    ev and ev.note,
    ev and ev.title,
    ev and ev.name,
    source and source.dateRange,
    source and source.dates,
    source and source.date,
    source and source.note,
    source and source.zone,
    source and source.title,
    source and source.name,
  }
end

local function ExtractRangeParts(ev)
  local candidates = CandidateTexts(ev)
  for i = 1, #candidates do
    local text = candidates[i]
    if type(text) == "string" and text ~= "" then
      local sm, sd, em, ed, y = text:match("([%a]+)%s+(%d%d?)%D+([%a]+)%s+(%d%d?)%D*(%d%d%d%d)")
      if sm and MonthNumber(sm) and MonthNumber(em) then
        return DateParts(sm, sd, y), DateParts(em, ed, y)
      end

      sm, sd, em, ed = text:match("([%a]+)%s+(%d%d?)%D+([%a]+)%s+(%d%d?)")
      if sm and MonthNumber(sm) and MonthNumber(em) then
        return DateParts(sm, sd), DateParts(em, ed)
      end

      sm, sd, ed, y = text:match("([%a]+)%s+(%d%d?)%D+(%d%d?)%D*(%d%d%d%d)")
      if sm and MonthNumber(sm) then
        return DateParts(sm, sd, y), DateParts(sm, ed, y)
      end

      sm, sd, ed = text:match("([%a]+)%s+(%d%d?)%D+(%d%d?)")
      if sm and MonthNumber(sm) then
        return DateParts(sm, sd), DateParts(sm, ed)
      end
    end
  end
end

local function ResolveRange(ev, now)
  now = now or Now()
  local startParts, endParts = ExtractRangeParts(ev)
  if not startParts and not endParts then return nil end

  local n = date("*t", now)
  local year = n.year
  local sEpoch = DateEpoch(startParts, year, false)
  local eEpoch = DateEpoch(endParts, year, true)

  if sEpoch and eEpoch and sEpoch > eEpoch and not startParts.hasYear and not endParts.hasYear then
    if now <= eEpoch then
      sEpoch = ShiftYear(sEpoch, -1) or sEpoch
    elseif now >= sEpoch then
      eEpoch = ShiftYear(eEpoch, 1) or eEpoch
    end
  end

  return sEpoch, eEpoch
end

local function DateStringFromEpoch(epoch)
  if type(epoch) ~= "number" then return nil end
  local t = date("*t", epoch)
  if type(t) ~= "table" then return nil end
  return (MONTH_NAME[t.month] or tostring(t.month)) .. " " .. tostring(t.day)
end

local function IsDecorVisible(item)
  local Availability = NS.Systems and NS.Systems.CatalogAvailability
  return not Availability or not Availability.ShouldShowItem or Availability:ShouldShowItem(item)
end

local function FirstVisibleItem(ev)
  if type(ev) ~= "table" or type(ev.items) ~= "table" then return nil end
  for i = 1, #ev.items do
    local item = ev.items[i]
    if type(item) == "table" and IsDecorVisible(item) then
      return item
    end
  end
end

function Events:ParseDateEpoch(str, isEnd)
  if type(str) ~= "string" or str == "" then return nil end

  local n = date("*t", Now())
  local y, m, d = str:match("^%s*(%d%d%d%d)%D+(%d%d?)%D+(%d%d?)%s*$")
  if y and m and d then
    return time({
      year = tonumber(y),
      month = tonumber(m),
      day = tonumber(d),
      hour = isEnd and 23 or 0,
      min = isEnd and 59 or 0,
      sec = isEnd and 59 or 0,
    })
  end

  m, d, y = str:match("^%s*(%d%d?)%D+(%d%d?)%D+(%d%d%d%d)%s*$")
  if y and m and d then
    return time({
      year = tonumber(y),
      month = tonumber(m),
      day = tonumber(d),
      hour = isEnd and 23 or 0,
      min = isEnd and 59 or 0,
      sec = isEnd and 59 or 0,
    })
  end

  local mon, day, year = str:match("^%s*([%a]+)%s*[-/ ]%s*(%d%d?)%s*[-/ ]?%s*(%d*)%s*$")
  local parts = DateParts(mon, day, year)
  if parts then
    return DateEpoch(parts, n.year, isEnd)
  end

  return nil
end

local function DateValueEpoch(value, year, isEnd)
  if type(value) == "number" then return value end
  if type(value) ~= "string" or value == "" then return nil end

  local y, m, d = value:match("^%s*(%d%d%d%d)%D+(%d%d?)%D+(%d%d?)%s*$")
  if y and m and d then
    return time({
      year = tonumber(y),
      month = tonumber(m),
      day = tonumber(d),
      hour = isEnd and 23 or 0,
      min = isEnd and 59 or 0,
      sec = isEnd and 59 or 0,
    })
  end

  local mon, day = value:match("^%s*([%a]+)%s+%D*(%d%d?)%s*$")
  local parts = DateParts(mon, day, year)
  if parts then
    local n = date("*t", Now())
    return DateEpoch(parts, tonumber(year) or n.year, isEnd)
  end

  return nil
end

function Events:GetEventsFlat()
  local c = Cache(self)
  if c.flat.ready then return c.flat.list end

  local DataLoader = NS.Systems and NS.Systems.DataLoader
  if DataLoader and DataLoader.EnsureEvents then
    DataLoader:EnsureEvents()
  end

  local list = {}
  if NS.Data and type(NS.Data.Events) == "table" then
    Flatten(NS.Data.Events, list, {}, 0)
  end

  c.flat.list = list
  c.flat.ready = true
  return list
end

function Events:IsActiveEvent(ev, now)
  if type(ev) ~= "table" then return false end
  now = now or Now()

  local sEpoch = tonumber(ev.startsAt or ev.startAt)
  local eEpoch = tonumber(ev.endsAt or ev.endAt)
  local source = ev.source
  local startsOn = ev.startsOn or ev.startDate or ev.startOn or ev.start or ev.starts
    or (source and (source.startsOn or source.startDate or source.startOn or source.start or source.starts or source.addOn))
  local endsOn = ev.endsOn or ev.endDate or ev.endOn or ev.finish or ev["end"] or ev.ends
    or (source and (source.endsOn or source.endDate or source.endOn or source.finish or source["end"] or source.ends))
  local startYear = ev.year or ev.startYear or (source and (source.year or source.startYear))
  local endYear = ev.endYear or ev.year or (source and (source.endYear or source.year))
  if not sEpoch and startsOn then sEpoch = DateValueEpoch(startsOn, startYear, false) or self:ParseDateEpoch(startsOn, false) end
  if not eEpoch and endsOn then eEpoch = DateValueEpoch(endsOn, endYear, true) or self:ParseDateEpoch(endsOn, true) end
  if not sEpoch or not eEpoch then
    local rs, re = ResolveRange(ev, now)
    sEpoch = sEpoch or rs
    eEpoch = eEpoch or re
  end

  if ev.active == true then return true, sEpoch, eEpoch end
  if sEpoch and eEpoch then return now >= sEpoch and now <= eEpoch, sEpoch, eEpoch end
  if eEpoch then return now <= eEpoch, sEpoch, eEpoch end
  if sEpoch then return now >= sEpoch, sEpoch, eEpoch end
  return false, sEpoch, eEpoch
end

function Events:RecalcStatus(now)
  now = now or Now()
  local c = Cache(self)
  local s = c.status

  if s.sig and now < (s.nextCheck or 0) then
    return s.hasActive, s.sig
  end

  Wipe(s.events)
  Wipe(s.parts)

  local hasActive = false
  local nextChange = now + 300
  local list = self:GetEventsFlat()

  for _, ev in ipairs(list) do
    if type(ev) == "table" then
      local active, sEpoch, eEpoch = self:IsActiveEvent(ev, now)

      if active and FirstVisibleItem(ev) then
        ev._startsEpoch = sEpoch
        ev._endsEpoch = eEpoch
        s.events[#s.events + 1] = ev
        s.parts[#s.parts + 1] = EventLabel(ev) .. ":" .. tostring(eEpoch or "")
        hasActive = true
        if eEpoch and eEpoch + 1 > now and eEpoch + 1 < nextChange then
          nextChange = eEpoch + 1
        end
      elseif sEpoch and sEpoch > now and sEpoch < nextChange then
        nextChange = sEpoch
      end
    end
  end

  if #s.parts > 1 then sort(s.parts) end
  s.sig = (#s.parts > 0) and concat(s.parts, "|") or ""
  s.hasActive = hasActive
  if nextChange <= now then nextChange = now + 1 end
  s.nextCheck = nextChange

  return hasActive, s.sig
end

function Events:GetActive()
  self:RecalcStatus(Now())
  return Cache(self).status.events
end

function Events:HasActive()
  local ok = self:RecalcStatus(Now())
  return ok == true
end

function Events:GetEventTimeText(ev, now)
  if type(ev) ~= "table" then return nil end
  now = now or Now()
  local e = ev._endsEpoch or tonumber(ev.endsAt or ev.endAt)
  if not e then
    local _, _, eEpoch = self:IsActiveEvent(ev, now)
    e = eEpoch
  end
  if not e then return nil end
  return "Ends in " .. FormatRemaining(e - now)
end

function Events:GetEventEndDateText(ev)
  if type(ev) ~= "table" then return nil end
  local e = ev._endsEpoch or tonumber(ev.endsAt or ev.endAt)
  if not e then
    local _, _, eEpoch = self:IsActiveEvent(ev, Now())
    e = eEpoch
  end
  local txt = DateStringFromEpoch(e)
  return txt and ("Ends " .. txt) or nil
end

function Events:GetTimeText(arg, now)
  if type(arg) == "table" then return self:GetEventTimeText(arg, now) end
  local e = tonumber(arg)
  if not e then return nil end
  return "Ends in " .. FormatRemaining(e - (now or Now()))
end

function Events:GetFeaturedEvent()
  local list = self:GetActive()
  local ev = list and list[1]
  if type(ev) ~= "table" then return nil end

  local item = FirstVisibleItem(ev)

  local sig = EventLabel(ev) .. ":" .. tostring(ev._endsEpoch or "")
  if item then sig = sig .. ":" .. tostring(item.decorID or item.itemID or "") end
  return ev, item, self:GetEventTimeText(ev), sig
end

function Events:Invalidate()
  local c = self.cache
  if not c then return end
  if c.flat then c.flat.ready = false; c.flat.list = {} end
  local s = c.status
  if s then
    s.sig = nil
    s.nextCheck = 0
    s.hasActive = false
    if s.events then Wipe(s.events) end
    if s.parts then Wipe(s.parts) end
  end
end

return Events
