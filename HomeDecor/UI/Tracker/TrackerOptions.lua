local _, NS = ...

NS.UI = NS.UI or {}
local TrackerOptions = {}
NS.UI.TrackerOptions = TrackerOptions

function TrackerOptions:GetTransparency()
  local value = tonumber(NS.Systems.Settings:GetValue("trackerTransparency"))
  if value then return math.max(0, math.min(1, value)) end
  return NS.Systems.Settings:GetValue("trackerTransparent", false) == true and 1 or 0
end

function TrackerOptions:GetAlpha(value, transparentValue)
  local amount = self:GetTransparency()
  return value + ((transparentValue or 0) - value) * amount
end

function TrackerOptions:Create(frame, anchor, callbacks)
  callbacks = callbacks or {}
  local Controls = NS.UI.Controls
  local options = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  options:SetSize(214, 112)
  options:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
  options:SetFrameLevel(frame:GetFrameLevel() + 20)
  Controls:Backdrop(options, Controls.colors.background)
  local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", 10, -9)
  title:SetText("Tracker Options")
  local hideCompleted = Controls:CreateCheckButton(options, "Hide Completed")
  hideCompleted:SetPoint("TOPLEFT", 8, -25)
  hideCompleted:SetScript("OnClick", function(self)
    NS.Systems.Settings:SetValue("trackerHideCompleted", self:GetChecked() == true)
    if callbacks.onHideCompleted then callbacks.onHideCompleted(self:GetChecked() == true) end
  end)
  local transparencyLabel = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  transparencyLabel:SetPoint("TOPLEFT", 10, -56)
  transparencyLabel:SetText("Transparency")
  local transparencyValue = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  transparencyValue:SetPoint("TOPRIGHT", -10, -56)
  local transparency = Controls:CreateSlider(options, {
    height = 12,
    minimum = 0,
    maximum = 100,
    step = 1,
    onDisplay = function(_, value) transparencyValue:SetText(tostring(math.floor((tonumber(value) or 0) + 0.5)) .. "%") end,
    onChanged = function(_, value)
      value = math.floor((tonumber(value) or 0) + 0.5)
      NS.Systems.Settings:SetValue("trackerTransparency", value / 100)
      NS.Systems.Settings:SetValue("trackerTransparent", value > 0)
      if callbacks.onTransparency then callbacks.onTransparency(value / 100) end
    end,
  })
  transparency:SetPoint("TOPLEFT", 10, -76)
  transparency:SetPoint("TOPRIGHT", -10, -76)
  options:SetScript("OnShow", function()
    hideCompleted:SetChecked(NS.Systems.Settings:GetValue("trackerHideCompleted", false) == true)
    transparency:SetValueSilently(math.floor(TrackerOptions:GetTransparency() * 100 + 0.5))
  end)
  Controls:SetTransientAnchor(options, anchor)
  Controls:RegisterTransientPopup(options)
  options:Hide()
  anchor:SetScript("OnClick", function() Controls:ToggleFrame(options) end)
  options.hideCompleted = hideCompleted
  options.transparency = transparency
  return options
end

function TrackerOptions:Apply(frame, render)
  if not frame then return end
  local Controls = NS.UI.Controls
  local background = Controls.colors.background
  local panel = Controls.colors.panel
  local border = Controls.colors.border
  local chromeAlpha = 1 - self:GetTransparency()
  frame:SetBackdropColor(background[1], background[2], background[3], self:GetAlpha(background[4], 0))
  frame:SetBackdropBorderColor(border[1], border[2], border[3], self:GetAlpha(border[4] or 1, 0))
  frame.search:SetBackdropColor(panel[1], panel[2], panel[3], self:GetAlpha(panel[4], 0))
  frame.areaBar:SetBackdropColor(panel[1], panel[2], panel[3], self:GetAlpha(panel[4], 0))
  frame.titleText:SetAlpha(chromeAlpha)
  frame.count:SetAlpha(chromeAlpha)
  frame.closeButton:SetAlpha(math.max(0.25, chromeAlpha))
  frame.settingsButton:SetAlpha(math.max(0.35, chromeAlpha))
  frame.minimizeButton:SetAlpha(math.max(0.25, chromeAlpha))
  frame.search:SetAlpha(chromeAlpha)
  frame.areaBar:SetAlpha(chromeAlpha)
  frame.listBar:SetAlpha(chromeAlpha)
  frame.blueprintBar:SetAlpha(chromeAlpha)
  frame.resizeGrip:SetAlpha(chromeAlpha)
  for index = 1, #frame.tabs do frame.tabs[index]:SetAlpha(chromeAlpha) end
  local scrollBar = frame.scroll.ScrollBar or frame.scroll.scrollBar
  if scrollBar then scrollBar:SetAlpha(chromeAlpha) end
  if frame:IsShown() and render then render() end
end

return TrackerOptions
