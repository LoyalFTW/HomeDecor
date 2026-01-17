local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Tailoring"] = NS.Data.Professions["Tailoring"] or {}

NS.Data.Professions["Tailoring"]["Pandaria"] = {
  {decorID=11945, title="Pandaren Fishing Net", decorType="Ornamental", source={type="profession", profession="Tailoring", expansion="Pandaria", skillID=1263553, skillLevel=60, itemID=258302}, reagents={{itemID=251763, count=8}, {itemID=82441, count=5}, {itemID=74866, count=10}}},
  {decorID=3878, title="Pandaren Meander Rug", decorType="Floor", source={type="profession", profession="Tailoring", expansion="Pandaria", skillID=1261250, skillLevel=60, itemID=247738}, reagents={{itemID=251763, count=25}, {itemID=82444, count=2}, {itemID=82441, count=15}}},
}
