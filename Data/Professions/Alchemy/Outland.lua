local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Alchemy"] = NS.Data.Professions["Alchemy"] or {}

NS.Data.Professions["Alchemy"]["Outland"] = {
  {decorID=16082, title="Glazed Sin'dorei Vial", decorType="Ornamental", source={type="profession", profession="Alchemy", expansion="Outland", skillID=1272712, skillLevel=60, itemID=264705}, reagents={{itemID=242691, count=6}, {itemID=34440, count=5}, {itemID=23449, count=4}, {itemID=3371, count=1}}},
  {decorID=16083, title="Shadow Council Torch", decorType="Misc Lighting", source={type="profession", profession="Alchemy", expansion="Outland", skillID=1272723, skillLevel=60, itemID=264706}, reagents={{itemID=242691, count=16}, {itemID=23573, count=3}, {itemID=22861, count=4}, {itemID=21884, count=4}}},
  {decorID=16086, title="Stranglekelp Sack", decorType="Uncategorized", source={type="profession", profession="Alchemy", expansion="Outland", skillID=1272715, skillLevel=60, itemID=264709}, reagents={{itemID=242691, count=8}, {itemID=21840, count=4}, {itemID=3820, count=10}}},
}
