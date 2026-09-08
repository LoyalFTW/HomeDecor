local _, NS = ...

local Changelog = {}
NS.Systems.Changelog = Changelog

local autoOpenImportance = {
  major = true,
}

local function NormalizeImportance(value)
  local normalized = type(value) == "string" and value:lower() or ""
  if normalized == "major" or normalized == "minor" or normalized == "silent" then
    return normalized
  end
  return "major"
end

local function State()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.changelog = type(profile.changelog) == "table" and profile.changelog or {}
  if profile.changelog.autoOpen == nil then profile.changelog.autoOpen = true end
  if type(profile.changelog.lastSeenVersion) ~= "string" then profile.changelog.lastSeenVersion = "" end
  return profile.changelog
end

function Changelog:GetCurrentVersion()
  return C_AddOns.GetAddOnMetadata(NS.Name, "Version") or ""
end

function Changelog:GetMeta()
  local meta = _G.HomeDecor_ChangelogMeta
  if type(meta) ~= "table" then return {} end
  return meta
end

function Changelog:GetImportance()
  return NormalizeImportance(self:GetMeta().importance)
end

function Changelog:GetText()
  return type(_G.HomeDecor_Changelog) == "string" and _G.HomeDecor_Changelog or ""
end

function Changelog:IsNewVersion()
  local state = State()
  return state and state.lastSeenVersion ~= self:GetCurrentVersion() or false
end

function Changelog:IsAutoOpenEnabled()
  local state = State()
  if not state then return true end
  return state.autoOpen ~= false
end

function Changelog:SetAutoOpen(enabled)
  local state = State()
  if state then state.autoOpen = enabled == true end
end

function Changelog:MarkSeen()
  local state = State()
  if state then state.lastSeenVersion = self:GetCurrentVersion() end
end

function Changelog:ShouldAutoOpen()
  return self:IsAutoOpenEnabled() and self:IsNewVersion() and autoOpenImportance[self:GetImportance()] == true
end

function Changelog:TryAutoOpen(anchor)
  if self.autoOpenChecked then return end
  self.autoOpenChecked = true
  if not self:IsNewVersion() then return end
  if not self:ShouldAutoOpen() then
    self:MarkSeen()
    return
  end
  if NS.UI.WhatsNew then NS.UI.WhatsNew:Show(anchor) end
end

return Changelog
