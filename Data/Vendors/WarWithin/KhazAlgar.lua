local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["WarWithin"] = NS.Data.Vendors["WarWithin"] or {}

NS.Data.Vendors["WarWithin"]["KhazAlgar"] = {

  {
    title="Corlen Hordralin",
    source={
      id=252915,
      type="vendor",
      faction="Neutral",
      zone="The Bazaar, Silvermoon City",
      worldmap="2393:4420:6280",
    },
    items={
      --       {decorID=9479, decorType="Wall Hangings", source={type="vendor", itemID=253602}}, -- Early Access / Midnight pre-patch
      --       {decorID=9480, decorType="Wall Hangings", source={type="vendor", itemID=253603}}, -- Early Access / Midnight pre-patch
      --       {decorID=9481, decorType="Wall Hangings", source={type="vendor", itemID=253604}}, -- Early Access / Midnight pre-patch
      --       {decorID=9482, decorType="Wall Hangings", source={type="vendor", itemID=253605}}, -- Early Access / Midnight pre-patch
      --       {decorID=9484, decorType="Wall Hangings", source={type="vendor", itemID=253607}}, -- Early Access / Midnight pre-patch
      --       {decorID=9485, decorType="Wall Hangings", source={type="vendor", itemID=253608}}, -- Early Access / Midnight pre-patch
      --       {decorID=9491, decorType="Wall Hangings", source={type="vendor", itemID=253614}}, -- Early Access / Midnight pre-patch
      --       {decorID=9492, decorType="Wall Hangings", source={type="vendor", itemID=253615}}, -- Early Access / Midnight pre-patch
      --       {decorID=9493, decorType="Wall Hangings", source={type="vendor", itemID=253616}}, -- Early Access / Midnight pre-patch
      --       {decorID=9494, decorType="Wall Hangings", source={type="vendor", itemID=253617}}, -- Early Access / Midnight pre-patch
      --       {decorID=9495, decorType="Wall Hangings", source={type="vendor", itemID=253618}}, -- Early Access / Midnight pre-patch
      --       {decorID=9496, decorType="Wall Hangings", source={type="vendor", itemID=253619}}, -- Early Access / Midnight pre-patch
      --       {decorID=9497, decorType="Wall Hangings", source={type="vendor", itemID=253620}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Val'zuun",
    source={
      id=105333,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="628:6736:6322",
    },
    items={
      {decorID=7610, decorType="Ornamental", source={type="vendor", itemID=250307, currency="10000", currencytype="Bronze"}, requirements={achievement={id=42318}}},
      {decorID=7620, decorType="Seating", source={type="vendor", itemID=250402, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42658}}},
      {decorID=7621, decorType="Miscellaneous - All", source={type="vendor", itemID=250403, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42692}}},
      {decorID=7622, decorType="Misc Accents", source={type="vendor", itemID=250404, currency="5000", currencytype="Bronze"}},
      {decorID=7623, decorType="Large Lights", source={type="vendor", itemID=250405, currency="5000", currencytype="Bronze"}, requirements={achievement={id=61060}}},
      {decorID=7624, decorType="Large Structures", source={type="vendor", itemID=250406, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42321}}},
      {decorID=7625, decorType="Large Lights", source={type="vendor", itemID=250407, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42619}}},
      {decorID=7658, decorType="Misc Accents", source={type="vendor", itemID=250622, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42675}}},
      {decorID=7686, decorType="Large Structures", source={type="vendor", itemID=250689, currency="10000", currencytype="Bronze"}, requirements={achievement={id=61054}}},
      {decorID=7687, decorType="Large Lights", source={type="vendor", itemID=250690, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42627}}},
      {decorID=7690, decorType="Ornamental", source={type="vendor", itemID=250693, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42674}}},
      {decorID=8810, decorType="Misc Accents", source={type="vendor", itemID=251778, currency="30000", currencytype="Bronze"}, requirements={achievement={id=61218}}},
      {decorID=8811, decorType="Large Structures", source={type="vendor", itemID=251779, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42689}}},
      {decorID=9165, decorType="Storage", source={type="vendor", itemID=252753, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42655}}},
      {decorID=11278, decorType="Small Lights", source={type="vendor", itemID=256677, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42628}}},
      {decorID=11279, decorType="Small Lights", source={type="vendor", itemID=256678, currency="2500", currencytype="Bronze"}},
      {decorID=11942, decorType="Misc Structural", source={type="vendor", itemID=258299, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42547}}},
    }
  },
  {
    title="Maku",
    source={
      id=255114,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5311:5092",
    },
    items={
      --       {decorID=1080, decorType="Ornamental", source={type="vendor", itemID=253443}}, -- Early Access / Midnight pre-patch
      --       {decorID=1147, decorType="Uncategorized", source={type="vendor", itemID=253467}}, -- Early Access / Midnight pre-patch
      --       {decorID=1726, decorType="Misc Furnishings", source={type="vendor", itemID=245535}}, -- Early Access / Midnight pre-patch
      --       {decorID=2224, decorType="Misc Furnishings", source={type="vendor", itemID=246407}}, -- Early Access / Midnight pre-patch
      --       {decorID=2232, decorType="Misc Furnishings", source={type="vendor", itemID=246415}}, -- Early Access / Midnight pre-patch
      --       {decorID=2605, decorType="Misc Furnishings", source={type="vendor", itemID=247234, currency="250", currencytype="Dragon Isles Supplies"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8993, decorType="Miscellaneous - All", source={type="vendor", itemID=252045}}, -- Early Access / Midnight pre-patch
      --       {decorID=10327, decorType="Misc Furnishings", source={type="vendor", itemID=254319}}, -- Early Access / Midnight pre-patch
      --       {decorID=10778, decorType="Misc Furnishings", source={type="vendor", itemID=254878}}, -- Early Access / Midnight pre-patch
      --       {decorID=14639, decorType="Ornamental", source={type="vendor", itemID=262614, currency="10", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14799, decorType="Ornamental", source={type="vendor", itemID=262906}}, -- Early Access / Midnight pre-patch
      --       {decorID=14809, decorType="Ornamental", source={type="vendor", itemID=263020}}, -- Early Access / Midnight pre-patch
      --       {decorID=14823, decorType="Ornamental", source={type="vendor", itemID=263037}}, -- Early Access / Midnight pre-patch
      --       {decorID=14827, decorType="Ornamental", source={type="vendor", itemID=263041}}, -- Early Access / Midnight pre-patch
      --       {decorID=14968, decorType="Small Lights", source={type="vendor", itemID=263196}}, -- Early Access / Midnight pre-patch
      --       {decorID=15155, decorType="Uncategorized", source={type="vendor", itemID=263315}}, -- Early Access / Midnight pre-patch
      --       {decorID=15463, decorType="Food and Drink", source={type="vendor", itemID=264178}}, -- Early Access / Midnight pre-patch
      --       {decorID=15494, decorType="Wall Hangings", source={type="vendor", itemID=264259}}, -- Early Access / Midnight pre-patch
      --       {decorID=15497, decorType="Ornamental", source={type="vendor", itemID=264262}}, -- Early Access / Midnight pre-patch
      --       {decorID=17516, decorType="Walls and Columns", source={type="vendor", itemID=265792}, requirements={achievement={id=62290}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17886, decorType="Uncategorized", source={type="vendor", itemID=266259}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Chel the Chip",
    source={
      id=257633,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2437:1737:3808",
    },
    items={
      --       {decorID=11323, decorType="Ornamental", source={type="vendor", itemID=256923}}, -- Early Access / Midnight pre-patch
      --       {decorID=15484, decorType="Seating", source={type="vendor", itemID=264249}}, -- Early Access / Midnight pre-patch
      --       {decorID=15489, decorType="Storage", source={type="vendor", itemID=264254}}, -- Early Access / Midnight pre-patch
      --       {decorID=15851, decorType="Seating", source={type="vendor", itemID=264655, currency="150", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Magovu",
    source={
      id=240279,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4595:6592",
    },
    items={
      --       {decorID=11324, decorType="Ornamental", source={type="vendor", itemID=256924}}, -- Early Access / Midnight pre-patch
      --       {decorID=11326, decorType="Ornamental", source={type="vendor", itemID=256926}}, -- Early Access / Midnight pre-patch
      --       {decorID=11327, decorType="Ornamental", source={type="vendor", itemID=256927}}, -- Early Access / Midnight pre-patch
      --       {decorID=11333, decorType="Ornamental", source={type="vendor", itemID=256933}}, -- Early Access / Midnight pre-patch
      --       {decorID=11334, decorType="Ornamental", source={type="vendor", itemID=256934}}, -- Early Access / Midnight pre-patch
      --       {decorID=11936, decorType="Ornamental", source={type="vendor", itemID=258290}}, -- Early Access / Midnight pre-patch
      --       {decorID=12154, decorType="Small Lights", source={type="vendor", itemID=258549}}, -- Early Access / Midnight pre-patch
      --       {decorID=14204, decorType="Wall Hangings", source={type="vendor", itemID=260202}}, -- Early Access / Midnight pre-patch
      --       {decorID=14350, decorType="Wall Hangings", source={type="vendor", itemID=260514}}, -- Early Access / Midnight pre-patch
      --       {decorID=14351, decorType="Wall Hangings", source={type="vendor", itemID=260515}}, -- Early Access / Midnight pre-patch
      --       {decorID=14352, decorType="Wall Hangings", source={type="vendor", itemID=260516}}, -- Early Access / Midnight pre-patch
      --       {decorID=15158, decorType="Storage", source={type="vendor", itemID=263318, currency="1000", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15160, decorType="Storage", source={type="vendor", itemID=263320, currency="1000", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15571, decorType="Miscellaneous - All", source={type="vendor", itemID=264333}}, -- Early Access / Midnight pre-patch
      --       {decorID=15596, decorType="Ornamental", source={type="vendor", itemID=264350}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Tajaka Sawtusk",
    source={
      id=254944,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4604:6608",
    },
    items={
      --       {decorID=1148, decorType="Tables and Desks", source={type="vendor", itemID=253469}}, -- Early Access / Midnight pre-patch
      --       {decorID=10858, decorType="Large Structures", source={type="vendor", itemID=255648, currency="2000", currencytype="Apexis Crystal"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11325, decorType="Uncategorized", source={type="vendor", itemID=256925}, requirements={achievement={id=62289}}}, -- Early Access / Midnight pre-patch
      --       {decorID=11328, decorType="Ornamental", source={type="vendor", itemID=256928}}, -- Early Access / Midnight pre-patch
      --       {decorID=15490, decorType="Wall Hangings", source={type="vendor", itemID=264255}}, -- Early Access / Midnight pre-patch
      --       {decorID=15492, decorType="Miscellaneous - All", source={type="vendor", itemID=264257}}, -- Early Access / Midnight pre-patch
      --       {decorID=15572, decorType="Miscellaneous - All", source={type="vendor", itemID=264334, currency="400", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15573, decorType="Miscellaneous - All", source={type="vendor", itemID=264335, currency="400", currencytype="War Resources"}, requirements={achievement={id=62122}}}, -- Early Access / Midnight pre-patch
      --       {decorID=15743, decorType="Wall Hangings", source={type="vendor", itemID=264479, currency="1200", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15744, decorType="Wall Hangings", source={type="vendor", itemID=264480, currency="1200", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15745, decorType="Wall Hangings", source={type="vendor", itemID=264481, currency="1200", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16092, decorType="Ceiling Lights", source={type="vendor", itemID=264715}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Telemancer Astrandis",
    source={
      id=242399,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5253:7887",
    },
    items={
      --       {decorID=15399, decorType="Storage", source={type="vendor", itemID=263994, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15400, decorType="Storage", source={type="vendor", itemID=263995, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15401, decorType="Storage", source={type="vendor", itemID=263996, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15412, decorType="Storage", source={type="vendor", itemID=264007, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15413, decorType="Storage", source={type="vendor", itemID=264008, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15455, decorType="Storage", source={type="vendor", itemID=264170, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15460, decorType="Storage", source={type="vendor", itemID=264175, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Morta Gage",
    source={
      id=252873,
      type="vendor",
      faction="Alliance",
      zone="Arcantina",
      worldmap="2541:4200:5000",
    },
    items={
      --       {decorID=9248, decorType="Small Foliage", source={type="vendor", itemID=253174, currency="750", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9249, decorType="Small Foliage", source={type="vendor", itemID=253175, currency="2500", currencytype="Voidlight Marl"}, requirements={quest={id=92323}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9250, decorType="Ornamental", source={type="vendor", itemID=253176, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92322}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9251, decorType="Ornamental", source={type="vendor", itemID=253177, currency="2500", currencytype="Voidlight Marl"}, requirements={quest={id=92324}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9252, decorType="Ornamental", source={type="vendor", itemID=253178, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92320}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9253, decorType="Ornamental", source={type="vendor", itemID=253179, currency="2500", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9439, decorType="Misc Furnishings", source={type="vendor", itemID=253542, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92319}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9440, decorType="Floor", source={type="vendor", itemID=253543, currency="750", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9441, decorType="Ornamental", source={type="vendor", itemID=253544, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92325}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9475, decorType="Wall Hangings", source={type="vendor", itemID=253598, currency="8000", currencytype="Voidlight Marl"}, requirements={quest={id=92321}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9624, decorType="Ornamental", source={type="vendor", itemID=253700, currency="2500", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Om'sirik",
    source={
      id=235252,
      type="vendor",
      faction="Neutral",
      zone="K'aresh",
      worldmap="2472:4033:2936",
    },
    items={
      {decorID=3891, decorType="Large Structures", source={type="vendor", itemID=247751, currency="2000", currencytype="Resonance Crystals"}},
      {decorID=11948, decorType="Large Structures", source={type="vendor", itemID=258306, currency="1000", currencytype="Resonance Crystals"}},
      {decorID=11952, decorType="Large Structures", source={type="vendor", itemID=258320, currency="1000", currencytype="Resonance Crystals"}},
      {decorID=12195, decorType="Large Structures", source={type="vendor", itemID=258666, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12196, decorType="Large Structures", source={type="vendor", itemID=258667, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12197, decorType="Large Structures", source={type="vendor", itemID=258668, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12198, decorType="Large Structures", source={type="vendor", itemID=258669, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12211, decorType="Large Structures", source={type="vendor", itemID=258766, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12212, decorType="Large Structures", source={type="vendor", itemID=258767, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12217, decorType="Large Structures", source={type="vendor", itemID=258835, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12218, decorType="Large Structures", source={type="vendor", itemID=258836, currency="800", currencytype="Resonance Crystals"}},
      {decorID=12220, decorType="Large Structures", source={type="vendor", itemID=258885, currency="800", currencytype="Resonance Crystals"}},
    }
  },
  {
    title="Hesta Forlath",
    source={
      id=252916,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4405:6276",
    },
    items={
      --       {decorID=1446, decorType="Seating", source={type="vendor", itemID=244656, currency="200", currencytype="Ancient Mana"}, requirements={achievement={id=62185}}}, -- Early Access / Midnight pre-patch
      --       {decorID=9483, decorType="Wall Hangings", source={type="vendor", itemID=253606}}, -- Early Access / Midnight pre-patch
      --       {decorID=9486, decorType="Wall Hangings", source={type="vendor", itemID=253609}}, -- Early Access / Midnight pre-patch
      --       {decorID=9487, decorType="Wall Hangings", source={type="vendor", itemID=253610}}, -- Early Access / Midnight pre-patch
      --       {decorID=9488, decorType="Wall Hangings", source={type="vendor", itemID=253611}}, -- Early Access / Midnight pre-patch
      --       {decorID=9489, decorType="Wall Hangings", source={type="vendor", itemID=253612}}, -- Early Access / Midnight pre-patch
      --       {decorID=9490, decorType="Wall Hangings", source={type="vendor", itemID=253613}}, -- Early Access / Midnight pre-patch
      --       {decorID=9628, decorType="Wall Hangings", source={type="vendor", itemID=253704}}, -- Early Access / Midnight pre-patch
      --       {decorID=9629, decorType="Wall Hangings", source={type="vendor", itemID=253705}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Caeris Fairdawn",
    source={
      id=240838,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4346:4742",
    },
    items={
      --       {decorID=1896, decorType="Ornamental", source={type="vendor", itemID=245941}}, -- Early Access / Midnight pre-patch
      --       {decorID=1901, decorType="Small Lights", source={type="vendor", itemID=245985}}, -- Early Access / Midnight pre-patch
      --       {decorID=5564, decorType="Large Structures", source={type="vendor", itemID=249559, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10944, decorType="Seating", source={type="vendor", itemID=256040, currency="750", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11502, decorType="Misc Furnishings", source={type="vendor", itemID=257421}}, -- Early Access / Midnight pre-patch
      --       {decorID=11503, decorType="Seating", source={type="vendor", itemID=257422, currency="750", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14971, decorType="Floor", source={type="vendor", itemID=263205}}, -- Early Access / Midnight pre-patch
      --       {decorID=14972, decorType="Floor", source={type="vendor", itemID=263206}}, -- Early Access / Midnight pre-patch
      --       {decorID=14979, decorType="Storage", source={type="vendor", itemID=263216}}, -- Early Access / Midnight pre-patch
      --       {decorID=14985, decorType="Wall Hangings", source={type="vendor", itemID=263223, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15059, decorType="Tables and Desks", source={type="vendor", itemID=263228}}, -- Early Access / Midnight pre-patch
      --       {decorID=15060, decorType="Tables and Desks", source={type="vendor", itemID=263229}}, -- Early Access / Midnight pre-patch
      --       {decorID=15063, decorType="Storage", source={type="vendor", itemID=263232}}, -- Early Access / Midnight pre-patch
      --       {decorID=15065, decorType="Storage", source={type="vendor", itemID=263234}}, -- Early Access / Midnight pre-patch
      --       {decorID=15499, decorType="Misc Lighting", source={type="vendor", itemID=264264}}, -- Early Access / Midnight pre-patch
      --       {decorID=15500, decorType="Misc Lighting", source={type="vendor", itemID=264265, currency="300", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Second Chair Pawdo",
    source={
      id=252312,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5284:6800",
    },
    items={
      {decorID=1693, decorType="Storage", source={type="vendor", itemID=245259, currency="75", currencytype="Order Resources"}, requirements={quest={id=38147}}},
      {decorID=1861, decorType="Small Lights", source={type="vendor", itemID=245655, currency="10", currencytype="Dragon Isles Supplies"}},
      {decorID=2330, decorType="Misc Structural", source={type="vendor", itemID=246487}, requirements={quest={id=40573}}},
      {decorID=2433, decorType="Seating", source={type="vendor", itemID=166846, currency="400", currencytype="War Resources"}},
      {decorID=4022, decorType="Small Lights", source={type="vendor", itemID=247908, currency="10", currencytype="Dragon Isles Supplies"}},
      {decorID=4029, decorType="Tables and Desks", source={type="vendor", itemID=247915, currency="400", currencytype="Order Resources"}, requirements={quest={id=44052}}},
      {decorID=4172, decorType="Ceiling Lights", source={type="vendor", itemID=248116, currency="150", currencytype="Dragon Isles Supplies"}, requirements={quest={id=70745}}},
      {decorID=5111, decorType="Storage", source={type="vendor", itemID=248934, currency="650", currencytype="War Resources"}},
      {decorID=9242, decorType="Storage", source={type="vendor", itemID=253168, currency="600", currencytype="Resonance Crystals"}},
      {decorID=9247, decorType="Storage", source={type="vendor", itemID=253173, currency="850", currencytype="Resonance Crystals"}, requirements={quest={id=92572}}},
      {decorID=10962, decorType="Wall Hangings", source={type="vendor", itemID=256168, currency="10", currencytype="Dragon Isles Supplies"}},
    }
  },
  {
    title="Garnett",
    source={
      id=252910,
      type="vendor",
      faction="Horde",
      zone="Dornogal",
      worldmap="2339:5468:5724",
    },
    items={
      {decorID=9168, decorType="Tables and Desks", source={type="vendor", itemID=252756, currency="800", currencytype="Resonance Crystals"}, requirements={quest={id=79530}}},
      {decorID=9169, decorType="Seating", source={type="vendor", itemID=252757, currency="900", currencytype="Resonance Crystals"}, requirements={achievement={id=20595}}},
      {decorID=9181, decorType="Beds", source={type="vendor", itemID=253023, currency="1000", currencytype="Resonance Crystals"}, requirements={achievement={id=40504}}},
      {decorID=9182, decorType="Small Lights", source={type="vendor", itemID=253034, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=82895}}},
      {decorID=9185, decorType="Large Lights", source={type="vendor", itemID=253037, currency="600", currencytype="Resonance Crystals"}, requirements={achievement={id=40859}}},
      {decorID=9186, decorType="Ceiling Lights", source={type="vendor", itemID=253038, currency="500", currencytype="Resonance Crystals"}},
      {decorID=9237, decorType="Large Structures", source={type="vendor", itemID=253163, currency="900", currencytype="Resonance Crystals"}, requirements={achievement={id=19408}}},
    }
  },
  {
    title="Gabbun",
    source={
      id=256783,
      type="vendor",
      faction="Alliance",
      zone="The Ringing Deeps",
      worldmap="2214:4335:3327",
    },
    items={
      {decorID=11930, decorType="Seating", source={type="vendor", itemID=258262, currency="400", currencytype="War Resources"}, requirements={quest={id=79510}}}, 
      {decorID=11931, decorType="Small Lights", source={type="vendor", itemID=258264, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=78642}}},
      {decorID=11932, decorType="Miscellaneous - All", source={type="vendor", itemID=258265, currency="1200", currencytype="Resonance Crystals"}, requirements={quest={id=80516}}}, 
      {decorID=11933, decorType="Large Structures", source={type="vendor", itemID=258267, currency="1000", currencytype="Order Resources"}, requirements={quest={id=79565}}}, 
    }
  },
  {
    title="Ta'sam",
    source={
      id=235314,
      type="vendor",
      faction="Neutral",
      zone="Tazavesh, the Veiled Market, K'aresh",
      worldmap="2472:4320:3479",
    },
    items={
      {decorID=14359, decorType="Miscellaneous - All", source={type="vendor", itemID=260582, currency="500", currencytype="Resonance Crystals"}},
    }
  },
  {
    title="Stacks Topskimmer",
    source={
      id=251911,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:4319:5047",
    },
    items={
      {decorID=825, decorType="Beds", source={type="vendor", itemID=245306, currency="1200", currencytype="Resonance Crystals"}, requirements={quest={id=86408}}},
      {decorID=827, decorType="Miscellaneous - All", source={type="vendor", itemID=245303, currency="800", currencytype="Resonance Crystals"}, requirements={quest={id=85780}}},
      {decorID=1257, decorType="Tables and Desks", source={type="vendor", itemID=245314, currency="850", currencytype="Resonance Crystals"}},
      {decorID=1258, decorType="Tables and Desks", source={type="vendor", itemID=243312, currency="900", currencytype="Resonance Crystals"}},
      {decorID=1262, decorType="Misc Structural", source={type="vendor", itemID=245319, currency="350", currencytype="Resonance Crystals"}},
      {decorID=1263, decorType="Misc Structural", source={type="vendor", itemID=245318, currency="450", currencytype="Resonance Crystals"}},
      {decorID=1266, decorType="Large Structures", source={type="vendor", itemID=245325, currency="1000", currencytype="Resonance Crystals"}, requirements={quest={id=85711}}},
      {decorID=1267, decorType="Tables and Desks", source={type="vendor", itemID=243321, currency="1000", currencytype="Resonance Crystals"}, requirements={quest={id=87297}}},
      {decorID=1271, decorType="Large Structures", source={type="vendor", itemID=245324, currency="1500", currencytype="Resonance Crystals"}, requirements={achievement={id=40894}}},
      {decorID=1274, decorType="Ornamental", source={type="vendor", itemID=245308, currency="750", currencytype="Resonance Crystals"}, requirements={quest={id=87008}}},
      {decorID=1276, decorType="Ornamental", source={type="vendor", itemID=245310, currency="800", currencytype="Resonance Crystals"}, requirements={quest={id=83176}}},
      {decorID=11455, decorType="Misc Accents", source={type="vendor", itemID=257353, currency="300", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=61451}}},
      {decorID=14381, decorType="Misc Accents", source={type="vendor", itemID=260700, currency="300", currencytype="Resonance Crystals"}, requirements={quest={id=84675}}},
    }
  },
  {
    title="\"Den\" Nightshade",
    source={
      id=257307,
      type="vendor",
      faction="Alliance",
      zone="",
      worldmap="0:0000:0000",
    },
    items={
      --       {decorID=14677, decorType="Ornamental", source={type="vendor", itemID=262664, currency="5", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14678, decorType="Miscellaneous - All", source={type="vendor", itemID=262665, currency="5", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14679, decorType="Miscellaneous - All", source={type="vendor", itemID=262666, currency="2", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14793, decorType="Large Lights", source={type="vendor", itemID=262884, currency="10", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14800, decorType="Miscellaneous - All", source={type="vendor", itemID=262907, currency="10", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14829, decorType="Storage", source={type="vendor", itemID=263043, currency="10", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14830, decorType="Storage", source={type="vendor", itemID=263044, currency="5", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14831, decorType="Large Lights", source={type="vendor", itemID=263045, currency="20", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14832, decorType="Storage", source={type="vendor", itemID=263046, currency="10", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14833, decorType="Storage", source={type="vendor", itemID=263047, currency="5", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14834, decorType="Ornamental", source={type="vendor", itemID=263048, currency="15", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Chert",
    source={
      id=252887,
      type="vendor",
      faction="Neutral",
      zone="The Ringing Deeps",
      worldmap="2214:4340:3300",
    },
    items={
      {decorID=9178, decorType="Seating", source={type="vendor", itemID=253020, currency="500", currencytype="Resonance Crystals"}, requirements={quest={id=78761}}},
      {decorID=9188, decorType="Misc Structural", source={type="vendor", itemID=253040, currency="650", currencytype="Resonance Crystals"}, requirements={quest={id=82144}}},
      {decorID=9236, decorType="Storage", source={type="vendor", itemID=253162, currency="600", currencytype="Resonance Crystals"}},
      {decorID=9246, decorType="Storage", source={type="vendor", itemID=253172, currency="850", currencytype="Resonance Crystals"}, requirements={quest={id=83160}}},
    }
  },
  {
    title="Void Researcher Aemely",
    source={
      id=259922,
      type="vendor",
      faction="Neutral",
      zone="Voidstorm",
      worldmap="2405:5266:7279",
    },
    items={
      --       {decorID=14554, decorType="Floor", source={type="vendor", itemID=262351}}, -- Early Access / Midnight pre-patch
      --       {decorID=14602, decorType="Food and Drink", source={type="vendor", itemID=262472, currency="2", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14631, decorType="Uncategorized", source={type="vendor", itemID=262606}}, -- Early Access / Midnight pre-patch
      --       {decorID=15071, decorType="Storage", source={type="vendor", itemID=263240}}, -- Early Access / Midnight pre-patch
      --       {decorID=15579, decorType="Storage", source={type="vendor", itemID=264340, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15597, decorType="Miscellaneous - All", source={type="vendor", itemID=264351}}, -- Early Access / Midnight pre-patch
      --       {decorID=15768, decorType="Miscellaneous - All", source={type="vendor", itemID=264508}}, -- Early Access / Midnight pre-patch
      --       {decorID=15890, decorType="Miscellaneous - All", source={type="vendor", itemID=264656}, requirements={achievement={id=62291}}}, -- Early Access / Midnight pre-patch
      --       {decorID=15891, decorType="Storage", source={type="vendor", itemID=264657, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15894, decorType="Storage", source={type="vendor", itemID=264659}}, -- Early Access / Midnight pre-patch
      --       {decorID=18617, decorType="Tables and Desks", source={type="vendor", itemID=267082}}, -- Early Access / Midnight pre-patch
      --       {decorID=18800, decorType="Uncategorized", source={type="vendor", itemID=267209}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Void Researcher Anomander",
    source={
      id=248328,
      type="vendor",
      faction="Neutral",
      zone="Voidstorm",
      worldmap="2405:5259:7290",
    },
    items={
      --       {decorID=5132, decorType="Tables and Desks", source={type="vendor", itemID=248964}}, -- Early Access / Midnight pre-patch
      --       {decorID=14592, decorType="Ornamental", source={type="vendor", itemID=262462}}, -- Early Access / Midnight pre-patch
      --       {decorID=14593, decorType="Ornamental", source={type="vendor", itemID=262463}}, -- Early Access / Midnight pre-patch
      --       {decorID=14596, decorType="Tables and Desks", source={type="vendor", itemID=262466}}, -- Early Access / Midnight pre-patch
      --       {decorID=14603, decorType="Food and Drink", source={type="vendor", itemID=262473}}, -- Early Access / Midnight pre-patch
      --       {decorID=14632, decorType="Seating", source={type="vendor", itemID=262607}}, -- Early Access / Midnight pre-patch
      --       {decorID=14634, decorType="Small Lights", source={type="vendor", itemID=262609}}, -- Early Access / Midnight pre-patch
      --       {decorID=15260, decorType="Storage", source={type="vendor", itemID=263499, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15575, decorType="Miscellaneous - All", source={type="vendor", itemID=264337}}, -- Early Access / Midnight pre-patch
      --       {decorID=15578, decorType="Miscellaneous - All", source={type="vendor", itemID=264339}}, -- Early Access / Midnight pre-patch
      --       {decorID=15581, decorType="Storage", source={type="vendor", itemID=264341, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15584, decorType="Small Lights", source={type="vendor", itemID=264344}}, -- Early Access / Midnight pre-patch
      --       {decorID=15597, decorType="Miscellaneous - All", source={type="vendor", itemID=264351}}, -- Early Access / Midnight pre-patch
      --       {decorID=15769, decorType="Storage", source={type="vendor", itemID=264509, currency="10", currencytype="Voidlight Marl"}}, -- Early Access / Midnight pre-patch
      --       {decorID=18800, decorType="Uncategorized", source={type="vendor", itemID=267209}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Neriv",
    source={
      id=242726,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4349:4765",
    },
    items={
      --       {decorID=2459, decorType="Food and Drink", source={type="vendor", itemID=246692, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=7782, decorType="Misc Furnishings", source={type="vendor", itemID=250772, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Dennia Silvertongue",
    source={
      id=256828,
      type="vendor",
      faction="Horde",
      zone="Silvermoon City",
      worldmap="2393:5117:5645",
    },
    items={
      {decorID=1458, decorType="Large Structures", source={type="vendor", itemID=244668, currency="2000", currencytype="Apexis Crystal"}},
      {decorID=1894, decorType="Large Structures", source={type="vendor", itemID=245939, currency="2000", currencytype="Apexis Crystal"}},
      {decorID=2231, decorType="Large Structures", source={type="vendor", itemID=246414, currency="600", currencytype="Order Resources"}},
      {decorID=4843, decorType="Large Structures", source={type="vendor", itemID=248809}},
      {decorID=9149, decorType="Wall Hangings", source={type="vendor", itemID=252666, currency="1000", currencytype="Garrison Resources"}},
      {decorID=9150, decorType="Wall Hangings", source={type="vendor", itemID=252667, currency="1000", currencytype="Garrison Resources"}},
      {decorID=9151, decorType="Wall Hangings", source={type="vendor", itemID=252668, currency="2000", currencytype="Order Resources"}},
      {decorID=9152, decorType="Wall Hangings", source={type="vendor", itemID=252669, currency="2000", currencytype="Order Resources"}},
      --       {decorID=15070, decorType="Floor", source={type="vendor", itemID=263239}}, -- Early Access / Midnight pre-patch
      --       {decorID=15072, decorType="Miscellaneous - All", source={type="vendor", itemID=263241}}, -- Early Access / Midnight pre-patch
      --       {decorID=15073, decorType="Miscellaneous - All", source={type="vendor", itemID=263242}}, -- Early Access / Midnight pre-patch
      --       {decorID=15074, decorType="Miscellaneous - All", source={type="vendor", itemID=263243}}, -- Early Access / Midnight pre-patch
      --       {decorID=15142, decorType="Miscellaneous - All", source={type="vendor", itemID=263292}}, -- Early Access / Midnight pre-patch
      --       {decorID=15143, decorType="Miscellaneous - All", source={type="vendor", itemID=263293}}, -- Early Access / Midnight pre-patch
      --       {decorID=15144, decorType="Miscellaneous - All", source={type="vendor", itemID=263294}}, -- Early Access / Midnight pre-patch
      --       {decorID=15145, decorType="Miscellaneous - All", source={type="vendor", itemID=263295}}, -- Early Access / Midnight pre-patch
      --       {decorID=15146, decorType="Miscellaneous - All", source={type="vendor", itemID=263296}}, -- Early Access / Midnight pre-patch
      --       {decorID=15147, decorType="Miscellaneous - All", source={type="vendor", itemID=263297}}, -- Early Access / Midnight pre-patch
      --       {decorID=15148, decorType="Miscellaneous - All", source={type="vendor", itemID=263298}}, -- Early Access / Midnight pre-patch
      --       {decorID=15149, decorType="Miscellaneous - All", source={type="vendor", itemID=263299}}, -- Early Access / Midnight pre-patch
      --       {decorID=15150, decorType="Miscellaneous - All", source={type="vendor", itemID=263300}}, -- Early Access / Midnight pre-patch
      --       {decorID=15151, decorType="Miscellaneous - All", source={type="vendor", itemID=263301}}, -- Early Access / Midnight pre-patch
      --       {decorID=15152, decorType="Miscellaneous - All", source={type="vendor", itemID=263302}}, -- Early Access / Midnight pre-patch
      --       {decorID=15153, decorType="Miscellaneous - All", source={type="vendor", itemID=263303}}, -- Early Access / Midnight pre-patch
      --       {decorID=16027, decorType="Miscellaneous - All", source={type="vendor", itemID=264680}}, -- Early Access / Midnight pre-patch
      --       {decorID=16028, decorType="Miscellaneous - All", source={type="vendor", itemID=264681}}, -- Early Access / Midnight pre-patch
      --       {decorID=16029, decorType="Miscellaneous - All", source={type="vendor", itemID=264682}}, -- Early Access / Midnight pre-patch
      --       {decorID=16030, decorType="Miscellaneous - All", source={type="vendor", itemID=264683}}, -- Early Access / Midnight pre-patch
      --       {decorID=16031, decorType="Miscellaneous - All", source={type="vendor", itemID=264684}}, -- Early Access / Midnight pre-patch
      --       {decorID=16032, decorType="Miscellaneous - All", source={type="vendor", itemID=264685}}, -- Early Access / Midnight pre-patch
      --       {decorID=16033, decorType="Miscellaneous - All", source={type="vendor", itemID=264686}}, -- Early Access / Midnight pre-patch
      --       {decorID=16034, decorType="Miscellaneous - All", source={type="vendor", itemID=264687}}, -- Early Access / Midnight pre-patch
      --       {decorID=16035, decorType="Miscellaneous - All", source={type="vendor", itemID=264688}}, -- Early Access / Midnight pre-patch
      --       {decorID=16036, decorType="Miscellaneous - All", source={type="vendor", itemID=264689}}, -- Early Access / Midnight pre-patch
      --       {decorID=16037, decorType="Miscellaneous - All", source={type="vendor", itemID=264690}}, -- Early Access / Midnight pre-patch
      --       {decorID=16038, decorType="Miscellaneous - All", source={type="vendor", itemID=264691}}, -- Early Access / Midnight pre-patch
      --       {decorID=16811, decorType="Miscellaneous - All", source={type="vendor", itemID=265387}}, -- Early Access / Midnight pre-patch
      --       {decorID=16812, decorType="Miscellaneous - All", source={type="vendor", itemID=265388}}, -- Early Access / Midnight pre-patch
      --       {decorID=16813, decorType="Miscellaneous - All", source={type="vendor", itemID=265389}}, -- Early Access / Midnight pre-patch
      --       {decorID=16814, decorType="Miscellaneous - All", source={type="vendor", itemID=265390}}, -- Early Access / Midnight pre-patch
      --       {decorID=16815, decorType="Miscellaneous - All", source={type="vendor", itemID=265391}}, -- Early Access / Midnight pre-patch
      --       {decorID=16816, decorType="Miscellaneous - All", source={type="vendor", itemID=265392}}, -- Early Access / Midnight pre-patch
      --       {decorID=16817, decorType="Miscellaneous - All", source={type="vendor", itemID=265393}}, -- Early Access / Midnight pre-patch
      --       {decorID=16818, decorType="Miscellaneous - All", source={type="vendor", itemID=265394}}, -- Early Access / Midnight pre-patch
      --       {decorID=16819, decorType="Miscellaneous - All", source={type="vendor", itemID=265395}}, -- Early Access / Midnight pre-patch
      --       {decorID=16820, decorType="Miscellaneous - All", source={type="vendor", itemID=265396}}, -- Early Access / Midnight pre-patch
      --       {decorID=16821, decorType="Miscellaneous - All", source={type="vendor", itemID=265397}}, -- Early Access / Midnight pre-patch
      --       {decorID=16822, decorType="Miscellaneous - All", source={type="vendor", itemID=265398}}, -- Early Access / Midnight pre-patch
      --       {decorID=16964, decorType="Miscellaneous - All", source={type="vendor", itemID=265544}}, -- Early Access / Midnight pre-patch
      --       {decorID=16965, decorType="Miscellaneous - All", source={type="vendor", itemID=265545}}, -- Early Access / Midnight pre-patch
      --       {decorID=16966, decorType="Miscellaneous - All", source={type="vendor", itemID=265546}}, -- Early Access / Midnight pre-patch
      --       {decorID=16967, decorType="Miscellaneous - All", source={type="vendor", itemID=265547}}, -- Early Access / Midnight pre-patch
      --       {decorID=16968, decorType="Miscellaneous - All", source={type="vendor", itemID=265548}}, -- Early Access / Midnight pre-patch
      --       {decorID=16969, decorType="Miscellaneous - All", source={type="vendor", itemID=265549}}, -- Early Access / Midnight pre-patch
      --       {decorID=16970, decorType="Miscellaneous - All", source={type="vendor", itemID=265550}}, -- Early Access / Midnight pre-patch
      --       {decorID=16971, decorType="Miscellaneous - All", source={type="vendor", itemID=265551}}, -- Early Access / Midnight pre-patch
      --       {decorID=16972, decorType="Miscellaneous - All", source={type="vendor", itemID=265552}}, -- Early Access / Midnight pre-patch
      --       {decorID=16973, decorType="Miscellaneous - All", source={type="vendor", itemID=265553}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Velerd",
    source={
      id=219217,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5520:7640",
    },
    items={
      {decorID=3890, decorType="Ornamental", source={type="vendor", itemID=247750, currency="2500", currencytype="Honor"}, requirements={achievement={id=40612}}},
      {decorID=9244, decorType="Misc Accents", source={type="vendor", itemID=253170, currency="750", currencytype="Honor"}, requirements={achievement={id=40210}}},
    }
  },
  {
    title="Sathren Azuredawn",
    source={
      id=259864,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2437:0314:1871",
    },
    items={
      --       {decorID=1159, decorType="Ornamental", source={type="vendor", itemID=253485}}, -- Early Access / Midnight pre-patch
      --       {decorID=1160, decorType="Ornamental", source={type="vendor", itemID=253488}}, -- Early Access / Midnight pre-patch
      --       {decorID=1173, decorType="Small Lights", source={type="vendor", itemID=243106, currency="150", currencytype="War Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1195, decorType="Storage", source={type="vendor", itemID=245282, currency="500", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1442, decorType="Ornamental", source={type="vendor", itemID=244538}}, -- Early Access / Midnight pre-patch
      --       {decorID=1489, decorType="Tables and Desks", source={type="vendor", itemID=244783, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1908, decorType="Small Lights", source={type="vendor", itemID=245992}}, -- Early Access / Midnight pre-patch
      --       {decorID=8872, decorType="Food and Drink", source={type="vendor", itemID=251909, currency="500", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8874, decorType="Food and Drink", source={type="vendor", itemID=251911, currency="500", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8875, decorType="Food and Drink", source={type="vendor", itemID=251912, currency="500", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10542, decorType="Uncategorized", source={type="vendor", itemID=254773, currency="1500", currencytype="Garrison Resources"}, requirements={achievement={id=62288}}}, -- Early Access / Midnight pre-patch
      --       {decorID=11470, decorType="Ornamental", source={type="vendor", itemID=257367, currency="250", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=61507}}}, -- Early Access / Midnight pre-patch
      --       {decorID=14977, decorType="Food and Drink", source={type="vendor", itemID=263211}}, -- Early Access / Midnight pre-patch
      --       {decorID=15062, decorType="Storage", source={type="vendor", itemID=263231, currency="10", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15483, decorType="Ornamental", source={type="vendor", itemID=264248}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Armorer Goldcrest",
    source={
      id=242725,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4354:4750",
    },
    items={
      --       {decorID=14970, decorType="Storage", source={type="vendor", itemID=263203, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15505, decorType="Ornamental", source={type="vendor", itemID=264270}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Waxmonger Squick",
    source={
      id=221390,
      type="vendor",
      faction="Neutral",
      zone="Gundargaz, Ringing Deeps",
      worldmap="2214:4320:3279",
    },
    items={
      {decorID=9236, decorType="Storage", source={type="vendor", itemID=253162, currency="600", currencytype="Resonance Crystals"}},
    }
  },
  {
    title="Auditor Balwurz",
    source={
      id=223728,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:3920:2440",
    },
    items={
      {decorID=760, decorType="Ornamental", source={type="vendor", itemID=245295, currency="1000", currencytype="Resonance Crystals"}},
      {decorID=761, decorType="Ornamental", source={type="vendor", itemID=245296, currency="1000", currencytype="Resonance Crystals"}},
      {decorID=762, decorType="Ornamental", source={type="vendor", itemID=245297, currency="1000", currencytype="Resonance Crystals"}},
      {decorID=1750, decorType="Windows", source={type="vendor", itemID=245561, currency="620", currencytype="Resonance Crystals"}},
      {decorID=9242, decorType="Storage", source={type="vendor", itemID=253168, currency="600", currencytype="Resonance Crystals"}},
    }
  },
  {
    title="Ranger Allorn",
    source={
      id=242724,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4344:4756",
    },
    items={
      --       {decorID=5564, decorType="Large Structures", source={type="vendor", itemID=249559, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14978, decorType="Misc Accents", source={type="vendor", itemID=263212, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14979, decorType="Storage", source={type="vendor", itemID=263216}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Mothkeeper Wew'tam",
    source={
      id=251259,
      type="vendor",
      faction="Alliance",
      zone="Harandar",
      worldmap="2413:4925:5433",
    },
    items={
      --       {decorID=14824, decorType="Beds", source={type="vendor", itemID=263038}}, -- Early Access / Midnight pre-patch
      --       {decorID=15478, decorType="Ornamental", source={type="vendor", itemID=264243}}, -- Early Access / Midnight pre-patch
      --       {decorID=15480, decorType="Floor", source={type="vendor", itemID=264245}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Naynar",
    source={
      id=240407,
      type="vendor",
      faction="Alliance",
      zone="Harandar",
      worldmap="2413:5095:5073",
    },
    items={
      --       {decorID=2219, decorType="Misc Furnishings", source={type="vendor", itemID=246402}}, -- Early Access / Midnight pre-patch
      --       {decorID=2225, decorType="Misc Furnishings", source={type="vendor", itemID=246408}}, -- Early Access / Midnight pre-patch
      --       {decorID=2588, decorType="Food and Drink", source={type="vendor", itemID=246959, currency="500", currencytype="Order Resources"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2589, decorType="Misc Furnishings", source={type="vendor", itemID=246960, currency="250", currencytype="Dragon Isles Supplies"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8916, decorType="Misc Furnishings", source={type="vendor", itemID=251980, currency="5", currencytype="Community Coupons"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14808, decorType="Wall Hangings", source={type="vendor", itemID=263019}}, -- Early Access / Midnight pre-patch
      --       {decorID=14825, decorType="Misc Lighting", source={type="vendor", itemID=263039}}, -- Early Access / Midnight pre-patch
      --       {decorID=14965, decorType="Wall Lights", source={type="vendor", itemID=263194}}, -- Early Access / Midnight pre-patch
      --       {decorID=14967, decorType="Large Lights", source={type="vendor", itemID=263195}}, -- Early Access / Midnight pre-patch
      --       {decorID=15502, decorType="Misc Nature", source={type="vendor", itemID=264267}}, -- Early Access / Midnight pre-patch
      --       {decorID=15503, decorType="Miscellaneous - All", source={type="vendor", itemID=264268}}, -- Early Access / Midnight pre-patch
      --       {decorID=15504, decorType="Misc Nature", source={type="vendor", itemID=264269}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Thraxadar",
    source={
      id=258328,
      type="vendor",
      faction="Neutral",
      zone="Masters' Perch",
      worldmap="2444:3935:8095",
    },
    items={
      --       {decorID=3922, decorType="Ornamental", source={type="vendor", itemID=247785}}, -- Early Access / Midnight pre-patch
      --       {decorID=15488, decorType="Ornamental", source={type="vendor", itemID=264253}}, -- Early Access / Midnight pre-patch
      --       {decorID=15585, decorType="Small Lights", source={type="vendor", itemID=264345}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Ando the Gat",
    source={
      id=235621,
      type="vendor",
      faction="Horde",
      zone="Liberation of Undermine",
      worldmap="2406:4329:5189",
    },
    items={
      {decorID=828, decorType="Seating", source={type="vendor", itemID=239213, currency="900", currencytype="Resonance Crystals"}},
      {decorID=1121, decorType="Ornamental", source={type="vendor", itemID=245302, currency="750", currencytype="Resonance Crystals"}, requirements={achievement={id=41119}}},
    }
  },
  {
    title="Apprentice Diell",
    source={
      id=242723,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4352:4752",
    },
    items={
      --       {decorID=14995, decorType="Misc Nature", source={type="vendor", itemID=263224, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15013, decorType="Wall Hangings", source={type="vendor", itemID=263225, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Naleidea Rivergleam",
    source={
      id=242398,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5276:7790",
    },
    items={
      --       {decorID=2503, decorType="Ceiling Lights", source={type="vendor", itemID=246779, currency="400", currencytype="Dragon Isles Supplies"}}, -- Early Access / Midnight pre-patch
      --       {decorID=7780, decorType="Misc Furnishings", source={type="vendor", itemID=250770, currency="250", currencytype="Dragon Isles Supplies"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Rocco Razzboom",
    source={
      id=231406,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:3915:2220",
    },
    items={
      {decorID=1259, decorType="Seating", source={type="vendor", itemID=245313, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10889, decorType="Small Lights", source={type="vendor", itemID=255674, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Thripps",
    source={
      id=218202,
      type="vendor",
      faction="Horde",
      zone="City of Threads",
      worldmap="2213:5000:3160",
    },
    items={
      {decorID=2532, decorType="Ornamental", source={type="vendor", itemID=246866, currency="1500", currencytype="Kej"}, requirements={achievement={id=40542}}},
    }
  },
  {
    title="Street Food Vendor",
    source={
      id=239333,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:2620:4280",
    },
    items={
      {decorID=11128, decorType="Food and Drink", source={type="vendor", itemID=256328, currency="350", currencytype="Resonance Crystals"}},
    }
  },
  {
    title="Melaris",
    source={
      id=243359,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4704:5166",
    },
    items={
      --       {decorID=15402, decorType="Wall Hangings", source={type="vendor", itemID=263997}, requirements={achievement={id=42788}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Eriden",
    source={
      id=241451,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4364:5147",
    },
    items={
      --       {decorID=15403, decorType="Wall Hangings", source={type="vendor", itemID=263998}, requirements={achievement={id=42792}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Quelis",
    source={
      id=257914,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:5644:6991",
    },
    items={
      --       {decorID=15404, decorType="Wall Hangings", source={type="vendor", itemID=263999}, requirements={achievement={id=42795}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Lyna",
    source={
      id=243350,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4792:5344",
    },
    items={
      --       {decorID=15405, decorType="Wall Hangings", source={type="vendor", itemID=264000}, requirements={achievement={id=42787}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Yatheon",
    source={
      id=241453,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4347:5374",
    },
    items={
      --       {decorID=15406, decorType="Wall Hangings", source={type="vendor", itemID=264001}, requirements={achievement={id=42798}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Mowaia",
    source={
      id=258507,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5228:5411",
    },
    items={
      --       {decorID=15407, decorType="Wall Hangings", source={type="vendor", itemID=264002}, requirements={achievement={id=42797}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Amwa'ana",
    source={
      id=258480,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5241:5062",
    },
    items={
      --       {decorID=15410, decorType="Wall Hangings", source={type="vendor", itemID=264005}, requirements={achievement={id=42789}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Zaralda",
    source={
      id=243531,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4304:5599",
    },
    items={
      --       {decorID=15411, decorType="Wall Hangings", source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Hawli",
    source={
      id=258540,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5274:5069",
    },
    items={
      --       {decorID=15457, decorType="Wall Hangings", source={type="vendor", itemID=264172}, requirements={achievement={id=42791}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Lelorian",
    source={
      id=243555,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4667:5119",
    },
    items={
      --       {decorID=15409, decorType="Wall Hangings", source={type="vendor", itemID=264004}, requirements={achievement={id=42796}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Deynna",
    source={
      id=243353,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4823:5431",
    },
    items={
      --       {decorID=15459, decorType="Wall Hangings", source={type="vendor", itemID=264174}, requirements={achievement={id=42794}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Sitch Lowdown",
    source={
      id=231396,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:3078:3893",
    },
    items={
      {decorID=1268, decorType="Storage", source={type="vendor", itemID=245307, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=11127, decorType="Storage", source={type="vendor", itemID=256327, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Construct Ali'a",
    source={
      id=258181,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:5579:6605",
    },
    items={
      --       {decorID=17439, decorType="Ornamental", source={type="vendor", itemID=265681}, requirements={achievement={id=62167}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17440, decorType="Ornamental", source={type="vendor", itemID=265682}, requirements={achievement={id=62168}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17441, decorType="Ornamental", source={type="vendor", itemID=265683}, requirements={achievement={id=62173}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17442, decorType="Ornamental", source={type="vendor", itemID=265684}, requirements={achievement={id=62174}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17443, decorType="Ornamental", source={type="vendor", itemID=265685}, requirements={achievement={id=62175}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17444, decorType="Ornamental", source={type="vendor", itemID=265686}, requirements={achievement={id=62177}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17446, decorType="Ornamental", source={type="vendor", itemID=265687}, requirements={achievement={id=62178}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17447, decorType="Ornamental", source={type="vendor", itemID=265688}, requirements={achievement={id=62179}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17449, decorType="Ornamental", source={type="vendor", itemID=265689}, requirements={achievement={id=62180}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17450, decorType="Ornamental", source={type="vendor", itemID=265690}, requirements={achievement={id=62181}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17452, decorType="Ornamental", source={type="vendor", itemID=265691}, requirements={achievement={id=62182}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17453, decorType="Ornamental", source={type="vendor", itemID=265692}, requirements={achievement={id=62183}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17454, decorType="Ornamental", source={type="vendor", itemID=265694}, requirements={achievement={id=62184}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17455, decorType="Ornamental", source={type="vendor", itemID=265696}, requirements={achievement={id=62144}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17456, decorType="Ornamental", source={type="vendor", itemID=265697}, requirements={achievement={id=62153}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17457, decorType="Ornamental", source={type="vendor", itemID=265698}, requirements={achievement={id=62155}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17458, decorType="Ornamental", source={type="vendor", itemID=265699}, requirements={achievement={id=62156}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17459, decorType="Ornamental", source={type="vendor", itemID=265700}, requirements={achievement={id=62157}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17460, decorType="Ornamental", source={type="vendor", itemID=265701}, requirements={achievement={id=62159}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17462, decorType="Ornamental", source={type="vendor", itemID=265702}, requirements={achievement={id=62160}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17464, decorType="Ornamental", source={type="vendor", itemID=265703}, requirements={achievement={id=62161}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17465, decorType="Ornamental", source={type="vendor", itemID=265704}, requirements={achievement={id=62162}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17467, decorType="Ornamental", source={type="vendor", itemID=265705}, requirements={achievement={id=62163}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17469, decorType="Ornamental", source={type="vendor", itemID=265706}, requirements={achievement={id=62164}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17472, decorType="Ornamental", source={type="vendor", itemID=265707}, requirements={achievement={id=62165}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17474, decorType="Ornamental", source={type="vendor", itemID=265708}, requirements={achievement={id=62166}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17518, decorType="Misc Furnishings", source={type="vendor", itemID=265794, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17519, decorType="Misc Furnishings", source={type="vendor", itemID=265795, currency="100", currencytype="Brimming Arcana"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17520, decorType="Ornamental", source={type="vendor", itemID=265796}, requirements={achievement={id=62169}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17521, decorType="Ornamental", source={type="vendor", itemID=265797}, requirements={achievement={id=62176}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17522, decorType="Ornamental", source={type="vendor", itemID=265798}, requirements={achievement={id=62154}}}, -- Early Access / Midnight pre-patch
      --       {decorID=17523, decorType="Ornamental", source={type="vendor", itemID=265799}, requirements={achievement={id=62158}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Boatswain Hardee",
    source={
      id=231405,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:6343:1680",
    },
    items={
      {decorID=4560, decorType="Seating", source={type="vendor", itemID=248758, currency="900", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10853, decorType="Wall Lights", source={type="vendor", itemID=255642, currency="475", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Lab Assistant Laszly",
    source={
      id=231408,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:2718:7254",
    },
    items={
      {decorID=1265, decorType="Storage", source={type="vendor", itemID=245321, currency="400", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10852, decorType="Ceiling Lights", source={type="vendor", itemID=255641, currency="500", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Blair Bass",
    source={
      id=226994,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:3400:7080",
    },
    items={
      {decorID=1277, decorType="Misc Furnishings", source={type="vendor", itemID=245309, currency="1000", currencytype="Resonance Crystals"}},
    }
  },
  {
    title="Shredz the Scrapper",
    source={
      id=231407,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:5334:7269",
    },
    items={
      {decorID=1269, decorType="Storage", source={type="vendor", itemID=245311, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10857, decorType="Ornamental", source={type="vendor", itemID=255647, currency="650", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Jorid",
    source={
      id=219318,
      type="vendor",
      faction="Horde",
      zone="Dornogal",
      worldmap="2339:5700:6060",
    },
    items={
      {decorID=2533, decorType="Ornamental", source={type="vendor", itemID=246867, currency="750", currencytype="Resonance Crystals"}, requirements={achievement={id=41186}}},
    }
  },
  {
    title="Smaks Topskimmer",
    source={
      id=231409,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:4380:5080",
    },
    items={
      {decorID=1257, decorType="Tables and Desks", source={type="vendor", itemID=245314, currency="850", currencytype="Resonance Crystals"}},
      {decorID=1258, decorType="Tables and Desks", source={type="vendor", itemID=243312, currency="900", currencytype="Resonance Crystals"}},
      {decorID=1262, decorType="Misc Structural", source={type="vendor", itemID=245319, currency="350", currencytype="Resonance Crystals"}},
      {decorID=1263, decorType="Misc Structural", source={type="vendor", itemID=245318, currency="450", currencytype="Resonance Crystals"}},
    }
  },
}
