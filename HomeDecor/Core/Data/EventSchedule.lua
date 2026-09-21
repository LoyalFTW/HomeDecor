local _, NS = ...

local EventSchedule = {}
NS.Systems.EventSchedule = EventSchedule

local deadlines = {
  ["Fanta x Warcraft collab"] = "2026-07-30",
  ["Zillow & Warcraft collab"] = "2026-09-30",
}

local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local function DateValue(value)
  return type(value) == "string" and value:match("^%d%d%d%d%-%d%d%-%d%d$") and value or nil
end

local function DisplayDate(value)
  local year, month, day = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  return string.format("%s %d, %s", months[tonumber(month)] or month, tonumber(day), year)
end

function EventSchedule:Apply(record, leaf, source)
  if record.sourceType ~= "event" then return end
  record.eventStartDate = DateValue(leaf.eventStartDate or source.eventStartDate)
  record.eventEndDate = DateValue(leaf.eventEndDate or source.eventEndDate or deadlines[record.sourceName])
end

function EventSchedule:Today()
  return _G.date and _G.date("%Y-%m-%d") or nil
end

function EventSchedule:IsCurrent(record, today)
  today = today or self:Today()
  if not today then return true end
  if record.eventStartDate and today < record.eventStartDate then return false end
  if record.eventEndDate and today > record.eventEndDate then return false end
  return true
end

function EventSchedule:DateLabel(record)
  if not record.eventStartDate and not record.eventEndDate then return nil end
  local today = self:Today()
  if record.eventStartDate and today and today < record.eventStartDate then
    return "Starts " .. DisplayDate(record.eventStartDate)
  end
  if not record.eventEndDate then return nil end
  if today and today > record.eventEndDate then
    return "Ended " .. DisplayDate(record.eventEndDate)
  end
  return "Available through " .. DisplayDate(record.eventEndDate)
end
