local ADDON, NS = ...
NS.UI = NS.UI or {}
NS.UI.Util = NS.UI.Util or {}
local U = NS.UI.Util

if not U.Backdrop then
  function U.Backdrop(frame, controls, bg, border)
    if not frame then return end
    if controls and controls.Backdrop then
      controls:Backdrop(frame, bg, border)
      return
    end
    frame:SetBackdrop({
      bgFile = "Interface/Buttons/WHITE8x8",
      edgeFile = "Interface/Buttons/WHITE8x8",
      edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(bg))
    frame:SetBackdropBorderColor(unpack(border))
  end
end

if not U.SetFont then
  function U.SetFont(fs, size)
    if fs then fs:SetFont(STANDARD_TEXT_FONT, size, "") end
  end
end

if not U.SafeBorder then
  function U.SafeBorder(frame, col)
    if frame and frame.SetBackdropBorderColor and col then
      frame:SetBackdropBorderColor(col[1], col[2], col[3], col[4] or 1)
    end
  end
end

if not U.BindBorderHover then
  function U.BindBorderHover(frame, accent, border)
    if not frame or not frame.SetScript or not frame.SetBackdropBorderColor then return end
    frame:SetScript("OnEnter", function() frame:SetBackdropBorderColor(unpack(accent)) end)
    frame:SetScript("OnLeave", function() frame:SetBackdropBorderColor(unpack(border)) end)
  end
end

local Dropdown = {}
NS.UI.Dropdown = Dropdown

local counter = 0
local OPEN = nil
local SCROLL_THRESHOLD = 14
local SEARCH_THRESHOLD = 20

local function IsShown(f) return f and f.IsShown and f:IsShown() end

local function CloseAny()
  if OPEN and OPEN.Close then OPEN:Close() end
end

local function SafeChildren(opt)
  if not opt or not opt.children then return nil end
  if type(opt.children) == "table" then return opt.children end
  if type(opt.children) == "function" then
    local ok, res = pcall(opt.children)
    if ok then return res end
  end
  return nil
end

function Dropdown.Create(parent, label, y, width, get, set, valuesFn, visibleFn, C, T)
  counter = counter + 1
  local dd = CreateFrame("Button", "HD_CustomDrop_"..counter, parent, "BackdropTemplate")

  dd:SetHeight(26)
  dd:SetClampedToScreen(true)
  dd:RegisterForClicks("LeftButtonUp")
  U.Backdrop(dd, C, T.panel, T.border)

  dd._get = get
  dd._set = set
  dd._valuesFn = valuesFn
  dd._visibleFn = visibleFn

  dd._label = label

  dd.text = dd:CreateFontString(nil,"OVERLAY","GameFontNormal")
  dd.text:SetPoint("LEFT",8,0)
  dd.text:SetPoint("RIGHT",-22,0)
  dd.text:SetJustifyH("LEFT")
  U.SetFont(dd.text, 12)
  dd.text:SetWordWrap(false)
  if dd.text.SetMaxLines then dd.text:SetMaxLines(1) end

  dd.arrow = dd:CreateTexture(nil,"OVERLAY")
  dd.arrow:SetSize(12,12)
  dd.arrow:SetPoint("RIGHT",-6,0)
  dd.arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")

  dd:SetScript("OnEnter", function() U.SafeBorder(dd, T.accent) end)
  dd:SetScript("OnLeave", function() U.SafeBorder(dd, T.border) end)

  dd._catcher = CreateFrame("Frame", nil, UIParent)
  dd._catcher:SetAllPoints(UIParent)
  dd._catcher:SetFrameStrata("FULLSCREEN_DIALOG")
  dd._catcher:SetFrameLevel(1)
  dd._catcher:EnableMouse(true)
  dd._catcher:Hide()
  dd._catcher:SetScript("OnMouseDown", function()
    if OPEN == dd then dd:Close() end
  end)

  dd.list = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  dd.list:SetFrameStrata("FULLSCREEN_DIALOG")
  dd.list:SetFrameLevel(100)
  dd.list:SetClampedToScreen(true)
  dd.list:Hide()
  U.Backdrop(dd.list, C, T.panel, T.border)

  dd.list.rowH, dd.list.pad = 24, 6

  dd.list.plain = CreateFrame("Frame", nil, dd.list)
  dd.list.plain:SetPoint("TOPLEFT", dd.list, "TOPLEFT", 0, 0)
  dd.list.plain:SetPoint("TOPRIGHT", dd.list, "TOPRIGHT", 0, 0)
  dd.list.plain:Show()

  dd.list.scroll = CreateFrame("ScrollFrame", nil, dd.list, "ScrollFrameTemplate")
  dd.list.scroll:SetPoint("TOPLEFT", 6, -6)
  dd.list.scroll:SetPoint("BOTTOMRIGHT", -26, 6)
  dd.list.scroll:Hide()

  dd.list.content = CreateFrame("Frame", nil, dd.list.scroll)

  dd.search = CreateFrame("EditBox", nil, dd.list, "BackdropTemplate")
  dd.search:SetAutoFocus(false)
  dd.search:SetHeight(22)
  dd.search:SetFont(STANDARD_TEXT_FONT, 12, "")
  dd.search:SetTextInsets(8,8,4,4)
  U.Backdrop(dd.search, nil, T.panel, T.border)
  dd.search:ClearAllPoints()
  dd.search:SetPoint("TOPLEFT", dd.list, "TOPLEFT", 6, -6)
  dd.search:SetPoint("TOPRIGHT", dd.list, "TOPRIGHT", -6, -6)
  dd.search:Hide()
  dd._hasSearch = false

  dd.list.content:SetPoint("TOPLEFT", 0, 0)
  dd.list.scroll:SetScrollChild(dd.list.content)

  local function LayoutListChrome()
    dd.list.scroll:ClearAllPoints()
    if dd._hasSearch then
      dd.list.scroll:SetPoint("TOPLEFT", 6, -(6 + 26))
      dd.list.scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    else
      dd.list.scroll:SetPoint("TOPLEFT", 6, -6)
      dd.list.scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    end
  end

  dd.list.buttons = {}

  dd.sub = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  dd.sub:SetFrameStrata("FULLSCREEN_DIALOG")
  dd.sub:SetFrameLevel(101)
  dd.sub:SetClampedToScreen(true)
  dd.sub:Hide()
  U.Backdrop(dd.sub, C, T.panel, T.border)
  dd.sub.rowH, dd.sub.pad = 24, 6
  dd.sub.buttons = {}

  local function PrefixLabel(txt)
    local lbl = dd._label
    if not lbl or lbl == "" then
      return txt or ""
    end
    lbl = tostring(lbl)
    if lbl:sub(-1) == ":" then
      return lbl .. " " .. (txt or "")
    end
    return lbl .. ": " .. (txt or "")
  end

  local function ResolveSelectedText(opts, v)
    local pickedList = nil

    if dd._get and opts then
      local list = {}
      for _,o in ipairs(opts) do
        if o and not o.separator and not o.children and o.checkable and o.value ~= nil then
          if dd._get(o.value) then
            list[#list+1] = o.text or tostring(o.value)
          end
        end
      end
      if #list > 0 then
        pickedList = table.concat(list, ", ")
      end
    end

    if pickedList and pickedList ~= "" then return pickedList end

    if v ~= nil and opts then
      for _,o in ipairs(opts) do
        if o and not o.separator and not o.children and not o.checkable and o.value == v then
          return o.text or tostring(o.value)
        end
      end
    end

    return nil
  end

  local function ApplyText(ph)
    local v = dd._get and dd._get()
    local opts = dd._valuesFn and dd._valuesFn() or {}
    local txt = ResolveSelectedText(opts, v)

    if txt and txt ~= "" then
      dd.text:SetText(PrefixLabel(txt))
    else
      dd.text:SetText(PrefixLabel(ph or ""))
    end
  end

  local function HideSub()
    dd.sub:Hide()
    dd.sub._parentOpt = nil
  end

  function dd:Close()
    dd.list:Hide()
    HideSub()
    dd._catcher:Hide()
    if OPEN == dd then OPEN = nil end
  end

  local function PositionMain()
    dd.list:ClearAllPoints()
    local left, bottom = dd:GetLeft(), dd:GetBottom()
    if left and bottom then
      dd.list:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, bottom - 4)
      dd.list:SetWidth(math.max(dd:GetWidth(), 180))
    end
  end

  local function PositionSub(anchorBtn)
    dd.sub:ClearAllPoints()
    local l, t = anchorBtn:GetLeft(), anchorBtn:GetTop()
    if l and t then
      dd.sub:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", l + dd.list:GetWidth() - 6, t)
      dd.sub:SetWidth(dd.list:GetWidth())
    end
  end

  local RefreshStates -- forward
  local UpdateMain    -- forward

  local function GetFilteredOptions(allOpts)
    local opts = allOpts or {}
    if not dd._hasSearch then
      return opts
    end

    local q = (dd.search and dd.search.GetText and dd.search:GetText()) or ""
    q = tostring(q):lower()
    if q == "" then
      return opts
    end

    local out = {}
    for _, opt in ipairs(opts) do
      if opt and (opt.separator or opt.title) then
        out[#out+1] = opt
      else
        local text = tostring(opt and opt.text or ""):lower()
        if text:find(q, 1, true) then
          out[#out+1] = opt
        end
      end
    end
    return out
  end

  local function EnsureButton(pool, i, parentFrame, isSub)
    local b = pool[i]
    if not b then
      b = CreateFrame("Button", nil, parentFrame)
      b:SetHeight(dd.list.rowH)

      b.hl = b:CreateTexture(nil,"BACKGROUND")
      b.hl:SetAllPoints()
      b.hl:SetColorTexture(unpack(T.accent))
      b.hl:SetAlpha(0.18)
      b.hl:Hide()

      b.sel = b:CreateTexture(nil,"ARTWORK")
      b.sel:SetPoint("LEFT",6,0)
      b.sel:SetSize(2, dd.list.rowH-6)
      b.sel:SetColorTexture(unpack(T.accent))
      b.sel:Hide()

      b.box = b:CreateTexture(nil,"OVERLAY")
      b.box:SetSize(14,14)
      b.box:SetPoint("LEFT",8,0)
      b.box:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
      b.box:Hide()

      b.check = b:CreateTexture(nil,"OVERLAY")
      b.check:SetSize(14,14)
      b.check:SetPoint("CENTER", b.box, "CENTER", 0, 0)
      b.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
      b.check:SetVertexColor(1, 1, 1, 1) -- white check
      b.check:Hide()

      b.arrow = b:CreateTexture(nil,"OVERLAY")
      b.arrow:SetSize(10,10)
      b.arrow:SetPoint("RIGHT",-6,0)
      b.arrow:SetTexture("Interface\\Buttons\\UI-MicroStream-Green")
      b.arrow:SetRotation(1.57) -- point right
      b.arrow:Hide()

      b.div = b:CreateTexture(nil,"ARTWORK")
      b.div:SetHeight(1)
      b.div:SetPoint("LEFT", 10, 0)
      b.div:SetPoint("RIGHT", -10, 0)
      b.div:SetColorTexture(1,1,1,0.15)
      b.div:Hide()

      b.text = b:CreateFontString(nil,"OVERLAY","GameFontNormal")
      b.text:SetPoint("LEFT",12,0)
      b.text:SetPoint("RIGHT",-18,0)
      U.SetFont(b.text, 12)
      b.text:SetWordWrap(false)
      if b.text.SetMaxLines then b.text:SetMaxLines(1) end

      b:SetScript("OnEnter", function()
        b.hl:Show()
        if b.children and not isSub then
          dd.sub._parentOpt = b.opt
          PositionSub(b)
          dd:_BuildSubmenu(b.opt)
          dd.sub:Show()
        end
      end)
      b:SetScript("OnLeave", function() b.hl:Hide() end)

      b:SetScript("OnClick", function()
        if b.separator or b.children then return end

        if b.checkable then
          if dd._set then dd._set(b.value, b.opt) end
          ApplyText()
          RefreshStates()
          if not b.keepOpen then dd:Close() end
          if parent and parent.Refresh then parent:Refresh() end
          return
        end

        if dd._set then dd._set(b.value, b.opt) end
        ApplyText()
        RefreshStates()
        if not b.keepOpen then dd:Close() end
        if parent and parent.Refresh then parent:Refresh() end
      end)

      pool[i] = b
    end

    if b:GetParent() ~= parentFrame then
      b:SetParent(parentFrame)
    end
    return b
  end

  local function LayoutButtons(pool, total, container, frame, useScroll)
    for i=1, total do
      local b = pool[i]
      b:ClearAllPoints()
      if useScroll then
        b:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -(i-1)*frame.rowH)
        b:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -(i-1)*frame.rowH)
      else
        local topPad = frame.pad + (dd._hasSearch and 26 or 0)
        b:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -(topPad + (i-1)*frame.rowH))
        b:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -(topPad + (i-1)*frame.rowH))
      end
    end
  end

  local function WantsCheckbox(opt)
    if not opt or opt.separator then return false end
    if opt.checkable then return true end
    if opt.children then return true end -- parent rows like "Faction"
    return false
  end

  UpdateMain = function()
    local allOpts = dd._valuesFn and dd._valuesFn() or {}

    dd._hasSearch = (#allOpts >= SEARCH_THRESHOLD)
    dd.search:SetShown(dd._hasSearch)
    LayoutListChrome()

    local opts = GetFilteredOptions(allOpts)

    local total = #opts
    local useScroll = total > SCROLL_THRESHOLD
    local container = useScroll and dd.list.content or dd.list.plain

    dd.list.scroll:SetShown(useScroll)
    dd.list.plain:SetShown(not useScroll)

    local visible = useScroll and SCROLL_THRESHOLD or total
    dd.list:SetHeight(dd.list.pad*2 + visible*dd.list.rowH + (dd._hasSearch and 28 or 0))

    if useScroll then
      dd.list.scroll:SetVerticalScroll(0)
      dd.list.content:SetWidth(dd.list:GetWidth() - 26)
      dd.list.content:SetHeight(total * dd.list.rowH)
    else
      dd.list.plain:SetHeight(dd.list.pad*2 + total*dd.list.rowH)
    end

    for i=1, total do
      local opt = opts[i] or {}
      local b = EnsureButton(dd.list.buttons, i, container, false)
      b.opt = opt
      b.value = opt.value
      b.separator = opt.separator
      b.checkable = opt.checkable
      b.keepOpen = opt.keepOpen
      b.children = opt.children

      b.text:SetText(opt.text or "")
      b.arrow:SetShown(opt.children and true or false)

      if opt.separator then
        b.text:SetText("")
        b.div:Show()
        b.box:Hide()
        b.check:Hide()
        b.sel:Hide()
        b.arrow:Hide()
      else
        b.div:Hide()
        b.text:SetTextColor(1,1,1,1)
        b.text:ClearAllPoints()
        if WantsCheckbox(opt) then
          b.box:Show()
          b.text:SetPoint("LEFT", 28, 0)
          b.text:SetPoint("RIGHT", -18, 0)
        else
          b.box:Hide()
          b.check:Hide()
          b.text:SetPoint("LEFT", 12, 0)
          b.text:SetPoint("RIGHT", -18, 0)
        end
      end

      b:Show()
    end

    for i=total+1, #dd.list.buttons do
      if dd.list.buttons[i] then dd.list.buttons[i]:Hide() end
    end

    LayoutButtons(dd.list.buttons, total, container, dd.list, useScroll)
  end

  function dd:_BuildSubmenu(parentOpt)
    local opts = SafeChildren(parentOpt) or {}
    local total = #opts

    dd.sub:SetHeight(dd.sub.pad*2 + math.min(total, SCROLL_THRESHOLD) * dd.sub.rowH)

    for i=1, total do
      local opt = opts[i] or {}
      local b = EnsureButton(dd.sub.buttons, i, dd.sub, true)
      b.opt = opt
      b.value = opt.value
      b.separator = opt.separator
      b.checkable = opt.checkable
      b.keepOpen = opt.keepOpen
      b.children = nil

      b.text:SetText(opt.text or "")
      b.arrow:Hide()

      if opt.separator then
        b.text:SetText("")
        b.box:Hide()
        b.check:Hide()
        b.sel:Hide()
      else
        b.text:SetTextColor(1,1,1,1)
        b.text:ClearAllPoints()
        if WantsCheckbox(opt) then
          b.box:Show()
          b.text:SetPoint("LEFT", 28, 0)
          b.text:SetPoint("RIGHT", -18, 0)
        else
          b.box:Hide()
          b.check:Hide()
          b.text:SetPoint("LEFT", 12, 0)
          b.text:SetPoint("RIGHT", -18, 0)
        end
      end

      b:Show()
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", dd.sub, "TOPLEFT", 0, -(dd.sub.pad + (i-1)*dd.sub.rowH))
      b:SetPoint("TOPRIGHT", dd.sub, "TOPRIGHT", 0, -(dd.sub.pad + (i-1)*dd.sub.rowH))
    end

    for i=total+1, #dd.sub.buttons do
      if dd.sub.buttons[i] then dd.sub.buttons[i]:Hide() end
    end

    RefreshStates()
  end

  local function AnyChildSelected(opt)
    local kids = SafeChildren(opt)
    if not kids or not dd._get then return false end
    for _,o in ipairs(kids) do
      if o and not o.separator and o.value ~= nil and dd._get(o.value) then
        return true
      end
    end
    return false
  end

  RefreshStates = function()
    local v = dd._get and dd._get()

    for _,b in ipairs(dd.list.buttons) do
      if b and b:IsShown() then
        if b.separator then
          b.sel:Hide()
          b.box:Hide()
          b.check:Hide()
        elseif b.children then
          b.sel:Hide()
          b.box:SetShown(true)
          b.check:SetShown(AnyChildSelected(b.opt))
        elseif b.checkable then
          local on = (dd._get and b.value ~= nil and dd._get(b.value)) and true or false
          b.sel:Hide()
          b.box:SetShown(true)
          b.check:SetShown(on)
        else
          b.sel:SetShown(b.value == v)
          b.box:Hide()
          b.check:Hide()
        end
      end
    end

    for _,b in ipairs(dd.sub.buttons) do
      if b and b:IsShown() then
        if b.separator then
          b.sel:Hide()
          b.box:Hide()
          b.check:Hide()
        elseif b.children then
          b.sel:Hide()
          b.box:SetShown(true)
          b.check:SetShown(AnyChildSelected(b.opt))
        elseif b.checkable then
          local on = (dd._get and b.value ~= nil and dd._get(b.value)) and true or false
          b.sel:Hide()
          b.box:SetShown(true)
          b.check:SetShown(on)
        else
          b.sel:SetShown(b.value == v)
          b.box:Hide()
          b.check:Hide()
        end
      end
    end
  end

  dd.search:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    UpdateMain()
    RefreshStates()
  end)

  dd.search:SetScript("OnTextChanged", function(self)
    if IsShown(dd.list) then
      UpdateMain()
      RefreshStates()
    end
  end)

  dd:SetScript("OnClick", function()
    if dd._visibleFn and not dd._visibleFn() then return end

    if OPEN and OPEN ~= dd then
      CloseAny()
    end

    if IsShown(dd.list) then
      dd:Close()
      return
    end

    if dd.search then dd.search:SetText("") end

    PositionMain()
    UpdateMain()
    HideSub()
    dd.list:Show()
    dd._catcher:Show()
    OPEN = dd
    RefreshStates()
    ApplyText()
  end)

  dd:HookScript("OnHide", function() dd:Close() end)
  dd:HookScript("OnSizeChanged", function()
    if IsShown(dd.list) then
      dd.list:SetWidth(dd:GetWidth())
      UpdateMain()
      RefreshStates()
      ApplyText()
    end
  end)

  ApplyText()
  return dd
end

return Dropdown
