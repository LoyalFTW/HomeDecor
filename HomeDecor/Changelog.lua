HomeDecor_ChangelogMeta = {
  importance = "Major", -- Major / Silent
}

HomeDecor_Changelog = [[
#HomeDecor

June 11, 2026
* Made the Home Decor logo/header area feel less empty, with better placement for Classic/Compact/settings/close controls.
* Moved and adjusted scale controls so the top area feels cleaner.
* Added separate `Grid`, `List`, and `Text List` view buttons with clearer sizing and layout.
* Changed the top filter bar layout multiple times to reduce clutter and keep the important controls easier to reach.
* Kept `All / Missing / Owned` visible outside the advanced filters, since those are quick-view filters.
* Moved more detailed filters into the filter panel instead of crowding the top bar.
* Improved the filter panel organization with clearer separation and labels.
* Fixed filter dropdown issues where some top dropdowns were not applying correctly.
* Fixed a filter crash caused by scanning a string as a table in `Filters.lua`.
* Fixed missing localization issue for `ToDebugString`.
* Improved button hover behavior so buttons no longer turn into empty boxes.
* Improved button active/highlight behavior so clicks feel more responsive.
* Restored missing header buttons like `Compact` and gallery/design controls.
* Restored tracker access and moved tracker-related buttons into the left side navigation.
* Made the right details panel open by default.
* Made the details panel close when opening other windows like Events, Decor Pricing, Alts, and Endeavors.
* Improved the right details panel layout with better item preview, status buttons, source info, requirements, price, ownership, and dyeability.
* Linked details panel pricing into the existing pricing system.
* Added owned/not owned status display in the details panel.
* Added dyeable/not dyeable status display in the details panel.
* Fixed pricing/status button layout so long price text fits better.
* Improved material/resource pricing display in the details panel.
* Added quantity-aware Decor AH details so cost, sell, profit, and material quantities update when queue quantity changes.
* Changed queue money formatting to compact values like `47.6k g` instead of huge full coin strings.
* Improved Decor AH pricing screen spacing so the table uses more available width.
* Changed the Decor AH `Margin` column label to `%`.
* Adjusted Decor AH column widths for better readability.
* Reduced wasted space between the pricing table and selected item panel.
* Improved selected item panel sizing on the pricing screen.
* Fixed inconsistent counts between filters/side panels/compact mode in several places.
* Fixed saved/favorites views so sorting and filters are preserved better.
* Fixed `All / Groups` style filtering not working correctly in some category views.
* Fixed PvP compact mode showing a count but no visible item text.
* Added/updated faction emblem handling for Alliance and Horde items.
* Added city-based fallback so Orgrimmar items can show Horde and Stormwind items can show Alliance.
* Fixed Horde emblem missing on some Horde-only filtered items.
* Improved faction/source display for items that can come from both faction cities.
* Added better compact PvP list behavior.
* Worked on addon open/close performance to reduce freezing when toggling quickly.
* Improved resizing behavior so the UI keeps its layout more consistently while resizing.
* Added/moved resize grip placement so it is easier to use without blocking important content.
* Improved separators around the top navigation/events area.
* Improved left sidebar layout with better grouping for saved items, categories, trackers, pricing, and other tools.
  
]]
