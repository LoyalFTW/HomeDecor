local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Pandaria"] = NS.Data.Vendors["Pandaria"] or {}

NS.Data.Vendors["Pandaria"]["Pandaria"] = {
  {
    source={
      id=64001,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms",
      worldmap="390:6280:2320"
    },
    items={
      {decorID=15605, source={type="vendor", itemID=264362, currency="5000000", currencytype="money"}, requirements={quest={id=30000}}, colors={"Dark Brown","Gold","Royal Blue"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=58414,
      type="vendor",
      faction="Neutral",
      zone="The Jade Forest - Arboretum",
      worldmap="371:5670:4440"
    },
    items={
      {decorID=3870, source={type="vendor", itemID=247730, currency="8000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Deep Red","Navy Blue"}, budgetCost=5, size="Huge"},
      {decorID=3872, source={type="vendor", itemID=247732, currency="4000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Deep Red","Red"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=58706,
      type="vendor",
      faction="Neutral",
      zone="Valley of the Four Winds",
      worldmap="376:5320:5180"
    },
    items={
      {decorID=4488, source={type="vendor", itemID=248663, currency="2400000", currencytype="money"}, requirements={quest={id=30526}}, colors={"Dark Brown","Dark Purple"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=58706,
      type="vendor",
      faction="Neutral",
      zone="Valley of the Four Winds - Halfhill",
      worldmap="376:5320:5160"
    },
    items={
      {decorID=1201, source={type="vendor", itemID=245508, currency="8000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Dark Purple","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=3840, source={type="vendor", itemID=247670, currency="8000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=3874, source={type="vendor", itemID=247734, currency="6400000", currencytype="money"}, requirements={rep="true"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=3877, source={type="vendor", itemID=247737, currency="2400000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Gray","Tan"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=59698,
      type="vendor",
      faction="Neutral",
      zone="Kun-Lai Summit",
      worldmap="379:5724:6096"
    },
    items={
      {decorID=15595, source={type="vendor", itemID=264349}, requirements={quest={id=30612}}, colors={"Copper","Dark Gray","Light Brown"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=59908,
      type="vendor",
      faction="Neutral",
      zone="Either Shrine in Vale of Eternal Blossoms",
      worldmap="390:6320:2210"
    },
    items={
--       {decorID=3879, source={type="vendor", itemID=247739, currency="16000000", currencytype="money"}, requirements={quest={id=30612}}, colors={"Copper","Dark Gray","Light Brown"}, budgetCost=5, size="Large"}, -- DNT / do not use
    }
  },

  {
    source={
      id=62088,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms",
      worldmap="433:2388:2179"
    },
    items={
      {decorID=767, source={type="vendor", itemID=245332, currency="20000000", currencytype="money"}, requirements={achievement={id=61467}}, colors={"Brown","Copper","Dark Brown"}, budgetCost=1, size="Tiny"},
      {decorID=11453, source={type="vendor", itemID=257351, currency="20000000", currencytype="money"}, requirements={achievement={id=42189}}, colors={"Dark Brown","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=11456, source={type="vendor", itemID=257354, currency="20000000", currencytype="money"}, requirements={achievement={id=42187}}, colors={"Light Purple","Purple","Tan"}, budgetCost=1, size="Small"},
      {decorID=11457, source={type="vendor", itemID=257355, currency="20000000", currencytype="money"}, requirements={achievement={id=42188}}, colors={"Copper","Dark Brown","Dark Purple"}, budgetCost=1, size="Small"},
      {decorID=21857, source={type="vendor", itemID=271971}, requirements={achievement={id=61442}}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=64001,
      type="vendor",
      faction="Neutral",
      zone="Shrine of Two Moons, Vale of Eternal Blossoms",
      worldmap=""
    },
    items={
      {decorID=3869, source={type="vendor", itemID=247729, currency="2400000", currencytype="money"}, requirements={quest={id=31230}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=64032,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms - Shrine of Seven Stars",
      worldmap="390:8520:6160"
    },
    items={
      {decorID=3869, source={type="vendor", itemID=247729, currency="2400000", currencytype="money"}, requirements={quest={id=31230}}, colors={"Amber","Copper","Dark Brown"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=64605,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms",
      worldmap="390:8220:2940"
    },
    items={
      {decorID=1172, source={type="vendor", itemID=245512, currency="2400000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=3832, source={type="vendor", itemID=247662, currency="4000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=3, size="Medium"},
      {decorID=3833, source={type="vendor", itemID=247663, currency="16000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Red","Silver"}, budgetCost=5, size="Huge"},
      {decorID=3993, source={type="vendor", itemID=247855, currency="2400000", currencytype="money"}, requirements={rep="true"}, colors={"Amber","Dark Brown","Red"}, budgetCost=1, size="Small"},
      {decorID=11873, source={type="vendor", itemID=258147, currency="8000000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Deep Red"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=64605,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms",
      worldmap="390:8223:2933"
    },
    items={
      {decorID=3995, source={type="vendor", itemID=247858, currency="16000000", currencytype="money"}, requirements={quest={id=32816}}, colors={"Dark Brown","Gray"}, budgetCost=5, size="Huge"},
    }
  },

}
