local _, NS = ...

local locales = NS.Locales or {}
local english = locales.enUS or {}
local active = locales[GetLocale()] or english

NS.L = setmetatable(active, { __index = english })

function NS.LT(value)
  if type(value) ~= "string" then return value end
  return active[value] or english[value] or value
end

function NS.LF(value, ...)
  return string.format(NS.LT(value), ...)
end
