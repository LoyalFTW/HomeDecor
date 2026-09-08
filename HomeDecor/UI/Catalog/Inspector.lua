local _, NS = ...

NS.UI = NS.UI or {}
local Inspector = {}
NS.UI.Inspector = Inspector

local GOLD = NS.UI.Controls.colors.border
local PANEL = NS.UI.Controls.colors.header

local function FactionTexture(value)
  if type(value) ~= "string" then return nil end
  value = value:lower()
  if value == "alliance" then return "Interface\\FriendsFrame\\PlusManz-Alliance" end
  if value == "horde" then return "Interface\\FriendsFrame\\PlusManz-Horde" end
  return nil
end

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

local function SkinButton(button)
  NS.UI.Controls:SkinButton(button)
end

local function ClearPreview(frame)
  if not frame.preview then return end
  local actor = frame.preview.GetActorByTag and frame.preview:GetActorByTag("decor")
  if actor and actor.ClearModel then pcall(actor.ClearModel, actor) end
  frame.preview:Hide()
  frame.previewBackdrop:Hide()
  if frame.previewControls then frame.previewControls:Hide() end
  frame.previewClose:Hide()
  frame.previewFallback:Hide()
  frame.icon:Show()
end

local function ShowPreview(frame, record)
  if not record or not record.decorID then return end
  local info = NS.Systems.Housing:GetEntry(record)
  if not info or not info.asset then
    frame.icon:Show()
    return
  end
  local sceneID = info.uiModelSceneID or (_G.Constants and _G.Constants.HousingCatalogConsts and _G.Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT) or 859
  local transitioned = pcall(frame.preview.TransitionToModelSceneID, frame.preview, sceneID, _G.CAMERA_TRANSITION_TYPE_IMMEDIATE, _G.CAMERA_MODIFICATION_TYPE_DISCARD, true)
  local actor = frame.preview.GetActorByTag and frame.preview:GetActorByTag("decor")
  if not transitioned or not actor then
    frame.icon:Show()
    return
  end
  pcall(actor.SetPreferModelCollisionBounds, actor, true)
  pcall(actor.SetModelByFileID, actor, info.asset)
  frame.previewFallback:Hide()
  frame.icon:Hide()
  frame.previewBackdrop:Show()
  frame.preview:Show()
  if frame.previewControls then frame.previewControls:Show() end
end

local function RequirementText(record)
  return NS.Systems.Requirements:Text(record)
end

local SOURCE_LABELS = {
  achievement = "ACHIEVEMENT", quest = "QUEST", vendor = "VENDOR", drop = "DROP",
  encounter = "ENCOUNTER", shop = "SHOP", treasure = "TREASURE", profession = "PROFESSION",
  event = "EVENT", pvp = "PVP",
}

local function SourceHeading(record)
  return SOURCE_LABELS[tostring(record.sourceType or ""):lower()] or tostring(record.sourceType or record.category or "SOURCE"):upper()
end

local function SourceText(record)
  local lines = {}
  local name = record.sourceName or record.vendorName
  if not name and record.sourceType == "vendor" and record.sourceID and NS.Systems.NPCNames then name = NS.Systems.NPCNames:Get(record.sourceID) end
  if name then lines[#lines + 1] = tostring(name) end
  local location = {}
  if record.zone then location[#location + 1] = tostring(record.zone) end
  if record.expansion then location[#location + 1] = tostring(record.expansion) end
  if #location > 0 then lines[#lines + 1] = table.concat(location, "  ·  ") end
  if #lines == 0 then lines[1] = "Source details unavailable" end
  return table.concat(lines, "\n")
end

local function DetailText(record)
  local lines = {}
  if record.size then lines[#lines + 1] = "Size  |cffe8e2d5" .. tostring(record.size) .. "|r" end
  if record.budgetCost then lines[#lines + 1] = "Placement budget  |cffe8e2d5" .. tostring(record.budgetCost) .. "|r" end
  local cost = NS.Systems.Cost:Format(record)
  if cost then lines[#lines + 1] = "Price  |cffffd166" .. tostring(cost) .. "|r" end
  if record.note then lines[#lines + 1] = "Note: " .. tostring(record.note) end
  return table.concat(lines, "\n")
end

local function ContextText(record)
  if tostring(record.sourceType or ""):lower() == "profession" then
    local trade = {}
    if record.expansion and record.expansion ~= "" then trade[#trade + 1] = tostring(record.expansion) end
    if record.profession and record.profession ~= "" then trade[#trade + 1] = tostring(record.profession) end
    if #trade > 0 then return "Profession: " .. table.concat(trade, " ") end
  end
  return NS.Systems.Housing:GetCategoryPath(record) or "Decor"
end

local function StateText(record, owned)
  local values = { owned and "|cff72e58bCOLLECTED|r" or "|cffffd166MISSING|r" }
  values[#values + 1] = NS.Systems.Housing:IsDyeable(record) and "|cff7dd3fcDYEABLE|r" or "|cff89919bNOT DYEABLE|r"
  local restrictions = {}
  local class = NS.Systems.Housing:GetClassRestriction(record)
  if class then restrictions[#restrictions + 1] = "|cff7dd3fc" .. tostring(class):upper() .. "|r" end
  if record.raceRestriction then restrictions[#restrictions + 1] = tostring(record.raceRestriction):upper() end
  local faction = FactionName(record.faction)
  if faction and faction ~= "Neutral" then restrictions[#restrictions + 1] = faction:upper() end
  local text = table.concat(values, "   ")
  return #restrictions > 0 and (text .. "\n" .. table.concat(restrictions, "   ")) or text
end

local function CreateDivider(parent, y)
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetPoint("TOPLEFT", 14, y)
  line:SetPoint("TOPRIGHT", -14, y)
  line:SetHeight(1)
  line:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.45)
  return line
end

local function LineCount(text)
  if not text or text == "" then return 0 end
  local _, breaks = text:gsub("\n", "")
  return breaks + 1
end

local function SetTop(text, y, right)
  text:ClearAllPoints()
  text:SetPoint("TOPLEFT", 14, y)
  text:SetPoint("TOPRIGHT", right or -14, y)
end

local function SetDivider(line, y)
  line:ClearAllPoints()
  line:SetPoint("TOPLEFT", 14, y)
  line:SetPoint("TOPRIGHT", -14, y)
end

local function LayoutDetails(frame, detailText, stateText, sourceText, requirementText)
  SetTop(frame.detailsTitle, -287)
  SetTop(frame.details, -308)
  local detailLines = math.max(1, LineCount(detailText))
  local detailsDividerY = -308 - detailLines * 13 - 7
  SetDivider(frame.stateDivider, detailsDividerY)
  local stateY = detailsDividerY - 14
  SetTop(frame.state, stateY)
  local stateLines = math.max(1, LineCount(stateText))
  local stateDividerY = stateY - stateLines * 13 - 8
  SetDivider(frame.sourceDivider, stateDividerY)
  local sourceTitleY = stateDividerY - 12
  local sourceTextY = sourceTitleY - 21
  local sourceLines = math.max(1, LineCount(sourceText))
  local sourceDividerY = sourceTextY - sourceLines * 13 - 7
  SetTop(frame.sourceTitle, sourceTitleY, -104)
  SetTop(frame.source, sourceTextY)
  frame.sourcesButton:ClearAllPoints()
  frame.sourcesButton:SetPoint("TOPRIGHT", -14, sourceTitleY + 5)
  if requirementText ~= "" then
    local requirementsTitleY = sourceDividerY - 12
    local requirementsTextY = requirementsTitleY - 21
    SetTop(frame.requirementsTitle, requirementsTitleY, -92)
    SetTop(frame.requirements, requirementsTextY)
    frame.requirementAction:ClearAllPoints()
    frame.requirementAction:SetPoint("TOPRIGHT", -14, requirementsTitleY + 5)
    SetDivider(frame.requirementDivider, sourceDividerY)
    frame.requirementsTitle:Show()
    frame.requirements:Show()
    frame.requirementAction:Show()
    frame.requirementDivider:Show()
  else
    frame.requirementsTitle:Hide()
    frame.requirements:Hide()
    frame.requirementAction:Hide()
    frame.requirementDivider:Hide()
  end
end

local function ClearViewerModel(frame)
  local actor = frame.scene.GetActorByTag and frame.scene:GetActorByTag("decor")
  if actor and actor.ClearModel then pcall(actor.ClearModel, actor) end
  frame.scene:Hide()
  if frame.sceneControls then frame.sceneControls:Hide() end
end

local function LoadViewerModel(frame, record)
  ClearViewerModel(frame)
  frame.largeIcon:Hide()
  frame.fallback:Hide()
  local info = record and record.decorID and NS.Systems.Housing:GetEntry(record)
  if not info or not info.asset then
    frame.largeIcon:Show()
    frame.fallback:SetText("A 3D preview is not available for this item.")
    frame.fallback:Show()
    return false
  end
  local sceneID = info.uiModelSceneID or (_G.Constants and _G.Constants.HousingCatalogConsts and _G.Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT) or 859
  local transitioned = pcall(frame.scene.TransitionToModelSceneID, frame.scene, sceneID, _G.CAMERA_TRANSITION_TYPE_IMMEDIATE, _G.CAMERA_MODIFICATION_TYPE_DISCARD, true)
  local actor = frame.scene.GetActorByTag and frame.scene:GetActorByTag("decor")
  if not transitioned or not actor then
    frame.largeIcon:Show()
    frame.fallback:SetText("A 3D preview is not available for this item.")
    frame.fallback:Show()
    return false
  end
  pcall(actor.SetPreferModelCollisionBounds, actor, true)
  local modeled = pcall(actor.SetModelByFileID, actor, info.asset)
  if not modeled then
    frame.largeIcon:Show()
    frame.fallback:SetText("A 3D preview is not available for this item.")
    frame.fallback:Show()
    return false
  end
  frame.scene:Show()
  if frame.sceneControls then frame.sceneControls:Show() end
  return true
end

function Inspector:CreateItemViewer()
  if self.viewer then return self.viewer end
  local controls = NS.UI.Controls
  local frame = controls:CreateDialog("HomeDecorItemViewer", "View Item", 640, 650, "itemViewer")
  frame.modelHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.modelHost:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -8)
  frame.modelHost:SetPoint("TOPRIGHT", frame.header, "BOTTOMRIGHT", 0, -8)
  frame.modelHost:SetPoint("BOTTOM", frame, "BOTTOM", 0, 104)
  frame.modelHost:SetClipsChildren(true)
  controls:Backdrop(frame.modelHost, controls.colors.panel, controls.colors.border)
  frame.scene = CreateFrame("ModelScene", nil, frame.modelHost, "PanningModelSceneMixinTemplate")
  frame.scene:SetPoint("TOPLEFT", 8, -8)
  frame.scene:SetPoint("BOTTOMRIGHT", -8, 8)
  frame.scene:Hide()
  local controlsOK, sceneControls = pcall(CreateFrame, "Frame", nil, frame.scene, "ModelSceneControlFrameTemplate")
  if controlsOK and sceneControls then
    sceneControls:SetPoint("BOTTOM", frame.scene, "BOTTOM", 0, 14)
    pcall(sceneControls.SetModelScene, sceneControls, frame.scene)
    sceneControls:SetFrameLevel(frame.scene:GetFrameLevel() + 2)
    sceneControls:Hide()
    frame.sceneControls = sceneControls
  end
  frame.largeIcon = frame.modelHost:CreateTexture(nil, "ARTWORK")
  frame.largeIcon:SetSize(180, 180)
  frame.largeIcon:SetPoint("CENTER", 0, 16)
  frame.largeIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  frame.largeIcon:Hide()
  frame.fallback = frame.modelHost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.fallback:SetPoint("TOP", frame.largeIcon, "BOTTOM", 0, -18)
  frame.fallback:SetWidth(360)
  frame.fallback:SetJustifyH("CENTER")
  controls:TextColor(frame.fallback, "muted")
  frame.fallback:Hide()
  frame.info = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.info:SetPoint("BOTTOMLEFT", 7, 7)
  frame.info:SetPoint("BOTTOMRIGHT", -7, 7)
  frame.info:SetHeight(88)
  controls:Backdrop(frame.info, controls.colors.header, controls.colors.border)
  frame.icon = frame.info:CreateTexture(nil, "ARTWORK")
  frame.icon:SetSize(56, 56)
  frame.icon:SetPoint("LEFT", 14, 0)
  frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  frame.name = frame.info:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  frame.name:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 12, -2)
  frame.name:SetPoint("TOPRIGHT", -130, -2)
  frame.name:SetJustifyH("LEFT")
  frame.name:SetWordWrap(false)
  controls:TextColor(frame.name, "accent")
  frame.meta = frame.info:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.meta:SetPoint("TOPLEFT", frame.name, "BOTTOMLEFT", 0, -6)
  frame.meta:SetPoint("TOPRIGHT", -130, -6)
  frame.meta:SetJustifyH("LEFT")
  frame.meta:SetWordWrap(false)
  controls:TextColor(frame.meta, "muted")
  frame.reset = controls:CreateButton(frame.info, "Reset Camera", 108, 26)
  frame.reset:SetPoint("RIGHT", -12, 0)
  frame.reset:SetScript("OnClick", function()
    if frame.record then LoadViewerModel(frame, frame.record) end
  end)
  frame:HookScript("OnHide", function(self)
    ClearViewerModel(self)
    self.record = nil
  end)
  self.viewer = frame
  return frame
end

function Inspector:ViewItem(record)
  if not record or not record.decorID then return false end
  local frame = self:CreateItemViewer()
  local title, icon = NS.Systems.Housing:GetDisplay(record)
  local meta = { tostring(record.category or "Decor") }
  if record.subcategory and record.subcategory ~= "" then meta[#meta + 1] = tostring(record.subcategory) end
  local source = SourceText(record):gsub("\n", "  ·  ")
  if source ~= "" then meta[#meta + 1] = source end
  frame.record = record
  frame.name:SetText(title or "Decor Item")
  frame.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
  frame.largeIcon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
  frame.meta:SetText(table.concat(meta, "  ·  "))
  frame:Show()
  if frame.Raise then frame:Raise() end
  LoadViewerModel(frame, record)
  return true
end

function Inspector:Create(parent)
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  NS.UI.Controls:Backdrop(frame, PANEL, GOLD)
  frame.previewTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.previewTitle:SetPoint("TOPLEFT", 14, -11)
  frame.previewTitle:SetText("DECOR PREVIEW")
  frame.previewTitle:SetTextColor(1, 0.76, 0.08, 1)
  frame.iconWell = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.iconWell:SetPoint("TOPLEFT", 10, -30)
  frame.iconWell:SetPoint("TOPRIGHT", -10, -30)
  frame.iconWell:SetHeight(185)
  NS.UI.Controls:Backdrop(frame.iconWell, NS.UI.Controls.colors.background, GOLD)
  frame.iconGlow = frame.iconWell:CreateTexture(nil, "BACKGROUND")
  frame.iconGlow:SetPoint("CENTER")
  frame.iconGlow:SetSize(156, 112)
  frame.iconGlow:SetTexture("Interface\\Buttons\\WHITE8x8")
  frame.iconGlow:SetVertexColor(0.10, 0.075, 0.018, 0.45)
  frame.icon = frame.iconWell:CreateTexture(nil, "ARTWORK")
  frame.icon:SetSize(112, 112)
  frame.icon:SetPoint("CENTER", frame.iconWell, "CENTER", 0, 0)
  frame.check = frame.iconWell:CreateTexture(nil, "OVERLAY")
  frame.check:SetSize(20, 20)
  frame.check:SetPoint("BOTTOMRIGHT", frame.icon, "BOTTOMRIGHT", 4, -4)
  frame.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  frame.check:Hide()
  frame.factionIcon = frame:CreateTexture(nil, "OVERLAY")
  frame.factionIcon:SetSize(28, 28)
  frame.factionIcon:SetPoint("TOPRIGHT", frame.iconWell, "TOPRIGHT", -8, -8)
  frame.factionIcon:Hide()
  frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.empty:SetPoint("TOP", 0, -225)
  frame.empty:SetWidth(230)
  frame.empty:SetJustifyH("CENTER")
  frame.empty:SetText("Select an item\nChoose decor from the catalog to see its details.")
  frame.empty:SetTextColor(0.64, 0.62, 0.56, 1)
  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  frame.title:SetPoint("TOPLEFT", 14, -226)
  frame.title:SetPoint("TOPRIGHT", -14, -226)
  frame.title:SetJustifyH("LEFT")
  frame.title:SetWordWrap(true)
  frame.category = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.category:SetPoint("TOPLEFT", 14, -265)
  frame.category:SetPoint("TOPRIGHT", -14, -265)
  frame.category:SetJustifyH("LEFT")
  frame.category:SetTextColor(0.64, 0.62, 0.56, 1)
  frame.state = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.state:SetPoint("TOPLEFT", 14, -287)
  frame.state:SetPoint("TOPRIGHT", -14, -287)
  frame.state:SetJustifyH("LEFT")
  frame.sourceTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.sourceTitle:SetPoint("TOPLEFT", 14, -331)
  frame.sourceTitle:SetTextColor(1, 0.76, 0.08, 1)
  frame.source = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.source:SetPoint("TOPLEFT", 14, -352)
  frame.source:SetPoint("TOPRIGHT", -14, -352)
  frame.source:SetJustifyH("LEFT")
  frame.source:SetWordWrap(true)
  frame.location = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.location:SetPoint("TOPLEFT", 14, -369)
  frame.location:SetPoint("TOPRIGHT", -14, -369)
  frame.location:SetJustifyH("LEFT")
  frame.location:SetWordWrap(true)
  frame.requirementsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.requirementsTitle:SetPoint("TOPLEFT", 14, -397)
  frame.requirementsTitle:SetText("REQUIREMENTS")
  frame.requirementsTitle:SetTextColor(1, 0.76, 0.08, 1)
  frame.requirements = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.requirements:SetPoint("TOPLEFT", 14, -418)
  frame.requirements:SetPoint("TOPRIGHT", -14, -418)
  frame.requirements:SetJustifyH("LEFT")
  frame.requirements:SetWordWrap(true)
  frame.detailsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.detailsTitle:SetPoint("TOPLEFT", 14, -471)
  frame.detailsTitle:SetText("DETAILS")
  frame.detailsTitle:SetTextColor(1, 0.76, 0.08, 1)
  frame.details = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.details:SetPoint("TOPLEFT", 14, -492)
  frame.details:SetPoint("TOPRIGHT", -14, -492)
  frame.details:SetJustifyH("LEFT")
  frame.details:SetWordWrap(true)
  frame.note = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.note:SetPoint("TOPLEFT", 14, -559)
  frame.note:SetPoint("TOPRIGHT", -14, -559)
  frame.note:SetJustifyH("LEFT")
  frame.note:SetWordWrap(true)
  frame.stateDivider = CreateDivider(frame, -319)
  frame.sourceDivider = CreateDivider(frame, -385)
  frame.requirementDivider = CreateDivider(frame, -459)
  frame.sourcesButton = NS.UI.Controls:CreateButton(frame, "SOURCES", 84, 19)
  frame.sourcesButton:SetScript("OnClick", function(button)
    if Inspector.record then NS.UI.ItemInteractions:ShowSources(button, Inspector.record) end
  end)
  frame.sourcesButton:Hide()
  frame.requirementAction = NS.UI.Controls:CreateButton(frame, "WOWHEAD", 72, 19)
  frame.requirementAction:SetScript("OnClick", function()
    if Inspector.record then NS.UI.ItemInteractions:ShowLinks(Inspector.record) end
  end)
  frame.requirementAction:Hide()
  frame.favorite = NS.UI.FavoriteStar:Create(frame, 22)
  frame.favorite:SetPoint("TOPLEFT", frame.iconWell, "TOPLEFT", 7, -7)
  frame.track = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  frame.track:SetSize(72, 26)
  frame.track:SetScript("OnClick", function(button)
    if not Inspector.record then return end
    local record = Inspector.record
    local active = NS.Systems.Tracker:Toggle(record)
    Inspector:Show(record)
    if NS.UI.CatalogView then NS.UI.CatalogView:InvalidateDisplay() end
    NS.Systems.MapPins:RequestRefresh()
    NS.UI.ListSelector:Show(button, record, function(id, selected)
      NS.Systems.Lists:Toggle(selected, id)
      if NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
    end, active and "Add to Lists" or "Update Lists")
  end)
  SkinButton(frame.track)
  frame.track:Hide()
  frame.map = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  frame.map:SetSize(76, 26)
  frame.map:SetPoint("BOTTOMRIGHT", -10, 10)
  frame.map:SetText("Map")
  frame.map:SetScript("OnClick", function()
    local record = Inspector.record
    if not record then return end
    if NS.Systems.Navigation:Open(record) then
      NS.Systems.MapPins:Attach()
      if _G.C_Timer and _G.C_Timer.After then
        _G.C_Timer.After(0, function() NS.Systems.MapPins:RequestRefresh() end)
      else
        NS.Systems.MapPins:RequestRefresh()
      end
    else
      NS.Systems.MapPins:Open(record)
    end
  end)
  SkinButton(frame.map)
  frame.waypoint = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  frame.waypoint:SetSize(148, 26)
  frame.waypoint:SetPoint("BOTTOM", 0, 144)
  frame.waypoint:SetScript("OnClick", function()
    if not Inspector.record then return end
    NS.Systems.Navigation:Toggle(Inspector.record)
    Inspector:Show(Inspector.record)
  end)
  SkinButton(frame.waypoint)
  frame.waypoint:Hide()
  frame.previewButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  frame.previewButton:SetSize(68, 26)
  frame.previewButton:SetPoint("BOTTOMLEFT", 10, 10)
  frame.previewButton:SetText("View Item")
  frame.previewButton:SetScript("OnClick", function()
    Inspector:ViewItem(Inspector.record)
  end)
  SkinButton(frame.previewButton)
  frame.list = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  frame.list:SetSize(54, 26)
  frame.list:SetText("Links")
  frame.list:SetScript("OnClick", function()
    if not Inspector.record then return end
    NS.UI.ItemInteractions:ShowLinks(Inspector.record)
  end)
  SkinButton(frame.list)
  frame.track:SetPoint("LEFT", frame.previewButton, "RIGHT", 6, 0)
  frame.list:SetPoint("LEFT", frame.track, "RIGHT", 6, 0)
  frame.map:ClearAllPoints()
  frame.map:SetSize(54, 26)
  frame.map:SetPoint("LEFT", frame.list, "RIGHT", 6, 0)
  frame.architect = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate,BackdropTemplate")
  frame.architect:SetSize(148, 26)
  frame.architect:SetPoint("BOTTOM", 0, 208)
  frame.architect:SetText("Add to Architect Room")
  frame.architect:SetScript("OnClick", function()
    local architect = NS.UI.Architect
    local roomID = architect and architect.panel and architect.panel.selectedRoomID
    if not Inspector.record or not roomID then return end
    NS.Systems.Architect:AddItemToRoom(roomID, Inspector.record)
    architect:Refresh()
  end)
  SkinButton(frame.architect)
  frame.architect:Hide()
  frame.previewBackdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.previewBackdrop:SetAllPoints(frame.iconWell)
  frame.previewBackdrop:SetFrameLevel(frame.iconWell:GetFrameLevel() + 1)
  frame.previewBackdrop:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2 })
  frame.previewBackdrop:SetBackdropColor(0.004, 0.006, 0.009, 1)
  frame.previewBackdrop:SetBackdropBorderColor(GOLD[1], GOLD[2], GOLD[3], GOLD[4])
  frame.previewBackdrop:Hide()
  frame.preview = CreateFrame("ModelScene", nil, frame.iconWell, "PanningModelSceneMixinTemplate")
  frame.preview:SetPoint("TOPLEFT", 4, -4)
  frame.preview:SetPoint("BOTTOMRIGHT", -4, 4)
  frame.preview:SetFrameLevel(frame.iconWell:GetFrameLevel() + 2)
  frame.preview:Hide()
  local controlsOK, previewControls = pcall(CreateFrame, "Frame", nil, frame.preview, "ModelSceneControlFrameTemplate")
  if controlsOK and previewControls then
    previewControls:SetPoint("BOTTOM", frame.preview, "BOTTOM", 0, 8)
    pcall(previewControls.SetModelScene, previewControls, frame.preview)
    previewControls:SetFrameLevel(frame.preview:GetFrameLevel() + 1)
    previewControls:Hide()
    frame.previewControls = previewControls
  end
  frame.previewFallback = frame.preview:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.previewFallback:SetPoint("CENTER")
  frame.previewFallback:SetJustifyH("CENTER")
  frame.previewFallback:SetWordWrap(true)
  frame.previewFallback:SetWidth(180)
  frame.previewFallback:Hide()
  frame.previewClose = NS.UI.Controls:CreateCloseButton(frame.iconWell, function() ClearPreview(frame) end, 24, 22)
  frame.previewClose:SetPoint("TOPRIGHT", -7, -7)
  frame.previewClose:SetFrameLevel(frame.preview:GetFrameLevel() + 2)
  frame.previewClose:Hide()
  frame.previewOverlay = CreateFrame("Frame", nil, frame.iconWell)
  frame.previewOverlay:SetAllPoints()
  frame.previewOverlay:SetFrameLevel(frame.preview:GetFrameLevel() + 2)
  frame.check:SetParent(frame.previewOverlay)
  frame.check:ClearAllPoints()
  frame.check:SetPoint("BOTTOMRIGHT", frame.previewOverlay, "BOTTOMRIGHT", -9, 9)
  frame.factionIcon:SetParent(frame.previewOverlay)
  frame.factionIcon:ClearAllPoints()
  frame.factionIcon:SetPoint("TOPRIGHT", frame.previewOverlay, "TOPRIGHT", -8, -8)
  frame.favorite:SetParent(frame.previewOverlay)
  frame.favorite:SetFrameLevel(frame.previewOverlay:GetFrameLevel() + 1)
  frame.favorite:ClearAllPoints()
  frame.favorite:SetPoint("TOPLEFT", frame.previewOverlay, "TOPLEFT", 7, -7)
  self.frame = frame
  self:Clear()
  return frame
end

function Inspector:Show(record)
  local frame = self:Create(NS.UI.CatalogView.frame)
  self.record = record
  if not record then
    self:Clear()
    return
  end
  frame.empty:Hide()
  frame.icon:Show()
  frame.title:Show()
  frame.category:Show()
  frame.state:Show()
  frame.sourceTitle:Show()
  frame.source:Show()
  frame.stateDivider:Show()
  frame.sourceDivider:Show()
  frame.location:Hide()
  frame.detailsTitle:Show()
  frame.details:Show()
  frame.note:Hide()
  frame.previewButton:Show()
  frame.list:Show()
  frame.track:Show()
  frame.map:Show()
  local title, icon, owned = NS.Systems.Housing:GetDisplay(record)
  frame.icon:SetTexture(icon)
  frame.check:SetShown(owned)
  local factionTexture = FactionTexture(record.faction)
  frame.factionIcon:SetTexture(factionTexture)
  frame.factionIcon:SetShown(factionTexture ~= nil)
  frame.title:SetText(title)
  frame.category:SetText(ContextText(record))
  local stateText = StateText(record, owned)
  frame.state:SetText(stateText)
  frame.sourceTitle:SetText(SourceHeading(record))
  local sourceText = SourceText(record)
  frame.source:SetText(sourceText)
  local requirementText = RequirementText(record)
  frame.requirements:SetText(requirementText)
  local detailText = DetailText(record)
  frame.details:SetText(detailText)
  local sourceCount, sourceLabel = NS.UI.ItemInteractions:GetSourceInfo(record)
  frame.sourcesButton:SetText(string.upper(sourceLabel) .. " (" .. tostring(sourceCount) .. ")")
  frame.sourcesButton:SetShown(sourceCount > 1)
  LayoutDetails(frame, detailText, stateText, sourceText, requirementText)
  frame.favorite:SetRecord(record)
  frame.track:SetText(NS.Systems.Tracker:IsTracked(record) and "Untrack" or "Track")
  frame.map:Show()
  frame.waypoint:SetText(NS.Systems.Navigation:IsActive(record) and "Clear Waypoint" or "Set Waypoint")
  frame.previewButton:SetShown(record.decorID ~= nil)
  frame.list:SetText("Links")
  frame.list:SetEnabled(NS.UI.ItemInteractions:BuildLinks(record) ~= nil)
  frame.map:SetEnabled(record.mapID ~= nil and record.mapX ~= nil and record.mapY ~= nil)
  local architect = NS.UI.Architect
  local roomID = architect and architect.panel and architect.panel.selectedRoomID
  local room = roomID and NS.Systems.Architect:GetRoom(roomID)
  local template = room and NS.Systems.Architect:GetTemplate(room.templateKey or room.name)
  frame.architect:SetEnabled(room ~= nil)
  frame.architect:SetText(template and ("Add to " .. template.name) or "Add to Architect Room")
  ClearPreview(frame)
  ShowPreview(frame, record)
  frame:Show()
end

function Inspector:Clear()
  self.record = nil
  local frame = self.frame
  if not frame then return end
  ClearPreview(frame)
  frame.empty:Show()
  frame.icon:Hide()
  frame.check:Hide()
  frame.factionIcon:Hide()
  frame.title:Hide()
  frame.category:Hide()
  frame.state:Hide()
  frame.sourceTitle:Hide()
  frame.source:Hide()
  frame.sourcesButton:Hide()
  frame.stateDivider:Hide()
  frame.sourceDivider:Hide()
  frame.location:Hide()
  frame.requirementsTitle:Hide()
  frame.requirements:Hide()
  frame.requirementAction:Hide()
  frame.requirementDivider:Hide()
  frame.detailsTitle:Hide()
  frame.details:Hide()
  frame.note:Hide()
  frame.favorite:SetRecord(nil)
  frame.track:Hide()
  frame.map:Hide()
  frame.waypoint:Hide()
  frame.previewButton:Hide()
  frame.list:Hide()
  frame.architect:Hide()
end
