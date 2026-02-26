local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["EasternKingdoms"] = {

  {
    source={
      id=1247,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh",
      worldmap="469:9392:7091"
    },
    items={
      {decorID=11130, source={type="vendor", itemID=256330, currency="190", currencytype="gold"}},
    }
  },

  {
    source={
      id=2140,
      type="vendor",
      faction="Horde",
      zone="Silverpine Forest",
      worldmap="21:4406:3968"
    },
    items={
      {decorID=11498, source={type="vendor", itemID=257412, costs={{currency="142", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={quest={id=27550}}},
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
      {decorID=2241, source={type="vendor", itemID=246424}},
    }
  },

  {
    source={
      id=14624,
      type="vendor",
      faction="Horde",
      zone="Searing Gorge",
      worldmap="32:3860:2870"
    },
    items={
      {decorID=1315, source={type="vendor", itemID=245333, currency="150", currencytype="gold"}, requirements={quest={id=28035}}},
      {decorID=2226, source={type="vendor", itemID=246409, currency="700", currencytype="gold"}, requirements={quest={id=28064}}},
    }
  },

  {
    source={
      id=44114,
      type="vendor",
      faction="Alliance",
      zone="Duskwood",
      worldmap="47:2027:5835"
    },
    items={
      {decorID=1833, source={type="vendor", itemID=245624, currency="150", currencytype="gold"}, requirements={quest={id=26760}}},
      {decorID=11305, source={type="vendor", itemID=256905, currency="175", currencytype="gold"}, requirements={quest={id=26754}}},
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
      {decorID=1481, source={type="vendor", itemID=244777, currency="1100", currencytype="gold"}},
    }
  },

  {
    source={
      id=45417,
      type="vendor",
      faction="Neutral",
      zone="Light's Hope Chapel",
      worldmap="23:7380:5220"
    },
    items={
      {decorID=4813, source={type="vendor", itemID=248796, currency="3000", currencytype="gold"}, requirements={achievement={id=5442}}},
    }
  },

  {
    source={
      id=49386,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4861:3068"
    },
    items={
      {decorID=1998, source={type="vendor", itemID=246108, currency="2000", currencytype="gold"}, requirements={rep="true"}},
      {decorID=2242, source={type="vendor", itemID=246425, currency="400", currencytype="gold"}, requirements={rep="true"}},
    }
  },

  {
    source={
      id=49877,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City",
      worldmap="84:6775:7306"
    },
    items={
      {decorID=4402, source={type="vendor", itemID=248333, currency="95", currencytype="gold"}, requirements={rep="true"}},
      {decorID=4405, source={type="vendor", itemID=248336, currency="285", currencytype="gold"}, requirements={quest={id=59583}}},
      {decorID=4443, source={type="vendor", itemID=248617, costs={{currency="142", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=4444, source={type="vendor", itemID=248618, currency="190", currencytype="gold"}, requirements={quest={id=26270}}},
      {decorID=4445, source={type="vendor", itemID=248619, costs={{currency="237", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=4446, source={type="vendor", itemID=248620, costs={{currency="142", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=4447, source={type="vendor", itemID=248621, currency="285", currencytype="gold"}, requirements={quest={id=26390}}},
      {decorID=4487, source={type="vendor", itemID=248662, currency="475", currencytype="gold"}, requirements={quest={id=543}}},
      {decorID=4490, source={type="vendor", itemID=248665, costs={{currency="237", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=4811, source={type="vendor", itemID=248794, costs={{currency="47", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=4812, source={type="vendor", itemID=248795, costs={{currency="71", currencytype="gold"},{currency="25", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=4814, source={type="vendor", itemID=248797, costs={{currency="47", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={quest={id=26229}}},
      {decorID=4815, source={type="vendor", itemID=248798, currency="190", currencytype="gold"}, requirements={quest={id=54}}},
      {decorID=4819, source={type="vendor", itemID=248801, currency="95", currencytype="gold"}, requirements={quest={id=26297}}},
      {decorID=5115, source={type="vendor", itemID=248938, costs={{currency="142", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={quest={id=60}}},
      {decorID=5116, source={type="vendor", itemID=248939, currency="95", currencytype="gold"}, requirements={rep="true"}},
      {decorID=9242, source={type="vendor", itemID=253168, currency="95", currencytype="silver"}},
      {decorID=11274, source={type="vendor", itemID=256673, currency="950", currencytype="gold"}, requirements={quest={id=7604}}},
    }
  },

  {
    source={
      id=50304,
      type="vendor",
      faction="Horde",
      zone="Undercity, Orgrimmar",
      worldmap="90:6320:4900"
    },
    items={
      {decorID=923, source={type="vendor", itemID=245504, costs={{currency="127", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={quest={id=27098}}},
      {decorID=924, source={type="vendor", itemID=245505, currency="85", currencytype="gold"}, requirements={quest={id=27098}}},
    }
  },

  {
    source={
      id=50309,
      type="vendor",
      faction="Alliance",
      zone="Ironforge",
      worldmap="87:5560:4820"
    },
    items={
      {decorID=2243, source={type="vendor", itemID=246426, currency="570", currencytype="gold"}, requirements={rep="true"}},
      {decorID=2333, source={type="vendor", itemID=246490, costs={{currency="237", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=2334, source={type="vendor", itemID=246491, costs={{currency="142", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=8982, source={type="vendor", itemID=252010, costs={{currency="427", currencytype="gold"},{currency="50", currencytype="silver"}}}, requirements={rep="true"}},
      {decorID=11133, source={type="vendor", itemID=256333, currency="950", currencytype="gold"}, requirements={rep="true"}},
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
      faction="Horde",
      zone="Burning Steppes",
      worldmap="36:4680:4460"
    },
    items={
      {decorID=11131, source={type="vendor", itemID=256331, currency="450", currencytype="gold"}},
    }
  },

  {
    source={
      id=142115,
      type="vendor",
      faction="Alliance",
      zone="Boralus Harbor",
      worldmap="23:7380:5220"
    },
    items={
      {decorID=4813, source={type="vendor", itemID=248796, currency="3000", currencytype="gold"}, requirements={achievement={id=5442}}},
    }
  },

  {
    source={
      id=211065,
      type="vendor",
      faction="Alliance",
      zone="Stormglen Village, Gilneas",
      worldmap="217:6040:9240"
    },
    items={
      {decorID=857, source={type="vendor", itemID=245520, currency="150", currencytype="gold"}, requirements={achievement={id=19719}}},
      {decorID=859, source={type="vendor", itemID=245516, currency="75", currencytype="gold"}},
      {decorID=860, source={type="vendor", itemID=245515, currency="75", currencytype="gold"}},
      {decorID=1795, source={type="vendor", itemID=245604, currency="100", currencytype="gold"}},
      {decorID=1826, source={type="vendor", itemID=245617, currency="100", currencytype="gold"}},
      {decorID=11944, source={type="vendor", itemID=258301, currency="125", currencytype="gold"}},
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
      {decorID=714, source={type="vendor", itemID=245284, currency="50", currencytype=3319}},
      {decorID=1227, source={type="vendor", itemID=251997, currency="75", currencytype=3319}},
      {decorID=1236, source={type="vendor", itemID=245330, currency="50", currencytype=3319}},
    }
  },

  {
    source={
      id=253227,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4974:2957"
    },
    items={
      {decorID=1998, source={type="vendor", itemID=246108, currency="2000", currencytype="gold"}, requirements={rep="true"}},
      {decorID=2242, source={type="vendor", itemID=246425, currency="400", currencytype="gold"}, requirements={rep="true"}},
      {decorID=2244, source={type="vendor", itemID=246427, currency="1000", currencytype="gold"}, requirements={quest={id=28244}}},
      {decorID=2245, source={type="vendor", itemID=246428, currency="1500", currencytype="gold"}, requirements={quest={id=28655}}},
    }
  },

  {
    source={
      id=253232,
      type="vendor",
      faction="Alliance",
      zone="The Library, Ironforge",
      worldmap="87:7580:940"
    },
    items={
      {decorID=2228, source={type="vendor", itemID=246411, currency="700", currencytype="gold"}},
      {decorID=2229, source={type="vendor", itemID=246412, currency="450", currencytype="gold"}},
    }
  },

  {
    source={
      id=253235,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh",
      worldmap="87:2481:4396"
    },
    items={
      {decorID=1118, source={type="vendor", itemID=245427, currency="1200", currencytype="gold"}, requirements={quest={id=53566}}},
      {decorID=1216, source={type="vendor", itemID=245426, currency="700", currencytype="gold"}, requirements={achievement={id=4859}}},
      {decorID=2243, source={type="vendor", itemID=246426, currency="600", currencytype="gold"}, requirements={rep="true"}},
      {decorID=2333, source={type="vendor", itemID=246490, currency="250", currencytype="gold"}, requirements={rep="true"}},
      {decorID=2334, source={type="vendor", itemID=246491, currency="150", currencytype="gold"}, requirements={rep="true"}},
      {decorID=8982, source={type="vendor", itemID=252010, currency="450", currencytype="gold"}, requirements={rep="true"}},
      {decorID=11133, source={type="vendor", itemID=256333, currency="1000", currencytype="gold"}, requirements={rep="true"}},
      {decorID=11160, source={type="vendor", itemID=256425, currency="350", currencytype="gold"}, requirements={achievement={id=8316}}},
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
      {decorID=3880, source={type="vendor", itemID=247740, currency="2000", currencytype=1792}, requirements={achievement={id=6981}}},
      {decorID=3881, source={type="vendor", itemID=247741, currency="1000", currencytype=1792}, requirements={achievement={id=6981}}},
      {decorID=3884, source={type="vendor", itemID=247744, currency="1000", currencytype=1792}, requirements={achievement={id=231}}},
      {decorID=3886, source={type="vendor", itemID=247746, currency="800", currencytype=1792}, requirements={achievement={id=200}}},
      {decorID=3890, source={type="vendor", itemID=247750, currency="2500", currencytype=1792}, requirements={achievement={id=40612}}},
      {decorID=3893, source={type="vendor", itemID=247756, currency="1000", currencytype=1792}, requirements={achievement={id=1157}}},
      {decorID=3894, source={type="vendor", itemID=247757, currency="600", currencytype=1792}, requirements={achievement={id=158}}},
      {decorID=3895, source={type="vendor", itemID=247758, currency="1200", currencytype=1792}, requirements={achievement={id=221}}},
      {decorID=3898, source={type="vendor", itemID=247761, currency="400", currencytype=1792}, requirements={achievement={id=212}}},
      {decorID=3899, source={type="vendor", itemID=247762, currency="300", currencytype=1792}, requirements={achievement={id=213}}},
      {decorID=3900, source={type="vendor", itemID=247763}, requirements={achievement={id=61683}}},
      {decorID=3902, source={type="vendor", itemID=247765}, requirements={achievement={id=61687}}},
      {decorID=3903, source={type="vendor", itemID=247766}, requirements={achievement={id=61688}}},
      {decorID=3905, source={type="vendor", itemID=247768}, requirements={achievement={id=61684}}},
      {decorID=3906, source={type="vendor", itemID=247769}, requirements={achievement={id=61685}}},
      {decorID=3907, source={type="vendor", itemID=247770}, requirements={achievement={id=61686}}},
      {decorID=9244, source={type="vendor", itemID=253170, currency="750", currencytype=1792}, requirements={achievement={id=40210}}},
      {decorID=11296, source={type="vendor", itemID=256896, currency="450", currencytype=1792}, requirements={achievement={id=5245}}},
    }
  },

  {
    source={
      id=256071,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City",
      worldmap="84:4926:8009"
    },
    items={
      {decorID=766, source={type="vendor", itemID=239177, currency="2000", currencytype="gold"}},
      {decorID=768, source={type="vendor", itemID=239179, currency="2000", currencytype="gold"}},
      {decorID=2511, source={type="vendor", itemID=246845, currency="2000", currencytype="gold"}},
      {decorID=2513, source={type="vendor", itemID=246847, currency="2000", currencytype="gold"}},
      {decorID=2514, source={type="vendor", itemID=246848, currency="2000", currencytype="gold"}},
      {decorID=2526, source={type="vendor", itemID=246860, currency="2000", currencytype="gold"}},
    }
  },

  {
    source={
      id=256119,
      type="vendor",
      faction="Horde",
      zone="Orgrimmar",
      worldmap="86:9987:1210"
    },
    items={
      {decorID=766, source={type="vendor", itemID=239177, currency="2000", currencytype="gold"}},
      {decorID=768, source={type="vendor", itemID=239179, currency="2000", currencytype="gold"}},
      {decorID=2511, source={type="vendor", itemID=246845, currency="2000", currencytype="gold"}},
      {decorID=2513, source={type="vendor", itemID=246847, currency="2000", currencytype="gold"}},
      {decorID=2514, source={type="vendor", itemID=246848, currency="2000", currencytype="gold"}},
      {decorID=2526, source={type="vendor", itemID=246860, currency="2000", currencytype="gold"}},
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
      {decorID=11287, source={type="vendor", itemID=256764}},
      {decorID=14467, source={type="vendor", itemID=260785, currency="1350", currencytype="gold"}, requirements={achievement={id=62387}}},
--       {decorID=15070, source={type="vendor", itemID=263239}} -- EA_NOTE,
--       {decorID=15072, source={type="vendor", itemID=263241}} -- EA_NOTE,
--       {decorID=15073, source={type="vendor", itemID=263242}} -- EA_NOTE,
--       {decorID=15074, source={type="vendor", itemID=263243}} -- EA_NOTE,
--       {decorID=15142, source={type="vendor", itemID=263292}} -- EA_NOTE,
--       {decorID=15143, source={type="vendor", itemID=263293}} -- EA_NOTE,
--       {decorID=15144, source={type="vendor", itemID=263294}} -- EA_NOTE,
--       {decorID=15145, source={type="vendor", itemID=263295}} -- EA_NOTE,
--       {decorID=15146, source={type="vendor", itemID=263296}} -- EA_NOTE,
--       {decorID=15147, source={type="vendor", itemID=263297}} -- EA_NOTE,
--       {decorID=15148, source={type="vendor", itemID=263298}} -- EA_NOTE,
--       {decorID=15149, source={type="vendor", itemID=263299}} -- EA_NOTE,
--       {decorID=15150, source={type="vendor", itemID=263300}} -- EA_NOTE,
      {decorID=15151, source={type="vendor", itemID=263301}},
--       {decorID=15152, source={type="vendor", itemID=263302}} -- EA_NOTE,
--       {decorID=15153, source={type="vendor", itemID=263303}} -- EA_NOTE,
--       {decorID=15229, source={type="vendor", itemID=263383}} -- EA_NOTE,
--       {decorID=15550, source={type="vendor", itemID=264278}} -- EA_NOTE,
--       {decorID=15551, source={type="vendor", itemID=264279}} -- EA_NOTE,
--       {decorID=15552, source={type="vendor", itemID=264280}} -- EA_NOTE,
--       {decorID=15553, source={type="vendor", itemID=264281}} -- EA_NOTE,
--       {decorID=15554, source={type="vendor", itemID=264282}} -- EA_NOTE,
--       {decorID=15555, source={type="vendor", itemID=264283}} -- EA_NOTE,
--       {decorID=15654, source={type="vendor", itemID=264384}} -- EA_NOTE,
      {decorID=15668, source={type="vendor", itemID=264396}},
--       {decorID=15669, source={type="vendor", itemID=264397}} -- EA_NOTE,
--       {decorID=16027, source={type="vendor", itemID=264680}} -- EA_NOTE,
--       {decorID=16028, source={type="vendor", itemID=264681}} -- EA_NOTE,
--       {decorID=16029, source={type="vendor", itemID=264682}} -- EA_NOTE,
--       {decorID=16030, source={type="vendor", itemID=264683}} -- EA_NOTE,
--       {decorID=16031, source={type="vendor", itemID=264684}} -- EA_NOTE,
--       {decorID=16032, source={type="vendor", itemID=264685}} -- EA_NOTE,
--       {decorID=16033, source={type="vendor", itemID=264686}} -- EA_NOTE,
--       {decorID=16034, source={type="vendor", itemID=264687}} -- EA_NOTE,
--       {decorID=16035, source={type="vendor", itemID=264688}} -- EA_NOTE,
--       {decorID=16036, source={type="vendor", itemID=264689}} -- EA_NOTE,
--       {decorID=16037, source={type="vendor", itemID=264690}} -- EA_NOTE,
--       {decorID=16038, source={type="vendor", itemID=264691}} -- EA_NOTE,
--       {decorID=16811, source={type="vendor", itemID=265387}} -- EA_NOTE,
--       {decorID=16812, source={type="vendor", itemID=265388}} -- EA_NOTE,
--       {decorID=16813, source={type="vendor", itemID=265389}} -- EA_NOTE,
--       {decorID=16814, source={type="vendor", itemID=265390}} -- EA_NOTE,
--       {decorID=16815, source={type="vendor", itemID=265391}} -- EA_NOTE,
--       {decorID=16816, source={type="vendor", itemID=265392}} -- EA_NOTE,
--       {decorID=16817, source={type="vendor", itemID=265393}} -- EA_NOTE,
--       {decorID=16818, source={type="vendor", itemID=265394}} -- EA_NOTE,
--       {decorID=16819, source={type="vendor", itemID=265395}} -- EA_NOTE,
--       {decorID=16820, source={type="vendor", itemID=265396}} -- EA_NOTE,
--       {decorID=16821, source={type="vendor", itemID=265397}} -- EA_NOTE,
--       {decorID=16822, source={type="vendor", itemID=265398}} -- EA_NOTE,
--       {decorID=16964, source={type="vendor", itemID=265544}} -- EA_NOTE,
--       {decorID=16965, source={type="vendor", itemID=265545}} -- EA_NOTE,
--       {decorID=16966, source={type="vendor", itemID=265546}} -- EA_NOTE,
--       {decorID=16967, source={type="vendor", itemID=265547}} -- EA_NOTE,
--       {decorID=16968, source={type="vendor", itemID=265548}} -- EA_NOTE,
--       {decorID=16969, source={type="vendor", itemID=265549}} -- EA_NOTE,
--       {decorID=16970, source={type="vendor", itemID=265550}} -- EA_NOTE,
--       {decorID=16971, source={type="vendor", itemID=265551}} -- EA_NOTE,
--       {decorID=16972, source={type="vendor", itemID=265552}} -- EA_NOTE,
--       {decorID=16973, source={type="vendor", itemID=265553}} -- EA_NOTE,
    }
  },

}
