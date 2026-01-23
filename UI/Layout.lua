local ADDON, NS = ...
local Dropdown = NS.UI and NS.UI.Dropdown
local L = {}
NS.UI.Layout = L

local C = NS.UI.Controls
local T = NS.UI.Theme.colors
local FiltersSys = NS.Systems and NS.Systems.Filters
local GlobalIndex = NS.Systems and NS.Systems.GlobalIndex

local function getDB()
  local db = NS.db and NS.db.profile
  if not db then return nil end

  db.ui = db.ui or {}
  db.ui.viewMode = db.ui.viewMode or "Icon"
  db.ui.activeCategory = db.ui.activeCategory or "Achievements"
  db.ui.expanded = db.ui.expanded or {}
  db.ui.search = db.ui.search or ""

  db.filters = db.filters or {}
  if FiltersSys and FiltersSys.EnsureDefaults then
    FiltersSys:EnsureDefaults(db)
  end

  db.favorites = db.favorites or {}
  return db
end

local _communityPopup

local function ShowCommunityPopup()
  if _communityPopup then
    _communityPopup:Show()
    return
  end

  local p = CreateFrame("Frame", "HomeDecorCommunityPopup", UIParent, "BackdropTemplate")
  _communityPopup = p

  tinsert(UISpecialFrames, "HomeDecorCommunityPopup")

  p:SetSize(560, 360)
  p:SetPoint("CENTER")
  p:SetFrameStrata("FULLSCREEN_DIALOG")
  p:SetFrameLevel(9999)
  p:SetToplevel(true)
  p:SetClampedToScreen(true)

  C:Backdrop(p, T.panel, T.border)

  p:EnableMouse(true)
  p:SetMovable(true)
  p:RegisterForDrag("LeftButton")
  p:SetScript("OnDragStart", p.StartMoving)
  p:SetScript("OnDragStop", p.StopMovingOrSizing)

  p:SetPropagateKeyboardInput(true)
  p:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
      self:Hide()
    end
  end)

  local header = CreateFrame("Frame", nil, p, "BackdropTemplate")
  C:Backdrop(header, T.header, T.border)
  header:SetPoint("TOPLEFT", 6, -6)
  header:SetPoint("TOPRIGHT", -6, -6)
  header:SetHeight(48)

  header.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  header.title:SetPoint("CENTER")
  header.title:SetText("Community")
  header.title:SetTextColor(unpack(T.accent))

  header.closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  C:Backdrop(header.closeBtn, T.panel, T.border)
  header.closeBtn:SetSize(26, 26)
  header.closeBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
  C:ApplyHover(header.closeBtn, T.panel, T.hover)

  header.closeBtn.icon = header.closeBtn:CreateTexture(nil, "OVERLAY")
  header.closeBtn.icon:SetSize(14, 14)
  header.closeBtn.icon:SetPoint("CENTER")
  header.closeBtn.icon:SetTexture("Interface\\Buttons\\UI-StopButton")
  header.closeBtn.icon:SetVertexColor(1, 0.82, 0.2, 1)

  header.closeBtn:SetScript("OnClick", function()
    p:Hide()
  end)

  local div = p:CreateTexture(nil, "ARTWORK")
  div:SetColorTexture(1, 1, 1, 0.12)
  div:SetHeight(1)
  div:SetPoint("TOPLEFT", 12, -60)
  div:SetPoint("TOPRIGHT", -12, -60)

  local links = {
    { "Join our Discord community", "https://discord.gg/f8njqW6Tgm" },
    { "Support development (BuyMeACoffee)", "https://buymeacoffee.com/azroaddons" },
    { "Donate via PayPal", "https://www.paypal.com/donate/?business=Jhookftw1@hotmail.com" },
    { "Share HomeDecor with friends", "https://legacy.curseforge.com/wow/addons/home-decor" },
  }

  local y = -78
  local gap = 60

  for i, info in ipairs(links) do
    local label = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 16, y - ((i - 1) * gap))
    label:SetText(info[1])
    label:SetTextColor(1, 1, 1, 0.95)

    local edit = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
    edit:SetAutoFocus(false)
    edit:SetHeight(30)
    edit:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -6, -6)
    edit:SetPoint("RIGHT", -16, 0)
    edit:SetTextInsets(12, 12, 0, 0)
    edit:SetFontObject("GameFontHighlight")
    edit:SetText(info[2])

    local function Highlight(self)
      self:SetFocus()
      self:HighlightText()
    end

    edit:SetScript("OnMouseUp", Highlight)
    edit:SetScript("OnEditFocusGained", Highlight)
    edit:SetScript("OnEscapePressed", function() p:Hide() end)
    edit:SetScript("OnEnterPressed", function() p:Hide() end)
  end

  p:Show()
end

function L:CreateShell()
  local db = getDB()
  if not db then return nil end
  local UI = db.ui
  local Filters = db.filters

  local f = CreateFrame("Frame","HomeDecorFrame",UIParent,"BackdropTemplate")
  C:Backdrop(f,T.bg,T.border)
  f:SetSize(1150,680)
  f:SetPoint("CENTER")

  local header = CreateFrame("Frame",nil,f,"BackdropTemplate")
  C:Backdrop(header,T.header,T.border)
  header:SetPoint("TOPLEFT",8,-8)
  header:SetPoint("TOPRIGHT",-8,-8)
  header:SetHeight(48)

  header.title = header:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  header.title:SetPoint("CENTER", 0, 0)
  header.title:SetText("HomeDecor")
  header.title:SetTextColor(unpack(T.accent))

  header.closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  C:Backdrop(header.closeBtn, T.panel, T.border)
  header.closeBtn:SetSize(26, 26)
  header.closeBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
  C:ApplyHover(header.closeBtn, T.panel, T.hover)

  header.closeBtn.icon = header.closeBtn:CreateTexture(nil, "OVERLAY")
  header.closeBtn.icon:SetSize(14, 14)
  header.closeBtn.icon:SetPoint("CENTER", 0, 0)
  header.closeBtn.icon:SetTexture("Interface\\Buttons\\UI-StopButton")
  header.closeBtn.icon:SetVertexColor(1, 0.82, 0.2, 1)

  header.closeBtn:SetScript("OnClick", function()
    if f and f.Hide then f:Hide() end
  end)

  header.viewToggle = C:Segmented(
    header, {"Icon","List"},
    function() return UI.viewMode end,
    function(v) UI.viewMode=v end
  )
  f.Header = header

  local left = CreateFrame("Frame",nil,f,"BackdropTemplate")
  C:Backdrop(left,T.panel,T.border)
  left:SetPoint("TOPLEFT",8,-64)
  left:SetPoint("BOTTOMLEFT",8,8)
  left:SetWidth(200)

  local cats={"Achievements","Quests","Vendors","Drops","Professions","PVP"}
  left.buttons={}
  local y=-12

  for _,cname in ipairs(cats) do
    local b=CreateFrame("Button",nil,left,"BackdropTemplate")
    C:Backdrop(b,T.panel,T.border)
    b:SetPoint("TOPLEFT",10,y)
    b:SetPoint("RIGHT",-10,y)
    b:SetHeight(28)

    b.text=b:CreateFontString(nil,"OVERLAY","GameFontNormal")
    b.text:SetPoint("CENTER")
    b._category = cname

    local collected, total = 0, 0
    if GlobalIndex and GlobalIndex.GetCounts then
      collected, total = GlobalIndex:GetCounts(cname)
    end

    if total > 0 then
      b.text:SetText(string.format("%s (%d / %d)", cname, collected, total))
    else
      b.text:SetText(cname)
    end

    C:ApplyHover(b, T.panel, T.hover)

    b:SetScript("OnClick", function()
      UI.activeCategory=cname
      if db and db.ui then db.ui.activeCategory = cname end

      UI.search = ""
      if db and db.ui then db.ui.search = "" end
      if f and f.SearchBox then
        f.SearchBox:SetText("")
        f.SearchBox:ClearFocus()
      end
      if f and f.SearchPlaceholder then
        f.SearchPlaceholder:Show()
      end

      for _,bb in ipairs(left.buttons) do
        C:SetSelected(bb, false, T.panel, T.row)
      end
      C:SetSelected(b, true, T.panel, T.row)

      if f.view and f.view.scrollFrame then
        f.view.scrollFrame:SetVerticalScroll(0)
      end
      if f.view and f.view.Render then
        f.view:Render()
      end
      if NS and NS.UI and NS.UI.HeaderController and NS.UI.HeaderController.Reset then
        NS.UI.HeaderController:Reset()
      end
    end)

    table.insert(left.buttons,b)
    y=y-32
  end

  for _,b in ipairs(left.buttons) do
    if b._category==UI.activeCategory then
      C:SetSelected(b, true, T.panel, T.row)
    end
  end

  local filtersTitle = left:CreateFontString(nil,"OVERLAY","GameFontNormal")
  filtersTitle:SetPoint("TOPLEFT",10,y-10)
  filtersTitle:SetText("Filters")
  filtersTitle:SetTextColor(unpack(T.accent))
  y = y - 24

  local filtersLine = left:CreateTexture(nil,"ARTWORK")
  filtersLine:SetColorTexture(1,1,1,0.15)
  filtersLine:SetHeight(1)
  filtersLine:SetPoint("TOPLEFT",10,y)
  filtersLine:SetPoint("TOPRIGHT",-10,y)
  y = y - 6

  local filterScroll = CreateFrame("ScrollFrame", nil, left, "ScrollFrameTemplate")
  filterScroll:SetPoint("TOPLEFT", 8, y)
  filterScroll:SetPoint("BOTTOMRIGHT", -28, 86)

  local filterContent = CreateFrame("Frame", nil, filterScroll)
  filterContent:SetPoint("TOPLEFT", 0, 0)
  filterScroll:SetScrollChild(filterContent)

  filterScroll:SetScript("OnSizeChanged", function(self, w)
    filterContent:SetWidth((w or 0) - 2)
  end)

  local function rerender()
    if f and f.view and f.view.Render then
      f.view:Render()
    end
  end

  if NS.UI and NS.UI.FilterPopup and NS.UI.FilterPopup.Build then
    NS.UI.FilterPopup:Build(filterContent, {
      C = C,
      T = T,
      Dropdown = Dropdown,
      Filters = Filters,
      FiltersSys = FiltersSys,
      UI = UI,
      db = db,
      rerender = rerender,
    })
  end

  local right=CreateFrame("Frame",nil,f,"BackdropTemplate")
  C:Backdrop(right,T.panel,T.border)
  right:SetPoint("TOPLEFT",left,"TOPRIGHT",8,0)
  right:SetPoint("BOTTOMRIGHT",-8,8)

  local bar=CreateFrame("Frame",nil,right,"BackdropTemplate")
  C:Backdrop(bar,T.panel,T.border)
  bar:SetPoint("TOPLEFT",8,-8)
  bar:SetPoint("TOPRIGHT",-8,-8)
  bar:SetHeight(36)

  local savedBtn = CreateFrame("Button", nil, bar, "BackdropTemplate")
  C:Backdrop(savedBtn, T.panel, T.border)
  savedBtn:SetPoint("LEFT", bar, "LEFT", 8, 0)
  savedBtn:SetSize(120, 24)

  savedBtn.icon = savedBtn:CreateTexture(nil, "OVERLAY")
  savedBtn.icon:SetSize(14, 14)
  savedBtn.icon:SetPoint("LEFT", savedBtn, "LEFT", 8, 0)
  if savedBtn.icon.SetAtlas then
    savedBtn.icon:SetAtlas("auctionhouse-icon-favorite", false)
    savedBtn.icon:SetSize(14, 14)
  else
    savedBtn.icon:SetTexture("Interface/Common/ReputationStar")
  end
  savedBtn.icon:SetVertexColor(1, 1, 1, 1)

  savedBtn.text = savedBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  savedBtn.text:SetPoint("LEFT", savedBtn.icon, "RIGHT", 6, 0)
  savedBtn.text:SetText("Saved Items")

  C:ApplyHover(savedBtn, T.panel, T.hover)

  local function SelectCategory(categoryName)
    UI.activeCategory = categoryName
    if db and db.ui then db.ui.activeCategory = categoryName end

    UI.search = ""
    if db and db.ui then db.ui.search = "" end
    if f and f.SearchBox then
      f.SearchBox:SetText("")
      f.SearchBox:ClearFocus()
    end
    if f and f.SearchPlaceholder then
      f.SearchPlaceholder:Show()
    end

    for _, bb in ipairs(left.buttons or {}) do
      C:SetSelected(bb, false, T.panel, T.row)
    end

    if f.view and f.view.scrollFrame then
      f.view.scrollFrame:SetVerticalScroll(0)
    end
    if f.view and f.view.Render then
      f.view:Render()
    end
    if NS and NS.UI and NS.UI.HeaderController and NS.UI.HeaderController.Reset then
      NS.UI.HeaderController:Reset()
    end
  end

  savedBtn:SetScript("OnClick", function()
    SelectCategory("Saved Items")
  end)

  do
    if header and header.viewToggle then
      header.viewToggle:SetParent(bar)
      header.viewToggle:ClearAllPoints()
      header.viewToggle:SetPoint("RIGHT", bar, "RIGHT", -8, 0)
    end
  end

  local search=CreateFrame("EditBox",nil,bar,"BackdropTemplate")
  C:Backdrop(search,T.panel,T.border)
  search:SetPoint("LEFT",savedBtn,"RIGHT",8,0)
  if header and header.viewToggle and header.viewToggle.GetLeft then
    search:SetPoint("RIGHT", header.viewToggle, "LEFT", -8, 0)
  else
    search:SetPoint("RIGHT", -8, 0)
  end
  search:SetHeight(24)
  search:SetAutoFocus(false)
  search:SetFontObject(GameFontHighlightSmall)
  search:SetTextInsets(8, 26, 0, 0)
  search:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)


  local placeholder=search:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
  placeholder:SetPoint("LEFT",search,"LEFT",8,0)
  placeholder:SetText("Search...")
  placeholder:SetTextColor(unpack(T.placeholder))

  f.SearchBox = search
  f.SearchPlaceholder = placeholder

	local clearBtn = CreateFrame("Button", nil, search, "BackdropTemplate")
	C:Backdrop(clearBtn, T.panel, T.border)
	clearBtn:SetSize(18, 18)
	clearBtn:SetPoint("RIGHT", search, "RIGHT", -6, 0)
	C:ApplyHover(clearBtn, T.panel, T.hover)

	clearBtn.icon = clearBtn:CreateTexture(nil, "OVERLAY")
	clearBtn.icon:SetSize(12, 12)
	clearBtn.icon:SetPoint("CENTER", 0, 0)
	clearBtn.icon:SetTexture("Interface\\Buttons\\UI-StopButton")
	clearBtn.icon:SetVertexColor(1, 0.82, 0.2, 0.95)

	clearBtn:Hide()
	search._clearBtn = clearBtn

	search:SetText(UI.search or "")
	if search._clearBtn then search._clearBtn:SetShown((search:GetText() or "") ~= "") end
	placeholder:SetShown(search:GetText()=="")


	clearBtn:SetScript("OnClick", function()
	search:SetText("")
	search:ClearFocus()
	UI.search = ""
	if db and db.ui then db.ui.search = "" end
	placeholder:Show()
	clearBtn:Hide()
	rerender()
end)

  search:SetScript("OnTextChanged",function(self)
  UI.search=(self:GetText() or "")
  if db and db.ui then db.ui.search = UI.search end

  local hasText = (UI.search ~= "")
  if self._clearBtn then
    self._clearBtn:SetShown(hasText)
  end

  placeholder:SetShown(self:GetText()=="" and not self:HasFocus())
  rerender()
end)
  search:SetScript("OnEditFocusGained",function(self)
    placeholder:Hide()
    if self._clearBtn then self._clearBtn:SetShown((self:GetText() or "") ~= "") end
  end)
  search:SetScript("OnEditFocusLost",function(self)
    placeholder:SetShown(self:GetText()=="")
    if self._clearBtn then self._clearBtn:SetShown((self:GetText() or "") ~= "") end
  end)

  f.Right=right
  f.TopBar=bar

  if NS.UI.ResizeBar then
    NS.UI.ResizeBar:Attach(f, header)
  end

  if NS.UI and NS.UI.ViewFactory and NS.UI.ViewFactory.Create then
    f.view = NS.UI.ViewFactory:Create(f, UI, db)
  end
  if f.view and f.view.OnShow then f.view:OnShow() end
  if f.view and f.view.Render then f.view:Render() end
  if NS.UI and NS.UI.HeaderController and NS.UI.HeaderController.Reset then
    NS.UI.HeaderController:Reset()
  end

  local divider = left:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(1, 1, 1, 0.15)
  divider:SetHeight(1)
  divider:SetPoint("BOTTOMLEFT", 12, 44)
  divider:SetPoint("BOTTOMRIGHT", -12, 44)

  local communityBtn = CreateFrame("Button",nil,left,"BackdropTemplate")
  C:Backdrop(communityBtn,T.header,T.border)
  communityBtn:SetPoint("BOTTOMLEFT",10,44+6)
  communityBtn:SetPoint("BOTTOMRIGHT",-10,44+6)
  communityBtn:SetHeight(26)

  communityBtn.icon = communityBtn:CreateTexture(nil,"OVERLAY")
  communityBtn.icon:SetSize(14,14)
  communityBtn.icon:SetPoint("LEFT",10,0)
  communityBtn.icon:SetTexture("Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon")

  communityBtn.text = communityBtn:CreateFontString(nil,"OVERLAY","GameFontNormal")
  communityBtn.text:SetPoint("LEFT",communityBtn.icon,"RIGHT",6,0)
  communityBtn.text:SetText("Community")
  communityBtn.text:SetTextColor(unpack(T.accent))

  C:ApplyHover(communityBtn, T.header, T.hover)

  communityBtn:SetScript("OnClick", function()
    ShowCommunityPopup()
  end)

  local whatsNewBtn = CreateFrame("Button", nil, left, "BackdropTemplate")
  C:Backdrop(whatsNewBtn, T.panel, T.border)
  whatsNewBtn:SetPoint("BOTTOMLEFT", 10, 10)
  whatsNewBtn:SetPoint("BOTTOMRIGHT", -10, 10)
  whatsNewBtn:SetHeight(26)

  whatsNewBtn.text = whatsNewBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  whatsNewBtn.text:SetPoint("CENTER")
  whatsNewBtn.text:SetText("What's New")
  
  C:ApplyHover(whatsNewBtn, T.header, T.hover)
  
  whatsNewBtn:SetScript("OnClick", function()
    if NS.UI and NS.UI.ShowChangelogPopup then
      NS.UI:ShowChangelogPopup(true)
    end
  end)

  return f
end

return L
