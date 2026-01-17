local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Professions = NS.Data.Professions or {}

NS.Data.Professions["Tailoring"] = NS.Data.Professions["Tailoring"] or {}

NS.Data.Professions["Tailoring"]["Shadowlands"] = {
  {decorID=16014, title="Aspirant's Ringed Banner", decorType="Wall Hangings", source={type="profession", profession="Tailoring", expansion="Shadowlands", skillID=1272578, skillLevel=80, itemID=264678}, reagents={{itemID=251772, count=16}, {itemID=177062, count=5}, {itemID=173202, count=25}, {itemID=173173, count=1}, {itemID=171828, count=12}}},
  {decorID=16090, title="Heart of the Forest Banner", decorType="Misc Accents", source={type="profession", profession="Tailoring", expansion="Shadowlands", skillID=1272575, skillLevel=80, itemID=264713}, reagents={{itemID=251772, count=45}, {itemID=177062, count=10}, {itemID=177061, count=2}, {itemID=173170, count=6}, {itemID=172439, count=20}}},
  {decorID=12165, title="Kyrian Aspirant's Rolled Cushion", decorType="Ornamental", source={type="profession", profession="Tailoring", expansion="Shadowlands", skillID=1263853, skillLevel=80, itemID=258561}, reagents={{itemID=251772, count=14}, {itemID=177062, count=5}, {itemID=173202, count=12}}},
}
