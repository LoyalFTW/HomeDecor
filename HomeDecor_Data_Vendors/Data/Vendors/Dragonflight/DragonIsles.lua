local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Dragonflight"] = NS.Data.Vendors["Dragonflight"] or {}

NS.Data.Vendors["Dragonflight"]["DragonIsles"] = {

  {
    source={
      id=188265,
      type="vendor",
      faction="Neutral",
      zone="Dragonscale Basecamp",
      worldmap=""
    },
    items={
--       {decorID=716, source={type="vendor", itemID=245285, currency="100", currencytype=2003}, requirements={rep="true"}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"}, -- missing verified worldmap
      {decorID=717, source={type="vendor", itemID=245287, currency="250", currencytype=2003}, colors={"Brown","Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=718, source={type="vendor", itemID=245288, currency="250", currencytype=2003}, colors={"Brown","Copper","Dark Brown"}, budgetCost=3, size="Medium"},
--       {decorID=720, source={type="vendor", itemID=238975, currency="750", currencytype=2003}, requirements={rep="true"}, colors={"Dark Brown","Orange","Teal"}, budgetCost=1, size="Small"}, -- missing verified worldmap
--       {decorID=1177, source={type="vendor", itemID=245283, currency="400", currencytype=2003}, requirements={rep="true"}, colors={"Copper","Dark Brown","Gold"}, budgetCost=1, size="Medium"}, -- missing verified worldmap
      {decorID=1181, source={type="vendor", itemID=245286, currency="250", currencytype=2003}, colors={"Bronze","Brown","Dark Brown"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=189226,
      type="vendor",
      faction="Neutral",
      zone="Dragonscale Basecamp",
      worldmap=""
    },
    items={
--       {decorID=716, source={type="vendor", itemID=245285, currency="100", currencytype=2003}, requirements={rep="true"}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"}, -- missing verified worldmap
--       {decorID=720, source={type="vendor", itemID=238975, currency="750", currencytype=2003}, requirements={rep="true"}, colors={"Dark Brown","Orange","Teal"}, budgetCost=1, size="Small"}, -- missing verified worldmap
--       {decorID=1177, source={type="vendor", itemID=245283, currency="400", currencytype=2003}, requirements={rep="true"}, colors={"Copper","Dark Brown","Gold"}, budgetCost=1, size="Medium"}, -- missing verified worldmap
    }
  },

  {
    source={
      id=189226,
      type="vendor",
      faction="Neutral",
      zone="Dragonscale Basecamp",
      worldmap="2022:4700:8260"
    },
    items={
      {decorID=717, source={type="vendor", itemID=245287, currency="250", currencytype=2003}, colors={"Brown","Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=718, source={type="vendor", itemID=245288, currency="250", currencytype=2003}, colors={"Brown","Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1181, source={type="vendor", itemID=245286, currency="250", currencytype=2003}, colors={"Bronze","Brown","Dark Brown"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=190155,
      type="vendor",
      faction="Neutral",
      zone="The Waking Shores",
      worldmap="2022:5499:3078"
    },
    items={
      {decorID=2529, source={type="vendor", itemID=246863, currency="500", currencytype=2003}, requirements={quest={id=66001}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=191025,
      type="vendor",
      faction="Neutral",
      zone="Ruby Lifeshrine, The Waking Shores",
      worldmap=""
    },
    items={
      {decorID=2529, source={type="vendor", itemID=246863, currency="500", currencytype=2003}, requirements={quest={id=66001}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=193015,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap=""
    },
    items={
      {decorID=4159, source={type="vendor", itemID=248103, currency="300", currencytype=2003}, requirements={rep="true"}, colors={"Bronze","Dark Brown","Gray"}, budgetCost=5, size="Large"},
      {decorID=4168, source={type="vendor", itemID=248112, currency="400", currencytype=2003}, requirements={rep="true"}, colors={"Dark Brown","Silver","Tan"}, budgetCost=3, size="Large"},
--       {decorID=4171, source={type="vendor", itemID=248115, currency="100000", currencytype="money"}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=5, size="Large"}, -- DNT / do not use
      {decorID=4478, source={type="vendor", itemID=248652, currency="250", currencytype=2003}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=10963, source={type="vendor", itemID=256169, currency="500", currencytype=2003}, requirements={rep="true"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=193015,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:5820:3560"
    },
    items={
      {decorID=10962, source={type="vendor", itemID=256168, currency="10", currencytype=2003}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=193659,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:3680:5060"
    },
    items={
      {decorID=7835, source={type="vendor", itemID=250912, currency="600", currencytype=2003}, colors={"Copper","Dark Gray","Silver"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=196637,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:2552:3365"
    },
    items={
      {decorID=5556, source={type="vendor", itemID=249545, currency="2500000", currencytype="money"}, colors={"Dark Brown","Light Brown","Orange"}, budgetCost=1, size="Medium"},
      {decorID=5558, source={type="vendor", itemID=249547, currency="2500000", currencytype="money"}, colors={"Bronze","Dark Brown","Teal"}, budgetCost=3, size="Large"},
      {decorID=5559, source={type="vendor", itemID=249548, currency="2500000", currencytype="money"}, colors={"Dark Gray","Light Gray","Light Purple"}, budgetCost=1, size="Small"},
      {decorID=5560, source={type="vendor", itemID=249549, costs={{currency="3000000", currencytype="money"},{currency="200", currencytype=2003}}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=3, size="Large"},
      {decorID=5689, source={type="vendor", itemID=249824, currency="2500000", currencytype="money"}, colors={"Dark Brown","Olive","Silver"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=199605,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:2660:3400"
    },
    items={
      {decorID=4180, source={type="vendor", itemID=248124, currency="7500", currencytype=2003}, requirements={achievement={id=19458}}, colors={"Dark Brown","Olive","Royal Blue"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=209192,
      type="vendor",
      faction="Neutral",
      zone="Thaldraszus",
      worldmap="2025:6140:3140"
    },
    items={
      {decorID=4173, source={type="vendor", itemID=248117, currency="4000", currencytype=2657}, colors={"Dark Brown","Orange","Purple"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=209220,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:3200:4620"
    },
    items={
      {decorID=4161, source={type="vendor", itemID=248105, currency="150", currencytype=2003}, requirements={achievement={id=19507}}, colors={"Amber","Dark Brown","Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=210608,
      type="vendor",
      faction="Neutral",
      zone="All Dragonflight Zones, moves with the Dreamsurge Event",
      worldmap="2022:5840:6780"
    },
    items={
      {decorID=10888, source={type="vendor", itemID=255673, costs={{currency="500", itemID=207026}}}, colors={"Dark Brown","Dark Purple","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=216284,
      type="vendor",
      faction="Neutral",
      zone="Amirdrassil",
      worldmap="2239:5400:6080"
    },
    items={
      {decorID=1989, source={type="vendor", itemID=246091, currency="500", currencytype=2003}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=4561, source={type="vendor", itemID=248759, currency="250", currencytype=2003}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=216285,
      type="vendor",
      faction="Neutral",
      zone="Amirdrassil",
      worldmap="2239:4840:5360"
    },
    items={
      {decorID=1834, source={type="vendor", itemID=245625, currency="350", currencytype=2003}, colors={"Dark Brown","Light Brown","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=1888, source={type="vendor", itemID=245704, currency="250", currencytype=2003}, colors={"Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=1987, source={type="vendor", itemID=246089, currency="350", currencytype=2003}, colors={"Dark Brown","Light Purple","Purple"}, budgetCost=3, size="Medium"},
      {decorID=1990, source={type="vendor", itemID=246100, currency="500", currencytype=2003}, colors={"Dark Brown","Dark Purple","Gray"}, budgetCost=5, size="Huge"},
      {decorID=4423, source={type="vendor", itemID=248401, currency="500", currencytype=2003}, requirements={quest={id=76213}}, colors={"Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=7896, source={type="vendor", itemID=251022, currency="300", currencytype=2003}, requirements={quest={id=78864}}, colors={"Cyan","Dark Brown","Dark Purple"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=216286,
      type="vendor",
      faction="Neutral",
      zone="Amirdrassil",
      worldmap="2239:4660:7060"
    },
    items={
      {decorID=11454, source={type="vendor", itemID=257352, currency="300", currencytype=2003}, requirements={quest={id=77283}}, colors={"Blue","Cyan","Royal Blue"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=217642,
      type="vendor",
      faction="Neutral",
      zone="Hallowfall",
      worldmap="2215:4280:5583"
    },
    items={
      {decorID=14360, source={type="vendor", itemID=260583, currency="500", currencytype=2815}, requirements={quest={id=82141}}, colors={"Dark Brown","Dark Gray","Royal Blue"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=226205,
      type="vendor",
      faction="Neutral",
      zone="Isle of Dorn",
      worldmap="2248:7440:4520"
    },
    items={
      {decorID=2470, source={type="vendor", itemID=246707, costs={{currency="100", itemID=225557}}}, colors={"Copper","Dark Brown","Orange"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=240852,
      type="vendor",
      faction="Neutral",
      zone="Hallowfall",
      worldmap="2215:1830:2050"
    },
    items={
      {decorID=763, source={type="vendor", itemID=245293, currency="1200", currencytype=2815}, requirements={rep="true"}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=252901,
      type="vendor",
      faction="Neutral",
      zone="Freywold Village, Isle of Dorn",
      worldmap="2248:4200:7300"
    },
    items={
      {decorID=9179, source={type="vendor", itemID=253021, currency="400", currencytype=2815}, requirements={quest={id=78999}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=9183, source={type="vendor", itemID=253035, currency="300", currencytype=2815}, requirements={quest={id=79703}}, colors={"Dark Brown","Teal"}, budgetCost=1, size="Small"},
      {decorID=9240, source={type="vendor", itemID=253166, currency="1100", currencytype=2815}, requirements={quest={id=78759}}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=253067,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:3360:5700"
    },
    items={
      {decorID=4159, source={type="vendor", itemID=248103, currency="300", currencytype=2003}, requirements={rep="true"}, colors={"Bronze","Dark Brown","Gray"}, budgetCost=5, size="Large"},
      {decorID=4168, source={type="vendor", itemID=248112, currency="400", currencytype=2003}, requirements={rep="true"}, colors={"Dark Brown","Silver","Tan"}, budgetCost=3, size="Large"},
      {decorID=4478, source={type="vendor", itemID=248652, currency="250", currencytype=2003}, requirements={rep="true"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=10963, source={type="vendor", itemID=256169, currency="500", currencytype=2003}, requirements={rep="true"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=253067,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:7153:4962"
    },
    items={
      {decorID=2469, source={type="vendor", itemID=246706, currency="100", currencytype=2003}, requirements={quest={id=67047}}, colors={"Dark Gray","Light Brown","Orange"}, budgetCost=1, size="Tiny"},
      {decorID=2594, source={type="vendor", itemID=247223, currency="175", currencytype=2003}, requirements={quest={id=67063}}, colors={"Dark Brown","Red","Teal"}, budgetCost=3, size="Medium"},
      {decorID=4160, source={type="vendor", itemID=248104, currency="150", currencytype=2003}, requirements={achievement={id=17773}}, colors={"Amber","Dark Brown","Gray"}, budgetCost=1, size="Large"},
      {decorID=4477, source={type="vendor", itemID=248651, currency="600", currencytype=2003}, requirements={quest={id=72935}}, colors={"Amber","Cyan","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=4479, source={type="vendor", itemID=248653, currency="50", currencytype=2003}, requirements={quest={id=71097}}, colors={"Bronze","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=4481, source={type="vendor", itemID=248655, currency="200", currencytype=2003}, requirements={quest={id=70880}}, colors={"Dark Brown","Dark Gray","Gold"}, budgetCost=1, size="Small"},
      {decorID=11164, source={type="vendor", itemID=256429, currency="200", currencytype=2003}, requirements={quest={id=70745}}, colors={"Dark Brown","Dark Gray","Light Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=253086,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:3400:5760"
    },
    items={
      {decorID=4482, source={type="vendor", itemID=248656, currency="1500", currencytype=2118}, requirements={achievement={id=17529}}, colors={"Dark Brown","Gray"}, budgetCost=3, size="Medium"},
    }
  },

}
