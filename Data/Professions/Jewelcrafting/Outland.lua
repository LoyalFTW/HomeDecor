local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Jewelcrafting"] = NS.Data.Professions["Jewelcrafting"] or {}

NS.Data.Professions["Jewelcrafting"]["Outland"] = {
  {decorID=14553, title="Draenei Crystal Chandelier", decorType="Ceiling Lights", source={type="profession", profession="Jewelcrafting", expansion="Outland", skillID=1269496, skillLevel=60, itemID=262347}, reagents={{itemID=242691, count=15}, {itemID=25867, count=2}, {itemID=23573, count=4}}},
  {decorID=11889, title="Shattrath Lamppost", decorType="Misc Lighting", source={type="profession", profession="Jewelcrafting", expansion="Outland", skillID=1263815, skillLevel=60, itemID=258201}, reagents={{itemID=242691, count=20}, {itemID=32230, count=2}, {itemID=31079, count=6}}},
  {decorID=11888, title="Shattrath Sconce", decorType="Wall Lights", source={type="profession", profession="Jewelcrafting", expansion="Outland", skillID=1263817, skillLevel=60, itemID=258200}, reagents={{itemID=242691, count=10}, {itemID=31079, count=3}, {itemID=23441, count=3}}},
}
