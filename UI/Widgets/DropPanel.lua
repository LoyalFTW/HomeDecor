local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.DropPanel = NS.UI.DropPanel or {}

local DropPanel  = NS.UI.DropPanel
local C          = NS.UI.Controls
local T          = NS.UI.Theme and NS.UI.Theme.colors or {}
local Navigation = NS.UI.Navigation

local function ResolveMobs(src)
  if not src then return nil end
  if src.mobSet and src._mobSets then return src._mobSets[src.mobSet] end
  if src.mobs then return src.mobs end
end

local function GetDropList(it)
  if not it or not it.source then return nil end
  local src = it.source

  local mobs = ResolveMobs(src)
  if mobs then
    local out = {}
    for npcID, mob in pairs(mobs) do
      if mob and mob.name and mob.worldmap then
        out[#out+1] = {npcID=npcID,name=mob.name,worldmap=mob.worldmap}
      end
    end
    table.sort(out, function(a,b) return tostring(a.name) < tostring(b.name) end)
    return out
  end

  if src.npcID and src.npc and src.worldmap then
    return {{npcID=src.npcID,name=src.npc,worldmap=src.worldmap}}
  end
end

local function EnsureBadge(frame)
  if frame._dropBadge then return frame._dropBadge end
  local b = CreateFrame("Button", nil, frame, "BackdropTemplate")
  b:SetFrameLevel(frame:GetFrameLevel() + 10)
  b:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
  if C and C.Backdrop then C:Backdrop(b, T.row, T.border) end
  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  b.text:SetPoint("CENTER")
  frame._dropBadge = b
  return b
end

function DropPanel:GetCount(it)
  local l = GetDropList(it)
  return l and #l or 0
end

function DropPanel:AttachBadge(frame, it, mode)
  local list = GetDropList(it)
  if not frame or not list then return end
  local b = EnsureBadge(frame)
  b:ClearAllPoints()
  if mode == "list" and frame.text then b:SetPoint("LEFT", frame.text, "RIGHT", 8, 0)
  else b:SetPoint("BOTTOMRIGHT", -6, 6) end
  b:SetSize(80, 16)
  b.text:SetText("Drops (" .. #list .. ")")
  b:Show()
  b:SetScript("OnClick", function() DropPanel:ShowForItem(it, frame) end)
end

function DropPanel:ShowForItem(it, anchor)
  local list = GetDropList(it)
  if not list then return end

  if not self._frame then
    local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(200)
    f:SetSize(260, 220)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    if C and C.Backdrop then C:Backdrop(f, T.panel, T.border) end

    f:SetPropagateKeyboardInput(true)
    f:SetScript("OnKeyDown", function(self, key) if key == "ESCAPE" then self:Hide() end end)
    f:SetScript("OnLeave", function(self)
      C_Timer.After(0.25, function()
        if not MouseIsOver(self) then self:Hide() end
      end)
    end)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 12, -10)
    f.rows = {}
    self._frame = f
  end

  local f = self._frame
  f.title:SetText("Drops From (" .. #list .. ")")

  for i, m in ipairs(list) do
    local r = f.rows[i]
    if not r then
      r = CreateFrame("Button", nil, f)
      r:SetSize(220, 18)
      r:SetPoint("TOPLEFT", 12, -30 - (i - 1) * 22)
      r:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
      r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      r.text:SetPoint("LEFT")

      r:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(self._mobName or "", 1, 0.82, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click: Open Map", 0.8, 0.8, 0.8)
        GameTooltip:Show()
      end)
      r:SetScript("OnLeave", function() GameTooltip:Hide() end)
      r:SetScript("OnClick", function(self)
        if Navigation and self._mobMap then
          Navigation:AddWaypoint({ title = self._mobName }, { source = { worldmap = self._mobMap } })
        end
      end)

      f.rows[i] = r
    end

    r._mobName = m.name
    r._mobMap  = m.worldmap

    r.text:SetText("• " .. (m.name or ""))
    r:Show()
  end

  for i = #list + 1, #f.rows do f.rows[i]:Hide() end

  f:ClearAllPoints()
  if anchor then f:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 10, 0) else f:SetPoint("CENTER") end
  f:Show()
end

return DropPanel
