local _, NS = ...

NS.UI = NS.UI or {}
local ItemInteractions = {}
NS.UI.ItemInteractions = ItemInteractions

local function AddLink(links, seen, label, url)
  if not url or seen[url] then return end
  seen[url] = true
  links[#links + 1] = { label = label, url = url }
end

local function EncodeQuery(value)
  return tostring(value or ""):gsub("([^%w%-_%.~])", function(character) return string.format("%%%02X", string.byte(character)) end)
end

local function AchievementID(record)
  local requirements = record and record.requirements
  local sourceID = record and record.sourceType == "achievement" and record.sourceID
  local achievement = requirements and requirements.achievement
  local requirementID = type(achievement) == "table" and (achievement.id or achievement.achievementID) or achievement
  return tonumber(sourceID or requirementID)
end

local function QuestID(record)
  local requirements = record and record.requirements
  local sourceID = record and record.sourceType == "quest" and record.sourceID
  local quest = requirements and requirements.quest
  local requirementID = type(quest) == "table" and (quest.id or quest.questID) or quest
  return tonumber(sourceID or requirementID)
end

function ItemInteractions:OpenRequirement(record)
  local achievementID = AchievementID(record)
  if achievementID then
    local loader = _G.C_AddOns and _G.C_AddOns.LoadAddOn or _G.LoadAddOn
    if loader then pcall(loader, "Blizzard_AchievementUI") end
    if _G.AchievementFrame_LoadUI then pcall(_G.AchievementFrame_LoadUI) end
    local toggle = _G.AchievementFrame_ToggleAchievementFrame
    if not toggle then return false end
    local frame = _G.AchievementFrame
    if not frame or not frame.IsShown or not frame:IsShown() then
      local ok = pcall(toggle)
      if not ok then return false end
    end
    local function SelectAchievement()
      if _G.AchievementFrame_SelectAchievement then pcall(_G.AchievementFrame_SelectAchievement, achievementID) end
    end
    SelectAchievement()
    if _G.C_Timer and _G.C_Timer.After then _G.C_Timer.After(0, SelectAchievement) end
    return true
  end
  local questID = QuestID(record)
  if questID and _G.QuestMapFrame_OpenToQuestDetails then
    local ok = pcall(_G.QuestMapFrame_OpenToQuestDetails, questID)
    if ok then return true end
  end
  return false
end

function ItemInteractions:BuildLinks(record)
  if not record then return nil end
  local links, seen = {}, {}
  local itemID = tonumber(record.itemID or record.id)
  if itemID then AddLink(links, seen, "Item Link", "https://www.wowhead.com/item=" .. itemID) end
  local requirements = record.requirements
  local achievementID = AchievementID(record)
  if achievementID then AddLink(links, seen, "Achievement Link", "https://www.wowhead.com/achievement=" .. achievementID) end
  local questID = QuestID(record)
  if questID then AddLink(links, seen, "Quest Link", "https://www.wowhead.com/quest=" .. questID) end
  local reputation = requirements and (requirements.reputation or requirements.rep)
  local reputationName = type(reputation) == "table" and (reputation.name or reputation.title or reputation.faction) or nil
  if reputation and not reputationName and NS.Systems.Requirements then
    local values = NS.Systems.Requirements:Get(record)
    for index = 1, #values do
      if values[index].kind == "reputation" then reputationName = values[index].title break end
    end
  end
  if reputation and not reputationName then reputationName = tostring(record.sourceName or record.vendorName or record.zone or record.title or "decor") .. " reputation" end
  if reputationName then AddLink(links, seen, "Reputation Search", "https://www.wowhead.com/search?q=" .. EncodeQuery(reputationName)) end
  return #links > 0 and links or nil
end

function ItemInteractions:CreatePopup()
  if self.popup then return self.popup end
  local frame = CreateFrame("Frame", "HomeDecorLinks", UIParent, "BackdropTemplate")
  frame:SetSize(560, 230)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.background, NS.UI.Controls.colors.border)
  NS.UI.Controls:MakeMovable(frame, frame)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -15)
  title:SetText("Wowhead Links")
  local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("TOPLEFT", 16, -42)
  hint:SetText("Select and copy the link you need.")
  local close = NS.UI.Controls:CreateCloseButton(frame, function() frame:Hide() end)
  close:SetPoint("TOPRIGHT", -8, -8)
  frame.rows = {}
  for index = 1, 4 do
    local row = CreateFrame("Frame", nil, frame)
    row:SetPoint("TOPLEFT", 16, -62 - (index - 1) * 50)
    row:SetPoint("TOPRIGHT", -16, -62 - (index - 1) * 50)
    row:SetHeight(44)
    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.label:SetPoint("TOPLEFT")
    row.edit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    row.edit:SetPoint("TOPLEFT", 0, -17)
    row.edit:SetPoint("TOPRIGHT", 0, -17)
    row.edit:SetHeight(22)
    row.edit:SetAutoFocus(false)
    row.edit:SetTextInsets(8, 8, 0, 0)
    row.edit:SetScript("OnEscapePressed", function() frame:Hide() end)
    row.edit:SetScript("OnEnterPressed", function() frame:Hide() end)
    frame.rows[index] = row
  end
  frame:Hide()
  self.popup = frame
  return frame
end

local function SameDecor(left, right)
  if not left or not right then return false end
  if left.decorID and right.decorID then return tonumber(left.decorID) == tonumber(right.decorID) end
  return left.itemID and right.itemID and tonumber(left.itemID) == tonumber(right.itemID)
end

local function SourceName(record)
  local source = tostring(record.sourceType or record.category or "Source")
  source = source:sub(1, 1):upper() .. source:sub(2)
  local name = record.sourceName or record.vendorName
  if not name and record.sourceType == "vendor" and record.sourceID and NS.Systems.NPCNames then name = NS.Systems.NPCNames:Get(record.sourceID) end
  local values = { source }
  if name then values[#values + 1] = tostring(name) end
  if record.zone then values[#values + 1] = tostring(record.zone) end
  return table.concat(values, "  ·  ")
end

function ItemInteractions:BuildSources(record)
  if not record then return {} end
  local catalog = NS.Systems.Catalog
  local sources, seen = {}, {}
  local function AddSource(candidate)
    local key = table.concat({ tostring(candidate.sourceType or ""), tostring(candidate.sourceID or ""), tostring(candidate.sourceName or candidate.vendorName or ""), tostring(candidate.zone or ""), tostring(candidate.mapID or ""), tostring(candidate.mapX or ""), tostring(candidate.mapY or "") }, "\031")
    if not seen[key] then
      seen[key] = true
      sources[#sources + 1] = candidate
    end
  end
  local function AddLocations(owner)
    for index = 1, #(owner.dropLocations or {}) do
      local location = owner.dropLocations[index]
      local candidate = {}
      for key, value in pairs(owner) do candidate[key] = value end
      for key, value in pairs(location) do candidate[key] = value end
      candidate.dropLocations = nil
      candidate.alternateSources = nil
      AddSource(candidate)
    end
  end
  for _, candidate in ipairs(catalog:GetMatches(record)) do
    if SameDecor(record, candidate) then
      if candidate.dropLocations and #candidate.dropLocations > 0 then AddLocations(candidate) else AddSource(candidate) end
      for alternateIndex = 1, #(candidate.alternateSources or {}) do
        local alternate = candidate.alternateSources[alternateIndex]
        if alternate.dropLocations and #alternate.dropLocations > 0 then AddLocations(alternate) else AddSource(alternate) end
      end
    end
  end
  if #sources == 0 then sources[1] = record end
  table.sort(sources, function(left, right) return SourceName(left) < SourceName(right) end)
  return sources
end

function ItemInteractions:GetSourceCount(record)
  return #self:BuildSources(record)
end

function ItemInteractions:GetSourceInfo(record)
  local sources = self:BuildSources(record)
  local sourceType
  for index = 1, #sources do
    local current = sources[index].sourceType
    if sourceType and current ~= sourceType then
      sourceType = "mixed"
      break
    end
    sourceType = current
  end
  local label = sourceType == "vendor" and "Vendors" or sourceType == "drop" and "Drops" or "Sources"
  return #sources, label, sources
end

function ItemInteractions:CreateSourcePopup()
  if self.sourcePopup then return self.sourcePopup end
  local frame = CreateFrame("Frame", "HomeDecorSources", UIParent, "BackdropTemplate")
  frame:SetSize(260, 220)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(500)
  frame:SetToplevel(true)
  frame:EnableMouse(true)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.panel, NS.UI.Controls.colors.border)
  frame.heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.heading:SetPoint("TOPLEFT", 12, -10)
  NS.UI.Controls:TextColor(frame.heading, "accent")
  frame.rows = {}
  frame:SetPropagateKeyboardInput(true)
  frame:SetScript("OnKeyDown", function(_, key) if key == "ESCAPE" then frame:Hide() end end)
  frame:SetScript("OnLeave", function()
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0.25, function()
        if frame:IsShown() and _G.MouseIsOver and not _G.MouseIsOver(frame) then frame:Hide() end
      end)
    end
  end)
  NS.UI.Controls:RegisterTransientPopup(frame)
  frame:Hide()
  self.sourcePopup = frame
  return frame
end

function ItemInteractions:CreateSourceRow(frame, index)
  local row = frame.rows[index]
  if row then return row end
  row = CreateFrame("Button", nil, frame)
  row:SetFrameLevel(frame:GetFrameLevel() + 2)
  row:EnableMouse(true)
  row:RegisterForClicks("LeftButtonUp")
  row:SetSize(236, 18)
  row:SetPoint("TOPLEFT", 12, -30 - (index - 1) * 22)
  row:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
  row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.text:SetPoint("LEFT")
  row.text:SetPoint("RIGHT")
  row.text:SetJustifyH("LEFT")
  row:SetScript("OnEnter", function(button)
    if not button.record or not _G.GameTooltip then return end
    _G.GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    _G.GameTooltip:ClearLines()
    _G.GameTooltip:AddLine(button.record.sourceName or "Drop location", 1, 0.82, 0)
    _G.GameTooltip:AddLine(" ")
    _G.GameTooltip:AddLine(button.record.mapID and "Click: Open Map" or "Map location unavailable", 0.8, 0.8, 0.8)
    _G.GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() if _G.GameTooltip then _G.GameTooltip:Hide() end end)
  row:SetScript("OnClick", function(button)
    local selected = button.record
    if not selected then return end
    frame:Hide()
    ItemInteractions:OpenMap(selected)
  end)
  frame.rows[index] = row
  return row
end

function ItemInteractions:ShowSources(anchor, record)
  local count, label, sources = self:GetSourceInfo(record)
  if #sources == 0 then return false end
  if _G.GameTooltip then _G.GameTooltip:Hide() end
  local frame = self:CreateSourcePopup()
  frame.sources = sources
  frame.heading:SetText(label .. " (" .. tostring(count) .. ")")
  NS.UI.Controls:SetTransientAnchor(frame, anchor)
  frame:SetHeight(220)
  for index = 1, #sources do
    local row = self:CreateSourceRow(frame, index)
    row.record = sources[index]
    row.text:SetText("• " .. SourceName(sources[index]))
    row:Show()
  end
  for index = #sources + 1, #frame.rows do frame.rows[index]:Hide() end
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 10, 0)
  frame:Show()
  return true
end

function ItemInteractions:OpenMap(record)
  if not record then return false end
  if NS.UI.CatalogView then NS.UI.CatalogView.selected = record end
  local profile = NS.Systems.Database:GetProfile()
  local catalog = NS.UI.CatalogView and NS.UI.CatalogView.frame
  local panelOpen = catalog and catalog:IsShown() and profile.ui.panelVisible ~= false and catalog:GetWidth() >= 1080
  if panelOpen and NS.UI.Inspector then NS.UI.Inspector:Show(record) end
  if NS.Systems.Navigation:Open(record) then
    NS.Systems.MapPins:Attach()
    NS.Systems.MapPins:RequestRefresh()
    return true
  end
  return NS.Systems.MapPins:Open(record)
end

function ItemInteractions:OpenSource(anchor, record)
  local count, _, sources = self:GetSourceInfo(record)
  if count > 1 then return self:ShowSources(anchor, record) end
  return self:OpenMap(sources[1] or record)
end

function ItemInteractions:ShowLinks(record)
  local links = self:BuildLinks(record)
  if not links then return false end
  local frame = self:CreatePopup()
  local first
  for index = 1, #frame.rows do
    local row = frame.rows[index]
    local link = links[index]
    row:SetShown(link ~= nil)
    if link then
      row.label:SetText(link.label)
      row.edit:SetText(link.url)
      if not first then first = row.edit end
    end
  end
  frame:SetHeight(74 + #links * 50)
  frame:Show()
  if first then
    first:SetFocus()
    first:HighlightText()
  end
  return true
end

function ItemInteractions:Preview(record)
  local itemID = record and tonumber(record.itemID or record.id)
  if not itemID or not _G.DressUpItemLink then return false end
  return pcall(_G.DressUpItemLink, "item:" .. tostring(itemID))
end

function ItemInteractions:HandleClick(record)
  if _G.IsControlKeyDown and _G.IsControlKeyDown() then return self:OpenRequirement(record) end
  if _G.IsAltKeyDown and _G.IsAltKeyDown() then return self:ShowLinks(record) end
  return false
end
