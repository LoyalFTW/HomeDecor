local MAJOR = "LibMapSuite-1.0"
local LibMapSuite = LibStub(MAJOR)
if not LibMapSuite then return end
local private = LibMapSuite.private
if (private.modules.Menu or 0) >= 4 then return end
private.modules.Menu = 4
local Menu = private.Menu or {}
private.Menu = Menu

local HasModernMenuAPI = type(MenuUtil) == "table" and type(MenuUtil.CreateContextMenu) == "function"

local function Resolve(value, item)
    return type(value) == "function" and value(item) or value
end

local function Normalize(items)
    local result = {}
    for _, source in ipairs(items or {}) do
        if source == "-" or source == "---" then
            result[#result + 1] = { isSeparator = true }
        elseif type(source) == "string" then
            result[#result + 1] = { text = source, isTitle = true }
        elseif type(source) == "table" then
            local item = {}
            item.text = source.text or source.label or source.name or source[1] or ""
            item.isSeparator = source.isSeparator or source.separator
            item.isTitle = source.isTitle or source.title
            item.disabled = source.disabled
            item.icon = source.icon
            item.checked = source.checked or source.get
            if item.checked == nil and type(source.value) ~= "nil" then item.checked = source.value end
            item.checkable = source.checkable or source.type == "toggle" or item.checked ~= nil or source.set ~= nil
            item.submenu = source.submenu or source.options or source.children
            if item.submenu then item.submenu = Normalize(Resolve(item.submenu, source)) end
            local action = source.func or source.action or source.onClick or (type(source[2]) == "function" and source[2])
            item.func = function()
                local value = not not Resolve(item.checked, source)
                if source.set then source.set(not value, source)
                elseif source.toggle then source.toggle(not value, source)
                elseif action then action(not value, source) end
            end
            result[#result + 1] = item
        end
    end
    return result
end

local function SetEnabled(description, item)
    local disabled = Resolve(item.disabled, item)
    if disabled and description and description.SetEnabled then description:SetEnabled(false) end
end

local function Decorate(description, item)
    SetEnabled(description, item)
    if item.icon and description and description.SetIcon then description:SetIcon(item.icon) end
end

local function AddModernItems(description, items)
    for _, item in ipairs(items) do
        if item.isSeparator then
            description:CreateDivider()
        elseif item.isTitle and description.CreateTitle then
            description:CreateTitle(item.text)
        elseif item.checkable then
            local entry = description:CreateCheckbox(
                item.text,
                function() return not not Resolve(item.checked, item) end,
                item.func
            )
            Decorate(entry, item)
        elseif item.submenu then
            local sub = description:CreateButton(item.text)
            AddModernItems(sub, item.submenu)
            Decorate(sub, item)
        else
            local entry = description:CreateButton(item.text, item.func)
            Decorate(entry, item)
        end
    end
end

local function OpenModernMenu(anchorFrame, items)
    MenuUtil.CreateContextMenu(anchorFrame, function(ownerRegion, rootDescription)
        AddModernItems(rootDescription, items)
    end)
end

local legacyFrameName = "LibMapSuite10_LegacyDropDown"
local legacyFrame = Menu.legacyFrame

local function EnsureLegacyFrame()
    if legacyFrame then return legacyFrame end
    legacyFrame = CreateFrame("Frame", legacyFrameName, UIParent, "UIDropDownMenuTemplate")
    Menu.legacyFrame = legacyFrame
    return legacyFrame
end

local function OpenLegacyMenu(anchorFrame, items)
    local frame = EnsureLegacyFrame()

    local function Initialize(self, level)
        local levelItems = level == 1 and items or UIDROPDOWNMENU_MENU_VALUE
        if type(levelItems) ~= "table" then return end
        for _, item in ipairs(levelItems) do
            if item.isSeparator then
                local info = UIDropDownMenu_CreateInfo()
                info.isTitle = true
                info.notCheckable = true
                UIDropDownMenu_AddButton(info)
            else
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.text
                info.icon = item.icon
                info.isTitle = item.isTitle
                info.notCheckable = not item.checkable
                if item.checkable then
                    info.checked = not not Resolve(item.checked, item)
                end
                info.func = item.func
                info.hasArrow = item.submenu ~= nil
                if item.submenu then
                    info.value = item.submenu
                end
                info.disabled = Resolve(item.disabled, item)
                info.keepShownOnClick = item.checkable and true or nil
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end

    UIDropDownMenu_Initialize(frame, Initialize, "MENU")
    ToggleDropDownMenu(1, nil, frame, anchorFrame, 0, 0)
end

function Menu:Open(anchorFrame, items)
    items = Normalize(type(items) == "function" and items(anchorFrame) or items)
    if #items == 0 then return end
    if HasModernMenuAPI then
        OpenModernMenu(anchorFrame, items)
    else
        OpenLegacyMenu(anchorFrame, items)
    end
end

function Menu:Attach(frame, itemsOrFn, mouseButton)
    frame.LibMapSuiteMenuSource = itemsOrFn
    frame.LibMapSuiteMenuButton = mouseButton or "RightButton"
    if frame.LibMapSuiteMenuAttached then return frame end
    frame.LibMapSuiteMenuAttached = true
    frame:HookScript("OnMouseUp", function(self, button)
        if button ~= self.LibMapSuiteMenuButton then return end
        Menu:Open(self, self.LibMapSuiteMenuSource)
    end)
    return frame
end

function LibMapSuite:OpenMenu(anchorFrame, options) return Menu:Open(anchorFrame, options) end
function LibMapSuite:AttachMenu(frame, options, mouseButton) return Menu:Attach(frame, options, mouseButton) end
