local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BurningCrusade"] = NS.Data.Vendors["BurningCrusade"] or {}

NS.Data.Vendors["BurningCrusade"]["Outland"] = {
  {
    source={
      id=16528,
      type="vendor",
      faction="Horde",
      zone="Shattrath",
      worldmap="111:4800:4620"
    },
    items={
      {decorID=10950, source={type="vendor", itemID=256049, currency="50000000", currencytype="money"}, requirements={reputation={name="Tranquillien", standing="Exalted"}}, colors={"Dark Brown","Deep Red","Silver"}, expansion="Midnight", budgetCost=5, size="Large"},
      {decorID=11500, source={type="vendor", itemID=257419, currency="50000000", currencytype="money"}, requirements={reputation={name="Tranquillien", standing="Exalted"}}, colors={"Amber","Dark Brown","Gray"}, expansion="Midnight", budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=151941,
      type="vendor",
      faction="Neutral",
      zone="Deeprun Tram",
      worldmap="499:4178:8467"
    },
    items={
      {decorID=10913, source={type="vendor", itemID=255840, currency="80000000", currencytype="money"}, requirements={reputation={name="Brawl'gar Arena", standing="Rank 7"}}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Small"},
      {decorID=12263, source={type="vendor", itemID=259071, currency="40000000", currencytype="money"}, requirements={reputation={name="Brawl'gar Arena", standing="Rank 5"}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=14815, source={type="vendor", itemID=263026, currency="5000000", currencytype="money"}, requirements={reputation={name="Brawl'gar Arena", standing="Rank 2"}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=161908,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman (Ghostlands)",
      worldmap="95:7370:3690"
    },
    items={
      {decorID=2322, source={type="vendor", itemID=246479, currency="5", currencytype=3363}, requirements={achievement={id=13723}}, colors={"Dark Gray","Deep Red","Olive"}, budgetCost=1, size="Small"},
      {decorID=2323, source={type="vendor", itemID=246480, costs={{currency="8000000", currencytype="money"},{currency="5", itemID=168327},{currency="5", itemID=168832}}}, requirements={reputation={name="Rustbolt Resistance", standing="Exalted"}}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=2326, source={type="vendor", itemID=246483, costs={{currency="4000000", currencytype="money"},{currency="1", itemID=168327},{currency="2", itemID=170500}}}, requirements={achievement={id=13473}}, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=5, size="Huge"},
      {decorID=2327, source={type="vendor", itemID=246484, costs={{currency="1", itemID=170500}}}, requirements={reputation={name="Rustbolt Resistance", standing="Friendly"}}, colors={"Blue","Dark Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=2337, source={type="vendor", itemID=246497, costs={{currency="1", itemID=170500}}}, requirements={reputation={name="Rustbolt Resistance", standing="Friendly"}}, colors={"Copper","Dark Brown","Yellow"}, budgetCost=1, size="Medium"},
      {decorID=2338, source={type="vendor", itemID=246498, costs={{currency="800000", currencytype="money"},{currency="1", itemID=170500}}}, requirements={reputation={name="Rustbolt Resistance", standing="Honored"}}, colors={"Copper","Dark Brown","Gold"}, budgetCost=3, size="Large"},
      {decorID=2339, source={type="vendor", itemID=246499, costs={{currency="1200000", currencytype="money"},{currency="2", itemID=170500}}}, requirements={reputation={name="Rustbolt Resistance", standing="Revered"}}, colors={"Blue","Dark Brown","Teal"}, budgetCost=3, size="Large"},
      {decorID=2341, source={type="vendor", itemID=246501, costs={{currency="1600000", currencytype="money"},{currency="2", itemID=168832}}}, requirements={reputation={name="Rustbolt Resistance", standing="Exalted"}}, colors={"Bronze","Dark Brown","Silver"}, budgetCost=3, size="Medium"},
      {decorID=2343, source={type="vendor", itemID=246503, costs={{currency="800000", currencytype="money"},{currency="2", itemID=169610}}}, requirements={reputation={name="Rustbolt Resistance", standing="Honored"}}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=2430, source={type="vendor", itemID=246598, costs={{currency="1", itemID=169610}}}, requirements={achievement={id=13477}}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=2433, source={type="vendor", itemID=246601, costs={{currency="10", itemID=166846}}}, colors={"Dark Gray","Silver"}, budgetCost=1, size="Small"},
      {decorID=2435, source={type="vendor", itemID=246603, costs={{currency="50", itemID=166846}}}, requirements={achievement={id=13475}}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=1, size="Medium"},
      {decorID=2437, source={type="vendor", itemID=246605, costs={{currency="1200000", currencytype="money"},{currency="2", itemID=168327}}}, requirements={reputation={name="Rustbolt Resistance", standing="Revered"}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Large"},
      {decorID=2466, source={type="vendor", itemID=246701, costs={{currency="1600000", currencytype="money"},{currency="2", itemID=169610}}}, requirements={quest={id=55651}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Medium"},
      {decorID=2467, source={type="vendor", itemID=246703, costs={{currency="3", itemID=169610}}}, requirements={quest={id=55736}}, colors={"Copper","Dark Gray","Gray"}, budgetCost=3, size="Large"},
    }
  },

}
