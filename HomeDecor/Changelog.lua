HomeDecor_ChangelogMeta = {
  importance = "Major", -- Major / Silent
}

HomeDecor_Changelog = [[
#HomeDecor

Sept 9, 2026
Added change log back so its working
Added locales hoping others will want to translate for other languages

Sept 8, 2026
HomeDecor received a broad usability, visual-consistency, and reliability overhaul.

The addon’s scrolling system was completely unified. Endeavors, the Decor Viewer, 
source lists, and other scrolling areas now use the same shared scrollbar design. 
These scrollbars respond properly to the selected Accent Color and Design Preset, giving every page a 
more consistent appearance and predictable behavior.

The interface was also cleaned up by removing redundant visual elements. 
This included the duplicate Trackers dropdown in the header and the small accent-colored selection 
bar previously displayed beside selected dropdown items. These changes make the addon feel less cluttered 
and more polished.

Collection tracking was made considerably more accurate. 
Horde and Alliance versions of equivalent décor items are no longer counted as separate collectibles, 
preventing inflated totals and ensuring that collection percentages reflect the player’s real progress.

The Endeavors system was made more dependable, particularly after reloading the interface. 
Cases where Endeavors information could appear blank or reset to zero after `/reload` were corrected. 
The related Statistics information now restores and displays properly as well.

HomeDecor’s internal systems were reorganized and simplified. Repeated scrollbar, color, and tooltip behavior was consolidated into shared systems, while unused and outdated code was removed. 
This reduced unnecessary duplication, made the addon smaller and easier to maintain, and ensures future interface changes behave consistently throughout every page.

The result is a cleaner and more cohesive addon with more accurate collection tracking, 
more reliable information, consistent theme support, and a stronger foundation for future development.


]]
