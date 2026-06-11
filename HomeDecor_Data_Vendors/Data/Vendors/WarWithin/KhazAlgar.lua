local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["WarWithin"] = NS.Data.Vendors["WarWithin"] or {}

NS.Data.Vendors["WarWithin"]["KhazAlgar"] = {

  {
    source={
      id=105333,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="628:6736:6322"
    },
    items={
      {decorID=7610, source={type="vendor", itemID=250307, costs={{currency="10000", itemID=3252},{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42318}}, colors={"Copper","Dark Brown","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=7620, source={type="vendor", itemID=250402, costs={{currency="20000", itemID=3252},{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42658}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=7621, source={type="vendor", itemID=250403, costs={{currency="30000", itemID=3252},{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42692}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7622, source={type="vendor", itemID=250404, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7623, source={type="vendor", itemID=250405, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61060}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=3, size="Medium"},
      {decorID=7624, source={type="vendor", itemID=250406, costs={{currency="30000", itemID=3252},{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42321}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7625, source={type="vendor", itemID=250407, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42619}}, colors={"Black","Forest Green","Green"}, budgetCost=1, size="Small"},
      {decorID=7658, source={type="vendor", itemID=250622, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42675}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7686, source={type="vendor", itemID=250689, costs={{currency="10000", itemID=3252},{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61054}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=7687, source={type="vendor", itemID=250690, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42627}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7690, source={type="vendor", itemID=250693, costs={{currency="30000", itemID=3252},{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42674}}, colors={"Dark Brown","Green","Olive"}, budgetCost=3, size="Large"},
      {decorID=8810, source={type="vendor", itemID=251778, costs={{currency="30000", itemID=3252},{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61218}}, colors={"Cyan","Tan","Teal"}, budgetCost=5, size="Large"},
      {decorID=8811, source={type="vendor", itemID=251779, costs={{currency="30000", itemID=3252},{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42689}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=9165, source={type="vendor", itemID=252753, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42655}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=11278, source={type="vendor", itemID=256677, costs={{currency="5000", itemID=3252},{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42628}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11279, source={type="vendor", itemID=256678, costs={{currency="2500", itemID=3252},{currency="1500", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11942, source={type="vendor", itemID=258299, costs={{currency="20000", itemID=3252},{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42547}}, colors={"Black","Teal"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=218202,
      type="vendor",
      faction="Neutral",
      zone="City of Threads",
      worldmap="2213:5020:3160"
    },
    items={
      {decorID=2532, source={type="vendor", itemID=246866, currency="1500", currencytype=3056}, requirements={achievement={id=40542}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=219217,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5520:7640"
    },
    items={
      {decorID=9244, source={type="vendor", itemID=253170, currency="750", currencytype=1792}, requirements={achievement={id=40210}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=219318,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5700:6040"
    },
    items={
      {decorID=2533, source={type="vendor", itemID=246867, currency="750", currencytype=2815}, requirements={achievement={id=41186}}, colors={"Brown","Copper","Dark Brown"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=221390,
      type="vendor",
      faction="Neutral",
      zone="Gundargaz, Ringing Deeps",
      worldmap="2214:4320:3280"
    },
    items={
      {decorID=9236, source={type="vendor", itemID=253162, currency="600", currencytype=2815}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=223728,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:3920:2440"
    },
    items={
      {decorID=760, source={type="vendor", itemID=245295, currency="1000", currencytype=2815}, colors={"Dark Brown","Navy Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=761, source={type="vendor", itemID=245296, currency="1000", currencytype=2815}, colors={"Dark Brown","Navy Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=762, source={type="vendor", itemID=245297, currency="1000", currencytype=2815}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=1750, source={type="vendor", itemID=245561, currency="620", currencytype=2815}, colors={"Amber","Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=9242, source={type="vendor", itemID=253168, costs={{currency="10000", currencytype="money"},{currency="9500", currencytype="money"},{currency="200000", currencytype="money"},{currency="8000", currencytype="money"}}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=226994,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:3400:7080"
    },
    items={
      {decorID=1277, source={type="vendor", itemID=245309, costs={{currency="15", itemID=227673}}}, colors={"Dark Gray","Teal"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=231396,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:2970:4100"
    },
    items={
      {decorID=1268, source={type="vendor", itemID=245307, currency="800", currencytype=2815}, colors={"Beige","Bronze","Dark Gray"}, requirements={rep="true"}, budgetCost=3, size="Medium"},
      {decorID=11127, source={type="vendor", itemID=256327, currency="450", currencytype=2815}, colors={"Brown","Dark Brown","Dark Gray"}, requirements={rep="true"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=231405,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:6320:1680"
    },
    items={
      {decorID=4560, source={type="vendor", itemID=248758, currency="900", currencytype=2815}, colors={"Dark Gray","Forest Green","Gold"}, requirements={rep="true"}, budgetCost=1, size="Small"},
      {decorID=10853, source={type="vendor", itemID=255642, currency="475", currencytype=2815}, colors={"Black","Dark Brown","Yellow"}, requirements={rep="true"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=231406,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:3900:2200"
    },
    items={
      {decorID=1259, source={type="vendor", itemID=245313, currency="450", currencytype=2815}, colors={"Dark Brown","Purple","Teal"}, requirements={rep="true"}, budgetCost=1, size="Small"},
      {decorID=10889, source={type="vendor", itemID=255674, currency="450", currencytype=2815}, colors={"Bronze","Brown","Dark Brown"}, requirements={rep="true"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=231407,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:5320:7260"
    },
    items={
      {decorID=1269, source={type="vendor", itemID=245311, currency="600", currencytype=2815}, colors={"Dark Gray","Forest Green","Light Brown"}, requirements={rep="true"}, budgetCost=1, size="Small"},
      {decorID=10857, source={type="vendor", itemID=255647, currency="650", currencytype=2815}, colors={"Brown","Copper","Dark Gray"}, requirements={rep="true"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=231408,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:2720:7240"
    },
    items={
      {decorID=1265, source={type="vendor", itemID=245321, currency="400", currencytype=2815}, colors={"Dark Gray","Gray"}, requirements={rep="true"}, budgetCost=1, size="Small"},
      {decorID=10852, source={type="vendor", itemID=255641, currency="500", currencytype=2815}, colors={"Dark Gray","Forest Green","Yellow"}, requirements={rep="true"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=231409,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:4380:5080"
    },
    items={
      {decorID=1257, source={type="vendor", itemID=245314, costs={{currency="650", currencytype=2815},{currency="850", currencytype=2815}}}, colors={"Beige","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=1258, source={type="vendor", itemID=243312, costs={{currency="700", currencytype=2815},{currency="900", currencytype=2815}}}, colors={"Dark Gray","Forest Green"}, budgetCost=3, size="Medium"},
      {decorID=1262, source={type="vendor", itemID=245319, currency="350", currencytype=2815}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=1263, source={type="vendor", itemID=245318, currency="450", currencytype=2815}, colors={"Copper","Dark Gray","Teal"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=235252,
      type="vendor",
      faction="Neutral",
      zone="K'aresh",
      worldmap="2472:4033:2936"
    },
    items={
      {decorID=3891, source={type="vendor", itemID=247751, currency="2000", currencytype=2815}, colors={"Copper","Dark Gray","Magenta"}, budgetCost=5, size="Huge"},
      {decorID=11948, source={type="vendor", itemID=258306, currency="1000", currencytype=2815}, colors={"Copper","Dark Gray","Light Purple"}, budgetCost=5, size="Large"},
      {decorID=11952, source={type="vendor", itemID=258320, currency="1000", currencytype=2815}, colors={"Dark Purple","Light Purple"}, budgetCost=5, size="Large"},
      {decorID=12195, source={type="vendor", itemID=258666, currency="800", currencytype=2815}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=12196, source={type="vendor", itemID=258667, currency="800", currencytype=2815}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=12197, source={type="vendor", itemID=258668, currency="800", currencytype=2815}, colors={"Dark Brown","Teal"}, budgetCost=5, size="Large"},
      {decorID=12198, source={type="vendor", itemID=258669, currency="800", currencytype=2815}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Medium"},
      {decorID=12211, source={type="vendor", itemID=258766, currency="800", currencytype=2815}, colors={"Black","Purple"}, budgetCost=5, size="Large"},
      {decorID=12212, source={type="vendor", itemID=258767, currency="800", currencytype=2815}, colors={"Dark Brown","Dark Purple","Magenta"}, budgetCost=5, size="Large"},
      {decorID=12217, source={type="vendor", itemID=258835, currency="800", currencytype=2815}, colors={"Dark Brown","Dark Purple","Magenta"}, budgetCost=5, size="Large"},
      {decorID=12218, source={type="vendor", itemID=258836, currency="800", currencytype=2815}, colors={"Copper","Dark Brown","Magenta"}, budgetCost=5, size="Large"},
      {decorID=12220, source={type="vendor", itemID=258885, currency="800", currencytype=2815}, colors={"Dark Brown","Dark Purple","Magenta"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=235314,
      type="vendor",
      faction="Neutral",
      zone="Tazavesh, the Veiled Market",
      worldmap="2472:4320:3480"
    },
    items={
      {decorID=14359, source={type="vendor", itemID=260582, currency="500", currencytype=2815}, requirements={quest={id=86820}}, colors={"Copper","Dark Gray","Gray"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=235621,
      type="vendor",
      faction="Neutral",
      zone="Liberation of Undermine",
      worldmap="2406:4329:5189"
    },
    items={
      {decorID=828, source={type="vendor", itemID=239213}, colors={"Deep Red","Gold","Gray"}, budgetCost=3, size="Small"},
      {decorID=1121, source={type="vendor", itemID=245302}, requirements={achievement={id=41119}}, colors={"Dark Gray","Deep Red","Teal"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=239333,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:2580:4360"
    },
    items={
      {decorID=11128, source={type="vendor", itemID=256328, currency="350", currencytype=2815}, colors={"Copper","Dark Gray","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=251911,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:0710:5300"
    },
    items={
      {decorID=1257, source={type="vendor", itemID=245314, costs={{currency="650", currencytype=2815},{currency="850", currencytype=2815}}}, colors={"Beige","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=1258, source={type="vendor", itemID=243312, costs={{currency="700", currencytype=2815},{currency="900", currencytype=2815}}}, colors={"Dark Gray","Forest Green"}, budgetCost=3, size="Medium"},
      {decorID=1262, source={type="vendor", itemID=245319, currency="350", currencytype=2815}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=1263, source={type="vendor", itemID=245318, currency="450", currencytype=2815}, colors={"Copper","Dark Gray","Teal"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=251911,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:4319:5047"
    },
    items={
      {decorID=825, source={type="vendor", itemID=245306, currency="1200", currencytype=2815}, requirements={quest={id=86408}}, colors={"Dark Gray","Royal Blue","Teal"}, budgetCost=5, size="Large"},
      {decorID=827, source={type="vendor", itemID=245303, currency="800", currencytype=2815}, requirements={quest={id=85780}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1266, source={type="vendor", itemID=245325, currency="1000", currencytype=2815}, requirements={quest={id=85711}}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=1267, source={type="vendor", itemID=243321, currency="1000", currencytype=2815}, requirements={quest={id=87297}}, colors={"Dark Gray","Deep Red","Silver"}, budgetCost=3, size="Medium"},
      {decorID=1271, source={type="vendor", itemID=245324, currency="1500", currencytype=2815}, requirements={achievement={id=40894}}, colors={"Dark Brown","Dark Gray","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=1274, source={type="vendor", itemID=245308, currency="750", currencytype=2815}, requirements={quest={id=87008}}, colors={"Brown","Dark Gray","Deep Red"}, budgetCost=3, size="Medium"},
      {decorID=1276, source={type="vendor", itemID=245310, currency="800", currencytype=2815}, requirements={quest={id=83176}}, colors={"Dark Gray","Gold","Red"}, budgetCost=3, size="Large"},
      {decorID=11455, source={type="vendor", itemID=257353}, requirements={achievement={id=61451}}, colors={"Blue","Dark Brown","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=14381, source={type="vendor", itemID=260700, currency="300", currencytype=2815}, requirements={quest={id=84675}}, colors={"Copper","Dark Gray","Silver"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=252312,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5284:6800"
    },
    items={
      {decorID=1693, source={type="vendor", itemID=245259, currency="500000", currencytype="money"}, colors={"Light Purple","Navy Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=1861, source={type="vendor", itemID=245655, currency="10", currencytype=2003}, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=2330, source={type="vendor", itemID=246487, currency="750000", currencytype="money"}, colors={"Dark Purple","Silver","Tan"}, budgetCost=3, size="Large"},
      {decorID=2433, source={type="vendor", itemID=246601, costs={{currency="10", itemID=166846}}}, colors={"Dark Gray","Silver"}, requirements={rep="true"}, budgetCost=1, size="Small"},
      {decorID=4022, source={type="vendor", itemID=247908, currency="50", currencytype=1220}, colors={"Dark Gray","Light Purple","Orange"}, budgetCost=1, size="Small"},
      {decorID=4029, source={type="vendor", itemID=247915, currency="1000000", currencytype="money"}, colors={"Dark Gray","Gray","Purple"}, budgetCost=3, size="Large"},
      {decorID=4172, source={type="vendor", itemID=248116, currency="750000", currencytype="money"}, colors={"Bronze","Dark Brown","Royal Blue"}, budgetCost=1, size="Medium"},
      {decorID=5111, source={type="vendor", itemID=248934, currency="15000000", currencytype="money"}, colors={"Amber","Copper","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=9242, source={type="vendor", itemID=253168, costs={{currency="10000", currencytype="money"},{currency="9500", currencytype="money"},{currency="200000", currencytype="money"},{currency="8000", currencytype="money"}}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=9247, source={type="vendor", itemID=253173, currency="200000", currencytype="money"}, requirements={quest={id=92572}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=10962, source={type="vendor", itemID=256168, currency="10", currencytype=2003}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=252887,
      type="vendor",
      faction="Neutral",
      zone="The Ringing Deeps",
      worldmap="2214:4340:3280"
    },
    items={
      {decorID=9178, source={type="vendor", itemID=253020, currency="500", currencytype=2815}, requirements={quest={id=78761}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=9188, source={type="vendor", itemID=253040, currency="650", currencytype=2815}, requirements={quest={id=82144}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=9236, source={type="vendor", itemID=253162, currency="600", currencytype=2815}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=3, size="Medium"},
      {decorID=9246, source={type="vendor", itemID=253172, currency="850", currencytype=2815}, requirements={quest={id=83160}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=252910,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5468:5724"
    },
    items={
      {decorID=9168, source={type="vendor", itemID=252756, currency="800", currencytype=2815}, requirements={quest={id=79530}}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=9169, source={type="vendor", itemID=252757, currency="900", currencytype=2815}, requirements={achievement={id=20595}}, colors={"Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=9181, source={type="vendor", itemID=253023, currency="1000", currencytype=2815}, requirements={achievement={id=40504}}, colors={"Dark Brown","Gray"}, budgetCost=3, size="Medium"},
      {decorID=9182, source={type="vendor", itemID=253034, currency="450", currencytype=2815}, requirements={quest={id=82895}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=9185, source={type="vendor", itemID=253037, currency="600", currencytype=2815}, requirements={achievement={id=40859}}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=9186, source={type="vendor", itemID=253038, currency="500", currencytype=2815}, colors={"Copper","Dark Gray","Teal"}, budgetCost=3, size="Medium"},
      {decorID=9237, source={type="vendor", itemID=253163, currency="900", currencytype=2815}, requirements={achievement={id=19408}}, colors={"Dark Gray","Gray"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=256783,
      type="vendor",
      faction="Neutral",
      zone="The Ringing Deeps",
      worldmap="2214:4335:3327"
    },
    items={
      {decorID=11930, source={type="vendor", itemID=258262, currency="350", currencytype=2815}, requirements={quest={id=79510}}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=11931, source={type="vendor", itemID=258264, currency="200", currencytype=2815}, requirements={quest={id=78642}}, colors={"Copper","Dark Brown","Orange"}, budgetCost=1, size="Small"},
      {decorID=11932, source={type="vendor", itemID=258265, currency="1000", currencytype=2815}, requirements={quest={id=80516}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=11933, source={type="vendor", itemID=258267, currency="750", currencytype=2815}, requirements={quest={id=79565}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=5, size="Large"},
    }
  },

}
