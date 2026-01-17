local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Inscription"] = NS.Data.Professions["Inscription"] or {}

NS.Data.Professions["Inscription"]["Cataclysm"] = {
  {decorID=11725, title="Gilnean Map", decorType="Wall Hangings", source={type="profession", profession="Inscription", expansion="Cataclysm", skillID=1269534, skillLevel=60, itemID=257696}, reagents={{itemID=251764, count=8}, {itemID=61978, count=8}, {itemID=54849, count=3}, {itemID=39354, count=1}}},
  {decorID=11724, title="Gilnean Postbox", decorType="Miscellaneous - All", source={type="profession", profession="Inscription", expansion="Cataclysm", skillID=1269540, skillLevel=60, itemID=257695}, reagents={{itemID=251764, count=35}, {itemID=61978, count=10}, {itemID=55053, count=1}, {itemID=52186, count=12}}},
  {decorID=1832, title="Gilnean Rocking Chair", decorType="Seating", source={type="profession", profession="Inscription", expansion="Cataclysm", skillID=1261278, skillLevel=60, itemID=245623}, reagents={{itemID=251764, count=25}, {itemID=61981, count=8}, {itemID=56850, count=4}, {itemID=52328, count=6}}},
  {decorID=1831, title="Gilnean Wall Shelf", decorType="Storage", source={type="profession", profession="Inscription", expansion="Cataclysm", skillID=1261288, skillLevel=60, itemID=245622}, reagents={{itemID=251764, count=10}, {itemID=61978, count=4}, {itemID=52186, count=2}}},
  {decorID=1830, title="Gilnean Wooden Table", decorType="Tables and Desks", source={type="profession", profession="Inscription", expansion="Cataclysm", skillID=1261259, skillLevel=60, itemID=245621}, reagents={{itemID=251764, count=25}, {itemID=61981, count=8}, {itemID=56850, count=4}, {itemID=52327, count=6}}},
}
