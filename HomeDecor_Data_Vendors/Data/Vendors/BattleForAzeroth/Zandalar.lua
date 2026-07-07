local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BattleForAzeroth"] = NS.Data.Vendors["BattleForAzeroth"] or {}

NS.Data.Vendors["BattleForAzeroth"]["Zandalar"] = {

  {
    source={
      id=135459,
      type="vendor",
      faction="Neutral",
      zone="Nazmir",
      worldmap="863:3911:7947"
    },
    items={
      {decorID=1170, source={type="vendor", itemID=245488, currency="500", currencytype=1560}, requirements={quest={id=47188}}, colors={"Dark Brown","Teal"}, budgetCost=3, size="Large"},
      {decorID=1178, source={type="vendor", itemID=245495, currency="400", currencytype=1560}, colors={"Dark Brown","Teal"}, budgetCost=5, size="Large"},
      {decorID=1199, source={type="vendor", itemID=245413, currency="150", currencytype=1560}, colors={"Bronze","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1218, source={type="vendor", itemID=245500, currency="400", currencytype=1560}, colors={"Bronze","Dark Brown","Teal"}, budgetCost=5, size="Large"},
      {decorID=11484, source={type="vendor", itemID=257394, currency="150", currencytype=1560}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=148923,
      type="vendor",
      faction="Horde",
      zone="Port of Zandalar, Dazar'alor",
      worldmap="1165:4440:9440"
    },
    items={
      {decorID=943, source={type="vendor", itemID=245482, currency="250", currencytype=1710}, colors={"Dark Gray","Tan"}, budgetCost=1, size="Large"},
    }
  },

  {
    source={
      id=148924,
      type="vendor",
      faction="Neutral",
      zone="Zuldazar",
      worldmap="1165:5122:9508"
    },
    items={
      {decorID=839, source={type="vendor", itemID=245464, currency="200", currencytype=1560}, colors={"Dark Gray","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=932, source={type="vendor", itemID=245474, currency="300", currencytype=1560}, colors={"Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=937, source={type="vendor", itemID=245476, currency="300", currencytype=1560}, requirements={achievement={id=13284}}, colors={"Dark Gray","Gray"}, budgetCost=5, size="Huge"},
      {decorID=938, source={type="vendor", itemID=245477, currency="200", currencytype=1560}, colors={"Black","Dark Purple"}, budgetCost=5, size="Huge"},
      {decorID=939, source={type="vendor", itemID=245471, currency="150", currencytype=1560}, colors={"Dark Gray","Forest Green","Tan"}, budgetCost=1, size="Small"},
      {decorID=940, source={type="vendor", itemID=245472, currency="150", currencytype=1560}, colors={"Dark Gray","Forest Green","Gray"}, budgetCost=1, size="Small"},
      {decorID=949, source={type="vendor", itemID=241067, currency="200", currencytype=1560}, colors={"Dark Gray","Red","Yellow"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=251921,
      type="vendor",
      faction="Horde",
      zone="Zuldazar",
      worldmap="862:5810:6250"
    },
    items={
      {decorID=837, source={type="vendor", itemID=245467, currency="150", currencytype=1560}, requirements={achievement={id=12869}}, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=838, source={type="vendor", itemID=245463, currency="150", currencytype=1560}, requirements={achievement={id=12867}}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=862, source={type="vendor", itemID=245473, currency="300", currencytype=1560}, requirements={quest={id=51986}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=863, source={type="vendor", itemID=245465, currency="200", currencytype=1560}, requirements={quest={id=51984}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=864, source={type="vendor", itemID=245466, currency="200", currencytype=1560}, requirements={quest={id=51601}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=865, source={type="vendor", itemID=239606, currency="200", currencytype=1560}, requirements={quest={id=46931}}, colors={"Gray","Purple","Teal"}, budgetCost=3, size="Medium"},
      {decorID=933, source={type="vendor", itemID=245483, currency="200", currencytype=1560}, requirements={achievement={id=12870}}, colors={"Black","Purple"}, budgetCost=3, size="Medium"},
      {decorID=934, source={type="vendor", itemID=245469, currency="300", currencytype=1560}, requirements={quest={id=52122}}, colors={"Beige","Copper","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=935, source={type="vendor", itemID=245475, currency="300", currencytype=1560}, requirements={quest={id=51985}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=936, source={type="vendor", itemID=245470, currency="300", currencytype=1560}, requirements={quest={id=52978}}, colors={"Amber","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=941, source={type="vendor", itemID=245478, currency="200", currencytype=1560}, colors={"Dark Gray","Deep Red","Red"}, budgetCost=1, size="Small"},
      {decorID=942, source={type="vendor", itemID=245479, currency="300", currencytype=1560}, requirements={rep="true"}, colors={"Dark Gray","Forest Green","Green"}, budgetCost=1, size="Small"},
      {decorID=944, source={type="vendor", itemID=241062, currency="200", currencytype=1560}, requirements={achievement={id=12509}}, colors={"Dark Purple","Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=945, source={type="vendor", itemID=245480, currency="200", currencytype=1560}, requirements={rep="true"}, colors={"Bronze","Deep Red","Yellow"}, budgetCost=3, size="Medium"},
      {decorID=946, source={type="vendor", itemID=245481, currency="300", currencytype=1560}, requirements={rep="true"}, colors={"Dark Brown","Gray","Green"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=252326,
      type="vendor",
      faction="Neutral",
      zone="Zuldazar",
      worldmap="1164:3694:5917"
    },
    items={
      {decorID=1175, source={type="vendor", itemID=245487, currency="500", currencytype=1560}, requirements={achievement={id=13038}}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1179, source={type="vendor", itemID=245491, currency="600", currencytype=1560}, requirements={quest={id=50808}}, colors={"Dark Brown","Olive","Teal"}, budgetCost=5, size="Large"},
      {decorID=1180, source={type="vendor", itemID=243113, currency="150", currencytype=1560}, colors={"Black","Navy Blue","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1183, source={type="vendor", itemID=245522, currency="1200", currencytype=1560}, requirements={achievement={id=12479}}, colors={"Cyan","Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=1185, source={type="vendor", itemID=245494, currency="200", currencytype=1560}, requirements={achievement={id=13039}}, colors={"Dark Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=1188, source={type="vendor", itemID=245497, currency="500", currencytype=1560}, requirements={achievement={id=12614}}, colors={"Amber","Dark Brown","Teal"}, budgetCost=5, size="Large"},
      {decorID=1189, source={type="vendor", itemID=245521, currency="100", currencytype=1560}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=1, size="Small"},
      {decorID=1191, source={type="vendor", itemID=245490, currency="600", currencytype=1560}, requirements={achievement={id=12733}}, colors={"Dark Brown","Red","Teal"}, budgetCost=5, size="Large"},
      {decorID=1192, source={type="vendor", itemID=245489, currency="150", currencytype=1560}, requirements={quest={id=47250}}, colors={"Dark Brown"}, budgetCost=1, size="Tiny"},
      {decorID=1193, source={type="vendor", itemID=245486, currency="150", currencytype=1560}, requirements={quest={id=47432}}, colors={"Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1196, source={type="vendor", itemID=245493, currency="200", currencytype=1560}, requirements={quest={id=47741}}, colors={"Dark Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=1197, source={type="vendor", itemID=243130, currency="300", currencytype=1560}, colors={"Dark Brown","Dark Gray","Gold"}, budgetCost=3, size="Large"},
      {decorID=1205, source={type="vendor", itemID=245485, currency="1000", currencytype=1560}, requirements={quest={id=50963}}, colors={"Copper","Dark Brown","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=1310, source={type="vendor", itemID=245417, currency="400", currencytype=1560}, requirements={quest={id=47874}}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1417, source={type="vendor", itemID=244325, currency="400", currencytype=1560}, requirements={achievement={id=12746}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=1418, source={type="vendor", itemID=244326, currency="150", currencytype=1560}, requirements={achievement={id=13018}}, colors={"Blue","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=1697, source={type="vendor", itemID=245263, currency="150", currencytype=1560}, requirements={quest={id=48554}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=11319, source={type="vendor", itemID=256919, currency="300", currencytype=1560}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=11489, source={type="vendor", itemID=257399, currency="300", currencytype=1560}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
    }
  },

}
