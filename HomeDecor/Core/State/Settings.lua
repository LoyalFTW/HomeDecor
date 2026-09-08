local _, NS = ...

local Settings = {}
NS.Systems.Settings = Settings

function Settings:Get(key)
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.settings = profile.settings or {}
  if profile.settings[key] == nil then return true end
  return profile.settings[key] == true
end

function Settings:Set(key, value)
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return false end
  profile.settings = profile.settings or {}
  profile.settings[key] = value == true
  return true
end

function Settings:GetValue(key, default)
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return default end
  profile.settings = profile.settings or {}
  local value = profile.settings[key]
  if value == nil then return default end
  return value
end

function Settings:SetValue(key, value)
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return false end
  profile.settings = profile.settings or {}
  profile.settings[key] = value
  return true
end
