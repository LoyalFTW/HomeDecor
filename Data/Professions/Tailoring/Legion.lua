local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Tailoring"] = NS.Data.Professions["Tailoring"] or {}

NS.Data.Professions["Tailoring"]["Legion"] = {
  {decorID=12161, title="Beloved Raptor Plushie", decorType="Ornamental", source={type="profession", profession="Tailoring", expansion="Legion", skillID=1263858, skillLevel=80, itemID=258557}, reagents={{itemID=251767, count=8}, {itemID=130175, count=2}, {itemID=129032, count=5}, {itemID=127037, count=2}, {itemID=124437, count=15}}},
  {decorID=4034, title="Circular Shal'dorei Rug", decorType="Floor", source={type="profession", profession="Tailoring", expansion="Legion", skillID=1260774, skillLevel=80, itemID=247920}, reagents={{itemID=251767, count=30}, {itemID=129032, count=15}, {itemID=127037, count=8}, {itemID=124437, count=40}}},
  {decorID=4041, title="Shal'dorei Open-Air Tent", decorType="Large Structures", source={type="profession", profession="Tailoring", expansion="Legion", skillID=1260769, skillLevel=80, itemID=248010}, reagents={{itemID=251767, count=40}, {itemID=127037, count=12}, {itemID=127004, count=20}, {itemID=124461, count=12}}},
}
