local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Blacksmithing"] = NS.Data.Professions["Blacksmithing"] or {}

NS.Data.Professions["Blacksmithing"]["Outland"] = {
  {decorID=11370, title="Bronze Banner of the Exiled", decorType="Miscellaneous - All", source={type="profession", profession="Blacksmithing", expansion="Outland", skillID=1261347, skillLevel=60, itemID=257035}, reagents={{itemID=242691, count=20}, {itemID=23449, count=8}, {itemID=22452, count=4}, {itemID=21845, count=2}}},
  {decorID=11374, title="Draenei Crystal Forge", decorType="Uncategorized", source={type="profession", profession="Blacksmithing", expansion="Outland", skillID=1261359, skillLevel=60, itemID=257039}, reagents={{itemID=242691, count=50}, {itemID=25868, count=2}, {itemID=23573, count=8}, {itemID=23449, count=10}, {itemID=21884, count=10}}},
  {decorID=11371, title="Draenei Smith's Anvil", decorType="Tables and Desks", source={type="profession", profession="Blacksmithing", expansion="Outland", skillID=1261383, skillLevel=60, itemID=257036}, reagents={{itemID=242691, count=25}, {itemID=23573, count=4}, {itemID=23449, count=6}, {itemID=22452, count=4}}},
}
