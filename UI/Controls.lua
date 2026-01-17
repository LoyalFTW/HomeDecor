local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.Util = NS.UI.Util or {}

local C = {}
NS.UI.Controls = C

local U = NS.UI.Util
local T = NS.UI.Theme and NS.UI.Theme.colors

if not U.Backdrop then
  function U.Backdrop(frame, controls, bg, border)
    if not frame then return end

    if controls and controls.Backdrop then
      controls:Backdrop(frame, bg, border)
      return
    end

    if not frame.SetBackdrop then return end

    frame:SetBackdrop({
      bgFile = "Interface/Buttons/WHITE8x8",
      edgeFile = "Interface/Buttons/WHITE8x8",
      edgeSize = 1,
    })

    if bg then frame:SetBackdropColor(unpack(bg)) end
    if border then frame:SetBackdropBorderColor(unpack(border)) end
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

function C:Backdrop(frame, bg, border)
  if not frame then return end

  local colors = T or {}
  U.Backdrop(frame, nil, bg or colors.panel, border or colors.border)
end

function C:ApplyHover(frame, normal, hover)
  if not frame or not frame.SetScript then return end

  frame:SetScript("OnEnter", function()
    if not frame._selected and frame.SetBackdropColor then
      frame:SetBackdropColor(unpack(hover))
    end
  end)

  frame:SetScript("OnLeave", function()
    if not frame._selected and frame.SetBackdropColor then
      frame:SetBackdropColor(unpack(normal))
    end
  end)
end

function C:SetSelected(frame, selected, normal, selectedBG)
  if not frame then return end

  frame._selected = selected
  if not frame.SetBackdropColor then return end

  if selected then
    frame:SetBackdropColor(unpack(selectedBG))
  else
    frame:SetBackdropColor(unpack(normal))
  end
end

function C:Segmented(parent, labels, get, set)
  local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  C:Backdrop(box, T.panel, T.border)
  box:SetHeight(26)

  local buttons = {}
  local x = 2

  for _, label in ipairs(labels or {}) do
    local b = CreateFrame("Button", nil, box, "BackdropTemplate")
    C:Backdrop(b, T.panel, T.border)
    b:SetSize(64, 22)
    b:SetPoint("LEFT", x, 0)

    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.text:SetPoint("CENTER")
    b.text:SetText(label)

    C:ApplyHover(b, T.panel, T.hover)

    b:SetScript("OnClick", function()
      if set then set(label) end
      box:Update()
      if HomeDecorFrame and HomeDecorFrame.view and HomeDecorFrame.view.Render then
        HomeDecorFrame.view:Render()
      end
    end)

    buttons[#buttons + 1] = b
    x = x + 66
  end

  box:SetWidth(x)

  function box:Update()
    local v = get and get()
    for _, b in ipairs(buttons) do
      C:SetSelected(b, (b.text and b.text:GetText() == v), T.panel, T.row)
    end
  end

  box:Update()
  return box
end

return C
