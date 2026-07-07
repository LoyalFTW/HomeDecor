local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Warlords"] = NS.Data.Vendors["Warlords"] or {}

NS.Data.Vendors["Warlords"]["Draenor"] = {

  {
    source={
      id=76872,
      type="vendor",
      faction="Neutral",
      zone="Frostwall",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=1416, source={type="vendor", itemID=244324, currency="150", currencytype=824}, colors={"Crimson","Dark Gray","Tan"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=78564,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="582:3850:3140"
    },
    items={
      {decorID=4403, source={type="vendor", itemID=248334, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=36404}}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=4404, source={type="vendor", itemID=248335, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, requirements={quest={id=36202}}, colors={"Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=4485, source={type="vendor", itemID=248660, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=34192}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=4486, source={type="vendor", itemID=248661, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=36592}}, colors={"Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=4816, source={type="vendor", itemID=248799, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, requirements={quest={id=34586}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=4818, source={type="vendor", itemID=248800, currency="1500", currencytype=824}, requirements={quest={id=36615}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=4844, source={type="vendor", itemID=248810, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, requirements={quest={id=35176}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=79774,
      type="vendor",
      faction="Neutral",
      zone="Frostwall",
      worldmap="590:4380:4740"
    },
    items={
      {decorID=1318, source={type="vendor", itemID=245438, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=824}}}, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1353, source={type="vendor", itemID=245443, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=34586}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1407, source={type="vendor", itemID=244315, currency="1500", currencytype=824}, requirements={quest={id=36614}}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Large"},
      {decorID=1408, source={type="vendor", itemID=244316, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=34192}}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1412, source={type="vendor", itemID=244320, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, colors={"Dark Gray","Navy Blue","Silver"}, budgetCost=1, size="Tiny"},
      {decorID=1443, source={type="vendor", itemID=244653, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=36592}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=79812,
      type="vendor",
      faction="Neutral",
      zone="Frostwall",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=1326, source={type="vendor", itemID=245437, costs={{currency="75", itemID=113681}}}, colors={"Dark Gray","Gray","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=1352, source={type="vendor", itemID=245442, currency="100", currencytype=824}, colors={"Dark Brown","Light Brown"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=81133,
      type="vendor",
      faction="Neutral",
      zone="Shadowmoon Valley (Draenor)",
      worldmap="539:4620:3930"
    },
    items={
      {decorID=11451, source={type="vendor", itemID=257349, costs={{currency="2000000", currencytype="money"},{currency="300", currencytype=824}}}, colors={"Dark Purple","Light Purple","Purple"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=85427,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="539:3100:1500"
    },
    items={
      {decorID=931, source={type="vendor", itemID=245424, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=823}}}, colors={"Bronze","Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=8235, source={type="vendor", itemID=251544, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=823}}}, colors={"Dark Gray","Light Purple","Purple"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=85932,
      type="vendor",
      faction="Alliance",
      zone="Stormshield",
      worldmap="622:4640:7460"
    },
    items={
      {decorID=927, source={type="vendor", itemID=245423, currency="250", currencytype=824}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray","Light Purple"}, budgetCost=3, size="Medium"},
      {decorID=8185, source={type="vendor", itemID=251476, currency="1000", currencytype=824}, requirements={rep="true"}, colors={"Dark Gray","Dark Purple","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=8188, source={type="vendor", itemID=251479, currency="1500", currencytype=824}, requirements={rep="true"}, colors={"Dark Gray","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=8190, source={type="vendor", itemID=251481, currency="500", currencytype=824}, requirements={rep="true"}, colors={"Blue","Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=8192, source={type="vendor", itemID=251483, currency="250", currencytype=824}, requirements={rep="true"}, colors={"Dark Brown","Dark Purple","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=8193, source={type="vendor", itemID=251484, currency="1000", currencytype=824}, requirements={rep="true"}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=5, size="Large"},
      {decorID=8194, source={type="vendor", itemID=251493, currency="500", currencytype=824}, requirements={rep="true"}, colors={"Dark Gray","Gray","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=8242, source={type="vendor", itemID=251551, currency="1500", currencytype=824}, requirements={rep="true"}, colors={"Copper","Dark Gray","Purple"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=85946,
      type="vendor",
      faction="Neutral",
      zone="Stormshield",
      worldmap=""
    },
    items={
--       {decorID=12203, source={type="vendor", itemID=258743, currency="80000", currencytype="money"}, requirements={rep="true"}, colors={"Amber","Dark Brown","Olive"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
--       {decorID=12206, source={type="vendor", itemID=258746, currency="80000", currencytype="money"}, requirements={rep="true"}, colors={"Copper","Dark Brown","Olive"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
--       {decorID=12207, source={type="vendor", itemID=258747, currency="80000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Light Brown","Orange"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=85950,
      type="vendor",
      faction="Neutral",
      zone="Stormshield",
      worldmap="622:4097:5954"
    },
    items={
      {decorID=928, source={type="vendor", itemID=245425, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=823}}}, requirements={quest={id=35396}}, colors={"Dark Purple","Magenta","Purple"}, budgetCost=1, size="Small"},
      {decorID=8177, source={type="vendor", itemID=251330, costs={{currency="1000000", currencytype="money"},{currency="300", currencytype=823}}}, requirements={quest={id=34792}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Medium"},
      {decorID=8186, source={type="vendor", itemID=251477, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=824}}}, requirements={quest={id=36169}}, colors={"Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=8187, source={type="vendor", itemID=251478}, requirements={quest={id=35196}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=8239, source={type="vendor", itemID=251548, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=823}}}, requirements={quest={id=34792}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Medium"},
      {decorID=8240, source={type="vendor", itemID=251549, currency="2000", currencytype=824}, requirements={quest={id=37322}}, colors={"Dark Brown","Dark Purple","Purple"}, budgetCost=5, size="Large"},
      {decorID=8772, source={type="vendor", itemID=251640, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=823}}}, requirements={quest={id=34099}}, colors={"Dark Brown","Gray","Red"}, budgetCost=3, size="Medium"},
      {decorID=8785, source={type="vendor", itemID=251653, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=824}}}, requirements={quest={id=35685}}, colors={"Dark Gray","Magenta","Purple"}, budgetCost=5, size="Large"},
      {decorID=8786, source={type="vendor", itemID=251654, costs={{currency="8000000", currencytype="money"},{currency="2000", currencytype=823}}}, requirements={quest={id=33256}}, colors={"Dark Gray","Gray","Royal Blue"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=86037,
      type="vendor",
      faction="Neutral",
      zone="Warspear",
      worldmap=""
    },
    items={
--       {decorID=12203, source={type="vendor", itemID=258743, currency="80000", currencytype="money"}, requirements={rep="true"}, colors={"Amber","Dark Brown","Olive"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
--       {decorID=12206, source={type="vendor", itemID=258746, currency="80000", currencytype="money"}, requirements={rep="true"}, colors={"Copper","Dark Brown","Olive"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
--       {decorID=12207, source={type="vendor", itemID=258747, currency="80000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Light Brown","Orange"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=86779,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="539:3100:1500"
    },
    items={
      {decorID=1354, source={type="vendor", itemID=245444, currency="250", currencytype=824}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=1355, source={type="vendor", itemID=245445, currency="150", currencytype=824}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=1413, source={type="vendor", itemID=244321, currency="100", currencytype=824}, colors={"Dark Brown","Gray"}, budgetCost=1, size="Small"},
      {decorID=1414, source={type="vendor", itemID=244322, currency="100", currencytype=824}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=87015,
      type="vendor",
      faction="Horde",
      zone="Frostwall Garrison",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=1317, source={type="vendor", itemID=245431, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=823}}}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=1322, source={type="vendor", itemID=245433, costs={{currency="5000000", currencytype="money"},{currency="1000", currencytype=823}}}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=87312,
      type="vendor",
      faction="Neutral",
      zone="Frostwall",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=751, source={type="vendor", itemID=239162, costs={{currency="500000", currencytype="money"},{currency="100", currencytype=824}}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=87775,
      type="vendor",
      faction="Neutral",
      zone="Spires of Arak",
      worldmap="542:4670:4496"
    },
    items={
      {decorID=12200, source={type="vendor", itemID=258740, currency="80000", currencytype="money"}, requirements={achievement={id=9415}}, colors={"Copper","Dark Brown","Gold"}, budgetCost=1, size="Medium"},
      {decorID=12201, source={type="vendor", itemID=258741, currency="80000", currencytype="money"}, requirements={quest={id=35671}}, colors={"Dark Brown","Light Brown","Purple"}, budgetCost=1, size="Tiny"},
      {decorID=12205, source={type="vendor", itemID=258745, currency="80000", currencytype="money"}, requirements={quest={id=35704}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=12208, source={type="vendor", itemID=258748, currency="80000", currencytype="money"}, requirements={quest={id=35273}}, colors={"Bronze","Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=12209, source={type="vendor", itemID=258749, currency="80000", currencytype="money"}, requirements={quest={id=35896}}, colors={"Copper","Dark Brown","Dark Purple"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=88220,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="539:3100:1500"
    },
    items={
      {decorID=751, source={type="vendor", itemID=239162, costs={{currency="500000", currencytype="money"},{currency="100", currencytype=824}}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=88223,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="582:3773:3589"
    },
    items={
      {decorID=126, source={type="vendor", itemID=245275}, colors={"Dark Gray","Light Purple","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=4403, source={type="vendor", itemID=248334, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=36404}}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=4404, source={type="vendor", itemID=248335, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, requirements={quest={id=36202}}, colors={"Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=4485, source={type="vendor", itemID=248660, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=34192}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=4486, source={type="vendor", itemID=248661, costs={{currency="1600000", currencytype="money"},{currency="300", currencytype=824}}}, requirements={quest={id=36592}}, colors={"Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=4816, source={type="vendor", itemID=248799, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, requirements={quest={id=34586}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=4844, source={type="vendor", itemID=248810, costs={{currency="400000", currencytype="money"},{currency="100", currencytype=824}}}, requirements={quest={id=35176}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=256946,
      type="vendor",
      faction="Neutral",
      zone="Talador",
      worldmap="535:7041:5754"
    },
    items={
      {decorID=12202, source={type="vendor", itemID=258742, currency="100000", currencytype="money"}, requirements={quest={id=33582}}, colors={"Dark Gray","Tan"}, budgetCost=1, size="Tiny"},
    }
  },

}
