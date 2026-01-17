local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Alchemy"] = NS.Data.Professions["Alchemy"] or {}

NS.Data.Professions["Alchemy"]["Northrend"] = {
  {decorID=11901, title="Icecrown Plague Canister", decorType="Storage", source={type="profession", profession="Alchemy", expansion="Northrend", skillID=1263559, skillLevel=60, itemID=258213}, reagents={{itemID=251762, count=40}, {itemID=43102, count=1}, {itemID=40077, count=5}, {itemID=36908, count=5}, {itemID=35625, count=2}, {itemID=33447, count=10}}},
  {decorID=11900, title="San'layn Blood Orb", decorType="Ornamental", source={type="profession", profession="Alchemy", expansion="Northrend", skillID=1263558, skillLevel=60, itemID=258212}, reagents={{itemID=251762, count=20}, {itemID=36908, count=3}, {itemID=36905, count=10}, {itemID=35627, count=4}, {itemID=3371, count=1}}},
}
