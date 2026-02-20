local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}
local QueuePanel = {}
NS.UI.DecorAH_Queue = QueuePanel

local C = NS.UI.Controls
local Theme = NS.UI.Theme
local T = (Theme and Theme.colors) or {}
local X = (Theme and Theme.textures) or {}
local PriceSource = NS.Systems and NS.Systems.PriceSource

local Queue  = nil
local Export = nil
local function EnsureModules()
  if not Queue  then Queue  = NS.DecorAH and NS.DecorAH.Queue  end
  if not Export then Export = NS.DecorAH and NS.DecorAH.Export end
end

local queueFrame = nil
local queueRows = {}
local materialsText = nil
local totalProfitText = nil
local totalCostText = nil
local matScrollChild = nil

local function Backdrop(f, bg, border)
  if C and C.Backdrop then C:Backdrop(f, bg or T.panel, border or T.border) end
end

local function NewFS(parent, template)
  return parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
end

local function FormatMoney(copper)
  if not copper or copper == 0 then return "|cff888888-|r" end
  local gold   = math.floor(copper / 10000)
  local silver = math.floor((copper % 10000) / 100)
  local cop    = copper % 100
  local str = ""
  if gold > 0 then str = str .. "|cffffd700" .. gold .. "g|r " end
  if silver > 0 or gold > 0 then str = str .. "|cffc7c7cf" .. silver .. "s|r " end
  str = str .. "|cffeda55f" .. cop .. "c|r"
  return str
end

local function CreateStyledButton(parent, width, height, text, color)
  local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
  btn:SetSize(width, height)
  Backdrop(btn, T.panel, T.border)
  local btnText = NewFS(btn, "GameFontNormal")
  btnText:SetPoint("CENTER")
  btnText:SetText(text)
  btnText:SetTextColor(unpack(color or T.text))
  if C and C.ApplyHover then C:ApplyHover(btn, T.panel, T.hover) end
  return btn, btnText
end

function QueuePanel:Create(parent, width, height)
  if queueFrame then return queueFrame end

  width  = width  or 400
  height = height or 570

  queueFrame = CreateFrame("Frame", "HomeDecorQueueFrame", parent, "BackdropTemplate")
  queueFrame:SetSize(width, height)
  queueFrame:SetPoint("CENTER")
  queueFrame:SetFrameStrata("DIALOG")
  queueFrame:SetToplevel(true)
  queueFrame:SetClampedToScreen(true)
  Backdrop(queueFrame, T.bg, T.border)
  queueFrame:SetMovable(true)
  queueFrame:EnableMouse(true)
  queueFrame:RegisterForDrag("LeftButton")
  queueFrame:SetScript("OnDragStart", queueFrame.StartMoving)
  queueFrame:SetScript("OnDragStop",  queueFrame.StopMovingOrSizing)
  queueFrame:Hide()

  local header = CreateFrame("Frame", nil, queueFrame, "BackdropTemplate")
  header:SetPoint("TOPLEFT",  0, 0)
  header:SetPoint("TOPRIGHT", 0, 0)
  header:SetHeight(42)
  Backdrop(header, T.header, nil)

  local title = NewFS(header, "GameFontNormalLarge")
  title:SetPoint("LEFT", 16, 0)
  title:SetText(L["DECOR_AH_CRAFTING_QUEUE"])
  title:SetTextColor(unpack(T.accent))

  local countBadge = header:CreateTexture(nil, "BACKGROUND")
  countBadge:SetPoint("LEFT", title, "RIGHT", 8, 0)
  countBadge:SetSize(28, 18)
  countBadge:SetColorTexture(unpack(T.accentDark))

  queueFrame.queueCount = NewFS(header, "GameFontNormalSmall")
  queueFrame.queueCount:SetPoint("CENTER", countBadge, "CENTER", 0, 0)
  queueFrame.queueCount:SetText("0")
  queueFrame.queueCount:SetTextColor(unpack(T.accent))

  local clearBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  clearBtn:SetSize(60, 24)
  clearBtn:SetPoint("RIGHT", -48, 0)
  Backdrop(clearBtn, T.panel, T.border)
  local clearTxt = NewFS(clearBtn, "GameFontNormal")
  clearTxt:SetPoint("CENTER")
  clearTxt:SetText(L["DECOR_AH_CLEAR"])
  clearTxt:SetTextColor(unpack(T.danger))
  clearBtn:SetScript("OnClick", function()
    EnsureModules()
    if Queue then
      Queue.ClearQueue()
      if queueFrame then queueFrame._auctionatorSynced = nil end
      QueuePanel:Refresh()
    end
  end)

  local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  closeBtn:SetSize(24, 24)
  closeBtn:SetPoint("RIGHT", -12, 0)
  Backdrop(closeBtn, T.panel, T.border)
  local closeX = NewFS(closeBtn, "GameFontNormalLarge")
  closeX:SetPoint("CENTER", 0, 1)
  closeX:SetText("×")
  closeX:SetTextColor(unpack(T.textMuted))
  closeBtn:SetScript("OnClick", function() queueFrame:Hide() end)
  closeBtn:SetScript("OnEnter", function()
    closeX:SetTextColor(unpack(T.text))
    if C and C.Backdrop then C:Backdrop(closeBtn, T.hover, T.border) end
  end)
  closeBtn:SetScript("OnLeave", function()
    closeX:SetTextColor(unpack(T.textMuted))
    if C and C.Backdrop then C:Backdrop(closeBtn, T.panel, T.border) end
  end)

  local scrollFrame = CreateFrame("ScrollFrame", nil, queueFrame, "ScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT",     12, -54)
  scrollFrame:SetPoint("BOTTOMRIGHT", -28, 194)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end

  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetSize(1, 1)
  scrollFrame:SetScrollChild(scrollChild)

  scrollFrame:SetScript("OnSizeChanged", function(sf, w)
    scrollChild:SetWidth(w)
  end)

  queueFrame.scrollFrame  = scrollFrame
  queueFrame.scrollChild  = scrollChild

  local summaryPanel = CreateFrame("Frame", nil, queueFrame, "BackdropTemplate")
  summaryPanel:SetPoint("BOTTOMLEFT",  12, 12)
  summaryPanel:SetPoint("BOTTOMRIGHT", -12, 12)
  summaryPanel:SetHeight(170)
  Backdrop(summaryPanel, T.panel, T.border)

  local summaryHeader = CreateFrame("Frame", nil, summaryPanel, "BackdropTemplate")
  summaryHeader:SetPoint("TOPLEFT",  0, 0)
  summaryHeader:SetPoint("TOPRIGHT", 0, 0)
  summaryHeader:SetHeight(28)
  Backdrop(summaryHeader, T.header, nil)

  local summaryTitle = NewFS(summaryHeader, "GameFontNormal")
  summaryTitle:SetPoint("LEFT", 12, 0)
  summaryTitle:SetText(L["DECOR_AH_MATERIALS_SUMMARY"])
  summaryTitle:SetTextColor(unpack(T.accent))

  local statsRow = CreateFrame("Frame", nil, summaryPanel)
  statsRow:SetPoint("TOPLEFT",  8, -32)
  statsRow:SetPoint("TOPRIGHT", -8, -32)
  statsRow:SetHeight(18)

  local profitLabel = NewFS(statsRow, "GameFontNormalSmall")
  profitLabel:SetPoint("LEFT", 0, 0)
  profitLabel:SetText(L["DECOR_AH_PROFIT_COLON"])
  profitLabel:SetTextColor(unpack(T.textMuted))

  totalProfitText = NewFS(statsRow, "GameFontNormal")
  totalProfitText:SetPoint("LEFT", profitLabel, "RIGHT", 4, 0)
  totalProfitText:SetText("|cff888888-|r")

  local costLabel = NewFS(statsRow, "GameFontNormalSmall")
  costLabel:SetPoint("RIGHT", 0, 0)
  costLabel:SetText(L["DECOR_AH_COST_COLON"])
  costLabel:SetTextColor(unpack(T.textMuted))

  totalCostText = NewFS(statsRow, "GameFontNormal")
  totalCostText:SetPoint("RIGHT", costLabel, "LEFT", -4, 0)
  totalCostText:SetText("|cff888888-|r")

  local matScrollFrame = CreateFrame("ScrollFrame", nil, summaryPanel, "ScrollFrameTemplate")
  matScrollFrame:SetPoint("TOPLEFT",     8,  -54)
  matScrollFrame:SetPoint("BOTTOMRIGHT", -24, 36)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(matScrollFrame) end

  matScrollChild = CreateFrame("Frame", nil, matScrollFrame)
  matScrollChild:SetSize(1, 1)
  matScrollFrame:SetScrollChild(matScrollChild)

  matScrollFrame:SetScript("OnSizeChanged", function(sf, w)
    matScrollChild:SetWidth(w)
  end)

  materialsText = NewFS(matScrollChild, "GameFontNormalSmall")
  materialsText:SetPoint("TOPLEFT", 4, -4)
  materialsText:SetJustifyH("LEFT")
  materialsText:SetJustifyV("TOP")
  materialsText:SetTextColor(unpack(T.text))

  matScrollFrame:SetScript("OnShow", function(sf)
    local w = sf:GetWidth()
    if w and w > 4 then
      matScrollChild:SetWidth(w)
      materialsText:SetWidth(w - 8)
    end
  end)

  local exportBtn = CreateFrame("Button", nil, summaryPanel, "BackdropTemplate")
  exportBtn:SetSize(90, 24)
  exportBtn:SetPoint("BOTTOMRIGHT", -8, 6)
  Backdrop(exportBtn, T.panel, T.border)
  local exportTxt = NewFS(exportBtn, "GameFontNormal")
  exportTxt:SetPoint("CENTER")
  exportTxt:SetText(L["DECOR_AH_EXPORT_LIST"])
  exportTxt:SetTextColor(unpack(T.accent))
  exportBtn:SetScript("OnClick", function() QueuePanel:ShowExportPopup() end)
  if C and C.ApplyHover then C:ApplyHover(exportBtn, T.accentDark, T.accentSoft) end

  local auctBtn = CreateFrame("Button", nil, summaryPanel, "BackdropTemplate")
  auctBtn:SetSize(110, 24)
  auctBtn:SetPoint("BOTTOMRIGHT", exportBtn, "BOTTOMLEFT", -6, 0)
  Backdrop(auctBtn, T.panel, T.border)
  local auctTxt = NewFS(auctBtn, "GameFontNormal")
  auctTxt:SetPoint("CENTER")
  auctTxt:SetText(L["DECOR_AH_AUCTIONATOR"])
  auctTxt:SetTextColor(unpack(T.accent))
  auctBtn:SetScript("OnClick", function()
    EnsureModules()
    if not Export then
      return
    end
    local ok, msg = Export.ExportQueueToAuctionator()
    queueFrame._auctionatorSynced = nil
  end)
  if C and C.ApplyHover then C:ApplyHover(auctBtn, T.accentDark, T.accentSoft) end

  return queueFrame
end

function QueuePanel:Refresh()
  EnsureModules()
  if not queueFrame or not Queue then return end

  local queue      = Queue.GetQueue()
  local scrollChild = queueFrame.scrollChild
  local scrollFrame = queueFrame.scrollFrame

  if queueFrame.queueCount then
    queueFrame.queueCount:SetText(tostring(#queue))
  end

  for _, row in ipairs(queueRows) do
    row:Hide()
  end

  local sfWidth = scrollFrame:GetWidth()
  if sfWidth and sfWidth > 4 then
    scrollChild:SetWidth(sfWidth)
  end
  local rowWidth = scrollChild:GetWidth()

  local y          = 0
  local ROW_HEIGHT = 64

  for i, entry in ipairs(queue) do
    local row = queueRows[i]

    if not row then
      row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
      row:SetHeight(ROW_HEIGHT)
      Backdrop(row, T.row, T.border)

      row.iconBG = CreateFrame("Frame", nil, row, "BackdropTemplate")
      row.iconBG:SetSize(44, 44)
      row.iconBG:SetPoint("LEFT", 8, 0)
      Backdrop(row.iconBG, T.iconBG, T.border)

      row.icon = row.iconBG:CreateTexture(nil, "ARTWORK")
      row.icon:SetPoint("TOPLEFT",     3, -3)
      row.icon:SetPoint("BOTTOMRIGHT", -3, 3)
      row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

      row.name = NewFS(row, "GameFontNormal")
      row.name:SetPoint("TOPLEFT", 60, -10)
      row.name:SetPoint("TOPRIGHT", -108, -10)
      row.name:SetJustifyH("LEFT")
      row.name:SetTextColor(unpack(T.text))

      row.profit = NewFS(row, "GameFontNormalSmall")
      row.profit:SetPoint("BOTTOMLEFT", 60, 10)
      row.profit:SetJustifyH("LEFT")

      local countBG = CreateFrame("Frame", nil, row, "BackdropTemplate")
      countBG:SetSize(88, 24)
      countBG:SetPoint("TOPRIGHT", -8, -10)
      Backdrop(countBG, T.panel, T.border)

      row.decreaseBtn = CreateFrame("Button", nil, countBG, "BackdropTemplate")
      row.decreaseBtn:SetSize(24, 22)
      row.decreaseBtn:SetPoint("LEFT", 1, 0)
      Backdrop(row.decreaseBtn, T.panel, T.border)
      local dTxt = NewFS(row.decreaseBtn, "GameFontNormal")
      dTxt:SetPoint("CENTER", 0, 1)
      dTxt:SetText("−")
      dTxt:SetTextColor(unpack(T.textMuted))
      if C and C.ApplyHover then C:ApplyHover(row.decreaseBtn, T.panel, T.hover) end

      row.countText = NewFS(countBG, "GameFontNormal")
      row.countText:SetPoint("CENTER", 0, 0)
      row.countText:SetWidth(30)
      row.countText:SetJustifyH("CENTER")
      row.countText:SetTextColor(unpack(T.accent))

      row.increaseBtn = CreateFrame("Button", nil, countBG, "BackdropTemplate")
      row.increaseBtn:SetSize(24, 22)
      row.increaseBtn:SetPoint("RIGHT", -1, 0)
      Backdrop(row.increaseBtn, T.panel, T.border)
      local iTxt = NewFS(row.increaseBtn, "GameFontNormal")
      iTxt:SetPoint("CENTER", 0, 1)
      iTxt:SetText("+")
      iTxt:SetTextColor(unpack(T.textMuted))
      if C and C.ApplyHover then C:ApplyHover(row.increaseBtn, T.panel, T.hover) end

      row.removeBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
      row.removeBtn:SetSize(88, 20)
      row.removeBtn:SetPoint("TOP", countBG, "BOTTOM", 0, -2)
      Backdrop(row.removeBtn, T.panel, T.border)
      local rTxt = NewFS(row.removeBtn, "GameFontNormalSmall")
      rTxt:SetPoint("CENTER", 0, 0)
      rTxt:SetText(L["DECOR_AH_REMOVE"])
      rTxt:SetTextColor(unpack(T.danger))
      if C and C.ApplyHover then C:ApplyHover(row.removeBtn, T.panel, T.hover) end

      table.insert(queueRows, row)
    end

    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, y)
    row:SetWidth(rowWidth > 4 and rowWidth or 350)

    row.name:SetText(entry.name or L["DECOR_AH_UNKNOWN_ITEM"])
    row.countText:SetText(tostring(entry.count or 1))

    if entry.itemID then
      local _, _, _, _, icon = GetItemInfoInstant(entry.itemID)
      if icon then row.icon:SetTexture(icon) end
    end

    local profit = (entry.profit or 0) * (entry.count or 1)
    if profit > 0 then
      row.profit:SetText(L["DECOR_AH_PROFIT_PREFIX"] .. FormatMoney(profit))
      row.profit:SetTextColor(unpack(T.success))
    elseif profit < 0 then
      row.profit:SetText(L["DECOR_AH_LOSS_PREFIX"] .. FormatMoney(math.abs(profit)))
      row.profit:SetTextColor(unpack(T.danger))
    else
      row.profit:SetText(L["DECOR_AH_PROFIT_UNKNOWN"])
      row.profit:SetTextColor(unpack(T.textMuted))
    end

    row.decreaseBtn:SetScript("OnClick", function()
      EnsureModules()
      if Queue then
        Queue.UpdateCount(i, math.max(1, (entry.count or 1) - 1))
        queueFrame._auctionatorSynced = nil
        QueuePanel:Refresh()
      end
    end)

    row.increaseBtn:SetScript("OnClick", function()
      EnsureModules()
      if Queue then
        Queue.UpdateCount(i, (entry.count or 1) + 1)
        queueFrame._auctionatorSynced = nil
        QueuePanel:Refresh()
      end
    end)

    row.removeBtn:SetScript("OnClick", function()
      EnsureModules()
      if Queue then
        Queue.RemoveFromQueue(i)
        queueFrame._auctionatorSynced = nil
        QueuePanel:Refresh()
      end
    end)

    row:Show()
    y = y - ROW_HEIGHT - 4
  end

  scrollChild:SetHeight(math.max(1, math.abs(y)))
  QueuePanel:UpdateMaterialsSummary()
end

function QueuePanel:UpdateMaterialsSummary()
  EnsureModules()
  if not materialsText or not Queue then return end

  local materials = Queue.GetTotalMaterials()

  if totalProfitText and Queue.GetTotalProfit then
    local profit = Queue.GetTotalProfit()
    totalProfitText:SetText(FormatMoney(profit))
    if profit > 0 then
      totalProfitText:SetTextColor(unpack(T.success))
    elseif profit < 0 then
      totalProfitText:SetTextColor(unpack(T.danger))
    else
      totalProfitText:SetTextColor(unpack(T.textMuted))
    end
  end

  if totalCostText and Queue.GetTotalCost then
    totalCostText:SetText(FormatMoney(Queue.GetTotalCost()))
  end

  local matList = {}
  for itemID, count in pairs(materials) do
    local itemName = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID))
                  or GetItemInfo(itemID)
                  or ("Item #" .. itemID)
    table.insert(matList, { name = itemName, count = count, id = itemID })
  end
  table.sort(matList, function(a, b) return a.name < b.name end)

  if matScrollChild then
    local matFrameW = matScrollChild:GetParent() and matScrollChild:GetParent():GetWidth() or 0
    if matFrameW > 4 then
      matScrollChild:SetWidth(matFrameW)
      materialsText:SetWidth(matFrameW - 8)
    elseif matScrollChild:GetWidth() < 4 then
      local fallbackW = 320
      matScrollChild:SetWidth(fallbackW)
      materialsText:SetWidth(fallbackW - 8)
    end
  end

  if #matList == 0 then
    materialsText:SetText("|cff888888(empty queue)|r")
  else
    local lines = {}
    for _, mat in ipairs(matList) do
      table.insert(lines, mat.count .. "x " .. mat.name)
    end
    materialsText:SetText(table.concat(lines, "\n"))
  end

  local stringHeight = materialsText:GetStringHeight()
  if matScrollChild then
    matScrollChild:SetHeight(math.max(1, stringHeight + 10))
  end

  if Export and Export.ExportQueueToAuctionator and #matList > 0 then
    local ok, msg = Export.ExportQueueToAuctionator()
    if ok and not queueFrame._auctionatorSynced then
      queueFrame._auctionatorSynced = true
    end
  end
end

function QueuePanel:ShowExportPopup()
  EnsureModules()
  if not Queue then return end

  local materials = Queue.GetTotalMaterials()
  local textList

  if Export and Export.GenerateTextList then
    textList = Export.GenerateTextList(materials)
  end

  if not textList or textList == "" or textList == "Shopping List:\n\n" then
    local lines = { "Shopping List:", "" }
    for itemID, count in pairs(materials) do
      local name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID))
                   or ("Item #" .. itemID)
      table.insert(lines, count .. "x " .. name)
    end
    textList = table.concat(lines, "\n")
  end

  if textList == "" or textList == "Shopping List:\n\n" then
    return
  end

  local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  popup:SetSize(480, 500)
  popup:SetPoint("CENTER")
  popup:SetFrameStrata("FULLSCREEN")
  popup:SetFrameLevel(200)
  popup:EnableMouse(true)
  Backdrop(popup, T.bg, T.border)

  local hdr = CreateFrame("Frame", nil, popup, "BackdropTemplate")
  hdr:SetPoint("TOPLEFT",  0, 0)
  hdr:SetPoint("TOPRIGHT", 0, 0)
  hdr:SetHeight(42)
  Backdrop(hdr, T.header, nil)

  local hdrTitle = NewFS(hdr, "GameFontNormalLarge")
  hdrTitle:SetPoint("LEFT", 16, 0)
  hdrTitle:SetText(L["DECOR_AH_EXPORT_SHOPPING_LIST"])
  hdrTitle:SetTextColor(unpack(T.accent))

  local hdrClose = CreateFrame("Button", nil, hdr, "BackdropTemplate")
  hdrClose:SetSize(24, 24)
  hdrClose:SetPoint("RIGHT", -12, 0)
  Backdrop(hdrClose, T.panel, T.border)
  local hdrCloseX = NewFS(hdrClose, "GameFontNormalLarge")
  hdrCloseX:SetPoint("CENTER", 0, 1)
  hdrCloseX:SetText("×")
  hdrCloseX:SetTextColor(unpack(T.textMuted))
  hdrClose:SetScript("OnClick", function() popup:Hide() end)

  local sf = CreateFrame("ScrollFrame", nil, popup, "ScrollFrameTemplate")
  sf:SetPoint("TOPLEFT",     12, -54)
  sf:SetPoint("BOTTOMRIGHT", -28, 48)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(sf) end

  local eb = CreateFrame("EditBox", nil, sf)
  eb:SetMultiLine(true)
  eb:SetFontObject("ChatFontNormal")
  eb:SetWidth(sf:GetWidth() - 20)
  eb:SetAutoFocus(false)
  eb:SetText(textList)
  eb:SetTextColor(unpack(T.text))
  eb:HighlightText()
  eb:SetCursorPosition(0)
  sf:SetScrollChild(eb)

  local copyBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
  copyBtn:SetSize(100, 28)
  copyBtn:SetPoint("BOTTOM", 0, 12)
  Backdrop(copyBtn, T.panel, T.border)
  local copyTxt = NewFS(copyBtn, "GameFontNormal")
  copyTxt:SetPoint("CENTER")
  copyTxt:SetText(L["DECOR_AH_COPY_ALL"])
  copyTxt:SetTextColor(unpack(T.accent))
  copyBtn:SetScript("OnClick", function()
    eb:HighlightText()
    eb:SetFocus()
  end)

  popup:Show()
end

function QueuePanel:Toggle()
  if not queueFrame then self:Create(UIParent) end
  if queueFrame:IsShown() then
    queueFrame:Hide()
  else
    self:Refresh()
    queueFrame:Show()
    queueFrame:Raise()
  end
end

function QueuePanel:Show()
  if not queueFrame then self:Create(UIParent) end
  self:Refresh()
  queueFrame:Show()
  queueFrame:Raise()
end

function QueuePanel:Hide()
  if queueFrame then queueFrame:Hide() end
end

return QueuePanel