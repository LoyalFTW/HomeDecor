HomeDecor_ChangelogMeta = {
  importance = "silent", -- Major / Silent
}

HomeDecor_Changelog = [[
#HomeDecor

July 21, 2026
* Unified every scroll frame in the addon (Endeavors, Decor Viewer, sources, etc.) to use one shared, theme-reactive scrollbar so they all look and behave the same.
* Fixed scrollbars/thumbs not fully following your Accent Color or Design Preset in some tabs.
* Removed a leftover duplicate `Trackers` dropdown that used to appear in the header.
* Added a new `Statistics` page: overall collection percentage, a breakdown by source (Achievements, Quests, Vendors, Drops, Treasures, Shop, Professions, PvP), Endeavors season progress, and Decor AH crafting/sales stats at a glance.
* Added a house/neighborhood dropdown to the Statistics page's Endeavors card so you can switch which house's stats are shown.
* Fixed Endeavors and Statistics showing blank/zero values after a `/reload` in some cases.
* Fixed collection totals being inflated by double-counting Horde/Alliance versions of the same item, item counts are now accurate.
* Removed the small accent-colored selection bar next to the selected item in dropdown menus for a cleaner look.
* General cleanup: removed dead/unused code and consolidated repeated color, tooltip, and scrollbar logic behind shared helpers to reduce overall code size.


]]
