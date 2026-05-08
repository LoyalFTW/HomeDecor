local ADDON, NS = ...

NS.Systems = NS.Systems or {}
NS.Systems.Changelog = NS.Systems.Changelog or {}
local CLog = NS.Systems.Changelog

CLog.CURRENT_VERSION = C_AddOns.GetAddOnMetadata(ADDON, "Version") or ""

local AUTO_POPUP_IMPORTANCE = {
  major = true,
}

local function NormalizeImportance(value)
  local normalized = type(value) == "string" and value:lower() or ""
  if normalized == "major" or normalized == "minor" or normalized == "silent" then
    return normalized
  end
  return "major"
end

local function Ensure()
  if not NS.db or not NS.db.profile then return nil end
  local p = NS.db.profile
  p.changelog = p.changelog or {}
  if p.changelog.autoOpen == nil then p.changelog.autoOpen = true end
  if p.changelog.lastSeenVersion == nil then p.changelog.lastSeenVersion = "" end
  return p.changelog
end

function CLog:IsAutoOpenEnabled()
  local s = Ensure()
  if not s then return true end
  return s.autoOpen and true or false
end

function CLog:SetAutoOpen(v)
  local s = Ensure()
  if s then s.autoOpen = v and true or false end
end

function CLog:IsNewVersion()
  local s = Ensure()
  if not s then return false end
  return s.lastSeenVersion ~= self.CURRENT_VERSION
end

function CLog:GetMeta()
  local meta = _G.HomeDecor_ChangelogMeta
  if type(meta) ~= "table" then return {} end
  return meta
end

function CLog:GetImportance()
  local meta = self:GetMeta()
  return NormalizeImportance(meta.importance)
end

function CLog:ShouldAutoPopup()
  local s = Ensure()
  if not s or not s.autoOpen or not self:IsNewVersion() then return false end
  return AUTO_POPUP_IMPORTANCE[self:GetImportance()] == true
end

function CLog:MarkSeen()
  local s = Ensure()
  if s then s.lastSeenVersion = self.CURRENT_VERSION end
end

function CLog:GetText()
  return _G.HomeDecor_Changelog or ""
end

function CLog:TryAutoPopup()
  if not self:IsNewVersion() then return end
  if not self:ShouldAutoPopup() then
    self:MarkSeen()
    return
  end
  if NS.UI and NS.UI.ShowChangelogPopup then
    NS.UI:ShowChangelogPopup(false)
  end
end
