local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Jewelcrafting"] = NS.Data.Professions["Jewelcrafting"] or {}

NS.Data.Professions["Jewelcrafting"]["Pandaria"] = {
  {decorID=3876, title="Jade Temple Dragon Fountain", decorType="Large Structures", source={type="profession", profession="Jewelcrafting", expansion="Pandaria", skillID=1261242, skillLevel=60, itemID=247736}, reagents={{itemID=251763, count=50}, {itemID=83092, count=1}, {itemID=76734, count=2}, {itemID=76061, count=6}, {itemID=72095, count=30}}},
  {decorID=3868, title="Pandaren Stone Post", decorType="Misc Structural", source={type="profession", profession="Jewelcrafting", expansion="Pandaria", skillID=1261244, skillLevel=60, itemID=247728}, reagents={{itemID=251763, count=10}, {itemID=76061, count=2}, {itemID=72096, count=6}}},
  {decorID=1194, title="Pandaren Stone Wall", decorType="Misc Structural", source={type="profession", profession="Jewelcrafting", expansion="Pandaria", skillID=1261243, skillLevel=60, itemID=245509}, reagents={{itemID=251763, count=15}, {itemID=76061, count=2}, {itemID=72096, count=10}}},
}
