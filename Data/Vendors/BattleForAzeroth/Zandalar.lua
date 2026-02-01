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
      {decorID=1175, decorType="Storage", source={type="vendor", itemID=245487, currency="500", currencytype="War Resources"}, requirements={achievement={id=13038}}},
      {decorID=1179, decorType="Ornamental", source={type="vendor", itemID=245491, currency="600", currencytype="War Resources"}, requirements={quest={id=50808}}},
      {decorID=1180, decorType="Floor", source={type="vendor", itemID=243113, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1183, decorType="Wall Hangings", source={type="vendor", itemID=245522, currency="1200", currencytype="War Resources"}, requirements={achievement={id=12479}}},
      {decorID=1185, decorType="Ornamental", source={type="vendor", itemID=245494, currency="200", currencytype="War Resources"}, requirements={achievement={id=13039}}},
      {decorID=1188, decorType="Ornamental", source={type="vendor", itemID=245497, currency="500", currencytype="War Resources"}, requirements={achievement={id=12614}}},
      {decorID=1189, decorType="Small Lights", source={type="vendor", itemID=245521, currency="100", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1191, decorType="Large Lights", source={type="vendor", itemID=245490, currency="600", currencytype="War Resources"}, requirements={achievement={id=12733}}},
      {decorID=1192, decorType="Seating", source={type="vendor", itemID=245489, currency="150", currencytype="War Resources"}, requirements={quest={id=47250}}},
      {decorID=1193, decorType="Seating", source={type="vendor", itemID=245486, currency="150", currencytype="War Resources"}, requirements={quest={id=47250}}},
      {decorID=1196, decorType="Ornamental", source={type="vendor", itemID=245493, currency="200", currencytype="War Resources"}, requirements={quest={id=47741}}},
      {decorID=1197, decorType="Storage", source={type="vendor", itemID=243130, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1205, decorType="Beds", source={type="vendor", itemID=245485, currency="1000", currencytype="War Resources"}, requirements={quest={id=50963}}},
      {decorID=1310, decorType="Wall Hangings", source={type="vendor", itemID=245417, currency="400", currencytype="War Resources"}, requirements={quest={id=47874}}},
      {decorID=1417, decorType="Food and Drink", source={type="vendor", itemID=244325, currency="400", currencytype="War Resources"}, requirements={achievement={id=12746}}},
      {decorID=1418, decorType="Storage", source={type="vendor", itemID=244326, currency="150", currencytype="War Resources"}, requirements={achievement={id=13018}}},
      {decorID=1697, decorType="Food and Drink", source={type="vendor", itemID=245263, currency="150", currencytype="War Resources"}, requirements={quest={id=48554}}},
      {decorID=11319, decorType="Ceiling Lights", source={type="vendor", itemID=256919, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=11489, decorType="Misc Lighting", source={type="vendor", itemID=257399, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
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
      {decorID=839, decorType="Storage", source={type="vendor", itemID=245464, currency="200", currencytype="War Resources"}},
      {decorID=932, decorType="Tables and Desks", source={type="vendor", itemID=245474, currency="300", currencytype="War Resources"}},
      {decorID=937, decorType="Large Structures", source={type="vendor", itemID=245476, currency="300", currencytype="War Resources"}, requirements={achievement={id=13284}}},
      {decorID=938, decorType="Large Structures", source={type="vendor", itemID=245477, currency="200", currencytype="War Resources"}},
      {decorID=939, decorType="Small Lights", source={type="vendor", itemID=245471, currency="150", currencytype="War Resources"}},
      {decorID=940, decorType="Wall Lights", source={type="vendor", itemID=245472, currency="150", currencytype="War Resources"}},
      {decorID=949, decorType="Large Lights", source={type="vendor", itemID=241067, currency="200", currencytype="War Resources"}},
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
      {decorID=837, decorType="Storage", source={type="vendor", itemID=245467, currency="150", currencytype="War Resources"}, requirements={achievement={id=12869}}},
      {decorID=838, decorType="Storage", source={type="vendor", itemID=245463, currency="150", currencytype="War Resources"}, requirements={achievement={id=12867}}},
      {decorID=862, decorType="Tables and Desks", source={type="vendor", itemID=245473, currency="300", currencytype="War Resources"}, requirements={quest={id=51986}}},
      {decorID=863, decorType="Seating", source={type="vendor", itemID=245465, currency="200", currencytype="War Resources"}, requirements={quest={id=51984}}},
      {decorID=864, decorType="Seating", source={type="vendor", itemID=245466, currency="200", currencytype="War Resources"}, requirements={quest={id=51601}}},
      {decorID=865, decorType="Floor", source={type="vendor", itemID=239606, currency="200", currencytype="War Resources"}, requirements={quest={id=46931}}},
      {decorID=933, decorType="Storage", source={type="vendor", itemID=245483, currency="200", currencytype="War Resources"}, requirements={achievement={id=12870}}},
      {decorID=934, decorType="Small Lights", source={type="vendor", itemID=245469, currency="300", currencytype="War Resources"}, requirements={quest={id=52122}}},
      {decorID=935, decorType="Tables and Desks", source={type="vendor", itemID=245475, currency="300", currencytype="War Resources"}, requirements={quest={id=51985}}},
      {decorID=936, decorType="Wall Lights", source={type="vendor", itemID=245470, currency="300", currencytype="War Resources"}, requirements={quest={id=52978}}},
      {decorID=941, decorType="Wall Lights", source={type="vendor", itemID=245478, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=942, decorType="Wall Lights", source={type="vendor", itemID=245479, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=944, decorType="Floor", source={type="vendor", itemID=241062, currency="200", currencytype="War Resources"}, requirements={achievement={id=12509}}},
      {decorID=945, decorType="Large Lights", source={type="vendor", itemID=245480, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=946, decorType="Large Lights", source={type="vendor", itemID=245481, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
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
      {decorID=1170, decorType="Miscellaneous - All", source={type="vendor", itemID=245488, currency="500", currencytype="War Resources"}, requirements={quest={id=47188}}},
      {decorID=1178, decorType="Large Structures", source={type="vendor", itemID=245495, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1199, decorType="Wall Lights", source={type="vendor", itemID=245413, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1218, decorType="Large Structures", source={type="vendor", itemID=245500, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=11484, decorType="Misc Lighting", source={type="vendor", itemID=257394, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
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
      {decorID=943, decorType="Storage", source={type="vendor", itemID=245482, currency="250", currencytype="Seafarer's Dubloon"}},
    }
  },
}
