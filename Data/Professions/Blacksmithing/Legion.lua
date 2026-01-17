local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Blacksmithing"] = NS.Data.Professions["Blacksmithing"] or {}

NS.Data.Professions["Blacksmithing"]["Legion"] = {
  {decorID=4036, title="Suramar Fence", decorType="Misc Structural", source={type="profession", profession="Blacksmithing", expansion="Legion", skillID=1260693, skillLevel=80, itemID=247922}, reagents={{itemID=251767, count=15}, {itemID=124461, count=10}, {itemID=124441, count=1}}},
  {decorID=4023, title="Suramar Fencepost", decorType="Misc Structural", source={type="profession", profession="Blacksmithing", expansion="Legion", skillID=1260695, skillLevel=80, itemID=247909}, reagents={{itemID=251767, count=10}, {itemID=124461, count=5}, {itemID=124441, count=1}}},
  {decorID=1314, title="Tauren Soup Pot", decorType="Food and Drink", source={type="profession", profession="Blacksmithing", expansion="Legion", skillID=1260698, skillLevel=80, itemID=245408}, reagents={{itemID=251767, count=35}, {itemID=133591, count=3}, {itemID=133589, count=3}, {itemID=133588, count=3}, {itemID=124461, count=20}, {itemID=124109, count=5}}},
}
