local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Midnight"] = NS.Data.Vendors["Midnight"] or {}

NS.Data.Vendors["Midnight"]["QuelThalas"] = {

  {
    source={
      id=112338,
      type="vendor",
      faction="Neutral",
      zone="Mandori Village",
      worldmap="709:5033:5913"
    },
    items={
      {decorID=5112, source={type="vendor", itemID=248935, currency="500", currencytype=1220}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=5113, source={type="vendor", itemID=248936, currency="500", currencytype=1220}, colors={"Dark Brown","Gray"}, budgetCost=3, size="Large"},
      {decorID=5119, source={type="vendor", itemID=248942, currency="2000", currencytype=1220}, requirements={achievement={id=60986}}, colors={"Dark Brown","Olive","Tan"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=240279,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4595:6592"
    },
    items={
      {decorID=11324, source={type="vendor", itemID=256924, currency="250", currencytype=3316}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=11326, source={type="vendor", itemID=256926, currency="250", currencytype=3316}, colors={"Dark Brown","Dark Gray","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=11327, source={type="vendor", itemID=256927, currency="250", currencytype=3316}, colors={"Forest Green","Teal"}, budgetCost=1, size="Small"},
      {decorID=11333, source={type="vendor", itemID=256933, currency="250", currencytype=3316}, colors={"Forest Green","Teal"}, budgetCost=1, size="Small"},
      {decorID=11334, source={type="vendor", itemID=256934, currency="250", currencytype=3316}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=11936, source={type="vendor", itemID=258290, currency="250", currencytype=3316}, colors={"Forest Green","Green","Teal"}, budgetCost=1, size="Small"},
      {decorID=12154, source={type="vendor", itemID=258549, currency="250", currencytype=3316}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=14204, source={type="vendor", itemID=260202, currency="500", currencytype=3316}, colors={"Dark Gray","Dark Purple","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=14350, source={type="vendor", itemID=260514, currency="500", currencytype=3316}, colors={"Dark Brown","Light Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=14351, source={type="vendor", itemID=260515, currency="500", currencytype=3316}, colors={"Dark Gray","Olive"}, budgetCost=1, size="Small"},
      {decorID=14352, source={type="vendor", itemID=260516, currency="500", currencytype=3316}, colors={"Dark Brown","Dark Gray","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=15158, source={type="vendor", itemID=263318, currency="150", currencytype=3316}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=15160, source={type="vendor", itemID=263320, currency="150", currencytype=3316}, colors={"Dark Brown","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=15571, source={type="vendor", itemID=264333, currency="150", currencytype=3316}, colors={"Dark Brown","Dark Gray","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=15596, source={type="vendor", itemID=264350, currency="250", currencytype=3316}, colors={"Forest Green","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=240838,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4346:4742"
    },
    items={
      {decorID=1198, source={type="vendor", itemID=245290, currency="250", currencytype=3316}, colors={"Brown","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1896, source={type="vendor", itemID=245941, currency="500", currencytype=3316}, colors={"Copper","Dark Brown","Orange"}, budgetCost=3, size="Medium"},
      {decorID=1901, source={type="vendor", itemID=245985, currency="250", currencytype=3316}, colors={"Copper","Cyan","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=5564, source={type="vendor", itemID=249559, costs={{currency="100", currencytype=3379},{currency="500", currencytype=3316}}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=5, size="Huge"},
      {decorID=10944, source={type="vendor", itemID=256040, currency="250", currencytype=3316}, colors={"Dark Brown","Tan","Teal"}, budgetCost=1, size="Medium"},
      {decorID=11502, source={type="vendor", itemID=257421, currency="500", currencytype=3316}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=11503, source={type="vendor", itemID=257422, currency="250", currencytype=3316}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=14971, source={type="vendor", itemID=263205, currency="250", currencytype=3316}, colors={"Crimson","Deep Red","Orange"}, budgetCost=1, size="Small"},
      {decorID=14972, source={type="vendor", itemID=263206, currency="250", currencytype=3316}, colors={"Light Brown","Orange","Purple"}, budgetCost=3, size="Medium"},
      {decorID=14979, source={type="vendor", itemID=263216, currency="150", currencytype=3379}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=14985, source={type="vendor", itemID=263223, currency="250", currencytype=3316}, colors={"Copper","Cyan","Navy Blue"}, budgetCost=3, size="Medium"},
      {decorID=15059, source={type="vendor", itemID=263228, currency="500", currencytype=3316}, colors={"Crimson","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=15060, source={type="vendor", itemID=263229, currency="250", currencytype=3316}, colors={"Crimson","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=15063, source={type="vendor", itemID=263232, currency="250", currencytype=3316}, colors={"Copper","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=15065, source={type="vendor", itemID=263234, currency="500", currencytype=3316}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=15499, source={type="vendor", itemID=264264, currency="250", currencytype=3316}, colors={"Bronze","Copper","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=15500, source={type="vendor", itemID=264265, currency="250", currencytype=3316}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=241451,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4364:5147"
    },
    items={
      {decorID=15403, source={type="vendor", itemID=263998, currency="50000", currencytype="money"}, requirements={achievement={id=42792}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=241453,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4347:5374"
    },
    items={
      {decorID=15406, source={type="vendor", itemID=264001}, requirements={achievement={id=42798}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=241928,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:3156:2626"
    },
    items={
      {decorID=11323, source={type="vendor", itemID=256923, currency="3200", currencytype=3377}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=15484, source={type="vendor", itemID=264249, currency="1600", currencytype=3377}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=15489, source={type="vendor", itemID=264254, currency="3200", currencytype=3377}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=15851, source={type="vendor", itemID=264655, currency="3200", currencytype=3377}, colors={"Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=242398,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5276:7790"
    },
    items={
      {decorID=2503, source={type="vendor", itemID=246779}, colors={"Copper","Cyan","Navy Blue"}, budgetCost=3, size="Medium"},
      {decorID=7780, source={type="vendor", itemID=250770}, colors={"Brown","Copper","Tan"}, budgetCost=3, size="Medium"},
      {decorID=24765, source={type="vendor", itemID=275857}, budgetCost=3, size="Medium"},
      {decorID=25296, source={type="vendor", itemID=275853}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=242399,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5253:7887"
    },
    items={
      {decorID=15399, source={type="vendor", itemID=263994, currency="10", currencytype=3316}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=15400, source={type="vendor", itemID=263995, currency="10", currencytype=3316}, colors={"Dark Brown","Dark Gray","Dark Purple"}, budgetCost=3, size="Medium"},
      {decorID=15401, source={type="vendor", itemID=263996, currency="10", currencytype=3316}, colors={"Dark Gray","Teal"}, budgetCost=3, size="Medium"},
      {decorID=15412, source={type="vendor", itemID=264007, currency="10", currencytype=3316}, colors={"Dark Gray","Royal Blue","Tan"}, budgetCost=3, size="Medium"},
      {decorID=15413, source={type="vendor", itemID=264008, currency="10", currencytype=3316}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=15455, source={type="vendor", itemID=264170, currency="10", currencytype=3316}, colors={"Dark Gray","Gray","Silver"}, budgetCost=3, size="Medium"},
      {decorID=15460, source={type="vendor", itemID=264175, currency="10", currencytype=3316}, colors={"Dark Brown","Olive"}, budgetCost=3, size="Medium"},
      {decorID=21951, source={type="vendor", itemID=272360}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=242723,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4352:4752"
    },
    items={
      {decorID=14995, source={type="vendor", itemID=263224, currency="100", currencytype=3379}, colors={"Dark Brown","Light Purple","Orange"}, budgetCost=1, size="Small"},
      {decorID=15013, source={type="vendor", itemID=263225, currency="100", currencytype=3379}, colors={"Bronze","Dark Brown","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=242724,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4344:4756"
    },
    items={
      {decorID=5564, source={type="vendor", itemID=249559, costs={{currency="100", currencytype=3379},{currency="500", currencytype=3316}}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=5, size="Huge"},
      {decorID=14978, source={type="vendor", itemID=263212, currency="100", currencytype=3379}, colors={"Dark Gray","Dark Purple","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=14979, source={type="vendor", itemID=263216, currency="150", currencytype=3379}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=242724,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4352:4752"
    },
    items={
      {decorID=14641, source={type="vendor", itemID=262616, currency="100", currencytype=3379}, colors={"Dark Brown","Tan","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=242725,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4354:4750"
    },
    items={
      {decorID=14970, source={type="vendor", itemID=263203, currency="100", currencytype=3379}, colors={"Amber","Copper","Dark Brown"}, budgetCost=3, size="Medium"},
--       {decorID=15505, source={type="vendor", itemID=264270}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"}, -- DNT / do not use
    }
  },

  {
    source={
      id=242725,
      type="vendor",
      faction="Neutral",
      zone="Satheril's Haven, Eversong Woods",
      worldmap=""
    },
    items={
--       {decorID=5564, source={type="vendor", itemID=249559, costs={{currency="100", currencytype=3379},{currency="500", currencytype=3316}}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=5, size="Huge"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=242726,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4349:4765"
    },
    items={
      {decorID=2459, source={type="vendor", itemID=246692, currency="100", currencytype=3379}, colors={"Amber","Light Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=7782, source={type="vendor", itemID=250772, currency="100", currencytype=3379}, colors={"Brown","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=243350,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4792:5344"
    },
    items={
      {decorID=15405, source={type="vendor", itemID=264000}, requirements={achievement={id=42787}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=243353,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4823:5431"
    },
    items={
      {decorID=15459, source={type="vendor", itemID=264174, currency="50000", currencytype="money"}, requirements={achievement={id=42794}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=243359,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4704:5166"
    },
    items={
      {decorID=15402, source={type="vendor", itemID=263997}, requirements={achievement={id=42788}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=243531,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4304:5599"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=243555,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4667:5119"
    },
    items={
      {decorID=15409, source={type="vendor", itemID=264004}, requirements={achievement={id=42796}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=250982,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5220:4740"
    },
    items={
      {decorID=714, source={type="vendor", itemID=245284, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, colors={"Dark Brown","Purple","Tan"}, requirements={rep="true"}, budgetCost=1, size="Small"},
      {decorID=1227, source={type="vendor", itemID=251997, costs={{currency="5000", currencytype=2815},{currency="75", currencytype=3319}}}, colors={"Crimson","Dark Brown","Tan"}, requirements={rep="true"}, budgetCost=3, size="Medium"},
      {decorID=1236, source={type="vendor", itemID=245330, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, colors={"Bronze","Dark Brown","Gold"}, requirements={rep="true"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=251091,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5072:5608"
    },
    items={
      {decorID=11499, source={type="vendor", itemID=257418, currency="750", currencytype=3316}, requirements={quest={id=92025}, rep="true"}, colors={"Copper","Cyan","Navy Blue"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=252915,
      type="vendor",
      faction="Neutral",
      zone="The Bazaar, Silvermoon City",
      worldmap="2393:4420:6240"
    },
    items={
      {decorID=9479, source={type="vendor", itemID=253602, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Gray"}, budgetCost=1, size="Small"},
      {decorID=9480, source={type="vendor", itemID=253603, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Gray"}, budgetCost=1, size="Small"},
      {decorID=9481, source={type="vendor", itemID=253604, currency="50000000", currencytype="money"}, colors={"Amber","Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=9482, source={type="vendor", itemID=253605, currency="50000000", currencytype="money"}, colors={"Bronze","Dark Brown","Dark Purple"}, budgetCost=1, size="Small"},
      {decorID=9484, source={type="vendor", itemID=253607, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=9485, source={type="vendor", itemID=253608, currency="50000000", currencytype="money"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Small"},
      {decorID=9491, source={type="vendor", itemID=253614, currency="50000000", currencytype="money"}, colors={"Dark Brown","Tan","Teal"}, budgetCost=1, size="Small"},
      {decorID=9492, source={type="vendor", itemID=253615, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=9493, source={type="vendor", itemID=253616, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=9494, source={type="vendor", itemID=253617, currency="50000000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=9495, source={type="vendor", itemID=253618, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=9496, source={type="vendor", itemID=253619, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=9497, source={type="vendor", itemID=253620, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Royal Blue"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=252916,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4405:6276"
    },
    items={
      {decorID=1446, source={type="vendor", itemID=244656, currency="1500000", currencytype="money"}, requirements={achievement={id=62185}}, colors={"Dark Purple","Light Brown","Purple"}, budgetCost=1, size="Small"},
      {decorID=9483, source={type="vendor", itemID=253606, currency="15000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Light Gray"}, budgetCost=1, size="Small"},
      {decorID=9486, source={type="vendor", itemID=253609, currency="15000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=9487, source={type="vendor", itemID=253610, currency="15000000", currencytype="money"}, colors={"Light Gray","Purple","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=9488, source={type="vendor", itemID=253611, currency="15000000", currencytype="money"}, colors={"Olive","Royal Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=9489, source={type="vendor", itemID=253612, currency="15000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=9490, source={type="vendor", itemID=253613, currency="15000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=9628, source={type="vendor", itemID=253704, currency="15000000", currencytype="money"}, colors={"Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=9629, source={type="vendor", itemID=253705, currency="15000000", currencytype="money"}, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=253035,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:3847:2245"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=254944,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap=""
    },
    items={
--       {decorID=26203, source={type="vendor", itemID=278691}, budgetCost=5, size="Large"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=254944,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4604:6608"
    },
    items={
      {decorID=1148, source={type="vendor", itemID=253469, currency="250", currencytype=3316}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=10858, source={type="vendor", itemID=255648, currency="500", currencytype=3316}, colors={"Dark Gray","Teal"}, budgetCost=5, size="Huge"},
      {decorID=11325, source={type="vendor", itemID=256925, currency="250", currencytype=3316}, requirements={achievement={id=62289}}, colors={"Dark Brown","Light Brown","Olive"}, budgetCost=1, size="Large"},
      {decorID=11328, source={type="vendor", itemID=256928, currency="250", currencytype=3316}, requirements={quest={id=91087}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Large"},
      {decorID=15490, source={type="vendor", itemID=264255, currency="250", currencytype=3316}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=15492, source={type="vendor", itemID=264257, currency="250", currencytype=3316}, colors={"Dark Brown","Olive","Teal"}, budgetCost=3, size="Medium"},
      {decorID=15572, source={type="vendor", itemID=264334, currency="250", currencytype=3316}, colors={"Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=15573, source={type="vendor", itemID=264335, currency="500", currencytype=3316}, requirements={achievement={id=62122}}, colors={"Dark Gray","Olive","Teal"}, budgetCost=5, size="Large"},
      {decorID=15743, source={type="vendor", itemID=264479, currency="250", currencytype=3316}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=15744, source={type="vendor", itemID=264480, currency="250", currencytype=3316}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=15745, source={type="vendor", itemID=264481, currency="250", currencytype=3316}, colors={"Dark Brown","Teal"}, budgetCost=3, size="Large"},
      {decorID=16092, source={type="vendor", itemID=264715, currency="250", currencytype=3316}, colors={"Dark Brown","Gray","Red"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=255095,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4522:6984"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
      {decorID=15458, source={type="vendor", itemID=264173}, requirements={achievement={id=42790}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255098,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4532:6983"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255474,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4860:4940"
    },
    items={
      {decorID=15403, source={type="vendor", itemID=263998, currency="50000", currencytype="money"}, requirements={achievement={id=42792}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255495,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4768:5055"
    },
    items={
      {decorID=21598, source={type="vendor", itemID=271158, currency="50", currencytype=3405}, colors={"Cyan","Dark Purple","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=22143, source={type="vendor", itemID=273159, currency="32", currencytype=3405}, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=22181, source={type="vendor", itemID=273135, currency="8", currencytype=3405}, colors={"Light Purple","Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=22182, source={type="vendor", itemID=273142, currency="8", currencytype=3405}, colors={"Cyan","Light Purple","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=22183, source={type="vendor", itemID=273157, currency="8", currencytype=3405}, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=22388, source={type="vendor", itemID=273147, currency="8", currencytype=3405}, colors={"Black","Dark Purple","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=25307, source={type="vendor", itemID=276083}, requirements={achievement={id=63325}}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=256009,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4315:5537"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
      {decorID=15458, source={type="vendor", itemID=264173}, requirements={achievement={id=42790}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=256026,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4830:5131"
    },
    items={
      {decorID=15408, source={type="vendor", itemID=264003}, requirements={achievement={id=42793}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=256828,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5117:5645"
    },
    items={
      {decorID=11287, source={type="vendor", itemID=256764}, budgetCost=1, size="Small"},
      {decorID=12244, source={type="vendor", itemID=259044}, dyeable=true, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12245, source={type="vendor", itemID=259045}, dyeable=true, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=12246, source={type="vendor", itemID=259046}, dyeable=true, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=12247, source={type="vendor", itemID=259055}, colors={"Beige","Copper","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=12248, source={type="vendor", itemID=259056}, colors={"Dark Gray","Red","Tan"}, budgetCost=3, size="Large"},
      {decorID=12249, source={type="vendor", itemID=259057}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=12250, source={type="vendor", itemID=259058}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=12251, source={type="vendor", itemID=259059}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12252, source={type="vendor", itemID=259060}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12253, source={type="vendor", itemID=259061}, colors={"Black"}, budgetCost=1, size="Tiny"},
      {decorID=12254, source={type="vendor", itemID=259062}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12255, source={type="vendor", itemID=259063}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12256, source={type="vendor", itemID=259064}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12257, source={type="vendor", itemID=259065}, colors={"Beige","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12258, source={type="vendor", itemID=259066}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=12259, source={type="vendor", itemID=259067}, colors={"Beige","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12260, source={type="vendor", itemID=259068}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=12261, source={type="vendor", itemID=259069}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
      {decorID=12262, source={type="vendor", itemID=259070}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=12264, source={type="vendor", itemID=259093}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=12265, source={type="vendor", itemID=259094}, dyeable=true, colors={"Bronze","Dark Brown","Royal Blue"}, budgetCost=1, size="Medium"},
      {decorID=14467, source={type="vendor", itemID=260785, costs={{currency="15000000", currencytype="money"},{currency="13500000", currencytype="money"}}}, requirements={achievement={id=62387}}, colors={"Dark Gray","Forest Green","Tan"}, budgetCost=5, size="Huge"},
      {decorID=15148, source={type="vendor", itemID=263298, currency="5000000", currencytype="money"}, colors={"Navy Blue","Olive","Royal Blue"}, budgetCost=1, size="Tiny"},
      {decorID=15149, source={type="vendor", itemID=263299, currency="5000000", currencytype="money"}, colors={"Crimson","Dark Gray","Deep Red"}, budgetCost=1, size="Tiny"},
      {decorID=15151, source={type="vendor", itemID=263301, currency="5000000", currencytype="money"}, colors={"Brown","Dark Brown","Green"}, budgetCost=1, size="Tiny"},
      {decorID=15229, source={type="vendor", itemID=263383}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=15547, source={type="vendor", itemID=264275}, dyeable=true, colors={"Copper","Dark Gray","Deep Red"}, budgetCost=1, size="Medium"},
      {decorID=15548, source={type="vendor", itemID=264276}, dyeable=true, colors={"Dark Gray","Deep Red","Tan"}, budgetCost=1, size="Medium"},
      {decorID=15549, source={type="vendor", itemID=264277}, dyeable=true, colors={"Copper","Deep Red","Purple"}, budgetCost=1, size="Medium"},
      {decorID=15550, source={type="vendor", itemID=264278}, dyeable=true, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Medium"},
      {decorID=15551, source={type="vendor", itemID=264279}, dyeable=true, colors={"Blue","Cyan","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=15552, source={type="vendor", itemID=264280}, dyeable=true, colors={"Brown","Dark Brown","Dark Gray"}, budgetCost=1, size="Tiny"},
      {decorID=15553, source={type="vendor", itemID=264281}, colors={"Bronze","Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=15554, source={type="vendor", itemID=264282}, colors={"Bronze","Dark Brown","Dark Purple"}, budgetCost=1, size="Small"},
      {decorID=15555, source={type="vendor", itemID=264283}, colors={"Dark Gray","Silver","Tan"}, budgetCost=1, size="Small"},
      {decorID=15668, source={type="vendor", itemID=264396, currency="5000000", currencytype="money"}, dyeable=true, colors={"Gray","Royal Blue","Silver"}, budgetCost=1, size="Small"},
      {decorID=15669, source={type="vendor", itemID=264397}, dyeable=true, colors={"Dark Brown","Navy Blue","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=257633,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2437:1737:3808"
    },
    items={
      {decorID=11323, source={type="vendor", itemID=256923, currency="3200", currencytype=3377}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=15484, source={type="vendor", itemID=264249, currency="1600", currencytype=3377}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=15489, source={type="vendor", itemID=264254, currency="3200", currencytype=3377}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=15851, source={type="vendor", itemID=264655, currency="3200", currencytype=3377}, colors={"Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=257914,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5644:6991"
    },
    items={
      {decorID=15404, source={type="vendor", itemID=263999, currency="50000", currencytype="money"}, requirements={achievement={id=42795}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=258181,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5579:6605"
    },
    items={
      {decorID=17439, source={type="vendor", itemID=265681, currency="1200", currencytype=3392}, requirements={achievement={id=62167}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17440, source={type="vendor", itemID=265682, currency="1200", currencytype=3392}, requirements={achievement={id=62168}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17441, source={type="vendor", itemID=265683, currency="1200", currencytype=3392}, requirements={achievement={id=62173}}, colors={"Bronze","Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17442, source={type="vendor", itemID=265684, currency="1200", currencytype=3392}, requirements={achievement={id=62174}}, colors={"Black","Dark Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17443, source={type="vendor", itemID=265685, currency="1200", currencytype=3392}, requirements={achievement={id=62175}}, colors={"Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17444, source={type="vendor", itemID=265686, currency="1200", currencytype=3392}, requirements={achievement={id=62177}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17446, source={type="vendor", itemID=265687, currency="1200", currencytype=3392}, requirements={achievement={id=62178}}, colors={"Dark Brown","Dark Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17447, source={type="vendor", itemID=265688, currency="1200", currencytype=3392}, requirements={achievement={id=62179}}, colors={"Bronze","Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17449, source={type="vendor", itemID=265689, currency="1200", currencytype=3392}, requirements={achievement={id=62180}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17450, source={type="vendor", itemID=265690, currency="1200", currencytype=3392}, requirements={achievement={id=62181}}, colors={"Black","Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17452, source={type="vendor", itemID=265691, currency="1200", currencytype=3392}, requirements={achievement={id=62182}}, colors={"Bronze","Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17453, source={type="vendor", itemID=265692, currency="1200", currencytype=3392}, requirements={achievement={id=62183}}, colors={"Dark Brown","Deep Red","Red"}, budgetCost=3, size="Medium"},
      {decorID=17454, source={type="vendor", itemID=265694, currency="1200", currencytype=3392}, requirements={achievement={id=62184}}, colors={"Dark Brown","Deep Red","Red"}, budgetCost=3, size="Medium"},
      {decorID=17455, source={type="vendor", itemID=265696, currency="800", currencytype=3392}, requirements={achievement={id=62144}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17456, source={type="vendor", itemID=265697, currency="800", currencytype=3392}, requirements={achievement={id=62153}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17457, source={type="vendor", itemID=265698, currency="800", currencytype=3392}, requirements={achievement={id=62155}}, colors={"Dark Brown","Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17458, source={type="vendor", itemID=265699, currency="800", currencytype=3392}, requirements={achievement={id=62156}}, colors={"Dark Brown","Light Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17459, source={type="vendor", itemID=265700, currency="800", currencytype=3392}, requirements={achievement={id=62157}}, colors={"Copper","Deep Red","Red"}, budgetCost=3, size="Medium"},
      {decorID=17460, source={type="vendor", itemID=265701, currency="800", currencytype=3392}, requirements={achievement={id=62159}}, colors={"Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17462, source={type="vendor", itemID=265702, currency="800", currencytype=3392}, requirements={achievement={id=62160}}, colors={"Dark Brown","Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17464, source={type="vendor", itemID=265703, currency="800", currencytype=3392}, requirements={achievement={id=62161}}, colors={"Dark Brown","Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17465, source={type="vendor", itemID=265704, currency="800", currencytype=3392}, requirements={achievement={id=62162}}, colors={"Dark Brown","Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17467, source={type="vendor", itemID=265705, currency="800", currencytype=3392}, requirements={achievement={id=62163}}, colors={"Copper","Deep Red","Red"}, budgetCost=3, size="Medium"},
      {decorID=17469, source={type="vendor", itemID=265706, currency="800", currencytype=3392}, requirements={achievement={id=62164}}, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=17472, source={type="vendor", itemID=265707, currency="800", currencytype=3392}, requirements={achievement={id=62165}}, colors={"Copper","Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17474, source={type="vendor", itemID=265708, currency="800", currencytype=3392}, requirements={achievement={id=62166}}, colors={"Dark Brown","Deep Red","Red"}, budgetCost=3, size="Medium"},
      {decorID=17518, source={type="vendor", itemID=265794, currency="800", currencytype=3392}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=17519, source={type="vendor", itemID=265795, currency="1200", currencytype=3392}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=17520, source={type="vendor", itemID=265796, currency="1200", currencytype=3392}, requirements={achievement={id=62169}}, colors={"Dark Brown","Deep Red","Red"}, budgetCost=3, size="Medium"},
      {decorID=17521, source={type="vendor", itemID=265797, currency="1200", currencytype=3392}, requirements={achievement={id=62176}}, colors={"Dark Brown","Red"}, budgetCost=3, size="Medium"},
      {decorID=17522, source={type="vendor", itemID=265798, currency="800", currencytype=3392}, requirements={achievement={id=62154}}, colors={"Deep Red","Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=17523, source={type="vendor", itemID=265799, currency="800", currencytype=3392}, requirements={achievement={id=62158}}, colors={"Dark Brown","Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=22145, source={type="vendor", itemID=278369}, requirements={achievement={id=63451}}, budgetCost=3, size="Medium"},
      {decorID=22146, source={type="vendor", itemID=278372}, requirements={achievement={id=63452}}, budgetCost=3, size="Medium"},
      {decorID=24891, source={type="vendor", itemID=278380}, requirements={achievement={id=63453}}, budgetCost=3, size="Medium"},
      {decorID=25274, source={type="vendor", itemID=278130}, budgetCost=1, size="Small"},
      {decorID=25279, source={type="vendor", itemID=278151}, budgetCost=3, size="Medium"},
      {decorID=25284, source={type="vendor", itemID=278134}, budgetCost=1, size="Small"},
      {decorID=25286, source={type="vendor", itemID=278123}, budgetCost=1, size="Small"},
      {decorID=25287, source={type="vendor", itemID=278148}, budgetCost=1, size="Small"},
      {decorID=25288, source={type="vendor", itemID=278145}, budgetCost=5, size="Large"},
      {decorID=25289, source={type="vendor", itemID=278126}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=258885,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:3867:2374"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=259864,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2437:0314:1871"
    },
    items={
      {decorID=1159, source={type="vendor", itemID=253485, currency="250", currencytype=3316}, requirements={quest={id=90493}}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=1160, source={type="vendor", itemID=253488, currency="250", currencytype=3316}, requirements={quest={id=90493}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=1, size="Medium"},
      {decorID=1173, source={type="vendor", itemID=243106, currency="250", currencytype=3316}, colors={"Copper","Dark Brown","Orange"}, budgetCost=1, size="Small"},
      {decorID=1195, source={type="vendor", itemID=245282, currency="250", currencytype=3316}, colors={"Dark Brown","Deep Red","Orange"}, budgetCost=3, size="Medium"},
      {decorID=1442, source={type="vendor", itemID=244538, currency="250", currencytype=3316}, requirements={quest={id=86650}}, colors={"Amber","Copper","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=1489, source={type="vendor", itemID=244783, currency="500", currencytype=3316}, requirements={quest={id=90907}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Large"},
      {decorID=1908, source={type="vendor", itemID=245992, currency="250", currencytype=3316}, requirements={quest={id=86741}}, colors={"Bronze","Dark Brown","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=2299, source={type="vendor", itemID=246458}, colors={"Light Brown","Light Purple","Navy Blue"}, budgetCost=5, size="Huge"},
      {decorID=8872, source={type="vendor", itemID=251909, currency="150", currencytype=3316}, requirements={achievement={id=62186}}, colors={"Beige","Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=8874, source={type="vendor", itemID=251911, currency="150", currencytype=3316}, colors={"Beige","Bronze","Brown"}, budgetCost=1, size="Small"},
      {decorID=8875, source={type="vendor", itemID=251912, currency="150", currencytype=3316}, colors={"Beige","Olive","Purple"}, budgetCost=1, size="Small"},
      {decorID=8877, source={type="vendor", itemID=251914}, colors={"Beige","Bronze","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=10542, source={type="vendor", itemID=254773, currency="250", currencytype=3316}, requirements={achievement={id=62288}}, colors={"Bronze","Dark Brown","Gold"}, budgetCost=1, size="Medium"},
      {decorID=11470, source={type="vendor", itemID=257367, currency="250", currencytype=3316}, requirements={achievement={id=61507}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=14635, source={type="vendor", itemID=262610, currency="250", currencytype=3316}, colors={"Blue","Navy Blue","Teal"}, budgetCost=3, size="Medium"},
      {decorID=14977, source={type="vendor", itemID=263211, currency="150", currencytype=3316}, colors={"Cyan","Tan","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=15062, source={type="vendor", itemID=263231, currency="500", currencytype=3316}, requirements={quest={id=86735}}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Large"},
      {decorID=15483, source={type="vendor", itemID=264248, currency="150", currencytype=3316}, requirements={quest={id=86739}}, colors={"Bronze","Brown","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=15895, source={type="vendor", itemID=264660, currency="500", currencytype=3316}, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=16691, source={type="vendor", itemID=265106}, colors={"Bronze","Dark Brown"}, budgetCost=5, size="Huge"},
      {decorID=17294, source={type="vendor", itemID=265631}, colors={"Copper","Dark Brown","Orange"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=260180,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:6828:2027"
    },
    items={
      {decorID=12140, source={type="vendor", itemID=258535}, colors={"Dark Brown","Green","Teal"}, budgetCost=1, size="Medium"},
      {decorID=12141, source={type="vendor", itemID=258536}, colors={"Dark Brown","Tan","Teal"}, budgetCost=3, size="Medium"},
      {decorID=12142, source={type="vendor", itemID=258537}, colors={"Dark Brown","Green","Teal"}, budgetCost=3, size="Medium"},
      {decorID=12143, source={type="vendor", itemID=258538}, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=15486, source={type="vendor", itemID=264251}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Large"},
      {decorID=15487, source={type="vendor", itemID=264252}, colors={"Dark Brown","Forest Green"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=264056,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:3163:7667"
    },
    items={
      {decorID=19763, source={type="vendor", itemID=268457, currency="100", currencytype=3316}, colors={"Bronze","Dark Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=21079, source={type="vendor", itemID=269613, currency="100", currencytype=3316}, colors={"Bronze","Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=21080, source={type="vendor", itemID=269614, currency="50", currencytype=3316}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=21101, source={type="vendor", itemID=269636, currency="50", currencytype=3316}, colors={"Bronze","Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=21106, source={type="vendor", itemID=269641, currency="100", currencytype=3316}, dyeable=true, colors={"Bronze","Dark Brown","Gray"}, budgetCost=3, size="Medium"},
      {decorID=21602, source={type="vendor", itemID=271162, currency="200", currencytype=3316}, colors={"Blue","Bronze","Brown"}, budgetCost=5, size="Large"},
      {decorID=22006, source={type="vendor", itemID=272441, currency="50", currencytype=3316}, colors={"Dark Brown","Dark Gray","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=22007, source={type="vendor", itemID=272442, currency="50", currencytype=3316}, colors={"Blue","Dark Brown","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=22008, source={type="vendor", itemID=272443, currency="50", currencytype=3316}, colors={"Dark Brown","Forest Green","Teal"}, budgetCost=1, size="Small"},
      {decorID=22009, source={type="vendor", itemID=272444, currency="100", currencytype=3316}, colors={"Light Purple","Navy Blue","Royal Blue"}, budgetCost=1, size="Large"},
      {decorID=22010, source={type="vendor", itemID=272445, currency="50", currencytype=3316}, colors={"Light Purple","Navy Blue","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=22011, source={type="vendor", itemID=272446, currency="200", currencytype=3316}, colors={"Light Purple","Navy Blue","Royal Blue"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=265581,
      type="vendor",
      faction="Neutral",
      zone="Naigtal",
      worldmap=""
    },
    items={
--       {decorID=18802, source={type="vendor", itemID=267211, currency="150", currencytype=3316}, colors={"Dark Brown","Olive","Tan"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
--       {decorID=25564, source={type="vendor", itemID=276321}, budgetCost=5, size="Large"}, -- missing verified worldmap
--       {decorID=25566, source={type="vendor", itemID=276316}, budgetCost=5, size="Huge"}, -- missing verified worldmap
--       {decorID=25665, source={type="vendor", itemID=276429}, budgetCost=5, size="Large"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=265581,
      type="vendor",
      faction="Neutral",
      zone="Val",
      worldmap=""
    },
    items={
--       {decorID=25565, source={type="vendor", itemID=276318}, budgetCost=5, size="Large"}, -- missing verified worldmap
--       {decorID=25664, source={type="vendor", itemID=276432}, budgetCost=5, size="Huge"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=267859,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:3934:5913"
    },
    items={
      {decorID=23706, source={type="vendor", itemID=274731}, budgetCost=1, size="Small"},
      {decorID=24193, source={type="vendor", itemID=274734}, budgetCost=1, size="Small"},
      {decorID=24194, source={type="vendor", itemID=274736}, budgetCost=1, size="Small"},
    }
  },

}
