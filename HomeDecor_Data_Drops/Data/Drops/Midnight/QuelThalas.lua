local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Drops = NS.Data.Drops or {}

NS.Data.Drops["Midnight"] = NS.Data.Drops["Midnight"] or {}

local MOBSETS = {
	IsleOfQuelDanas_Embers = {
		[246728] = {name="Void Ember"},
		[246729] = {name="Light Ember"}
	}
}

NS.Data.Drops["Midnight"]["QuelThalas"] = {
	{decorID=15570, source={ type="drop", zone="DenOfNalorakk", itemID=264332, npcID=258877, npc="Nalorakk", worldmap="2437:3140:8390" }, colors={"Dark Gray","Light Brown"}, budgetCost=3, size="Medium"},
	{decorID=16094, source={ type="drop", zone="MaisaraCaverns", itemID=264717, npcID=248605, npc="Rak'tul", worldmap="2437:4440:4030" }, colors={"Dark Gray"}, budgetCost=5, size="Large"},
	{decorID=15061, source={ type="drop", zone="MagistersTerrace", itemID=263230, npc="Magister's Terrace", bossencounter=2662, worldmap="2520:5000:5000" }, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
	{decorID=15069, source={ type="drop", zone="MurderRow", itemID=263238, npc="Murder Row", bossencounter=2682, worldmap="2434:5000:5000" }, colors={"Crimson","Dark Brown","Tan"}, budgetCost=5, size="Large"},

	{decorID=15761, source={ type="drop", zone="TheVoidspire", itemID=264497, npcID=240435, npc="Imperator Averzian", worldmap="2405:4540:6400" }, colors={"Dark Gray","Royal Blue","Tan"}, budgetCost=1, size="Tiny"},
	{decorID=15762, source={ type="drop", zone="TheVoidspire", itemID=264498, npcID=240434, npc="Vorasius", worldmap="2405:4540:6400" }, colors={"Cyan","Teal"}, budgetCost=5, size="Large"},
	{decorID=15758, source={ type="drop", zone="TheVoidspire", itemID=264494, npcID=240432, npc="Fallen-King Salhadaar", worldmap="2405:4540:6400" }, colors={"Dark Gray","Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
	{decorID=15755, source={ type="drop", zone="TheVoidspire", itemID=264491, npcID=242056, npc="Vaelgor", worldmap="2405:4540:6400" }, colors={"Dark Brown","Light Purple","Navy Blue"}, budgetCost=5, size="Large"},
	{decorID=14806, source={ type="drop", zone="TheVoidspire", itemID=262957, npcID=250589, npc="War Chaplain Senn", worldmap="2405:4540:6400" }, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Huge"},
	{decorID=20632, source={ type="drop", zone="TheVoidspire", itemID=269269, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }, budgetCost=5, size="Large"},
	{decorID=19252, source={ type="drop", zone="TheVoidspire", itemID=268049, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }, colors={"Blue","Light Gray","Light Purple"}, budgetCost=1, size="Small"},
	{decorID=17630, source={ type="drop", zone="TheVoidspire", itemID=265951, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }, colors={"Bronze","Dark Brown","Gray"}, budgetCost=1, size="Small"},
	{decorID=18398, source={ type="drop", zone="TheVoidspire", itemID=266887, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }, colors={"Dark Brown","Gold","Gray"}, budgetCost=1, size="Small"},
	{decorID=14633, source={ type="drop", zone="Voidstorm", itemID=262608, worldmap="2405:5000:5000" }, colors={"Light Purple","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
	{decorID=15583, source={ type="drop", zone="Voidstorm", itemID=264343, worldmap="2405:5000:5000" }, colors={"Dark Gray","Royal Blue"}, budgetCost=1, size="Small"},
	{decorID=15747, source={ type="drop", zone="Voidstorm", itemID=264483, worldmap="2405:5000:5000" }, colors={"Blue","Dark Purple","Royal Blue"}, budgetCost=1, size="Small"},

	{decorID=15576, source={ type="drop", zone="NexusPointXenas", itemID=264338, npcID=241546, npc="Lothraxion", worldmap="2405:6440:6180" }, colors={"Dark Gray","Royal Blue","Tan"}, budgetCost=5, size="Large"},

	{decorID=15481, source={ type="drop", zone="TheDreamrift", itemID=264246, npcID=256116, npc="Chimaerus" }, colors={"Dark Gray","Light Purple","Royal Blue"}, budgetCost=3, size="Large"},
	{decorID=19197, source={ type="drop", zone="TheDreamrift", itemID=267645, npcID=256116, npc="Chimaerus" }, colors={"Dark Gray","Light Gray","Light Purple"}, budgetCost=1, size="Small"},
	{decorID=17629, source={ type="drop", zone="TheDreamrift", itemID=265950, npcID=256116, npc="Chimaerus" }, colors={"Amber","Copper","Dark Brown"}, budgetCost=1, size="Small"},
	{decorID=18397, source={ type="drop", zone="TheDreamrift", itemID=266886, npcID=256116, npc="Chimaerus" }, colors={"Copper","Dark Brown","Gold"}, budgetCost=1, size="Small"},

	{decorID=15467, source={ type="drop", zone="IsleOfQuelDanas", itemID=264187, mobSet="IsleOfQuelDanas_Embers", _mobSets=MOBSETS }, colors={"Beige","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
	{decorID=15756, source={ type="drop", zone="IsleOfQuelDanas", itemID=264492, npcID=214650, npc="L'ura" }, colors={"Dark Gray","Navy Blue","Royal Blue"}, budgetCost=5, size="Large"},
	{decorID=17628, source={ type="drop", zone="IsleOfQuelDanas", itemID=265949, npcID=214650, npc="L'ura" }, colors={"Bronze","Dark Brown"}, budgetCost=1, size="Small"},
	{decorID=18396, source={ type="drop", zone="IsleOfQuelDanas", itemID=266885, npcID=214650, npc="L'ura" }, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
	{decorID=19198, source={ type="drop", zone="IsleOfQuelDanas", itemID=267646, npcID=214650, npc="L'ura" }, colors={"Dark Gray","Light Purple","Silver"}, budgetCost=1, size="Small"},

	{decorID=15567, source={ type="drop", zone="Delves", itemID=264329, worldmap="2537:5000:5000" }, colors={"Dark Brown","Olive","Teal"}, budgetCost=3, size="Medium"},
	{decorID=15568, source={ type="drop", zone="Delves", itemID=264330, worldmap="2537:5000:5000" }, colors={"Black","Dark Brown"}, budgetCost=1, size="Small"},
	{decorID=18485, source={ type="drop", zone="Delves", itemID=267009, worldmap="2537:5000:5000" }, colors={"Dark Gray","Deep Red","Tan"}, budgetCost=3, size="Medium"},
	{decorID=15493, source={ type="drop", zone="Delves", itemID=264258, worldmap="2537:5000:5000" }, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
	{decorID=15582, source={ type="drop", zone="Delves", itemID=264342, worldmap="2537:5000:5000" }, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
	{decorID=8889,  source={ type="drop", zone="Delves", itemID=251967, worldmap="2537:5000:5000" }, colors={"Dark Brown","Light Brown","Tan"}, budgetCost=1, size="Large"},
	{decorID=14822, source={ type="drop", zone="Delves", itemID=263036, worldmap="2537:5000:5000" }, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=3, size="Medium"},
	{decorID=14828, source={ type="drop", zone="Delves", itemID=263042, worldmap="2537:5000:5000" }, colors={"Dark Brown","Gold","Light Brown"}, budgetCost=3, size="Medium"},
	{decorID=15064, source={ type="drop", zone="Delves", itemID=263233, worldmap="2537:5000:5000" }, colors={"Dark Gray","Light Brown","Tan"}, budgetCost=3, size="Medium"},

	{decorID=11284, source={ type="drop", zone="WindrunnerSpire", itemID=256683, npcID=231636, npc="Restless Heart", worldmap="2395:6440:6180" }, colors={"Bronze","Dark Brown"}, budgetCost=3, size="Medium"},

	{decorID=1137,  source={ type="drop", zone="TheBlindingVale", itemID=253451, npcID=247676, npc="Ziekket" }, colors={"Dark Gray","White","Yellow"}, budgetCost=3, size="Large"},

	{decorID=15574, source={ type="drop", zone="VoidscarArena", itemID=264336, npcID=248015, npc="Charonus" }, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=5, size="Large"},
    {decorID=24889, source={type="drop", zone="Delves", itemID=275855, name="Delves"}, budgetCost=3, size="Medium"},
    {decorID=22147, source={type="drop", zone="Ral'kala", itemID=278374, name="Ral'kala"}, budgetCost=3, size="Medium"},
    {decorID=24890, source={type="drop", zone="Ral'kala", itemID=278378, name="Ral'kala"}, budgetCost=3, size="Medium"},
    -- {decorID=21956, source={type="drop", zone="The Bargained Crown", itemID=272365, name="The Bargained Crown"}, budgetCost=1, size="Huge"}, -- HIDDENCATALOG
    {decorID=25293, source={type="drop", zone="Zul'jan's Strongbox", itemID=279211, name="Zul'jan's Strongbox"}, budgetCost=5, size="Huge"},
    {decorID=25293, source={type="encounter", zone="Altar of Fangs - Zul'jan", itemID=279211, name="Altar of Fangs - Zul'jan"}, budgetCost=5, size="Huge"},
    {decorID=26205, source={type="encounter", zone="The Venomous Abyss - Nek'zali the Soulcoiler", itemID=279115, name="The Venomous Abyss - Nek'zali the Soulcoiler"}, budgetCost=1, size="Small"},
    {decorID=25812, source={type="encounter", zone="The Venomous Abyss - The Bargained Crown", itemID=279131, name="The Venomous Abyss - The Bargained Crown"}, budgetCost=5, size="Huge"},
    {decorID=25813, source={type="encounter", zone="The Venomous Abyss - The Twin Fangs", itemID=279122, name="The Venomous Abyss - The Twin Fangs"}, budgetCost=5, size="Huge"},
    {decorID=25131, source={type="encounter", zone="The Venomous Abyss - Ula'tek", itemID=279125, name="The Venomous Abyss - Ula'tek"}, budgetCost=1, size="Small"},
    {decorID=25132, source={type="encounter", zone="The Venomous Abyss - Ula'tek", itemID=279129, name="The Venomous Abyss - Ula'tek"}, budgetCost=1, size="Small"},
    {decorID=25133, source={type="encounter", zone="The Venomous Abyss - Ula'tek", itemID=279127, name="The Venomous Abyss - Ula'tek"}, budgetCost=1, size="Small"},
    {decorID=27043, source={type="encounter", zone="The Venomous Abyss - Ula'tek", itemID=279500, name="The Venomous Abyss - Ula'tek"}, budgetCost=5, size="Huge"},
    {decorID=21952, source={type="encounter", zone="The Venomous Abyss - Vashnik the Malignant", itemID=272361, name="The Venomous Abyss - Vashnik the Malignant"}, budgetCost=5, size="Large"},
    {decorID=16813, source={type="drop", zone="Drop", itemID=265389, name="Drop"}, colors={"Royal Blue","Tan","Teal"}, budgetCost=1, size="Tiny"},
    {decorID=2606, source={type="encounter", zone="Encounter", itemID=247235, name="Encounter"}, colors={"Beige","Copper","Deep Red"}, budgetCost=1, size="Medium"},
}
