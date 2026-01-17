local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BattleForAzeroth"] = NS.Data.Vendors["BattleForAzeroth"] or {}

NS.Data.Vendors["BattleForAzeroth"]["Zandalar"] = {

  {
    title="T'lama",
    source={
      id=252326,
      type="vendor",
      faction="Horde",
      zone="Zuldazar",
      worldmap="1164:3694:5917",
    },
    items={
      {decorID=1175, title="Bookcase of Gonk", decorType="Storage", source={type="vendor", itemID=245487, currency="500", currencytype="War Resources"}, requirements={achievement={id=13038, title="Raptari Rider"}, rep="true"}},
      {decorID=1179, title="Bwonsamdi's Golden Gong", decorType="Ornamental", source={type="vendor", itemID=245491, currency="600", currencytype="War Resources"}, requirements={quest={id=50808, title="Halting the Empire's Fall"}, rep="true"}},
      {decorID=1180, title="Blue Dazar'alor Rug", decorType="Floor", source={type="vendor", itemID=243113, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1183, title="Grand Mask of Bwonsamdi, Loa of Graves", decorType="Wall Hangings", source={type="vendor", itemID=245522, currency="1200", currencytype="War Resources"}, requirements={achievement={id=12479, title="Zandalar Forever!"}, rep="true"}},
      {decorID=1185, title="Idol of Pa'ku, Master of Winds", decorType="Ornamental", source={type="vendor", itemID=245494, currency="200", currencytype="War Resources"}, requirements={achievement={id=13039, title="Paku'ai"}, rep="true"}},
      {decorID=1188, title="Golden Loa's Altar", decorType="Ornamental", source={type="vendor", itemID=245497, currency="500", currencytype="War Resources"}, requirements={achievement={id=12614, title="Loa Expectations"}, rep="true"}},
      {decorID=1189, title="Stone Zandalari Lamp", decorType="Small Lights", source={type="vendor", itemID=245521, currency="100", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1191, title="Dazar'alor Forge", decorType="Large Lights", source={type="vendor", itemID=245490, currency="600", currencytype="War Resources"}, requirements={achievement={id=12733, title="Professional Zandalari Master"}, rep="true"}},
      {decorID=1192, title="Zuldazar Stool", decorType="Seating", source={type="vendor", itemID=245489, currency="150", currencytype="War Resources"}, requirements={quest={id=47250, title="We'll Meet Again"}, rep="true"}},
      {decorID=1193, title="Tired Troll's Bench", decorType="Seating", source={type="vendor", itemID=245486, currency="150", currencytype="War Resources"}, requirements={quest={id=47250, title="We'll Meet Again"}, rep="true"}},
      {decorID=1196, title="Idol of Rezan, Loa of Kings", decorType="Ornamental", source={type="vendor", itemID=245493, currency="200", currencytype="War Resources"}, requirements={quest={id=47741, title="To Sacrifice a Loa"}, rep="true"}},
      {decorID=1197, title="Zandalari Weapon Rack", decorType="Storage", source={type="vendor", itemID=243130, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1205, title="Golden Zandalari Bed", decorType="Beds", source={type="vendor", itemID=245485, currency="1000", currencytype="War Resources"}, requirements={quest={id=50963, title="Of Dark Deeds and Dark Days"}, rep="true"}},
      {decorID=1310, title="Akunda the Tapestry", decorType="Wall Hangings", source={type="vendor", itemID=245417, currency="400", currencytype="War Resources"}, requirements={quest={id=47874, title="Clearing the Fog"}, rep="true"}},
      {decorID=1417, title="Zuldazar Cook's Griddle", decorType="Food and Drink", source={type="vendor", itemID=244325, currency="400", currencytype="War Resources"}, requirements={achievement={id=12746, title="The Zandalari Menu"}, rep="true"}},
      {decorID=1418, title="Zandalari Wall Shelf", decorType="Storage", source={type="vendor", itemID=244326, currency="150", currencytype="War Resources"}, requirements={achievement={id=13018, title="Dune Rider"}, rep="true"}},
      {decorID=1697, title="Zocalo Drinks", decorType="Food and Drink", source={type="vendor", itemID=245263, currency="150", currencytype="War Resources"}, requirements={quest={id=48554, title="The Source of the Problem"}, rep="true"}},
      {decorID=11319, title="Zandalari War Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=256919, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=11489, title="Zandalari War Brazier", decorType="Misc Lighting", source={type="vendor", itemID=257399, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Provisioner Mukra",
    source={
      id=148924,
      type="vendor",
      faction="Horde",
      zone="Zuldazar",
      worldmap="1165:5122:9508",
    },
    items={
      {decorID=839, title="Inert Blight Canister", decorType="Storage", source={type="vendor", itemID=245464, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=932, title="Forsaken War Planning Table", decorType="Tables and Desks", source={type="vendor", itemID=245474, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=937, title="Large Forsaken War Tent", decorType="Large Structures", source={type="vendor", itemID=245476, currency="300", currencytype="War Resources"}, requirements={achievement={id=13284, title="Frontline Warrior"}, rep="true"}},
      {decorID=938, title="Small Forsaken War Tent", decorType="Large Structures", source={type="vendor", itemID=245477, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=939, title="Blightfire Lantern", decorType="Small Lights", source={type="vendor", itemID=245471, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=940, title="Blightfire Hanging Lantern", decorType="Wall Lights", source={type="vendor", itemID=245472, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=949, title="Large Forsaken Spiked Brazier", decorType="Large Lights", source={type="vendor", itemID=241067, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Arcanist Peroleth",
    source={
      id=251921,
      type="vendor",
      faction="Horde",
      zone="Port of Zandalar, Dazar'alor",
      worldmap="862:5800:6260",
    },
    items={
      {decorID=837, title="Lordaeron Banded Crate", decorType="Storage", source={type="vendor", itemID=245467, currency="150", currencytype="War Resources"}, requirements={achievement={id=12869, title="Azeroth at War: After Lordaeron"}, rep="true"}},
      {decorID=838, title="Lordaeron Banded Barrel", decorType="Storage", source={type="vendor", itemID=245463, currency="150", currencytype="War Resources"}, requirements={achievement={id=12867, title="Azeroth at War: The Barrens"}, rep="true"}},
      {decorID=862, title="Forsaken Studded Table", decorType="Tables and Desks", source={type="vendor", itemID=245473, currency="300", currencytype="War Resources"}, requirements={quest={id=51986, title="Return to Zuldazar"}, rep="true"}},
      {decorID=863, title="Tirisfal Wooden Chair", decorType="Seating", source={type="vendor", itemID=245465, currency="200", currencytype="War Resources"}, requirements={quest={id=51984, title="Return to Zuldazar"}, rep="true"}},
      {decorID=864, title="Forsaken Spiked Chair", decorType="Seating", source={type="vendor", itemID=245466, currency="200", currencytype="War Resources"}, requirements={quest={id=51601, title="The Bridgeport Ride"}, rep="true"}},
      {decorID=865, title="Forsaken Round Rug", decorType="Floor", source={type="vendor", itemID=239606, currency="200", currencytype="War Resources"}, requirements={quest={id=46931, title="Speaker of the Horde"}, rep="true"}},
      {decorID=933, title="Lordaeron Spiked Weapon Rack", decorType="Storage", source={type="vendor", itemID=245483, currency="200", currencytype="War Resources"}, requirements={achievement={id=12870, title="Azeroth at War: Kalimdor on Fire"}, rep="true"}},
      {decorID=934, title="Lordaeron Lantern", decorType="Small Lights", source={type="vendor", itemID=245469, currency="300", currencytype="War Resources"}, requirements={quest={id=52122, title="To Be Forsaken"}, rep="true"}},
      {decorID=935, title="Forsaken Long Table", decorType="Tables and Desks", source={type="vendor", itemID=245475, currency="300", currencytype="War Resources"}, requirements={quest={id=51985, title="Return to Zuldazar"}, rep="true"}},
      {decorID=936, title="Lordaeron Hanging Lantern", decorType="Wall Lights", source={type="vendor", itemID=245470, currency="300", currencytype="War Resources"}, requirements={quest={id=52978, title="With Prince in Tow"}, rep="true"}},
      {decorID=941, title="Lordaeron Sconce", decorType="Wall Lights", source={type="vendor", itemID=245478, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=942, title="Blightfire Sconce", decorType="Wall Lights", source={type="vendor", itemID=245479, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=944, title="Lordaeron Rectangular Rug", decorType="Floor", source={type="vendor", itemID=241062, currency="200", currencytype="War Resources"}, requirements={achievement={id=12509, title="Ready for War"}, rep="true"}},
      {decorID=945, title="Lordaeron Torch", decorType="Large Lights", source={type="vendor", itemID=245480, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=946, title="Blightfire Torch", decorType="Large Lights", source={type="vendor", itemID=245481, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Provisioner Lija",
    source={
      id=135459,
      type="vendor",
      faction="Horde",
      zone="Nazmir",
      worldmap="863:3911:7947",
    },
    items={
      {decorID=1170, title="Zandalari Rickshaw", decorType="Miscellaneous - All", source={type="vendor", itemID=245488, currency="500", currencytype="War Resources"}, requirements={quest={id=47188, title="The Aid of the Loa"}, rep="true"}},
      {decorID=1178, title="Dazar'alor Market Tent", decorType="Large Structures", source={type="vendor", itemID=245495, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1199, title="Zandalari Sconce", decorType="Wall Lights", source={type="vendor", itemID=245413, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1218, title="Red Dazar'alor Tent", decorType="Large Structures", source={type="vendor", itemID=245500, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=11484, title="Zandalari War Torch", decorType="Misc Lighting", source={type="vendor", itemID=257394, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Captain Zen'taga",
    source={
      id=148923,
      type="vendor",
      faction="Horde",
      zone="Port of Zandalar, Dazar'alor",
      worldmap="1163:4460:9440",
    },
    items={
      {decorID=943, title="Undercity Spiked Chest", decorType="Storage", source={type="vendor", itemID=245482, currency="250", currencytype="Seafarer's Dubloon"}, requirements={rep="true"}},
    }
  },
}
