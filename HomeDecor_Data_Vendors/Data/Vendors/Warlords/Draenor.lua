local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Warlords"] = NS.Data.Vendors["Warlords"] or {}

NS.Data.Vendors["Warlords"]["Draenor"] = {

  {
    source={
      id=76872,
      type="vendor",
      faction="Horde",
      zone="Frostwall Garrison",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=1416, source={type="vendor", itemID=244324, currency="150", currencytype=824}},
    }
  },

  {
    source={
      id=78564,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall Garrison",
      worldmap="539:3850:3140"
    },
    items={
      {decorID=126, source={type="vendor", itemID=245275, currency="100", currencytype=824}},
      {decorID=4403, source={type="vendor", itemID=248334, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=36404}}},
      {decorID=4404, source={type="vendor", itemID=248335, currency="40", currencytype="& 100 Garrison Resources"}, requirements={quest={id=36202}}},
      {decorID=4485, source={type="vendor", itemID=248660, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=34192}}},
      {decorID=4486, source={type="vendor", itemID=248661, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=36592}}},
      {decorID=4816, source={type="vendor", itemID=248799, currency="40", currencytype="& 100 Garrison Resources"}, requirements={quest={id=34586}}},
      {decorID=4818, source={type="vendor", itemID=248800, currency="1500", currencytype=824}, requirements={quest={id=36615}}},
      {decorID=4844, source={type="vendor", itemID=248810, currency="40", currencytype="& 100 Garrison Resources"}, requirements={quest={id=35176}}},
    }
  },

  {
    source={
      id=79774,
      type="vendor",
      faction="Horde",
      zone="Frostwall Garrison (Town Hall Outside)",
      worldmap="525:5160:4540"
    },
    items={
      {decorID=1318, source={type="vendor", itemID=245438, currency="240", currencytype="& 500 Garrison Resources"}},
      {decorID=1353, source={type="vendor", itemID=245443, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=34586}}},
      {decorID=1407, source={type="vendor", itemID=244315, currency="1500", currencytype=824}, requirements={quest={id=36614}}},
      {decorID=1408, source={type="vendor", itemID=244316, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=34192}}},
      {decorID=1412, source={type="vendor", itemID=244320, currency="40", currencytype="& 100 Garrison Resources"}},
      {decorID=1443, source={type="vendor", itemID=244653, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=36592}}},
    }
  },

  {
    source={
      id=79812,
      type="vendor",
      faction="Horde",
      zone="Frostwall Garrison",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=1326, source={type="vendor", itemID=245437, currency="75", currencytype="Iron Horde Scraps"}},
      {decorID=1352, source={type="vendor", itemID=245442, currency="100", currencytype=824}},
    }
  },

  {
    source={
      id=81133,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall Garrison",
      worldmap="539:4620:3930"
    },
    items={
      {decorID=11451, source={type="vendor", itemID=257349, currency="200", currencytype="& 300 Garrison Resources"}},
    }
  },

  {
    source={
      id=85427,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall Garrison (Trading Post)",
      worldmap="539:2900:1400"
    },
    items={
      {decorID=931, source={type="vendor", itemID=245424, currency="500", currencytype="& 1000 Apexis Crystal"}},
      {decorID=8235, source={type="vendor", itemID=251544, currency="500", currencytype="& 1000 Apexis Crystal"}},
    }
  },

  {
    source={
      id=85932,
      type="vendor",
      faction="Alliance",
      zone="Stormshield",
      worldmap="622:4640:7460"
    },
    items={
      {decorID=927, source={type="vendor", itemID=245423, currency="250", currencytype=824}},
      {decorID=8185, source={type="vendor", itemID=251476, currency="1000", currencytype=824}},
      {decorID=8188, source={type="vendor", itemID=251479, currency="1500", currencytype=824}},
      {decorID=8190, source={type="vendor", itemID=251481, currency="500", currencytype=824}},
      {decorID=8192, source={type="vendor", itemID=251483, currency="250", currencytype=824}},
      {decorID=8193, source={type="vendor", itemID=251484, currency="1000", currencytype=824}},
      {decorID=8194, source={type="vendor", itemID=251493, currency="500", currencytype=824}},
      {decorID=8242, source={type="vendor", itemID=251551, currency="1500", currencytype=824}},
    }
  },

  {
    source={
      id=85946,
      type="vendor",
      faction="Neutral",
      zone="Stormshield",
      worldmap=""
    },
    items={
--       {decorID=12203, source={type="vendor", itemID=258743}}, -- missing verified worldmap
--       {decorID=12206, source={type="vendor", itemID=258746}}, -- missing verified worldmap
--       {decorID=12207, source={type="vendor", itemID=258747}}, -- missing verified worldmap
    }
  },

  {
    source={
      id=85950,
      type="vendor",
      faction="Alliance",
      zone="Stormshield (Ashran)",
      worldmap="622:4160:5960"
    },
    items={
      {decorID=928, source={type="vendor", itemID=245425, currency="300", currencytype="& 500 Apexis Crystal"}, requirements={quest={id=35396}}},
      {decorID=8177, source={type="vendor", itemID=251330, currency="100", currencytype="& 300 Apexis Crystal"}, requirements={quest={id=34792}}},
      {decorID=8186, source={type="vendor", itemID=251477, currency="500", currencytype="& 1000 Garrison Resources"}, requirements={quest={id=36169}}},
      {decorID=8187, source={type="vendor", itemID=251478}, requirements={quest={id=35196}}},
      {decorID=8239, source={type="vendor", itemID=251548, currency="300", currencytype="& 500 Apexis Crystal"}, requirements={quest={id=34792}}},
      {decorID=8240, source={type="vendor", itemID=251549, currency="2000", currencytype=824}, requirements={quest={id=37322}}},
      {decorID=8772, source={type="vendor", itemID=251640, currency="500", currencytype="& 1000 Apexis Crystal"}, requirements={quest={id=34099}}},
      {decorID=8785, source={type="vendor", itemID=251653, currency="500", currencytype="& 1000 Garrison Resources"}, requirements={quest={id=35685}}},
      {decorID=8786, source={type="vendor", itemID=251654, currency="800", currencytype="& 2000 Apexis Crystal"}, requirements={quest={id=33256}}},
    }
  },

  {
    source={
      id=86037,
      type="vendor",
      faction="Neutral",
      zone="Warspear",
      worldmap=""
    },
    items={
--       {decorID=12203, source={type="vendor", itemID=258743}}, -- missing verified worldmap
--       {decorID=12206, source={type="vendor", itemID=258746}}, -- missing verified worldmap
--       {decorID=12207, source={type="vendor", itemID=258747}}, -- missing verified worldmap
    }
  },

  {
    source={
      id=86776,
      type="vendor",
      faction="Neutral",
      zone="Frostwall",
      worldmap="585:5140:6200"
    },
    items={
      {decorID=1354, source={type="vendor", itemID=245444, costs={{currency="250", currencytype=824},{currency="250", currencytype=824}}}},
      {decorID=1355, source={type="vendor", itemID=245445, costs={{currency="150", currencytype=824},{currency="150", currencytype=824}}}},
      {decorID=1413, source={type="vendor", itemID=244321, costs={{currency="100", currencytype=824},{currency="100", currencytype=824}}}},
      {decorID=1414, source={type="vendor", itemID=244322, costs={{currency="100", currencytype=824},{currency="100", currencytype=824}}}},
    }
  },

  {
    source={
      id=86779,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="539:3100:1500"
    },
    items={
      {decorID=1354, source={type="vendor", itemID=245444, costs={{currency="250", currencytype=824},{currency="250", currencytype=824}}}},
      {decorID=1355, source={type="vendor", itemID=245445, costs={{currency="150", currencytype=824},{currency="150", currencytype=824}}}},
      {decorID=1413, source={type="vendor", itemID=244321, costs={{currency="100", currencytype=824},{currency="100", currencytype=824}}}},
      {decorID=1414, source={type="vendor", itemID=244322, costs={{currency="100", currencytype=824},{currency="100", currencytype=824}}}},
    }
  },

  {
    source={
      id=87015,
      type="vendor",
      faction="Horde",
      zone="Frostwall Garrison",
      worldmap="525:4800:6600"
    },
    items={
      {decorID=1317, source={type="vendor", itemID=245431, currency="500", currencytype="& 1000 Apexis Crystal"}},
      {decorID=1322, source={type="vendor", itemID=245433, currency="500", currencytype="& 1000 Apexis Crystal"}},
    }
  },

  {
    source={
      id=87312,
      type="vendor",
      faction="Neutral",
      zone="Garrison Inn / Tavern",
      worldmap="525:3640:4000"
    },
    items={
      {decorID=751, source={type="vendor", itemID=239162, costs={{currency="50", currencytype="& 100 Garrison Resources"},{currency="50", currencytype="& 100 Garrison Resources"}}}},
    }
  },

  {
    source={
      id=87775,
      type="vendor",
      faction="Neutral",
      zone="Spires of Arak",
      worldmap="542:3700:5100"
    },
    items={
      {decorID=12200, source={type="vendor", itemID=258740}, requirements={achievement={id=9415}}},
      {decorID=12201, source={type="vendor", itemID=258741}, requirements={quest={id=35671}}},
      {decorID=12205, source={type="vendor", itemID=258745}, requirements={quest={id=35704}}},
      {decorID=12208, source={type="vendor", itemID=258748}, requirements={quest={id=35273}}},
      {decorID=12209, source={type="vendor", itemID=258749}, requirements={quest={id=35896}}},
    }
  },

  {
    source={
      id=88220,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="539:3100:1500"
    },
    items={
      {decorID=751, source={type="vendor", itemID=239162, costs={{currency="50", currencytype="& 100 Garrison Resources"},{currency="50", currencytype="& 100 Garrison Resources"}}}},
    }
  },

  {
    source={
      id=88223,
      type="vendor",
      faction="Neutral",
      zone="Lunarfall",
      worldmap="582:3773:3589"
    },
    items={
      {decorID=126, source={type="vendor", itemID=245275, currency="100", currencytype=824}},
      {decorID=4403, source={type="vendor", itemID=248334, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=36404}}},
      {decorID=4404, source={type="vendor", itemID=248335, currency="40", currencytype="& 100 Garrison Resources"}, requirements={quest={id=36202}}},
      {decorID=4485, source={type="vendor", itemID=248660, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=34192}}},
      {decorID=4486, source={type="vendor", itemID=248661, currency="160", currencytype="& 300 Garrison Resources"}, requirements={quest={id=36592}}},
      {decorID=4816, source={type="vendor", itemID=248799, currency="40", currencytype="& 100 Garrison Resources"}, requirements={quest={id=34586}}},
      {decorID=4844, source={type="vendor", itemID=248810, currency="40", currencytype="& 100 Garrison Resources"}, requirements={quest={id=35176}}},
    }
  },

  {
    source={
      id=256946,
      type="vendor",
      faction="Neutral",
      zone="Talador",
      worldmap="535:7041:5754"
    },
    items={
      {decorID=12202, source={type="vendor", itemID=258742}, requirements={quest={id=33582}}},
    }
  },

}
