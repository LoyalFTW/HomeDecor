local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Leatherworking"] = NS.Data.Professions["Leatherworking"] or {}

NS.Data.Professions["Leatherworking"]["Legion"] = {
  {decorID=11490, title="Highmountain Tanner's Frame", decorType="Misc Accents", source={type="profession", profession="Leatherworking", expansion="Legion", skillID=1262273, skillLevel=80, itemID=257400}, reagents={{itemID=251767, count=34}, {itemID=124438, count=10}, {itemID=124116, count=5}, {itemID=124113, count=25}}},
  {decorID=1243, title="Tauren Fencepost", decorType="Misc Structural", source={type="profession", profession="Leatherworking", expansion="Legion", skillID=1260765, skillLevel=80, itemID=245407}, reagents={{itemID=251767, count=15}, {itemID=124438, count=5}, {itemID=124113, count=10}}},
  {decorID=1242, title="Tauren Leather Fence", decorType="Misc Structural", source={type="profession", profession="Leatherworking", expansion="Legion", skillID=1260762, skillLevel=80, itemID=245406}, reagents={{itemID=251767, count=20}, {itemID=124438, count=5}, {itemID=124113, count=20}}},
}
