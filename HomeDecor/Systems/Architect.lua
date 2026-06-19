local ADDON, NS = ...

NS.Systems = NS.Systems or {}

local Architect = {}
NS.Systems.Architect = Architect

local tinsert = table.insert
local sort = table.sort
local tonumber = tonumber
local tostring = tostring

local PALETTE = {
  { 0.93, 0.68, 0.20, 0.34 },
  { 0.35, 0.72, 0.95, 0.30 },
  { 0.44, 0.86, 0.52, 0.30 },
  { 0.88, 0.42, 0.56, 0.30 },
  { 0.68, 0.55, 0.92, 0.30 },
  { 0.90, 0.86, 0.58, 0.30 },
}

local C_N = { { 0.5, 0.0, "N" } }
local C_S = { { 0.5, 1.0, "S" } }
local C_E = { { 1.0, 0.5, "E" } }
local C_W = { { 0.0, 0.5, "W" } }
local C_NS = { { 0.5, 0.0, "N" }, { 0.5, 1.0, "S" } }
local C_EW = { { 0.0, 0.5, "W" }, { 1.0, 0.5, "E" } }
local C_ALL = { { 0.5, 0.0, "N" }, { 1.0, 0.5, "E" }, { 0.5, 1.0, "S" }, { 0.0, 0.5, "W" } }
local DIR_ORDER = { N = 0, E = 1, S = 2, W = 3 }
local DIR_FROM_INDEX = { [0] = "N", [1] = "E", [2] = "S", [3] = "W" }
local OPPOSITE_DIR = { N = "S", S = "N", E = "W", W = "E" }
local ART = "Interface\\AddOns\\HomeDecor\\Media\\Architect\\"

Architect.RoomTemplates = {
  { key = "entry",         name = "Entry",                  shape = "entry",      cost = 0,  connections = C_N,   w = 2, h = 1, color = 1, art = ART.."entry", icon = "Interface\\Icons\\INV_Misc_Home", atlasShape = "entry" },
  { key = "closet",        name = "Closet",                 shape = "rect",       cost = 1,  connections = C_NS,  w = 2, h = 1, color = 2, art = ART.."closet", icon = "Interface\\Icons\\INV_Chest_Cloth_17", atlasShape = "closet_xs" },
  { key = "squareTiny",    name = "Square Room (Tiny)",     shape = "rect",       cost = 2,  connections = C_ALL, w = 2, h = 2, color = 1, art = ART.."squareTiny", icon = "Interface\\Icons\\INV_Misc_Rune_01", atlasShape = "square_xs" },
  { key = "hallway",       name = "Hallway",                shape = "hall",       cost = 3,  connections = C_NS,  w = 2, h = 4, color = 2, art = ART.."hallway", icon = "Interface\\Icons\\INV_Misc_Map_01", atlasShape = "hallway" },
  { key = "lRoom",         name = "L-Shaped Room",          shape = "lRight",     cost = 3,  connections = { { 0.5, 0.0, "N" }, { 1.0, 0.5, "E" } }, w = 3, h = 3, color = 4, art = ART.."lRoom", icon = "Interface\\Icons\\INV_Misc_CorneredBox", atlasShape = "l_shape" },
  { key = "tRoom",         name = "T-Shaped Room",          shape = "t",          cost = 3,  connections = { { 0.5, 1.0, "S" }, { 1.0, 0.5, "E" }, { 0.0, 0.5, "W" } }, w = 4, h = 3, color = 5, art = ART.."tRoom", icon = "Interface\\Icons\\INV_Misc_Token_ArgentDawn3", atlasShape = "t_shape" },
  { key = "crossRoom",     name = "Cross-Shaped Room",      shape = "cross",      cost = 4,  connections = C_ALL, w = 4, h = 4, color = 5, art = ART.."crossRoom", icon = "Interface\\Icons\\Spell_Holy_PowerWordBarrier", atlasShape = "cross_shape" },
  { key = "octagonSmall",  name = "Octagon Room (Small)",   shape = "octagon",    cost = 4,  connections = C_ALL, w = 4, h = 4, color = 5, art = ART.."octagonSmall", icon = "Interface\\Icons\\INV_Misc_Gem_01", atlasShape = "octagon_s" },
  { key = "squareSmall",   name = "Square Room (Small)",    shape = "rect",       cost = 5,  connections = C_ALL, w = 4, h = 4, color = 1, art = ART.."squareSmall", icon = "Interface\\Icons\\INV_Misc_Rune_02", atlasShape = "square_s" },
  { key = "stairEmpty",    name = "Stairwell Room (Empty)", shape = "stair",      cost = 6,  connections = C_ALL, w = 4, h = 4, color = 2, art = ART.."stairEmpty", icon = "Interface\\Icons\\Ability_Mount_Jumping", atlasShape = "tall_room" },
  { key = "stairLeft",     name = "Stairwell (Left)",       shape = "stairLeft",  cost = 7,  connections = C_W,   w = 4, h = 4, color = 2, art = ART.."stairLeft", icon = "Interface\\Icons\\Ability_Mount_Jumping", atlasShape = "staircase" },
  { key = "stairRight",    name = "Stairwell (Right)",      shape = "stairRight", cost = 7,  connections = C_E,   w = 4, h = 4, color = 2, art = ART.."stairRight", icon = "Interface\\Icons\\Ability_Mount_Jumping", atlasShape = "staircase_mirror" },
  { key = "gardenDay",     name = "Daylight Circle Room",   shape = "gardenDay",  cost = 8,  connections = C_N,   w = 8, h = 8, color = 3, art = ART.."gardenDay", icon = "Interface\\Icons\\Spell_Nature_Sun", atlasShape = "circle_daylight" },
  { key = "gardenEve",     name = "Evening Circle Room",    shape = "gardenEve",  cost = 8,  connections = C_N,   w = 8, h = 8, color = 2, art = ART.."gardenEve", icon = "Interface\\Icons\\INV_Misc_Moonstone_01", atlasShape = "circle_evening" },
  { key = "octagonMedium", name = "Octagon Room (Medium)",  shape = "octagon",    cost = 8,  connections = C_ALL, w = 6, h = 6, color = 5, art = ART.."octagonMedium", icon = "Interface\\Icons\\INV_Misc_Gem_02", atlasShape = "octagon_m" },
  { key = "squareMedium",  name = "Square Room (Medium)",   shape = "rect",       cost = 12, connections = C_ALL, w = 6, h = 6, color = 1, art = ART.."squareMedium", icon = "Interface\\Icons\\INV_Misc_Rune_03", atlasShape = "square_m" },
  { key = "octagonLarge",  name = "Octagon Room (Large)",   shape = "octagon",    cost = 16, connections = C_ALL, w = 8, h = 8, color = 5, art = ART.."octagonLarge", icon = "Interface\\Icons\\INV_Misc_Gem_03", atlasShape = "octagon_l" },
  { key = "squareLarge",   name = "Square Room (Large)",    shape = "rect",       cost = 20, connections = C_ALL, w = 8, h = 8, color = 1, art = ART.."squareLarge", icon = "Interface\\Icons\\INV_Misc_Rune_04", atlasShape = "square_l" },
}

local TEMPLATE_BY_KEY = {}
local TEMPLATE_BY_ATLAS_SHAPE = {}
for _, template in ipairs(Architect.RoomTemplates) do
  TEMPLATE_BY_KEY[template.key] = template
  if template.atlasShape then TEMPLATE_BY_ATLAS_SHAPE[template.atlasShape] = template end
end

local ROOM_TYPE_ID_BY_KEY = {
  entry = 0,
  closet = 3,
  squareTiny = 7,
  hallway = 2,
  lRoom = 8,
  tRoom = 6,
  crossRoom = 13,
  octagonSmall = 14,
  squareSmall = 1,
  stairEmpty = 48,
  stairLeft = 10,
  stairRight = 50,
  gardenDay = 223,
  gardenEve = 233,
  octagonMedium = 9,
  squareMedium = 11,
  octagonLarge = 15,
  squareLarge = 12,
}
local TEMPLATE_KEY_BY_ROOM_TYPE_ID = {}
local ROOM_TYPE_ID_BY_NAME = {}
for key, id in pairs(ROOM_TYPE_ID_BY_KEY) do
  TEMPLATE_KEY_BY_ROOM_TYPE_ID[id] = key
  if TEMPLATE_BY_KEY[key] then ROOM_TYPE_ID_BY_NAME[string.lower(TEMPLATE_BY_KEY[key].name)] = id end
end
TEMPLATE_KEY_BY_ROOM_TYPE_ID[46] = "entry"
local FLOORPLAN_COORD_SCALE = 32

local function trim(s)
  if type(s) ~= "string" then return "" end
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function ensureProfile()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end

  profile.architect = profile.architect or {}
  local db = profile.architect
  db.nextLayoutID = tonumber(db.nextLayoutID) or 2
  db.nextRoomID = tonumber(db.nextRoomID) or 2
  db.nextItemID = tonumber(db.nextItemID) or 1
  db.layouts = db.layouts or {}
  db.capture = db.capture or { auto = true, history = {} }

  if #db.layouts == 0 then
    db.layouts[1] = {
      id = 1,
      name = "First Home",
      gridW = 24,
      gridH = 16,
      budgetLimit = 250,
      yardBudgetLimit = 100,
      rooms = {
        {
          id = 1,
          name = "Great Room",
          design = "Welcome",
          x = 2,
          y = 2,
          w = 8,
          h = 5,
          color = 1,
          budgetLimit = 40,
          items = {},
        },
      },
    }
  end

  db.activeLayoutID = tonumber(db.activeLayoutID) or db.layouts[1].id
  return db
end

local function findLayout(db, id)
  if not db then return nil end
  id = tonumber(id or db.activeLayoutID)
  for i = 1, #db.layouts do
    if tonumber(db.layouts[i].id) == id then return db.layouts[i], i end
  end
  return db.layouts[1], 1
end

local function findRoom(layout, id)
  if not layout then return nil end
  id = tonumber(id)
  for i = 1, #(layout.rooms or {}) do
    if tonumber(layout.rooms[i].id) == id then return layout.rooms[i], i end
  end
end

local function applyRotationFootprint(room)
  if not room then return end
  local template = room.templateKey and TEMPLATE_BY_KEY[room.templateKey]
  if not template then return end
  local baseW, baseH = tonumber(template.w), tonumber(template.h)
  if not (baseW and baseH) or baseW == baseH then return end
  local turns = math.floor(((tonumber(room.rotation) or 0) % 360) / 90 + 0.5) % 4
  local cx = (tonumber(room.x) or 0) + ((tonumber(room.w) or baseW) / 2)
  local cy = (tonumber(room.y) or 0) + ((tonumber(room.h) or baseH) / 2)
  if turns % 2 == 1 then
    room.w, room.h = baseH, baseW
  else
    room.w, room.h = baseW, baseH
  end
  room.x = cx - (room.w / 2)
  room.y = cy - (room.h / 2)
end

local function clampRoom(layout, room)
  if not layout or not room then return end
  applyRotationFootprint(room)
  room.w = math.max(1, tonumber(room.w) or 4)
  room.h = math.max(1, tonumber(room.h) or 3)
  room.x = tonumber(room.x) or 0
  room.y = tonumber(room.y) or 0
  layout.gridW = math.max(24, tonumber(layout.gridW) or 24, math.ceil(room.x + room.w + 8))
  layout.gridH = math.max(16, tonumber(layout.gridH) or 16, math.ceil(room.y + room.h + 8))
end

local function normalizeLayout(layout)
  if not layout or type(layout.rooms) ~= "table" then return end
  local minX, minY, maxX, maxY = 999999, 999999, 0, 0
  for _, room in ipairs(layout.rooms or {}) do
    applyRotationFootprint(room)
    room.w = math.max(1, tonumber(room.w) or 4)
    room.h = math.max(1, tonumber(room.h) or 3)
    room.x = tonumber(room.x) or 0
    room.y = tonumber(room.y) or 0
    minX = math.min(minX, room.x)
    minY = math.min(minY, room.y)
    maxX = math.max(maxX, room.x + room.w)
    maxY = math.max(maxY, room.y + room.h)
  end
  if minX == 999999 then
    layout.gridW = math.max(24, tonumber(layout.gridW) or 24)
    layout.gridH = math.max(16, tonumber(layout.gridH) or 16)
    return
  end
  local shiftX = minX < 2 and (2 - minX) or 0
  local shiftY = minY < 2 and (2 - minY) or 0
  if shiftX ~= 0 or shiftY ~= 0 then
    for _, room in ipairs(layout.rooms or {}) do
      room.x = room.x + shiftX
      room.y = room.y + shiftY
    end
    maxX = maxX + shiftX
    maxY = maxY + shiftY
  end
  layout.gridW = math.max(24, math.ceil(maxX + 8))
  layout.gridH = math.max(16, math.ceil(maxY + 8))
end

local function updateLayoutGridFromRooms(layout)
  if not layout or type(layout.rooms) ~= "table" then return end
  local minX, minY, maxX, maxY = 999999, 999999, -999999, -999999
  for _, room in ipairs(layout.rooms or {}) do
    room.w = math.max(1, tonumber(room.w) or 4)
    room.h = math.max(1, tonumber(room.h) or 3)
    room.x = tonumber(room.x) or 0
    room.y = tonumber(room.y) or 0
    minX = math.min(minX, room.x)
    minY = math.min(minY, room.y)
    maxX = math.max(maxX, room.x + room.w)
    maxY = math.max(maxY, room.y + room.h)
  end
  if minX == 999999 then
    layout.gridW = math.max(24, tonumber(layout.gridW) or 24)
    layout.gridH = math.max(16, tonumber(layout.gridH) or 16)
    return
  end
  layout.gridW = math.max(24, math.ceil((maxX - minX) + 8))
  layout.gridH = math.max(16, math.ceil((maxY - minY) + 8))
end

local function itemKey(it)
  if not it then return nil end
  local src = it.source or {}
  return tonumber(it.decorID or it.recordID or src.decorID or it.itemID or src.itemID or src.id or it.id)
end

local function itemName(it, decorID)
  if type(it) == "table" then
    local n = trim(it.title or it.name or (it.source and it.source.name))
    if n ~= "" then return n end
  end
  local VD = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
  if VD and VD.GetDecorName and decorID then
    local n = VD.GetDecorName(decorID)
    if n and n ~= "" then return n end
  end
  return decorID and ("Decor " .. tostring(decorID)) or "Decor"
end

local function itemIcon(it, decorID, itemID)
  local VD = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
  if VD and VD.GetDecorIcon and decorID then
    local icon = VD.GetDecorIcon(decorID)
    if icon then return icon end
  end
  if itemID and C_Item and C_Item.GetItemIconByID then
    local ok, icon = pcall(C_Item.GetItemIconByID, itemID)
    if ok and icon then return icon end
  end
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function visitNode(node, out, seen)
  if type(node) ~= "table" then return end
  if node.decorID or node.itemID or (node.source and (node.source.itemID or node.source.id)) then
    local key = itemKey(node)
    if key and not seen[key] then
      seen[key] = true
      local itemID = node.itemID or (node.source and node.source.itemID)
      out[#out + 1] = {
        decorID = tonumber(node.decorID or key),
        itemID = tonumber(itemID),
        name = itemName(node, tonumber(node.decorID or key)),
        icon = itemIcon(node, tonumber(node.decorID or key), tonumber(itemID)),
        sourceType = node.source and node.source.type,
        raw = node,
      }
    end
    return
  end
  if node.items and type(node.items) == "table" then
    visitNode(node.items, out, seen)
  end
  for _, child in pairs(node) do
    if type(child) == "table" then visitNode(child, out, seen) end
  end
end

function Architect:GetDB()
  return ensureProfile()
end

function Architect:GetActiveLayout()
  local db = ensureProfile()
  return findLayout(db)
end

function Architect:SetActiveLayout(id)
  local db = ensureProfile()
  local layout = findLayout(db, id)
  if layout then db.activeLayoutID = layout.id end
  return layout
end

function Architect:RenameLayout(id, name)
  local db = ensureProfile()
  local layout = findLayout(db, id)
  name = trim(name)
  if not layout or name == "" then return nil end
  layout.name = name
  return layout
end

function Architect:CreateLayout(name)
  local db = ensureProfile()
  if not db then return nil end
  local id = db.nextLayoutID
  db.nextLayoutID = id + 1
  local layout = {
    id = id,
    name = trim(name) ~= "" and trim(name) or ("Layout " .. tostring(id)),
    gridW = 24,
    gridH = 16,
    budgetLimit = 250,
    yardBudgetLimit = 100,
    rooms = {},
  }
  db.layouts[#db.layouts + 1] = layout
  db.activeLayoutID = id
  return layout
end

function Architect:DuplicateLayout(id)
  local db = ensureProfile()
  local src = findLayout(db, id)
  if not src then return nil end
  local nid = db.nextLayoutID
  db.nextLayoutID = nid + 1
  local copy = CopyTable and CopyTable(src) or {}
  if not CopyTable then
    for k, v in pairs(src) do copy[k] = v end
    copy.rooms = {}
    for i, r in ipairs(src.rooms or {}) do
      copy.rooms[i] = {}
      for rk, rv in pairs(r) do copy.rooms[i][rk] = rv end
      copy.rooms[i].items = {}
      for ii, item in ipairs(r.items or {}) do
        copy.rooms[i].items[ii] = {}
        for ik, iv in pairs(item) do copy.rooms[i].items[ii][ik] = iv end
      end
    end
  end
  copy.id = nid
  copy.name = (src.name or "Layout") .. " Copy"
  db.layouts[#db.layouts + 1] = copy
  db.activeLayoutID = nid
  return copy
end

function Architect:DeleteLayout(id)
  local db = ensureProfile()
  if not db or #db.layouts <= 1 then return false end
  local _, idx = findLayout(db, id)
  if not idx then return false end
  local deleteID = tonumber(id)
  local activeID = tonumber(db.activeLayoutID)
  table.remove(db.layouts, idx)
  if activeID and activeID ~= deleteID then
    db.activeLayoutID = activeID
  else
    local nextLayout = db.layouts[math.min(idx, #db.layouts)] or db.layouts[1]
    db.activeLayoutID = nextLayout and nextLayout.id or nil
  end
  return true
end

function Architect:AddRoom(layout, name, skipNormalize)
  local db = ensureProfile()
  layout = layout or findLayout(db)
  if not layout then return nil end
  local template = type(name) == "table" and name or nil
  if template and template.key then
    template = TEMPLATE_BY_KEY[template.key] or template
  end
  local id = db.nextRoomID
  db.nextRoomID = id + 1
  local idx = #(layout.rooms or {}) + 1
  layout.rooms = layout.rooms or {}
  local room = {
    id = id,
    name = template and template.name or (trim(name) ~= "" and trim(name) or ("Room " .. tostring(idx))),
    design = "",
    x = 1 + ((idx - 1) * 2) % 12,
    y = 1 + math.floor((idx - 1) / 6) * 2,
    w = template and template.w or 5,
    h = template and template.h or 4,
    color = template and template.color or (((idx - 1) % #PALETTE) + 1),
    shape = template and template.shape or "rect",
    templateKey = template and template.key or nil,
    cost = template and template.cost or 0,
    connections = template and CopyTable and CopyTable(template.connections) or (template and template.connections) or C_ALL,
    rotation = 0,
    art = template and template.art or nil,
    icon = template and template.icon or nil,
    budgetLimit = 30,
    items = {},
  }
  clampRoom(layout, room)
  layout.rooms[#layout.rooms + 1] = room
  if not skipNormalize then normalizeLayout(layout) end
  return room
end

function Architect:AddRoomAt(layout, name, x, y, floorNum)
  local room = self:AddRoom(layout, name, true)
  if not room then return nil end
  room.x = tonumber(x) or room.x
  room.y = tonumber(y) or room.y
  room.floor = tonumber(floorNum) or room.floor or 1
  room.capture = room.capture or {}
  room.capture.floor = room.floor
  clampRoom(layout, room)
  return room
end

function Architect:GetRoomTemplates()
  return self.RoomTemplates
end

function Architect:GetRoomCost(room)
  return tonumber(room and room.cost) or 0
end

local function rotateConnection(conn, turns)
  turns = (tonumber(turns) or 0) % 4
  local x, y, dir = tonumber(conn[1]) or 0.5, tonumber(conn[2]) or 0.5, conn[3] or "N"
  for _ = 1, turns do
    x, y = 1 - y, x
    dir = DIR_FROM_INDEX[((DIR_ORDER[dir] or 0) + 1) % 4]
  end
  return { x, y, dir }
end

local function adjustForFootprint(room, conn)
  local shape = room and room.shape
  if shape ~= "octagon" and shape ~= "gardenDay" and shape ~= "gardenEve" then return conn end
  local w, h = tonumber(room.w) or 1, tonumber(room.h) or 1
  local size = math.min(w, h)
  if w <= 0 or h <= 0 or size <= 0 then return conn end
  local ox, oy = (w - size) / 2, (h - size) / 2
  return {
    (ox + (conn[1] * size)) / w,
    (oy + (conn[2] * size)) / h,
    conn[3],
  }
end

local ROOM_CONNECTION_CACHE = setmetatable({}, { __mode = "k" })

function Architect:GetRoomConnections(room)
  if type(room) ~= "table" then return {} end
  local template = room.templateKey and TEMPLATE_BY_KEY[room.templateKey]
  local raw = (template and template.connections) or room.connections or C_ALL
  local turns = math.floor(((tonumber(room.rotation) or 0) % 360) / 90 + 0.5) % 4
  local width = tonumber(room.w) or 1
  local height = tonumber(room.h) or 1
  local cached = ROOM_CONNECTION_CACHE[room]
  if cached
    and cached.raw == raw
    and cached.turns == turns
    and cached.width == width
    and cached.height == height
    and cached.shape == room.shape
  then
    return cached.connections
  end

  local out = {}
  for i, conn in ipairs(raw) do
    out[i] = adjustForFootprint(room, rotateConnection(conn, turns))
  end
  ROOM_CONNECTION_CACHE[room] = {
    raw = raw,
    turns = turns,
    width = width,
    height = height,
    shape = room.shape,
    connections = out,
  }
  return out
end

function Architect:DeleteRoom(layout, roomID)
  local room, idx = findRoom(layout, roomID)
  if not room or not idx then return false end
  table.remove(layout.rooms, idx)
  normalizeLayout(layout)
  return true
end

function Architect:MoveRoom(layout, roomID, x, y)
  local room = findRoom(layout, roomID)
  if not room then return end
  room.x, room.y = tonumber(x) or room.x, tonumber(y) or room.y
  clampRoom(layout, room)
end

function Architect:ResizeRoom(layout, roomID, w, h)
  local room = findRoom(layout, roomID)
  if not room then return end
  room.w, room.h = tonumber(w) or room.w, tonumber(h) or room.h
  clampRoom(layout, room)
  normalizeLayout(layout)
end

function Architect:NormalizeLayout(layout)
  normalizeLayout(layout)
  return layout
end

function Architect:RotateRoom(layout, roomID, turns)
  local room = findRoom(layout, roomID)
  if not room then return end
  turns = tonumber(turns) or 1
  room.rotation = ((tonumber(room.rotation) or 0) + (turns * 90)) % 360
  applyRotationFootprint(room)
  clampRoom(layout, room)
  return room.rotation
end

function Architect:AddItemToRoom(room, info, qty)
  if not room or not info then return nil end
  room.items = room.items or {}
  local decorID = tonumber(info.decorID)
  for i = 1, #room.items do
    local item = room.items[i]
    if tonumber(item.decorID) == decorID then
      item.qty = math.max(1, tonumber(item.qty or 1) + (tonumber(qty) or 1))
      return item
    end
  end
  local db = ensureProfile()
  local id = db.nextItemID
  db.nextItemID = id + 1
  local item = {
    id = id,
    decorID = decorID,
    itemID = tonumber(info.itemID),
    name = info.name or itemName(info.raw, decorID),
    icon = info.icon,
    qty = math.max(1, tonumber(qty) or 1),
  }
  room.items[#room.items + 1] = item
  return item
end

function Architect:RemoveItemFromRoom(room, itemID)
  if not room then return false end
  for i = 1, #(room.items or {}) do
    if tonumber(room.items[i].id) == tonumber(itemID) then
      table.remove(room.items, i)
      return true
    end
  end
end

function Architect:RoomBudget(room)
  local used, missing, owned = 0, 0, 0
  local Collection = NS.Systems and NS.Systems.Collection
  for _, item in ipairs((room and room.items) or {}) do
    local qty = math.max(1, tonumber(item.qty) or 1)
    used = used + qty
    local isOwned = Collection and Collection.IsDecorCollected and Collection:IsDecorCollected(item.decorID)
    if isOwned then owned = owned + qty else missing = missing + qty end
  end
  return used, tonumber(room and room.budgetLimit) or 0, owned, missing
end

function Architect:LayoutBudget(layout)
  local used, roomLimit, owned, missing = 0, 0, 0, 0
  local roomCost = 0
  for _, room in ipairs((layout and layout.rooms) or {}) do
    local ru, rl, ro, rm = self:RoomBudget(room)
    used = used + ru
    roomLimit = roomLimit + rl
    owned = owned + ro
    missing = missing + rm
    roomCost = roomCost + self:GetRoomCost(room)
  end
  return used, tonumber(layout and layout.budgetLimit) or roomLimit, owned, missing, roomCost
end

function Architect:GetPaletteColor(index)
  return unpack(PALETTE[((tonumber(index) or 1) - 1) % #PALETTE + 1])
end

function Architect:SearchItems(query, limit)
  query = trim(query):lower()
  limit = limit or 30
  if query == "" then return {} end

  local DataLoader = NS.Systems and NS.Systems.DataLoader
  if DataLoader and DataLoader.EnsureAllCatalogData then
    pcall(function() DataLoader:EnsureAllCatalogData() end)
  end
  local DecorIndex = NS.Systems and NS.Systems.DecorIndex
  if DecorIndex and DecorIndex.Ensure then pcall(function() DecorIndex:Ensure() end) end

  local out, seen = {}, {}
  if DecorIndex then
    for decorID, entry in pairs(DecorIndex) do
      if type(decorID) == "number" and type(entry) == "table" then
        local node = entry.item or entry
        node.decorID = node.decorID or decorID
        visitNode(node, out, seen)
      end
    end
  end

  local categories = { "Achievements", "Quests", "Vendors", "Drops", "Professions", "PvP", "Saved Items" }
  for _, cat in ipairs(categories) do
    visitNode(NS.Data and NS.Data[cat], out, seen)
  end

  local filtered = {}
  for _, info in ipairs(out) do
    local hay = (info.name or ""):lower()
    if hay:find(query, 1, true) or tostring(info.decorID or "") == query or tostring(info.itemID or "") == query then
      filtered[#filtered + 1] = info
    end
  end
  sort(filtered, function(a, b) return tostring(a.name) < tostring(b.name) end)
  while #filtered > limit do table.remove(filtered) end
  return filtered
end

local function esc(s)
  s = tostring(s or "")
  s = s:gsub("%%", "%%%%"):gsub("|", "%%p"):gsub(";", "%%s"):gsub(",", "%%c"):gsub(":", "%%d")
  return s
end

local function unesc(s)
  s = tostring(s or "")
  s = s:gsub("%%d", ":"):gsub("%%c", ","):gsub("%%s", ";"):gsub("%%p", "|"):gsub("%%%%", "%%")
  return s
end

local function splitFixed(text, sep, maxParts)
  local out, start = {}, 1
  sep = sep or "|"
  while (not maxParts or #out < maxParts - 1) do
    local pos = string.find(text, sep, start, true)
    if not pos then break end
    out[#out + 1] = string.sub(text, start, pos - 1)
    start = pos + #sep
  end
  out[#out + 1] = string.sub(text, start)
  return out
end

local JSON_NULL = {}

local function jsonEscape(s)
  s = tostring(s or "")
  s = s:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
  return s
end

local function jsonEncode(v)
  local tv = type(v)
  if tv == "nil" or v == JSON_NULL then return "null" end
  if tv == "boolean" then return v and "true" or "false" end
  if tv == "number" then return tostring(v) end
  if tv == "string" then return "\"" .. jsonEscape(v) .. "\"" end
  if tv ~= "table" then return "null" end

  local isArray = true
  local n = 0
  for k in pairs(v) do
    if type(k) ~= "number" then isArray = false; break end
    if k > n then n = k end
  end

  local parts = {}
  if isArray then
    for i = 1, n do parts[#parts + 1] = jsonEncode(v[i]) end
    return "[" .. table.concat(parts, ",") .. "]"
  end

  for k, val in pairs(v) do
    parts[#parts + 1] = jsonEncode(tostring(k)) .. ":" .. jsonEncode(val)
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

local function jsonDecode(text)
  text = tostring(text or "")
  local i, len = 1, #text

  local function skip()
    while i <= len do
      local c = text:sub(i, i)
      if c ~= " " and c ~= "\n" and c ~= "\r" and c ~= "\t" then break end
      i = i + 1
    end
  end

  local parseValue

  local function parseString()
    i = i + 1
    local out = {}
    while i <= len do
      local c = text:sub(i, i)
      if c == "\"" then
        i = i + 1
        return table.concat(out)
      elseif c == "\\" then
        local n = text:sub(i + 1, i + 1)
        if n == "\"" or n == "\\" or n == "/" then out[#out + 1] = n
        elseif n == "b" then out[#out + 1] = "\b"
        elseif n == "f" then out[#out + 1] = "\f"
        elseif n == "n" then out[#out + 1] = "\n"
        elseif n == "r" then out[#out + 1] = "\r"
        elseif n == "t" then out[#out + 1] = "\t"
        elseif n == "u" then out[#out + 1] = "?" ; i = i + 4
        else out[#out + 1] = n end
        i = i + 2
      else
        out[#out + 1] = c
        i = i + 1
      end
    end
    error("Unterminated JSON string")
  end

  local function parseNumber()
    local start = i
    while i <= len and text:sub(i, i):match("[%d%+%-%e%E%.]") do i = i + 1 end
    return tonumber(text:sub(start, i - 1))
  end

  local function parseArray()
    local arr = {}
    i = i + 1
    skip()
    if text:sub(i, i) == "]" then i = i + 1; return arr end
    while i <= len do
      arr[#arr + 1] = parseValue()
      skip()
      local c = text:sub(i, i)
      if c == "]" then i = i + 1; return arr end
      if c ~= "," then error("Expected comma in JSON array") end
      i = i + 1
    end
    error("Unterminated JSON array")
  end

  local function parseObject()
    local obj = {}
    i = i + 1
    skip()
    if text:sub(i, i) == "}" then i = i + 1; return obj end
    while i <= len do
      skip()
      if text:sub(i, i) ~= "\"" then error("Expected JSON object key") end
      local key = parseString()
      skip()
      if text:sub(i, i) ~= ":" then error("Expected colon in JSON object") end
      i = i + 1
      obj[key] = parseValue()
      skip()
      local c = text:sub(i, i)
      if c == "}" then i = i + 1; return obj end
      if c ~= "," then error("Expected comma in JSON object") end
      i = i + 1
    end
    error("Unterminated JSON object")
  end

  parseValue = function()
    skip()
    local c = text:sub(i, i)
    if c == "\"" then return parseString() end
    if c == "{" then return parseObject() end
    if c == "[" then return parseArray() end
    if c == "t" and text:sub(i, i + 3) == "true" then i = i + 4; return true end
    if c == "f" and text:sub(i, i + 4) == "false" then i = i + 5; return false end
    if c == "n" and text:sub(i, i + 3) == "null" then i = i + 4; return JSON_NULL end
    return parseNumber()
  end

  local ok, value = pcall(parseValue)
  if not ok then return nil, value end
  return value
end

local function findTemplate(value)
  if not value then return nil end
  local id = tonumber(value)
  if id and TEMPLATE_KEY_BY_ROOM_TYPE_ID[id] then return TEMPLATE_BY_KEY[TEMPLATE_KEY_BY_ROOM_TYPE_ID[id]] end
  local v = tostring(value):lower()
  for _, template in ipairs(Architect.RoomTemplates) do
    if tostring(template.key):lower() == v or tostring(template.name):lower() == v then
      return template
    end
  end
end

local function baseRoomName(name)
  name = tostring(name or "")
  return (name:gsub("^Floor%s+%d+%s+%-%s+", ""))
end

local function isEntryTypeID(id)
  id = tonumber(id)
  return id == ROOM_TYPE_ID_BY_KEY.entry or id == 46
end

local function roomLooksLikeEntry(room)
  if not room then return false end
  if room.templateKey == "entry" then return true end
  if isEntryTypeID(room.roomTypeId or room.roomTypeID) then return true end
  return string.lower(baseRoomName(room.name)) == "entry"
end

local function externalLooksLikeEntry(room)
  if type(room) ~= "table" then return false end
  if isEntryTypeID(room.roomTypeId or room.roomTypeID or room.roomId or room.roomID) then return true end
  local template = findTemplate(room.templateKey or room.type or room.name)
  if template and template.key == "entry" then return true end
  return string.lower(baseRoomName(room.name or room.customName)) == "entry"
end

local function roomTypeIDForRoom(room)
  local id = tonumber(room and (room.roomTypeId or room.roomTypeID))
  if id then return isEntryTypeID(id) and ROOM_TYPE_ID_BY_KEY.entry or id end
  local key = room and room.templateKey
  id = key and ROOM_TYPE_ID_BY_KEY[key]
  if id then return id end
  local guid = room and room.capture and room.capture.roomGUID
  if guid then
    id = tonumber(tostring(guid):match("^Housing%-%d+%-(%d+)%-"))
    if id then return isEntryTypeID(id) and ROOM_TYPE_ID_BY_KEY.entry or id end
  end
  return ROOM_TYPE_ID_BY_NAME[string.lower(baseRoomName(room and room.name))] or 0
end

local function floorplanImportRotation(roomTypeID, rotation, template)
  rotation = tonumber(rotation) or 0
  if tonumber(roomTypeID) == ROOM_TYPE_ID_BY_KEY.hallway or (template and template.key == "hallway") then
    return (rotation + 90) % 360
  end
  return rotation
end

local function floorplanExportRotation(roomTypeID, rotation)
  rotation = tonumber(rotation) or 0
  if tonumber(roomTypeID) == ROOM_TYPE_ID_BY_KEY.hallway then
    return (rotation - 90) % 360
  end
  return rotation
end

local function importedRoomFloor(room)
  return tonumber(room and room.floor) or tonumber(room and room.capture and room.capture.floor) or 1
end

local function roomConnectionForCard(system, room, card)
  if not (system and room and card) then return nil end
  for _, conn in ipairs(system:GetRoomConnections(room) or {}) do
    if conn[3] == card then return conn end
  end
end

local function alignRoomForImport(system, anchor, moving, anchorCard, movingCard)
  local a = roomConnectionForCard(system, anchor, anchorCard)
  local m = roomConnectionForCard(system, moving, movingCard)
  if not (a and m) then return false end
  moving.x = math.floor((anchor.x or 0) + a[1] * (anchor.w or 1) - m[1] * (moving.w or 1) + 0.5)
  moving.y = math.floor((anchor.y or 0) + a[2] * (anchor.h or 1) - m[2] * (moving.h or 1) + 0.5)
  return true
end

local function overlapArea(a, b)
  local left = math.max(a.x or 0, b.x or 0)
  local right = math.min((a.x or 0) + (a.w or 1), (b.x or 0) + (b.w or 1))
  local top = math.max(a.y or 0, b.y or 0)
  local bottom = math.min((a.y or 0) + (a.h or 1), (b.y or 0) + (b.h or 1))
  if right <= left or bottom <= top then return 0 end
  return (right - left) * (bottom - top)
end

local function entryAnchorScore(room)
  if room.templateKey == "closet" then return 0 end
  if room.templateKey == "squareMedium" then return 8 end
  if room.templateKey == "squareSmall" or room.templateKey == "squareTiny" then return 12 end
  if room.templateKey == "hallway" then return 18 end
  return 24 + ((tonumber(room.cost) or 0) * 0.25)
end

local function ensureFloorplanEntry(system, layout)
  if not (system and layout and type(layout.rooms) == "table") then return false end
  for _, room in ipairs(layout.rooms) do
    if importedRoomFloor(room) == 1 and roomLooksLikeEntry(room) then return false end
  end

  local template = TEMPLATE_BY_KEY.entry
  if not template then return false end

  local options = {
    { "S", "N", 0, 0 },
    { "N", "S", 180, 10 },
    { "E", "W", 270, 14 },
    { "W", "E", 90, 14 },
  }
  local best
  for _, anchor in ipairs(layout.rooms) do
    if importedRoomFloor(anchor) == 1 and not roomLooksLikeEntry(anchor) then
      for _, opt in ipairs(options) do
        local room = {
          id = 0,
          roomTypeId = ROOM_TYPE_ID_BY_KEY.entry,
          name = template.name,
          design = "",
          x = anchor.x or 0,
          y = anchor.y or 0,
          w = template.w,
          h = template.h,
          color = template.color,
          shape = template.shape,
          templateKey = template.key,
          cost = template.cost,
          icon = template.icon,
          art = template.art,
          rotation = opt[3],
          budgetLimit = 30,
          floor = 1,
          items = {},
        }
        room.capture = { floor = 1 }
        applyRotationFootprint(room)
        if alignRoomForImport(system, anchor, room, opt[1], opt[2]) then
          local overlap = 0
          for _, other in ipairs(layout.rooms) do
            if importedRoomFloor(other) == 1 then overlap = overlap + overlapArea(room, other) end
          end
          local score = entryAnchorScore(anchor) + opt[4] + (overlap * 100)
          if not best or score < best.score then best = { score = score, room = room } end
        end
      end
    end
  end

  if not best then return false end
  local db = system:GetDB()
  best.room.id = db.nextRoomID
  db.nextRoomID = db.nextRoomID + 1
  layout.rooms[#layout.rooms + 1] = best.room
  return true
end

local function roomExternalID(room)
  local id = room and (room.externalID or room.exportID)
  if type(id) == "string" and id ~= "" then return id end
  local n = tonumber(room and room.id) or 0
  return string.format("00000000-0000-4000-8000-%012x", math.max(0, math.floor(n)))
end

local function createdTimestamp()
  if date then
    local ok, value = pcall(date, "!%Y-%m-%dT%H:%M:%S.000Z")
    if ok and value then return value end
  end
  return "1970-01-01T00:00:00.000Z"
end

local function requiredHouseLevelForCost(totalCost)
  totalCost = tonumber(totalCost) or 0
  return math.max(1, math.min(50, math.ceil(totalCost / 10) + 1))
end

local function floorplanRoomObject(system, room)
  local template = findTemplate(roomTypeIDForRoom(room)) or (room and room.templateKey and TEMPLATE_BY_KEY[room.templateKey])
  local defaultName = template and template.name or baseRoomName(room and room.name) or "Room"
  local currentName = baseRoomName(room and room.name)
  local customName = (currentName ~= "" and currentName ~= defaultName) and currentName or ""
  local floor = (room and room.capture and tonumber(room.capture.floor)) or tonumber(room and room.floor) or 1
  local roomTypeID = roomTypeIDForRoom(room)
  return {
    id = roomExternalID(room),
    roomTypeId = roomTypeID,
    name = defaultName,
    customName = customName,
    cost = system:GetRoomCost(room),
    x = (tonumber(room and room.x) or 0) * FLOORPLAN_COORD_SCALE,
    y = (tonumber(room and room.y) or 0) * FLOORPLAN_COORD_SCALE,
    rotation = floorplanExportRotation(roomTypeID, room and room.rotation),
    floor = floor,
    connections = {},
    isPrimaryStairwell = room and room.isPrimaryStairwell and true or false,
    primaryStairwellId = (room and room.primaryStairwellId) or JSON_NULL,
    interFloorConnections = {},
    interFloorConnection = (room and room.interFloorConnection) or JSON_NULL,
    isMirrorStairwell = roomTypeID == ROOM_TYPE_ID_BY_KEY.stairRight or (room and room.isMirrorStairwell and true or false),
  }
end

local FLOORPLAN_ROOM_FIELD_ORDER = {
  "id",
  "roomTypeId",
  "name",
  "customName",
  "cost",
  "x",
  "y",
  "rotation",
  "floor",
  "connections",
  "isPrimaryStairwell",
  "primaryStairwellId",
  "interFloorConnections",
  "interFloorConnection",
  "isMirrorStairwell",
}

local function appendFloorplanRoomJSON(lines, roomObj, indent, comma)
  local pad = string.rep(" ", indent)
  local childPad = string.rep(" ", indent + 2)
  lines[#lines + 1] = pad .. "{"
  for i, key in ipairs(FLOORPLAN_ROOM_FIELD_ORDER) do
    lines[#lines + 1] = childPad .. jsonEncode(key) .. ": " .. jsonEncode(roomObj[key]) .. (i < #FLOORPLAN_ROOM_FIELD_ORDER and "," or "")
  end
  lines[#lines + 1] = pad .. "}" .. (comma and "," or "")
end

local function firstList(obj, ...)
  for i = 1, select("#", ...) do
    local key = select(i, ...)
    local val = obj and obj[key]
    if type(val) == "table" then return val end
  end
end

function Architect:ExportLayout(layout)
  layout = layout or self:GetActiveLayout()
  if not layout then return "" end
  local parts = { "HDARCH1", esc(layout.name), layout.gridW or 24, layout.gridH or 16, layout.budgetLimit or 250 }
  local rooms = {}
  for _, room in ipairs(layout.rooms or {}) do
    local items = {}
    for _, item in ipairs(room.items or {}) do
      items[#items + 1] = table.concat({ item.decorID or 0, item.itemID or 0, item.qty or 1, esc(item.name) }, ",")
    end
    rooms[#rooms + 1] = table.concat({
      room.id or 0, esc(room.name), esc(room.design), room.x or 0, room.y or 0, room.w or 4,
      room.h or 3, room.color or 1, room.budgetLimit or 30, esc(room.shape or "rect"),
      room.cost or 0, esc(room.icon or ""), esc(room.templateKey or ""), room.rotation or 0, table.concat(items, ":")
    }, ";")
  end
  parts[#parts + 1] = table.concat(rooms, "|")
  return table.concat(parts, "|")
end

function Architect:ImportLayout(text)
  text = trim(text)
  if text == "" then return nil, "Paste a HomeDecor Architect string first." end
  local fields = splitFixed(text, "|", 6)
  if fields[1] ~= "HDARCH1" then return nil, "That does not look like a HomeDecor Architect string." end
  local layout = self:CreateLayout(unesc(fields[2] or "Imported Layout"))
  layout.gridW = tonumber(fields[3]) or 24
  layout.gridH = tonumber(fields[4]) or 16
  layout.budgetLimit = tonumber(fields[5]) or 250
  layout.rooms = {}

  local roomBlob = fields[6] or ""
  for roomText in roomBlob:gmatch("([^|]+)") do
    local r = splitFixed(roomText, ";", 15)
    local oldItemBlob = (r[10] and (r[10]:find(",", 1, true) or r[10]:find(":", 1, true))) and r[10] or nil
    local room = {
      id = tonumber(r[1]) or (self:GetDB().nextRoomID),
      name = unesc(r[2] or "Room"),
      design = unesc(r[3] or ""),
      x = tonumber(r[4]) or 0,
      y = tonumber(r[5]) or 0,
      w = tonumber(r[6]) or 4,
      h = tonumber(r[7]) or 3,
      color = tonumber(r[8]) or 1,
      budgetLimit = tonumber(r[9]) or 30,
      shape = oldItemBlob and "rect" or unesc(r[10] or "rect"),
      cost = oldItemBlob and 0 or (tonumber(r[11]) or 0),
      icon = oldItemBlob and "" or unesc(r[12] or ""),
      templateKey = oldItemBlob and "" or unesc(r[13] or ""),
      rotation = oldItemBlob and 0 or (tonumber(r[14]) or 0),
      items = {},
    }
    if self:GetDB().nextRoomID <= room.id then
      self:GetDB().nextRoomID = room.id + 1
    end
    clampRoom(layout, room)
    for itemText in tostring(oldItemBlob or r[15] or ""):gmatch("([^:]+)") do
      local p = splitFixed(itemText, ",", 4)
      if tonumber(p[1]) then
        room.items[#room.items + 1] = {
          id = self:GetDB().nextItemID,
          decorID = tonumber(p[1]),
          itemID = tonumber(p[2]),
          qty = tonumber(p[3]) or 1,
          name = unesc(p[4] or ""),
        }
        self:GetDB().nextItemID = self:GetDB().nextItemID + 1
      end
    end
    layout.rooms[#layout.rooms + 1] = room
  end
  return layout
end

function Architect:ExportWoWDBJSON(layout)
  layout = layout or self:GetActiveLayout()
  if not layout then return "" end

  local floors, maxFloor, totalCost = {}, 5, 0
  for _, room in ipairs(layout.rooms or {}) do
    local floorNum = tonumber(room.capture and room.capture.floor) or tonumber(room.floor) or 1
    maxFloor = math.max(maxFloor, floorNum)
    floors[floorNum] = floors[floorNum] or {}
    floors[floorNum][#floors[floorNum] + 1] = floorplanRoomObject(self, room)
    totalCost = totalCost + self:GetRoomCost(room)
  end

  local lines = {
    "{",
    "  \"version\": \"1.4\",",
    "  \"created\": " .. jsonEncode(createdTimestamp()) .. ",",
    "  \"currentFloor\": " .. tostring(tonumber(layout.currentFloor) or 1) .. ",",
    "  \"totalCost\": " .. tostring(totalCost) .. ",",
    "  \"requiredHouseLevel\": " .. tostring(requiredHouseLevelForCost(totalCost)) .. ",",
    "  \"floors\": {",
  }

  for floorNum = 1, maxFloor do
    local rooms = floors[floorNum] or {}
    lines[#lines + 1] = "    " .. jsonEncode(tostring(floorNum)) .. ": ["
    for i, roomObj in ipairs(rooms) do
      appendFloorplanRoomJSON(lines, roomObj, 6, i < #rooms)
    end
    lines[#lines + 1] = "    ]" .. (floorNum < maxFloor and "," or "")
  end
  lines[#lines + 1] = "  }"
  lines[#lines + 1] = "}"
  return table.concat(lines, "\n")
end

function Architect:ImportWoWDBJSON(text)
  local obj, err = jsonDecode(text)
  if type(obj) ~= "table" then return nil, err or "JSON could not be parsed." end

  local source = obj.floorplan or obj.floorPlan or obj.plan or obj
  local rooms = firstList(source, "rooms", "placedRooms", "floorRooms", "items")
  local floorRooms = {}
  local usesFloorplanFloors = type(source.floors) == "table"
  if usesFloorplanFloors then
    local maxFloor = 0
    for key, list in pairs(source.floors) do
      local floorNum = tonumber(key)
      if floorNum then maxFloor = math.max(maxFloor, floorNum) end
      if floorNum and type(list) == "table" then
        local actualList = firstList(list, "rooms", "placedRooms", "floorRooms", "items") or list
        if type(actualList) == "table" then
          for _, external in ipairs(actualList) do
            if type(external) == "table" then
              floorRooms[#floorRooms + 1] = { floor = floorNum, room = external }
            end
          end
        end
      end
    end
    local hasEntryInFloorList = false
    for _, floorEntry in ipairs(floorRooms) do
      if externalLooksLikeEntry(floorEntry.room) then
        hasEntryInFloorList = true
        break
      end
    end
    local standaloneEntry = source.entry or source.entrance or source.baseRoom or obj.entry or obj.entrance or obj.baseRoom
    if type(standaloneEntry) == "table" and not hasEntryInFloorList then
      floorRooms[#floorRooms + 1] = { floor = tonumber(standaloneEntry.floor) or 1, room = standaloneEntry, forceEntry = true }
    end
  elseif type(rooms) == "table" then
    for _, external in ipairs(rooms) do
      if type(external) == "table" then
        floorRooms[#floorRooms + 1] = { floor = tonumber(external.floor) or 1, room = external }
      end
    end
  end
  if #floorRooms == 0 then return nil, "No rooms were found in that floorplan JSON." end

  local layout = self:CreateLayout(source.name or source.title or obj.name or "Imported Floorplan")
  local grid = source.grid or obj.grid or {}
  layout.gridW = tonumber(grid.width or grid.w or source.gridW or source.width) or 24
  layout.gridH = tonumber(grid.height or grid.h or source.gridH or source.height) or 16
  layout.budgetLimit = tonumber(source.budgetLimit or source.budget or obj.budgetLimit) or 250
  layout.currentFloor = tonumber(source.currentFloor or obj.currentFloor) or 1
  layout.rooms = {}

  for _, entry in ipairs(floorRooms) do
    local external = entry.room
    if type(external) == "table" then
      local pos = external.position or external.pos or {}
      local coordScale = usesFloorplanFloors and FLOORPLAN_COORD_SCALE or 1
      local roomTypeID = tonumber(external.roomTypeId or external.roomTypeID or external.roomId or external.roomID)
      if entry.forceEntry and not roomTypeID then roomTypeID = ROOM_TYPE_ID_BY_KEY.entry end
      if isEntryTypeID(roomTypeID) then roomTypeID = ROOM_TYPE_ID_BY_KEY.entry end
      local template = findTemplate(roomTypeID or external.templateKey or external.type or external.name)
      local nextID = self:GetDB().nextRoomID
      local importedW = tonumber(external.w or external.width)
      local importedH = tonumber(external.h or external.height)
      if usesFloorplanFloors then
        importedW = importedW and (importedW / coordScale) or nil
        importedH = importedH and (importedH / coordScale) or nil
      end
      local baseW = importedW or (template and template.w) or 4
      local baseH = importedH or (template and template.h) or 3
      local rawRotation = tonumber(external.rotation or external.r) or 0
      local rotation = usesFloorplanFloors and floorplanImportRotation(roomTypeID, rawRotation, template) or rawRotation
      if usesFloorplanFloors and not importedW and not importedH then
        local turns = math.floor(((rotation % 360) / 90) + 0.5) % 4
        if turns % 2 == 1 then baseW, baseH = baseH, baseW end
      end
      local room = {
        id = tonumber(external.localID) or nextID,
        externalID = type(external.id) == "string" and external.id or nil,
        roomTypeId = roomTypeID,
        name = (external.customName and external.customName ~= "" and external.customName) or external.name or (template and template.name) or "Room",
        design = external.design or external.designName or "",
        x = (tonumber(external.x or pos.x or external.left) or 0) / coordScale,
        y = (tonumber(external.y or pos.y or external.top) or 0) / coordScale,
        w = baseW,
        h = baseH,
        color = tonumber(external.color or (template and template.color)) or 1,
        shape = external.shape or (template and template.shape) or "rect",
        templateKey = external.templateKey or (template and template.key) or external.roomId or external.type,
        cost = tonumber(external.cost or (template and template.cost)) or 0,
        icon = external.icon or (template and template.icon) or "",
        rotation = rotation,
        budgetLimit = tonumber(external.budgetLimit) or 30,
        floor = tonumber(external.floor) or entry.floor or 1,
        isPrimaryStairwell = external.isPrimaryStairwell and true or false,
        primaryStairwellId = external.primaryStairwellId ~= JSON_NULL and external.primaryStairwellId or nil,
        interFloorConnection = external.interFloorConnection ~= JSON_NULL and external.interFloorConnection or nil,
        isMirrorStairwell = external.isMirrorStairwell and true or false,
        items = {},
      }
      room.capture = { floor = room.floor }
      if self:GetDB().nextRoomID <= room.id then self:GetDB().nextRoomID = room.id + 1 end
      if usesFloorplanFloors then
        room.w = math.max(1, tonumber(room.w) or 4)
        room.h = math.max(1, tonumber(room.h) or 3)
        room.x = tonumber(room.x) or 0
        room.y = tonumber(room.y) or 0
      else
        clampRoom(layout, room)
      end
      layout.rooms[#layout.rooms + 1] = room
    end
  end

  if usesFloorplanFloors then
    ensureFloorplanEntry(self, layout)
    updateLayoutGridFromRooms(layout)
  else
    normalizeLayout(layout)
  end
  return layout
end

function Architect:ImportAny(text)
  text = trim(text)
  if text == "" then return nil, "Paste a floorplan export first." end
  if text:sub(1, 1) == "\"" and text:sub(-1) == "\"" and text:find("{", 1, true) then
    text = text:sub(2, -2):gsub("\\\"", "\""):gsub("\\n", "\n"):gsub("\\r", "\r"):gsub("\\t", "\t")
    text = trim(text)
  end
  if text:sub(1, 1) == "{" or text:sub(1, 1) == "[" then
    return self:ImportWoWDBJSON(text)
  end
  return self:ImportLayout(text)
end

function Architect:GetLastCaptureDebugJSON()
  local db = ensureProfile()
  local last = db and db.capture and db.capture.last
  if not last then return "{}" end
  return jsonEncode({
    time = last.time,
    reason = last.reason,
    owned = last.owned,
    roomSource = last.roomSource,
    roomCount = last.roomCount,
    floorCounts = last.floorCounts or {},
    houseSource = last.house and last.house._source,
    probeReport = last.probeReport or {},
  })
end

local function safeCall(owner, name, ...)
  local fn = owner and owner[name]
  if type(fn) ~= "function" then return nil end
  local ok, a, b, c, d = pcall(fn, ...)
  if ok then return a, b, c, d end
end

local function candidateCall(candidates)
  for _, c in ipairs(candidates) do
    local result = safeCall(c[1], c[2], unpack(c, 3))
    if result ~= nil then return result, c[2] end
  end
end

local function countArray(t)
  if type(t) ~= "table" then return 0 end
  local n = 0
  for i = 1, #t do
    if t[i] ~= nil then n = n + 1 end
  end
  return n
end

local TWO_PI = 2 * math.pi
local QUARTER_PI = math.pi / 2
local FACING_DIRS = { "S", "E", "N", "W" }
local ATLAS_DOORS = {
  entry = { "N" },
  closet_xs = { "N", "S" },
  square_xs = { "N", "E", "S", "W" },
  square_s = { "N", "E", "S", "W" },
  square_m = { "N", "E", "S", "W" },
  square_l = { "N", "E", "S", "W" },
  octagon_s = { "N", "E", "S", "W" },
  octagon_m = { "N", "E", "S", "W" },
  octagon_l = { "N", "E", "S", "W" },
  l_shape = { "N", "E" },
  t_shape = { "S", "E", "W" },
  cross_shape = { "N", "E", "S", "W" },
  hallway = { "N", "S" },
  tall_room = { "N", "E", "S", "W" },
  staircase = { "W" },
  staircase_mirror = { "E" },
  circle_daylight = { "N" },
  circle_evening = { "N" },
}
local NAME_TO_ATLAS_SHAPE = {
  ["Closet"] = "closet_xs",
  ["Square Room (Tiny)"] = "square_xs",
  ["Square Room (Small)"] = "square_s",
  ["Square Room (Medium)"] = "square_m",
  ["Square Room (Large)"] = "square_l",
  ["Octagon Room (Small)"] = "octagon_s",
  ["Octagon Room (Medium)"] = "octagon_m",
  ["Octagon Room (Large)"] = "octagon_l",
  ["L-Shaped Room"] = "l_shape",
  ["T-Shaped Room"] = "t_shape",
  ["Cross-Shaped Room"] = "cross_shape",
  ["Hallway"] = "hallway",
  ["Entry"] = "entry",
  ["Evening Circle Room"] = "circle_evening",
  ["Daylight Circle Room"] = "circle_daylight",
  ["Stairwell (Left)"] = "staircase",
  ["Stairwell (Right)"] = "staircase_mirror",
  ["Stairwell Room (Empty)"] = "tall_room",
}
local ENTRY_RESTRICTION = (Enum and Enum.HousingLayoutRestriction and Enum.HousingLayoutRestriction.IsBaseRoom) or 4

local function facingToCardinal(rad)
  if type(rad) ~= "number" then return nil end
  local r = rad % TWO_PI
  if r < 0 then r = r + TWO_PI end
  local q = math.floor((r + QUARTER_PI / 2) / QUARTER_PI) % 4
  return FACING_DIRS[q + 1]
end

local function sortedUniqueCardinals(doors)
  local out, seen = {}, {}
  for _, door in ipairs(doors or {}) do
    -- Type 3 is the vertical stair link between floors, not a room doorway.
    if door.connectionType == nil or tonumber(door.connectionType) == 1 then
      local card = facingToCardinal(door.facing)
      if card and not seen[card] then
        seen[card] = true
        out[#out + 1] = card
      end
    end
  end
  table.sort(out)
  return out
end

local function sortedOccupiedCardinals(doors)
  local out, seen = {}, {}
  for _, door in ipairs(doors or {}) do
    if door.occupied then
      local card = facingToCardinal(door.facing)
      if card and not seen[card] then
        seen[card] = true
        out[#out + 1] = card
      end
    end
  end
  table.sort(out)
  return out
end

local function setEq(a, b)
  if #a ~= #b then return false end
  local seen = {}
  for _, v in ipairs(a) do seen[v] = true end
  for _, v in ipairs(b) do if not seen[v] then return false end end
  return true
end

local function rotateCardinal(card, turns)
  local i = DIR_ORDER[card]
  if i == nil then return card end
  return DIR_FROM_INDEX[(i + turns) % 4]
end

local function inferRotation(atlasShape, capturedCardinals)
  local doors = ATLAS_DOORS[atlasShape]
  if not doors or not capturedCardinals then return 0 end
  for turns = 0, 3 do
    local rotated = {}
    for _, card in ipairs(doors) do rotated[#rotated + 1] = rotateCardinal(card, turns) end
    if setEq(rotated, capturedCardinals) then return turns end
  end
  return 0
end

local function currentHouseLabel()
  if C_Housing and C_Housing.GetCurrentHouseInfo then
    local ok, info = pcall(C_Housing.GetCurrentHouseInfo)
    if ok and type(info) == "table" then
      return info.houseName or info.name or info.neighborhoodName or "Captured House", info
    end
  end
  return "Captured House", {}
end

local function looksLikeRoom(row)
  if type(row) ~= "table" then return false end
  local hasName = row.name or row.roomName or row.houseRoomName or row.roomType or row.roomID or row.roomId
  local hasPos = row.x or row.y or row.posX or row.posY or row.positionX or row.positionY or row.position
  local hasShape = row.shape or row.templateKey or row.roomType or row.roomID or row.roomId
  return (hasName and hasShape) or (hasShape and hasPos) or (hasName and hasPos)
end

local function findRoomListInValue(value, depth, seen)
  if type(value) ~= "table" or depth > 3 then return nil end
  if seen[value] then return nil end
  seen[value] = true

  local n = countArray(value)
  if n > 0 then
    local hits = 0
    for i = 1, math.min(n, 8) do
      if looksLikeRoom(value[i]) then hits = hits + 1 end
    end
    if hits > 0 then return value end
  end

  local keys = {
    "rooms", "roomList", "placedRooms", "floorRooms", "floorplanRooms",
    "floorPlanRooms", "layouts", "layoutRooms", "items",
  }
  for _, key in ipairs(keys) do
    local found = findRoomListInValue(value[key], depth + 1, seen)
    if found then return found end
  end

  for _, child in pairs(value) do
    if type(child) == "table" then
      local found = findRoomListInValue(child, depth + 1, seen)
      if found then return found end
    end
  end
end

local function probeNamespaceForRooms(ns, nsName, report)
  if type(ns) ~= "table" then return nil end
  for fnName, fn in pairs(ns) do
    if type(fn) == "function" and tostring(fnName):lower():find("room")
      or (type(fn) == "function" and tostring(fnName):lower():find("floor"))
      or (type(fn) == "function" and tostring(fnName):lower():find("layout"))
      or (type(fn) == "function" and tostring(fnName):lower():find("plan")) then
      local ok, value = pcall(fn)
      report[#report + 1] = {
        namespace = nsName,
        functionName = tostring(fnName),
        ok = ok and true or false,
        valueType = type(value),
        count = type(value) == "table" and countArray(value) or 0,
      }
      if ok then
        local found = findRoomListInValue(value, 0, {})
        if found then return found, nsName .. "." .. tostring(fnName), report end
      end
    end
  end
end

local function normKey(s)
  return tostring(s or ""):lower():gsub("[^a-z0-9]+", "")
end

function Architect:ResolveTemplate(value)
  if not value then return nil end
  local v = normKey(value)
  for _, template in ipairs(self.RoomTemplates) do
    if normKey(template.key) == v or normKey(template.name) == v then return template end
  end
end

function Architect:IsInOwnedHouse()
  local owner = candidateCall({
    { C_Housing, "IsCurrentHouseOwnedByPlayer" },
    { C_Housing, "IsCurrentHouseOwner" },
    { C_Housing, "IsInOwnedHouse" },
    { C_HouseEditor, "CanEditCurrentHouse" },
    { C_HouseEditor, "IsHouseEditorAvailable" },
  })
  if owner ~= nil then return owner == true end
  local editable = C_HouseEditor and safeCall(C_HouseEditor, "GetHouseEditorModeAvailability", Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.BasicDecor)
  return editable ~= nil
end

function Architect:ReadCurrentHouseInfo()
  local info, source = candidateCall({
    { C_Housing, "GetCurrentHouseInfo" },
    { C_Housing, "GetCurrentHouse" },
    { C_Housing, "GetActiveHouseInfo" },
    { C_HouseEditor, "GetCurrentHouseInfo" },
  })
  if type(info) ~= "table" then info = {} end
  info._source = source
  return info
end

function Architect:ReadCurrentRooms()
  local rooms, source = candidateCall({
    { C_Housing, "GetCurrentHouseRooms" },
    { C_Housing, "GetCurrentHouseRoomList" },
    { C_Housing, "GetPlacedRooms" },
    { C_Housing, "GetFloorplanRooms" },
    { C_Housing, "GetFloorPlanRooms" },
    { C_Housing, "GetCurrentFloorplan" },
    { C_Housing, "GetCurrentFloorPlan" },
    { C_Housing, "GetActiveFloorplan" },
    { C_Housing, "GetActiveFloorPlan" },
    { C_Housing, "GetCurrentLayout" },
    { C_Housing, "GetHouseLayout" },
    { C_HouseEditor, "GetCurrentHouseRooms" },
    { C_HouseEditor, "GetPlacedRooms" },
    { C_HouseEditor, "GetCurrentFloorplan" },
    { C_HouseEditor, "GetCurrentFloorPlan" },
    { C_HouseEditor, "GetCurrentLayout" },
  })
  if type(rooms) == "table" then
    local found = findRoomListInValue(rooms, 0, {})
    if found then return found, source end
  end
  local report = {}
  local namespaces = {
    { C_Housing, "C_Housing" },
    { C_HouseEditor, "C_HouseEditor" },
    { C_HousingDecor, "C_HousingDecor" },
    { C_HousingBasicMode, "C_HousingBasicMode" },
    { C_HousingExpertMode, "C_HousingExpertMode" },
    { _G.C_HousingRoom, "C_HousingRoom" },
    { _G.C_HousingRooms, "C_HousingRooms" },
    { _G.C_HousingFloorPlan, "C_HousingFloorPlan" },
    { _G.C_HousingFloorplan, "C_HousingFloorplan" },
    { _G.C_HousingLayout, "C_HousingLayout" },
    { _G.C_HousingBlueprint, "C_HousingBlueprint" },
  }
  for _, ns in ipairs(namespaces) do
    local found, foundSource = probeNamespaceForRooms(ns[1], ns[2], report)
    if found then return found, foundSource, report end
  end
  if type(rooms) ~= "table" then return nil, source, report end
  return rooms, source
end

local function layoutMode()
  return (Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.Layout) or 3
end

local function decorateMode()
  return (Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.Decorate) or 1
end

local function resetHousingLayoutView(floor)
  if not C_HousingLayout then return end
  local calls = {
    { "SetViewedFloor", (tonumber(floor) or 1) - 1 },
    { "SetZoom", 0 },
    { "SetZoomLevel", 0 },
    { "SetMapZoom", 0 },
    { "ResetZoom" },
    { "ResetView" },
    { "SetPan", 0, 0 },
    { "SetPanOffset", 0, 0 },
    { "SetScrollOffset", 0, 0 },
  }
  for _, call in ipairs(calls) do
    local fn = C_HousingLayout[call[1]]
    if type(fn) == "function" then pcall(fn, unpack(call, 2)) end
  end
end

local function resolveCapturedShape(name, isBase)
  if isBase then return "entry" end
  return NAME_TO_ATLAS_SHAPE[name] or NAME_TO_ATLAS_SHAPE[tostring(name or "")] or nil
end

local function readPinCenter(pinFrame)
  if not pinFrame then return nil, nil end
  local parent = pinFrame.GetParent and pinFrame:GetParent() or nil
  if parent and parent.GetLeft and parent.GetTop and pinFrame.GetCenter then
    local okP, pLeft, pTop = pcall(function() return parent:GetLeft(), parent:GetTop() end)
    local okC, cx, cy = pcall(pinFrame.GetCenter, pinFrame)
    if okP and okC and pLeft and pTop and cx and cy then
      return cx - pLeft, pTop - cy
    end
  end
  if pinFrame.GetPoint then
    local ok, point, rel, relPoint, xOfs, yOfs = pcall(pinFrame.GetPoint, pinFrame, 1)
    if ok and type(xOfs) == "number" and type(yOfs) == "number" then
      local p = tostring(point or "") .. tostring(relPoint or "")
      if p:find("TOP", 1, true) then yOfs = -yOfs end
      return xOfs, yOfs
    end
  end
  if pinFrame.GetCenter then
    local ok, x, y = pcall(pinFrame.GetCenter, pinFrame)
    if ok and x and y then return x, y end
  end
  if pinFrame.GetRect then
    local ok, x, y, w, h = pcall(pinFrame.GetRect, pinFrame)
    if ok and x and y and w and h then return x + (w / 2), y + (h / 2) end
  end
  return nil, nil
end

local function scalarDoorInfo(d)
  local out = {}
  if type(d) ~= "table" then return out end
  for k, v in pairs(d) do
    local tv = type(v)
    if tv == "number" or tv == "string" or tv == "boolean" then
      out[k] = v
    end
  end
  return out
end

local function connectedDoorRoomKey(door, ownGUID)
  if type(door) ~= "table" then return nil end
  local own = tostring(ownGUID or "")
  local function scan(t)
    if type(t) ~= "table" then return nil end
    for k, v in pairs(t) do
      local key = tostring(k):lower()
      if key:find("room", 1, true) and (key:find("guid", 1, true) or key:find("id", 1, true)) then
        local value = tostring(v or "")
        if value ~= "" and value ~= own then return value end
      end
    end
    return nil
  end
  return scan(door) or scan(door.raw)
end

function Architect:_BeginPinCapture(floor)
  self._pinCapture = {
    active = true,
    floor = floor or 1,
    rooms = {},
    nextIndex = 1,
  }
end

function Architect:_EndPinCapture()
  local cap = self._pinCapture
  if not (cap and cap.active) then return nil end
  cap.active = false
  for _, room in pairs(cap.rooms or {}) do
    if room._pinFrame then
      local x, y = readPinCenter(room._pinFrame)
      room.pinX = x or room.pinX
      room.pinY = y or room.pinY
      room._pinFrame = nil
    end
  end
  self._pinCapture = nil
  return cap
end

function Architect:_IngestLayoutPin(pinFrame)
  local cap = self._pinCapture
  if not (cap and cap.active and pinFrame and pinFrame.GetPinType and pinFrame.GetRoomGUID) then return end
  local okType, pinType = pcall(pinFrame.GetPinType, pinFrame)
  local okGuid, roomGUID = pcall(pinFrame.GetRoomGUID, pinFrame)
  if not (okType and okGuid and roomGUID) then return end

  local room = cap.rooms[roomGUID]
  if not room then
    room = { roomGUID = roomGUID, doors = {}, doorSeen = {}, captureIndex = cap.nextIndex, floor = cap.floor }
    cap.rooms[roomGUID] = room
    cap.nextIndex = cap.nextIndex + 1
  end

  if pinType == 1 then
    local okName, name = pcall(pinFrame.GetRoomName, pinFrame)
    local okRemove, restriction = false, nil
    if pinFrame.CanRemove then okRemove, restriction = pcall(pinFrame.CanRemove, pinFrame) end
    room.name = okName and name or room.name
    room.isBase = okRemove and restriction == ENTRY_RESTRICTION
    room.atlasShape = resolveCapturedShape(room.name, room.isBase)
    room.templateKey = room.atlasShape and TEMPLATE_BY_ATLAS_SHAPE[room.atlasShape] and TEMPLATE_BY_ATLAS_SHAPE[room.atlasShape].key
    room.pinX, room.pinY = readPinCenter(pinFrame)
    room._pinFrame = pinFrame
    if C_Timer and C_Timer.After then
      local function sampleSettledPosition()
        if self._pinCapture ~= cap or room._pinFrame ~= pinFrame then return end
        local okCurrent, currentGUID = pcall(pinFrame.GetRoomGUID, pinFrame)
        if not okCurrent or currentGUID ~= roomGUID then return end
        local x, y = readPinCenter(pinFrame)
        if x and y then room.pinX, room.pinY = x, y end
      end
      C_Timer.After(0, sampleSettledPosition)
      C_Timer.After(0.25, sampleSettledPosition)
      C_Timer.After(1.0, sampleSettledPosition)
    end
  elseif pinType == 0 and pinFrame.GetDoorConnectionInfo then
    local okDoor, d = pcall(pinFrame.GetDoorConnectionInfo, pinFrame)
    if okDoor and type(d) == "table" then
      local occupied = false
      if pinFrame.IsOccupiedDoor then
        local okOccupied, isOccupied = pcall(pinFrame.IsOccupiedDoor, pinFrame)
        occupied = okOccupied and isOccupied and true or false
      end
      local doorKey = tostring(d.doorID or "") .. ":" .. tostring(d.connectionType or "") .. ":" .. tostring(d.doorFacing or "")
      if not room.doorSeen[doorKey] then
        room.doorSeen[doorKey] = true
        room.doors[#room.doors + 1] = {
          doorID = d.doorID,
          connectionType = d.connectionType,
          facing = d.doorFacing,
          occupied = occupied,
          raw = scalarDoorInfo(d),
        }
      end
    end
  end
end

local function addSnapshotRooms(out, snapshot)
  if not snapshot then return end
  local floor = snapshot.floor or 1
  for _, raw in pairs(snapshot.rooms or {}) do
    local atlasShape = raw.atlasShape or resolveCapturedShape(raw.name, raw.isBase)
    local template = atlasShape and TEMPLATE_BY_ATLAS_SHAPE[atlasShape]
    if template then
      local cards = sortedUniqueCardinals(raw.doors)
      local occupiedCards = sortedOccupiedCardinals(raw.doors)
      out[#out + 1] = {
        roomGUID = raw.roomGUID,
        name = raw.name or template.name,
        templateKey = template.key,
        atlasShape = atlasShape,
        floor = floor,
        captureIndex = raw.captureIndex or (#out + 1),
        rotation = inferRotation(atlasShape, cards) * 90,
        doorCardinals = cards,
        occupiedCardinals = occupiedCards,
        doors = raw.doors,
        pinX = raw.pinX,
        pinY = raw.pinY,
        isBase = raw.isBase,
      }
    end
  end
end

local function rectsOverlap(a, b)
  return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

local function roomWouldOverlap(layout, movingRoom, x, y, placed)
  local test = { x = x, y = y, w = movingRoom.w, h = movingRoom.h }
  for _, other in ipairs(layout.rooms or {}) do
    if other.id ~= movingRoom.id and (not placed or placed[other.id]) then
      if rectsOverlap(test, other) then return true end
    end
  end
end

local function hasCaptureCard(room, card)
  local cap = room and room.capture
  local cards = cap and (#(cap.occupiedCardinals or {}) > 0 and cap.occupiedCardinals or cap.doorCardinals)
  if not cards then return true end
  for _, c in ipairs(cards) do if c == card then return true end end
  return false
end

local function anyOverlapWithPlaced(layout, room, placed)
  local test = { x = room.x, y = room.y, w = room.w, h = room.h }
  for _, other in ipairs(layout.rooms or {}) do
    if other.id ~= room.id and placed[other.id] and rectsOverlap(test, other) then return true end
  end
end

local function deconflictRoom(layout, room, placed)
  if not anyOverlapWithPlaced(layout, room, placed) then return end
  local baseX, baseY = room.x, room.y
  local bestX, bestY
  for radius = 1, 18 do
    for dy = -radius, radius do
      for dx = -radius, radius do
        if math.abs(dx) == radius or math.abs(dy) == radius then
          room.x, room.y = baseX + dx, baseY + dy
          if not anyOverlapWithPlaced(layout, room, placed) then
            bestX, bestY = room.x, room.y
            break
          end
        end
      end
      if bestX then break end
    end
    if bestX then break end
  end
  room.x, room.y = bestX or (baseX + 1), bestY or (baseY + 1)
end

local function connectionForCard(system, room, card)
  for _, conn in ipairs(system:GetRoomConnections(room) or {}) do
    if conn[3] == card then return conn end
  end
end

local function alignRoomConnection(system, anchor, moving, anchorCard, movingCard)
  local a = connectionForCard(system, anchor, anchorCard)
  local m = connectionForCard(system, moving, movingCard)
  if not (a and m) then return false end
  moving.x = math.floor(anchor.x + (a[1] * anchor.w) - (m[1] * moving.w) + 0.5)
  moving.y = math.floor(anchor.y + (a[2] * anchor.h) - (m[2] * moving.h) + 0.5)
  return true
end

local function sameCapturedFloor(a, b)
  return (tonumber(a and a.capture and a.capture.floor) or 1) == (tonumber(b and b.capture and b.capture.floor) or 1)
end

local function capturedFloor(room)
  return tonumber(room and room.capture and room.capture.floor) or tonumber(room and room.floor) or 1
end

local function isStairRoom(room)
  local key = room and room.templateKey
  local atlas = room and room.capture and room.capture.atlasShape
  local name = string.lower(tostring(room and room.name or ""))
  return key == "stairEmpty" or key == "stairLeft" or key == "stairRight" or
    atlas == "tall_room" or atlas == "staircase" or atlas == "staircase_mirror" or
    name:find("stair", 1, true) ~= nil
end

local function stairStackKey(room)
  if not isStairRoom(room) then return nil end
  local key = room and room.templateKey
  local atlas = room and room.capture and room.capture.atlasShape
  local name = string.lower(tostring(room and room.name or ""))
  if key == "stairLeft" or atlas == "staircase" or name:find("left", 1, true) then return "left" end
  if key == "stairRight" or atlas == "staircase_mirror" or name:find("right", 1, true) then return "right" end
  if key == "stairEmpty" or atlas == "tall_room" or name:find("empty", 1, true) then return "empty" end
  return "stair"
end

local function roomCenter(room)
  return (room.x or 0) + ((room.w or 1) / 2), (room.y or 0) + ((room.h or 1) / 2)
end

local function shiftFloorRooms(rooms, dx, dy)
  for _, room in ipairs(rooms or {}) do
    room.x = (room.x or 0) + dx
    room.y = (room.y or 0) + dy
  end
end

local function bestStairAnchor(rooms)
  local first
  for _, room in ipairs(rooms or {}) do
    if isStairRoom(room) then
      if room.templateKey == "stairEmpty" then return room end
      first = first or room
    end
  end
  return first
end

local function bestStairAnchorForKey(rooms, stackKey)
  local first
  for _, room in ipairs(rooms or {}) do
    if stairStackKey(room) == stackKey then
      if room.templateKey == "stairEmpty" then return room end
      first = first or room
    end
  end
  return first
end

local function findCrossFloorLinkedRoom(source, candidatesByGUID)
  local cap = source and source.capture
  if not cap then return nil end
  for _, door in ipairs(cap.doors or {}) do
    if door.occupied then
      local targetGUID = connectedDoorRoomKey(door, cap.roomGUID)
      local target = targetGUID and candidatesByGUID[tostring(targetGUID)]
      if target and not sameCapturedFloor(source, target) then return target end
    end
  end
end

local function floorHasOnlyStairRooms(rooms)
  local nonStair = 0
  for _, room in ipairs(rooms or {}) do
    if not isStairRoom(room) then nonStair = nonStair + 1 end
  end
  return nonStair == 0
end

local function capturePoint(room)
  local cap = room and room.capture
  if cap and cap.pinX and cap.pinY then return cap.pinX, cap.pinY end
  return roomCenter(room)
end

local function roundGrid(value)
  value = tonumber(value) or 0
  if value >= 0 then return math.floor(value + 0.5) end
  return math.ceil(value - 0.5)
end

local function collectStairRooms(rooms)
  local stairs = {}
  for _, room in ipairs(rooms or {}) do
    if isStairRoom(room) then stairs[#stairs + 1] = room end
  end
  table.sort(stairs, function(a, b)
    local ak, bk = stairStackKey(a) or "", stairStackKey(b) or ""
    if ak ~= bk then return ak < bk end
    local ax, ay = capturePoint(a)
    local bx, by = capturePoint(b)
    if ay ~= by then return ay < by end
    if ax ~= bx then return ax < bx end
    return ((a.capture and a.capture.index) or a.id or 0) < ((b.capture and b.capture.index) or b.id or 0)
  end)
  return stairs
end

local function matchStairStacks(anchorStairs, targetStairs)
  local pairs, pairedTargets = {}, {}
  if not anchorStairs or not targetStairs or #anchorStairs == 0 or #targetStairs == 0 then return pairs, pairedTargets end

  local candidates = {}
  for ti, stair in ipairs(targetStairs) do
    local sx, sy = capturePoint(stair)
    local stairKey = stairStackKey(stair)
    for ai, anchor in ipairs(anchorStairs) do
      if stairStackKey(anchor) == stairKey then
        local ax, ay = capturePoint(anchor)
        candidates[#candidates + 1] = {
          anchorIndex = ai,
          targetIndex = ti,
          score = math.abs(ax - sx) + math.abs(ay - sy),
        }
      end
    end
  end

  table.sort(candidates, function(a, b)
    if a.score ~= b.score then return a.score < b.score end
    return a.targetIndex < b.targetIndex
  end)

  local usedAnchors, usedTargets = {}, {}
  for _, candidate in ipairs(candidates) do
    if not usedAnchors[candidate.anchorIndex] and not usedTargets[candidate.targetIndex] then
      local anchor = anchorStairs[candidate.anchorIndex]
      local stair = targetStairs[candidate.targetIndex]
      pairs[#pairs + 1] = { anchor = anchor, stair = stair }
      pairedTargets[stair] = true
      usedAnchors[candidate.anchorIndex] = true
      usedTargets[candidate.targetIndex] = true
    end
  end

  return pairs, pairedTargets
end

local function stairPairOffset(pair)
  local ax, ay = roomCenter(pair.anchor)
  local sx, sy = roomCenter(pair.stair)
  return ax - sx, ay - sy
end

local function moveStairToAnchor(pair)
  pair.stair.x = roundGrid((pair.anchor.x or 0) + (((pair.anchor.w or 1) - (pair.stair.w or 1)) / 2))
  pair.stair.y = roundGrid((pair.anchor.y or 0) + (((pair.anchor.h or 1) - (pair.stair.h or 1)) / 2))
end

local function stairOffsetsAgree(stairPairs)
  if not stairPairs or #stairPairs == 0 then return false end
  local sumDX, sumDY = 0, 0
  for _, pair in ipairs(stairPairs) do
    local dx, dy = stairPairOffset(pair)
    sumDX, sumDY = sumDX + dx, sumDY + dy
  end
  local avgDX, avgDY = sumDX / #stairPairs, sumDY / #stairPairs
  for _, pair in ipairs(stairPairs) do
    local dx, dy = stairPairOffset(pair)
    if math.abs(dx - avgDX) > 1.25 or math.abs(dy - avgDY) > 1.25 then
      return false, roundGrid(avgDX), roundGrid(avgDY)
    end
  end
  return true, roundGrid(avgDX), roundGrid(avgDY)
end

local function roomsShareCapturedConnection(system, a, b)
  local function occupied(room, card)
    local cards = room and room.capture and room.capture.occupiedCardinals
    if type(cards) ~= "table" then return true end
    for _, capturedCard in ipairs(cards) do
      if capturedCard == card then return true end
    end
    return false
  end
  for _, ac in ipairs(system:GetRoomConnections(a) or {}) do
    if occupied(a, ac[3]) then
      local ax = (a.x or 0) + ac[1] * (a.w or 1)
      local ay = (a.y or 0) + ac[2] * (a.h or 1)
      for _, bc in ipairs(system:GetRoomConnections(b) or {}) do
        if bc[3] == OPPOSITE_DIR[ac[3]] and occupied(b, bc[3]) then
          local bx = (b.x or 0) + bc[1] * (b.w or 1)
          local by = (b.y or 0) + bc[2] * (b.h or 1)
          if math.abs(ax - bx) < 0.01 and math.abs(ay - by) < 0.01 then return true end
        end
      end
    end
  end
  return false
end

local function capturedPositionComponents(system, rooms)
  local components, roomToComponent, visited = {}, {}, {}
  for _, start in ipairs(rooms or {}) do
    if not visited[start] then
      local component, queue = {}, { start }
      visited[start] = true
      local qi = 1
      while queue[qi] do
        local room = queue[qi]
        qi = qi + 1
        component[#component + 1] = room
        for _, other in ipairs(rooms or {}) do
          if not visited[other] and roomsShareCapturedConnection(system, room, other) then
            visited[other] = true
            queue[#queue + 1] = other
          end
        end
      end
      components[#components + 1] = component
      for _, room in ipairs(component) do roomToComponent[room] = component end
    end
  end
  return components, roomToComponent
end

local function applyStairStackAlignment(system, layout)
  if not layout or type(layout.rooms) ~= "table" then return end
  local byFloor, floors = {}, {}
  for _, room in ipairs(layout.rooms) do
    local floor = capturedFloor(room)
    if not byFloor[floor] then
      byFloor[floor] = {}
      floors[#floors + 1] = floor
    end
    byFloor[floor][#byFloor[floor] + 1] = room
  end
  table.sort(floors)

  local anchorStairs = {}
  for _, floor in ipairs(floors) do
    local rooms = byFloor[floor]
    local stairs = collectStairRooms(rooms)
    if #stairs > 0 then
      if #anchorStairs == 0 then
        for _, stair in ipairs(stairs) do anchorStairs[#anchorStairs + 1] = stair end
      else
        local stairPairs, pairedTargets = matchStairStacks(anchorStairs, stairs)
        local _, roomToComponent = capturedPositionComponents(system, rooms)
        local componentOffsets = {}
        for _, pair in ipairs(stairPairs) do
          local component = roomToComponent[pair.stair]
          if component then
            local dx, dy = stairPairOffset(pair)
            local offsets = componentOffsets[component]
            if not offsets then
              offsets = { dx = 0, dy = 0, count = 0 }
              componentOffsets[component] = offsets
            end
            offsets.dx = offsets.dx + dx
            offsets.dy = offsets.dy + dy
            offsets.count = offsets.count + 1
          end
        end
        for component, offsets in pairs(componentOffsets) do
          shiftFloorRooms(component, roundGrid(offsets.dx / offsets.count), roundGrid(offsets.dy / offsets.count))
        end
        for _, stair in ipairs(stairs) do
          if not pairedTargets[stair] then anchorStairs[#anchorStairs + 1] = stair end
        end
      end
    end
  end
end

local function directionAgreementScore(anchor, moving, card)
  local ax, ay = capturePoint(anchor)
  local bx, by = capturePoint(moving)
  local dx, dy = bx - ax, by - ay
  local absDx, absDy = math.abs(dx), math.abs(dy)
  if card == "N" then
    if dy >= 0 or absDx > math.max(24, absDy * 1.75) then return nil end
    return absDx + absDy * 0.18
  elseif card == "S" then
    if dy <= 0 or absDx > math.max(24, absDy * 1.75) then return nil end
    return absDx + absDy * 0.18
  elseif card == "E" then
    if dx <= 0 or absDy > math.max(24, absDx * 1.75) then return nil end
    return absDy + absDx * 0.18
  elseif card == "W" then
    if dx >= 0 or absDy > math.max(24, absDx * 1.75) then return nil end
    return absDy + absDx * 0.18
  end
  return absDx + absDy
end

local function postSnapDistance(system, anchor, moving, anchorCard, movingCard)
  local a = connectionForCard(system, anchor, anchorCard)
  local m = connectionForCard(system, moving, movingCard)
  if not (a and m) then return nil end
  local x = math.floor((anchor.x or 0) + a[1] * (anchor.w or 1) - m[1] * (moving.w or 1) + 0.5)
  local y = math.floor((anchor.y or 0) + a[2] * (anchor.h or 1) - m[2] * (moving.h or 1) + 0.5)
  local cx, cy = roomCenter(moving)
  return math.abs((x + ((moving.w or 1) / 2)) - cx) + math.abs((y + ((moving.h or 1) / 2)) - cy)
end

local function snapLikelyOccupiedPairs(system, layout)
  if not layout or type(layout.rooms) ~= "table" then return end
  local byFloor, floors = {}, {}
  for _, room in ipairs(layout.rooms) do
    local floor = capturedFloor(room)
    if not byFloor[floor] then
      byFloor[floor] = {}
      floors[#floors + 1] = floor
    end
    byFloor[floor][#byFloor[floor] + 1] = room
  end
  table.sort(floors)

  for _, floor in ipairs(floors) do
    local rooms = byFloor[floor]
    if rooms and not floorHasOnlyStairRooms(rooms) then
      local candidates = {}
      for _, anchor in ipairs(rooms) do
        for _, card in ipairs((anchor.capture and anchor.capture.occupiedCardinals) or {}) do
          local opposite = OPPOSITE_DIR[card]
          for _, moving in ipairs(rooms) do
            if moving ~= anchor and not isStairRoom(moving) and hasCaptureCard(moving, opposite) and connectionForCard(system, anchor, card) and connectionForCard(system, moving, opposite) then
              local directionScore = directionAgreementScore(anchor, moving, card)
              local moveScore = directionScore and postSnapDistance(system, anchor, moving, card, opposite)
              if directionScore and moveScore and moveScore <= 18 then
                candidates[#candidates + 1] = {
                  anchor = anchor,
                  moving = moving,
                  card = card,
                  opposite = opposite,
                  score = directionScore + moveScore * 2,
                }
              end
            end
          end
        end
      end
      table.sort(candidates, function(a, b) return a.score < b.score end)

      local usedMoving, usedAnchorCard = {}, {}
      for _, c in ipairs(candidates) do
        local key = tostring(c.anchor.id) .. ":" .. tostring(c.card)
        if not usedMoving[c.moving.id] and not usedAnchorCard[key] then
          alignRoomConnection(system, c.anchor, c.moving, c.card, c.opposite)
          usedMoving[c.moving.id] = true
          usedAnchorCard[key] = true
        end
      end
    end
  end
end

local function snapFloorRoomsToStairs(system, layout)
  if not layout or type(layout.rooms) ~= "table" then return end
  local byFloor, floors = {}, {}
  for _, room in ipairs(layout.rooms) do
    local floor = capturedFloor(room)
    if not byFloor[floor] then
      byFloor[floor] = {}
      floors[#floors + 1] = floor
    end
    byFloor[floor][#byFloor[floor] + 1] = room
  end
  table.sort(floors)

  for i, floor in ipairs(floors) do
    local rooms = byFloor[floor]
    if i == 1 or floorHasOnlyStairRooms(rooms) then
      -- Do not let stair repair reshape the main captured floor, and do not invent
      -- hallway links on floors that only captured a stair.
    else
    local stair = bestStairAnchor(rooms)
    if stair then
      local best
      for _, sc in ipairs(system:GetRoomConnections(stair) or {}) do
        local opposite = OPPOSITE_DIR[sc[3]]
        for _, room in ipairs(rooms) do
          if room ~= stair and not isStairRoom(room) then
            local rc = connectionForCard(system, room, opposite)
            if rc then
              local x = math.floor((stair.x or 0) + sc[1] * (stair.w or 1) - rc[1] * (room.w or 1) + 0.5)
              local y = math.floor((stair.y or 0) + sc[2] * (stair.h or 1) - rc[2] * (room.h or 1) + 0.5)
              local cx, cy = roomCenter(room)
              local score = math.abs((x + ((room.w or 1) / 2)) - cx) + math.abs((y + ((room.h or 1) / 2)) - cy)
              local cap = room.capture or {}
              if hasCaptureCard(room, opposite) then score = score - 4 end
              if #(cap.occupiedCardinals or {}) == 0 then score = score + 2 end
              if not best or score < best.score then
                best = { room = room, x = x, y = y, score = score }
              end
            end
          end
        end
      end
      if best and best.score <= 48 then
        best.room.x, best.room.y = best.x, best.y
      end
    end
    end
  end
end

local function snapCapturedConnections(system, layout)
  if not layout or type(layout.rooms) ~= "table" then return end
  local byGUID = {}
  for _, room in ipairs(layout.rooms) do
    local guid = room.capture and room.capture.roomGUID
    if guid then byGUID[tostring(guid)] = room end
  end

  for _ = 1, 3 do
    local changed = false
    for _, room in ipairs(layout.rooms) do
      local cap = room.capture or {}
      for _, door in ipairs(cap.doors or {}) do
        if door.occupied then
          local card = facingToCardinal(door.facing)
          local targetGUID = connectedDoorRoomKey(door, cap.roomGUID)
          local target = targetGUID and byGUID[tostring(targetGUID)]
          if card and target and target ~= room and sameCapturedFloor(room, target) then
            local anchor, moving, anchorCard, movingCard = room, target, card, OPPOSITE_DIR[card]
            if target.templateKey == "entry" or ((target.capture and target.capture.index) or 9999) < ((room.capture and room.capture.index) or 9999) then
              anchor, moving, anchorCard, movingCard = target, room, OPPOSITE_DIR[card], card
            end
            if not (isStairRoom(anchor) and isStairRoom(moving)) then
              if isStairRoom(moving) then
                anchor, moving, anchorCard, movingCard = moving, anchor, movingCard, anchorCard
              end
              local oldX, oldY = moving.x, moving.y
              if alignRoomConnection(system, anchor, moving, anchorCard, movingCard) and (moving.x ~= oldX or moving.y ~= oldY) then
                changed = true
              end
            end
          end
        end
      end
    end
    if not changed then break end
  end

  -- If Blizzard does not expose the linked room GUID, snap only very close projected
  -- neighbors with opposite occupied doors. This keeps capture faithful without
  -- turning unrelated rooms into a fake chain.
  for _, room in ipairs(layout.rooms) do
    local cap = room.capture or {}
    for _, card in ipairs(cap.occupiedCardinals or {}) do
      local opposite = OPPOSITE_DIR[card]
      local best, bestScore
      for _, other in ipairs(layout.rooms) do
        if other ~= room and not isStairRoom(other) and sameCapturedFloor(room, other) and hasCaptureCard(other, opposite) then
          local dx = ((other.x or 0) + ((other.w or 1) / 2)) - ((room.x or 0) + ((room.w or 1) / 2))
          local dy = ((other.y or 0) + ((other.h or 1) / 2)) - ((room.y or 0) + ((room.h or 1) / 2))
          local directional =
            (card == "N" and dy < 0 and math.abs(dx) <= math.max(room.w, other.w)) or
            (card == "S" and dy > 0 and math.abs(dx) <= math.max(room.w, other.w)) or
            (card == "E" and dx > 0 and math.abs(dy) <= math.max(room.h, other.h)) or
            (card == "W" and dx < 0 and math.abs(dy) <= math.max(room.h, other.h))
          local score = math.abs(dx) + math.abs(dy)
          if directional and score <= 10 and (not bestScore or score < bestScore) then
            best, bestScore = other, score
          end
        end
      end
      if best then
        alignRoomConnection(system, room, best, card, opposite)
      end
    end
  end
end

local TOPOLOGY_CARD_ORDER = { "N", "S", "E", "W" }

local function occupiedCaptureCard(room, card)
  for _, capturedCard in ipairs((room.capture and room.capture.occupiedCardinals) or {}) do
    if capturedCard == card then return true end
  end
  return false
end

local function occupiedCaptureDegree(room)
  return #((room.capture and room.capture.occupiedCardinals) or {})
end

local function overlapsPlacedFloorRoom(room, x, y, rooms, placed)
  local test = { x = x, y = y, w = room.w or 1, h = room.h or 1 }
  for _, other in ipairs(rooms or {}) do
    if other ~= room and placed[other] and rectsOverlap(test, other) then return true end
  end
  return false
end

local function stableCaptureOrder(room)
  local guid = tostring(room and room.capture and room.capture.roomGUID or "")
  local suffix = guid:match("([%x]+)$")
  local ordinal = suffix and tonumber(suffix, 16)
  return ordinal or tonumber(room and room.capture and room.capture.index) or tonumber(room and room.id) or 0, guid
end

function Architect:ArrangeCapturedByDoorTopology(layout)
  if not layout or type(layout.rooms) ~= "table" or #layout.rooms < 2 then return false end
  local byFloor, floors, occupiedDoorCount = {}, {}, 0
  for _, room in ipairs(layout.rooms) do
    local floor = capturedFloor(room)
    if not byFloor[floor] then
      byFloor[floor] = {}
      floors[#floors + 1] = floor
    end
    byFloor[floor][#byFloor[floor] + 1] = room
    occupiedDoorCount = occupiedDoorCount + occupiedCaptureDegree(room)
  end
  if occupiedDoorCount < 2 then return false end
  table.sort(floors)

  local attachedCount = 0
  for _, floor in ipairs(floors) do
    local rooms = byFloor[floor]
    local placed, usedCards = {}, {}
    local componentX, placedSequence = 2, 0
    local maxRoomSpan = 1
    for _, room in ipairs(rooms) do
      maxRoomSpan = math.max(maxRoomSpan, room.w or 1, room.h or 1)
    end
    table.sort(rooms, function(a, b)
      local ae, be = a.templateKey == "entry", b.templateKey == "entry"
      if ae ~= be then return ae end
      local ao, ag = stableCaptureOrder(a)
      local bo, bg = stableCaptureOrder(b)
      if ao ~= bo then return ao < bo end
      return ag < bg
    end)

    for _, moving in ipairs(rooms) do
      local candidates = {}
      for _, anchor in ipairs(rooms) do
        local anchorIsStair = isStairRoom(anchor)
        local movingIsStair = isStairRoom(moving)
        if placed[anchor] and anchor ~= moving
            and not (anchorIsStair and movingIsStair) then
          usedCards[anchor] = usedCards[anchor] or {}
          for _, movingCard in ipairs(TOPOLOGY_CARD_ORDER) do
            local anchorCard = OPPOSITE_DIR[movingCard]
            if occupiedCaptureCard(moving, movingCard) and occupiedCaptureCard(anchor, anchorCard)
                and not usedCards[anchor][anchorCard] then
              local ac = connectionForCard(self, anchor, anchorCard)
              local mc = connectionForCard(self, moving, movingCard)
              if ac and mc then
                local x = math.floor((anchor.x or 0) + ac[1] * (anchor.w or 1) - mc[1] * (moving.w or 1) + 0.5)
                local y = math.floor((anchor.y or 0) + ac[2] * (anchor.h or 1) - mc[2] * (moving.h or 1) + 0.5)
                if not overlapsPlacedFloorRoom(moving, x, y, rooms, placed) then
                  candidates[#candidates + 1] = {
                    anchor = anchor,
                    anchorCard = anchorCard,
                    movingCard = movingCard,
                    x = x,
                    y = y,
                    sequence = placed[anchor],
                  }
                end
              end
            end
          end
        end
      end
      table.sort(candidates, function(a, b)
        if a.sequence ~= b.sequence then return a.sequence > b.sequence end
        return DIR_ORDER[a.anchorCard] < DIR_ORDER[b.anchorCard]
      end)

      local selected = candidates[1]
      if selected then
        moving.x, moving.y = selected.x, selected.y
        usedCards[selected.anchor][selected.anchorCard] = true
        usedCards[moving] = usedCards[moving] or {}
        usedCards[moving][selected.movingCard] = true
        attachedCount = attachedCount + 1
      else
        moving.x, moving.y = componentX, 2
        while overlapsPlacedFloorRoom(moving, moving.x, moving.y, rooms, placed) do
          moving.x = moving.x + 2
        end
      end
      placedSequence = placedSequence + 1
      placed[moving] = placedSequence
      -- Leave room for a later attachment to extend back toward this component.
      componentX = math.max(componentX, (moving.x or 0) + (moving.w or 1) + maxRoomSpan + 3)
    end
  end

  if attachedCount == 0 then return false end
  normalizeLayout(layout)
  return true
end

local function alignCapturedFloorsByStairs(system, layout)
  applyStairStackAlignment(system, layout)
end

local function forceStackCapturedStairs(system, layout)
  applyStairStackAlignment(system, layout)
end

function Architect:ArrangeCapturedByPinPositions(layout)
  if not layout or type(layout.rooms) ~= "table" then return false end
  local byFloor, pinCount = {}, 0
  for _, room in ipairs(layout.rooms or {}) do
    local cap = room.capture or {}
    if cap.pinX and cap.pinY then
      local floor = capturedFloor(room)
      byFloor[floor] = byFloor[floor] or {}
      byFloor[floor][#byFloor[floor] + 1] = room
      pinCount = pinCount + 1
    end
  end
  if pinCount < 2 then return false end

  local floors = {}
  for floor in pairs(byFloor) do floors[#floors + 1] = floor end
  table.sort(floors)

  for _, floor in ipairs(floors) do
    local rooms = byFloor[floor]
    local floorBaseY = 2
    local minPX, minPY, maxPX, maxPY = 999999, 999999, -999999, -999999
    local totalArea, totalW, totalH = 0, 0, 0
    for _, room in ipairs(rooms) do
      local cap = room.capture
      minPX, minPY = math.min(minPX, cap.pinX), math.min(minPY, cap.pinY)
      maxPX, maxPY = math.max(maxPX, cap.pinX), math.max(maxPY, cap.pinY)
      totalArea = totalArea + ((room.w or 1) * (room.h or 1))
      totalW = totalW + (room.w or 1)
      totalH = totalH + (room.h or 1)
    end
    local count = math.max(1, #rooms)
    local spanPX, spanPY = math.max(1, maxPX - minPX), math.max(1, maxPY - minPY)
    local distances = {}
    for i, room in ipairs(rooms) do
      local best
      local a = room.capture
      for j, other in ipairs(rooms) do
        if i ~= j then
          local b = other.capture
          local dx, dy = (a.pinX or 0) - (b.pinX or 0), (a.pinY or 0) - (b.pinY or 0)
          local d = math.sqrt(dx * dx + dy * dy)
          if d > 0 and (not best or d < best) then best = d end
        end
      end
      if best then distances[#distances + 1] = best end
    end

    table.sort(distances)
    local medianDistance = distances[math.max(1, math.ceil(#distances / 2))]
    if not medianDistance or medianDistance <= 0 then
      medianDistance = math.max(spanPX, spanPY) / math.max(1, math.sqrt(count))
    end

    local avgW = totalW / count
    local avgH = totalH / count
    local maxRoomSide = 1
    for _, room in ipairs(rooms) do
      maxRoomSide = math.max(maxRoomSide, room.w or 1, room.h or 1)
    end
    local avgFootprint = math.max(2.5, math.sqrt(math.max(1, totalArea / count)) + math.max(avgW, avgH) * 0.35)
    local scale = avgFootprint / math.max(1, medianDistance)
    local targetW = math.max(maxRoomSide + 8, math.sqrt(count) * (avgW + 3))
    local targetH = math.max(maxRoomSide + 8, math.sqrt(count) * (avgH + 3))
    scale = math.max(scale, targetW / spanPX, targetH / spanPY)
    scale = math.max(0.035, math.min(0.80, scale))

    -- Keep very wide or tall captures readable without crushing the smaller axis.
    local projectedW, projectedH = spanPX * scale, spanPY * scale
    local maxProjected = math.max(32, math.sqrt(count) * 14, maxRoomSide * 4)
    if projectedW > maxProjected or projectedH > maxProjected then
      scale = scale * math.min(maxProjected / math.max(1, projectedW), maxProjected / math.max(1, projectedH))
    end

    table.sort(rooms, function(a, b)
      local ax, bx = (a.capture and a.capture.pinX) or 0, (b.capture and b.capture.pinX) or 0
      local ay, by = (a.capture and a.capture.pinY) or 0, (b.capture and b.capture.pinY) or 0
      local af, bf = (a.templateKey == "entry") and 0 or 1, (b.templateKey == "entry") and 0 or 1
      if af ~= bf then return af < bf end
      if ay ~= by then return ay < by end
      if ax ~= bx then return ax < bx end
      return ((a.capture and a.capture.index) or a.id or 0) < ((b.capture and b.capture.index) or b.id or 0)
    end)

    local placed = {}
    for _, room in ipairs(rooms) do
      local cap = room.capture or {}
      local rawX = 2 + ((cap.pinX or minPX) - minPX) * scale
      local rawY = floorBaseY + ((cap.pinY or minPY) - minPY) * scale
      room.x = math.floor(rawX - ((room.w or 1) / 2) + 0.5)
      room.y = math.floor(rawY - ((room.h or 1) / 2) + 0.5)
      room.x = math.max(1, room.x)
      room.y = math.max(floorBaseY, room.y)
      deconflictRoom(layout, room, placed)
      placed[room.id] = true
    end
  end

  snapCapturedConnections(self, layout)
  snapLikelyOccupiedPairs(self, layout)
  alignCapturedFloorsByStairs(self, layout)
  normalizeLayout(layout)
  return true
end

function Architect:AutoArrangeCapturedLayout(layout)
  if not layout or type(layout.rooms) ~= "table" or #layout.rooms < 2 then return layout end
  if self:ArrangeCapturedByPinPositions(layout) then return layout end
  if self:ArrangeCapturedByDoorTopology(layout) then
    snapCapturedConnections(self, layout)
    alignCapturedFloorsByStairs(self, layout)
    normalizeLayout(layout)
    return layout
  end

  table.sort(layout.rooms, function(a, b)
    local af, bf = (a.capture and a.capture.floor) or 1, (b.capture and b.capture.floor) or 1
    if af ~= bf then return af < bf end
    local ae, be = a.templateKey == "entry", b.templateKey == "entry"
    if ae ~= be then return ae end
    return ((a.capture and a.capture.index) or a.id or 0) < ((b.capture and b.capture.index) or b.id or 0)
  end)

  local placed, floorOffsets = {}, {}
  local function placeFallback(room)
    local floor = (room.capture and room.capture.floor) or 1
    local pos = floorOffsets[floor] or { x = 1, y = 1 + ((floor - 1) * 12), rowH = 0 }
    if pos.x > 1 and pos.x + room.w > 26 then
      pos.x, pos.y, pos.rowH = 1, pos.y + pos.rowH + 1, 0
    end
    room.x, room.y = pos.x, pos.y
    pos.x = pos.x + room.w + 1
    pos.rowH = math.max(pos.rowH, room.h)
    floorOffsets[floor] = pos
  end

  for _, room in ipairs(layout.rooms) do
    room.x, room.y = 0, 0
  end

  for _, room in ipairs(layout.rooms) do
    if room.templateKey == "entry" then
      room.x, room.y = 12, 1 + (((room.capture and room.capture.floor) or 1) - 1) * 12
      placed[room.id] = true
    end
  end

  if not next(placed) and layout.rooms[1] then
    layout.rooms[1].x, layout.rooms[1].y = 12, 1
    placed[layout.rooms[1].id] = true
  end

  for pass = 1, 4 do
    for _, room in ipairs(layout.rooms) do
      if not placed[room.id] then
        local best
        for _, other in ipairs(layout.rooms) do
          if placed[other.id] and ((other.capture and other.capture.floor) or 1) == ((room.capture and room.capture.floor) or 1) then
            for _, oc in ipairs(self:GetRoomConnections(other)) do
              for _, mc in ipairs(self:GetRoomConnections(room)) do
                if OPPOSITE_DIR[mc[3]] == oc[3] then
                  local x = math.floor(other.x + oc[1] * other.w - mc[1] * room.w + 0.5)
                  local y = math.floor(other.y + oc[2] * other.h - mc[2] * room.h + 0.5)
                  if not roomWouldOverlap(layout, room, x, y, placed) then
                    local score = math.abs(x - other.x) + math.abs(y - other.y)
                    if not hasCaptureCard(other, oc[3]) then score = score + 25 end
                    if not hasCaptureCard(room, mc[3]) then score = score + 25 end
                    if not best or score < best.score then best = { x = x, y = y, score = score } end
                  end
                end
              end
            end
          end
        end
        if best then
          room.x, room.y = best.x, best.y
          placed[room.id] = true
        end
      end
    end
  end

  for _, room in ipairs(layout.rooms) do
    if not placed[room.id] then
      placeFallback(room)
      placed[room.id] = true
    end
  end

  local minX, minY, maxX, maxY = 999999, 999999, 0, 0
  for _, room in ipairs(layout.rooms) do
    minX = math.min(minX, room.x or 0)
    minY = math.min(minY, room.y or 0)
    maxX = math.max(maxX, (room.x or 0) + (room.w or 1))
    maxY = math.max(maxY, (room.y or 0) + (room.h or 1))
  end
  local dx, dy = 1 - minX, 1 - minY
  for _, room in ipairs(layout.rooms) do
    room.x = (room.x or 0) + dx
    room.y = (room.y or 0) + dy
  end
  layout.gridW = math.max(28, maxX + dx + 2)
  layout.gridH = math.max(18, maxY + dy + 2)
  for _, room in ipairs(layout.rooms) do clampRoom(layout, room) end
  return layout
end

function Architect:RepairCapturedFloorStack(layout)
  if not layout or type(layout.rooms) ~= "table" then return layout end
  local captured, stairFloors = false, {}
  for _, room in ipairs(layout.rooms) do
    if room.capture then
      captured = true
      if isStairRoom(room) then stairFloors[capturedFloor(room)] = true end
    end
  end
  if not captured or not next(stairFloors) then return layout end

  snapCapturedConnections(self, layout)
  alignCapturedFloorsByStairs(self, layout)
  normalizeLayout(layout)
  return layout
end

function Architect:BuildLayoutFromPinCaptures(name, captures)
  local captured = {}
  for _, snap in ipairs(captures or {}) do addSnapshotRooms(captured, snap) end
  if #captured == 0 then return nil end

  table.sort(captured, function(a, b)
    if (a.floor or 1) ~= (b.floor or 1) then return (a.floor or 1) < (b.floor or 1) end
    if (a.isBase and true or false) ~= (b.isBase and true or false) then return not a.isBase end
    return (a.captureIndex or 0) < (b.captureIndex or 0)
  end)

  local layout = self:CreateLayout(name or "Captured House")
  layout.rooms = {}
  layout.gridW, layout.gridH = 28, 18
  local x, y, rowH, maxRight = 1, 1, 0, 1
  local maxRowW = 24
  local entryRooms = {}

  for _, raw in ipairs(captured) do
    local template = TEMPLATE_BY_KEY[raw.templateKey] or TEMPLATE_BY_ATLAS_SHAPE[raw.atlasShape] or self.RoomTemplates[1]
    local room = self:AddRoom(layout, template)
    room.name = ((raw.floor or 1) > 1 and ("Floor " .. tostring(raw.floor) .. " - ") or "") .. (raw.name or template.name)
    room.rotation = raw.rotation or 0
    room.capture = {
      roomGUID = raw.roomGUID,
      floor = raw.floor,
      index = raw.captureIndex,
      atlasShape = raw.atlasShape,
      doorCardinals = raw.doorCardinals,
      occupiedCardinals = raw.occupiedCardinals,
      doors = raw.doors,
      pinX = raw.pinX,
      pinY = raw.pinY,
      isBase = raw.isBase,
    }
    if raw.isBase or raw.atlasShape == "entry" then
      entryRooms[#entryRooms + 1] = room
    else
      if x > 1 and (x + room.w) > maxRowW then
        x, y, rowH = 1, y + rowH + 1, 0
      end
      room.x, room.y = x, y
      x = x + room.w + 1
      rowH = math.max(rowH, room.h)
      maxRight = math.max(maxRight, x)
    end
  end

  local entryY = y + rowH + 1
  for _, room in ipairs(entryRooms) do
    room.x = math.max(1, math.floor((maxRight - room.w) / 2))
    room.y = entryY
    entryY = entryY + room.h + 1
  end

  local maxBottom = 0
  for _, room in ipairs(layout.rooms) do
    maxBottom = math.max(maxBottom, (room.y or 0) + (room.h or 1))
  end
  layout.gridW = math.max(layout.gridW, maxRight + 1)
  layout.gridH = math.max(layout.gridH, maxBottom + 1)
  for _, room in ipairs(layout.rooms) do clampRoom(layout, room) end
  self:AutoArrangeCapturedLayout(layout)
  self:RepairCapturedFloorStack(layout)
  return layout
end

function Architect:_FinishLiveCapture(captures, reason)
  local db = ensureProfile()
  local name, house = currentHouseLabel()
  local layout = self:BuildLayoutFromPinCaptures(name, captures)
  local roomCount = 0
  local floorCounts = {}
  for _, snap in ipairs(captures or {}) do
    local floor = snap.floor or 1
    floorCounts[floor] = floorCounts[floor] or 0
    for _ in pairs(snap.rooms or {}) do
      roomCount = roomCount + 1
      floorCounts[floor] = floorCounts[floor] + 1
    end
  end
  local record = {
    time = time and time() or 0,
    reason = reason or "manual",
    owned = self:IsInOwnedHouse(),
    house = house,
    roomSource = "HOUSING_LAYOUT_PIN_FRAME_ADDED",
    roomCount = layout and #(layout.rooms or {}) or roomCount,
    floorCounts = floorCounts,
    layoutID = layout and layout.id or nil,
    captures = captures,
  }
  if db and db.capture then
    db.capture.history[#db.capture.history + 1] = record
    db.capture.last = record
    while #db.capture.history > 10 do table.remove(db.capture.history, 1) end
  end
  self._activeLiveCapture = nil
  if NS.SendMessage then NS.SendMessage("HOMEDECOR_ARCHITECT_CAPTURED", layout, record) end
  return layout, record
end

function Architect:StartLiveCapture(reason)
  local db = ensureProfile()
  if not db then return nil, "No profile database." end
  if self._activeLiveCapture then return nil, "Capture already in progress." end
  if not (C_Housing and C_Housing.IsInsideHouse and C_Housing.IsInsideHouse()) then
    return nil, "Enter your house before capturing."
  end
  if not (C_HouseEditor and C_HouseEditor.IsHouseEditorStatusAvailable and C_HouseEditor.IsHouseEditorStatusAvailable()) then
    return nil, "House editor is not available yet."
  end

  local maxFloor = (C_HousingLayout and C_HousingLayout.GetNumFloors and C_HousingLayout.GetNumFloors()) or 1
  maxFloor = math.max(1, tonumber(maxFloor) or 1)
  local state = {
    reason = reason or "manual",
    floor = 0,
    maxFloor = maxFloor,
    captures = {},
    settle = 1.5,
  }
  self._activeLiveCapture = state

  local function after(delay, fn)
    if C_Timer and C_Timer.After then C_Timer.After(delay, fn) else fn() end
  end

  local function step()
    if self._activeLiveCapture ~= state then return end
    if self._pinCapture then
      local snap = self:_EndPinCapture()
      if snap then state.captures[#state.captures + 1] = snap end
    end
    state.floor = state.floor + 1
    if state.floor > state.maxFloor then
      if C_HouseEditor and C_HouseEditor.LeaveHouseEditor then C_HouseEditor.LeaveHouseEditor() end
      self:_FinishLiveCapture(state.captures, state.reason)
      return
    end
    resetHousingLayoutView(state.floor)
    self:_BeginPinCapture(state.floor)
    after(state.settle, step)
  end

  if C_HouseEditor.EnterHouseEditor then C_HouseEditor.EnterHouseEditor() end
  if C_HouseEditor.ActivateHouseEditorMode then C_HouseEditor.ActivateHouseEditorMode(decorateMode()) end
  after(0.1, function()
    if self._activeLiveCapture ~= state then return end
    if C_HouseEditor.ActivateHouseEditorMode then C_HouseEditor.ActivateHouseEditorMode(layoutMode()) end
    step()
  end)
  return nil, "Capture started.", { started = true, maxFloor = maxFloor, roomSource = "HOUSING_LAYOUT_PIN_FRAME_ADDED" }
end

function Architect:BuildLayoutFromCapturedRooms(name, rooms)
  if type(rooms) ~= "table" or #rooms == 0 then return nil end
  local layout = self:CreateLayout(name or "Captured House")
  layout.rooms = {}
  local minX, minY = 999999, 999999
  for _, r in ipairs(rooms) do
    if type(r) == "table" then
      local x = tonumber(r.x or r.posX or r.positionX or (r.position and r.position.x)) or 0
      local y = tonumber(r.y or r.posY or r.positionY or (r.position and r.position.y)) or 0
      if x < minX then minX = x end
      if y < minY then minY = y end
    end
  end
  if minX == 999999 then minX, minY = 0, 0 end
  for _, r in ipairs(rooms) do
    if type(r) == "table" then
      local template = self:ResolveTemplate(r.templateKey or r.roomType or r.roomID or r.roomId or r.name)
      template = template or self.RoomTemplates[1]
      local room = self:AddRoom(layout, template)
      room.name = r.name or (template and template.name) or room.name
      room.x = math.floor((tonumber(r.x or r.posX or r.positionX or (r.position and r.position.x)) or 0) - minX + 1)
      room.y = math.floor((tonumber(r.y or r.posY or r.positionY or (r.position and r.position.y)) or 0) - minY + 1)
      room.rotation = tonumber(r.rotation or r.r or r.angle) or 0
      clampRoom(layout, room)
    end
  end
  return layout
end

function Architect:CaptureCurrentHouse(reason)
  if C_Housing and C_Housing.IsInsideHouse and C_Housing.IsInsideHouse() then
    return self:StartLiveCapture(reason)
  end

  local db = ensureProfile()
  if not db then return nil, "No profile database." end
  local owned = self:IsInOwnedHouse()

  local house = self:ReadCurrentHouseInfo()
  local rooms, roomSource, probeReport = self:ReadCurrentRooms()
  local name = house.houseName or house.name or house.neighborhoodName or "Captured House"
  local layout
  if rooms and #rooms > 0 then
    layout = self:BuildLayoutFromCapturedRooms(name, rooms)
  end

  local record = {
    time = time and time() or 0,
    reason = reason or "manual",
    owned = owned,
    house = house,
    roomSource = roomSource,
    probeReport = probeReport,
    roomCount = rooms and #rooms or 0,
    layoutID = layout and layout.id or nil,
  }
  db.capture.history[#db.capture.history + 1] = record
  db.capture.last = record
  while #db.capture.history > 10 do table.remove(db.capture.history, 1) end
  if layout then return layout, nil, record end
  if not owned then
    return nil, "Ownership/editor check failed, and no room list API returned placed rooms.", record
  end
  return nil, "No room list API returned placed rooms yet.", record
end

function Architect:TryAutoCapture(reason)
  return nil, "Architect capture is manual only."
end

NS.SafeRegisterEvent(Architect, "HOUSING_LAYOUT_PIN_FRAME_ADDED", function(pinFrame)
  Architect:_IngestLayoutPin(pinFrame)
end)

return Architect
