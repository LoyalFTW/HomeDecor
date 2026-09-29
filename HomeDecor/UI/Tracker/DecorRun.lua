local _, NS = ...

local UI = {}
NS.UI.DecorRun = UI
local Run = NS.Systems.DecorRun

local function Text(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
  text:SetJustifyH("LEFT")
  NS.UI.Controls:TextColor(text, role or "text")
  return text
end

local function Hint(button, title, body)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(title)
    GameTooltip:AddLine(body, 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function UI:Create()
  if self.frame then return self.frame end
  local controls = NS.UI.Controls
  local frame = CreateFrame("Frame", "HomeDecorRun", UIParent, "BackdropTemplate")
  frame:SetSize(520, 620)
  frame:SetScale(math.min(1, (UIParent:GetHeight() - 32) / 620, (UIParent:GetWidth() - 32) / 520))
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetClampedToScreen(true)
  controls:Backdrop(frame, controls.colors.background)
  controls:MakeMovable(frame, frame, "decorRun")
  NS.Systems.Layout:Restore(frame, "decorRun")
  frame:Hide()
  local title = Text(frame, "GameFontNormalLarge", "accent")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("Plan a Decor Run")
  local close = controls:CreateCloseButton(frame, function() frame:Hide() end, 22, 22)
  close:SetPoint("TOPRIGHT", -10, -10)
  frame.source = Text(frame)
  frame.source:SetPoint("TOPLEFT", 16, -42)
  frame.source:SetPoint("RIGHT", -16, 0)
  frame.source:SetWordWrap(false)
  frame.zone = controls:CreateButton(frame, "Choose a zone", 310, 26)
  frame.zone:SetPoint("TOPLEFT", 16, -66)
  frame.zone:SetScript("OnClick", function(self)
    local options = {}
    for _, zone in ipairs(Run.zones or {}) do options[#options + 1] = { value = zone.mapID, label = zone.title .. " (" .. zone.stops .. " stops)" } end
    NS.UI.Dropdown:Show(self, options, Run.mapID, function(value)
      Run:SetZone(value)
      UI:Refresh(true)
    end)
  end)
  frame.reorder = controls:CreateButton(frame, "Reorder Stops", 166, 26)
  frame.reorder:SetPoint("LEFT", frame.zone, "RIGHT", 8, 0)
  frame.reorder:SetScript("OnClick", function()
    Run:Refresh()
    Run:Reorder()
    UI:Refresh(true)
  end)
  Hint(frame.reorder, "Reorder Stops", "Prioritize nearby vendors with more needed items. Your current stop stays selected during a run. Distances are estimates within this zone.")
  frame.summary = Text(frame, "GameFontHighlightSmall", "accent")
  frame.summary:SetPoint("TOPLEFT", 16, -104)
  frame.summary:SetPoint("RIGHT", -16, 0)
  frame.summary:SetHeight(30)
  local summaryHelp = CreateFrame("Frame", nil, frame)
  summaryHelp:SetPoint("TOPLEFT", 16, -104)
  summaryHelp:SetSize(484, 30)
  summaryHelp:EnableMouse(true)
  summaryHelp:SetScript("OnEnter", function(self)
    local costs, unknown = {}, 0
    for _, stop in ipairs(Run.route or {}) do
      if not stop.skipped then
        unknown = unknown + stop.unknownCosts
        for key, cost in pairs(stop.costs) do
          if not costs[key] then costs[key] = { currency = 0, currencyType = cost.currencyType, itemID = cost.itemID } end
          costs[key].currency = costs[key].currency + cost.currency
        end
      end
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Estimated cost for this zone")
    GameTooltip:AddLine(Run:CostText(costs) ~= "" and Run:CostText(costs) or "No known costs.", 0.82, 0.82, 0.82, true)
    local shortage = Run:BalanceText(costs)
    if shortage then GameTooltip:AddLine("Short by: " .. shortage, 1, 0.4, 0.4, true) end
    if unknown > 0 then GameTooltip:AddLine(unknown .. " item prices are unknown.", 1, 0.8, 0.3, true) end
    GameTooltip:AddLine("Locked and skipped items are excluded. Vendor discounts and stock may change the final total.", 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  summaryHelp:SetScript("OnLeave", function() GameTooltip:Hide() end)
  frame.notes = controls:CreateButton(frame, "", 484, 24)
  frame.notes:SetPoint("TOPLEFT", 16, -136)
  frame.notes:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Outside this run")
    for _, entry in ipairs(Run.excluded or {}) do
      if Run:Remaining(entry) > 0 then GameTooltip:AddLine(tostring(entry.record.title or entry.record.name or "Item") .. ": " .. entry.reason, 0.82, 0.82, 0.82, true) end
    end
    GameTooltip:AddLine("Other zones can be planned separately. Skipping a stop keeps its items on your list.", 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  frame.notes:SetScript("OnLeave", function() GameTooltip:Hide() end)
  local scroll = controls:CreateScrollFrame(frame)
  scroll:SetPoint("TOPLEFT", 16, -170)
  scroll:SetPoint("TOPRIGHT", -32, -170)
  scroll:SetHeight(168)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(462)
  controls:ConfigureScrollFrame(scroll, content, { step = 56 })
  frame.scroll, frame.content, frame.rows = scroll, content, {}
  frame.empty = Text(frame, "GameFontHighlightSmall", "muted")
  frame.empty:SetPoint("TOPLEFT", 26, -206)
  frame.empty:SetPoint("RIGHT", -40, 0)
  frame.empty:SetHeight(90)
  frame.detailTitle = Text(frame, "GameFontNormal", "accent")
  frame.detailTitle:SetPoint("TOPLEFT", 16, -350)
  frame.detailTitle:SetPoint("RIGHT", -16, 0)
  frame.detailTitle:SetWordWrap(false)
  frame.detailMeta = Text(frame)
  frame.detailMeta:SetPoint("TOPLEFT", 16, -376)
  frame.detailMeta:SetPoint("RIGHT", -16, 0)
  frame.detailMeta:SetHeight(52)
  local detailHelp = CreateFrame("Frame", nil, frame)
  detailHelp:SetPoint("TOPLEFT", 16, -376)
  detailHelp:SetSize(484, 52)
  detailHelp:EnableMouse(true)
  detailHelp:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Stop costs")
    GameTooltip:AddLine(frame.detailMeta:GetText(), 0.82, 0.82, 0.82, true)
    GameTooltip:AddLine("Click an item below for details. Hover over it to check its requirements.", 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  detailHelp:SetScript("OnLeave", function() GameTooltip:Hide() end)
  local details = controls:CreateScrollFrame(frame)
  details:SetPoint("TOPLEFT", 16, -434)
  details:SetPoint("BOTTOMRIGHT", -32, 64)
  local detailContent = CreateFrame("Frame", nil, details)
  detailContent:SetWidth(462)
  controls:ConfigureScrollFrame(details, detailContent, { step = 42 })
  frame.details, frame.detailContent, frame.items = details, detailContent, {}
  frame.go = controls:CreateButton(frame, "Start Run", 154, 28)
  frame.go:SetPoint("BOTTOMLEFT", 16, 24)
  frame.go:SetScript("OnClick", function()
    if not Run.running then
      Run:Start()
    elseif Run.selected and Run.selected ~= Run.current then
      Run:Resume(Run.selected)
    else
      Run:Navigate()
    end
    UI:Refresh(true)
  end)
  frame.skip = controls:CreateButton(frame, "Skip Current", 154, 28)
  frame.skip:SetPoint("LEFT", frame.go, "RIGHT", 10, 0)
  frame.skip:SetScript("OnClick", function() Run:Skip() UI:Refresh(true) end)
  Hint(frame.skip, "Skip Stop", "Move to the next useful stop. No items are removed. Select a skipped stop and choose Resume Stop to return to it.")
  frame.finish = controls:CreateButton(frame, "Close", 154, 28)
  frame.finish:SetPoint("LEFT", frame.skip, "RIGHT", 10, 0)
  frame.finish:SetScript("OnClick", function()
    if Run.running then Run:End() end
    frame:Hide()
  end)
  frame.footer = Text(frame, "GameFontHighlightSmall", "muted")
  frame.footer:SetPoint("BOTTOMLEFT", 16, 6)
  frame.footer:SetPoint("RIGHT", -16, 0)
  frame.footer:SetWordWrap(false)
  frame:SetScript("OnShow", function() UI:Refresh() end)
  frame:SetScript("OnHide", function() GameTooltip:Hide() NS.UI.Dropdown:Hide() end)
  self.frame = frame
  return frame
end

function UI:Refresh(reset)
  Run:Refresh()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local controls = NS.UI.Controls
  if reset then controls:ResetScrollFrame(frame.details, false) end
  frame.source:SetText((Run.tab == "lists" and "Shopping list: " or "Blueprint: ") .. tostring(Run.sourceName))
  local zoneTitle = "No vendor stops available"
  for _, zone in ipairs(Run.zones or {}) do if zone.mapID == Run.mapID then zoneTitle = zone.title break end end
  frame.zone:SetText(zoneTitle .. (#(Run.zones or {}) > 0 and "  v" or ""))
  frame.zone:SetEnabled(not Run.running and #(Run.zones or {}) > 0)
  frame.reorder:SetEnabled(#(Run.route or {}) > 1)
  local quantity, complete, blocked, skipped, useful, other = 0, 0, 0, 0, 0, 0
  for _, stop in ipairs(Run.route or {}) do
    quantity = quantity + stop.remaining
    blocked = blocked + stop.blocked
    if stop.remaining == 0 then complete = complete + 1 elseif stop.skipped then skipped = skipped + 1 elseif stop.ready > 0 then useful = useful + 1 end
  end
  for _, stop in ipairs(Run.stops or {}) do if stop.mapID ~= Run.mapID then other = other + stop.remaining end end
  for _, entry in ipairs(Run.excluded or {}) do other = other + Run:Remaining(entry) end
  local summary = tostring(quantity) .. " copies remaining / " .. tostring(#(Run.route or {})) .. " vendor stops"
  if Run.running then summary = complete .. " stops completed / " .. summary end
  frame.summary:SetText(summary)
  frame.notes:SetText(other .. " copies elsewhere" .. (blocked > 0 and (" / " .. blocked .. " items locked") or "") .. (skipped > 0 and (" / " .. skipped .. " stops skipped") or "") .. "  (?)")
  for index, stop in ipairs(Run.route or {}) do
    local row = frame.rows[index]
    if not row then
      row = controls:CreateButton(frame.content, "", 460, 54)
      row.title = Text(row, "GameFontNormal")
      row.title:SetPoint("TOPLEFT", 10, -7)
      row.title:SetPoint("RIGHT", -10, 0)
      row.title:SetWordWrap(false)
      row.meta = Text(row, "GameFontHighlightSmall", "muted")
      row.meta:SetPoint("BOTTOMLEFT", 10, 8)
      row.meta:SetPoint("RIGHT", -10, 0)
      row.meta:SetWordWrap(false)
      row:SetScript("OnClick", function(self) Run.selected = self.stop controls:ResetScrollFrame(frame.details, false) UI:Refresh() end)
      controls:ForwardScrollWheel(row, frame.scroll)
      frame.rows[index] = row
    end
    row.stop = stop
    row:SetPoint("TOPLEFT", 0, -(index - 1) * 56)
    local status = stop.remaining == 0 and "Complete" or stop.skipped and "Skipped" or stop == Run.current and "Current stop" or stop.ready == 0 and "Locked" or ""
    row.title:SetText(index .. ". " .. tostring(stop.title) .. (status ~= "" and ("  -  " .. status) or ""))
    row.meta:SetText(stop.remaining .. " copies / " .. stop.ready .. " eligible items" .. (stop.blocked > 0 and (" / " .. stop.blocked .. " locked") or "") .. (stop.unverified > 0 and (" / " .. stop.unverified .. " to verify") or ""))
    controls:SetButtonSelected(row, stop == Run.selected)
    row:Show()
  end
  for index = #(Run.route or {}) + 1, #frame.rows do frame.rows[index]:Hide() end
  frame.content:SetHeight(math.max(1, #(Run.route or {}) * 56))
  controls:SetScrollOffset(frame.scroll, frame.scroll:GetVerticalScroll() or 0, false)
  if reset or frame.lastSelected ~= Run.selected then
    for index, stop in ipairs(Run.route or {}) do
      if stop == Run.selected then
        local top, offset = (index - 1) * 56, frame.scroll:GetVerticalScroll() or 0
        if top < offset then controls:SetScrollOffset(frame.scroll, top, false)
        elseif top + 56 > offset + frame.scroll:GetHeight() then controls:SetScrollOffset(frame.scroll, top + 56 - frame.scroll:GetHeight(), false) end
        break
      end
    end
    frame.lastSelected = Run.selected
  end
  frame.empty:SetShown(#(Run.route or {}) == 0)
  frame.empty:SetText(#(Run.entries or {}) == 0 and "Add items to a shopping list, or open a blueprint's missing items in Plans, then choose Plan Run." or "These items have no known vendor stops. Hover over 'copies elsewhere' for their sources.")
  local stop = Run.selected
  frame.detailTitle:SetText(stop and tostring(stop.title) or "Your next shopping trip")
  local meta = stop and Run:CostText(stop.costs) or "Choose a list with vendor items to begin."
  if stop then
    if meta == "" then meta = stop.remaining == 0 and "All requested copies acquired." or "No known costs for available items." end
    if stop.unknownCosts > 0 then meta = meta .. " / " .. stop.unknownCosts .. " prices unknown" end
    local shortage = Run:BalanceText(stop.costs)
    if shortage then meta = meta .. "\nShort by: " .. shortage end
  end
  frame.detailMeta:SetText(meta)
  local count = 0
  for _, entry in ipairs(stop and stop.entries or {}) do
    count = count + 1
    local row = frame.items[count]
    if not row then
      row = controls:CreateButton(frame.detailContent, "", 460, 40)
      row.title = Text(row)
      row.title:SetPoint("TOPLEFT", 8, -5)
      row.title:SetPoint("RIGHT", -8, 0)
      row.title:SetWordWrap(false)
      row.meta = Text(row, "GameFontHighlightSmall", "muted")
      row.meta:SetPoint("BOTTOMLEFT", 8, 5)
      row.meta:SetPoint("RIGHT", -8, 0)
      row.meta:SetWordWrap(false)
      row:SetScript("OnClick", function(self)
        NS.UI.CatalogView:Open("catalog")
        NS.UI.Inspector:Show(self.entry.record)
      end)
      row:SetScript("OnEnter", function(self) NS.UI.ItemTooltip:Show(self, self.entry.record, "tracker") end)
      row:SetScript("OnLeave", function() NS.UI.ItemTooltip:Hide() end)
      controls:ForwardScrollWheel(row, frame.details)
      frame.items[count] = row
    end
    row.entry = entry
    row:SetPoint("TOPLEFT", 0, -(count - 1) * 42)
    row.title:SetText((entry.remaining == 0 and "Done: " or (entry.remaining .. "x ")) .. tostring(entry.record.title or entry.record.name or "Decor"))
    row.meta:SetText(entry.reason ~= "" and ("Locked: " .. entry.reason) or entry.unknown and "Check requirements before buying" or NS.Systems.Cost:Format(entry.record) and ("Each: " .. NS.Systems.Cost:Format(entry.record)) or "Price unknown")
    row:Show()
  end
  for index = count + 1, #frame.items do frame.items[index]:Hide() end
  frame.detailContent:SetHeight(math.max(1, count * 42))
  controls:SetScrollOffset(frame.details, frame.details:GetVerticalScroll() or 0, false)
  local canResume = Run.running and stop and stop ~= Run.current and stop.ready > 0 and stop.remaining > 0
  frame.go:SetText(not Run.running and "Start Run" or canResume and (stop.skipped and "Resume Stop" or "Go to This Stop") or "Set Waypoint")
  frame.go:SetEnabled(not Run.sourceMissing and (not Run.running and useful > 0 or Run.running and (canResume or Run.current ~= nil)))
  frame.skip:SetEnabled(Run.running and Run.current ~= nil)
  frame.finish:SetText(Run.running and "End Run" or "Close")
  frame.footer:SetText(Run.sourceMissing and "Source removed or renamed. Open Plan Run again to choose a list." or Run.navigationError or Run.running and quantity == 0 and "Run complete! All requested copies acquired." or Run.running and not Run.current and "No available stops left. Review locked or skipped items." or Run.running and "Purchases update progress. Closing this window keeps the run active." or "Costs are estimates. Check vendor prices and requirements before buying.")
end

function UI:Open(tab)
  local frame = self:Create()
  if not Run.running then Run:OpenSource(tab) end
  NS.UI.Controls:ResetScrollFrame(frame.scroll, false)
  NS.UI.Controls:ResetScrollFrame(frame.details, false)
  frame:Show()
  self:Refresh()
end

local Refresh = NS.Debounce(0.3, function()
  if Run.running or UI.frame and UI.frame:IsShown() then UI:Refresh() end
end)

for _, event in ipairs({ "BAG_UPDATE_DELAYED", "PLAYER_MONEY", "CURRENCY_DISPLAY_UPDATE", "UPDATE_FACTION", "MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "QUEST_TURNED_IN", "ACHIEVEMENT_EARNED", "MERCHANT_CLOSED", "HOUSING_STORAGE_UPDATED", "HOUSING_STORAGE_ENTRY_UPDATED", "NEW_HOUSING_ITEM_ACQUIRED", "HOUSE_DECOR_ADDED_TO_CHEST" }) do NS.SafeRegisterEvent(UI, event, Refresh) end
for _, message in ipairs({ "HOMEDECOR_LISTS_UPDATED", "HOMEDECOR_SHOPPING_BUY_UPDATED", "HOMEDECOR_COLLECTION_UPDATED" }) do NS.OnMessage(message, Refresh) end
NS.Systems.BlueprintList:RegisterListener(UI, Refresh)
