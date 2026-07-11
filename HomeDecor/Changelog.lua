HomeDecor_ChangelogMeta = {
  importance = "silent", -- Major / Silent
}

HomeDecor_Changelog = [[
#HomeDecor

July 11, 2026

Fixed Twitch/event drop tiles clipping long reward names and timer text.
Increased timed event reward card height so names like “Cuddly Cotton Candy Grrgle” display cleanly.
Updated event grid spacing so taller Twitch/event cards do not overlap the next row.
Hid the Twitch/event drop button when there is no active reward item to show.
Kept the button visible only when an active event/Twitch drop has a real displayable item.

July 7, 2026

Updated Events Data
Improved background Lag (Shouldn't have lag any more when opening)
Improved first-open performance for the main HomeDecor window.
Added background catalog warmup after login to reduce opening lag.
Fixed normal mode doing extra hidden rendering before the window was shown.
Fixed startup flow for tracker and minimap vendor setup.

Added a cleaner Events header badge with active event countdowns
Improved Twitch Drop display and click handling
Moved the window Scale control under the event badge
Improved catalog availability filtering across lists, shop, vendors, map pins, minimap, and trackers
Hid unavailable/not-yet-in-game decor from All Sources and source views
Fixed expired event items showing past their end dates
Improved normal mode startup performance after reload
Reduced first-open lag by warming catalog data in the background
Fixed header layout issues and invalid anchor errors
Database / Event Button
Updated the Database
Added better Check Availability for the catalog
New Event Button will be added for now all old event button infomation has been removed
Removed the Events top button and its glow/timer logic from UI\Shell\Layout.lua.
Removed Systems\Events.lua and its HomeDecor.toc entry.
Stopped loading/scanning Events data through Core\DataLoader.lua, search, map pins, and map popup vendor caches.
Removed the Events source option from the filter dropdown.
Added fallbacks so old saved Events category/source-filter settings go back to normal catalog views.

]]
