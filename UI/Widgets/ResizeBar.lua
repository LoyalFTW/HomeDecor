local ADDON, NS = ...

local ResizeBar = {}
NS.UI.ResizeBar = ResizeBar

local C = NS.UI.Controls
local T = NS.UI.Theme.colors

function ResizeBar:Attach(rootFrame, headerFrame)
    if not rootFrame or not headerFrame then return end
    if rootFrame._resizeWidget then return end

    local db = NS.db and NS.db.profile
    if not db then return end
    db.ui = db.ui or {}

    local BASE_W = 1150  
    local BASE_H = 680
    local MIN_W  = 820  
    local MAX_W  = 1600   
    local STEP   = 5

    local function scaleToWidth(scale)
        return MIN_W + (scale / 200) * (MAX_W - MIN_W)
    end

    local function widthToScale(width)
        return math.floor(((width - MIN_W) / (MAX_W - MIN_W)) * 200 + 0.5)
    end

    local startWidth = db.ui.width or BASE_W
    local startScale = widthToScale(startWidth)

    rootFrame:SetSize(
        startWidth,
        db.ui.height or math.floor(BASE_H * (startWidth / BASE_W))
    )

    local holder = CreateFrame("Frame", nil, headerFrame)
    holder:SetSize(250, 24)
    holder:SetPoint("LEFT", headerFrame, "LEFT", 12, 0)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", 0, 0)
    label:SetText("Scale")

    local sliderBG = CreateFrame("Frame", nil, holder, "BackdropTemplate")
    C:Backdrop(sliderBG, T.panel, T.border)
    sliderBG:SetPoint("LEFT", label, "RIGHT", 6, 0)
    sliderBG:SetSize(150, 24)

    local slider = CreateFrame("Slider", nil, sliderBG)
    slider:SetAllPoints(sliderBG)
    slider:SetMinMaxValues(0, 200)
    slider:SetValueStep(STEP)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("HORIZONTAL")
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:GetThumbTexture():Hide()

    local fill = sliderBG:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", 4, 0)
    fill:SetHeight(16)
    fill:SetColorTexture(unpack(T.accent))

    local valueBox = CreateFrame("Frame", nil, holder, "BackdropTemplate")
    C:Backdrop(valueBox, T.panel, T.border)
    valueBox:SetPoint("LEFT", sliderBG, "RIGHT", 6, 0)
    valueBox:SetSize(40, 24)

    local valueText = valueBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("CENTER")

    local function updateVisuals(scale)
        scale = math.max(0, math.min(200, scale))
        local pct = scale / 200

        fill:SetWidth((sliderBG:GetWidth() - 8) * pct)
        valueText:SetText(scale)
    end

    slider:SetValue(startScale)
    updateVisuals(startScale)

    slider:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / STEP) * STEP
        updateVisuals(v)
    end)

    slider:SetScript("OnMouseUp", function(self)
        local scale = math.floor(self:GetValue() / STEP) * STEP
        local width = math.floor(scaleToWidth(scale))
        local height = math.floor(BASE_H * (width / BASE_W))

        rootFrame:SetSize(width, height)

        db.ui.width  = width
        db.ui.height = height
    end)

    C:ApplyHover(sliderBG, T.panel, T.hover)
    C:ApplyHover(valueBox, T.panel, T.hover)

    holder:SetFrameLevel(headerFrame:GetFrameLevel() + 2)
    rootFrame._resizeWidget = holder
end

return ResizeBar
