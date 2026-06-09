local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["EasternKingdoms"] = {

  {
    source={
      id=2140,
      type="vendor",
      faction="Horde",
      zone="Silverpine Forest",
      worldmap="21:4410:3970"
    },
    items={
      {decorID=11498, source={type="vendor", itemID=257412, currency="142", currencytype="50"}, requirements={quest={id=27550}}},
    }
  },

  {
    source={
      id=3178,
      type="vendor",
      faction="Alliance",
      zone="Wetlands",
      worldmap="56:0630:5750"
    },
    items={
      {decorID=11495, source={type="vendor", itemID=257405}},
    }
  },

  {
    source={
      id=13217,
      type="vendor",
      faction="Alliance",
      zone="Hillsbrad Foothills",
      worldmap="25:4480:4640"
    },
    items={
      {decorID=2241, source={type="vendor", itemID=246424, currency="1", currencytype="Mark of Honor"}},
    }
  },

  {
    source={
      id=14624,
      type="vendor",
      faction="Neutral",
      zone="Searing Gorge",
      worldmap="32:3860:2870"
    },
    items={
      {decorID=1315, source={type="vendor", itemID=245333}, requirements={quest={id=28035}}},
      {decorID=2226, source={type="vendor", itemID=246409}, requirements={quest={id=28064}}},
    }
  },

  {
    source={
      id=44337,
      type="vendor",
      faction="Alliance",
      zone="Surwich, Blasted Lands",
      worldmap="17:4580:8860"
    },
    items={
      {decorID=1481, source={type="vendor", itemID=244777}, requirements={quest={id=25720}}},
    }
  },

  {
    source={
      id=45417,
      type="vendor",
      faction="Neutral",
      zone="E. Plaguelands",
      worldmap="23:4480:5300"
    },
    items={
      {decorID=4813, source={type="vendor", itemID=248796}, requirements={achievement={id=5442}}},
    }
  },

  {
    source={
      id=49386,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap=""
    },
    items={
--       {decorID=1998, source={type="vendor", itemID=246108}}, -- missing verified worldmap
--       {decorID=2242, source={type="vendor", itemID=246425}}, -- missing verified worldmap
    }
  },

  {
    source={
      id=49877,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap=""
    },
    items={
--       {decorID=4402, source={type="vendor", itemID=248333}}, -- missing verified worldmap
--       {decorID=4443, source={type="vendor", itemID=248617, currency="142", currencytype="50"}}, -- missing verified worldmap
--       {decorID=4445, source={type="vendor", itemID=248619, currency="237", currencytype="50"}}, -- missing verified worldmap
--       {decorID=4446, source={type="vendor", itemID=248620, currency="142", currencytype="50"}}, -- missing verified worldmap
--       {decorID=4490, source={type="vendor", itemID=248665, currency="237", currencytype="50"}}, -- missing verified worldmap
--       {decorID=4811, source={type="vendor", itemID=248794, currency="47", currencytype="50"}}, -- missing verified worldmap
--       {decorID=4812, source={type="vendor", itemID=248795, currency="71", currencytype="25"}}, -- missing verified worldmap
--       {decorID=5116, source={type="vendor", itemID=248939}}, -- missing verified worldmap
    }
  },

  {
    source={
      id=49877,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:6775:7306"
    },
    items={
      {decorID=4405, source={type="vendor", itemID=248336}, requirements={quest={id=59583}}},
      {decorID=4444, source={type="vendor", itemID=248618}, requirements={quest={id=26270}}},
      {decorID=4447, source={type="vendor", itemID=248621}, requirements={quest={id=26390}}},
      {decorID=4487, source={type="vendor", itemID=248662}, requirements={quest={id=543}}},
      {decorID=4814, source={type="vendor", itemID=248797}, requirements={quest={id=26229}}},
      {decorID=4815, source={type="vendor", itemID=248798}, requirements={quest={id=54}}},
      {decorID=4819, source={type="vendor", itemID=248801}, requirements={quest={id=26297}}},
      {decorID=5115, source={type="vendor", itemID=248938, currency="142", currencytype="50"}, requirements={quest={id=60}}},
      {decorID=11274, source={type="vendor", itemID=256673}, requirements={quest={id=7604}}},
    }
  },

  {
    source={
      id=49877,
      type="vendor",
      faction="Neutral",
      zone="Trade District, Stormwind",
      worldmap="84:6760:7280"
    },
    items={
      {decorID=9242, source={type="vendor", itemID=253168}},
    }
  },

  {
    source={
      id=50304,
      type="vendor",
      faction="Horde",
      zone="Undercity",
      worldmap="90:6320:4900"
    },
    items={
      {decorID=923, source={type="vendor", itemID=245504, currency="127", currencytype="50"}, requirements={quest={id=27098}}},
      {decorID=924, source={type="vendor", itemID=245505}, requirements={quest={id=27098}}},
    }
  },

  {
    source={
      id=50309,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh",
      worldmap="87:5600:4700"
    },
    items={
      {decorID=2243, source={type="vendor", itemID=246426}},
      {decorID=2333, source={type="vendor", itemID=246490, currency="237", currencytype="50"}},
      {decorID=2334, source={type="vendor", itemID=246491, currency="142", currencytype="50"}},
      {decorID=8982, source={type="vendor", itemID=252010, currency="427", currencytype="50"}},
      {decorID=11133, source={type="vendor", itemID=256333}},
    }
  },

  {
    source={
      id=68363,
      type="vendor",
      faction="Neutral",
      zone="Bizmo's Brawlpub",
      worldmap=""
    },
    items={
--       {decorID=10913, source={type="vendor", itemID=255840}}, -- missing verified worldmap
--       {decorID=12263, source={type="vendor", itemID=259071}}, -- missing verified worldmap
--       {decorID=14815, source={type="vendor", itemID=263026}}, -- missing verified worldmap
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
      {decorID=7572, source={type="vendor", itemID=250231, currency="500", currencytype=1220}},
      {decorID=7573, source={type="vendor", itemID=250232, currency="500", currencytype=1220}},
      {decorID=7576, source={type="vendor", itemID=250235, currency="1000", currencytype=1220}},
      {decorID=7577, source={type="vendor", itemID=250236, currency="2000", currencytype=1220}, requirements={achievement={id=60987}}},
    }
  },

  {
    source={
      id=115805,
      type="vendor",
      faction="Neutral",
      zone="Chiselgrip",
      worldmap="36:4680:4460"
    },
    items={
      {decorID=11131, source={type="vendor", itemID=256331}, requirements={quest={id=28183}}},
    }
  },

  {
    source={
      id=190155,
      type="vendor",
      faction="Neutral",
      zone="Bel'ameth",
      worldmap="217:5020:6180"
    },
    items={
      {decorID=2529, source={type="vendor", itemID=246863, currency="500", currencytype=2003}, requirements={quest={id=66001}}},
    }
  },

  {
    source={
      id=196637,
      type="vendor",
      faction="Neutral",
      zone="Bel'ameth",
      worldmap="217:5060:6240"
    },
    items={
      {decorID=5556, source={type="vendor", itemID=249545}},
      {decorID=5558, source={type="vendor", itemID=249547}},
      {decorID=5559, source={type="vendor", itemID=249548}},
      {decorID=5560, source={type="vendor", itemID=249549, currency="300", currencytype="& 200 Dragon Isles Supplies"}},
      {decorID=5689, source={type="vendor", itemID=249824}},
    }
  },

  {
    source={
      id=211065,
      type="vendor",
      faction="Neutral",
      zone="Bel'ameth",
      worldmap="217:5800:4120"
    },
    items={
      {decorID=857, source={type="vendor", itemID=245520}, requirements={achievement={id=19719}}},
      {decorID=859, source={type="vendor", itemID=245516}},
      {decorID=860, source={type="vendor", itemID=245515}},
      {decorID=1795, source={type="vendor", itemID=245604}},
      {decorID=1826, source={type="vendor", itemID=245617}},
      {decorID=11944, source={type="vendor", itemID=258301}},
    }
  },

  {
    source={
      id=249196,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4960:8120"
    },
    items={
      {decorID=714, source={type="vendor", itemID=245284, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, requirements={rep="true"}},
      {decorID=1227, source={type="vendor", itemID=251997, costs={{currency="5000", currencytype=2815},{currency="75", currencytype=3319}}}, requirements={rep="true"}},
      {decorID=1236, source={type="vendor", itemID=245330, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, requirements={rep="true"}},
    }
  },

  {
    source={
      id=253227,
      type="vendor",
      faction="Alliance",
      zone="Highbank",
      worldmap="241:7280:4700"
    },
    items={
      {decorID=1998, source={type="vendor", itemID=246108}},
      {decorID=2242, source={type="vendor", itemID=246425}},
      {decorID=2244, source={type="vendor", itemID=246427}, requirements={quest={id=28244}}},
      {decorID=2245, source={type="vendor", itemID=246428}, requirements={quest={id=28655}}},
    }
  },

  {
    source={
      id=253232,
      type="vendor",
      faction="Alliance",
      zone="Ironforge",
      worldmap="87:7610:0820"
    },
    items={
      {decorID=2228, source={type="vendor", itemID=246411}},
      {decorID=2229, source={type="vendor", itemID=246412}},
    }
  },

  {
    source={
      id=253235,
      type="vendor",
      faction="Neutral",
      zone="Dun Morogh",
      worldmap=""
    },
    items={
--       {decorID=2243, source={type="vendor", itemID=246426}}, -- missing verified worldmap
--       {decorID=2333, source={type="vendor", itemID=246490, currency="237", currencytype="50"}}, -- missing verified worldmap
--       {decorID=2334, source={type="vendor", itemID=246491, currency="142", currencytype="50"}}, -- missing verified worldmap
--       {decorID=8982, source={type="vendor", itemID=252010, currency="427", currencytype="50"}}, -- missing verified worldmap
--       {decorID=11133, source={type="vendor", itemID=256333}}, -- missing verified worldmap
    }
  },

  {
    source={
      id=253235,
      type="vendor",
      faction="Neutral",
      zone="Dun Morogh",
      worldmap="87:2481:4396"
    },
    items={
      {decorID=1118, source={type="vendor", itemID=245427}, requirements={quest={id=53566}}},
      {decorID=1216, source={type="vendor", itemID=245426}, requirements={achievement={id=4859}}},
      {decorID=11160, source={type="vendor", itemID=256425}, requirements={achievement={id=8316}}},
    }
  },

  {
    source={
      id=254603,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City",
      worldmap="84:7780:6580"
    },
    items={
      {decorID=3880, source={type="vendor", itemID=247740, costs={{currency="2000", currencytype=1792},{currency="2000", currencytype=1792}}}, requirements={achievement={id=6981}}},
      {decorID=3881, source={type="vendor", itemID=247741, costs={{currency="1000", currencytype=1792},{currency="1000", currencytype=1792}}}, requirements={achievement={id=6981}}},
      {decorID=3884, source={type="vendor", itemID=247744, currency="1000", currencytype=1792}, requirements={achievement={id=231}}},
      {decorID=3886, source={type="vendor", itemID=247746, currency="800", currencytype=1792}, requirements={achievement={id=200}}},
      {decorID=3890, source={type="vendor", itemID=247750, costs={{currency="2500", currencytype=1792},{currency="2500", currencytype=1792}}}, requirements={achievement={id=40612}}},
      {decorID=3893, source={type="vendor", itemID=247756, costs={{currency="1000", currencytype=1792},{currency="1000", currencytype=1792}}}, requirements={achievement={id=1157}}},
      {decorID=3894, source={type="vendor", itemID=247757, currency="600", currencytype=1792}, requirements={achievement={id=158}}},
      {decorID=3895, source={type="vendor", itemID=247758, currency="1200", currencytype=1792}, requirements={achievement={id=221}}},
      {decorID=3898, source={type="vendor", itemID=247761, costs={{currency="400", currencytype=1792},{currency="400", currencytype=1792}}}, requirements={achievement={id=212}}},
      {decorID=3899, source={type="vendor", itemID=247762, costs={{currency="300", currencytype=1792},{currency="300", currencytype=1792}}}, requirements={achievement={id=213}}},
      {decorID=3900, source={type="vendor", itemID=247763, costs={{currency="5", currencytype="Mark of Honor"},{currency="5", currencytype="Mark of Honor"}}}, requirements={achievement={id=61683}}},
      {decorID=3902, source={type="vendor", itemID=247765, costs={{currency="5", currencytype="Mark of Honor"},{currency="5", currencytype="Mark of Honor"}}}, requirements={achievement={id=61687}}},
      {decorID=3903, source={type="vendor", itemID=247766, costs={{currency="5", currencytype="Mark of Honor"},{currency="5", currencytype="Mark of Honor"}}}, requirements={achievement={id=61688}}},
      {decorID=3905, source={type="vendor", itemID=247768, costs={{currency="5", currencytype="Mark of Honor"},{currency="5", currencytype="Mark of Honor"}}}, requirements={achievement={id=61684}}},
      {decorID=3906, source={type="vendor", itemID=247769, costs={{currency="5", currencytype="Mark of Honor"},{currency="5", currencytype="Mark of Honor"}}}, requirements={achievement={id=61685}}},
      {decorID=3907, source={type="vendor", itemID=247770, costs={{currency="2", currencytype="Mark of Honor"},{currency="2", currencytype="Mark of Honor"}}}, requirements={achievement={id=61686}}},
      {decorID=9244, source={type="vendor", itemID=253170, costs={{currency="750", currencytype=1792},{currency="750", currencytype=1792},{currency="750", currencytype=1792}}}, requirements={achievement={id=40210}}},
      {decorID=11296, source={type="vendor", itemID=256896, costs={{currency="450", currencytype=1792},{currency="450", currencytype=1792}}}, requirements={achievement={id=5245}}},
    }
  },

  {
    source={
      id=256071,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:4926:8009"
    },
    items={
      {decorID=2511, source={type="vendor", itemID=246845}},
      {decorID=2513, source={type="vendor", itemID=246847}},
      {decorID=2514, source={type="vendor", itemID=246848}},
      {decorID=2526, source={type="vendor", itemID=246860}},
    }
  },

  {
    source={
      id=261231,
      type="vendor",
      faction="Neutral",
      zone="Stormwind City",
      worldmap="84:4851:6876"
    },
    items={
      {decorID=14467, source={type="vendor", itemID=260785}, requirements={achievement={id=62387}}},
    }
  },

}
