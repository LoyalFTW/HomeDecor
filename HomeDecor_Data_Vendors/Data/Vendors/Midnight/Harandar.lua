local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Midnight"] = NS.Data.Vendors["Midnight"] or {}

NS.Data.Vendors["Midnight"]["Harandar"] = {

  {
    source={
      id=240407,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5095:5073"
    },
    items={
      {decorID=2219, source={type="vendor", itemID=246402, currency="150", currencytype=3316}, colors={"Dark Brown","Dark Gray","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=2225, source={type="vendor", itemID=246408, currency="150", currencytype=3316}, colors={"Dark Brown","Deep Red","Tan"}, budgetCost=1, size="Small"},
      {decorID=2588, source={type="vendor", itemID=246959, currency="150", currencytype=3316}, colors={"Bronze","Dark Brown","Deep Red"}, budgetCost=1, size="Small"},
--       {decorID=2589, source={type="vendor", itemID=246960}, colors={"Brown","Dark Brown"}, budgetCost=1, size="Small"}, -- HIDDENCATALOG
      {decorID=5651, source={type="vendor", itemID=249768, currency="250", currencytype=3316}, colors={"Dark Brown","Gray","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=8916, source={type="vendor", itemID=251980, currency="150", currencytype=3316}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=14808, source={type="vendor", itemID=263019}, colors={"Dark Brown","Deep Red","Tan"}, budgetCost=5, size="Huge"},
      {decorID=14825, source={type="vendor", itemID=263039, currency="250", currencytype=3316}, colors={"Dark Brown","Gold","Red"}, budgetCost=5, size="Large"},
      {decorID=14965, source={type="vendor", itemID=263194, currency="250", currencytype=3316}, colors={"Brown","Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=14967, source={type="vendor", itemID=263195, currency="250", currencytype=3316}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=5, size="Large"},
      {decorID=15502, source={type="vendor", itemID=264267}, colors={"Copper","Olive","Yellow"}, budgetCost=5, size="Huge"},
      {decorID=15503, source={type="vendor", itemID=264268}, colors={"Dark Brown","Gold","Light Purple"}, budgetCost=5, size="Huge"},
      {decorID=15504, source={type="vendor", itemID=264269}, colors={"Dark Brown","Gold","Olive"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=248658,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:6611:6149"
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
      id=251259,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:4925:5433"
    },
    items={
      {decorID=14824, source={type="vendor", itemID=263038, currency="500", currencytype=3316}, colors={"Brown","Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=15478, source={type="vendor", itemID=264243, currency="150", currencytype=3316}, colors={"Brown","Crimson","Dark Purple"}, budgetCost=3, size="Medium"},
      {decorID=15480, source={type="vendor", itemID=264245, currency="150", currencytype=3316}, colors={"Black","Dark Brown"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=252650,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5368:5532"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255114,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5311:5092"
    },
    items={
      {decorID=1080, source={type="vendor", itemID=253443, currency="250", currencytype=3316}, colors={"Dark Brown","Gold","Red"}, budgetCost=1, size="Small"},
      {decorID=1147, source={type="vendor", itemID=253467, currency="250", currencytype=3316}, colors={"Crimson","Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=1726, source={type="vendor", itemID=245535, currency="250", currencytype=3316}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=2224, source={type="vendor", itemID=246407, currency="150", currencytype=3316}, colors={"Dark Brown","Tan","Teal"}, budgetCost=1, size="Tiny"},
      {decorID=2232, source={type="vendor", itemID=246415, currency="150", currencytype=3316}, colors={"Dark Brown","Gold","Red"}, budgetCost=1, size="Small"},
      {decorID=2233, source={type="vendor", itemID=246416, currency="150", currencytype=3316}, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=2605, source={type="vendor", itemID=247234, currency="250", currencytype=3316}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Medium"},
      {decorID=8993, source={type="vendor", itemID=252045, currency="500", currencytype=3316}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=5, size="Huge"},
      {decorID=10327, source={type="vendor", itemID=254319, currency="500", currencytype=3316}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=5, size="Large"},
      {decorID=10778, source={type="vendor", itemID=254878, currency="250", currencytype=3316}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=5, size="Large"},
      {decorID=14639, source={type="vendor", itemID=262614, currency="150", currencytype=3316}, colors={"Dark Gray","Orange","Teal"}, budgetCost=3, size="Medium"},
      {decorID=14799, source={type="vendor", itemID=262906, currency="250", currencytype=3316}, colors={"Dark Gray","Light Brown","Teal"}, budgetCost=5, size="Large"},
      {decorID=14809, source={type="vendor", itemID=263020, currency="250", currencytype=3316}, colors={"Dark Brown","Deep Red","Tan"}, budgetCost=5, size="Huge"},
      {decorID=14823, source={type="vendor", itemID=263037, currency="150", currencytype=3316}, colors={"Copper","Dark Brown","Deep Red"}, budgetCost=1, size="Small"},
      {decorID=14827, source={type="vendor", itemID=263041, currency="150", currencytype=3316}, colors={"Light Brown","Olive","Orange"}, budgetCost=5, size="Large"},
      {decorID=14968, source={type="vendor", itemID=263196, currency="250", currencytype=3316}, colors={"Copper","Dark Brown","Gold"}, budgetCost=1, size="Small"},
      {decorID=15155, source={type="vendor", itemID=263315, currency="250", currencytype=3316}, colors={"Bronze","Brown","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=15463, source={type="vendor", itemID=264178, currency="150", currencytype=3316}, colors={"Bronze","Brown","Purple"}, budgetCost=3, size="Medium"},
      {decorID=15494, source={type="vendor", itemID=264259, currency="150", currencytype=3316}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=15497, source={type="vendor", itemID=264262, currency="150", currencytype=3316}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=15501, source={type="vendor", itemID=264266, currency="250", currencytype=3316}, requirements={achievement={id=61264}}, colors={"Copper","Forest Green","Gold"}, budgetCost=1, size="Large"},
      {decorID=17516, source={type="vendor", itemID=265792, currency="250", currencytype=3316}, requirements={achievement={id=62290}}, colors={"Crimson","Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=17886, source={type="vendor", itemID=266259, currency="250", currencytype=3316}, colors={"Dark Brown","Tan","Teal"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=258480,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5241:5062"
    },
    items={
      {decorID=15410, source={type="vendor", itemID=264005}, requirements={achievement={id=42789}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=258507,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5228:5411"
    },
    items={
      {decorID=15407, source={type="vendor", itemID=264002}, requirements={achievement={id=42797}}, colors={"Dark Gray","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=258540,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5274:5069"
    },
    items={
      {decorID=15457, source={type="vendor", itemID=264172}, requirements={achievement={id=42791}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
    }
  },

}
