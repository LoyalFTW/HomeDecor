local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Drops = NS.Data.Drops or {}

NS.Data.Drops["BattleForAzeroth"] = NS.Data.Drops["BattleForAzeroth"] or {}

NS.Data.Drops["BattleForAzeroth"]["KulTiras"] = {
	{decorID=11814, source={ type="drop", zone="KulTiras", itemID=257928, worldmap="1462:5000:5000" }, colors={"Dark Brown","Gold","Gray"}, budgetCost=5, size="Large"},
	{decorID=2324,  source={ type="drop", zone="KulTiras", itemID=246481, worldmap="1462:5000:5000" }, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=5, size="Huge"},
	{decorID=2431,  source={ type="drop", zone="KulTiras", itemID=246599, worldmap="1462:5000:5000" }, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
	{decorID=2432,  source={ type="drop", zone="KulTiras", itemID=246600, worldmap="1462:5000:5000" }, colors={"Dark Gray"}, budgetCost=1, size="Small"},
	{decorID=2434,  source={ type="drop", zone="KulTiras", itemID=246602, worldmap="1462:5000:5000" }, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
	{decorID=10887, source={ type="drop", zone="KulTiras", itemID=255672, npcID=150397, npc="King Mechagon", worldmap="1462:7274:3656" }, colors={"Dark Purple","Olive","Royal Blue"}, budgetCost=5, size="Huge"},
	{decorID=2238, source={ type="drop", zone="KulTiras", itemID=246421, npcID=126983, npc="Harlan Sweete", worldmap="895:8399:7901" }, colors={"Dark Brown","Deep Red"}, budgetCost=1, size="Small"},
	{decorID=1880, source={ type="drop", zone="KulTiras", itemID=245681, npcID=134069, npc="Vol'zith the Whisperer", worldmap="942:7878:2663" }, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=5, size="Huge"},
    {decorID=18484, source={ type="drop", zone="KulTiras", itemID=267008, npcID=267008, npc="Zaxasj the Speaker", worldmap="2133:4920:5240"}, colors={"Bronze","Dark Brown","Gold"}, budgetCost=3, size="Medium"},
    -- {decorID=25337, source={type="drop", zone="Ral'kala", itemID=278154, name="Ral'kala"}, budgetCost=3, size="Medium"}, -- HIDDENCATALOG
    -- {decorID=26208, source={type="encounter", zone="Kings' Rest - Dazar, The First King", itemID=278245, name="Kings' Rest - Dazar, The First King"}, budgetCost=3, size="Large"}, -- HIDDENCATALOG
    -- {decorID=26198, source={type="encounter", zone="Temple of Sethraliss - Avatar of Sethraliss", itemID=278982, name="Temple of Sethraliss - Avatar of Sethraliss"}, budgetCost=5, size="Huge"}, -- HIDDENCATALOG
}
