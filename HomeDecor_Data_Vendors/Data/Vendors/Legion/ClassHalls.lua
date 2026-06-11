local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Legion"] = NS.Data.Vendors["Legion"] or {}

NS.Data.Vendors["Legion"]["ClassHalls"] = {

  {
    source={
      id=93550,
      type="vendor",
      faction="Neutral",
      zone="Acherus: Ebon Hold",
      worldmap="647:4390:3717"
    },
    items={
      {decorID=14361, source={type="vendor", itemID=260584, currency="3000", currencytype=1220}, requirements={achievement={id=60962}}, colors={"Cyan","Dark Gray","Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=93550,
      type="vendor",
      faction="Neutral",
      zone="Acherus: The Ebon Hold",
      worldmap="647:4390:3717"
    },
    items={
      {decorID=5575, source={type="vendor", itemID=249690, currency="3000", currencytype=1220}, requirements={achievement={id=60963}}, colors={"Dark Brown","Olive","Teal"}, budgetCost=1, size="Small"},
      {decorID=5879, source={type="vendor", itemID=250112, currency="2000", currencytype=1220}, requirements={achievement={id=60981}}, colors={"Cyan","Dark Purple","Teal"}, budgetCost=3, size="Medium"},
      {decorID=5880, source={type="vendor", itemID=250113, currency="500", currencytype=1220}, colors={"Dark Gray","Forest Green"}, budgetCost=1, size="Tiny"},
      {decorID=5881, source={type="vendor", itemID=250114, currency="500", currencytype=1220}, colors={"Dark Brown","Dark Purple","Olive"}, budgetCost=3, size="Medium"},
      {decorID=5882, source={type="vendor", itemID=250115, currency="1500", currencytype=1220}, requirements={achievement={id=42270}}, colors={"Blue","Cyan","Forest Green"}, budgetCost=3, size="Medium"},
      {decorID=5888, source={type="vendor", itemID=250123, currency="5000", currencytype=1220}, requirements={achievement={id=42287}}, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=5889, source={type="vendor", itemID=250124, currency="1000", currencytype=1220}, colors={"Dark Purple","Light Purple"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=100196,
      type="vendor",
      faction="Neutral",
      zone="Sanctum of Light",
      worldmap="23:7564:4909"
    },
    items={
      {decorID=7571, source={type="vendor", itemID=250230, currency="5000", currencytype=1220}, requirements={achievement={id=42293}}, colors={"Dark Gray","Gray"}, budgetCost=3, size="Medium"},
      {decorID=7574, source={type="vendor", itemID=250233, currency="3000", currencytype=1220}, requirements={achievement={id=60968}}, colors={"Dark Brown","Tan","Yellow"}, budgetCost=5, size="Large"},
      {decorID=7575, source={type="vendor", itemID=250234, currency="1500", currencytype=1220}, requirements={achievement={id=42276}}, colors={"Bronze","Dark Brown","Yellow"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=103693,
      type="vendor",
      faction="Neutral",
      zone="Trueshot Lodge",
      worldmap="739:4456:4888"
    },
    items={
      {decorID=4042, source={type="vendor", itemID=248011, currency="1500", currencytype=1220}, requirements={achievement={id=42273}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=5890, source={type="vendor", itemID=250125, currency="5000", currencytype=1220}, requirements={achievement={id=42290}}, colors={"Beige","Dark Gray","Tan"}, budgetCost=3, size="Large"},
      {decorID=5892, source={type="vendor", itemID=250127, currency="3000", currencytype=1220}, requirements={achievement={id=60965}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=105986,
      type="vendor",
      faction="Neutral",
      zone="The Hall of Shadows",
      worldmap="626:2692:3683"
    },
    items={
      {decorID=7819, source={type="vendor", itemID=250787, currency="5000", currencytype=1220}, requirements={achievement={id=42295}}, colors={"Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=7820, source={type="vendor", itemID=250788, currency="3000", currencytype=1220}, requirements={achievement={id=60970}}, colors={"Dark Gray","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=11493, source={type="vendor", itemID=257403, currency="1500", currencytype=1220}, requirements={achievement={id=42280}}, colors={"Amber","Dark Brown","Red"}, budgetCost=5, size="Huge"},
      {decorID=14461, source={type="vendor", itemID=260776, currency="1500", currencytype=1220}, requirements={achievement={id=42279}}, colors={"Dark Gray","Light Brown"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=112318,
      type="vendor",
      faction="Neutral",
      zone="The Maelstrom",
      worldmap="726:3032:6069"
    },
    items={
      {decorID=7837, source={type="vendor", itemID=250914, currency="5000", currencytype=1220}, requirements={achievement={id=42296}}, colors={"Black","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=7838, source={type="vendor", itemID=250915, currency="3000", currencytype=1220}, requirements={achievement={id=60971}}, colors={"Copper","Dark Brown","Teal"}, budgetCost=5, size="Large"},
      {decorID=11493, source={type="vendor", itemID=257403, currency="1500", currencytype=1220}, requirements={achievement={id=42280}}, colors={"Amber","Dark Brown","Red"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=112323,
      type="vendor",
      faction="Neutral",
      zone="The Dreamgrove",
      worldmap="747:4002:1772"
    },
    items={
      {decorID=5878, source={type="vendor", itemID=250111, currency="3000", currencytype=1220}, requirements={achievement={id=60964}}, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=5898, source={type="vendor", itemID=250134, currency="5000", currencytype=1220}, requirements={achievement={id=42289}}, colors={"Dark Brown","Forest Green","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=14358, source={type="vendor", itemID=260581, currency="1500", currencytype=1220}, requirements={achievement={id=42272}}, colors={"Cyan","Dark Gray","Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=112338,
      type="vendor",
      faction="Neutral",
      zone="Mandori Village",
      worldmap="709:5033:5913"
    },
    items={
      {decorID=5126, source={type="vendor", itemID=248958, currency="1500", currencytype=1220}, requirements={achievement={id=42275}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=11280, source={type="vendor", itemID=256679, currency="3000", currencytype=1220}, requirements={achievement={id=60967}}, colors={"Dark Gray","Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=14644, source={type="vendor", itemID=262619}, requirements={achievement={id=42292}}, colors={"Bronze","Dark Brown","Teal"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=112392,
      type="vendor",
      faction="Neutral",
      zone="Skyhold",
      worldmap="695:5549:2591"
    },
    items={
      {decorID=5526, source={type="vendor", itemID=249458, currency="5000", currencytype=1220}, requirements={achievement={id=42298}}, colors={"Dark Brown","Light Brown","Tan"}, budgetCost=3, size="Large"},
      {decorID=5534, source={type="vendor", itemID=249466, currency="1500", currencytype=1220}, requirements={achievement={id=42282}}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=11486, source={type="vendor", itemID=257396, currency="3000", currencytype=1220}, requirements={achievement={id=60973}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=112401,
      type="vendor",
      faction="Neutral",
      zone="Netherlight Temple",
      worldmap="702:3862:2377"
    },
    items={
      {decorID=7822, source={type="vendor", itemID=250790, currency="5000", currencytype=1220}, requirements={achievement={id=42294}}, colors={"Dark Brown","Olive","Silver"}, budgetCost=3, size="Large"},
      {decorID=7823, source={type="vendor", itemID=250791, currency="3000", currencytype=1220}, requirements={achievement={id=60969}}, colors={"Copper","Dark Brown","Light Purple"}, budgetCost=3, size="Medium"},
      {decorID=7824, source={type="vendor", itemID=250792, currency="1500", currencytype=1220}, requirements={achievement={id=42277}}, colors={"Bronze","Dark Brown","Navy Blue"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=112407,
      type="vendor",
      faction="Neutral",
      zone="The Fel Hammer",
      worldmap="720:6100:5673"
    },
    items={
      {decorID=5525, source={type="vendor", itemID=249457, currency="5000", currencytype=1220}, requirements={achievement={id=42288}}, colors={"Dark Brown","Orange","Tan"}, budgetCost=3, size="Large"},
      {decorID=5527, source={type="vendor", itemID=249459, currency="1500", currencytype=1220}, requirements={achievement={id=42271}}, colors={"Blue","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=5575, source={type="vendor", itemID=249690, currency="3000", currencytype=1220}, requirements={achievement={id=60963}}, colors={"Dark Brown","Olive","Teal"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=112434,
      type="vendor",
      faction="Neutral",
      zone="Dreadscar Rift",
      worldmap="717:5876:3269"
    },
    items={
      {decorID=5117, source={type="vendor", itemID=248940, currency="5000", currencytype=1220}, requirements={achievement={id=42297}}, colors={"Forest Green","Green","Teal"}, budgetCost=3, size="Medium"},
      {decorID=5128, source={type="vendor", itemID=248960, currency="1500", currencytype=1220}, requirements={achievement={id=42281}}, colors={"Teal"}, budgetCost=5, size="Large"},
      {decorID=11307, source={type="vendor", itemID=256907}, requirements={achievement={id=60972}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=112440,
      type="vendor",
      faction="Neutral",
      zone="Hall of the Guardian",
      worldmap="735:4475:5787"
    },
    items={
      {decorID=750, source={type="vendor", itemID=245429, currency="1500", currencytype=1220}, requirements={achievement={id=42274}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Medium"},
      {decorID=7609, source={type="vendor", itemID=250306, currency="5000", currencytype=1220}, requirements={achievement={id=42291}}, colors={"Dark Gray","Gray"}, budgetCost=3, size="Medium"},
      {decorID=11275, source={type="vendor", itemID=256674, currency="3000", currencytype=1220}, requirements={achievement={id=60966}}, colors={"Dark Gray","Magenta","Silver"}, budgetCost=3, size="Medium"},
    }
  },

}
