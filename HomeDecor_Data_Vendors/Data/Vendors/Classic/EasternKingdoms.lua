local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["EasternKingdoms"] = {
  {
    source={
      id=1247,
      type="vendor",
      faction="Neutral",
      zone="Dun Morogh",
      worldmap="469:9392:7091"
    },
    items={
      {decorID=11130, source={type="vendor", itemID=256330, currency="1900000", currencytype="money"}, colors={"Dark Gray","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=2140,
      type="vendor",
      faction="Neutral",
      zone="Silverpine Forest",
      worldmap="21:4406:3968"
    },
    items={
      {decorID=11498, source={type="vendor", itemID=257412, currency="1425000", currencytype="money"}, requirements={quest={id=27550}}, colors={"Black","Dark Brown"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=3178,
      type="vendor",
      faction="Neutral",
      zone="Wetlands",
      worldmap="56:0627:5745"
    },
    items={
      {decorID=11495, source={type="vendor", itemID=257405}, colors={"Black","Dark Brown"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=13217,
      type="vendor",
      faction="Neutral",
      zone="Hillsbrad Foothills",
      worldmap="25:4480:4640"
    },
    items={
      {decorID=2241, source={type="vendor", itemID=246424, costs={{currency="1", itemID=137642}}}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=14624,
      type="vendor",
      faction="Neutral",
      zone="Searing Gorge",
      worldmap="32:3860:2870"
    },
    items={
      {decorID=1315, source={type="vendor", itemID=245333, currency="1500000", currencytype="money"}, requirements={quest={id=28035}}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=2226, source={type="vendor", itemID=246409, currency="7000000", currencytype="money"}, requirements={quest={id=28064}}, colors={"Dark Gray","Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=44114,
      type="vendor",
      faction="Neutral",
      zone="Duskwood",
      worldmap="47:2027:5835"
    },
    items={
      {decorID=1833, source={type="vendor", itemID=245624, currency="1500000", currencytype="money"}, requirements={quest={id=26760}}, colors={"Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=11305, source={type="vendor", itemID=256905, currency="1750000", currencytype="money"}, requirements={quest={id=26754}}, colors={"Black"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=44337,
      type="vendor",
      faction="Alliance",
      zone="Surwich, Blasted Lands",
      worldmap="17:4580:8860"
    },
    items={
      {decorID=1481, source={type="vendor", itemID=244777, currency="11000000", currencytype="money"}, requirements={quest={id=25720}}, colors={"Black"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=45417,
      type="vendor",
      faction="Neutral",
      zone="Light's Hope Chapel",
      worldmap="23:7380:5220"
    },
    items={
      {decorID=4813, source={type="vendor", itemID=248796, currency="30000000", currencytype="money"}, requirements={achievement={id=5442}}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=49386,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap=""
    },
    items={
      {decorID=1998, source={type="vendor", itemID=246108, currency="20000000", currencytype="money"}, requirements={reputation={name="Wildhammer Clan", standing="Honored"}}, colors={"Beige","Copper","Dark Brown"}, budgetCost=1, size="Tiny"},
      {decorID=2242, source={type="vendor", itemID=246425, currency="4000000", currencytype="money"}, requirements={reputation={name="Wildhammer Clan", standing="Friendly"}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=49877,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City",
      worldmap="84:6700:7200"
    },
    items={
      {decorID=4402, source={type="vendor", itemID=248333, currency="950000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Honored"}}, colors={"Dark Brown","Dark Gray","Navy Blue"}, budgetCost=5, size="Large"},
      {decorID=4405, source={type="vendor", itemID=248336, currency="2850000", currencytype="money"}, requirements={quest={id=59583}}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=3, size="Large"},
      {decorID=4443, source={type="vendor", itemID=248617, currency="1425000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Revered"}}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=4444, source={type="vendor", itemID=248618, currency="1900000", currencytype="money"}, requirements={quest={id=26270}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=4445, source={type="vendor", itemID=248619, currency="2375000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Exalted"}}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=4446, source={type="vendor", itemID=248620, currency="1425000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Revered"}}, colors={"Dark Brown","Tan"}, budgetCost=3, size="Large"},
      {decorID=4447, source={type="vendor", itemID=248621, currency="2850000", currencytype="money"}, requirements={quest={id=26390}}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=4487, source={type="vendor", itemID=248662, currency="4750000", currencytype="money"}, requirements={quest={id=543}}, colors={"Navy Blue","Olive","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=4490, source={type="vendor", itemID=248665, currency="2375000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Exalted"}}, colors={"Dark Gray","Navy Blue","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=4811, source={type="vendor", itemID=248794, currency="475000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Friendly"}}, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=4812, source={type="vendor", itemID=248795, currency="712500", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Friendly"}}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=4814, source={type="vendor", itemID=248797}, requirements={quest={id=26229}}, colors={"Dark Brown","Red","Yellow"}, budgetCost=1, size="Tiny"},
      {decorID=4815, source={type="vendor", itemID=248798, currency="1900000", currencytype="money"}, requirements={quest={id=54}}, colors={"Dark Brown","Dark Gray","Light Gray"}, budgetCost=1, size="Small"},
      {decorID=4819, source={type="vendor", itemID=248801, currency="950000", currencytype="money"}, requirements={quest={id=26297}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=5115, source={type="vendor", itemID=248938, currency="1425000", currencytype="money"}, requirements={quest={id=60}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=5116, source={type="vendor", itemID=248939, currency="950000", currencytype="money"}, requirements={reputation={name="Stormwind", standing="Honored"}}, colors={"Bronze","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=9242, source={type="vendor", itemID=253168, costs={{currency="10000", currencytype="money"},{currency="9500", currencytype="money"},{currency="200000", currencytype="money"},{currency="8000", currencytype="money"}}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=11274, source={type="vendor", itemID=256673, currency="9500000", currencytype="money"}, requirements={quest={id=7604}}, colors={"Dark Gray","Gray"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=50307,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="89:3716:4743"
    },
    items={
      {decorID=858, source={type="vendor", itemID=245518, currency="1500000", currencytype="money"}, requirements={quest={id=24675}}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1829, source={type="vendor", itemID=245620, currency="500000", currencytype="money"}, requirements={quest={id=14402}}, colors={"Black","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=50309,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh",
      worldmap="87:5600:4700"
    },
    items={
      {decorID=2243, source={type="vendor", itemID=246426, costs={{currency="5700000", currencytype="money"},{currency="6000000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Honored"}}, colors={"Dark Brown","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=2333, source={type="vendor", itemID=246490, costs={{currency="2375000", currencytype="money"},{currency="2500000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Friendly"}}, colors={"Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=2334, source={type="vendor", itemID=246491, costs={{currency="1425000", currencytype="money"},{currency="1500000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Friendly"}}, colors={"Dark Gray"}, budgetCost=1, size="Large"},
      {decorID=8982, source={type="vendor", itemID=252010, costs={{currency="4275000", currencytype="money"},{currency="4500000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Honored"}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=11133, source={type="vendor", itemID=256333, costs={{currency="9500000", currencytype="money"},{currency="10000000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Revered"}}, colors={"Dark Brown","Dark Purple","Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=68363,
      type="vendor",
      faction="Neutral",
      zone="Bizmo's Brawlpub",
      worldmap=""
    },
    items={
      {decorID=10913, source={type="vendor", itemID=255840, currency="80000000", currencytype="money"}, requirements={reputation={name="Brawl'gar Arena", standing="Rank 7"}}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Small"},
      {decorID=12263, source={type="vendor", itemID=259071, currency="40000000", currencytype="money"}, requirements={reputation={name="Brawl'gar Arena", standing="Rank 5"}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=14815, source={type="vendor", itemID=263026, currency="5000000", currencytype="money"}, requirements={reputation={name="Brawl'gar Arena", standing="Rank 2"}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=115805,
      type="vendor",
      faction="Neutral",
      zone="Burning Steppes",
      worldmap="36:4680:4460"
    },
    items={
      {decorID=11131, source={type="vendor", itemID=256331, currency="4500000", currencytype="money"}, requirements={quest={id=28183}}, colors={"Copper","Dark Brown","Olive"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=211065,
      type="vendor",
      faction="Neutral",
      zone="Stormglen Village, Gilneas",
      worldmap="217:6040:9240"
    },
    items={
      {decorID=857, source={type="vendor", itemID=245520, currency="1500000", currencytype="money"}, requirements={achievement={id=19719}}, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=859, source={type="vendor", itemID=245516, currency="750000", currencytype="money"}, colors={"Black","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=860, source={type="vendor", itemID=245515, currency="750000", currencytype="money"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=1795, source={type="vendor", itemID=245604, currency="1000000", currencytype="money"}, colors={"Dark Brown","Deep Red"}, budgetCost=3, size="Large"},
      {decorID=1826, source={type="vendor", itemID=245617, currency="1000000", currencytype="money"}, colors={"Black"}, budgetCost=1, size="Small"},
      {decorID=11944, source={type="vendor", itemID=258301, currency="1250000", currencytype="money"}, colors={"Dark Gray","Gray","Light Gray"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=249196,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4960:8120"
    },
    items={
      {decorID=714, source={type="vendor", itemID=245284, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, colors={"Dark Brown","Purple","Tan"}, budgetCost=1, size="Small"},
      {decorID=1227, source={type="vendor", itemID=251997, costs={{currency="5000", currencytype=2815},{currency="75", currencytype=3319}}}, colors={"Crimson","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1236, source={type="vendor", itemID=245330, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, colors={"Bronze","Dark Brown","Gold"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=252312,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="2339:5284:6800"
    },
    items={
      {decorID=1693, source={type="vendor", itemID=245259, currency="500000", currencytype="money"}, colors={"Light Purple","Navy Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=1861, source={type="vendor", itemID=245655, currency="10", currencytype=2003}, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=2330, source={type="vendor", itemID=246487, currency="750000", currencytype="money"}, colors={"Dark Purple","Silver","Tan"}, budgetCost=3, size="Large"},
      {decorID=2433, source={type="vendor", itemID=246601, costs={{currency="10", itemID=166846}}}, colors={"Dark Gray","Silver"}, budgetCost=1, size="Small"},
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
      id=253227,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4974:2957"
    },
    items={
      {decorID=1998, source={type="vendor", itemID=246108, currency="20000000", currencytype="money"}, requirements={reputation={name="Wildhammer Clan", standing="Honored"}}, colors={"Beige","Copper","Dark Brown"}, budgetCost=1, size="Tiny"},
      {decorID=2242, source={type="vendor", itemID=246425, currency="4000000", currencytype="money"}, requirements={reputation={name="Wildhammer Clan", standing="Friendly"}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=2244, source={type="vendor", itemID=246427, currency="10000000", currencytype="money"}, requirements={quest={id=28244}}, colors={"Dark Gray","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=2245, source={type="vendor", itemID=246428, currency="15000000", currencytype="money"}, requirements={quest={id=28655}}, colors={"Cyan","Dark Gray","Royal Blue"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=253232,
      type="vendor",
      faction="Neutral",
      zone="The Library, Ironforge",
      worldmap="87:7580:0940"
    },
    items={
      {decorID=2228, source={type="vendor", itemID=246411, currency="7000000", currencytype="money"}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=2229, source={type="vendor", itemID=246412, currency="4500000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=253235,
      type="vendor",
      faction="Neutral",
      zone="Dun Morogh",
      worldmap=""
    },
    items={
      {decorID=2243, source={type="vendor", itemID=246426, costs={{currency="5700000", currencytype="money"},{currency="6000000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Honored"}}, colors={"Dark Brown","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=2333, source={type="vendor", itemID=246490, costs={{currency="2375000", currencytype="money"},{currency="2500000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Friendly"}}, colors={"Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=2334, source={type="vendor", itemID=246491, costs={{currency="1425000", currencytype="money"},{currency="1500000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Friendly"}}, colors={"Dark Gray"}, budgetCost=1, size="Large"},
      {decorID=8982, source={type="vendor", itemID=252010, costs={{currency="4275000", currencytype="money"},{currency="4500000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Honored"}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=11133, source={type="vendor", itemID=256333, costs={{currency="9500000", currencytype="money"},{currency="10000000", currencytype="money"}}}, requirements={reputation={name="Ironforge", standing="Revered"}}, colors={"Dark Brown","Dark Purple","Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=253235,
      type="vendor",
      faction="Neutral",
      zone="Dun Morogh",
      worldmap="87:2481:4396"
    },
    items={
      {decorID=1118, source={type="vendor", itemID=245427, currency="12000000", currencytype="money"}, requirements={quest={id=53566}}, colors={"Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=1216, source={type="vendor", itemID=245426, currency="7000000", currencytype="money"}, requirements={achievement={id=4859}}, colors={"Bronze","Dark Brown","Red"}, budgetCost=1, size="Small"},
      {decorID=11160, source={type="vendor", itemID=256425, currency="3500000", currencytype="money"}, requirements={achievement={id=8316}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=254603,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:7780:6580"
    },
    items={
      {decorID=3884, source={type="vendor", itemID=247744, currency="1000", currencytype=1792}, requirements={achievement={id=231}}, colors={"Copper","Dark Brown","Navy Blue"}, budgetCost=3, size="Medium"},
      {decorID=3886, source={type="vendor", itemID=247746, currency="800", currencytype=1792}, requirements={achievement={id=200}}, colors={"Blue","Dark Brown","Gold"}, budgetCost=3, size="Medium"},
      {decorID=3894, source={type="vendor", itemID=247757, currency="600", currencytype=1792}, requirements={achievement={id=158}}, colors={"Dark Brown","Gray","Navy Blue"}, budgetCost=3, size="Large"},
      {decorID=3895, source={type="vendor", itemID=247758, currency="1200", currencytype=1792}, requirements={achievement={id=221}}, colors={"Dark Gray","Gray","Navy Blue"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=254603,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:7783:6577"
    },
    items={
      {decorID=3880, source={type="vendor", itemID=247740, currency="2000", currencytype=1792}, requirements={achievement={id=6981}}, colors={"Dark Brown","Orange","Teal"}, budgetCost=1, size="Medium"},
      {decorID=3881, source={type="vendor", itemID=247741, currency="1000", currencytype=1792}, requirements={achievement={id=6981}}, colors={"Beige","Teal"}, budgetCost=1, size="Small"},
      {decorID=3890, source={type="vendor", itemID=247750, currency="2500", currencytype=1792}, requirements={achievement={id=40612}}, colors={"Brown","Crimson","Deep Red"}, budgetCost=3, size="Large"},
      {decorID=3893, source={type="vendor", itemID=247756, currency="1000", currencytype=1792}, requirements={achievement={id=1157}}, colors={"Dark Brown","Tan","White"}, budgetCost=3, size="Medium"},
      {decorID=3898, source={type="vendor", itemID=247761, currency="400", currencytype=1792}, requirements={achievement={id=212}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=3899, source={type="vendor", itemID=247762, currency="300", currencytype=1792}, requirements={achievement={id=213}}, colors={"Dark Brown","Forest Green","Gold"}, budgetCost=3, size="Medium"},
      {decorID=3900, source={type="vendor", itemID=247763, costs={{currency="5", itemID=137642}}}, requirements={achievement={id=61683}}, colors={"Amber","Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=3902, source={type="vendor", itemID=247765, costs={{currency="5", itemID=137642}}}, requirements={achievement={id=61687}}, colors={"Dark Brown","Green","Orange"}, budgetCost=3, size="Medium"},
      {decorID=3903, source={type="vendor", itemID=247766, costs={{currency="5", itemID=137642}}}, requirements={achievement={id=61688}}, colors={"Copper","Dark Brown","Gold"}, budgetCost=3, size="Medium"},
      {decorID=3905, source={type="vendor", itemID=247768, costs={{currency="5", itemID=137642}}}, requirements={achievement={id=61684}}, colors={"Amber","Dark Brown","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=3906, source={type="vendor", itemID=247769, costs={{currency="5", itemID=137642}}}, requirements={achievement={id=61685}}, colors={"Dark Brown","Royal Blue","Yellow"}, budgetCost=3, size="Medium"},
      {decorID=3907, source={type="vendor", itemID=247770, costs={{currency="2", itemID=137642}}}, requirements={achievement={id=61686}}, colors={"Royal Blue","Yellow"}, budgetCost=3, size="Medium"},
      {decorID=9244, source={type="vendor", itemID=253170, currency="750", currencytype=1792}, requirements={achievement={id=40210}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=11296, source={type="vendor", itemID=256896, currency="450", currencytype=1792}, requirements={achievement={id=5245}}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=256071,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:4926:8009"
    },
    items={
      {decorID=2511, source={type="vendor", itemID=246845, currency="20000000", currencytype="money"}, colors={"Dark Gray","Light Brown","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=2513, source={type="vendor", itemID=246847, currency="20000000", currencytype="money"}, colors={"Dark Brown","Light Brown","Purple"}, budgetCost=1, size="Tiny"},
      {decorID=2514, source={type="vendor", itemID=246848, currency="20000000", currencytype="money"}, colors={"Dark Brown","Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=2526, source={type="vendor", itemID=246860, currency="20000000", currencytype="money"}, colors={"Dark Gray","Gray","Silver"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=261231,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:4851:6876"
    },
    items={
      {decorID=14467, source={type="vendor", itemID=260785, costs={{currency="15000000", currencytype="money"},{currency="13500000", currencytype="money"}}}, requirements={achievement={id=62387}}, colors={"Dark Gray","Forest Green","Tan"}, budgetCost=5, size="Huge"},
      {decorID=15070, source={type="vendor", itemID=263239}, colors={"Blue","Dark Brown","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=15072, source={type="vendor", itemID=263241}, colors={"Brown","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=15073, source={type="vendor", itemID=263242}, colors={"Dark Brown","Light Purple","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=15074, source={type="vendor", itemID=263243}, colors={"Dark Brown","Silver","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=15142, source={type="vendor", itemID=263292}, colors={"Cyan","Dark Gray","Light Purple"}, budgetCost=1, size="Tiny"},
      {decorID=15143, source={type="vendor", itemID=263293}, colors={"Light Gray","Light Purple","Purple"}, budgetCost=1, size="Tiny"},
      {decorID=15144, source={type="vendor", itemID=263294}, colors={"Dark Brown","Olive","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=15145, source={type="vendor", itemID=263295}, colors={"Brown","Forest Green","Gold"}, budgetCost=1, size="Tiny"},
      {decorID=15146, source={type="vendor", itemID=263296}, colors={"Dark Brown","Forest Green","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=15147, source={type="vendor", itemID=263297}, colors={"Dark Purple","Light Purple","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=15150, source={type="vendor", itemID=263300}, colors={"Dark Purple","Light Purple","Royal Blue"}, budgetCost=1, size="Tiny"},
      {decorID=15152, source={type="vendor", itemID=263302}, colors={"Copper","Cyan","Dark Purple"}, budgetCost=1, size="Tiny"},
      {decorID=15153, source={type="vendor", itemID=263303}, colors={"Dark Brown","Navy Blue","Yellow"}, budgetCost=1, size="Tiny"},
      {decorID=16027, source={type="vendor", itemID=264680}, colors={"Cyan","Forest Green","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=16028, source={type="vendor", itemID=264681}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=16029, source={type="vendor", itemID=264682}, colors={"Crimson","Dark Brown","Gold"}, budgetCost=1, size="Tiny"},
      {decorID=16030, source={type="vendor", itemID=264683}, colors={"Crimson","Dark Brown","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=16031, source={type="vendor", itemID=264684}, colors={"Dark Purple","Light Purple","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16032, source={type="vendor", itemID=264685}, colors={"Dark Purple","Light Purple","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16033, source={type="vendor", itemID=264686}, colors={"Beige","Dark Brown","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=16034, source={type="vendor", itemID=264687}, colors={"Dark Purple","Light Gray","Light Purple"}, budgetCost=1, size="Tiny"},
      {decorID=16035, source={type="vendor", itemID=264688}, colors={"Copper","Dark Brown","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16036, source={type="vendor", itemID=264689}, colors={"Blue","Light Gray","Royal Blue"}, budgetCost=1, size="Tiny"},
      {decorID=16037, source={type="vendor", itemID=264690}, colors={"Dark Brown","Forest Green","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16038, source={type="vendor", itemID=264691}, colors={"Crimson","Dark Brown","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16811, source={type="vendor", itemID=265387}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=16812, source={type="vendor", itemID=265388}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=16814, source={type="vendor", itemID=265390}, colors={"Cyan","Navy Blue","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=16815, source={type="vendor", itemID=265391}, colors={"Dark Purple","Light Purple","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16816, source={type="vendor", itemID=265392}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=1, size="Tiny"},
      {decorID=16817, source={type="vendor", itemID=265393}, colors={"Dark Brown","Navy Blue","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16818, source={type="vendor", itemID=265394}, colors={"Dark Gray","Gray","Light Gray"}, budgetCost=1, size="Tiny"},
      {decorID=16819, source={type="vendor", itemID=265395}, colors={"Dark Gray","Gray","Light Gray"}, budgetCost=1, size="Tiny"},
      {decorID=16820, source={type="vendor", itemID=265396}, colors={"Dark Gray","Light Gray"}, budgetCost=1, size="Tiny"},
      {decorID=16821, source={type="vendor", itemID=265397}, colors={"Dark Brown","Gold","Royal Blue"}, budgetCost=1, size="Tiny"},
      {decorID=16822, source={type="vendor", itemID=265398}, colors={"Forest Green","Light Gray","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=16964, source={type="vendor", itemID=265544}, colors={"Dark Brown","Royal Blue","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16965, source={type="vendor", itemID=265545}, colors={"Amber","Light Purple","Navy Blue"}, budgetCost=1, size="Tiny"},
      {decorID=16966, source={type="vendor", itemID=265546}, colors={"Forest Green","Light Purple","Purple"}, budgetCost=1, size="Tiny"},
      {decorID=16967, source={type="vendor", itemID=265547}, colors={"Blue","Light Purple","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16968, source={type="vendor", itemID=265548}, colors={"Dark Purple","Light Purple","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=16969, source={type="vendor", itemID=265549}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
      {decorID=16970, source={type="vendor", itemID=265550}, colors={"Forest Green","Purple"}, budgetCost=1, size="Tiny"},
      {decorID=16971, source={type="vendor", itemID=265551}, colors={"Dark Brown","Navy Blue","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=16972, source={type="vendor", itemID=265552}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=1, size="Tiny"},
      {decorID=16973, source={type="vendor", itemID=265553}, colors={"Amber","Dark Brown","Light Brown"}, budgetCost=1, size="Tiny"},
      {decorID=23706, source={type="vendor", itemID=274731, currency="50000000", currencytype="money"}, budgetCost=1, size="Small"},
      {decorID=24193, source={type="vendor", itemID=274734, currency="50000000", currencytype="money"}, budgetCost=1, size="Small"},
      {decorID=24194, source={type="vendor", itemID=274736, currency="50000000", currencytype="money"}, budgetCost=1, size="Small"},
    }
  },

}
