local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Blacksmithing"] = NS.Data.Professions["Blacksmithing"] or {}

NS.Data.Professions["Blacksmithing"]["Northrend"] = {
  {decorID=11375, title="Dalaran Runic Anvil", decorType="Uncategorized", source={type="profession", profession="Blacksmithing", expansion="Northrend", skillID=1261327, skillLevel=60, itemID=257040}, reagents={{itemID=251762, count=40}, {itemID=45087, count=6}, {itemID=37663, count=8}, {itemID=35624, count=4}}},
  {decorID=16012, title="Dalaran Sewer Gate", decorType="Doors", source={type="profession", profession="Blacksmithing", expansion="Northrend", skillID=1272662, skillLevel=60, itemID=264676}, reagents={{itemID=251762, count=30}, {itemID=45087, count=4}, {itemID=37663, count=6}, {itemID=35622, count=2}}},
  {decorID=16087, title="Dalaran Sun Sconce", decorType="Small Lights", source={type="profession", profession="Blacksmithing", expansion="Northrend", skillID=1272614, skillLevel=60, itemID=264710}, reagents={{itemID=251762, count=8}, {itemID=37663, count=4}, {itemID=36860, count=3}}},
}
