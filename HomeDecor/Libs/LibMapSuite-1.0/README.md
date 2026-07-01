# LibMapSuite-1.0

One embeddable WoW map library for minimap appearance, minimap buttons,
world-coordinate math, minimap and world-map pins, and a cooperative world-map button rail.
It targets Retail and the supported Classic clients through capability checks in
`Compat.lua`.

The API is inspired by LibDBIcon, HereBeDragons, HereBeDragons-Pins, and
Krowi_WorldMapButtons, but it does **not** register under those libraries' names.
An addon must explicitly migrate to `LibMapSuite-1.0`; this avoids silently
changing another addon's behavior when both libraries are installed.

## LibStub and embedding

LibStub is intentionally used for version arbitration. Multiple addons may
embed LibMapSuite, and LibStub ensures they share the newest compatible
instance. A public-domain LibStub copy is bundled, so consumers do not need to
download or declare it separately.

Copy the complete library folder into `MyAddon/Libs/LibMapSuite-1.0`. For the
full suite, add one line to the embedding addon's `.toc`:

```text
Libs\LibMapSuite-1.0\LibMapSuite-1.0.xml
```

```lua
local Map = LibStub("LibMapSuite-1.0")
-- Optional mixin form: Map:Embed(MyAddon)
```

When shipped embedded, retain the complete folder, including `LibStub`. The
suite uses Blizzard textures only, so asset paths remain valid regardless of
which addon's `Libs` folder contains it.

## Load only the modules you need

Selective loading follows HereBeDragons' simple convention: list the Lua files
you need directly in your addon's `.toc`. Every setup begins with these three:

```text
Libs\LibMapSuite-1.0\LibStub\LibStub.lua
Libs\LibMapSuite-1.0\Core.lua
Libs\LibMapSuite-1.0\Compat.lua
```

Then append only the requested feature files, in this order:

| Feature | Additional Lua files |
|---|---|
| Minimap shape, size, overlays | `Minimap.lua` |
| Minimap launcher buttons | `Menu.lua`, `MinimapButton.lua` |
| Map coordinates and distances | `MapData.lua` |
| Minimap pins | `MapData.lua`, `MinimapPins.lua` |
| World-map pins | `MapData.lua`, `WorldMapPins.lua` |
| World-map button rail | `Menu.lua`, `WorldMapButtons.lua` |
| Automatic LDB bridge | `Menu.lua`, `MinimapButton.lua`, `LDBBridge.lua` |

For example, coordinates and world-map pins require only:

```text
Libs\LibMapSuite-1.0\LibStub\LibStub.lua
Libs\LibMapSuite-1.0\Core.lua
Libs\LibMapSuite-1.0\Compat.lua
Libs\LibMapSuite-1.0\MapData.lua
Libs\LibMapSuite-1.0\WorldMapPins.lua
```

The cooperative world-map rail requires only Core, Compat, Menu, and
`WorldMapButtons.lua`.

Each module has its own internal revision guard, so embedding addons cannot
initialize duplicate event watchers or hooks when their selected modules overlap.

## Minimap appearance

```lua
Map:SetMinimapShape("SQUARE")       -- ROUND or SQUARE
Map:SetMinimapSize(180, 180)
local width, height = Map:GetMinimapSize()

Map:AddMinimapOverlay(myFrame, "ABOVE", true) -- BELOW, ABOVE, BORDER
Map:RemoveMinimapOverlay(myFrame)
Map:RestoreMinimap() -- restore Blizzard's original mask, border and size
```

Shape/size are global UI choices. A feature addon should normally expose them as
user settings instead of forcing them during load.

## Minimap buttons (LibDBIcon-style replacement)

```lua
MyAddonDB.minimap = MyAddonDB.minimap or {}
local button = Map:RegisterMinimapButton("MyAddon", {
    icon = "Interface\\Icons\\INV_Misc_Map_01",
    text = "My Addon",
    OnClick = function(self, mouseButton) MyAddon:Toggle() end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("My Addon")
        tooltip:AddLine("Click to open", 1, 1, 1)
    end,
    options = {
        { "Open Options", function() MyAddon:OpenOptions() end },
        "---",
        {
            label = "Show Pins",
            get = function() return MyAddonDB.showPins end,
            set = function(enabled) MyAddonDB.showPins = enabled end,
        },
        {
            label = "Pin Size",
            options = {
                { "Small", function() MyAddon:SetPinSize(16) end },
                { "Large", function() MyAddon:SetPinSize(24) end },
            },
        },
    },
}, MyAddonDB.minimap)

Map:SetMinimapButtonIcon("MyAddon", newTexture)
Map:SetMinimapButtonIconSize("MyAddon", 18)
Map:SetMinimapButtonPosition("MyAddon", 225)
Map:SetMinimapButtonLocked("MyAddon", true)
Map:SetMinimapButtonSize("MyAddon", 32)
Map:HideMinimapButton("MyAddon")
Map:ShowMinimapButton("MyAddon")
Map:UnregisterMinimapButton("MyAddon")
```

Retail's addon compartment is supported with
`AddMinimapButtonToCompartment` and `RemoveMinimapButtonFromCompartment`.

The caller-owned database uses `minimapPos`, `hide`, and `locked`. Buttons avoid
collisions and overflow into a drawer after the configured ring threshold.

`options` and `menu` are interchangeable. The compact `{ "Label", callback }`
form handles ordinary actions, `"---"` adds a divider, and nested `options`
create submenus. A `get`/`set` pair creates a toggle automatically. Long-form
aliases include `text`/`label`, `func`/`action`/`onClick`,
`submenu`/`options`/`children`, `disabled`, `icon`, and `isTitle`. Menus can be
attached to any frame with `Map:AttachMenu(frame, options)` or opened directly
with `Map:OpenMenu(frame, options)`.

LDB discovery is intentionally opt-in because a library should not create UI for
every data object merely by loading:

```lua
Map:EnableLDBBridge(MyAddonDB.libMapSuiteLDB) -- saved table is optional
```

## Coordinates (HereBeDragons-style replacement)

```lua
local x, y, mapID = Map:GetPlayerMapPosition()
local worldX, worldY, instanceID = Map:MapToWorld(mapID, x, y)
local zoneX, zoneY = Map:WorldToMap(instanceID, worldX, worldY, otherMapID)
local parentX, parentY = Map:TranslateMapCoordinates(x, y, mapID, parentMapID)
local yards = Map:GetMapDistance(mapID, x, y, otherMapID, otherX, otherY)
local angle, distance = Map:GetMapVector(mapID, x, y, otherMapID, otherX, otherY)
local zoneX, zoneY, zoneID, mapType = Map:GetPlayerZonePosition()
```

Migration aliases are provided for the common HBD method names:
`GetWorldCoordinatesFromZone`, `GetZoneCoordinatesFromWorldInstance`,
`TranslateZoneCoordinates`, `GetZoneDistance`, `GetWorldDistance`, and
`GetWorldVector`. Coordinates use Blizzard's live map assignments, so newly
added maps do not require a generated coordinate database. A conversion may
return nil for maps without a continuous world assignment or between different
instances.

## Minimap pins

Minimap POIs are separate from launcher buttons and update automatically while
the player moves, the minimap rotates, or its zoom and shape change:

```lua
local pin = Map:RegisterMinimapPin("MyAddon:vendor:42", {
    mapID = 2248, x = 0.52, y = 0.41,
    icon = "Interface\\Icons\\INV_Misc_Coin_01",
    size = 18,
    showOnEdge = true,
    OnTooltipShow = function(tooltip) tooltip:AddLine("Special Vendor") end,
    OnClick = function(pin, button, data) MyAddon:OpenVendor(data) end,
})

Map:SetMinimapPinPosition("MyAddon:vendor:42", mapID, x, y)
Map:HideMinimapPin("MyAddon:vendor:42")
Map:ShowMinimapPin("MyAddon:vendor:42")
Map:UnregisterMinimapPin("MyAddon:vendor:42")
```

Pins outside the visible area are hidden unless `showOnEdge = true`. Provider
collections use `RegisterMinimapPinProvider`, `AddMinimapPin`,
`RemoveMinimapPin`, and `RemoveMinimapPinProvider`.

## World-map pins

```lua
local pin = Map:RegisterWorldMapPin("MyAddon:vendor:42", {
    mapID = 2248,
    x = 0.52, y = 0.41,
    icon = "Interface\\Icons\\INV_Misc_Coin_01",
    size = 22,
    scaleWithZoom = true,
    OnTooltipShow = function(tooltip) tooltip:AddLine("Special Vendor") end,
    OnClick = function(pin, mouseButton, data) MyAddon:OpenVendor(data) end,
})

Map:SetWorldMapPinPosition("MyAddon:vendor:42", mapID, x, y)
Map:HideWorldMapPin("MyAddon:vendor:42")
Map:ShowWorldMapPin("MyAddon:vendor:42")
Map:UnregisterWorldMapPin("MyAddon:vendor:42")
```

Pins translate onto parent/continent maps when Blizzard exposes a continuous
assignment. For large collections, use provider-scoped keys:

```lua
Map:RegisterWorldMapPinProvider("MyAddon")
Map:AddWorldMapPin("MyAddon", vendorID, pinData)
Map:RemoveWorldMapPin("MyAddon", vendorID)
Map:RemoveWorldMapPinProvider("MyAddon")
```

## World-map button rail (Krowi-style replacement)

```lua
Map:RegisterWorldMapButton("MyAddon", {
    icon = "Interface\\Icons\\INV_Misc_Map_01",
    text = "Open My Addon",
    OnClick = function() MyAddon:ToggleMapPanel() end,
    OnRefresh = function(button, displayedMapID)
        button:SetEnabled(displayedMapID ~= nil)
    end,
})

Map:HideWorldMapButton("MyAddon")
Map:ShowWorldMapButton("MyAddon")
Map:UnregisterWorldMapButton("MyAddon")
```

If an addon already creates its frame, use
`Map:AddWorldMapButton("MyAddon", frame, options)`. The rail is vertical on
Retail and horizontal on Classic, follows map changes, supports caller-provided
frames/templates, and gives each button a no-op-safe `Refresh` contract.

LibMapSuite interoperates with an active `Krowi_WorldMapButtons` instance: new
buttons join Krowi's rail, while late-loaded or caller-owned frames reserve the
space already occupied by Krowi and Blizzard controls. Layout runs immediately
and once again on the next frame so on-demand map controls cannot cover a newly
registered button. The cooperative pass measures real frame sizes rather than
assuming every Krowi button is 32px, preventing larger buttons such as All The
Things from overlapping adjacent entries. Minimap shape changes similarly
refresh active LibDBIcon buttons instead of leaving them on the previous shape's perimeter.

## Public API rule

Everything an embedding addon needs is on the library object. `.private` is an
implementation detail and may change between minor versions. All registration
methods return their created frame, and every registration has a matching
unregister method so addons can cleanly disable modules at runtime.

## Current scope

The library now covers the practical replacement surface above. It does not yet
cluster overlapping pins.

License: MIT.
