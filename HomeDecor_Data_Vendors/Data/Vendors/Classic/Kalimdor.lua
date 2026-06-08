local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["Kalimdor"] = {

  {
    source={
      id=1247,
      type="vendor",
      faction="Alliance",
      zone="Thelsamar",
      worldmap="48:3480:4680"
    },
    items={
      {decorID=11130, source={type="vendor", itemID=256330}},
    }
  },

  {
    source={
      id=1465,
      type="vendor",
      faction="Alliance",
      zone="Thelsamar, Loch Modan",
      worldmap="48:3560:4900"
    },
    items={
      {decorID=2239, source={type="vendor", itemID=246422}, requirements={quest={id=26868}}},
    }
  },

  {
    source={
      id=2483,
      type="vendor",
      faction="Neutral",
      zone="Nesingwary Expedition",
      worldmap="50:4380:2320"
    },
    items={
      {decorID=4841, source={type="vendor", itemID=248808}, requirements={achievement={id=940}}},
    }
  },

  {
    source={
      id=23995,
      type="vendor",
      faction="Neutral",
      zone="Mudsprocket",
      worldmap="70:4190:7390"
    },
    items={
      {decorID=1674, source={type="vendor", itemID=244852}, requirements={achievement={id=4405}}},
    }
  },

  {
    source={
      id=44114,
      type="vendor",
      faction="Alliance",
      zone="Ruins of Gilneas",
      worldmap="218:2030:5820"
    },
    items={
      {decorID=1833, source={type="vendor", itemID=245624}, requirements={quest={id=26760}}},
      {decorID=11305, source={type="vendor", itemID=256905}, requirements={quest={id=26754}}},
    }
  },

  {
    source={
      id=50307,
      type="vendor",
      faction="Alliance",
      zone="Darnassus",
      worldmap="89:5630:1350"
    },
    items={
      {decorID=1794, source={type="vendor", itemID=245603}},
      {decorID=1796, source={type="vendor", itemID=245605}},
    }
  },

  {
    source={
      id=50307,
      type="vendor",
      faction="Alliance",
      zone="Darnassus (via Zidormi)",
      worldmap="89:4860:6380"
    },
    items={
      {decorID=858, source={type="vendor", itemID=245518}, requirements={quest={id=24675}}},
      {decorID=1829, source={type="vendor", itemID=245620}, requirements={quest={id=14402}}},
    }
  },

  {
    source={
      id=50483,
      type="vendor",
      faction="Neutral",
      zone="Thunder Bluff",
      worldmap=""
    },
    items={
--       {decorID=1281, source={type="vendor", itemID=243335}, requirements={quest={id=26397}}}, -- missing verified worldmap
    }
  },

  {
    source={
      id=50488,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:5020:5840"
    },
    items={
      {decorID=9242, source={type="vendor", itemID=253168}},
    }
  },

  {
    source={
      id=68364,
      type="vendor",
      faction="Neutral",
      zone="Brawl'gar Arena",
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
      id=145695,
      type="vendor",
      faction="Neutral",
      zone="Brawl'gar Arena",
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
      id=151941,
      type="vendor",
      faction="Neutral",
      zone="Brawl'gar Arena",
      worldmap="369:5000:2900"
    },
    items={
      {decorID=10913, source={type="vendor", itemID=255840}},
      {decorID=12263, source={type="vendor", itemID=259071}},
      {decorID=14815, source={type="vendor", itemID=263026}},
    }
  },

  {
    source={
      id=216888,
      type="vendor",
      faction="Alliance",
      zone="Bel'ameth",
      worldmap="218:5800:4120"
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
      id=224353,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="1535:3572:1316"
    },
    items={
      {decorID=15411, source={type="vendor", itemID=264006}, requirements={achievement={id=42786}}},
    }
  },

  {
    source={
      id=254606,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:3880:7190"
    },
    items={
      {decorID=3867, source={type="vendor", itemID=247727, currency="5000", currencytype=1792}, requirements={achievement={id=5223}}},
      {decorID=3880, source={type="vendor", itemID=247740, costs={{currency="2000", currencytype=1792},{currency="2000", currencytype=1792}}}, requirements={achievement={id=6981}}},
      {decorID=3881, source={type="vendor", itemID=247741, costs={{currency="1000", currencytype=1792},{currency="1000", currencytype=1792}}}, requirements={achievement={id=6981}}},
      {decorID=3885, source={type="vendor", itemID=247745, currency="1000", currencytype=1792}, requirements={achievement={id=229}}},
      {decorID=3887, source={type="vendor", itemID=247747, currency="800", currencytype=1792}, requirements={achievement={id=167}}},
      {decorID=3890, source={type="vendor", itemID=247750, costs={{currency="2500", currencytype=1792},{currency="2500", currencytype=1792}}}, requirements={achievement={id=40612}}},
      {decorID=3893, source={type="vendor", itemID=247756, costs={{currency="1000", currencytype=1792},{currency="1000", currencytype=1792}}}, requirements={achievement={id=1157}}},
      {decorID=3896, source={type="vendor", itemID=247759, currency="600", currencytype=1792}, requirements={achievement={id=1153}}},
      {decorID=3897, source={type="vendor", itemID=247760, currency="1200", currencytype=1792}, requirements={achievement={id=222}}},
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
      id=256119,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="86:9987:1210"
    },
    items={
      {decorID=766, source={type="vendor", itemID=239177}},
      {decorID=768, source={type="vendor", itemID=239179}},
      {decorID=2511, source={type="vendor", itemID=246845}},
      {decorID=2513, source={type="vendor", itemID=246847}},
      {decorID=2514, source={type="vendor", itemID=246848}},
      {decorID=2526, source={type="vendor", itemID=246860}},
    }
  },

  {
    source={
      id=261262,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="85:4837:8115"
    },
    items={
      {decorID=11287, source={type="vendor", itemID=256764}},
      {decorID=12244, source={type="vendor", itemID=259044}},
      {decorID=12245, source={type="vendor", itemID=259045}},
      {decorID=12246, source={type="vendor", itemID=259046}},
      {decorID=12247, source={type="vendor", itemID=259055}},
      {decorID=12248, source={type="vendor", itemID=259056}},
      {decorID=12249, source={type="vendor", itemID=259057}},
      {decorID=12250, source={type="vendor", itemID=259058}},
      {decorID=12251, source={type="vendor", itemID=259059}},
      {decorID=12252, source={type="vendor", itemID=259060}},
      {decorID=12253, source={type="vendor", itemID=259061}},
      {decorID=12254, source={type="vendor", itemID=259062}},
      {decorID=12255, source={type="vendor", itemID=259063}},
      {decorID=12256, source={type="vendor", itemID=259064}},
      {decorID=12257, source={type="vendor", itemID=259065}},
      {decorID=12258, source={type="vendor", itemID=259066}},
      {decorID=12259, source={type="vendor", itemID=259067}},
      {decorID=12260, source={type="vendor", itemID=259068}},
      {decorID=12261, source={type="vendor", itemID=259069}},
      {decorID=12262, source={type="vendor", itemID=259070}},
      {decorID=12264, source={type="vendor", itemID=259093}},
      {decorID=12265, source={type="vendor", itemID=259094}},
      {decorID=14467, source={type="vendor", itemID=260785}, requirements={achievement={id=62387}}},
      {decorID=15148, source={type="vendor", itemID=263298}},
      {decorID=15149, source={type="vendor", itemID=263299}},
      {decorID=15151, source={type="vendor", itemID=263301}},
      {decorID=15229, source={type="vendor", itemID=263383}},
      {decorID=15547, source={type="vendor", itemID=264275}},
      {decorID=15548, source={type="vendor", itemID=264276}},
      {decorID=15549, source={type="vendor", itemID=264277}},
      {decorID=15550, source={type="vendor", itemID=264278}},
      {decorID=15551, source={type="vendor", itemID=264279}},
      {decorID=15552, source={type="vendor", itemID=264280}},
      {decorID=15553, source={type="vendor", itemID=264281}},
      {decorID=15554, source={type="vendor", itemID=264282}},
      {decorID=15555, source={type="vendor", itemID=264283}},
      {decorID=15668, source={type="vendor", itemID=264396}},
      {decorID=15669, source={type="vendor", itemID=264397}},
    }
  },

}
