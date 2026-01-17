local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Alchemy"] = NS.Data.Professions["Alchemy"] or {}

NS.Data.Professions["Alchemy"]["Cataclysm"] = {
  {decorID=855, title="Gilnean Cauldron", decorType="Food and Drink", source={type="profession", profession="Alchemy", expansion="Cataclysm", skillID=1261255, skillLevel=60, itemID=245517}, reagents={{itemID=251764, count=30}, {itemID=69237, count=1}, {itemID=56850, count=6}, {itemID=54849, count=16}, {itemID=52326, count=40}}},
  {decorID=11723, title="Gilnean Green Potion", decorType="Ornamental", source={type="profession", profession="Alchemy", expansion="Cataclysm", skillID=1269506, skillLevel=60, itemID=257694}, reagents={{itemID=251764, count=10}, {itemID=52988, count=5}, {itemID=52985, count=3}, {itemID=52329, count=5}, {itemID=3371, count=1}}},
}
