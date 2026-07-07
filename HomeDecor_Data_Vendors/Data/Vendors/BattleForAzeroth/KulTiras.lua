local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BattleForAzeroth"] = NS.Data.Vendors["BattleForAzeroth"] or {}

NS.Data.Vendors["BattleForAzeroth"]["KulTiras"] = {

  {
    source={
      id=127151,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="940:6822:5691"
    },
    items={
      {decorID=930, source={type="vendor", itemID=245422, currency="6400000", currencytype="money"}, requirements={quest={id=47691}}, colors={"Dark Brown","Dark Purple","Tan"}, budgetCost=3, size="Large"},
      {decorID=8189, source={type="vendor", itemID=251480, currency="2400000", currencytype="money"}, requirements={quest={id=44004}}, colors={"Dark Gray","Gray","Tan"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=135808,
      type="vendor",
      faction="Alliance",
      zone="Harbormaster's Office",
      worldmap="1161:6760:2180"
    },
    items={
      {decorID=2091, source={type="vendor", itemID=246222, currency="75", currencytype=1560}, requirements={rep="true"}, colors={"Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=8984, source={type="vendor", itemID=252036, currency="500", currencytype=1560}, requirements={rep="true"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=5, size="Large"},
      {decorID=9036, source={type="vendor", itemID=252387, currency="100", currencytype=1560}, requirements={rep="true"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=9037, source={type="vendor", itemID=252388, currency="50", currencytype=1560}, requirements={rep="true"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=9051, source={type="vendor", itemID=252402, currency="450", currencytype=1560}, requirements={rep="true"}, colors={"Dark Gray","Olive"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=142115,
      type="vendor",
      faction="Neutral",
      zone="Boralus Harbor",
      worldmap="1161:6760:4080"
    },
    items={
      {decorID=4813, source={type="vendor", itemID=248796, currency="30000000", currencytype="money"}, requirements={achievement={id=5442}}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=144129,
      type="vendor",
      faction="Neutral",
      zone="Blackrock Depths",
      worldmap="1186:4977:3222"
    },
    items={
      {decorID=1120, source={type="vendor", itemID=245291}, colors={"Dark Gray","Gray"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=150716,
      type="vendor",
      faction="Neutral",
      zone="Mechagon",
      worldmap="1462:7370:3691"
    },
    items={
      {decorID=2322, source={type="vendor", itemID=246479, currency="5", currencytype=3363}, requirements={achievement={id=13723}}, colors={"Dark Gray","Deep Red","Olive"}, budgetCost=1, size="Small"},
      {decorID=2326, source={type="vendor", itemID=246483, costs={{currency="4000000", currencytype="money"},{currency="1", itemID=168327},{currency="2", itemID=170500}}}, requirements={achievement={id=13473}}, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=5, size="Huge"},
      {decorID=2430, source={type="vendor", itemID=246598, costs={{currency="1", itemID=169610}}}, requirements={achievement={id=13477}}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=2433, source={type="vendor", itemID=246601, costs={{currency="10", itemID=166846}}}, colors={"Dark Gray","Silver"}, budgetCost=1, size="Small"},
      {decorID=2435, source={type="vendor", itemID=246603, costs={{currency="50", itemID=166846}}}, requirements={achievement={id=13475}}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=1, size="Medium"},
      {decorID=2466, source={type="vendor", itemID=246701, costs={{currency="1600000", currencytype="money"},{currency="2", itemID=169610}}}, requirements={quest={id=55651}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Medium"},
      {decorID=2467, source={type="vendor", itemID=246703, costs={{currency="3", itemID=169610}}}, requirements={quest={id=55736}}, colors={"Copper","Dark Gray","Gray"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=150716,
      type="vendor",
      faction="Neutral",
      zone="Mechagon Island",
      worldmap="1460:7140:3860"
    },
    items={
      {decorID=2323, source={type="vendor", itemID=246480, costs={{currency="8000000", currencytype="money"},{currency="5", itemID=168327},{currency="5", itemID=168832}}}, requirements={rep="true"}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=2327, source={type="vendor", itemID=246484, costs={{currency="1", itemID=170500}}}, requirements={rep="true"}, colors={"Blue","Dark Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=2337, source={type="vendor", itemID=246497, costs={{currency="1", itemID=170500}}}, requirements={rep="true"}, colors={"Copper","Dark Brown","Yellow"}, budgetCost=1, size="Medium"},
      {decorID=2338, source={type="vendor", itemID=246498, costs={{currency="800000", currencytype="money"},{currency="1", itemID=170500}}}, requirements={rep="true"}, colors={"Copper","Dark Brown","Gold"}, budgetCost=3, size="Large"},
      {decorID=2339, source={type="vendor", itemID=246499, costs={{currency="1200000", currencytype="money"},{currency="2", itemID=170500}}}, requirements={rep="true"}, colors={"Blue","Dark Brown","Teal"}, budgetCost=3, size="Large"},
      {decorID=2341, source={type="vendor", itemID=246501, costs={{currency="1600000", currencytype="money"},{currency="2", itemID=168832}}}, requirements={rep="true"}, colors={"Bronze","Dark Brown","Silver"}, budgetCost=3, size="Medium"},
      {decorID=2343, source={type="vendor", itemID=246503, costs={{currency="800000", currencytype="money"},{currency="2", itemID=169610}}}, requirements={rep="true"}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=2437, source={type="vendor", itemID=246605, costs={{currency="1200000", currencytype="money"},{currency="2", itemID=168327}}}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=152194,
      type="vendor",
      faction="Neutral",
      zone="Chamber of Heart",
      worldmap="1473:5015:6693"
    },
    items={
      {decorID=3837, source={type="vendor", itemID=247667, currency="10000", currencytype=1803}, requirements={achievement={id=40953}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=3838, source={type="vendor", itemID=247668, currency="10000", currencytype=1803}, requirements={achievement={id=40953}}, colors={"Deep Red","Purple"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=246721,
      type="vendor",
      faction="Neutral",
      zone="Tiragarde Sound",
      worldmap="1161:5629:4582"
    },
    items={
      {decorID=9039, source={type="vendor", itemID=252390, currency="450", currencytype=1560}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Medium"},
      {decorID=9040, source={type="vendor", itemID=252391, currency="750", currencytype=1560}, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=9042, source={type="vendor", itemID=252393, currency="500", currencytype=1560}, colors={"Dark Gray","Gray","Silver"}, budgetCost=5, size="Large"},
      {decorID=9053, source={type="vendor", itemID=252404, currency="300", currencytype=1560}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=12210, source={type="vendor", itemID=258765, currency="175", currencytype=1560}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=252313,
      type="vendor",
      faction="Neutral",
      zone="Stormsong Valley",
      worldmap="942:5950:6960"
    },
    items={
      {decorID=1900, source={type="vendor", itemID=245984, currency="350", currencytype=1560}, requirements={quest={id=50783}}, colors={"Amber","Copper","Teal"}, budgetCost=3, size="Medium"},
      {decorID=9043, source={type="vendor", itemID=252394, currency="550", currencytype=1560}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=5, size="Large"},
      {decorID=9044, source={type="vendor", itemID=252395, currency="450", currencytype=1560}, requirements={quest={id=51401}}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=9045, source={type="vendor", itemID=252396, currency="125", currencytype=1560}, requirements={rep="true"}, colors={"Light Brown","Orange","Teal"}, budgetCost=1, size="Small"},
      {decorID=9047, source={type="vendor", itemID=252398, currency="200", currencytype=1560}, requirements={rep="true"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=9139, source={type="vendor", itemID=252652, currency="800", currencytype=1560}, requirements={rep="true"}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=9142, source={type="vendor", itemID=252655, currency="175", currencytype=1560}, requirements={quest={id=50611}}, colors={"Copper","Gold","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=252316,
      type="vendor",
      faction="Neutral",
      zone="Tiragarde Sound",
      worldmap="895:5340:3120"
    },
    items={
      {decorID=9041, source={type="vendor", itemID=252392, currency="250", currencytype=1560}, requirements={quest={id=48089}}, colors={"Bronze","Dark Brown","Gold"}, budgetCost=3, size="Medium"},
      {decorID=9054, source={type="vendor", itemID=252405, currency="250", currencytype=1560}, colors={"Amber","Copper","Dark Gray"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=252345,
      type="vendor",
      faction="Neutral",
      zone="Tiragarde Sound",
      worldmap="1161:7074:1566"
    },
    items={
      {decorID=1704, source={type="vendor", itemID=245271, currency="800", currencytype=1560}, requirements={achievement={id=12582}}, colors={"Copper","Dark Gray","Deep Red"}, budgetCost=5, size="Huge"},
      {decorID=9035, source={type="vendor", itemID=252386, currency="400", currencytype=1560}, requirements={quest={id=50972}}, colors={"Olive","Teal"}, budgetCost=1, size="Medium"},
      {decorID=9049, source={type="vendor", itemID=252400, currency="500", currencytype=1560}, requirements={quest={id=53887}}, colors={"Dark Gray","Olive"}, budgetCost=1, size="Small"},
      {decorID=9052, source={type="vendor", itemID=252403, currency="550", currencytype=1560}, requirements={quest={id=53720}}, colors={"Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=9055, source={type="vendor", itemID=252406, currency="375", currencytype=1560}, requirements={quest={id=47489}}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=9140, source={type="vendor", itemID=252653, currency="650", currencytype=1560}, requirements={achievement={id=13049}}, colors={"Dark Brown","Olive","Silver"}, budgetCost=3, size="Medium"},
      {decorID=9141, source={type="vendor", itemID=252654, currency="300", currencytype=1560}, requirements={achievement={id=12997}}, colors={"Dark Brown","Olive","Teal"}, budgetCost=5, size="Large"},
      {decorID=9166, source={type="vendor", itemID=252754, currency="800", currencytype=1560}, requirements={quest={id=55045}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
    }
  },

}
