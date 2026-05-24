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
	{decorID=15570, source={ type="drop", zone="DenOfNalorakk", itemID=264332, npcID=258877, npc="Nalorakk", worldmap="2437:3140:8390" }},
	{decorID=16094, source={ type="drop", zone="MaisaraCaverns", itemID=264717, npcID=248605, npc="Rak'tul", worldmap="2437:4440:4030" }},
	{decorID=15061, source={ type="drop", zone="MagistersTerrace", itemID=263230, npc="Magister's Terrace", bossencounter=2662, worldmap="2520:5000:5000" }},
	{decorID=15069, source={ type="drop", zone="MurderRow", itemID=263238, npc="Murder Row", bossencounter=2682, worldmap="2434:5000:5000" }},

	{decorID=15761, source={ type="drop", zone="TheVoidspire", itemID=264497, npcID=240435, npc="Imperator Averzian", worldmap="2405:4540:6400" }},
	{decorID=15762, source={ type="drop", zone="TheVoidspire", itemID=264498, npcID=240434, npc="Vorasius", worldmap="2405:4540:6400" }},
	{decorID=15758, source={ type="drop", zone="TheVoidspire", itemID=264494, npcID=240432, npc="Fallen-King Salhadaar", worldmap="2405:4540:6400" }},
	{decorID=15755, source={ type="drop", zone="TheVoidspire", itemID=264491, npcID=242056, npc="Vaelgor", worldmap="2405:4540:6400" }},
	{decorID=14806, source={ type="drop", zone="TheVoidspire", itemID=262957, npcID=250589, npc="War Chaplain Senn", worldmap="2405:4540:6400" }},
	{decorID=20632, source={ type="drop", zone="TheVoidspire", itemID=269269, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }},
	{decorID=19252, source={ type="drop", zone="TheVoidspire", itemID=268049, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }},
	{decorID=17630, source={ type="drop", zone="TheVoidspire", itemID=265951, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }},
	{decorID=18398, source={ type="drop", zone="TheVoidspire", itemID=266887, npcID=244761, npc="Alleria Windrunner", worldmap="2405:4540:6400" }},
	{decorID=14633, source={ type="drop", zone="Voidstorm", itemID=262608, worldmap="2405:5000:5000" }},
	{decorID=15583, source={ type="drop", zone="Voidstorm", itemID=264343, worldmap="2405:5000:5000" }},
	{decorID=15747, source={ type="drop", zone="Voidstorm", itemID=264483, worldmap="2405:5000:5000" }},

	{decorID=15576, source={ type="drop", zone="NexusPointXenas", itemID=264338, npcID=241546, npc="Lothraxion", worldmap="2405:6440:6180" }},

	{decorID=15481, source={ type="drop", zone="TheDreamrift", itemID=264246, npcID=256116, npc="Chimaerus" }},
	{decorID=19197, source={ type="drop", zone="TheDreamrift", itemID=267645, npcID=256116, npc="Chimaerus" }},
	{decorID=17629, source={ type="drop", zone="TheDreamrift", itemID=265950, npcID=256116, npc="Chimaerus" }},
	{decorID=18397, source={ type="drop", zone="TheDreamrift", itemID=266886, npcID=256116, npc="Chimaerus" }},

	{decorID=15467, source={ type="drop", zone="IsleOfQuelDanas", itemID=264187, mobSet="IsleOfQuelDanas_Embers", _mobSets=MOBSETS }},
	{decorID=15756, source={ type="drop", zone="IsleOfQuelDanas", itemID=264492, npcID=214650, npc="L'ura" }},
	{decorID=17628, source={ type="drop", zone="IsleOfQuelDanas", itemID=265949, npcID=214650, npc="L'ura" }},
	{decorID=18396, source={ type="drop", zone="IsleOfQuelDanas", itemID=266885, npcID=214650, npc="L'ura" }},
	{decorID=19198, source={ type="drop", zone="IsleOfQuelDanas", itemID=267646, npcID=214650, npc="L'ura" }},

	{decorID=15567, source={ type="drop", zone="Delves", itemID=264329, worldmap="2537:5000:5000" }},
	{decorID=15568, source={ type="drop", zone="Delves", itemID=264330, worldmap="2537:5000:5000" }},
	{decorID=18485, source={ type="drop", zone="Delves", itemID=267009, worldmap="2537:5000:5000" }},
	{decorID=15493, source={ type="drop", zone="Delves", itemID=264258, worldmap="2537:5000:5000" }},
	{decorID=15582, source={ type="drop", zone="Delves", itemID=264342, worldmap="2537:5000:5000" }},
	{decorID=8889,  source={ type="drop", zone="Delves", itemID=251967, worldmap="2537:5000:5000" }},
	{decorID=14822, source={ type="drop", zone="Delves", itemID=263036, worldmap="2537:5000:5000" }},
	{decorID=14828, source={ type="drop", zone="Delves", itemID=263042, worldmap="2537:5000:5000" }},
	{decorID=15064, source={ type="drop", zone="Delves", itemID=263233, worldmap="2537:5000:5000" }},

	{decorID=11284, source={ type="drop", zone="WindrunnerSpire", itemID=256683, npcID=231636, npc="Restless Heart", worldmap="2395:6440:6180" }},

	{decorID=1137,  source={ type="drop", zone="TheBlindingVale", itemID=253451, npcID=247676, npc="Ziekket" }},

	{decorID=15574, source={ type="drop", zone="VoidscarArena", itemID=264336, npcID=248015, npc="Charonus" }}
}
