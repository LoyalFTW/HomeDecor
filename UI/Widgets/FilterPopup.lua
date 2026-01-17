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

local function InsertAllSeparator(values)
  if type(values) ~= "table" then return values end
  if values.__hasAllSeparator then return values end

  local first = values[1]
  if first and first.value == "ALL" then
    table.insert(values, 2, { separator = true })
    values.__hasAllSeparator = true
  end
  return values
end

local M = {}
NS.UI.FilterPopup = M

function M:Build(popup, env)
  local C, T, Dropdown, Filters, FiltersSys =
    env.C, env.T, env.Dropdown, env.Filters, env.FiltersSys

  local HeaderCtrl = NS.UI and NS.UI.HeaderController
  local rerender = env.rerender

  popup._rows = {}

  local function GetProfile()
    local db = NS.db and NS.db.profile
    if db and FiltersSys and FiltersSys.EnsureDefaults then
      pcall(function() FiltersSys:EnsureDefaults(db) end)
    end
    return db
  end

  local function GetFilterTable()
    local db = GetProfile()
    if not db then return nil end
    db.filters = db.filters or {}
    return db.filters
  end

  local function Mirror(k, v)
    if type(Filters) == "table" then
      Filters[k] = v
    end
  end

  local function RebuildNow()
    if HeaderCtrl and HeaderCtrl.Reset then
      HeaderCtrl:Reset()
    end
    if rerender then
      rerender()
    end
  end

  local function SetDDText(dd, value)
    if not dd or not dd.text then return end
    local opts = dd._valuesFn and dd._valuesFn() or {}
    for _, o in ipairs(opts) do
      if o and not o.separator and o.value == value then
        dd.text:SetText(o.text or tostring(value))
        return
      end
    end
    dd.text:SetText(tostring(value or ""))
  end

  local function SyncAllDropdownTexts()
    for _, r in ipairs(popup._rows) do
      if r and not r.isButton and not r.isCheck and r.dd and r._get then
        local v = r._get()
        SetDDText(r.dd, v)
      end
    end
  end

  local function SyncAllCheckRows()
    for _, r in ipairs(popup._rows) do
      if r and r.isCheck and r.dd and r._get then
        if r.dd.text then
          r.dd.text:SetText(r.title and r.title.GetText and (r.title:GetText() or "") or "")
        end
        if r.dd.check and r.dd.check.SetShown then
          r.dd.check:SetShown(r._get() == true)
        end
      end
    end
  end

  local function HardResetAllFilters()
    local db = NS.db and NS.db.profile
    if not db then return end

    if FiltersSys and FiltersSys.EnsureDefaults then
      pcall(function() FiltersSys:EnsureDefaults(db) end)
    end

    db.filters = db.filters or {}
    db.filters.expansion = "ALL"
    db.filters.zone = "ALL"
    db.filters.category = "ALL"
    db.filters.subcategory = "ALL"
    db.filters.faction = "ALL"
    db.filters.hideCollected = false
    db.filters.onlyCollected = false

    if Filters then
      Filters.expansion = db.filters.expansion
      Filters.zone = db.filters.zone
      Filters.category = db.filters.category
      Filters.subcategory = db.filters.subcategory
    end

    SyncAllDropdownTexts()
    SyncAllCheckRows()
    RebuildNow()
  end

  local function Row(titleText, get, set, values)
    local row = {}

    row._get = get

    row.title = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.title:SetText(titleText)
    row.title:SetTextColor(unpack(T.accent))

    row.line = popup:CreateTexture(nil, "ARTWORK")
    row.line:SetHeight(2)
    row.line:SetColorTexture(unpack(T.accent))

    row.dd = Dropdown.Create(
      popup, nil, nil, 1,
      get,
      function(v)
        set(v)
        SetDDText(row.dd, get())
        RebuildNow()
      end,
      values,
      function() return true end,
      C, T
    )

    SetDDText(row.dd, get())
    popup._rows[#popup._rows + 1] = row
  end

  local function MakeButton(text, onClick)
    local b = CreateFrame("Button", nil, popup, "BackdropTemplate")
    b:SetHeight(24)

    U.Backdrop(b, C, T.panel, T.border)

    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("CENTER")
    b.text:SetText(text)
    b.text:SetTextColor(1, 1, 1, 1)

    U.BindBorderHover(b, T.accent, T.border)

    b:SetScript("OnClick", function()
      if onClick then onClick() end
    end)

    popup._rows[#popup._rows + 1] = { isButton = true, dd = b }
    return b
  end

  local function CheckRow(titleText, get, set)
    local row = { isCheck = true, _get = get }

    row.title = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.title:SetText(titleText)
    row.title:SetTextColor(unpack(T.accent))

    row.line = popup:CreateTexture(nil, "ARTWORK")
    row.line:SetHeight(2)
    row.line:SetColorTexture(unpack(T.accent))

    local b = CreateFrame("Button", nil, popup, "BackdropTemplate")
    b:SetHeight(24)
    U.Backdrop(b, C, T.panel, T.border)

    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", 10, 0)
    b.text:SetText(titleText)

    b.check = b:CreateTexture(nil, "OVERLAY")
    b.check:SetSize(14, 14)
    b.check:SetPoint("RIGHT", -10, 0)
    b.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")

    local function Sync()
      b.check:SetShown(get() == true)
    end

    U.BindBorderHover(b, T.accent, T.border)

    b:SetScript("OnClick", function()
      set(not get())
      Sync()
      RebuildNow()
    end)

    Sync()
    row.dd = b
    popup._rows[#popup._rows + 1] = row
  end

  CheckRow("Hide Completed",
    function()
      local f = GetFilterTable()
      return (f and f.hideCollected == true) or false
    end,
    function(v)
      local f = GetFilterTable()
      if f then
        f.hideCollected = (v == true)
      end
    end
  )

  Row("Faction",
    function()
      local f = GetFilterTable()
      return (f and f.faction) or "ALL"
    end,
    function(v)
      local f = GetFilterTable()
      if f then
        f.faction = v or "ALL"
      end
    end,
    function()
      return {
        { value = "ALL", text = "All Factions" },
        { value = "Alliance", text = "Alliance" },
        { value = "Horde", text = "Horde" },
      }
    end
  )

  Row("Expansion",
    function()
      local db = NS.db and NS.db.profile
      if not db then return "ALL" end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      local v = db.filters.expansion or "ALL"
      if Filters then Filters.expansion = v end
      return v
    end,
    function(v)
      local db = NS.db and NS.db.profile
      if not db then return end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      db.filters.expansion = v or "ALL"
      db.filters.zone = "ALL"
      if Filters then
        Filters.expansion = db.filters.expansion
        Filters.zone = db.filters.zone
      end
    end,
    function()
      local out = { { value = "ALL", text = "All Expansions" } }
      local seen = {}

      local vendors = NS.Data and NS.Data.Vendors
      if type(vendors) == "table" then
        for exp in pairs(vendors) do
          if not seen[exp] then
            seen[exp] = true
            out[#out + 1] = { value = exp, text = exp }
          end
        end
      end

      table.sort(out, function(a, b) return a.text < b.text end)
      return InsertAllSeparator(out)
    end
  )

  Row("Zone",
    function()
      local db = NS.db and NS.db.profile
      if not db then return "ALL" end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      local v = db.filters.zone or "ALL"
      if Filters then Filters.zone = v end
      return v
    end,
    function(v)
      local db = NS.db and NS.db.profile
      if not db then return end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      db.filters.zone = v or "ALL"
      if Filters then Filters.zone = db.filters.zone end
    end,
    function()
      local out = { { value = "ALL", text = "All Zones" } }
      local seen = {}

      local db = NS.db and NS.db.profile
      local exp = "ALL"
      if db then
        if FiltersSys and FiltersSys.EnsureDefaults then
          pcall(function() FiltersSys:EnsureDefaults(db) end)
        end
        db.filters = db.filters or {}
        exp = db.filters.expansion or "ALL"
      end

      local vendors = NS.Data and NS.Data.Vendors

      local function add(z)
        if type(z) == "string" and z ~= "" and not seen[z] then
          seen[z] = true
          out[#out + 1] = { value = z, text = z }
        end
      end

      local function scanExp(expTbl)
        for _, zoneTbl in pairs(expTbl or {}) do
          if type(zoneTbl) == "table" then
            for _, vendor in ipairs(zoneTbl) do
              if type(vendor) == "table" and vendor.source then
                add(vendor.source.zone)
              end
            end
          end
        end
      end

      if type(vendors) == "table" then
        if exp ~= "ALL" and type(vendors[exp]) == "table" then
          scanExp(vendors[exp])
        else
          for _, expTbl in pairs(vendors) do
            if type(expTbl) == "table" then
              scanExp(expTbl)
            end
          end
        end
      end

      table.sort(out, function(a, b) return a.text < b.text end)
      return InsertAllSeparator(out)
    end
  )

  Row("Category",
    function()
      local db = NS.db and NS.db.profile
      if not db then return "ALL" end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      local v = db.filters.category or "ALL"
      if Filters then Filters.category = v end
      return v
    end,
    function(v)
      local db = NS.db and NS.db.profile
      if not db then return end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      db.filters.category = v or "ALL"
      db.filters.subcategory = "ALL"
      if Filters then
        Filters.category = db.filters.category
        Filters.subcategory = db.filters.subcategory
      end
    end,
    function()
      return {
        { value = "ALL", text = "All Categories" },
        { separator = true },
        { value = "Accents", text = "Accents" },
        { value = "Functional", text = "Functional" },
        { value = "Furnishings", text = "Furnishings" },
        { value = "Lighting", text = "Lighting" },
        { value = "Miscellaneous", text = "Miscellaneous" },
        { value = "Nature", text = "Nature" },
        { value = "Structural", text = "Structural" },
        { value = "Uncategorized", text = "Uncategorized" },
      }
    end
  )

  Row("Subcategory",
    function()
      local db = NS.db and NS.db.profile
      if not db then return "ALL" end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      local v = db.filters.subcategory or "ALL"
      if Filters then Filters.subcategory = v end
      return v
    end,
    function(v)
      local db = NS.db and NS.db.profile
      if not db then return end
      if FiltersSys and FiltersSys.EnsureDefaults then
        pcall(function() FiltersSys:EnsureDefaults(db) end)
      end
      db.filters = db.filters or {}
      db.filters.subcategory = v or "ALL"
      if Filters then Filters.subcategory = db.filters.subcategory end
    end,
    function()
      return {
        { value = "ALL", text = "All Subcategories" },

        { separator = true },

        { value = "Floor", text = "Floor" },
        { value = "Food and Drink", text = "Food and Drink" },
        { value = "Misc Accents", text = "Misc Accents" },
        { value = "Ornamental", text = "Ornamental" },
        { value = "Wall Hangings", text = "Wall Hangings" },

        { value = "Misc Functional", text = "Misc Functional" },
        { value = "Utility", text = "Utility" },

        { value = "Beds", text = "Beds" },
        { value = "Misc Furnishings", text = "Misc Furnishings" },
        { value = "Seating", text = "Seating" },
        { value = "Storage", text = "Storage" },
        { value = "Tables and Desks", text = "Tables and Desks" },

        { value = "Ceiling Lights", text = "Ceiling Lights" },
        { value = "Large Lights", text = "Large Lights" },
        { value = "Misc Lighting", text = "Misc Lighting" },
        { value = "Small Lights", text = "Small Lights" },
        { value = "Wall Lights", text = "Wall Lights" },

        { value = "Miscellaneous - All", text = "Miscellaneous - All" },

        { value = "Bushes", text = "Bushes" },
        { value = "Ground Cover", text = "Ground Cover" },
        { value = "Large Foliage", text = "Large Foliage" },
        { value = "Misc Nature", text = "Misc Nature" },
        { value = "Small Foliage", text = "Small Foliage" },

        { value = "Doors", text = "Doors" },
        { value = "Large Structures", text = "Large Structures" },
        { value = "Misc Structural", text = "Misc Structural" },
        { value = "Walls and Columns", text = "Walls and Columns" },
        { value = "Windows", text = "Windows" },

        { value = "Uncategorized", text = "Uncategorized" },
      }
    end
  )

  MakeButton("Reset All Filters", HardResetAllFilters)

  function popup:Refresh()
    local y = -18
    local left, right = 6, 6

    for _, r in ipairs(popup._rows) do
      if r.isButton then
        r.dd:ClearAllPoints()
        r.dd:SetPoint("TOPLEFT", popup, "TOPLEFT", left, y)
        r.dd:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -right, y)
        r.dd:SetHeight(24)
        y = y - 34
      elseif r.isCheck then
        r.title:ClearAllPoints()
        r.title:SetPoint("TOPLEFT", left, y)
        y = y - 20

        r.line:ClearAllPoints()
        r.line:SetPoint("TOPLEFT", left, y)
        r.line:SetPoint("TOPRIGHT", -right, y)
        y = y - 10

        r.dd:ClearAllPoints()
        r.dd:SetPoint("TOPLEFT", popup, "TOPLEFT", left, y)
        r.dd:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -right, y)
        r.dd:SetHeight(24)
        y = y - 30
      else
        r.title:ClearAllPoints()
        r.title:SetPoint("TOPLEFT", left, y)
        y = y - 20

        r.line:ClearAllPoints()
        r.line:SetPoint("TOPLEFT", left, y)
        r.line:SetPoint("TOPRIGHT", -right, y)
        y = y - 10

        r.dd:ClearAllPoints()
        r.dd:SetPoint("TOPLEFT", popup, "TOPLEFT", left, y)
        r.dd:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -right, y)
        if r.dd.SetHeight then r.dd:SetHeight(26) end

        y = y - 30
      end
    end

    popup:SetHeight(-y + 12)
  end

  popup:Refresh()
end

return M
