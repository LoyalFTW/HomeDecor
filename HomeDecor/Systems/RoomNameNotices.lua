local ADDON, NS = ...

local Architect = NS.Systems and NS.Systems.Architect
if not Architect then return end

local RoomNameNotices = {}
NS.Systems.RoomNameNotices = RoomNameNotices

local function insideHouse()
  if not (_G.C_Housing and type(_G.C_Housing.IsInsideHouse) == "function") then return false end
  local ok, result = pcall(_G.C_Housing.IsInsideHouse)
  return ok and result and true or false
end

local function playerPosition()
  if type(_G.UnitPosition) ~= "function" then return nil end
  local posY, posX, posZ, mapID = _G.UnitPosition("player")
  if type(posX) ~= "number" or type(posY) ~= "number" or mapID == nil then return nil end
  return posX, posY, tonumber(posZ), mapID
end

local function stripFloorPrefix(name)
  return (tostring(name or ""):gsub("^Floor%s+%d+%s+%-%s+", ""))
end

local function templateName(room)
  for _, template in ipairs(Architect:GetRoomTemplates() or {}) do
    if template.key == room.templateKey then return tostring(template.name or "") end
  end
end

local function displayName(room)
  if not room then return nil end
  local name = stripFloorPrefix(room.name)
  if name == "" or name == templateName(room) then return nil end
  return name
end

local function isCapturedRoom(room)
  return room and room.capture and room.capture.roomGUID ~= nil
end

local function isCapturedLayout(layout)
  for _, room in ipairs((layout and layout.rooms) or {}) do
    if isCapturedRoom(room) then return true end
  end
  return false
end

local function boundsContain(bounds, x, y, z, mapID)
  if type(bounds) ~= "table" or tostring(bounds.mapID) ~= tostring(mapID) then return false end
  if x < bounds.minX or x > bounds.maxX or y < bounds.minY or y > bounds.maxY then return false end
  if z and bounds.minZ and bounds.maxZ and (z < bounds.minZ or z > bounds.maxZ) then return false end
  return true
end

local function mappedRoomAtPosition(layout, x, y, z, mapID)
  local found, foundArea
  for _, room in ipairs((layout and layout.rooms) or {}) do
    local bounds = room.worldBounds
    if boundsContain(bounds, x, y, z, mapID) then
      local area = math.max(0.01, (bounds.maxX - bounds.minX) * (bounds.maxY - bounds.minY))
      if not foundArea or area < foundArea then
        found, foundArea = room, area
      end
    end
  end
  return found
end

local function createBanner()
  local frame = CreateFrame("Frame", "HomeDecorRoomNameBanner", UIParent)
  frame:SetSize(620, 72)
  frame:SetPoint("TOP", UIParent, "TOP", 0, -150)
  frame:SetFrameStrata("DIALOG")
  frame:SetAlpha(0)
  frame:Hide()

  local topLine = frame:CreateTexture(nil, "ARTWORK")
  topLine:SetColorTexture(0.90, 0.62, 0.12, 0.85)
  topLine:SetPoint("TOP", 0, -6)
  topLine:SetSize(300, 1)

  local bottomLine = frame:CreateTexture(nil, "ARTWORK")
  bottomLine:SetColorTexture(0.90, 0.62, 0.12, 0.85)
  bottomLine:SetPoint("BOTTOM", 0, 6)
  bottomLine:SetSize(300, 1)

  local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  text:SetPoint("CENTER")
  text:SetWidth(600)
  text:SetJustifyH("CENTER")
  text:SetTextColor(1, 0.82, 0.28)
  text:SetShadowColor(0, 0, 0, 0.95)
  text:SetShadowOffset(2, -2)
  frame.text = text

  local animation = frame:CreateAnimationGroup()
  local fadeIn = animation:CreateAnimation("Alpha")
  fadeIn:SetFromAlpha(0)
  fadeIn:SetToAlpha(1)
  fadeIn:SetDuration(0.22)
  fadeIn:SetOrder(1)

  local hold = animation:CreateAnimation("Alpha")
  hold:SetFromAlpha(1)
  hold:SetToAlpha(1)
  hold:SetDuration(2.2)
  hold:SetOrder(2)

  local fadeOut = animation:CreateAnimation("Alpha")
  fadeOut:SetFromAlpha(1)
  fadeOut:SetToAlpha(0)
  fadeOut:SetDuration(0.75)
  fadeOut:SetOrder(3)

  animation:SetScript("OnFinished", function()
    frame:SetAlpha(0)
    frame:Hide()
  end)
  frame.animation = animation
  return frame
end

function RoomNameNotices:Show(name)
  if not name or name == "" then return end
  self.banner = self.banner or createBanner()
  self.banner.animation:Stop()
  self.banner.text:SetText(name)
  self.banner:SetAlpha(0)
  self.banner:Show()
  self.banner.animation:Play()
end

function RoomNameNotices:GetMappingState(room, layout)
  if not isCapturedRoom(room) then return "unavailable" end
  local pending = self.pendingCorner
  if pending and pending.roomID == room.id and pending.layoutID == (layout and layout.id) then
    return "first"
  end
  return room.worldBounds and "mapped" or "unmapped"
end

function RoomNameNotices:MarkRoom(room, layout)
  if not (room and layout) then return false, "Select a room first." end
  if not isCapturedRoom(room) then return false, "Room mapping is available for captured houses only." end
  if not insideHouse() then return false, "Enter the house before mapping a room." end

  local x, y, z, mapID = playerPosition()
  if not x then return false, "Your position is not available yet." end

  local pending = self.pendingCorner
  if pending and pending.roomID == room.id and pending.layoutID == layout.id then
    if tostring(pending.mapID) ~= tostring(mapID) then
      self.pendingCorner = nil
      return false, "Both corners must be on the same map. Start again."
    end
    if math.abs(x - pending.x) < 0.5 and math.abs(y - pending.y) < 0.5 then
      return false, "Move to the opposite corner before saving it."
    end

    room.worldBounds = {
      mapID = mapID,
      minX = math.min(pending.x, x),
      maxX = math.max(pending.x, x),
      minY = math.min(pending.y, y),
      maxY = math.max(pending.y, y),
      minZ = pending.z and z and (math.min(pending.z, z) - 4) or nil,
      maxZ = pending.z and z and (math.max(pending.z, z) + 4) or nil,
    }
    self.pendingCorner = nil
    self.currentRoomID = nil
    local name = displayName(room)
    if name then self:Show(name) end
    return true, "Room mapped."
  end

  self.pendingCorner = {
    roomID = room.id,
    layoutID = layout.id,
    x = x,
    y = y,
    z = z,
    mapID = mapID,
  }
  return true, "First corner saved. Move to the opposite corner."
end

function RoomNameNotices:CheckCurrentRoom()
  if not insideHouse() then
    self.currentRoomID = nil
    return
  end

  local x, y, z, mapID = playerPosition()
  if not x then return end
  local layout = Architect:GetActiveLayout()
  if not isCapturedLayout(layout) then
    self.currentRoomID = nil
    return
  end
  local room = mappedRoomAtPosition(layout, x, y, z, mapID)
  local roomID = room and room.id or nil
  if roomID == self.currentRoomID then return end
  self.currentRoomID = roomID

  local name = displayName(room)
  if name then self:Show(name) end
end

local watcher = CreateFrame("Frame")
local elapsed = 0
watcher:SetScript("OnUpdate", function(_, delta)
  elapsed = elapsed + delta
  if elapsed < 0.25 then return end
  elapsed = 0
  RoomNameNotices:CheckCurrentRoom()
end)

for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA" }) do
  NS.SafeRegisterEvent(RoomNameNotices, event, function()
    RoomNameNotices.currentRoomID = nil
  end)
end

return RoomNameNotices
