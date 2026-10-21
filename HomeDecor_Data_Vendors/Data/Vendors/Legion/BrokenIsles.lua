local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Legion"] = NS.Data.Vendors["Legion"] or {}

NS.Data.Vendors["Legion"]["BrokenIsles"] = {
  {
    source={
      id=93971,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4032:6973"
    },
    items={
      {decorID=4026, source={type="vendor", itemID=247912, currency="250", currencytype=1155}, colors={"Dark Gray","Dark Purple","Purple"}, budgetCost=5, size="Large"},
      {decorID=4033, source={type="vendor", itemID=247919, currency="150", currencytype=1155}, colors={"Blue","Dark Purple","Royal Blue"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=97140,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:3709:4623"
    },
    items={
      {decorID=1440, source={type="vendor", itemID=244536, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Exalted"}}, colors={"Dark Gray","Gold","Red"}, budgetCost=5, size="Huge"},
      {decorID=2516, source={type="vendor", itemID=246850, costs={{currency="8000000", currencytype="money"},{currency="2000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Exalted"}}, colors={"Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=3983, source={type="vendor", itemID=247844, costs={{currency="4000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Honored"}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=3984, source={type="vendor", itemID=247845, costs={{currency="4000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Honored"}}, colors={"Dark Gray","Dark Purple"}, budgetCost=1, size="Small"},
      {decorID=3985, source={type="vendor", itemID=247847, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Revered"}}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=4022, source={type="vendor", itemID=247908, currency="50", currencytype=1220}, colors={"Dark Gray","Light Purple","Orange"}, budgetCost=1, size="Small"},
      {decorID=4024, source={type="vendor", itemID=247910, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Friendly"}}, colors={"Dark Brown","Gray","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=4035, source={type="vendor", itemID=247921, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Friendly"}}, colors={"Dark Gray","Dark Purple","Gray"}, budgetCost=3, size="Medium"},
      {decorID=4038, source={type="vendor", itemID=247924, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Revered"}}, colors={"Copper","Cyan","Navy Blue"}, budgetCost=5, size="Large"},
    }
  },





  {
    source={
      id=105333,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="627:5697:4896"
    },
    items={
      {decorID=7610, source={type="vendor", itemID=250307, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42318}}, colors={"Copper","Dark Brown","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=7620, source={type="vendor", itemID=250402, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42658}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=7621, source={type="vendor", itemID=250403, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42692}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7622, source={type="vendor", itemID=250404, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7623, source={type="vendor", itemID=250405, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61060}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=3, size="Medium"},
      {decorID=7624, source={type="vendor", itemID=250406, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42321}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7625, source={type="vendor", itemID=250407, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42619}}, colors={"Black","Forest Green","Green"}, budgetCost=1, size="Small"},
      {decorID=7658, source={type="vendor", itemID=250622, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42675}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7686, source={type="vendor", itemID=250689, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61054}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=7687, source={type="vendor", itemID=250690, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42627}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7690, source={type="vendor", itemID=250693, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42674}}, colors={"Dark Brown","Green","Olive"}, budgetCost=3, size="Large"},
      {decorID=8810, source={type="vendor", itemID=251778, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61218}}, colors={"Cyan","Tan","Teal"}, budgetCost=5, size="Large"},
      {decorID=8811, source={type="vendor", itemID=251779, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42689}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=9165, source={type="vendor", itemID=252753, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42655}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=11278, source={type="vendor", itemID=256677, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42628}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11279, source={type="vendor", itemID=256678, costs={{currency="1500", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11942, source={type="vendor", itemID=258299, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42547}}, colors={"Black","Teal"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=106901,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:5470:7325"
    },
    items={
      {decorID=675, source={type="vendor", itemID=238859, costs={{currency="10000000", currencytype="money"},{currency="2000", currencytype=1220},{currency="8000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Exalted"}}, colors={"Copper","Dark Brown","Dark Purple"}, budgetCost=3, size="Medium"},
      {decorID=677, source={type="vendor", itemID=238861, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220},{currency="4000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Honored"}}, colors={"Dark Gray","Dark Purple","Purple"}, budgetCost=5, size="Large"},
--       {decorID=678, source={type="vendor", itemID=238862}, colors={"Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"}, -- DNT / do not use
      {decorID=1695, source={type="vendor", itemID=245261, costs={{currency="7000000", currencytype="money"},{currency="1000", currencytype=1220},{currency="5000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Revered"}}, colors={"Dark Brown","Gray","Purple"}, budgetCost=1, size="Small"},
      {decorID=8195, source={type="vendor", itemID=251494, currency="200", currencytype=1220}, requirements={reputation={name="Dreamweavers", standing="Friendly"}}, colors={"Dark Brown","Light Purple","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=15453, source={type="vendor", itemID=264168, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220},{currency="4000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Honored"}}, colors={"Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=106902,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:4588:6049"
    },
    items={
      {decorID=1231, source={type="vendor", itemID=245452, costs={{currency="4000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Honored"}}, colors={"Dark Brown"}, budgetCost=5, size="Huge"},
      {decorID=1235, source={type="vendor", itemID=245453, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=42590}}, colors={"Bronze","Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=1251, source={type="vendor", itemID=245405, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=42622}}, colors={"Dark Brown","Olive","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1252, source={type="vendor", itemID=243290, costs={{currency="8000000", currencytype="money"},{currency="2000", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Exalted"}}, colors={"Black"}, budgetCost=5, size="Huge"},
      {decorID=1287, source={type="vendor", itemID=245456, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={quest={id=39579}}, colors={"Dark Brown","Light Brown"}, budgetCost=5, size="Huge"},
      {decorID=1291, source={type="vendor", itemID=245461, costs={{currency="7000000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={quest={id=39780}}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=1292, source={type="vendor", itemID=243359, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Revered"}}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=1293, source={type="vendor", itemID=245454, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Friendly"}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=1294, source={type="vendor", itemID=245457, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=39614}}, colors={"Copper","Dark Brown","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=1295, source={type="vendor", itemID=245458, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Friendly"}}, colors={"Dark Brown"}, budgetCost=3, size="Small"},
      {decorID=1297, source={type="vendor", itemID=245450, costs={{currency="8000000", currencytype="money"},{currency="2000", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Exalted"}}, colors={"Dark Brown","Tan"}, budgetCost=5, size="Huge"},
      {decorID=1307, source={type="vendor", itemID=245460, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={achievement={id=11257}}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1309, source={type="vendor", itemID=245409, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=39496}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=1703, source={type="vendor", itemID=245270, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Revered"}}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=5136, source={type="vendor", itemID=248985, costs={{currency="4000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={reputation={name="Highmountain Tribe", standing="Honored"}}, colors={"Copper","Dark Brown","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=11315, source={type="vendor", itemID=256913, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={achievement={id=10996}}, colors={"Dark Gray","Light Brown","Royal Blue"}, budgetCost=3, size="Small"},
      {decorID=11487, source={type="vendor", itemID=257397, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={quest={id=39992}}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=11491, source={type="vendor", itemID=257401, costs={{currency="7000000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={quest={id=39387}}, colors={"Black","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=11751, source={type="vendor", itemID=257721, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={achievement={id=10398}}, colors={"Gray","Teal"}, budgetCost=3, size="Large"},
      {decorID=11752, source={type="vendor", itemID=257722, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=39426}}, colors={"Black","Dark Brown","Purple"}, budgetCost=3, size="Large"},
      {decorID=11753, source={type="vendor", itemID=257723, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={quest={id=39305}}, colors={"Blue","Dark Gray","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=14379, source={type="vendor", itemID=260698, costs={{currency="1000000", currencytype="money"},{currency="200", currencytype=1220}}}, requirements={quest={id=39772}}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=15741, source={type="vendor", itemID=264477, currency="80000", currencytype="money"}, requirements={quest={id=39487}}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=108017,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:5320:7980"
    },
    items={
      {decorID=15741, source={type="vendor", itemID=264477, currency="80000", currencytype="money"}, requirements={quest={id=39487}}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=108017,
      type="vendor",
      faction="Neutral",
      zone="Thunder Totem, Highmountain",
      worldmap="652:5470:7740"
    },
    items={
      {decorID=1235, source={type="vendor", itemID=245453, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=42590}}, colors={"Bronze","Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=1251, source={type="vendor", itemID=245405, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=42622}}, colors={"Dark Brown","Olive","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1287, source={type="vendor", itemID=245456, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={quest={id=39579}}, colors={"Dark Brown","Light Brown"}, budgetCost=5, size="Huge"},
      {decorID=1291, source={type="vendor", itemID=245461, costs={{currency="7000000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={quest={id=39780}}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=1294, source={type="vendor", itemID=245457, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=39614}}, colors={"Copper","Dark Brown","Deep Red"}, budgetCost=5, size="Large"},
      {decorID=1307, source={type="vendor", itemID=245460, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={achievement={id=11257}}, colors={"Copper","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1309, source={type="vendor", itemID=245409, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=39496}}, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=11315, source={type="vendor", itemID=256913, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={achievement={id=10996}}, colors={"Dark Gray","Light Brown","Royal Blue"}, budgetCost=3, size="Small"},
      {decorID=11487, source={type="vendor", itemID=257397, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={quest={id=39992}}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=11491, source={type="vendor", itemID=257401, costs={{currency="7000000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={quest={id=39387}}, colors={"Black","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=11751, source={type="vendor", itemID=257721, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={achievement={id=10398}}, colors={"Gray","Teal"}, budgetCost=3, size="Large"},
      {decorID=11752, source={type="vendor", itemID=257722, costs={{currency="3000000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={quest={id=39426}}, colors={"Black","Dark Brown","Purple"}, budgetCost=3, size="Large"},
      {decorID=11753, source={type="vendor", itemID=257723, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={quest={id=39305}}, colors={"Blue","Dark Gray","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=14379, source={type="vendor", itemID=260698, costs={{currency="1000000", currencytype="money"},{currency="200", currencytype=1220}}}, requirements={quest={id=39772}}, colors={"Bronze","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=108537,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:4162:1044"
    },
    items={
      {decorID=11905, source={type="vendor", itemID=258219, currency="175", currencytype=1220}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=11907, source={type="vendor", itemID=258221, currency="450", currencytype=1220}, requirements={quest={id=40230}}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=11909, source={type="vendor", itemID=258223, currency="400", currencytype=1220}, requirements={achievement={id=11699}}, colors={"Dark Gray","Navy Blue","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=109306,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:6020:8486"
    },
    items={
      {decorID=1692, source={type="vendor", itemID=245258}, requirements={quest={id=42751}}, colors={"Dark Gray","Navy Blue","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=1882, source={type="vendor", itemID=245698}, requirements={quest={id=40573}}, colors={"Dark Gray","Dark Purple","Olive"}, budgetCost=1, size="Medium"},
      {decorID=1883, source={type="vendor", itemID=245699}, requirements={quest={id=40573}}, colors={"Dark Gray","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=112634,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:5714:7191"
    },
    items={
      {decorID=679, source={type="vendor", itemID=238863, currency="300", currencytype=1220}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=3, size="Medium"},
      {decorID=1694, source={type="vendor", itemID=245260, currency="400", currencytype=1220}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=112716,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="626:4340:4940"
    },
    items={
      {decorID=2517, source={type="vendor", itemID=246851, currency="150000000", currencytype="money"}, colors={"Dark Brown","Dark Purple","Tan"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=112716,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="627:4314:4906"
    },
    items={
      {decorID=2517, source={type="vendor", itemID=246851, currency="150000000", currencytype="money"}, colors={"Dark Brown","Dark Purple","Tan"}, budgetCost=1, size="Medium"},
      {decorID=22399, source={type="vendor", itemID=284264}, budgetCost=1},
    }
  },

  {
    source={
      id=115736,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:3650:4672"
    },
    items={
      {decorID=1440, source={type="vendor", itemID=244536, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Exalted"}}, colors={"Dark Gray","Gold","Red"}, budgetCost=5, size="Huge"},
      {decorID=2516, source={type="vendor", itemID=246850, costs={{currency="8000000", currencytype="money"},{currency="2000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Exalted"}}, colors={"Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=3983, source={type="vendor", itemID=247844, costs={{currency="4000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Honored"}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=3984, source={type="vendor", itemID=247845, costs={{currency="4000000", currencytype="money"},{currency="750", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Honored"}}, colors={"Dark Gray","Dark Purple"}, budgetCost=1, size="Small"},
      {decorID=3985, source={type="vendor", itemID=247847, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Revered"}}, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=4022, source={type="vendor", itemID=247908, currency="50", currencytype=1220}, colors={"Dark Gray","Light Purple","Orange"}, budgetCost=1, size="Small"},
      {decorID=4024, source={type="vendor", itemID=247910, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Friendly"}}, colors={"Dark Brown","Gray","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=4035, source={type="vendor", itemID=247921, costs={{currency="2400000", currencytype="money"},{currency="500", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Friendly"}}, colors={"Dark Gray","Dark Purple","Gray"}, budgetCost=3, size="Medium"},
      {decorID=4038, source={type="vendor", itemID=247924, costs={{currency="5600000", currencytype="money"},{currency="1000", currencytype=1220}}}, requirements={reputation={name="The Nightfallen", standing="Revered"}}, colors={"Copper","Cyan","Navy Blue"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=127120,
      type="vendor",
      faction="Neutral",
      zone="Antorus, the Burning Throne",
      worldmap="909:1191:-497"
    },
    items={
      {decorID=27824, source={type="vendor", itemID=282111}, budgetCost=3},
      {decorID=28428, source={type="vendor", itemID=282122}, budgetCost=5},
      {decorID=28431, source={type="vendor", itemID=282128}, budgetCost=3},
      {decorID=28432, source={type="vendor", itemID=282130}, budgetCost=1},
      {decorID=28434, source={type="vendor", itemID=282134}, budgetCost=5},
      {decorID=28438, source={type="vendor", itemID=282142}, budgetCost=1},
      {decorID=28440, source={type="vendor", itemID=282146}, budgetCost=5},
      {decorID=28445, source={type="vendor", itemID=282156}, budgetCost=3},
    }
  },

  {
    source={
      id=127120,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="831:4326:7439"
    },
    items={
      {decorID=27824, source={type="vendor", itemID=282111}, budgetCost=3},
      {decorID=28428, source={type="vendor", itemID=282122}, budgetCost=5},
      {decorID=28431, source={type="vendor", itemID=282128}, budgetCost=3},
      {decorID=28432, source={type="vendor", itemID=282130}, budgetCost=1},
      {decorID=28434, source={type="vendor", itemID=282134}, budgetCost=5},
      {decorID=28438, source={type="vendor", itemID=282142}, budgetCost=1},
      {decorID=28440, source={type="vendor", itemID=282146}, budgetCost=5},
      {decorID=28445, source={type="vendor", itemID=282156}, budgetCost=3},
    }
  },

  {
    source={
      id=127120,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="883:4339:6714"
    },
    items={
      {decorID=27824, source={type="vendor", itemID=282111}, budgetCost=3},
      {decorID=28428, source={type="vendor", itemID=282122}, budgetCost=5},
      {decorID=28431, source={type="vendor", itemID=282128}, budgetCost=3},
      {decorID=28432, source={type="vendor", itemID=282130}, budgetCost=1},
      {decorID=28434, source={type="vendor", itemID=282134}, budgetCost=5},
      {decorID=28438, source={type="vendor", itemID=282142}, budgetCost=1},
      {decorID=28440, source={type="vendor", itemID=282146}, budgetCost=5},
      {decorID=28445, source={type="vendor", itemID=282156}, budgetCost=3},
    }
  },

  {
    source={
      id=127120,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="886:6263:6394"
    },
    items={
      {decorID=27824, source={type="vendor", itemID=282111}, budgetCost=3},
      {decorID=28428, source={type="vendor", itemID=282122}, budgetCost=5},
      {decorID=28431, source={type="vendor", itemID=282128}, budgetCost=3},
      {decorID=28432, source={type="vendor", itemID=282130}, budgetCost=1},
      {decorID=28434, source={type="vendor", itemID=282134}, budgetCost=5},
      {decorID=28438, source={type="vendor", itemID=282142}, budgetCost=1},
      {decorID=28440, source={type="vendor", itemID=282146}, budgetCost=5},
      {decorID=28445, source={type="vendor", itemID=282156}, budgetCost=3},
    }
  },

  {
    source={
      id=127151,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="830:6398:8946"
    },
    items={
      {decorID=930, source={type="vendor", itemID=245422, currency="6400000", currencytype="money"}, requirements={quest={id=47691}}, colors={"Dark Brown","Dark Purple","Tan"}, budgetCost=3, size="Large"},
    }
  },

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
      id=127518,
      type="vendor",
      faction="Neutral",
      zone="Antorus, the Burning Throne",
      worldmap="909:1192:-495"
    },
    items={
      {decorID=27608, source={type="vendor", itemID=281682}, budgetCost=5},
      {decorID=28106, source={type="vendor", itemID=282113}, budgetCost=3},
      {decorID=28107, source={type="vendor", itemID=282115}, budgetCost=3},
      {decorID=28108, source={type="vendor", itemID=282117}, budgetCost=3},
      {decorID=28109, source={type="vendor", itemID=282119}, budgetCost=3},
      {decorID=28427, source={type="vendor", itemID=282024}, budgetCost=3},
      {decorID=28435, source={type="vendor", itemID=282136}, budgetCost=1},
      {decorID=28436, source={type="vendor", itemID=282138}, budgetCost=1},
      {decorID=28441, source={type="vendor", itemID=282148}, budgetCost=5},
      {decorID=28442, source={type="vendor", itemID=282150}, budgetCost=5},
      {decorID=28443, source={type="vendor", itemID=282152}, budgetCost=5},
      {decorID=28444, source={type="vendor", itemID=282154}, budgetCost=5},
      {decorID=28448, source={type="vendor", itemID=282162}, budgetCost=5},
    }
  },

  {
    source={
      id=127518,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="831:3210:6661"
    },
    items={
      {decorID=27608, source={type="vendor", itemID=281682}, budgetCost=5},
      {decorID=28106, source={type="vendor", itemID=282113}, budgetCost=3},
      {decorID=28107, source={type="vendor", itemID=282115}, budgetCost=3},
      {decorID=28108, source={type="vendor", itemID=282117}, budgetCost=3},
      {decorID=28109, source={type="vendor", itemID=282119}, budgetCost=3},
      {decorID=28427, source={type="vendor", itemID=282024}, budgetCost=3},
      {decorID=28435, source={type="vendor", itemID=282136}, budgetCost=1},
      {decorID=28436, source={type="vendor", itemID=282138}, budgetCost=1},
      {decorID=28441, source={type="vendor", itemID=282148}, budgetCost=5},
      {decorID=28442, source={type="vendor", itemID=282150}, budgetCost=5},
      {decorID=28443, source={type="vendor", itemID=282152}, budgetCost=5},
      {decorID=28444, source={type="vendor", itemID=282154}, budgetCost=5},
      {decorID=28448, source={type="vendor", itemID=282162}, budgetCost=5},
    }
  },

  {
    source={
      id=127518,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="883:3490:5745"
    },
    items={
      {decorID=27608, source={type="vendor", itemID=281682}, budgetCost=5},
      {decorID=28106, source={type="vendor", itemID=282113}, budgetCost=3},
      {decorID=28107, source={type="vendor", itemID=282115}, budgetCost=3},
      {decorID=28108, source={type="vendor", itemID=282117}, budgetCost=3},
      {decorID=28109, source={type="vendor", itemID=282119}, budgetCost=3},
      {decorID=28427, source={type="vendor", itemID=282024}, budgetCost=3},
      {decorID=28435, source={type="vendor", itemID=282136}, budgetCost=1},
      {decorID=28436, source={type="vendor", itemID=282138}, budgetCost=1},
      {decorID=28441, source={type="vendor", itemID=282148}, budgetCost=5},
      {decorID=28442, source={type="vendor", itemID=282150}, budgetCost=5},
      {decorID=28443, source={type="vendor", itemID=282152}, budgetCost=5},
      {decorID=28444, source={type="vendor", itemID=282154}, budgetCost=5},
      {decorID=28448, source={type="vendor", itemID=282162}, budgetCost=5},
    }
  },

  {
    source={
      id=127518,
      type="vendor",
      faction="Neutral",
      zone="The Vindicaar",
      worldmap="886:5622:7713"
    },
    items={
      {decorID=27608, source={type="vendor", itemID=281682}, budgetCost=5},
      {decorID=28106, source={type="vendor", itemID=282113}, budgetCost=3},
      {decorID=28107, source={type="vendor", itemID=282115}, budgetCost=3},
      {decorID=28108, source={type="vendor", itemID=282117}, budgetCost=3},
      {decorID=28109, source={type="vendor", itemID=282119}, budgetCost=3},
      {decorID=28427, source={type="vendor", itemID=282024}, budgetCost=3},
      {decorID=28435, source={type="vendor", itemID=282136}, budgetCost=1},
      {decorID=28436, source={type="vendor", itemID=282138}, budgetCost=1},
      {decorID=28441, source={type="vendor", itemID=282148}, budgetCost=5},
      {decorID=28442, source={type="vendor", itemID=282150}, budgetCost=5},
      {decorID=28443, source={type="vendor", itemID=282152}, budgetCost=5},
      {decorID=28444, source={type="vendor", itemID=282154}, budgetCost=5},
      {decorID=28448, source={type="vendor", itemID=282162}, budgetCost=5},
    }
  },

  {
    source={
      id=216418,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="628:6736:6322"
    },
    items={
      {decorID=7610, source={type="vendor", itemID=250307, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42318}}, colors={"Copper","Dark Brown","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=7620, source={type="vendor", itemID=250402, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42658}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=7621, source={type="vendor", itemID=250403, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42692}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7622, source={type="vendor", itemID=250404, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7623, source={type="vendor", itemID=250405, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61060}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=3, size="Medium"},
      {decorID=7624, source={type="vendor", itemID=250406, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42321}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7625, source={type="vendor", itemID=250407, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42619}}, colors={"Black","Forest Green","Green"}, budgetCost=1, size="Small"},
      {decorID=7658, source={type="vendor", itemID=250622, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42675}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7686, source={type="vendor", itemID=250689, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61054}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=7687, source={type="vendor", itemID=250690, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42627}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7690, source={type="vendor", itemID=250693, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42674}}, colors={"Dark Brown","Green","Olive"}, budgetCost=3, size="Large"},
      {decorID=8810, source={type="vendor", itemID=251778, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61218}}, colors={"Cyan","Tan","Teal"}, budgetCost=5, size="Large"},
      {decorID=8811, source={type="vendor", itemID=251779, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42689}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=9165, source={type="vendor", itemID=252753, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42655}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=11278, source={type="vendor", itemID=256677, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42628}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11279, source={type="vendor", itemID=256678, costs={{currency="1500", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11942, source={type="vendor", itemID=258299, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42547}}, colors={"Black","Teal"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=248594,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:5090:7778"
    },
    items={
      {decorID=1444, source={type="vendor", itemID=244654, currency="100", currencytype=1155}, requirements={reputation={name="The Nightfallen", standing="Friendly"}}, colors={"Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=1464, source={type="vendor", itemID=244676, currency="200", currencytype=1155}, requirements={reputation={name="The Nightfallen", standing="Honored"}}, colors={"Dark Purple","Teal"}, budgetCost=1, size="Small"},
      {decorID=1465, source={type="vendor", itemID=244677, currency="300", currencytype=1155}, requirements={reputation={name="The Nightfallen", standing="Revered"}}, colors={"Dark Gray","Dark Purple","Purple"}, budgetCost=1, size="Small"},
      {decorID=1466, source={type="vendor", itemID=244678, currency="100", currencytype=1155}, requirements={reputation={name="The Nightfallen", standing="Friendly"}}, colors={"Brown","Crimson","Purple"}, budgetCost=1, size="Small"},
      {decorID=1919, source={type="vendor", itemID=246001, currency="200", currencytype=1155}, requirements={reputation={name="The Nightfallen", standing="Honored"}}, colors={"Copper","Deep Red","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=1920, source={type="vendor", itemID=246002, currency="300", currencytype=1155}, requirements={reputation={name="The Nightfallen", standing="Revered"}}, colors={"Brown","Copper","Dark Purple"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=251042,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="619:5506:7797"
    },
    items={
      {decorID=7610, source={type="vendor", itemID=250307, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42318}}, colors={"Copper","Dark Brown","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=7620, source={type="vendor", itemID=250402, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42658}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=7621, source={type="vendor", itemID=250403, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42692}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7622, source={type="vendor", itemID=250404, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7623, source={type="vendor", itemID=250405, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61060}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=3, size="Medium"},
      {decorID=7624, source={type="vendor", itemID=250406, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42321}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7625, source={type="vendor", itemID=250407, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42619}}, colors={"Black","Forest Green","Green"}, budgetCost=1, size="Small"},
      {decorID=7658, source={type="vendor", itemID=250622, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42675}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7686, source={type="vendor", itemID=250689, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61054}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=7687, source={type="vendor", itemID=250690, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42627}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7690, source={type="vendor", itemID=250693, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42674}}, colors={"Dark Brown","Green","Olive"}, budgetCost=3, size="Large"},
      {decorID=8810, source={type="vendor", itemID=251778, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61218}}, colors={"Cyan","Tan","Teal"}, budgetCost=5, size="Large"},
      {decorID=8811, source={type="vendor", itemID=251779, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42689}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=9165, source={type="vendor", itemID=252753, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42655}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=11278, source={type="vendor", itemID=256677, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42628}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11279, source={type="vendor", itemID=256678, costs={{currency="1500", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11942, source={type="vendor", itemID=258299, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42547}}, colors={"Black","Teal"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=251042,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="627:5114:0121"
    },
    items={
      {decorID=7610, source={type="vendor", itemID=250307, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42318}}, colors={"Copper","Dark Brown","Forest Green"}, budgetCost=1, size="Small"},
      {decorID=7620, source={type="vendor", itemID=250402, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42658}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=7621, source={type="vendor", itemID=250403, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42692}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7622, source={type="vendor", itemID=250404, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7623, source={type="vendor", itemID=250405, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61060}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=3, size="Medium"},
      {decorID=7624, source={type="vendor", itemID=250406, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42321}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7625, source={type="vendor", itemID=250407, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42619}}, colors={"Black","Forest Green","Green"}, budgetCost=1, size="Small"},
      {decorID=7658, source={type="vendor", itemID=250622, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42675}}, colors={"Black","Teal"}, budgetCost=5, size="Large"},
      {decorID=7686, source={type="vendor", itemID=250689, costs={{currency="6000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61054}}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=7687, source={type="vendor", itemID=250690, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42627}}, colors={"Dark Brown","Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=7690, source={type="vendor", itemID=250693, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42674}}, colors={"Dark Brown","Green","Olive"}, budgetCost=3, size="Large"},
      {decorID=8810, source={type="vendor", itemID=251778, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=61218}}, colors={"Cyan","Tan","Teal"}, budgetCost=5, size="Large"},
      {decorID=8811, source={type="vendor", itemID=251779, costs={{currency="18000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42689}}, colors={"Forest Green","Green"}, budgetCost=5, size="Large"},
      {decorID=9165, source={type="vendor", itemID=252753, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42655}}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=11278, source={type="vendor", itemID=256677, costs={{currency="3000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42628}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11279, source={type="vendor", itemID=256678, costs={{currency="1500", currencytype=1220},{currency="50", currencytype=1508}}}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=11942, source={type="vendor", itemID=258299, costs={{currency="12000", currencytype=1220},{currency="50", currencytype=1508}}}, requirements={achievement={id=42547}}, colors={"Black","Teal"}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=252043,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="627:6746:3389"
    },
    items={
      {decorID=947, source={type="vendor", itemID=245411, currency="20000000", currencytype="money"}, requirements={quest={id=38882}}, colors={"Dark Purple","Light Purple","Purple"}, budgetCost=1, size="Small"},
      {decorID=9267, source={type="vendor", itemID=253251, currency="2000000", currencytype="money"}, requirements={quest={id=39801}}, colors={"Black","Forest Green"}, budgetCost=1, size="Tiny"},
    }
  },

  {
    source={
      id=252498,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:4209:5938"
    },
    items={
      {decorID=1801, source={type="vendor", itemID=245615, currency="350", currencytype=1220}, requirements={quest={id=39117}}, colors={"Dark Gray","Light Brown","Orange"}, budgetCost=1, size="Small"},
      {decorID=1802, source={type="vendor", itemID=245616, currency="1000", currencytype=1220}, requirements={quest={id=46107}}, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=252969,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4963:6283"
    },
    items={
      {decorID=752, source={type="vendor", itemID=245448, costs={{currency="10000000", currencytype="money"},{currency="2000", currencytype=1220}}}, requirements={achievement={id=11124}, reputation={name="The Nightfallen", standing="Exalted"}}, colors={"Dark Purple","Light Purple","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=1747, source={type="vendor", itemID=245558, currency="225", currencytype=1220}, requirements={quest={id=44955}}, colors={"Dark Gray","Olive","Silver"}, budgetCost=3, size="Medium"},
      {decorID=3981, source={type="vendor", itemID=247842, currency="600", currencytype=1220}, requirements={quest={id=44756}}, colors={"Dark Brown","Dark Purple","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=3982, source={type="vendor", itemID=247843, currency="1200", currencytype=1220}, requirements={achievement={id=11340}}, colors={"Dark Purple","Navy Blue","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=4025, source={type="vendor", itemID=247911, currency="100", currencytype=1220}, requirements={quest={id=43318}}, colors={"Light Purple","Navy Blue","Teal"}, budgetCost=1, size="Small"},
      {decorID=4028, source={type="vendor", itemID=247914, currency="400", currencytype=1220}, requirements={quest={id=44052}}, colors={"Blue","Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=4031, source={type="vendor", itemID=247917, currency="200", currencytype=1220}, requirements={quest={id=41915}}, colors={"Navy Blue","Royal Blue","Teal"}, budgetCost=1, size="Medium"},
      {decorID=4040, source={type="vendor", itemID=248009, currency="175", currencytype=1220}, requirements={quest={id=42489}}, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=253387,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:5426:7236"
    },
    items={
      {decorID=675, source={type="vendor", itemID=238859, costs={{currency="10000000", currencytype="money"},{currency="2000", currencytype=1220},{currency="8000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Exalted"}}, colors={"Copper","Dark Brown","Dark Purple"}, budgetCost=3, size="Medium"},
      {decorID=676, source={type="vendor", itemID=238860, currency="700", currencytype=1220}, colors={"Dark Brown","Dark Purple"}, budgetCost=3, size="Medium"},
      {decorID=677, source={type="vendor", itemID=238861, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220},{currency="4000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Honored"}}, colors={"Dark Gray","Dark Purple","Purple"}, budgetCost=5, size="Large"},
--       {decorID=678, source={type="vendor", itemID=238862}, colors={"Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"}, -- DNT / do not use
      {decorID=1695, source={type="vendor", itemID=245261, costs={{currency="7000000", currencytype="money"},{currency="1000", currencytype=1220},{currency="5000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Revered"}}, colors={"Dark Brown","Gray","Purple"}, budgetCost=1, size="Small"},
      {decorID=1881, source={type="vendor", itemID=245697, currency="600", currencytype=1220}, requirements={achievement={id=10698}}, colors={"Dark Brown","Light Brown","Purple"}, budgetCost=3, size="Large"},
      {decorID=1884, source={type="vendor", itemID=245700, currency="250", currencytype=1220}, requirements={quest={id=38663}}, colors={"Dark Purple","Light Gray","Light Purple"}, budgetCost=1, size="Small"},
      {decorID=1886, source={type="vendor", itemID=245702, currency="75", currencytype=1220}, requirements={quest={id=38147}}, colors={"Dark Brown","Royal Blue","Silver"}, budgetCost=3, size="Medium"},
      {decorID=1887, source={type="vendor", itemID=245703, currency="750", currencytype=1220}, requirements={achievement={id=11258}}, colors={"Dark Gray","Gray","Light Purple"}, budgetCost=3, size="Medium"},
      {decorID=1889, source={type="vendor", itemID=245739, currency="300", currencytype=1220}, requirements={quest={id=40890}}, colors={"Dark Gray","Gray","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=8195, source={type="vendor", itemID=251494, currency="200", currencytype=1220}, requirements={reputation={name="Dreamweavers", standing="Friendly"}}, colors={"Dark Brown","Light Purple","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=15453, source={type="vendor", itemID=264168, costs={{currency="5000000", currencytype="money"},{currency="750", currencytype=1220},{currency="4000000", currencytype="money"}}}, requirements={reputation={name="Dreamweavers", standing="Honored"}}, colors={"Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=253434,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="641:7992:7389"
    },
    items={
      {decorID=1885, source={type="vendor", itemID=245701, currency="175", currencytype=1220}, requirements={quest={id=40321}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=253434,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:2622:3229"
    },
    items={
      {decorID=1885, source={type="vendor", itemID=245701, currency="175", currencytype=1220}, requirements={quest={id=40321}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255101,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4558:6915"
    },
    items={
      {decorID=11483, source={type="vendor", itemID=257393}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Large"},
      {decorID=11708, source={type="vendor", itemID=257598, currency="125", currencytype=1155}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Large"},
    }
  },

  {
    source={
      id=256826,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:1511:5333"
    },
    items={
      {decorID=11908, source={type="vendor", itemID=258222, currency="600", currencytype=1220}, requirements={quest={id=41143}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

}
