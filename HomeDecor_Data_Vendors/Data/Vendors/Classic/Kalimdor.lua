local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["Kalimdor"] = {

  {
    source={
      id=1465,
      type="vendor",
      faction="Alliance",
      zone="Thelsamar, Loch Modan",
      worldmap="48:3560:4900"
    },
    items={
      {decorID=2239, source={type="vendor", itemID=246422, currency="2850000", currencytype="money"}, requirements={quest={id=26868}}, colors={"Dark Gray","Gold","Light Brown"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=2483,
      type="vendor",
      faction="Neutral",
      zone="Nesingwary Expedition",
      worldmap="50:4380:2320"
    },
    items={
      {decorID=4841, source={type="vendor", itemID=248808, currency="4500000", currencytype="money"}, requirements={achievement={id=940}}, colors={"Dark Gray","Olive","Tan"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=23995,
      type="vendor",
      faction="Neutral",
      zone="Mudsprocket, Dustwallow Marsh",
      worldmap="70:4190:7390"
    },
    items={
      {decorID=1674, source={type="vendor", itemID=244852, currency="2500000", currencytype="money"}, requirements={achievement={id=4405}}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=50307,
      type="vendor",
      faction="Alliance",
      zone="Darnassus",
      worldmap="89:5630:1350"
    },
    items={
      {decorID=1794, source={type="vendor", itemID=245603, currency="3500000", currencytype="money"}, colors={"Black"}, budgetCost=3, size="Large"},
      {decorID=1796, source={type="vendor", itemID=245605, currency="3000000", currencytype="money"}, colors={"Dark Gray"}, budgetCost=1, size="Large"},
    }
  },

  {
    source={
      id=50307,
      type="vendor",
      faction="Neutral",
      zone="Darnassus",
      worldmap="89:3720:4800"
    },
    items={
      {decorID=858, source={type="vendor", itemID=245518, currency="1500000", currencytype="money"}, requirements={quest={id=24675}}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1829, source={type="vendor", itemID=245620, currency="500000", currencytype="money"}, requirements={quest={id=14402}}, colors={"Black","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=50483,
      type="vendor",
      faction="Neutral",
      zone="Thunder Bluff",
      worldmap=""
    },
    items={
--       {decorID=1281, source={type="vendor", itemID=243335, currency="1600000", currencytype="money"}, requirements={quest={id=26397}}, colors={"Copper","Light Brown","Navy Blue"}, budgetCost=3, size="Medium"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=50488,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:5020:5840"
    },
    items={
      {decorID=9242, source={type="vendor", itemID=253168, costs={{currency="10000", currencytype="money"},{currency="9500", currencytype="money"},{currency="200000", currencytype="money"},{currency="8000", currencytype="money"}}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=68364,
      type="vendor",
      faction="Neutral",
      zone="Brawl'gar Arena",
      worldmap=""
    },
    items={
--       {decorID=10913, source={type="vendor", itemID=255840, currency="80000000", currencytype="money"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Small"}, -- missing verified worldmap
--       {decorID=12263, source={type="vendor", itemID=259071, currency="40000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"}, -- missing verified worldmap
--       {decorID=14815, source={type="vendor", itemID=263026, currency="5000000", currencytype="money"}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=145695,
      type="vendor",
      faction="Neutral",
      zone="Brawl'gar Arena",
      worldmap=""
    },
    items={
--       {decorID=10913, source={type="vendor", itemID=255840, currency="80000000", currencytype="money"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Small"}, -- missing verified worldmap
--       {decorID=12263, source={type="vendor", itemID=259071, currency="40000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"}, -- missing verified worldmap
--       {decorID=14815, source={type="vendor", itemID=263026, currency="5000000", currencytype="money"}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=151941,
      type="vendor",
      faction="Neutral",
      zone="Brawl'gar Arena",
      worldmap="369:5000:2900"
    },
    items={
      {decorID=10913, source={type="vendor", itemID=255840, currency="80000000", currencytype="money"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Small"},
      {decorID=12263, source={type="vendor", itemID=259071, currency="40000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=14815, source={type="vendor", itemID=263026, currency="5000000", currencytype="money"}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=216888,
      type="vendor",
      faction="Neutral",
      zone="Ruins of Gilneas",
      worldmap="218:6199:3672"
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
      id=224353,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="1535:3572:1316"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=254606,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:3880:7193"
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
      id=254606,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:3880:7240"
    },
    items={
      {decorID=3867, source={type="vendor", itemID=247727, currency="5000", currencytype=1792}, requirements={achievement={id=5223}}, colors={"Dark Purple","Light Purple","Silver"}, budgetCost=5, size="Huge"},
      {decorID=3885, source={type="vendor", itemID=247745, currency="1000", currencytype=1792}, requirements={achievement={id=229}}, colors={"Dark Gray","Deep Red","Tan"}, budgetCost=3, size="Medium"},
      {decorID=3887, source={type="vendor", itemID=247747, currency="800", currencytype=1792}, requirements={achievement={id=167}}, colors={"Brown","Copper","Deep Red"}, budgetCost=3, size="Medium"},
      {decorID=3896, source={type="vendor", itemID=247759, currency="600", currencytype=1792}, requirements={achievement={id=1153}}, colors={"Dark Brown","Dark Gray","Deep Red"}, budgetCost=3, size="Large"},
      {decorID=3897, source={type="vendor", itemID=247760, currency="1200", currencytype=1792}, requirements={achievement={id=222}}, colors={"Dark Brown","Dark Gray","Deep Red"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=256119,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="86:9987:1210"
    },
    items={
      {decorID=766, source={type="vendor", itemID=239177, currency="20000000", currencytype="money"}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=768, source={type="vendor", itemID=239179, currency="20000000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=2511, source={type="vendor", itemID=246845, currency="20000000", currencytype="money"}, colors={"Dark Gray","Light Brown","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=2513, source={type="vendor", itemID=246847, currency="20000000", currencytype="money"}, colors={"Dark Brown","Light Brown","Purple"}, budgetCost=1, size="Tiny"},
      {decorID=2514, source={type="vendor", itemID=246848, currency="20000000", currencytype="money"}, colors={"Dark Brown","Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=2526, source={type="vendor", itemID=246860, currency="20000000", currencytype="money"}, colors={"Dark Gray","Gray","Silver"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=261262,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:4837:8115"
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
      {decorID=15669, source={type="vendor", itemID=264397}, colors={"Dark Brown","Navy Blue","Tan"}, budgetCost=1, size="Small"},
    }
  },

}
