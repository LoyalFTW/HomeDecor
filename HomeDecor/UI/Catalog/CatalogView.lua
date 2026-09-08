local _, NS = ...

NS.UI = NS.UI or {}
local CatalogView = {}
NS.UI.CatalogView = CatalogView

local ROW_HEIGHT = 48
local OVERSCAN = 4
local INITIAL_ROWS = 20
local QUESTION_MARK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local COLOR = NS.UI.Controls.colors

local function Backdrop(frame, background, border)
  NS.UI.Controls:Backdrop(frame, background or COLOR.panel, border or COLOR.border)
end

local function SetTextColor(text, color)
  NS.UI.Controls:TextColor(text, color)
end

local function SkinButton(button)
  NS.UI.Controls:SkinButton(button)
end

local function CreateSection(parent, label, y, x, right)
  local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("TOPLEFT", x or 10, y)
  text:SetText(label)
  SetTextColor(text, COLOR.accent)
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(COLOR.border[1], COLOR.border[2], COLOR.border[3], 0.75)
  line:SetPoint("LEFT", text, "RIGHT", 8, 0)
  line:SetPoint("RIGHT", parent, "RIGHT", right or -10, 0)
  line:SetHeight(1)
  return text
end

local SIDEBAR_ICONS = {
  ["Saved Items"] = "Interface\\Common\\ReputationStar",
  ["All Sources"] = "Interface\\Icons\\INV_Misc_Map_01",
  ["Achievements"] = "Interface\\Icons\\Achievement_General",
  ["Quests"] = "Interface\\Icons\\INV_Misc_Note_02",
  ["Vendors"] = "Interface\\Icons\\INV_Misc_Coin_01",
  ["Drops"] = "Interface\\Icons\\INV_Box_01",
  ["Drops/Encounters"] = "Interface\\Icons\\INV_Box_01",
  ["Treasures"] = "Interface\\Icons\\INV_Misc_TreasureChest04b",
  ["Shop"] = "Interface\\Icons\\INV_Misc_Coin_02",
  ["Professions"] = "Interface\\Icons\\Trade_BlackSmithing",
  ["PvP"] = "Interface\\Icons\\INV_BannerPVP_02",
  ["Architect"] = "Interface\\Icons\\INV_Inscription_Tradeskill01",
  ["Decor Pricing"] = "Interface\\Icons\\INV_Misc_Coin_01",
  ["Events"] = "Interface\\Icons\\INV_Misc_PocketWatch_01",
  ["Decor Tracker"] = "Interface\\Icons\\Ability_Hunter_BeastCall",
  ["Gather Tracker"] = "Interface\\Icons\\INV_Misc_Map_01",
  ["Alts Professions"] = "Interface\\Icons\\INV_Misc_Book_11",
  ["Endeavors"] = "Interface\\Icons\\Achievement_Zone_Cataclysm",
  ["Statistics"] = "Interface\\Icons\\INV_Misc_Spyglass_03",
  ["Community"] = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon",
  ["What's New"] = "Interface\\Icons\\INV_Misc_Note_01",
  ["Gallery"] = "Interface\\Icons\\INV_Inscription_Pigment_Golden",
  ["Filters"] = "Interface\\Buttons\\UI-OptionsButton",
}

local function AddSidebarIcon(button, label)
  local icon = button:CreateTexture(nil, "OVERLAY")
  icon:SetSize(14, 14)
  icon:SetPoint("LEFT", button, "LEFT", 8, 0)
  icon:SetTexture(SIDEBAR_ICONS[label] or "Interface\\Icons\\INV_Misc_QuestionMark")
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  icon:SetVertexColor(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 0.95)
  local text = button:GetFontString()
  if text then
    text:ClearAllPoints()
    text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    text:SetPoint("RIGHT", button, "RIGHT", -6, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    if text.SetMaxLines then text:SetMaxLines(1) end
    text:SetFontObject(GameFontNormal)
  end
  button.icon = icon
end

local function CreateSidebarButton(parent, label, y, onClick, managesTransient)
  local button = NS.UI.Controls:CreateButton(parent, label, 184, 22)
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
  button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, y)
  AddSidebarIcon(button, label)
  if onClick then
    button:SetScript("OnClick", function(...)
      if NS.UI.Controls and not managesTransient then NS.UI.Controls:CloseTransientPopups() end
      onClick(...)
    end)
  end
  return button
end

local categories = {
  { key = "All", label = "All Sources" },
  { key = "All", label = "Achievements", requirement = "Achievement" },
  { key = "All", label = "Quests", requirement = "Quest" },
  { key = "Vendors", label = "Vendors" },
  { key = "Drops", label = "Drops/Encounters" },
  { key = "Treasures", label = "Treasures" },
  { key = "Shops", label = "Shop" },
  { key = "Professions", label = "Professions" },
  { key = "PvP", label = "PvP" },
}

local GROUP_CATEGORY_RANK = {
  Achievements = 1,
  Quests = 2,
  Vendors = 3,
  Drops = 4,
  Treasures = 5,
  Shops = 6,
  Shop = 6,
  Professions = 7,
  PvP = 8,
}

local EXPANSION_RANK = {
  Classic = 1,
  Jewelcrafting = 1,
  Leatherworking = 1,
  Tailoring = 1,
  BurningCrusade = 2,
  Outland = 2,
  Wrath = 3,
  Northrend = 3,
  Cataclysm = 4,
  Cata = 4,
  Pandaria = 5,
  MistsOfPandaria = 5,
  Pandaren = 5,
  Warlords = 6,
  WarlordsOfDraenor = 6,
  Draenor = 6,
  Legion = 7,
  BattleForAzeroth = 8,
  Kul = 8,
  KulTiras = 8,
  ["Kul Tiran"] = 8,
  Zandalar = 8,
  Shadowlands = 9,
  Dragonflight = 10,
  Dragon = 10,
  DragonIsles = 10,
  ["Dragon Isles"] = 10,
  WarWithin = 11,
  TheWarWithin = 11,
  Khaz = 11,
  KhazAlgar = 11,
  ["Khaz Algar"] = 11,
  Midnight = 12,
}

local function FactionName(value)
  if type(value) ~= "table" then return type(value) == "string" and value or nil end
  local alliance, horde
  for _, faction in pairs(value) do
    if faction == "Alliance" then alliance = true elseif faction == "Horde" then horde = true end
  end
  if alliance and horde then return "Both" end
  if alliance then return "Alliance" end
  if horde then return "Horde" end
end

local function FactionTexture(value)
  value = FactionName(value)
  if value == "Alliance" or value == "alliance" then return "Interface\\FriendsFrame\\PlusManz-Alliance" end
  if value == "Horde" or value == "horde" then return "Interface\\FriendsFrame\\PlusManz-Horde" end
  return nil
end

local SOURCE_LABELS = {
  achievement = "Achievement", quest = "Quest", vendor = "Vendor", drop = "Drop",
  encounter = "Encounter", shop = "Shop", treasure = "Treasure", profession = "Profession",
  event = "Event", pvp = "PvP",
}

local function SourceLabel(record)
  local source = SOURCE_LABELS[tostring(record.sourceType or ""):lower()] or record.sourceType or record.category or "Unknown source"
  local name = record.sourceName or record.vendorName
  if not name and record.sourceType == "vendor" and record.sourceID and NS.Systems.NPCNames then name = NS.Systems.NPCNames:Get(record.sourceID) end
  return name and (tostring(source) .. " · " .. tostring(name)) or tostring(source)
end

local function CardContextText(record)
  if tostring(record.sourceType or ""):lower() == "profession" then
    local trade = {}
    if record.expansion and record.expansion ~= "" then trade[#trade + 1] = tostring(record.expansion) end
    if record.profession and record.profession ~= "" then trade[#trade + 1] = tostring(record.profession) end
    if #trade > 0 then return "Profession: " .. table.concat(trade, " ") end
  end
  return NS.Systems.Housing:GetCategoryPath(record) or ""
end

local function CardAttributeText(record)
  local context = CardContextText(record)
  local values = {}
  if record.size then values[#values + 1] = tostring(record.size) end
  if record.budgetCost then values[#values + 1] = "Budget " .. tostring(record.budgetCost) end
  if record.raceRestriction then values[#values + 1] = tostring(record.raceRestriction) end
  local faction = FactionName(record.faction)
  if faction and faction ~= "Neutral" then values[#values + 1] = faction end
  local attributes = table.concat(values, "  ·  ")
  if context ~= "" and attributes ~= "" then return context .. "\n" .. attributes end
  return context ~= "" and context or attributes
end

local function CardMediaLabel(record)
  local dyeable = record and record.dyeable == true
  local class = NS.Systems.Housing:GetClassRestriction(record)
  if dyeable and class then return "DYEABLE  ·  " .. tostring(class):upper(), true end
  if dyeable then return "DYEABLE", true end
  if class then return tostring(class):upper(), true end
  return nil, false
end

local function CardSourceText(record)
  local values = { SourceLabel(record) }
  if record.zone then values[#values + 1] = tostring(record.zone) end
  return table.concat(values, "  ·  ")
end

local function CreateBadge(parent, fontObject, clickable)
  local badge = CreateFrame(clickable and "Button" or "Frame", nil, parent, "BackdropTemplate")
  Backdrop(badge, COLOR.background, COLOR.border)
  badge.text = badge:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormalSmall")
  badge.text:SetPoint("CENTER", 0, 0)
  badge:Hide()
  return badge
end

function CatalogView:GetRowHeight()
  local profile = NS.Systems.Database:GetProfile()
  return profile and profile.ui.compact and 34 or ROW_HEIGHT
end

function CatalogView:GetLayout()
  local profile = NS.Systems.Database:GetProfile()
  local width = self.frame and self.frame.content and self.frame.content:GetWidth() or 650
  if profile and profile.ui.catalogOnly == true then return 1, 30, width end
  if profile and profile.ui.view == "grid" then
    local columns = math.max(2, math.floor(width / 176))
    if profile.ui.panelVisible ~= false and self.frame and self.frame:GetWidth() >= 1080 then columns = math.max(4, columns) end
    return columns, 320, width / columns
  end
  if profile and profile.ui.view == "text" then return 1, 42, width end
  return 1, self:GetRowHeight(), width
end

function CatalogView:RefreshCompactExpansions()
  local frame = self.frame
  if not frame or not frame.compactExpansionSelect then return end
  local profile = NS.Systems.Database:GetProfile()
  local selected = profile and profile.filters and profile.filters.expansion or "All"
  local label = selected == "All" and "All" or NS.Systems.QueryState:GetOptionLabel("expansion", selected)
  frame.compactExpansionSelect:SetText("Expansion: " .. tostring(label) .. "  v")
  frame.compactExpansionSelect.selectedValue = selected
end

function CatalogView:UpdateResponsiveLayout()
  local frame = self.frame
  if not frame or not frame.scroll or not frame.inspector then return end
  local profile = NS.Systems.Database:GetProfile()
  local catalogOnly = profile and profile.ui.catalogOnly == true
  if catalogOnly then
    frame.scroll:ClearAllPoints()
    frame.scroll:SetPoint("TOPLEFT", frame.compactColumnHeader, "BOTTOMLEFT", 0, -4)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 14)
    frame.inspector:Hide()
    if frame.groupBar then frame.groupBar:Hide() end
    frame.content:SetWidth(math.max(1, frame.scroll:GetWidth() - 20))
    return
  end
  local wide = frame:GetWidth() >= 1080
  local panelVisible = not profile or profile.ui.panelVisible ~= false
  local grouped = false
  frame.scroll:ClearAllPoints()
  frame.scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 228, grouped and -184 or -154)
  frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", wide and panelVisible and -310 or -16, 48)
  frame.inspector:ClearAllPoints()
  frame.inspector:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, grouped and -184 or -154)
  frame.inspector:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 48)
  frame.inspector:SetShown(wide and panelVisible)
  if frame.groupBar then
    frame.groupBar:ClearAllPoints()
    frame.groupBar:SetPoint("TOPLEFT", frame.toolbar, "BOTTOMLEFT", 0, -5)
    frame.groupBar:SetPoint("RIGHT", frame, "RIGHT", wide and panelVisible and -310 or -16, 0)
    frame.groupBar:SetHeight(28)
    frame.groupBar:SetShown(grouped)
  end
  frame.content:SetWidth(math.max(1, frame.scroll:GetWidth() - 20))
end

function CatalogView:ApplyShellLayout()
  local frame = self.frame
  local profile = NS.Systems.Database:GetProfile()
  if not frame or not profile then return end
  local catalogOnly = profile.ui.catalogOnly == true
  frame._applyingShellLayout = true
  frame:SetSize(catalogOnly and 560 or 1320, catalogOnly and 620 or 760)
  frame.header:SetHeight(catalogOnly and 38 or 62)
  frame.sidebar:SetShown(not catalogOnly)
  frame.footer:SetShown(not catalogOnly)
  frame.logo:SetShown(not catalogOnly)
  frame.headerLine:SetShown(not catalogOnly)
  frame.scaleLabel:SetShown(not catalogOnly)
  frame.scaleSlider:SetShown(not catalogOnly)
  frame.scaleValue:SetShown(not catalogOnly)
  frame.settingsButton:SetShown(not catalogOnly)
  frame.galleryTop:SetShown(not catalogOnly)
  frame.panelTop:SetShown(not catalogOnly)
  frame.viewButtons[1]:SetShown(not catalogOnly)
  frame.viewButtons[2]:SetShown(not catalogOnly)
  frame.viewButtons[3]:SetShown(not catalogOnly)
  frame.compactSourceSelect:SetShown(catalogOnly)
  frame.compactExpansionSelect:SetShown(catalogOnly)
  frame.compactColumnHeader:SetShown(catalogOnly)
  frame.catalogTitle:SetShown(catalogOnly)
  frame.compactTop:SetText(catalogOnly and "Full View" or "Compact")
  frame.compactTop:SetWidth(catalogOnly and 82 or 72)
  frame.filtersTop:SetWidth(catalogOnly and 94 or 82)
  frame.toolbar:ClearAllPoints()
  if catalogOnly then
    frame.toolbar:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -1)
  else
    frame.toolbar:SetPoint("TOPLEFT", frame.sidebar, "TOPRIGHT", 8, 0)
  end
  frame.toolbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, catalogOnly and -46 or -70)
  frame.toolbar:SetHeight(catalogOnly and 128 or 72)
  frame.search:ClearAllPoints()
  frame.panelTop:ClearAllPoints()
  frame.modeTop:ClearAllPoints()
  frame.filtersTop:ClearAllPoints()
  if catalogOnly then
    frame.search:SetPoint("TOPLEFT", frame.toolbar, "TOPLEFT", 10, -38)
    frame.search:SetPoint("TOPRIGHT", frame.toolbar, "TOPRIGHT", -166, -38)
    frame.filtersTop:SetPoint("TOPRIGHT", frame.toolbar, "TOPRIGHT", -10, -38)
    frame.modeTop:SetPoint("RIGHT", frame.filtersTop, "LEFT", -4, 0)
  else
    frame.search:SetPoint("TOPLEFT", frame.toolbar, "TOPLEFT", 10, -9)
    frame.search:SetPoint("TOPRIGHT", frame.toolbar, "TOPRIGHT", -226, -9)
    frame.panelTop:SetPoint("TOPRIGHT", frame.toolbar, "TOPRIGHT", -10, -9)
    frame.modeTop:SetPoint("RIGHT", frame.panelTop, "LEFT", -4, 0)
    frame.filtersTop:SetPoint("RIGHT", frame.modeTop, "LEFT", -4, 0)
  end
  for index = 1, #frame.ownershipButtons do frame.ownershipButtons[index]:ClearAllPoints() end
  if catalogOnly then
    for index = 1, #frame.ownershipButtons do frame.ownershipButtons[index]:SetWidth(110) end
    frame.ownershipButtons[1]:SetPoint("TOPLEFT", frame.toolbar, "TOPLEFT", 10, -67)
  else
    frame.ownershipButtons[1]:SetWidth(54)
    frame.ownershipButtons[2]:SetWidth(66)
    frame.ownershipButtons[3]:SetWidth(54)
    frame.ownershipButtons[1]:SetPoint("BOTTOMLEFT", frame.toolbar, "BOTTOMLEFT", 10, 8)
  end
  for index = 2, #frame.ownershipButtons do frame.ownershipButtons[index]:SetPoint("LEFT", frame.ownershipButtons[index - 1], "RIGHT", 0, 0) end
  frame.sortTop:ClearAllPoints()
  frame.sortTop:SetPoint("LEFT", frame.ownershipButtons[#frame.ownershipButtons], "RIGHT", 8, 0)
  self:RefreshCompactExpansions()
  self:UpdateResponsiveLayout()
  frame._applyingShellLayout = nil
end

function CatalogView:RequestSearchRefresh()
  self._searchToken = (self._searchToken or 0) + 1
  local token = self._searchToken
  if self._searchTimer then self._searchTimer:Cancel() self._searchTimer = nil end
  if _G.C_Timer and _G.C_Timer.NewTimer then
    self._searchTimer = _G.C_Timer.NewTimer(0.15, function()
      CatalogView._searchTimer = nil
      if CatalogView._searchToken ~= token then return end
      CatalogView:Refresh(true)
    end)
  else
    self:Refresh(true)
  end
end

function CatalogView:InvalidateDisplay()
  self._displayRevision = (self._displayRevision or 0) + 1
  self:Refresh(false)
end

function CatalogView:ReleaseQueryView()
  local frame = self.frame
  if not frame then return end
  if frame.filteredRecords then wipe(frame.filteredRecords) end
  frame.filteredSignature = nil
  frame.groupModel = nil
  frame.groupModelSignature = nil
  frame.groupLayoutSignature = nil
  frame.groupHeight = nil
  frame.groupTotal = nil
  frame.groupEntryCount = 0
  for index = 1, #(frame.groupEntries or {}) do wipe(frame.groupEntries[index]) end
end

function CatalogView:RefreshCategoryCounts()
  local frame = self.frame
  if not frame or not frame.categoryButtons then return end
  local collection = NS.Systems.Collection
  if collection and not collection.snapshotReady then collection:RequestSnapshot() end
  local revision = table.concat({ tostring(NS.Systems.Catalog.revision or 0), tostring(collection and collection.revision or 0), tostring(collection and collection.snapshotReady), tostring(collection and collection.loading) }, ":")
  if frame.categoryCountsRevision == revision then return end
  frame.categoryCountsRevision = revision
  local buckets = {}
  local function Add(bucketName, key, owned)
    local bucket = buckets[bucketName]
    if not bucket then
      bucket = { total = 0, owned = 0, seen = {}, collected = {} }
      buckets[bucketName] = bucket
    end
    if not bucket.seen[key] then
      bucket.seen[key] = true
      bucket.total = bucket.total + 1
    end
    if owned and not bucket.collected[key] then
      bucket.collected[key] = true
      bucket.owned = bucket.owned + 1
    end
  end
  local records = NS.Systems.Catalog.ordered or {}
  local ownershipReady = collection and collection.snapshotReady
  for index = 1, #records do
    local record = records[index]
    local key = tostring(record.decorID or record.itemID or record.id or record.storageKey or index)
    local owned = ownershipReady and collection.owned[tonumber(record.decorID)] == true
    Add("All", key, owned)
    Add(record.category or "Uncategorized", key, owned)
    if type(record.requirements) == "table" then
      if record.requirements.achievement then Add("Requirement:Achievement", key, owned) end
      if record.requirements.quest then Add("Requirement:Quest", key, owned) end
    end
  end
  for index = 1, #frame.categoryButtons do
    local button = frame.categoryButtons[index]
    local option = button.option
    local bucketKey = option.requirement and ("Requirement:" .. option.requirement) or option.key
    local bucket = buckets[bucketKey] or { owned = 0, total = 0 }
    local categoryReady = NS.Systems.SourceAdapter:IsCategoryReady(option.key, option.requirement, option.sourceType)
    if not categoryReady then
      button:SetText(option.label)
    elseif ownershipReady then
      button:SetText(string.format("%s (%d / %d)", option.label, bucket.owned, bucket.total))
    else
      button:SetText(string.format("%s (? / %d)", option.label, bucket.total))
    end
  end
end

function CatalogView:EnsureRowPool(count)
  local frame = self.frame
  if not frame then return end
  count = math.max(0, math.ceil(tonumber(count) or 0))
  for index = #frame.rows + 1, count do
    local row = self:CreateRow(frame.content, frame.scroll)
    row:Hide()
    frame.rows[index] = row
  end
end

function CatalogView:GetFilteredRecords(query)
  local frame = self.frame
  local signature = table.concat({
    tostring(NS.Systems.Catalog.revision or 0),
    tostring(NS.Systems.Collection.revision or 0),
    tostring(NS.Systems.Favorites.revision or 0),
    tostring(NS.Systems.Tracker.revision or 0),
    tostring(NS.Systems.Requirements.revision or 0),
    tostring(query.category or ""),
    tostring(query.search or ""),
    tostring(query.favoriteOnly == true),
    tostring(query.trackedOnly == true),
    tostring(query.ownership or ""),
    tostring(query.expansion or ""),
    tostring(query.profession or ""),
    tostring(query.class or ""),
    tostring(query.sourceType or ""),
    tostring(query.faction or ""),
    tostring(query.zone or ""),
    tostring(query.size or ""),
    tostring(query.budgetCost or ""),
    tostring(query.requirement or ""),
    tostring(query.dyeability or ""),
    tostring(query.subcategory or ""),
    NS.Systems.QueryState:GetColorSignature(),
    tostring(query.hidePvp == true),
    tostring(query.requiresReputation == true),
    tostring(query.requiresRenown == true),
    tostring(query.questCompleted == true),
    tostring(query.achievementCompleted == true),
  }, "\031")
  local records = frame.filteredRecords
  if not records then
    records = {}
    frame.filteredRecords = records
  end
  if frame.filteredSignature ~= signature then
    wipe(records)
    local seen = {}
    NS.Systems.Pipeline:ForEach(query, function(record)
      local key = record.decorID and ("d:" .. tostring(record.decorID)) or record.itemID and ("i:" .. tostring(record.itemID)) or record.id and ("r:" .. tostring(record.id))
      if not key or not seen[key] then
        if key then seen[key] = true end
        records[#records + 1] = record
      end
    end)
    frame.filteredSignature = signature
  end
  return records
end

function CatalogView:ScrollBy(delta)
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local scroll = frame.scroll
  local _, height = self:GetLayout()
  local step = math.min(height, 72)
  NS.UI.Controls:SetScrollOffset(scroll, (scroll:GetVerticalScroll() or 0) - delta * step, true)
end

function CatalogView:SyncScrollBar()
  local frame = self.frame
  local scroll = frame and frame.scroll
  if scroll then NS.UI.Controls:SyncScrollFrame(scroll) end
end

function CatalogView:CreateRow(parent, scroll)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  Backdrop(row, COLOR.panel, COLOR.border)
  row.imageBG = row:CreateTexture(nil, "BACKGROUND")
  row.imageBG:SetColorTexture(0.018, 0.021, 0.023, 1)
  row.imageGlow = row:CreateTexture(nil, "BORDER")
  row.imageGlow:SetPoint("TOPLEFT", row.imageBG, "TOPLEFT", 2, -2)
  row.imageGlow:SetPoint("BOTTOMRIGHT", row.imageBG, "BOTTOMRIGHT", -2, 2)
  row.imageGlow:SetColorTexture(0.90, 0.72, 0.18, 0.065)
  row.imageEdges = {}
  for index = 1, 4 do
    local edge = row:CreateTexture(nil, "BORDER")
    edge:SetColorTexture(COLOR.border[1], COLOR.border[2], COLOR.border[3], 0.55)
    row.imageEdges[index] = edge
  end
  row.imageEdges[1]:SetPoint("TOPLEFT", row.imageBG, "TOPLEFT")
  row.imageEdges[1]:SetPoint("TOPRIGHT", row.imageBG, "TOPRIGHT")
  row.imageEdges[1]:SetHeight(1)
  row.imageEdges[2]:SetPoint("BOTTOMLEFT", row.imageBG, "BOTTOMLEFT")
  row.imageEdges[2]:SetPoint("BOTTOMRIGHT", row.imageBG, "BOTTOMRIGHT")
  row.imageEdges[2]:SetHeight(1)
  row.imageEdges[3]:SetPoint("TOPLEFT", row.imageBG, "TOPLEFT")
  row.imageEdges[3]:SetPoint("BOTTOMLEFT", row.imageBG, "BOTTOMLEFT")
  row.imageEdges[3]:SetWidth(1)
  row.imageEdges[4]:SetPoint("TOPRIGHT", row.imageBG, "TOPRIGHT")
  row.imageEdges[4]:SetPoint("BOTTOMRIGHT", row.imageBG, "BOTTOMRIGHT")
  row.imageEdges[4]:SetWidth(1)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(34, 34)
  row.icon:SetPoint("LEFT", 8, 0)
  row.check = row:CreateTexture(nil, "OVERLAY")
  row.check:SetSize(16, 16)
  row.check:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 3, -3)
  row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.check:Hide()
  row.dye = CreateFrame("Frame", nil, row)
  row.dye:SetFrameLevel(row:GetFrameLevel() + 10)
  row.dye:SetSize(58, 16)
  row.dye.bg = row.dye:CreateTexture(nil, "BACKGROUND")
  row.dye.bg:SetAllPoints()
  row.dye.bg:SetColorTexture(0, 0, 0, 0.78)
  row.dye.text = row.dye:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.dye.text:SetPoint("CENTER")
  row.dye.text:SetTextColor(0.4, 0.9, 1, 1)
  row.dye:Hide()
  row.ownership = CreateBadge(row, "GameFontNormalSmall")
  row.requirement = CreateBadge(row, "GameFontNormalSmall", true)
  row.requirement:SetBackdrop(nil)
  NS.UI.Controls.backdrops[row.requirement] = nil
  row.requirement:SetFrameLevel(row:GetFrameLevel() + 10)
  row.requirement:RegisterForClicks("LeftButtonUp")
  row.requirement:SetScript("OnClick", function(button)
    if button.record then NS.UI.ItemInteractions:ShowLinks(button.record) end
  end)
  row.requirement:SetScript("OnEnter", function(button)
    if not button.record or not _G.GameTooltip then return end
    _G.GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    _G.GameTooltip:AddLine("Requirement links", 1, 0.82, 0.18)
    local text = NS.Systems.Requirements:Text(button.record)
    if text ~= "" then _G.GameTooltip:AddLine(text, 0.9, 0.9, 0.9, true) end
    _G.GameTooltip:AddLine("Click to open Wowhead links", 0.65, 0.8, 1)
    _G.GameTooltip:Show()
  end)
  row.requirement:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  row.sources = CreateFrame("Button", nil, row, "BackdropTemplate")
  Backdrop(row.sources, COLOR.row, COLOR.border)
  row.sources:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
  row.sources.text = row.sources:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  row.sources.text:SetPoint("CENTER")
  row.sources:Hide()
  row.sources:SetFrameLevel(row:GetFrameLevel() + 10)
  row.sources:RegisterForClicks("LeftButtonUp")
  row.sources:SetScript("OnClick", function(button)
    local owner = button:GetParent()
    local record = button.record or (owner and owner.record)
    if record then NS.UI.ItemInteractions:ShowSources(owner or button, record) end
  end)
  row.sources:SetScript("OnEnter", function(button)
    local record = button.record
    if not record or not _G.GameTooltip then return end
    local count, label = NS.UI.ItemInteractions:GetSourceInfo(record)
    _G.GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    _G.GameTooltip:SetText(label .. " (" .. tostring(count) .. ")")
    _G.GameTooltip:AddLine("Click to choose a location and open its map", 0.65, 0.8, 1)
    _G.GameTooltip:Show()
  end)
  row.sources:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  row.faction = row:CreateTexture(nil, "OVERLAY")
  row.faction:SetSize(24, 24)
  row.faction:Hide()
  row.favorite = NS.UI.FavoriteStar:Create(row, 20)
  row.favorite:SetPoint("TOPRIGHT", -10, -7)
  row.tracked = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.tracked:SetPoint("RIGHT", row.favorite, "LEFT", -8, 0)
  row.tracked:SetText("Tracked")
  row.tracked:SetTextColor(1, 0.78, 0.10, 1)
  row.tracked:Hide()
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, -3)
  row.title:SetPoint("TOPRIGHT", -10, -3)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  if row.title.SetMaxLines then row.title:SetMaxLines(2) end
  SetTextColor(row.title, COLOR.text)
  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 10, 4)
  row.meta:SetPoint("BOTTOMRIGHT", -10, 4)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetWordWrap(false)
  if row.meta.SetMaxLines then row.meta:SetMaxLines(2) end
  SetTextColor(row.meta, COLOR.muted)
  row.attributes = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.attributes:SetJustifyH("LEFT")
  row.attributes:SetWordWrap(true)
  if row.attributes.SetMaxLines then row.attributes:SetMaxLines(2) end
  SetTextColor(row.attributes, COLOR.muted)
  row.groupBar = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.groupBar:SetSize(140, 8)
  Backdrop(row.groupBar, { 0.05, 0.05, 0.06, 0.8 }, { 0.15, 0.15, 0.18, 0.9 })
  row.groupBar.fill = row.groupBar:CreateTexture(nil, "ARTWORK")
  row.groupBar.fill:SetPoint("LEFT", 1, 0)
  row.groupBar.fill:SetHeight(6)
  row.groupBar.fill:SetColorTexture(0.90, 0.72, 0.18, 1)
  row.groupBar:Hide()
  row.groupComplete = row:CreateTexture(nil, "OVERLAY")
  row.groupComplete:SetSize(14, 14)
  row.groupComplete:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.groupComplete:Hide()
  row:SetScript("OnClick", function(button, mouseButton)
    if button.groupKey then
      NS.Systems.QueryState:ToggleGroup(button.groupKey)
      CatalogView._groupRevision = (CatalogView._groupRevision or 0) + 1
      CatalogView:Refresh(false)
      return
    end
    if _G.IsShiftKeyDown and _G.IsShiftKeyDown() then
      NS.UI.ListSelector:Show(button, button.record, function(id, record)
        NS.Systems.Lists:Toggle(record, id)
        CatalogView:Refresh(false)
        if NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
      end)
    elseif NS.UI.ItemInteractions:HandleClick(button.record) then
      return
    elseif mouseButton == "RightButton" then
      NS.UI.ItemInteractions:OpenSource(button, button.record)
    else
      CatalogView.selected = button.record
      local profile = NS.Systems.Database:GetProfile()
      local panelOpen = profile.ui.panelVisible ~= false and CatalogView.frame:GetWidth() >= 1080
      if panelOpen then
        NS.UI.Inspector:Show(button.record)
      else
        NS.UI.ItemInteractions:Preview(button.record)
      end
    end
  end)
  NS.UI.Controls:ForwardScrollWheel(row, scroll)
  row:SetScript("OnEnter", function(self)
    if self.groupKey then return end
    if not self.record then return end
    NS.UI.ItemTooltip:Show(self, self.record, "catalog")
  end)
  row:SetScript("OnLeave", function() NS.UI.ItemTooltip:Hide() end)
  row:HookScript("OnEnter", function(self)
    self:SetBackdropColor(COLOR.hover[1], COLOR.hover[2], COLOR.hover[3], COLOR.hover[4])
  end)
  row:HookScript("OnLeave", function(self)
    local color = self.groupKey and COLOR.header or COLOR.panel
    self:SetBackdropColor(color[1], color[2], color[3], color[4])
  end)
  return row
end

function CatalogView:BindItemRow(row, record, columns, rowWidth, lightweight)
  row.groupKey = nil
  row.record = record
  row.requirement.record = record
  row.sources.record = record
  row.icon:Show()
  row.groupBar:Hide()
  row.groupComplete:Hide()
  local needsBind = row._displayRecord ~= record or row._displayRevision ~= self._displayRevision or (not lightweight and row._displayLightweight)
  if needsBind then
    row._displayRecord = record
    row._displayRevision = self._displayRevision
    row._displayLightweight = lightweight == true
    local title, icon, owned
    if lightweight then
      title = record.title or (record.itemID and ("Item " .. tostring(record.itemID))) or ("Decor " .. tostring(record.decorID or "?"))
      icon = record.icon
      owned = NS.Systems.Collection:IsOwned(record)
    else
      title, icon, owned = NS.Systems.Housing:GetCatalogDisplay(record)
    end
    local placeholder = not icon or icon == QUESTION_MARK_ICON or tonumber(icon) == 134400
    row.icon:SetTexture(placeholder and nil or icon)
    row.icon:SetAlpha(placeholder and 0 or 1)
    row.title:SetText(title)
    row.check:SetShown(owned)
    row._owned = owned
    row._dyeLabel, row._dyeAccent = CardMediaLabel(record)
    row.dye.text:SetText(row._dyeLabel or "")
    if row._dyeAccent then row.dye.text:SetTextColor(0.4, 0.9, 1, 1) else row.dye.text:SetTextColor(0.58, 0.61, 0.65, 1) end
    local requirementValues = lightweight and {} or NS.Systems.Requirements:Get(record)
    row._requirementLabel, row._requirementState = NS.Systems.Requirements:Badge(record, requirementValues)
    row.requirement.text:SetText(NS.Systems.Requirements:Display(record, requirementValues))
    row._requirementCount = #requirementValues
    row._sourceCount, row._sourceLabel = NS.UI.ItemInteractions:GetSourceInfo(record)
    row.sources.text:SetText(tostring(row._sourceLabel) .. " (" .. tostring(row._sourceCount) .. ")")
    row.attributes:SetText(CardAttributeText(record))
    local factionTexture = FactionTexture(record.faction)
    row._factionTexture = factionTexture
    row.faction:SetTexture(factionTexture)
    row.faction:SetShown(factionTexture ~= nil)
    row.tracked:Hide()
    row.meta:SetText(CardSourceText(record))
  end
  row.favorite:SetRecord(record)
  row.icon:ClearAllPoints()
  row.check:ClearAllPoints()
  row.dye:ClearAllPoints()
  row.ownership:ClearAllPoints()
  row.requirement:ClearAllPoints()
  row.sources:ClearAllPoints()
  row.title:ClearAllPoints()
  row.meta:ClearAllPoints()
  row.attributes:ClearAllPoints()
  row.favorite:ClearAllPoints()
  row.tracked:ClearAllPoints()
  row.faction:ClearAllPoints()
  row.imageBG:ClearAllPoints()
  if columns > 1 then
    row.imageBG:SetPoint("TOPLEFT", 8, -8)
    row.imageBG:SetPoint("TOPRIGHT", -8, -8)
    row.imageBG:SetHeight(158)
    row.imageBG:Show()
    row.imageGlow:Show()
    for index = 1, #row.imageEdges do row.imageEdges[index]:Show() end
    row.icon:SetSize(math.min(126, rowWidth - 30), 126)
    row.icon:SetPoint("CENTER", row.imageBG, "CENTER", 0, 0)
    row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    row.check:SetVertexColor(0.2, 1, 0.2, 1)
    row.check:SetSize(16, 16)
    row.check:SetPoint("TOP", row.imageBG, "TOP", 0, -6)
    row.check:SetShown(row._owned == true)
    row.ownership:Hide()
    row.dye:SetSize(math.max(58, math.min(rowWidth - 24, 10 + (row.dye.text:GetStringWidth() or 50))), 16)
    row.dye:SetPoint("BOTTOMLEFT", row.imageBG, "BOTTOMLEFT", 2, 2)
    row.dye:SetShown(row._dyeLabel ~= nil)
    row.requirement:SetHeight((row._requirementCount or 0) > 1 and 34 or 18)
    row.requirement:SetPoint("TOPLEFT", 10, -245)
    row.requirement:SetPoint("TOPRIGHT", -10, -245)
    row.requirement:SetShown(row._requirementLabel ~= nil)
    row.requirement.text:ClearAllPoints()
    row.requirement.text:SetPoint("LEFT", 3, 0)
    row.requirement.text:SetPoint("RIGHT", -3, 0)
    row.requirement.text:SetJustifyH("LEFT")
    row.requirement.text:SetWordWrap(false)
    row.title:SetPoint("TOPLEFT", 10, -177)
    row.title:SetPoint("TOPRIGHT", -10, -177)
    row.title:SetJustifyH("LEFT")
    row.title:SetWordWrap(true)
    row.attributes:SetPoint("TOPLEFT", 10, -213)
    row.attributes:SetPoint("TOPRIGHT", -10, -213)
    row.meta:SetPoint("BOTTOMLEFT", 10, 10)
    row.meta:SetPoint("BOTTOMRIGHT", (row._sourceCount or 0) > 1 and -90 or -10, 10)
    row.meta:SetJustifyH("LEFT")
    row.meta:SetWordWrap(true)
    row.favorite:SetPoint("TOPLEFT", 13, -13)
    row.faction:SetSize(24, 24)
    row.faction:SetPoint("TOPRIGHT", row.imageBG, "TOPRIGHT", -8, -8)
    row.faction:SetShown(row._factionTexture ~= nil)
    row.tracked:SetPoint("TOPRIGHT", -12, -42)
    row.sources:SetSize(76, 17)
    row.sources:SetPoint("BOTTOMRIGHT", -8, 7)
    row.sources:SetShown((row._sourceCount or 0) > 1)
  elseif NS.Systems.Database:GetProfile().ui.view == "text" then
    local catalogOnly = NS.Systems.Database:GetProfile().ui.catalogOnly == true
    row.imageBG:Hide()
    row.imageGlow:Hide()
    for index = 1, #row.imageEdges do row.imageEdges[index]:Hide() end
    row.icon:SetSize(24, 24)
    row.icon:SetPoint("LEFT", 7, 0)
    row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    row.check:SetVertexColor(1, 1, 1, 1)
    row.check:SetSize(14, 14)
    row.check:SetPoint("TOP", row.icon, "TOP", 0, 2)
    row.check:SetShown(row._owned == true)
    row.dye:Hide()
    row.ownership:Hide()
    row.requirement:Hide()
    row.sources:SetSize(76, 17)
    row.sources:SetPoint("RIGHT", row.favorite, "LEFT", -8, 0)
    row.sources:SetShown((row._sourceCount or 0) > 1)
    row.attributes:Hide()
    row.title:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
    if catalogOnly then
      row.title:SetPoint("RIGHT", row, "RIGHT", -220, 0)
    elseif (row._sourceCount or 0) > 1 then
      row.title:SetPoint("RIGHT", row.sources, "LEFT", -8, 0)
    else
      row.title:SetPoint("RIGHT", row.favorite, "LEFT", -8, 0)
    end
    row.title:SetJustifyH("LEFT")
    row.title:SetWordWrap(false)
    row.favorite:SetPoint("RIGHT", -9, 0)
    row.tracked:SetPoint("RIGHT", row.favorite, "LEFT", -8, 0)
    if catalogOnly then
      row.meta:SetPoint("RIGHT", row, "RIGHT", -68, 0)
      row.meta:SetWidth(140)
      row.meta:SetJustifyH("RIGHT")
      row.meta:SetWordWrap(false)
    end
    row.faction:Hide()
  else
    row.imageBG:Hide()
    row.imageGlow:Hide()
    for index = 1, #row.imageEdges do row.imageEdges[index]:Hide() end
    row.icon:SetSize(34, 34)
    row.icon:SetPoint("LEFT", 8, 0)
    row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    row.check:SetVertexColor(1, 1, 1, 1)
    row.check:SetSize(14, 14)
    row.check:SetPoint("TOP", row.icon, "TOP", 0, 2)
    row.check:SetShown(row._owned == true)
    row.dye:Hide()
    row.ownership:Hide()
    row.requirement:Hide()
    row.sources:SetSize(76, 17)
    row.sources:SetPoint("RIGHT", row.favorite, "LEFT", -8, 0)
    row.sources:SetShown((row._sourceCount or 0) > 1)
    row.attributes:Hide()
    row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, -3)
    row.title:SetPoint("TOPRIGHT", -10, -3)
    row.title:SetJustifyH("LEFT")
    row.title:SetWordWrap(false)
    row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 10, 4)
    row.meta:SetPoint("BOTTOMRIGHT", (row._sourceCount or 0) > 1 and -92 or -10, 4)
    row.meta:SetJustifyH("LEFT")
    row.favorite:SetPoint("TOPRIGHT", -10, -7)
    row.tracked:SetPoint("RIGHT", row.favorite, "LEFT", -8, 0)
    row.faction:SetSize(16, 16)
    row.faction:SetPoint("RIGHT", row.tracked, "LEFT", -7, 0)
    row.faction:SetShown(row._factionTexture ~= nil)
  end
  if columns > 1 then row.attributes:Show() end
  local profile = NS.Systems.Database:GetProfile()
  row.meta:SetShown(profile.ui.catalogOnly == true or (profile.ui.view ~= "text" and profile.ui.compact ~= true))
  Backdrop(row, COLOR.panel, COLOR.border)
  row:Show()
end

function CatalogView:BindGroupRow(row, entry)
  row.record = nil
  row.requirement.record = nil
  row.sources.record = nil
  row.groupKey = entry.key
  row._displayRecord = nil
  row._displayRevision = nil
  row.imageBG:Hide()
  row.imageGlow:Hide()
  for index = 1, #row.imageEdges do row.imageEdges[index]:Hide() end
  row.icon:Hide()
  row.check:Hide()
  row.dye:Hide()
  row.ownership:Hide()
  row.requirement:Hide()
  row.sources:Hide()
  row.attributes:Hide()
  row.favorite:SetRecord(nil)
  row.tracked:Hide()
  row.faction:Hide()
  row.title:ClearAllPoints()
  row.title:SetPoint("TOPLEFT", 34 + entry.indent, -6)
  row.title:SetPoint("TOPRIGHT", -120, -6)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.title:SetText((entry.open and "|cffffc21a-|r  " or "|cffffc21a+|r  ") .. entry.label)
  row.meta:ClearAllPoints()
  row.meta:SetPoint("TOPRIGHT", -38, -7)
  row.meta:SetJustifyH("RIGHT")
  row.meta:SetText(string.format("%d / %d", entry.owned, entry.total))
  row.meta:Show()
  row.groupBar:ClearAllPoints()
  row.groupBar:SetPoint("BOTTOMLEFT", 14 + entry.indent, 5)
  row.groupBar.fill:SetWidth(math.max(0.5, 138 * (entry.total > 0 and math.min(1, entry.owned / entry.total) or 0)))
  row.groupBar:Show()
  row.groupComplete:ClearAllPoints()
  row.groupComplete:SetPoint("TOPRIGHT", -14, -6)
  row.groupComplete:SetShown(entry.total > 0 and entry.owned >= entry.total)
  Backdrop(row, COLOR.header, COLOR.border)
  row:Show()
end

function CatalogView:BuildGroupedModel(query)
  local profile = NS.Systems.Database:GetProfile()
  local function CountOwned(records)
    local owned = 0
    for index = 1, #records do
      if NS.Systems.Collection:IsOwned(records[index]) then owned = owned + 1 end
    end
    return owned
  end
  local all = self:GetFilteredRecords(query)
  local model = { groups = {}, total = #all }
  if profile.ui.category == "All" and not query.requirement and not query.sourceType then
    local buckets = {}
    local order = {}
    for index = 1, #all do
      local record = all[index]
      local name = record.category or "Other"
      if not buckets[name] then
        buckets[name] = {}
        order[#order + 1] = name
      end
      buckets[name][#buckets[name] + 1] = record
    end
    table.sort(order, function(left, right)
      local leftRank = GROUP_CATEGORY_RANK[left] or 999
      local rightRank = GROUP_CATEGORY_RANK[right] or 999
      if leftRank ~= rightRank then return leftRank < rightRank end
      return tostring(left) < tostring(right)
    end)
    for index = 1, #order do
      local name = order[index]
      model.groups[#model.groups + 1] = { key = "category:" .. tostring(name), label = name == "Drops" and "Drops/Encounters" or name, records = buckets[name], owned = CountOwned(buckets[name]) }
    end
  else
    local expansions = {}
    local expansionOrder = {}
    for index = 1, #all do
      local record = all[index]
      local expansion = NS.Systems.QueryState:NormalizeExpansion(record.expansion) or "Other"
      local zone = record.zone or "Other"
      if not expansions[expansion] then
        expansions[expansion] = { records = {}, zones = {}, order = {} }
        expansionOrder[#expansionOrder + 1] = expansion
      end
      local group = expansions[expansion]
      group.records[#group.records + 1] = record
      if not group.zones[zone] then
        group.zones[zone] = {}
        group.order[#group.order + 1] = zone
      end
      group.zones[zone][#group.zones[zone] + 1] = record
    end
    table.sort(expansionOrder, function(left, right)
      local leftRank = EXPANSION_RANK[left] or 999
      local rightRank = EXPANSION_RANK[right] or 999
      if leftRank ~= rightRank then return leftRank < rightRank end
      return tostring(left) < tostring(right)
    end)
    local groupContext = query.requirement or query.sourceType or profile.ui.category
    for index = 1, #expansionOrder do
      local expansion = expansionOrder[index]
      local source = expansions[expansion]
      local group = { key = "expansion:" .. tostring(groupContext) .. ":" .. tostring(expansion), label = expansion, records = source.records, owned = CountOwned(source.records), children = {} }
      table.sort(source.order, function(left, right) return tostring(left) < tostring(right) end)
      for zoneIndex = 1, #source.order do
        local zone = source.order[zoneIndex]
        group.children[#group.children + 1] = { key = group.key .. ":zone:" .. tostring(zone), label = zone, records = source.zones[zone], owned = CountOwned(source.zones[zone]) }
      end
      model.groups[#model.groups + 1] = group
    end
  end
  return model
end

function CatalogView:BuildGroupedEntries(model, columns, rowHeight)
  local open = NS.Systems.QueryState:GetGroupOpen()
  local contentWidth = math.max(1, self.frame.content:GetWidth() or 1)
  local entries = self.frame.groupEntries or {}
  self.frame.groupEntries = entries
  local used = 0
  local y = 0
  local function Entry()
    used = used + 1
    local entry = entries[used]
    if not entry then
      entry = {}
      entries[used] = entry
    else
      wipe(entry)
    end
    return entry
  end
  local function Header(group, indent)
    local entry = Entry()
    entry.kind = "header"
    entry.key = group.key
    entry.label = group.label
    entry.owned = group.owned or 0
    entry.total = #group.records
    entry.open = open[group.key] == true
    entry.indent = indent or 0
    entry.x = indent or 0
    entry.y = y
    entry.w = contentWidth - (indent or 0) - 4
    entry.h = 40
    y = y + 44
    return entry.open
  end
  local function Items(records, indent)
    local available = contentWidth - indent
    local itemColumns = columns > 1 and math.max(1, math.floor(available / 176)) or 1
    local width = available / itemColumns
    local entry = Entry()
    entry.kind = "items"
    entry.records = records
    entry.x = indent
    entry.y = y
    entry.w = available
    entry.h = math.ceil(#records / itemColumns) * rowHeight
    entry.columns = itemColumns
    entry.rowWidth = width
    entry.rowHeight = rowHeight
    y = y + entry.h
  end
  for index = 1, #model.groups do
    local group = model.groups[index]
    if Header(group, 0) then
      if group.children then
        for childIndex = 1, #group.children do
          local child = group.children[childIndex]
          if Header(child, 16) then Items(child.records, 32) end
        end
      else
        Items(group.records, 16)
      end
    end
  end
  for index = used + 1, #entries do wipe(entries[index]) end
  self.frame.groupEntryCount = used
  return entries, math.max(1, y), model.total
end

function CatalogView:RenderFlat(query, columns, rowHeight, rowWidth, scrollOffset, lightweight)
  local frame = self.frame
  local filtered = self:GetFilteredRecords(query)
  local total = #filtered
  frame.count:SetText(tostring(total) .. " items")
  frame.catalogTitle:SetText("Decor Catalog  -  " .. tostring(total) .. " items")
  if frame.filterPanel and frame.filterPanel.summary then frame.filterPanel.summary:SetText(tostring(total) .. " matching items - drag header to move") end
  frame.content:SetHeight(math.max(1, math.ceil(total / columns) * rowHeight))
  NS.UI.Controls:SetScrollOffset(frame.scroll, scrollOffset, false)
  self:SyncScrollBar()
  local overscan = columns > 1 and 1 or OVERSCAN
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / rowHeight) - overscan) * columns
  local visible = math.min(math.max(0, total - first), (math.ceil((frame.scroll:GetHeight() or 480) / rowHeight) + overscan * 2) * columns)
  self:EnsureRowPool(visible)
  local rowIndex = 0
  local last = math.min(total, first + visible)
  for absolute = first + 1, last do
    local record = filtered[absolute]
    rowIndex = rowIndex + 1
    local row = frame.rows[rowIndex]
    local position = absolute - 1
    local column = position % columns
    local line = math.floor(position / columns)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", column * rowWidth, -(line * rowHeight))
    if columns == 1 then row:SetPoint("TOPRIGHT", 0, -(line * rowHeight)) end
    row:SetWidth(rowWidth - 4)
    row:SetHeight(rowHeight - 2)
    row.groupKey = nil
    row.icon:Show()
    row.groupBar:Hide()
    row.groupComplete:Hide()
    self:BindItemRow(row, record, columns, rowWidth, lightweight)
  end
  for index = rowIndex + 1, #frame.rows do
    local row = frame.rows[index]
    row.record = nil
    row.requirement.record = nil
    row.sources.record = nil
    row._displayRecord = nil
    row._displayRevision = nil
    row._displayLightweight = nil
    row._factionTexture = nil
    row._dyeLabel = nil
    row.favorite:SetRecord(nil)
    row.dye:Hide()
    row.ownership:Hide()
    row.requirement:Hide()
    row.sources:Hide()
    row.attributes:Hide()
    row:Hide()
  end
end

function CatalogView:RenderGrouped(query, columns, rowHeight, scrollOffset, lightweight)
  local frame = self.frame
  local modelSignature = table.concat({
    tostring(NS.Systems.Catalog.revision or 0),
    tostring(NS.Systems.Collection.revision or 0),
    tostring(NS.Systems.Requirements.revision or 0),
    tostring(self._displayRevision or 0),
    tostring(query.category or ""),
    tostring(query.sourceType or ""),
    tostring(query.faction or ""),
    tostring(query.expansion or ""),
    tostring(query.profession or ""),
    tostring(query.zone or ""),
    tostring(query.size or ""),
    tostring(query.budgetCost or ""),
    tostring(query.requirement or ""),
    tostring(query.dyeability or ""),
    tostring(query.subcategory or ""),
    NS.Systems.QueryState:GetColorSignature(),
    tostring(query.hidePvp == true),
    tostring(query.requiresReputation == true),
    tostring(query.requiresRenown == true),
    tostring(query.questCompleted == true),
    tostring(query.achievementCompleted == true),
    tostring(query.ownership or ""),
  }, ":")
  if frame.groupModelSignature ~= modelSignature then
    frame.groupModel = self:BuildGroupedModel(query)
    frame.groupModelSignature = modelSignature
    frame.groupLayoutSignature = nil
  end
  local signature = table.concat({
    modelSignature,
    tostring(self._groupRevision or 0),
    tostring(columns),
    tostring(rowHeight),
    tostring(math.floor(frame.content:GetWidth() or 0)),
  }, ":")
  if frame.groupLayoutSignature ~= signature then
    frame.groupEntries, frame.groupHeight, frame.groupTotal = self:BuildGroupedEntries(frame.groupModel, columns, rowHeight)
    frame.groupLayoutSignature = signature
  end
  local entries = frame.groupEntries or {}
  local height = frame.groupHeight or 1
  local total = frame.groupTotal or 0
  frame.count:SetText(tostring(total) .. " items")
  frame.catalogTitle:SetText("Decor Catalog  -  " .. tostring(total) .. " items")
  if frame.filterPanel and frame.filterPanel.summary then
    frame.filterPanel.summary:SetText(tostring(total) .. " matching items - drag header to move")
  end
  frame.content:SetHeight(height)
  NS.UI.Controls:SetScrollOffset(frame.scroll, scrollOffset or 0, false)
  self:SyncScrollBar()
  local top = frame.scroll:GetVerticalScroll() or 0
  local bottom = top + (frame.scroll:GetHeight() or 480)
  local required = 0
  for index = 1, frame.groupEntryCount or 0 do
    local entry = entries[index]
    if entry.y + entry.h >= top - rowHeight and entry.y <= bottom + rowHeight then
      if entry.kind == "header" then
        required = required + 1
      else
        local overscan = entry.columns > 1 and 1 or OVERSCAN
        local firstLine = math.max(0, math.floor((top - entry.y) / entry.rowHeight) - overscan)
        local lastLine = math.min(math.ceil(#entry.records / entry.columns) - 1, math.floor((bottom - entry.y) / entry.rowHeight) + overscan)
        local firstRecord = firstLine * entry.columns + 1
        local lastRecord = math.min(#entry.records, (lastLine + 1) * entry.columns)
        if lastRecord >= firstRecord then required = required + lastRecord - firstRecord + 1 end
      end
    end
  end
  self:EnsureRowPool(required)
  local rowIndex = 0
  for index = 1, frame.groupEntryCount or 0 do
    local entry = entries[index]
    if entry.y + entry.h >= top - rowHeight and entry.y <= bottom + rowHeight then
      if entry.kind == "header" then
        rowIndex = rowIndex + 1
        if rowIndex > #frame.rows then break end
        local row = frame.rows[rowIndex]
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", entry.x, -entry.y)
        row:SetWidth(entry.w)
        row:SetHeight(entry.h)
        self:BindGroupRow(row, entry)
      else
        local overscan = entry.columns > 1 and 1 or OVERSCAN
        local firstLine = math.max(0, math.floor((top - entry.y) / entry.rowHeight) - overscan)
        local lastLine = math.min(math.ceil(#entry.records / entry.columns) - 1, math.floor((bottom - entry.y) / entry.rowHeight) + overscan)
        for line = firstLine, lastLine do
          for column = 0, entry.columns - 1 do
            local recordIndex = line * entry.columns + column + 1
            local record = entry.records[recordIndex]
            if record then
              rowIndex = rowIndex + 1
              if rowIndex > #frame.rows then break end
              local row = frame.rows[rowIndex]
              row:ClearAllPoints()
              row:SetPoint("TOPLEFT", entry.x + column * entry.rowWidth, -(entry.y + line * entry.rowHeight))
              row:SetWidth(entry.rowWidth - 4)
              row:SetHeight(entry.rowHeight - 2)
              self:BindItemRow(row, record, entry.columns, entry.rowWidth, lightweight)
            end
          end
          if rowIndex >= #frame.rows then break end
        end
      end
    end
    if rowIndex >= #frame.rows then break end
  end
  for index = rowIndex + 1, #frame.rows do
    local row = frame.rows[index]
    row.record = nil
    row.requirement.record = nil
    row.sources.record = nil
    row.groupKey = nil
    row._displayRecord = nil
    row._displayRevision = nil
    row._displayLightweight = nil
    row.favorite:SetRecord(nil)
    row:Hide()
  end
end

function CatalogView:RefreshViewport(lightweight)
  local frame = self.frame
  if not frame or not frame:IsShown() or frame._hdRefreshing then return end
  local route = NS.Systems.QueryState:GetRoute()
  if route == "architect" or route == "pricing" or route == "alts" or route == "endeavors" or route == "statistics" then return end
  frame._hdRefreshing = true
  frame.query = frame.query or {}
  local query = NS.Systems.QueryState:Fill(frame.query)
  local columns, rowHeight, rowWidth = self:GetLayout()
  local scrollOffset = frame.scroll:GetVerticalScroll() or 0
  local profile = NS.Systems.Database:GetProfile()
  if profile.ui.catalogMode == "Sections" and route == "catalog" and (query.search or "") == "" then
    self:RenderGrouped(query, columns, rowHeight, scrollOffset, lightweight)
  else
    self:RenderFlat(query, columns, rowHeight, rowWidth, scrollOffset, lightweight)
  end
  frame._hdRefreshing = nil
end

function CatalogView:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorCatalog", UIParent, "BackdropTemplate")
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(100)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(false)
  NS.Systems.Layout:Restore(frame, "catalog")
  frame:SetClampedToScreen(false)
  frame:SetSize(1320, 760)
  Backdrop(frame, COLOR.background, COLOR.border)
  NS.UI.Controls:MakeMovable(frame, frame, "catalog")
  frame:Hide()

  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 7, -7)
  header:SetPoint("TOPRIGHT", -7, -7)
  header:SetHeight(62)
  Backdrop(header, COLOR.header, COLOR.border)
  frame.header = header

  local headerLine = header:CreateTexture(nil, "ARTWORK")
  headerLine:SetPoint("BOTTOMLEFT", 8, 5)
  headerLine:SetPoint("BOTTOMRIGHT", -8, 5)
  headerLine:SetHeight(1)
  headerLine:SetColorTexture(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 0.55)
  frame.headerLine = headerLine

  local logo = header:CreateTexture(nil, "ARTWORK")
  logo:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\UI\\logo.tga")
  logo:SetSize(360, 46)
  logo:SetPoint("TOP", 0, -4)
  frame.logo = logo

  local scaleLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  scaleLabel:SetPoint("TOPLEFT", 10, -15)
  scaleLabel:SetText("Scale")
  SetTextColor(scaleLabel, COLOR.accent)
  frame.scaleLabel = scaleLabel

  local scale = CreateFrame("Slider", nil, header, "BackdropTemplate")
  scale:SetPoint("LEFT", scaleLabel, "RIGHT", 10, 0)
  scale:SetSize(128, 14)
  scale:SetOrientation("HORIZONTAL")
  scale:SetMinMaxValues(0, 200)
  scale:SetValueStep(5)
  scale:SetObeyStepOnDrag(true)
  Backdrop(scale, COLOR.background, COLOR.border)
  frame.scaleSlider = scale
  local thumb = scale:CreateTexture(nil, "OVERLAY")
  thumb:SetSize(10, 14)
  thumb:SetColorTexture(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 1)
  scale:SetThumbTexture(thumb)
  thumb:Hide()
  local scaleFill = scale:CreateTexture(nil, "ARTWORK")
  scaleFill:SetPoint("LEFT", scale, "LEFT", 3, 0)
  scaleFill:SetHeight(8)
  scaleFill:SetColorTexture(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 1)

  local scaleValue = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  scaleValue:SetPoint("LEFT", scale, "RIGHT", 8, 0)
  scaleValue:SetWidth(32)
  SetTextColor(scaleValue, COLOR.text)
  frame.scaleValue = scaleValue
  local profile = NS.Systems.Database:GetProfile()
  local function Clamp(value, low, high)
    return math.max(low, math.min(high, value))
  end
  local function DisplayToEffective(value)
    value = Clamp(value or 0, 0, 200)
    local offset = (value - 100) / 100
    return Clamp(value + 20 * (1 - offset * offset), 0, 200)
  end
  local function EffectiveToDisplay(value)
    local low, high = 0, 200
    for _ = 1, 20 do
      local middle = (low + high) / 2
      if DisplayToEffective(middle) < value then low = middle else high = middle end
    end
    return Clamp(math.floor((low + high) / 2 + 0.5), 0, 200)
  end
  local function WidthToDisplay(width)
    return EffectiveToDisplay(((Clamp(width, 880, 1700) - 880) / 820) * 200)
  end
  local function DisplayToWidth(value)
    return 880 + (DisplayToEffective(value) / 200) * 820
  end
  local function SetScaleVisual(value)
    value = Clamp(math.floor((value or 0) / 5 + 0.5) * 5, 0, 200)
    scaleFill:SetWidth(math.max(2, 122 * value / 200))
    scaleValue:SetText(tostring(value))
  end
  local function ApplyScale(value)
    value = Clamp(math.floor((value or 0) / 5 + 0.5) * 5, 0, 200)
    local width = math.floor(DisplayToWidth(value) + 0.5)
    local rootScale = width / 1320
    NS.Systems.QueryState:SetWindowMetrics(width, math.floor(760 * rootScale + 0.5), rootScale)
    frame:SetSize(1320, 760)
    frame:SetScale(rootScale)
    SetScaleVisual(value)
  end
  frame.ApplyWindowScale = ApplyScale
  frame.GetWindowScaleDisplay = function() return scale:GetValue() end
  frame.scaleSlider = scale
  local initialWidth = profile and tonumber(profile.ui.width)
  local initialDisplay = initialWidth and WidthToDisplay(initialWidth) or Clamp(math.floor(((profile and tonumber(profile.ui.scale)) or 0.87) * 100 + 0.5), 0, 200)
  scale:SetValue(initialDisplay)
  ApplyScale(initialDisplay)
  scale:SetScript("OnValueChanged", function(_, value)
    SetScaleVisual(value)
  end)
  scale:SetScript("OnMouseUp", function(self)
    ApplyScale(self:GetValue())
  end)

  local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
  sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 7, 46)
  sidebar:SetWidth(204)
  Backdrop(sidebar, COLOR.header, COLOR.border)
  frame.sidebar = sidebar

  local toolbar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  toolbar:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
  toolbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -70)
  toolbar:SetHeight(72)
  Backdrop(toolbar, COLOR.header, COLOR.border)
  frame.toolbar = toolbar

  local compactSourceSelect = NS.UI.Controls:CreateButton(toolbar, "Source: All Sources  v", 258, 22)
  compactSourceSelect:SetPoint("TOPLEFT", toolbar, "TOPLEFT", 9, -7)
  compactSourceSelect:Hide()
  frame.compactSourceSelect = compactSourceSelect

  local compactExpansionSelect = NS.UI.Controls:CreateButton(toolbar, "Expansion: All  v", 258, 22)
  compactExpansionSelect:SetPoint("TOPRIGHT", toolbar, "TOPRIGHT", -9, -7)
  compactExpansionSelect:Hide()
  frame.compactExpansionSelect = compactExpansionSelect

  local compactColumnHeader = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  compactColumnHeader:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 9, -5)
  compactColumnHeader:SetPoint("TOPRIGHT", toolbar, "BOTTOMRIGHT", -9, -5)
  compactColumnHeader:SetHeight(20)
  Backdrop(compactColumnHeader, COLOR.header, COLOR.border)
  compactColumnHeader.item = compactColumnHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  compactColumnHeader.item:SetPoint("LEFT", compactColumnHeader, "LEFT", 39, 0)
  compactColumnHeader.item:SetText("ITEM")
  SetTextColor(compactColumnHeader.item, COLOR.accent)
  compactColumnHeader.source = compactColumnHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  compactColumnHeader.source:SetPoint("RIGHT", compactColumnHeader, "RIGHT", -69, 0)
  compactColumnHeader.source:SetText("SOURCE")
  SetTextColor(compactColumnHeader.source, COLOR.accent)
  compactColumnHeader:Hide()
  frame.compactColumnHeader = compactColumnHeader

  local groupBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  groupBar:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -5)
  groupBar:SetPoint("RIGHT", frame, "RIGHT", -310, 0)
  groupBar:SetHeight(28)
  Backdrop(groupBar, COLOR.header, COLOR.border)
  groupBar:Hide()
  frame.groupBar = groupBar

  local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  footer:SetPoint("BOTTOMLEFT", 7, 7)
  footer:SetPoint("BOTTOMRIGHT", -7, 7)
  footer:SetHeight(32)
  Backdrop(footer, COLOR.header, COLOR.border)
  frame.footer = footer

  local levelCircle = CreateFrame("Frame", nil, footer, "BackdropTemplate")
  levelCircle:SetSize(24, 24)
  levelCircle:SetPoint("LEFT", footer, "LEFT", 8, 0)
  Backdrop(levelCircle, COLOR.hover, COLOR.accent)
  footer.level = levelCircle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footer.level:SetPoint("CENTER")
  footer.level:SetText("?")
  SetTextColor(footer.level, COLOR.accent)
  footer.house = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  footer.house:SetPoint("LEFT", levelCircle, "RIGHT", 7, 0)
  footer.house:SetText("HOUSE LVL")
  SetTextColor(footer.house, COLOR.accent)
  local xpHolder = CreateFrame("Frame", nil, footer, "BackdropTemplate")
  xpHolder:SetHeight(18)
  xpHolder:SetPoint("LEFT", footer.house, "RIGHT", 10, 0)
  xpHolder:SetPoint("RIGHT", footer, "CENTER", -60, 0)
  Backdrop(xpHolder, COLOR.background, COLOR.border)
  footer.xpFill = xpHolder:CreateTexture(nil, "ARTWORK")
  footer.xpFill:SetPoint("TOPLEFT", xpHolder, "TOPLEFT", 2, -2)
  footer.xpFill:SetPoint("BOTTOMLEFT", xpHolder, "BOTTOMLEFT", 2, 2)
  footer.xpFill:SetColorTexture(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 0.75)
  footer.xp = xpHolder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  footer.xp:SetPoint("CENTER")
  footer.xp:SetText("0 XP")
  SetTextColor(footer.xp, COLOR.text)
  footer.nextLevel = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  footer.nextLevel:SetPoint("LEFT", xpHolder, "RIGHT", 8, 0)
  SetTextColor(footer.nextLevel, COLOR.muted)
  footer.endeavors = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  footer.endeavors:SetPoint("LEFT", footer, "CENTER", 42, 0)
  footer.endeavors:SetText("ENDEAVORS")
  SetTextColor(footer.endeavors, COLOR.accent)
  footer.dots = {}
  for index = 1, 6 do
    local dot = CreateFrame("Frame", nil, footer, "BackdropTemplate")
    dot:SetSize(9, 9)
    if index == 1 then
      dot:SetPoint("LEFT", footer.endeavors, "RIGHT", 9, 0)
    else
      dot:SetPoint("LEFT", footer.dots[index - 1], "RIGHT", 4, 0)
    end
    Backdrop(dot, COLOR.panel, COLOR.border)
    footer.dots[index] = dot
  end
  footer.coupons = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  footer.coupons:SetPoint("RIGHT", footer, "RIGHT", -12, 0)
  footer.coupons:SetText("0 Coupons")
  SetTextColor(footer.coupons, COLOR.accent)
  footer.couponIcon = footer:CreateTexture(nil, "OVERLAY")
  footer.couponIcon:SetSize(14, 14)
  footer.couponIcon:SetPoint("RIGHT", footer.coupons, "LEFT", -4, 0)
  footer.couponIcon:SetTexture(134400)
  footer.cachedLevel = nil
  footer.cachedXP = 0
  footer.cachedMaxXP = 0
  footer.Refresh = function(self)
    local level = self.cachedLevel or "?"
    self.level:SetText(tostring(level))
    local maximum = tonumber(self.cachedMaxXP) or 0
    local current = tonumber(self.cachedXP) or 0
    local width = math.max(2, ((xpHolder:GetWidth() or 200) - 4) * (maximum > 0 and math.min(1, current / maximum) or 0))
    self.xpFill:SetWidth(width)
    self.xp:SetText(maximum > 0 and (tostring(current) .. " / " .. tostring(maximum) .. " XP") or (tostring(current) .. " XP"))
    self.nextLevel:SetText(type(level) == "number" and ("Next: Lvl " .. tostring(level + 1)) or "")
    if _G.C_CurrencyInfo and type(_G.C_CurrencyInfo.GetCurrencyInfo) == "function" then
      local info = _G.C_CurrencyInfo.GetCurrencyInfo(3363)
      self.coupons:SetText(tostring(info and info.quantity or 0) .. " Coupons")
      if info and info.iconFileID then self.couponIcon:SetTexture(info.iconFileID) end
    end
  end
  footer:SetScript("OnShow", function(self) self:Refresh() end)
  local houseEvents = CreateFrame("Frame")
  houseEvents:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED")
  houseEvents:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
  houseEvents:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
  houseEvents:SetScript("OnEvent", function(_, event, favor)
    if event == "HOUSE_LEVEL_FAVOR_UPDATED" and type(favor) == "table" then
      footer.cachedLevel = favor.houseLevel or 1
      footer.cachedXP = favor.houseFavor or 0
      if _G.C_Housing and type(_G.C_Housing.GetHouseLevelFavorForLevel) == "function" then
        local ok, needed = pcall(_G.C_Housing.GetHouseLevelFavorForLevel, footer.cachedLevel + 1)
        footer.cachedMaxXP = ok and tonumber(needed) or 0
      end
      footer:Refresh()
    elseif event == "PLAYER_HOUSE_LIST_UPDATED" and _G.C_Housing then
      local houses = type(favor) == "table" and favor or nil
      local house = houses and houses[1]
      if house and house.houseGUID and type(_G.C_Housing.GetCurrentHouseLevelFavor) == "function" then
        pcall(_G.C_Housing.GetCurrentHouseLevelFavor, house.houseGUID)
      end
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
      footer:Refresh()
    end
  end)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", header, "TOPLEFT", 12, -10)
  title:SetText("Decor Catalog")
  title:Hide()
  frame.catalogTitle = title

  local close = NS.UI.Controls:CreateCloseButton(header, function() frame:Hide() end)
  close:SetPoint("RIGHT", header, "RIGHT", -8, 0)
  local settings = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  settings:SetSize(30, 22)
  settings:SetPoint("RIGHT", close, "LEFT", -2, -1)
  settings:SetText("Opt")
  SkinButton(settings)
  settings:SetText("")
  settings.icon = settings:CreateTexture(nil, "OVERLAY")
  settings.icon:SetSize(15, 15)
  settings.icon:SetPoint("CENTER")
  settings.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  settings.icon:SetVertexColor(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 1)
  settings:SetScript("OnClick", function() NS.UI.Settings:Toggle() end)
  frame.settingsButton = settings
  local compactTop = NS.UI.Controls:CreateButton(header, "Compact", 72, 22)
  compactTop:SetPoint("RIGHT", settings, "LEFT", -6, 0)
  compactTop:SetScript("OnClick", function()
    local profile = NS.Systems.Database:GetProfile()
    NS.Systems.QueryState:SetCatalogOnly(not profile.ui.catalogOnly)
    NS.Systems.QueryState:SetRoute("catalog")
    CatalogView:ApplyShellLayout()
    CatalogView:Refresh(true)
  end)
  frame.compactTop = compactTop

  local theme = NS.UI.Theme
  local galleryTop = NS.UI.Controls:CreateButton(header, theme and theme:GetDesignPresetLabel() or "Gallery", 94, 22)
  galleryTop:SetPoint("RIGHT", compactTop, "LEFT", -7, 0)
  AddSidebarIcon(galleryTop, "Gallery")
  galleryTop:SetScript("OnClick", function()
    if NS.UI.Theme then NS.UI.Theme:CycleDesignPreset() end
  end)
  galleryTop:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Design Preset", 1, 1, 1)
    GameTooltip:AddLine("Cycle through Classic, Gallery, Workshop, and Arcane.", 0.7, 0.7, 0.7, true)
    if NS.UI.Theme then GameTooltip:AddLine("Current: " .. NS.UI.Theme:GetDesignPresetLabel(), 1, 0.82, 0.2, true) end
    GameTooltip:Show()
  end)
  galleryTop:SetScript("OnLeave", function() GameTooltip:Hide() end)
  frame.galleryTop = galleryTop

  CreateSection(sidebar, "QUICK ACCESS", -12)
  CreateSection(sidebar, "CATALOG", -60)
  CreateSection(sidebar, "FEATURED", -294)
  CreateSection(sidebar, "TRACKERS", -390)
  CreateSection(sidebar, "ACCOUNT", -462)
  CreateSection(sidebar, "LINKS", -558)

  frame.categoryButtons = {}
  local function SelectCatalogSource(clicked)
    CatalogView:ReleaseQueryView()
    NS.Systems.QueryState:ResetFilters()
    NS.Systems.QueryState:SetCategory(clicked.category)
    if clicked.option.requirement then NS.Systems.QueryState:SetFilter("requirement", clicked.option.requirement) end
    if clicked.option.sourceType then NS.Systems.QueryState:SetFilter("sourceType", clicked.option.sourceType) end
    NS.Systems.QueryState:SetRoute("catalog")
    CatalogView:Refresh(true)
    collectgarbage("step", 256)
  end
  local compactSourceOptions = {}
  for index = 1, #categories do compactSourceOptions[index] = { value = index, label = categories[index].label } end
  compactSourceSelect:SetScript("OnClick", function(self)
    NS.UI.Dropdown:Show(self, compactSourceOptions, self.selectedIndex or 1, function(index)
      local option = categories[tonumber(index)]
      if option then SelectCatalogSource({ category = option.key, option = option }) end
    end)
  end)
  compactExpansionSelect:SetScript("OnClick", function(self)
    local current = NS.Systems.QueryState:GetFilter("expansion", "All")
    NS.UI.Dropdown:Show(self, NS.Systems.QueryState:GetOptions("expansion"), current, function(value)
      CatalogView:ReleaseQueryView()
      NS.Systems.QueryState:SetFilter("expansion", value)
      CatalogView:Refresh(true)
      collectgarbage("step", 256)
    end)
  end)
  for index = 1, #categories do
    local option = categories[index]
    local button = NS.UI.Controls:CreateButton(sidebar, option.label, 184, 22)
    button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 10, -78 - (index - 1) * 24)
    button:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -10, -78 - (index - 1) * 24)
    AddSidebarIcon(button, option.label)
    button.category = option.key
    button.option = option
    button:SetScript("OnClick", SelectCatalogSource)
    frame.categoryButtons[index] = button
  end

  frame.routeButtons = {}
  local routes = {
    { key = "catalog", label = "All Sources" },
    { key = "favorites", label = "Saved Items" },
    { key = "tracked", label = "Decor Tracker" },
  }
  for index = 1, #routes do
    local route = routes[index]
    local button = NS.UI.Controls:CreateButton(sidebar, route.label, 184, 22)
    if route.key == "favorites" then
      button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 10, -30)
      button:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -10, -30)
    elseif route.key == "tracked" then
      button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 10, -408)
      button:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -10, -408)
    else
      button:Hide()
    end
    AddSidebarIcon(button, route.label)
    button.route = route.key
    if route.key == "tracked" then frame.trackerButton = button end
    button:SetScript("OnClick", function(clicked)
      NS.UI.Controls:CloseTransientPopups()
      if clicked.route == "tracked" then
        NS.UI.TrackerPanel:Toggle()
        return
      end
      NS.Systems.QueryState:ResetFilters()
      NS.Systems.QueryState:SetRoute(clicked.route)
      if clicked.route == "catalog" then NS.Systems.QueryState:SetCategory("All") end
      frame.search:SetText("")
      CatalogView:Refresh(true)
    end)
    frame.routeButtons[index] = button
  end

  local function ToggleEmbeddedRoute(target)
    NS.Systems.QueryState:ResetFilters()
    NS.Systems.QueryState:SetRoute(NS.Systems.QueryState:GetRoute() == target and "catalog" or target)
    CatalogView:Refresh(true)
  end
  frame.architectButton = CreateSidebarButton(sidebar, "Architect", -312, function()
    ToggleEmbeddedRoute("architect")
  end)
  frame.pricingButton = CreateSidebarButton(sidebar, "Decor Pricing", -336, function()
    ToggleEmbeddedRoute("pricing")
  end)
  frame.eventsButton = CreateSidebarButton(sidebar, "Events", -360, function()
    NS.Systems.QueryState:ResetFilters()
    NS.Systems.QueryState:SetCategory("Events")
    NS.Systems.QueryState:SetRoute("catalog")
    CatalogView:Refresh(true)
  end)
  frame.gatherButton = CreateSidebarButton(sidebar, "Gather Tracker", -432, function()
    if NS.UI.GatherTracker then NS.UI.GatherTracker:Toggle() end
  end)
  frame.altsButton = CreateSidebarButton(sidebar, "Alts Professions", -480, function()
    ToggleEmbeddedRoute("alts")
  end)
  frame.endeavorsButton = CreateSidebarButton(sidebar, "Endeavors", -504, function()
    ToggleEmbeddedRoute("endeavors")
  end)
  frame.statisticsButton = CreateSidebarButton(sidebar, "Statistics", -528, function()
    ToggleEmbeddedRoute("statistics")
  end)
  frame.communityButton = CreateSidebarButton(sidebar, "Community", -576, function()
    NS.UI.Community:Toggle(frame.communityButton)
  end, true)
  frame.whatsNewButton = CreateSidebarButton(sidebar, "What's New", -604, function()
    NS.UI.WhatsNew:Toggle(frame.whatsNewButton)
  end, true)

  local architectHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  architectHost:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
  architectHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 46)
  Backdrop(architectHost, COLOR.background, COLOR.border)
  architectHost:Hide()
  frame.architectHost = architectHost

  local pricingHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  pricingHost:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
  pricingHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 46)
  Backdrop(pricingHost, COLOR.background, COLOR.border)
  pricingHost:Hide()
  frame.pricingHost = pricingHost

  local altsHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  altsHost:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
  altsHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 46)
  Backdrop(altsHost, COLOR.background, COLOR.border)
  altsHost:Hide()
  frame.altsHost = altsHost

  local endeavorsHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  endeavorsHost:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
  endeavorsHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 46)
  Backdrop(endeavorsHost, COLOR.background, COLOR.border)
  endeavorsHost:Hide()
  frame.endeavorsHost = endeavorsHost

  local statisticsHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  statisticsHost:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
  statisticsHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 46)
  Backdrop(statisticsHost, COLOR.background, COLOR.border)
  statisticsHost:Hide()
  frame.statisticsHost = statisticsHost

  local search = NS.UI.Controls:CreateSearchBox(toolbar, {
    height = 22,
    placeholder = "Search decor...",
    leftInset = 8,
    rightInset = 28,
    background = COLOR.background,
    border = COLOR.border,
    placeholderColor = COLOR.muted,
    notifyProgrammatic = true,
    onChanged = function(self)
      if frame._syncingSearch then return end
      NS.Systems.QueryState:SetSearch(self:GetText() or "")
      CatalogView:RequestSearchRefresh()
    end,
  })
  search:SetPoint("TOPLEFT", toolbar, "TOPLEFT", 10, -9)
  search:SetPoint("TOPRIGHT", toolbar, "TOPRIGHT", -226, -9)
  local searchPlaceholder = search.placeholder
  frame.searchPlaceholder = searchPlaceholder
  local searchClear = CreateFrame("Button", nil, search, "BackdropTemplate")
  searchClear:SetSize(18, 18)
  searchClear:SetPoint("RIGHT", search, "RIGHT", -3, 0)
  searchClear:SetText("X")
  SkinButton(searchClear)
  searchClear:SetScript("OnClick", function()
    search:SetText("")
    search:ClearFocus()
  end)
  frame.search = search

  local panelTop = NS.UI.Controls:CreateButton(toolbar, "Panel", 62, 22)
  panelTop:SetPoint("TOPRIGHT", toolbar, "TOPRIGHT", -10, -9)
  panelTop:SetScript("OnClick", function()
    local current = NS.Systems.Database:GetProfile()
    NS.Systems.QueryState:SetPanelVisible(current.ui.panelVisible == false)
    CatalogView:UpdateResponsiveLayout()
    if current.ui.panelVisible and CatalogView.selected then NS.UI.Inspector:Show(CatalogView.selected) end
    CatalogView:Refresh(false)
  end)
  frame.panelTop = panelTop

  local catalogTop = NS.UI.Controls:CreateButton(toolbar, "All", 54, 22)
  catalogTop:SetPoint("RIGHT", panelTop, "LEFT", -4, 0)
  catalogTop:SetScript("OnClick", function()
    local current = NS.Systems.Database:GetProfile()
    NS.Systems.QueryState:SetCatalogMode(current.ui.catalogMode == "Sections" and "All Items" or "Sections")
    CatalogView:Refresh(true)
  end)
  frame.modeTop = catalogTop

  local filtersTop = NS.UI.Controls:CreateButton(toolbar, "Filters", 82, 22)
  filtersTop:SetPoint("RIGHT", catalogTop, "LEFT", -4, 0)
  AddSidebarIcon(filtersTop, "Filters")
  frame.filtersTop = filtersTop

  frame.ownershipButtons = {}
  local ownershipLabels = { "All", "Missing", "Owned" }
  local previousOwnership
  for index = 1, #ownershipLabels do
    local label = ownershipLabels[index]
    local button = NS.UI.Controls:CreateButton(toolbar, label, label == "Missing" and 66 or 54, 22)
    if previousOwnership then
      button:SetPoint("LEFT", previousOwnership, "RIGHT", 0, 0)
    else
      button:SetPoint("BOTTOMLEFT", toolbar, "BOTTOMLEFT", 10, 8)
    end
    button.ownership = label
    button:SetScript("OnClick", function(clicked)
      NS.Systems.QueryState:SetOwnership(clicked.ownership)
      CatalogView:Refresh(true)
    end)
    frame.ownershipButtons[index] = button
    previousOwnership = button
  end

  local sortTop = NS.UI.Controls:CreateButton(toolbar, "Sort: Name (A-Z)", 154, 22)
  sortTop:SetPoint("LEFT", previousOwnership, "RIGHT", 8, 0)
  local sortText = sortTop:GetFontString()
  sortText:ClearAllPoints()
  sortText:SetPoint("LEFT", 9, 0)
  sortText:SetPoint("RIGHT", -24, 0)
  sortText:SetJustifyH("LEFT")
  sortTop.arrow = sortTop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sortTop.arrow:SetPoint("RIGHT", -8, 0)
  sortTop.arrow:SetText("v")
  SetTextColor(sortTop.arrow, COLOR.muted)
  sortTop:SetScript("OnClick", function(self)
    local current = NS.Systems.QueryState:GetSort()
    NS.UI.Dropdown:Show(self, NS.Systems.QueryState:GetOptions("sort"), current, function(value)
      NS.Systems.QueryState:SetSort(value)
      NS.Systems.Catalog:Sort(value)
      CatalogView:Refresh(false)
    end)
  end)
  frame.sortTop = sortTop

  frame.viewButtons = {}
  local viewOptions = {
    { key = "grid", label = "Grid", width = 68, glyph = "grid" },
    { key = "list", label = "List", width = 64, glyph = "list" },
    { key = "text", label = "Text List", width = 90, glyph = "text" },
  }
  local function AddViewGlyph(button, kind)
    local function Piece(x, y, width, height)
      local texture = button:CreateTexture(nil, "OVERLAY")
      texture:SetPoint("LEFT", button, "LEFT", x, y)
      texture:SetSize(width, height)
      texture:SetColorTexture(COLOR.accent[1], COLOR.accent[2], COLOR.accent[3], 0.95)
    end
    if kind == "grid" then
      Piece(8, 4, 3, 3)
      Piece(13, 4, 3, 3)
      Piece(8, -1, 3, 3)
      Piece(13, -1, 3, 3)
    elseif kind == "text" then
      Piece(8, 4, 12, 2)
      Piece(8, 0, 16, 2)
      Piece(8, -4, 10, 2)
    else
      Piece(8, 4, 3, 3)
      Piece(14, 4, 13, 2)
      Piece(8, -1, 3, 3)
      Piece(14, -1, 13, 2)
      Piece(8, -6, 3, 3)
      Piece(14, -6, 13, 2)
    end
    local text = button:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("LEFT", button, "LEFT", kind == "list" and 31 or 27, 0)
    text:SetPoint("RIGHT", button, "RIGHT", -6, 0)
    text:SetJustifyH("LEFT")
  end
  local previousView
  for index = #viewOptions, 1, -1 do
    local option = viewOptions[index]
    local button = NS.UI.Controls:CreateButton(toolbar, option.label, option.width, 24)
    if previousView then
      button:SetPoint("RIGHT", previousView, "LEFT", 0, 0)
    else
      button:SetPoint("BOTTOMRIGHT", toolbar, "BOTTOMRIGHT", -10, 8)
    end
    AddViewGlyph(button, option.glyph)
    button.view = option.key
    button:SetScript("OnClick", function(clicked)
      NS.Systems.QueryState:SetView(clicked.view)
      NS.Systems.QueryState:SetCompact(clicked.view == "text")
      CatalogView:Refresh(true)
    end)
    frame.viewButtons[index] = button
    previousView = button
  end

  local filterPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  filterPanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  filterPanel:SetSize(620, 680)
  filterPanel:SetFrameStrata("FULLSCREEN_DIALOG")
  filterPanel:SetClampedToScreen(true)
  Backdrop(filterPanel, COLOR.header, COLOR.border)
  filterPanel:Hide()
  frame.filterPanel = filterPanel
  local filterHeader = CreateFrame("Frame", nil, filterPanel, "BackdropTemplate")
  filterHeader:SetPoint("TOPLEFT", 1, -1)
  filterHeader:SetPoint("TOPRIGHT", -1, -1)
  filterHeader:SetHeight(60)
  Backdrop(filterHeader, COLOR.row, COLOR.border)
  filterPanel.header = filterHeader
  local filterTitle = filterHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  filterTitle:SetPoint("TOPLEFT", 14, -12)
  filterTitle:SetText("Filter Studio")
  SetTextColor(filterTitle, COLOR.accent)
  local filterSummary = filterHeader:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  filterSummary:SetPoint("TOPLEFT", filterTitle, "BOTTOMLEFT", 0, -5)
  filterSummary:SetText("Drag this header to move the window")
  SetTextColor(filterSummary, COLOR.muted)
  filterPanel.summary = filterSummary
  local filterBadge = CreateFrame("Frame", nil, filterHeader, "BackdropTemplate")
  filterBadge:SetSize(72, 22)
  filterBadge:SetPoint("TOPRIGHT", -42, -9)
  Backdrop(filterBadge, COLOR.row, COLOR.accent)
  filterBadge.text = filterBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  filterBadge.text:SetPoint("CENTER")
  SetTextColor(filterBadge.text, COLOR.accent)
  filterPanel.badge = filterBadge
  local filterClose = NS.UI.Controls:CreateCloseButton(filterHeader, function() filterPanel:Hide() end, 22, 22)
  filterClose:SetPoint("TOPRIGHT", -8, -7)
  NS.UI.Controls:MakeMovable(filterPanel, filterHeader, "filterStudio")
  NS.Systems.Layout:Restore(filterPanel, "filterStudio")
  filtersTop:SetScript("OnClick", function()
    filterPanel:SetShown(not filterPanel:IsShown())
  end)

  local favorites = NS.UI.Controls:CreateCheckButton(frame, "Favorites")
  favorites:SetSize(26, 26)
  favorites:SetPoint("LEFT", search, "RIGHT", 10, 0)
  favorites:SetScript("OnClick", function(clicked)
    if clicked:GetChecked() == true then
      NS.Systems.QueryState:SetRoute("favorites")
    elseif NS.Systems.QueryState:GetRoute() == "favorites" then
      NS.Systems.QueryState:SetRoute("catalog")
    end
    CatalogView:Refresh(true)
  end)
  frame.favorites = favorites
  favorites:Hide()

  local favoritesLabel = favorites.label
  favoritesLabel:Hide()

  local tracked = NS.UI.Controls:CreateCheckButton(frame, "Tracked")
  tracked:SetSize(26, 26)
  tracked:SetPoint("LEFT", favoritesLabel, "RIGHT", 86, 0)
  tracked:SetScript("OnClick", function(clicked)
    if clicked:GetChecked() == true then
      NS.Systems.QueryState:SetRoute("tracked")
    elseif NS.Systems.QueryState:GetRoute() == "tracked" then
      NS.Systems.QueryState:SetRoute("catalog")
    end
    CatalogView:Refresh(true)
  end)
  frame.tracked = tracked
  tracked:Hide()

  local trackedLabel = tracked.label
  trackedLabel:Hide()

  local compact = NS.UI.Controls:CreateCheckButton(frame, "Compact")
  compact:SetSize(26, 26)
  compact:SetPoint("LEFT", trackedLabel, "RIGHT", 74, 0)
  compact:SetScript("OnClick", function(clicked)
    NS.Systems.QueryState:SetCompact(clicked:GetChecked() == true)
    CatalogView:Refresh(true)
  end)
  frame.compact = compact
  compact:Hide()

  local compactLabel = compact.label
  compactLabel:Hide()

  local count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  count:SetPoint("RIGHT", footer, "RIGHT", -12, 0)
  SetTextColor(count, COLOR.muted)
  count:Hide()
  frame.count = count

  local filterScroll = NS.UI.Controls:CreateScrollFrame(filterPanel)
  filterScroll:SetPoint("TOPLEFT", 10, -64)
  filterScroll:SetPoint("BOTTOMRIGHT", -10, 52)
  local filterContent = CreateFrame("Frame", nil, filterScroll)
  filterContent:SetSize(582, 1050)
  NS.UI.Controls:ConfigureScrollFrame(filterScroll, filterContent, { step = 52, barInset = 10, barTop = 12, barBottom = 12 })
  filterPanel.scroll = filterScroll
  filterPanel.content = filterContent
  frame.filterControls = {}

  local function FilterValue(field)
    if field == "sort" then return NS.Systems.QueryState:GetSort() end
    return NS.Systems.QueryState:GetFilter(field, "All")
  end

  local function CreateFilterCard(field, label, x, y, width)
    local button = NS.UI.Controls:CreateButton(filterContent, "", width or 282, 46)
    button:SetPoint("TOPLEFT", x, y)
    NS.UI.Controls:ForwardScrollWheel(button, filterScroll)
    button:GetFontString():Hide()
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.label:SetPoint("TOPLEFT", 10, -6)
    button.label:SetText(label)
    SetTextColor(button.label, COLOR.muted)
    button.value = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.value:SetPoint("BOTTOMLEFT", 10, 6)
    button.value:SetPoint("RIGHT", -28, 0)
    button.value:SetJustifyH("LEFT")
    button.value:SetWordWrap(false)
    button.arrow = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.arrow:SetPoint("RIGHT", -10, 0)
    button.arrow:SetText(">")
    SetTextColor(button.arrow, COLOR.accent)
    button.field = field
    button.ApplyText = function(self)
      local value = FilterValue(self.field)
      self.value:SetText(NS.Systems.QueryState:GetOptionLabel(self.field, value))
      local active = value ~= nil and value ~= "All" and not (self.field == "sort" and value == "name")
      NS.UI.Controls:SetButtonSelected(self, active)
      SetTextColor(self.value, active and COLOR.accent or COLOR.text)
    end
    button:SetScript("OnClick", function(self)
      local current = FilterValue(self.field)
      NS.UI.Dropdown:Show(self, NS.Systems.QueryState:GetOptions(self.field), current, function(value)
        if self.field == "sort" then
          NS.Systems.QueryState:SetSort(value)
          NS.Systems.Catalog:Sort(value)
        else
          NS.Systems.QueryState:SetFilter(self.field, value)
        end
        CatalogView:Refresh(true)
      end)
    end)
    frame.filterControls[field] = button
    return button
  end

  local function CreateFilterToggle(field, label, x, y)
    local button = NS.UI.Controls:CreateButton(filterContent, "", 282, 42)
    button:SetPoint("TOPLEFT", x, y)
    NS.UI.Controls:ForwardScrollWheel(button, filterScroll)
    button:GetFontString():Hide()
    button.mark = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.mark:SetPoint("LEFT", 10, 0)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.text:SetPoint("LEFT", button.mark, "RIGHT", 8, 0)
    button.text:SetText(label)
    button.field = field
    button.ApplyText = function(self)
      local active = NS.Systems.QueryState:GetFilter(self.field, false) == true
      self.mark:SetText(active and "ON" or "OFF")
      SetTextColor(self.mark, active and COLOR.accent or COLOR.muted)
      SetTextColor(self.text, active and COLOR.accent or COLOR.text)
      NS.UI.Controls:SetButtonSelected(self, active)
    end
    button:SetScript("OnClick", function(self)
      NS.Systems.QueryState:SetFlag(self.field, not (NS.Systems.QueryState:GetFilter(self.field, false) == true))
      CatalogView:Refresh(true)
    end)
    frame.filterControls[field] = button
    return button
  end

  local colorValues = {
    black = { 0.03, 0.03, 0.03 }, gray = { 0.38, 0.38, 0.38 }, grey = { 0.38, 0.38, 0.38 }, silver = { 0.68, 0.68, 0.66 },
    white = { 0.96, 0.96, 0.92 }, cream = { 0.90, 0.84, 0.64 }, beige = { 0.72, 0.61, 0.44 }, tan = { 0.67, 0.48, 0.29 },
    red = { 0.90, 0.06, 0.04 }, crimson = { 0.66, 0.03, 0.08 }, pink = { 0.96, 0.38, 0.58 }, purple = { 0.53, 0.20, 0.72 },
    blue = { 0.10, 0.38, 0.90 }, navy = { 0.04, 0.10, 0.30 }, cyan = { 0.05, 0.78, 0.88 }, teal = { 0.02, 0.52, 0.50 },
    green = { 0.08, 0.62, 0.22 }, lime = { 0.45, 0.82, 0.08 }, olive = { 0.40, 0.43, 0.10 }, yellow = { 0.95, 0.82, 0.05 },
    gold = { 0.92, 0.62, 0.05 }, amber = { 0.94, 0.45, 0.03 }, orange = { 0.92, 0.25, 0.03 }, brown = { 0.38, 0.19, 0.08 },
    copper = { 0.66, 0.31, 0.13 }, bronze = { 0.50, 0.34, 0.12 },
  }

  local function ResolveColor(value)
    local name = tostring(value or ""):lower()
    if colorValues[name] then return unpack(colorValues[name]) end
    for key, color in pairs(colorValues) do
      if name:find(key, 1, true) then
        local scale = 1
        if name:find("dark", 1, true) or name:find("deep", 1, true) or name:find("forest", 1, true) then scale = 0.55 end
        if name:find("light", 1, true) then scale = 1.25 end
        return math.min(1, color[1] * scale), math.min(1, color[2] * scale), math.min(1, color[3] * scale)
      end
    end
    return 0.45, 0.45, 0.45
  end

  local colorButtons = {}
  local acquisitionSection
  local factionFilter
  local requirementFilter
  local budgetFilter
  local preferencesSection
  local reputationToggle
  local renownToggle
  local pvpToggle
  local completionSection
  local questToggle
  local achievementToggle
  local orderSection
  local sortFilter
  local function CreateColorButton(index)
    local button = NS.UI.Controls:CreateButton(filterContent, "", 137, 30)
    NS.UI.Controls:ForwardScrollWheel(button, filterScroll)
    button:GetFontString():Hide()
    button.swatch = button:CreateTexture(nil, "ARTWORK")
    button.swatch:SetSize(20, 20)
    button.swatch:SetPoint("LEFT", 5, 0)
    button.check = button:CreateTexture(nil, "OVERLAY")
    button.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    button.check:SetSize(22, 22)
    button.check:SetPoint("CENTER", button.swatch)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.text:SetPoint("LEFT", button.swatch, "RIGHT", 6, 0)
    button.text:SetPoint("RIGHT", -5, 0)
    button.text:SetJustifyH("LEFT")
    button.text:SetWordWrap(false)
    button:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(self.value or "Color")
      GameTooltip:AddLine("Click to add or remove this color", 0.78, 0.78, 0.72)
      GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(self)
      NS.Systems.QueryState:ToggleColor(self.value)
      CatalogView:Refresh(true)
    end)
    colorButtons[index] = button
    return button
  end

  local colorClear = NS.UI.Controls:CreateButton(filterContent, "Clear colors", 96, 22)
  colorClear:SetPoint("TOPRIGHT", filterContent, "TOPRIGHT", -10, -402)
  NS.UI.Controls:ForwardScrollWheel(colorClear, filterScroll)
  colorClear:SetScript("OnClick", function()
    NS.Systems.QueryState:ClearColors()
    CatalogView:Refresh(true)
  end)

  filterPanel.RefreshColors = function()
    local selected = NS.Systems.QueryState:GetSelectedColors()
    local options = NS.Systems.QueryState:GetOptions("color")
    local visible = 0
    local available = {}
    for _, option in ipairs(options) do
      local value = type(option) == "table" and option.value or option
      if value and value ~= "All" then
        available[value] = true
        visible = visible + 1
        local button = colorButtons[visible] or CreateColorButton(visible)
        local column = (visible - 1) % 4
        local row = math.floor((visible - 1) / 4)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", 0 + column * 145, -474 - row * 34)
        button.value = value
        button.text:SetText(type(option) == "table" and (option.label or value) or value)
        button.swatch:SetColorTexture(ResolveColor(value))
        local active = selected[value] == true
        button.check:SetShown(active)
        NS.UI.Controls:SetButtonSelected(button, active)
        SetTextColor(button.text, active and COLOR.accent or COLOR.text)
        button:Show()
      end
    end
    for value in pairs(selected) do
      if not available[value] then selected[value] = nil end
    end
    for index = visible + 1, #colorButtons do colorButtons[index]:Hide() end
    colorClear:SetEnabled(next(selected) ~= nil)
    if filterPanel.ReflowColors then filterPanel:ReflowColors(math.ceil(visible / 4)) end
  end

  local function CreateFilterSection(label, x, y, width)
    local section = CreateFrame("Frame", nil, filterContent, "BackdropTemplate")
    section:SetPoint("TOPLEFT", filterContent, "TOPLEFT", x, y)
    section:SetSize(width, 24)
    Backdrop(section, COLOR.row, COLOR.accent)
    section.text = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.text:SetPoint("LEFT", 10, 0)
    section.text:SetText(label)
    SetTextColor(section.text, COLOR.accent)
    return section
  end

  CreateFilterSection("DISCOVERY", 0, -2, 282)
  CreateFilterCard("expansion", "Expansion", 0, -30)
  CreateFilterCard("zone", "Zone", 0, -82)
  CreateFilterCard("sourceType", "Source", 0, -134)
  CreateFilterCard("profession", "Profession", 0, -186)
  CreateFilterCard("class", "Class", 0, -238)
  CreateFilterCard("category", "Temporary Category", 0, -290)
  CreateFilterCard("subcategory", "Subcategory", 0, -342)

  preferencesSection = CreateFilterSection("PREFERENCES", 290, -2, 282)
  reputationToggle = CreateFilterToggle("requiresReputation", "Requires reputation", 290, -30)
  renownToggle = CreateFilterToggle("requiresRenown", "Requires renown", 290, -78)
  pvpToggle = CreateFilterToggle("hidePvp", "Hide PvP rewards", 290, -126)

  completionSection = CreateFilterSection("COMPLETION", 290, -176, 282)
  questToggle = CreateFilterToggle("questCompleted", "Completed quest rewards", 290, -204)
  achievementToggle = CreateFilterToggle("achievementCompleted", "Earned achievements", 290, -252)

  CreateFilterSection("APPEARANCE", 290, -302, 282)
  CreateFilterCard("size", "Size", 290, -330)
  CreateFilterCard("dyeability", "Dyeability", 290, -382)
  local colorsSection = CreateFilterSection("COLORS - SELECT ANY", 0, -440, 572)
  colorClear:SetParent(colorsSection)
  colorClear:ClearAllPoints()
  colorClear:SetPoint("RIGHT", colorsSection, "RIGHT", -6, 0)

  acquisitionSection = CreateFilterSection("ACQUISITION", 0, -686, 572)
  factionFilter = CreateFilterCard("faction", "Faction", 0, -714)
  requirementFilter = CreateFilterCard("requirement", "Requirement", 290, -714)
  budgetFilter = CreateFilterCard("budgetCost", "Placement Budget", 0, -766, 572)

  orderSection = CreateFilterSection("RESULT ORDER", 0, -826, 572)
  sortFilter = CreateFilterCard("sort", "Sort catalog by", 0, -854, 572)

  local function MoveControl(control, x, y)
    control:ClearAllPoints()
    control:SetPoint("TOPLEFT", filterContent, "TOPLEFT", x, y)
  end

  function filterPanel:ReflowColors(rowCount)
    local rows = math.max(1, rowCount or 1)
    local colorBottom = -474 - (rows - 1) * 34 - 30
    local acquisitionY = colorBottom - 36
    MoveControl(acquisitionSection, 0, acquisitionY)
    MoveControl(factionFilter, 0, acquisitionY - 28)
    MoveControl(requirementFilter, 290, acquisitionY - 28)
    MoveControl(budgetFilter, 0, acquisitionY - 80)
    MoveControl(orderSection, 0, acquisitionY - 140)
    MoveControl(sortFilter, 0, acquisitionY - 168)
    filterContent:SetHeight(-acquisitionY + 220)
  end

  local reset = NS.UI.Controls:CreateButton(filterPanel, "Reset Filters", 286, 30)
  reset:SetPoint("BOTTOMLEFT", filterPanel, "BOTTOMLEFT", 10, 10)
  reset:SetScript("OnClick", function()
    NS.Systems.QueryState:ResetFilters()
    frame.search:SetText("")
    CatalogView:Refresh(true)
  end)
  local done = NS.UI.Controls:CreateButton(filterPanel, "Done", 294, 30)
  done:SetPoint("BOTTOMRIGHT", filterPanel, "BOTTOMRIGHT", -10, 10)
  done:SetScript("OnClick", function() filterPanel:Hide() end)

  local scroll = NS.UI.Controls:CreateScrollFrame(frame)
  scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 228, -154)
  scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -310, 48)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(650)
  content:SetHeight(1)
  NS.UI.Controls:ConfigureScrollFrame(scroll, content, {
    step = function()
      local _, height = CatalogView:GetLayout()
      return math.min(height, 72)
    end,
    onScroll = function()
      CatalogView:SyncScrollBar()
      CatalogView:RefreshViewport(true)
      if CatalogView.scrollDetailTimer then CatalogView.scrollDetailTimer:Cancel() end
      CatalogView.scrollDetailTimer = C_Timer.NewTimer(0.08, function()
        CatalogView.scrollDetailTimer = nil
        CatalogView:RefreshViewport(false)
        NS.UI.Controls:CollectGarbageIncrementally()
      end)
    end,
  })
  frame.scroll = scroll
  frame.content = content
  local inspector = NS.UI.Inspector:Create(frame)
  inspector:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -154)
  inspector:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 48)
  inspector:SetWidth(278)
  inspector:Hide()
  frame.inspector = inspector
  frame.rows = {}
  for index = 1, INITIAL_ROWS do
    local row = self:CreateRow(content, scroll)
    row:SetPoint("TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((index - 1) * ROW_HEIGHT))
    row:Hide()
    frame.rows[index] = row
  end
  frame:SetScript("OnShow", function()
    if _G.C_Housing and type(_G.C_Housing.GetPlayerOwnedHouses) == "function" then
      local ok, houses = pcall(_G.C_Housing.GetPlayerOwnedHouses)
      local house = ok and type(houses) == "table" and houses[1]
      if house and house.houseGUID and type(_G.C_Housing.GetCurrentHouseLevelFavor) == "function" then pcall(_G.C_Housing.GetCurrentHouseLevelFavor, house.houseGUID) end
    end
    CatalogView:UpdateResponsiveLayout()
    CatalogView:Refresh(true)
    if NS.Systems.Changelog then NS.Systems.Changelog:TryAutoOpen(frame.whatsNewButton) end
  end)
  frame:SetScript("OnSizeChanged", function()
    if frame._applyingShellLayout then return end
    CatalogView:UpdateResponsiveLayout()
    CatalogView:Refresh(false)
  end)
  frame:SetScript("OnHide", function()
    NS.UI.Controls:CloseTransientPopups()
    if CatalogView.scrollDetailTimer then CatalogView.scrollDetailTimer:Cancel() CatalogView.scrollDetailTimer = nil end
    if CatalogView.itemDisplayTimer then CatalogView.itemDisplayTimer:Cancel() CatalogView.itemDisplayTimer = nil end
    CatalogView._searchToken = (CatalogView._searchToken or 0) + 1
    CatalogView:ReleaseCatalogPage()
    for index = 1, #frame.rows do
      local row = frame.rows[index]
      row.record = nil
      row.requirement.record = nil
      row.sources.record = nil
      row._displayRecord = nil
      row._displayRevision = nil
      row._factionTexture = nil
      row:Hide()
    end
    CatalogView.selected = nil
    NS.UI.Inspector:Clear()
  end)
  self.frame = frame
  return frame
end

function CatalogView:ReleaseCatalogPage()
  local frame = self.frame
  if not frame or frame._catalogReleased then return end
  frame._catalogReleased = true
  frame.catalogScrollOffset = frame.scroll and frame.scroll:GetVerticalScroll() or 0
  for index = 1, #(frame.rows or {}) do
    local row = frame.rows[index]
    row.record = nil
    row.requirement.record = nil
    row.sources.record = nil
    row.groupKey = nil
    row._displayRecord = nil
    row._displayRevision = nil
    row._factionTexture = nil
    row.favorite:SetRecord(nil)
    row:Hide()
  end
  NS.UI.Inspector:Clear()
end

function CatalogView:Refresh(resetScroll)
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  if frame._hdRefreshing then return end
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return end
  frame._hdRefreshing = true
  local scrollOffset = resetScroll and 0 or (frame.scroll:GetVerticalScroll() or 0)
  frame.query = frame.query or {}
  local route = NS.Systems.QueryState:GetRoute()
  local architectOpen = route == "architect"
  local pricingOpen = route == "pricing"
  local altsOpen = route == "alts"
  local endeavorsOpen = route == "endeavors"
  local statisticsOpen = route == "statistics"
  local specialOpen = architectOpen or pricingOpen or altsOpen or endeavorsOpen or statisticsOpen
  if specialOpen and profile.ui.catalogOnly == true then
    NS.Systems.QueryState:SetCatalogOnly(false)
  end
  self:ApplyShellLayout()
  if not specialOpen then
    if route == "catalog" then
      NS.Systems.SourceAdapter:EnsureCategory(profile.ui.category, profile.filters and profile.filters.requirement, profile.filters and profile.filters.sourceType)
    else
      NS.Systems.SourceAdapter:LoadAll()
    end
    self:RefreshCategoryCounts()
    if profile.ui.catalogOnly == true then self:RefreshCompactExpansions() end
  end
  if specialOpen then
    self:ReleaseCatalogPage()
  elseif frame._catalogReleased then
    scrollOffset = frame.catalogScrollOffset or scrollOffset
    frame._catalogReleased = nil
  end
  frame.toolbar:SetShown(not specialOpen)
  frame.scroll:SetShown(not specialOpen)
  frame.groupBar:Hide()
  frame.architectButton:SetEnabled(true)
  frame.pricingButton:SetEnabled(true)
  frame.altsButton:SetEnabled(true)
  frame.endeavorsButton:SetEnabled(true)
  frame.statisticsButton:SetEnabled(true)
  if NS.UI.Controls and NS.UI.Controls.SetButtonSelected then
    NS.UI.Controls:SetButtonSelected(frame.architectButton, architectOpen)
    NS.UI.Controls:SetButtonSelected(frame.pricingButton, pricingOpen)
    NS.UI.Controls:SetButtonSelected(frame.altsButton, altsOpen)
    NS.UI.Controls:SetButtonSelected(frame.endeavorsButton, endeavorsOpen)
    NS.UI.Controls:SetButtonSelected(frame.statisticsButton, statisticsOpen)
  else
    Backdrop(frame.architectButton, architectOpen and COLOR.hover or COLOR.panel, architectOpen and COLOR.accent or COLOR.border)
    Backdrop(frame.pricingButton, pricingOpen and COLOR.hover or COLOR.panel, pricingOpen and COLOR.accent or COLOR.border)
    Backdrop(frame.altsButton, altsOpen and COLOR.hover or COLOR.panel, altsOpen and COLOR.accent or COLOR.border)
    Backdrop(frame.endeavorsButton, endeavorsOpen and COLOR.hover or COLOR.panel, endeavorsOpen and COLOR.accent or COLOR.border)
    Backdrop(frame.statisticsButton, statisticsOpen and COLOR.hover or COLOR.panel, statisticsOpen and COLOR.accent or COLOR.border)
  end
  if architectOpen then
    frame.inspector:Hide()
    frame.pricingHost:Hide()
    if frame.pricingPanel then frame.pricingPanel:Hide() end
    frame.altsHost:Hide()
    if frame.altsPanel then frame.altsPanel:Hide() end
    frame.endeavorsHost:Hide()
    if frame.endeavorsPanel then frame.endeavorsPanel:Hide() end
    frame.statisticsHost:Hide()
    if frame.statisticsPanel then frame.statisticsPanel:Hide() end
    frame.architectHost:Show()
    if not frame.architectPanel then frame.architectPanel = NS.UI.Architect:Create(frame.architectHost) end
    frame.architectPanel:Show()
    NS.UI.Architect:Refresh()
    frame._hdRefreshing = nil
    return
  end
  if pricingOpen then
    frame.inspector:Hide()
    frame.architectHost:Hide()
    if frame.architectPanel then frame.architectPanel:Hide() end
    frame.altsHost:Hide()
    if frame.altsPanel then frame.altsPanel:Hide() end
    frame.endeavorsHost:Hide()
    if frame.endeavorsPanel then frame.endeavorsPanel:Hide() end
    frame.statisticsHost:Hide()
    if frame.statisticsPanel then frame.statisticsPanel:Hide() end
    frame.pricingHost:Show()
    NS.Systems.SourceAdapter:EnsureCategory("Professions")
    if not frame.pricingPanel then frame.pricingPanel = NS.UI.DecorPricing:Create(frame.pricingHost) end
    frame.pricingPanel:Show()
    NS.UI.DecorPricing:Refresh(false)
    frame._hdRefreshing = nil
    return
  end
  if altsOpen then
    NS.Systems.SourceAdapter:EnsureCategory("Professions")
    frame.inspector:Hide()
    frame.architectHost:Hide()
    if frame.architectPanel then frame.architectPanel:Hide() end
    frame.pricingHost:Hide()
    if frame.pricingPanel then frame.pricingPanel:Hide() end
    frame.endeavorsHost:Hide()
    if frame.endeavorsPanel then frame.endeavorsPanel:Hide() end
    frame.statisticsHost:Hide()
    if frame.statisticsPanel then frame.statisticsPanel:Hide() end
    frame.altsHost:Show()
    if not frame.altsPanel then frame.altsPanel = NS.UI.AltProfessions:Create(frame.altsHost) end
    frame.altsPanel:Show()
    NS.UI.AltProfessions:Refresh()
    frame._hdRefreshing = nil
    return
  end
  if endeavorsOpen then
    frame.inspector:Hide()
    frame.architectHost:Hide()
    if frame.architectPanel then frame.architectPanel:Hide() end
    frame.pricingHost:Hide()
    if frame.pricingPanel then frame.pricingPanel:Hide() end
    frame.altsHost:Hide()
    if frame.altsPanel then frame.altsPanel:Hide() end
    frame.statisticsHost:Hide()
    if frame.statisticsPanel then frame.statisticsPanel:Hide() end
    frame.endeavorsHost:Show()
    if not frame.endeavorsPanel then frame.endeavorsPanel = NS.UI.Endeavors:Create(frame.endeavorsHost) end
    frame.endeavorsPanel:Show()
    NS.UI.Endeavors:Refresh()
    frame._hdRefreshing = nil
    return
  end
  if statisticsOpen then
    frame.inspector:Hide()
    frame.architectHost:Hide()
    if frame.architectPanel then frame.architectPanel:Hide() end
    frame.pricingHost:Hide()
    if frame.pricingPanel then frame.pricingPanel:Hide() end
    frame.altsHost:Hide()
    if frame.altsPanel then frame.altsPanel:Hide() end
    frame.endeavorsHost:Hide()
    if frame.endeavorsPanel then frame.endeavorsPanel:Hide() end
    frame.statisticsHost:Show()
    if not frame.statisticsPanel then frame.statisticsPanel = NS.UI.Statistics:Create(frame.statisticsHost) end
    frame.statisticsPanel:Show()
    NS.UI.Statistics:Refresh()
    frame._hdRefreshing = nil
    return
  end
  frame.architectHost:Hide()
  if frame.architectPanel then frame.architectPanel:Hide() end
  frame.pricingHost:Hide()
  if frame.pricingPanel then frame.pricingPanel:Hide() end
  frame.altsHost:Hide()
  if frame.altsPanel then frame.altsPanel:Hide() end
  frame.endeavorsHost:Hide()
  if frame.endeavorsPanel then frame.endeavorsPanel:Hide() end
  frame.statisticsHost:Hide()
  if frame.statisticsPanel then frame.statisticsPanel:Hide() end
  self:UpdateResponsiveLayout()
  local query = NS.Systems.QueryState:Fill(frame.query)
  local columns, rowHeight, rowWidth = self:GetLayout()
  if not frame.search:HasFocus() and frame.search:GetText() ~= (profile.ui.search or "") then
    frame._syncingSearch = true
    frame.search:SetText(profile.ui.search or "")
    frame._syncingSearch = nil
  end
  frame.searchPlaceholder:SetShown((frame.search:GetText() or "") == "" and not frame.search:HasFocus())
  frame.favorites:SetChecked(query.favoriteOnly)
  frame.tracked:SetChecked(query.trackedOnly)
  frame.compact:SetChecked(profile.ui.compact == true)
  for _, control in pairs(frame.filterControls or {}) do
    if control.ApplyText then control:ApplyText() end
  end
  if frame.filterPanel and frame.filterPanel.RefreshColors then frame.filterPanel:RefreshColors() end
  local activeFilters = NS.Systems.QueryState:GetActiveFilterCount()
  frame.filtersTop:SetText(activeFilters > 0 and ("Filters " .. tostring(activeFilters)) or "Filters")
  NS.UI.Controls:SetButtonSelected(frame.filtersTop, activeFilters > 0)
  if frame.filterPanel and frame.filterPanel.badge then
    frame.filterPanel.badge.text:SetText(activeFilters == 1 and "1 active" or tostring(activeFilters) .. " active")
    local border = activeFilters > 0 and COLOR.accent or COLOR.border
    frame.filterPanel.badge:SetBackdropBorderColor(border[1], border[2], border[3], 1)
  end
  frame.modeTop:SetText(profile.ui.catalogMode == "Sections" and "Groups" or "All")
  NS.UI.Controls:SetButtonSelected(frame.modeTop, profile.ui.catalogMode == "Sections")
  NS.UI.Controls:SetButtonSelected(frame.panelTop, profile.ui.panelVisible ~= false)
  NS.UI.Controls:SetButtonSelected(frame.compactTop, profile.ui.catalogOnly == true)
  NS.UI.Controls:SetButtonSelected(frame.galleryTop, false)
  if NS.UI.Theme then
    frame.galleryTop:SetText(NS.UI.Theme:GetDesignPresetLabel())
    if frame.galleryTop.icon then
      local accent = NS.UI.Controls.colors.accent
      frame.galleryTop.icon:SetVertexColor(accent[1], accent[2], accent[3], 0.95)
    end
  end
  NS.UI.Controls:SetButtonSelected(frame.eventsButton, route == "catalog" and profile.ui.category == "Events")
  local ownership = profile.ui.ownership or "All"
  for index = 1, #frame.ownershipButtons do
    local button = frame.ownershipButtons[index]
    button:SetEnabled(true)
    NS.UI.Controls:SetButtonSelected(button, button.ownership == ownership)
  end
  frame.sortTop:SetText("Sort: " .. NS.Systems.QueryState:GetOptionLabel("sort", NS.Systems.QueryState:GetSort()))
  for index = 1, #frame.viewButtons do
    local button = frame.viewButtons[index]
    button:SetEnabled(true)
    NS.UI.Controls:SetButtonSelected(button, button.view == profile.ui.view)
  end
  frame.compactSourceSelect.selectedIndex = 1
  frame.compactSourceSelect:SetText("Source: All Sources  v")
  for index = 1, #frame.categoryButtons do
    local button = frame.categoryButtons[index]
    local option = button.option or {}
    local selected = route == "catalog" and button.category == profile.ui.category
    if option.requirement then
      selected = selected and query.requirement == option.requirement
    elseif option.sourceType then
      selected = selected and query.sourceType == option.sourceType
    elseif button.category == "All" then
      selected = selected and not query.requirement and not query.sourceType
    end
    button:SetEnabled(true)
    NS.UI.Controls:SetButtonSelected(button, selected)
    if selected then
      frame.compactSourceSelect.selectedIndex = index
      frame.compactSourceSelect:SetText("Source: " .. tostring(option.label or "All Sources") .. "  v")
    end
  end
  for index = 1, #frame.routeButtons do
    local button = frame.routeButtons[index]
    button:SetEnabled(true)
    if button.route ~= "tracked" then NS.UI.Controls:SetButtonSelected(button, button.route == route) end
  end
  local grouped = profile.ui.catalogMode == "Sections" and route == "catalog" and (query.search or "") == ""
  if grouped then
    self:RenderGrouped(query, columns, rowHeight, scrollOffset)
    frame._hdRefreshing = nil
    return
  end
  self:RenderFlat(query, columns, rowHeight, rowWidth, scrollOffset)
  frame._hdRefreshing = nil
end

function CatalogView:Toggle()
  NS.UI.Controls:CloseTransientPopups()
  local frame = self:Create()
  if not frame:IsShown() then
    NS.Systems.QueryState:ResetFilters()
    NS.Systems.QueryState:SetCategory("All")
    NS.Systems.QueryState:SetRoute("catalog")
    if NS.Systems.Settings:GetValue("openCompact", false) then NS.Systems.QueryState:SetCatalogOnly(true) end
  end
  NS.UI.Controls:ToggleFrame(frame)
end

function CatalogView:Open(mode)
  NS.UI.Controls:CloseTransientPopups()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return end
  mode = mode or "catalog"
  if mode == "catalog" then
    NS.Systems.QueryState:ResetFilters()
    NS.Systems.QueryState:SetCategory("All")
  end
  NS.Systems.QueryState:SetRoute(mode)
  if NS.Systems.Settings:GetValue("openCompact", false) then NS.Systems.QueryState:SetCatalogOnly(true) end
  local frame = self:Create()
  local wasShown = frame:IsShown()
  frame:Show()
  if wasShown then self:Refresh(true) end
end

NS.Systems.ItemResolver:Subscribe(CatalogView, function(_, itemID, name)
  local frame = CatalogView.frame
  if not frame then return end
  local changed = false
  for _, record in ipairs(NS.Systems.Catalog.ordered or {}) do
    if record and tonumber(record.itemID) == tonumber(itemID) then
      if type(name) == "string" and name ~= "" then
        record.title = name
      elseif record.title == "Loading..." then
        record.title = nil
      end
      record.icon = NS.Systems.ItemResolver:GetIcon(itemID)
      if NS.Systems.SearchIndex then NS.Systems.SearchIndex:Invalidate(record) end
      changed = true
    end
  end
  if not changed then return end
  if CatalogView.itemDisplayTimer then CatalogView.itemDisplayTimer:Cancel() end
  CatalogView.itemDisplayTimer = C_Timer.NewTimer(0.05, function()
    CatalogView.itemDisplayTimer = nil
    local sort = NS.Systems.QueryState:GetSort()
    if sort == "name" or sort == "name_desc" then
      NS.Systems.Catalog:Sort(sort)
      CatalogView:Refresh(false)
    else
      CatalogView:RefreshViewport(false)
    end
  end)
end)

NS.OnMessage("HOMEDECOR_THEME_UPDATED", function()
  if not CatalogView.frame then return end
  CatalogView:Refresh(true)
  if NS.UI.Settings then NS.UI.Settings:Sync() end
end)
