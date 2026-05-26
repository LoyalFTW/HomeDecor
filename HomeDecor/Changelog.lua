HomeDecor_ChangelogMeta = {
  importance = "silent", -- Major / Silent
}

HomeDecor_Changelog = [[
#HomeDecor

May 26, 2026
* Added a new **Vendor Assistant** feature that appears when interacting with known decor vendors.
* Connected the Vendor Assistant to existing merchant open, update, page-change, and close events.
* Added direct integration with the existing **Saved Items** system, allowing vendor decor to be starred and unstarred from the vendor interface.
* Added purchase-cost support using live merchant gold and alternate-currency pricing.
* Added saved-item refresh support so starred vendor items update correctly in the tracker and main viewer.
* Reworked the feature into an attached drawer rather than a separate floating window.
* Made the vertical tab clickable so the vendor drawer smoothly opens and closes from the merchant window.
* Changed the drawer to start closed by default, showing only the compact vertical tab until opened.
* Added missing, saved, and total vendor decor counters.
* Added a shopping-total footer for the currently displayed items.
* Styled the drawer with a themed header, summary cards, divider lines, compact item cards, collection checkmarks, and favorite stars.
* Reduced the drawer size and made the interface more compact.
* Shrunk the summary boxes and tightened the item row layout so more decor fits in the panel.
* Added a cog-wheel options button to the drawer header.
* Added a `Compact item rows` option, enabled by default.
* Added a `Show prices` option that can hide item costs and the shopping-total footer.
* Made drawer settings persist between uses.
* Added supporting localization strings for the new drawer labels, empty states, options, and tooltips.
* Added saved configuration defaults for the Vendor Assistant.
* Registered the new Vendor Assistant module in the addon load order.
* Verified all modified Lua files parse successfully.
  
]]
