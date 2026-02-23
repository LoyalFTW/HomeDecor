# HomeDecor

## [v12.0.56](https://github.com/LoyalFTW/HomeDecor/tree/v12.0.56) (2026-02-21)
[Full Changelog](https://github.com/LoyalFTW/HomeDecor/compare/v12.0.55...v12.0.56) [Previous Releases](https://github.com/LoyalFTW/HomeDecor/releases)

- World Map + Minimap + Optimization.  
    * Map pin tooltip position is now its own setting  
      separate from the rest of the addon - changing  
      it won't touch tooltips anywhere else. Works  
      the same across both the World Map and Minimap.  
      Added a Middle option that locks the tooltip  
      to the center of your screen instead of  
      following the cursor. Button order in the  
      World Map panel fixed to Left Right instead  
      of Right Left.  
    * DecorAH filter results are now cached and only  
      rebuild when something actually changes instead  
      of recalculating the full list on every scroll  
      or interaction. Recipe lookups are cached the  
      same way. Noticeable on larger profession lists.  
    * Item data for profession recipes now preloads  
      in small batches shortly after login so prices  
      and tooltips are ready before you open the  
      window instead of loading on demand.  
