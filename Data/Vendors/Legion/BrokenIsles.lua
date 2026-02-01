local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Legion"] = NS.Data.Vendors["Legion"] or {}

NS.Data.Vendors["Legion"]["BrokenIsles"] = {

   -- {
   --Legion Remix not sure if it'll be added back some where else.   title="Domelius",
   -- source={
   --   id=251042,
   --   type="vendor",
   --  faction="Neutral",
   --   zone="Dalaran",
   --   worldmap="619:5506:7797",
   -- },
   -- items={
   --   {decorID=7610, decorType="Ornamental", source={type="vendor", itemID=250307, currency="10000", currencytype="Bronze"}, requirements={achievement={id=42318}}},
   --   {decorID=7620, decorType="Seating", source={type="vendor", itemID=250402, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42658}}},
   --   {decorID=7621, decorType="Miscellaneous - All", source={type="vendor", itemID=250403, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42692}}},
   --   {decorID=7622, decorType="Misc Accents", source={type="vendor", itemID=250404, currency="5000", currencytype="Bronze"}},
   --   {decorID=7623, decorType="Large Lights", source={type="vendor", itemID=250405, currency="5000", currencytype="Bronze"}, requirements={achievement={id=61060}}},
   --   {decorID=7624, decorType="Large Structures", source={type="vendor", itemID=250406, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42321}}},
   --   {decorID=7625, decorType="Large Lights", source={type="vendor", itemID=250407, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42619}}},
   --   {decorID=7658, decorType="Misc Accents", source={type="vendor", itemID=250622, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42675}}},
   --   {decorID=7686, decorType="Large Structures", source={type="vendor", itemID=250689, currency="10000", currencytype="Bronze"}, requirements={achievement={id=61054}}},
   --   {decorID=7687, decorType="Large Lights", source={type="vendor", itemID=250690, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42627}}},
   --   {decorID=7690, decorType="Ornamental", source={type="vendor", itemID=250693, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42674}}},
   --   {decorID=8810, decorType="Misc Accents", source={type="vendor", itemID=251778, currency="30000", currencytype="Bronze"}, requirements={achievement={id=61218}}},
   --   {decorID=8811, decorType="Large Structures", source={type="vendor", itemID=251779, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42689}}},
   --   {decorID=9165, decorType="Storage", source={type="vendor", itemID=252753, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42655}}},
   --  {decorID=11278, decorType="Small Lights", source={type="vendor", itemID=256677, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42628}}},
   --   {decorID=11279, decorType="Small Lights", source={type="vendor", itemID=256678, currency="2500", currencytype="Bronze"}},
   --   {decorID=11942, decorType="Misc Structural", source={type="vendor", itemID=258299, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42547}}},
   -- }
   --},
  {
    title="First Arcanist Thalyssra",
    source={
      id=115736,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:3649:4583",
    },
    items={
      {decorID=1440, decorType="Large Lights", source={type="vendor", itemID=244536, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2516, decorType="Wall Hangings", source={type="vendor", itemID=246850, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=3983, decorType="Storage", source={type="vendor", itemID=247844, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=3984, decorType="Seating", source={type="vendor", itemID=247845, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=3985, decorType="Tables and Desks", source={type="vendor", itemID=247847, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4024, decorType="Wall Lights", source={type="vendor", itemID=247910, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4035, decorType="Storage", source={type="vendor", itemID=247921, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4038, decorType="Large Lights", source={type="vendor", itemID=247924, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Outfitter Reynolds",
    source={
      id=103693,
      type="vendor",
      faction="Neutral",
      zone="Trueshot Lodge",
      worldmap="739:4456:4888",
    },
    items={
      {decorID=1740, decorType="Large Lights", source={type="vendor", itemID=245549, currency="500", currencytype="Order Resources"}},
      {decorID=4042, decorType="Wall Hangings", source={type="vendor", itemID=248011, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42273}}},
      {decorID=5877, decorType="Storage", source={type="vendor", itemID=250110, currency="500", currencytype="Order Resources"}},
      {decorID=5890, decorType="Ornamental", source={type="vendor", itemID=250125, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42290}}},
      {decorID=5891, decorType="Ornamental", source={type="vendor", itemID=250126, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60984}}},
      {decorID=5892, decorType="Ornamental", source={type="vendor", itemID=250127, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60965}}},
      {decorID=5893, decorType="Ornamental", source={type="vendor", itemID=250128, currency="1000", currencytype="Order Resources"}},
    }
  },
  {
    title="Gigi Gigavoid",
    source={
      id=112434,
      type="vendor",
      faction="Neutral",
      zone="Dreadscar Rift",
      worldmap="717:5876:3269",
    },
    items={
      {decorID=5117, decorType="Miscellaneous - All", source={type="vendor", itemID=248940, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42297}}},
      {decorID=5120, decorType="Ornamental", source={type="vendor", itemID=248943, currency="1000", currencytype="Order Resources"}},
      {decorID=5127, decorType="Storage", source={type="vendor", itemID=248959, currency="500", currencytype="Order Resources"}},
      {decorID=5128, decorType="Floor", source={type="vendor", itemID=248960, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42281}}},
      {decorID=5292, decorType="Large Structures", source={type="vendor", itemID=249004, currency="500", currencytype="Order Resources"}},
      {decorID=11307, decorType="Misc Accents", source={type="vendor", itemID=256907, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60972}}},
      {decorID=15477, decorType="Miscellaneous - All", source={type="vendor", itemID=264242, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60991}}},
    }
  },
  {
    title="Halenthos Brightstride",
    source={
      id=252043,
      type="vendor",
      faction="Alliance",
      zone="Dalaran",
      worldmap="627:6745:3389",
    },
    items={
      {decorID=947, decorType="Wall Lights", source={type="vendor", itemID=245411, currency="150", currencytype="War Resources"}, requirements={quest={id=38882}}},
      {decorID=9267, decorType="Small Lights", source={type="vendor", itemID=253251, currency="150", currencytype="War Resources"}, requirements={quest={id=39801}}},
    }
  },
  {
    title="Corbin Branbell",
    source={
      id=252498,
      type="vendor",
      faction="Horde",
      zone="Val'sharah",
      worldmap="641:4209:5938",
    },
    items={
      {decorID=1801, decorType="Small Lights", source={type="vendor", itemID=245615, currency="350", currencytype="Order Resources"}, requirements={quest={id=39117}}},
      {decorID=1802, decorType="Large Structures", source={type="vendor", itemID=245616, currency="1000", currencytype="Order Resources"}, requirements={quest={id=46107}}},
    }
  },
  {
    title="Amurra Thistledew",
    source={
      id=112323,
      type="vendor",
      faction="Neutral",
      zone="The Dreamgrove",
      worldmap="747:4002:1772",
    },
    items={
      {decorID=1741, decorType="Ornamental", source={type="vendor", itemID=245550, currency="500", currencytype="Order Resources"}},
      {decorID=2086, decorType="Large Lights", source={type="vendor", itemID=246216, currency="500", currencytype="Order Resources"}},
      {decorID=5878, decorType="Misc Furnishings", source={type="vendor", itemID=250111, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60964}}},
      {decorID=5897, decorType="Wall Hangings", source={type="vendor", itemID=250133, currency="1000", currencytype="Order Resources"}},
      {decorID=5898, decorType="Ornamental", source={type="vendor", itemID=250134, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42289}}},
      {decorID=7873, decorType="Large Structures", source={type="vendor", itemID=251013, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60983}}},
      {decorID=14358, decorType="Large Lights", source={type="vendor", itemID=260581, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42272}}},
    }
  },
  {
    title="Selfira Ambergrove",
    source={
      id=253387,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:5426:7236",
    },
    items={
      {decorID=675, decorType="Misc Accents", source={type="vendor", itemID=238859, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=676, decorType="Beds", source={type="vendor", itemID=238860, currency="700", currencytype="Order Resources"}},
      {decorID=677, decorType="Floor", source={type="vendor", itemID=238861, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1695, decorType="Food and Drink", source={type="vendor", itemID=245261, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1881, decorType="Beds", source={type="vendor", itemID=245697, currency="600", currencytype="Order Resources"}, requirements={achievement={id=10698}}},
      {decorID=1884, decorType="Seating", source={type="vendor", itemID=245700, currency="250", currencytype="Order Resources"}, requirements={quest={id=38663}}},
      {decorID=1886, decorType="Storage", source={type="vendor", itemID=245702, currency="75", currencytype="Order Resources"}, requirements={quest={id=38147}}},
      {decorID=1887, decorType="Storage", source={type="vendor", itemID=245703, currency="750", currencytype="Order Resources"}, requirements={achievement={id=11258}}},
      {decorID=1889, decorType="Large Lights", source={type="vendor", itemID=245739, currency="300", currencytype="Order Resources"}, requirements={quest={id=40890}}},
      {decorID=8195, decorType="Storage", source={type="vendor", itemID=251494, currency="200", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=15453, decorType="Floor", source={type="vendor", itemID=264168, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Sylvia Hartshorn",
    source={
      id=106901,
      type="vendor",
      faction="Horde",
      zone="Val'sharah",
      worldmap="641:5470:7325",
    },
    items={
      {decorID=675, decorType="Misc Accents", source={type="vendor", itemID=238859, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=677, decorType="Floor", source={type="vendor", itemID=238861, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1695, decorType="Food and Drink", source={type="vendor", itemID=245261, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=8195, decorType="Storage", source={type="vendor", itemID=251494, currency="200", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=15453, decorType="Floor", source={type="vendor", itemID=264168, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Meridelle Lightspark",
    source={
      id=112401,
      type="vendor",
      faction="Neutral",
      zone="Netherlight Temple",
      worldmap="702:3861:2377",
    },
    items={
      {decorID=7606, decorType="Misc Furnishings", source={type="vendor", itemID=250302, currency="500", currencytype="Order Resources"}},
      {decorID=7607, decorType="Uncategorized", source={type="vendor", itemID=250303, currency="500", currencytype="Order Resources"}},
      {decorID=7608, decorType="Small Lights", source={type="vendor", itemID=250304, currency="500", currencytype="Order Resources"}},
      {decorID=7821, decorType="Wall Hangings", source={type="vendor", itemID=250789, currency="1000", currencytype="Order Resources"}},
      {decorID=7822, decorType="Ornamental", source={type="vendor", itemID=250790, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42294}}},
      {decorID=7823, decorType="Ornamental", source={type="vendor", itemID=250791, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60969}}},
      {decorID=7824, decorType="Ornamental", source={type="vendor", itemID=250792, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42277}}},
      {decorID=8768, decorType="Uncategorized", source={type="vendor", itemID=251636, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60988}}},
    }
  },
  {
    title="Jackson Watkins",
    source={
      id=112440,
      type="vendor",
      faction="Neutral",
      zone="Hall of the Guardian",
      worldmap="735:4475:5787",
    },
    items={
      {decorID=750, decorType="Ornamental", source={type="vendor", itemID=245429, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42274}}},
      {decorID=5894, decorType="Small Lights", source={type="vendor", itemID=250130, currency="500", currencytype="Order Resources"}},
      {decorID=5895, decorType="Misc Furnishings", source={type="vendor", itemID=250131, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=60985}}},
      {decorID=5896, decorType="Large Lights", source={type="vendor", itemID=250132, currency="500", currencytype="Order Resources"}},
      {decorID=7579, decorType="Wall Hangings", source={type="vendor", itemID=250239, currency="1000", currencytype="Order Resources"}},
      {decorID=7609, decorType="Ornamental", source={type="vendor", itemID=250306, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42291}}},
      {decorID=11275, decorType="Ornamental", source={type="vendor", itemID=256674, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60966}}},
    }
  },
  {
    title="Jocenna",
    source={
      id=252969,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4963:6283",
    },
    items={
      {decorID=752, decorType="Wall Hangings", source={type="vendor", itemID=245448, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=11124}, rep="true"}},
      {decorID=1747, decorType="Windows", source={type="vendor", itemID=245558, currency="225", currencytype="Order Resources"}, requirements={quest={id=44955}}},
      {decorID=3981, decorType="Large Structures", source={type="vendor", itemID=247842, currency="600", currencytype="Order Resources"}, requirements={quest={id=44756}}},
      {decorID=3982, decorType="Beds", source={type="vendor", itemID=247843, currency="1200", currencytype="Order Resources"}, requirements={achievement={id=11340}}},
      {decorID=4025, decorType="Seating", source={type="vendor", itemID=247911, currency="100", currencytype="Order Resources"}, requirements={quest={id=43318}}},
      {decorID=4028, decorType="Tables and Desks", source={type="vendor", itemID=247914, currency="400", currencytype="Order Resources"}, requirements={quest={id=44052}}},
      {decorID=4031, decorType="Tables and Desks", source={type="vendor", itemID=247917, currency="200", currencytype="Order Resources"}, requirements={quest={id=41915}}},
      {decorID=4040, decorType="Windows", source={type="vendor", itemID=248009, currency="175", currencytype="Order Resources"}, requirements={quest={id=42489}}},
    }
  },
  {
    title="Torv Dubstomp",
    source={
      id=108017,
      type="vendor",
      faction="Neutral",
      zone="Thunder Totem, Highmountain",
      worldmap="650:5280:8000",
    },
    items={
      {decorID=1235, decorType="Storage", source={type="vendor", itemID=245453, currency="500", currencytype="Order Resources"}, requirements={quest={id=42590}}},
      {decorID=1251, decorType="Misc Accents", source={type="vendor", itemID=245405, currency="500", currencytype="Order Resources"}, requirements={quest={id=42622}}},
      {decorID=1287, decorType="Large Lights", source={type="vendor", itemID=245456, currency="750", currencytype="Order Resources"}, requirements={quest={id=39579}}},
      {decorID=1291, decorType="Large Structures", source={type="vendor", itemID=245461, currency="1000", currencytype="Order Resources"}, requirements={quest={id=39780}}},
      {decorID=1294, decorType="Wall Hangings", source={type="vendor", itemID=245457, currency="500", currencytype="Order Resources"}, requirements={quest={id=39614}}},
      {decorID=1307, decorType="Storage", source={type="vendor", itemID=245460, currency="750", currencytype="Order Resources"}, requirements={achievement={id=11257}}},
      {decorID=1309, decorType="Food and Drink", source={type="vendor", itemID=245409, currency="500", currencytype="Order Resources"}, requirements={quest={id=39496}}},
      {decorID=11315, decorType="Misc Accents", source={type="vendor", itemID=256913, currency="500", currencytype="Order Resources"}, requirements={achievement={id=10996}}},
      {decorID=11487, decorType="Misc Accents", source={type="vendor", itemID=257397, currency="750", currencytype="Order Resources"}, requirements={quest={id=39992}}},
      {decorID=11491, decorType="Wall Hangings", source={type="vendor", itemID=257401, currency="1000", currencytype="Order Resources"}, requirements={quest={id=39387}}},
      {decorID=11751, decorType="Ornamental", source={type="vendor", itemID=257721, currency="500", currencytype="Order Resources"}, requirements={achievement={id=10398}}},
      {decorID=11752, decorType="Ornamental", source={type="vendor", itemID=257722, currency="500", currencytype="Order Resources"}, requirements={quest={id=39426}}},
      {decorID=11753, decorType="Ornamental", source={type="vendor", itemID=257723, currency="750", currencytype="Order Resources"}, requirements={quest={id=39305}}},
      {decorID=14379, decorType="Misc Accents", source={type="vendor", itemID=260698, currency="200", currencytype="Order Resources"}, requirements={quest={id=39772}}},
    }
  },
  {
    title="Crafty Palu",
    source={
      id=108537,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:4162:1044",
    },
    items={
      {decorID=11905, decorType="Storage", source={type="vendor", itemID=258219, currency="175", currencytype="Order Resources"}}, 
      {decorID=11907, decorType="Storage", source={type="vendor", itemID=258221, currency="450", currencytype="Order Resources"}, requirements={quest={id=40230}}},
      {decorID=11909, decorType="Ornamental", source={type="vendor", itemID=258223, currency="400", currencytype="Order Resources"}, requirements={achievement={id=11699}}},
    }
  },
  {
    title="Flamesmith Lanying",
    source={
      id=112318,
      type="vendor",
      faction="Neutral",
      zone="The Maelstrom",
      worldmap="726:3032:6069",
    },
    items={
      {decorID=7837, decorType="Ornamental", source={type="vendor", itemID=250914, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42296}}},
      {decorID=7838, decorType="Ornamental", source={type="vendor", itemID=250915, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60971}}},
      {decorID=7839, decorType="Ornamental", source={type="vendor", itemID=250916, currency="500", currencytype="Order Resources"}},
      {decorID=7841, decorType="Ornamental", source={type="vendor", itemID=250918, currency="1000", currencytype="Order Resources"}},
      {decorID=7874, decorType="Ornamental", source={type="vendor", itemID=251014, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60990}}},
      {decorID=7875, decorType="Ornamental", source={type="vendor", itemID=251015, currency="500", currencytype="Order Resources"}},
      {decorID=11493, decorType="Miscellaneous - All", source={type="vendor", itemID=257403, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42280}}},
    }
  },
  {
    title="Sileas Duskvine",
    source={
      id=253434,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="641:7992:7389",
    },
    items={
      {decorID=1885, decorType="Tables and Desks", source={type="vendor", itemID=245701, currency="175", currencytype="Order Resources"}, requirements={quest={id=40321}}},
    }
  },
  {
    title="Falara Nightsong",
    source={
      id=112407,
      type="vendor",
      faction="Neutral",
      zone="The Fel Hammer",
      worldmap="720:6100:5673",
    },
    items={
      {decorID=5525, decorType="Large Structures", source={type="vendor", itemID=249457, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42288}}},
      {decorID=5527, decorType="Wall Hangings", source={type="vendor", itemID=249459, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42271}}},
      {decorID=5530, decorType="Wall Hangings", source={type="vendor", itemID=249462, currency="1000", currencytype="Order Resources"}},
      {decorID=5531, decorType="Miscellaneous - All", source={type="vendor", itemID=249463, currency="500", currencytype="Order Resources"}},
      {decorID=5555, decorType="Miscellaneous - All", source={type="vendor", itemID=249518, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60982}}},
      {decorID=5575, decorType="Ornamental", source={type="vendor", itemID=249690, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60963}}},
      {decorID=11276, decorType="Large Structures", source={type="vendor", itemID=256675, currency="500", currencytype="Order Resources"}},
    }
  },
  {
    title="Caydori Brightstar",
    source={
      id=112338,
      type="vendor",
      faction="Neutral",
      zone="Mandori Village",
      worldmap="709:5033:5913",
    },
    items={
      {decorID=5112, decorType="Storage", source={type="vendor", itemID=248935, currency="500", currencytype="Order Resources"}},
      {decorID=5113, decorType="Ornamental", source={type="vendor", itemID=248936, currency="500", currencytype="Order Resources"}},
      {decorID=5119, decorType="Tables and Desks", source={type="vendor", itemID=248942, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60986}}},
      {decorID=5126, decorType="Large Structures", source={type="vendor", itemID=248958, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42275}}},
      {decorID=11280, decorType="Ornamental", source={type="vendor", itemID=256679, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60967}}},
      {decorID=14644, decorType="Misc Structural", source={type="vendor", itemID=262619, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42292}}},
    }
  },
  {
    title="Ransa Greyfeather",
    source={
      id=106902,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:4588:6049",
    },
    items={
      {decorID=1231, decorType="Ornamental", source={type="vendor", itemID=245452, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1252, decorType="Miscellaneous - All", source={type="vendor", itemID=243290, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1292, decorType="Large Structures", source={type="vendor", itemID=243359, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1293, decorType="Ornamental", source={type="vendor", itemID=245454, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1295, decorType="Ornamental", source={type="vendor", itemID=245458, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1297, decorType="Ornamental", source={type="vendor", itemID=245450, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1703, decorType="Misc Accents", source={type="vendor", itemID=245270, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5136, decorType="Wall Lights", source={type="vendor", itemID=248985, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Hilseth Travelstride",
    source={
      id=112634,
      type="vendor",
      faction="Alliance",
      zone="Val'sharah",
      worldmap="641:5714:7191",
    },
    items={
      {decorID=679, decorType="Tables and Desks", source={type="vendor", itemID=238863, currency="300", currencytype="Order Resources"}},
      {decorID=1694, decorType="Tables and Desks", source={type="vendor", itemID=245260, currency="400", currencytype="Order Resources"}},
    }
  },
  {
    title="Myria Glenbrook",
    source={
      id=109306,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:6020:8486",
    },
    items={
      {decorID=1692, decorType="Storage", source={type="vendor", itemID=245258, currency="75", currencytype="Order Resources"}, requirements={quest={id=42751}}},
      {decorID=1882, decorType="Misc Structural", source={type="vendor", itemID=245698, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=40573}}},
      {decorID=1883, decorType="Misc Structural", source={type="vendor", itemID=245699, currency="350", currencytype="Resonance Crystals"}, requirements={quest={id=40573}}},
    }
  },
  {
    title="Leyweaver Inondra",
    source={
      id=93971,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4032:6973",
    },
    items={
      {decorID=4026, decorType="Floor", source={type="vendor", itemID=247912, currency="250", currencytype="Ancient Mana"}},
      {decorID=4033, decorType="Floor", source={type="vendor", itemID=247919, currency="150", currencytype="Ancient Mana"}},
    }
  },
  {
    title="Kelsey Steelspark",
    source={
      id=105986,
      type="vendor",
      faction="Neutral",
      zone="The Hall of Shadows",
      worldmap="626:2692:3683",
    },
    items={
      {decorID=7815, decorType="Storage", source={type="vendor", itemID=250783, currency="500", currencytype="Order Resources"}},
      {decorID=7816, decorType="Ornamental", source={type="vendor", itemID=250784, currency="500", currencytype="Order Resources"}},
      {decorID=7817, decorType="Wall Hangings", source={type="vendor", itemID=250785, currency="1000", currencytype="Order Resources"}},
      {decorID=7818, decorType="Tables and Desks", source={type="vendor", itemID=250786, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60989}}},
      {decorID=7819, decorType="Ornamental", source={type="vendor", itemID=250787, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42295}}},
      {decorID=7820, decorType="Misc Furnishings", source={type="vendor", itemID=250788, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60970}}},
      {decorID=11493, decorType="Miscellaneous - All", source={type="vendor", itemID=257403, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42280}}},
      {decorID=14461, decorType="Large Structures", source={type="vendor", itemID=260776, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42279}}},
    }
  },
  {
    title="Sundries Merchant",
    source={
      id=248594,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:5090:7778",
    },
    items={
      {decorID=1444, decorType="Seating", source={type="vendor", itemID=244654, currency="100", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1464, decorType="Seating", source={type="vendor", itemID=244676, currency="200", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1465, decorType="Seating", source={type="vendor", itemID=244677, currency="300", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1466, decorType="Seating", source={type="vendor", itemID=244678, currency="100", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1919, decorType="Seating", source={type="vendor", itemID=246001, currency="200", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1920, decorType="Seating", source={type="vendor", itemID=246002, currency="300", currencytype="Ancient Mana"}, requirements={rep="true"}},
    }
  },
  {
    title="Rasil Fireborne",
    source={
      id=112716,
      type="vendor",
      faction="Alliance",
      zone="Dalaran",
      worldmap="626:4340:4940",
    },
    items={
      {decorID=2517, decorType="Wall Hangings", source={type="vendor", itemID=246851, currency="600", currencytype="Honor"}},
    }
  },
  {
    title="Quartermaster Durnolf",
    source={
      id=112392,
      type="vendor",
      faction="Neutral",
      zone="Skyhold",
      worldmap="695:5549:2591",
    },
    items={
      {decorID=5526, decorType="Large Structures", source={type="vendor", itemID=249458, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42298}}},
      {decorID=5528, decorType="Large Lights", source={type="vendor", itemID=249460, currency="500", currencytype="Order Resources"}},
      {decorID=5529, decorType="Tables and Desks", source={type="vendor", itemID=249461, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60992}}},
      {decorID=5532, decorType="Wall Hangings", source={type="vendor", itemID=249464, currency="1000", currencytype="Order Resources"}},
      {decorID=5534, decorType="Wall Hangings", source={type="vendor", itemID=249466, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42282}}},
      {decorID=5562, decorType="Storage", source={type="vendor", itemID=249551, currency="500", currencytype="Order Resources"}},
      {decorID=11486, decorType="Miscellaneous - All", source={type="vendor", itemID=257396, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60973}}},
    }
  },
  {
    title="Quartermaster Ozorg",
    source={
      id=93550,
      type="vendor",
      faction="Neutral",
      zone="Acherus: The Ebon Hold",
      worldmap="647:4390:3717",
    },
    items={
      {decorID=5575, decorType="Ornamental", source={type="vendor", itemID=249690, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60963}}},
      {decorID=5879, decorType="Tables and Desks", source={type="vendor", itemID=250112, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60981}}},
      {decorID=5880, decorType="Ornamental", source={type="vendor", itemID=250113, currency="500", currencytype="Order Resources"}},
      {decorID=5881, decorType="Tables and Desks", source={type="vendor", itemID=250114, currency="500", currencytype="Order Resources"}},
      {decorID=5882, decorType="Storage", source={type="vendor", itemID=250115, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42270}}},
      {decorID=5888, decorType="Large Structures", source={type="vendor", itemID=250123, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42287}}},
      {decorID=5889, decorType="Wall Hangings", source={type="vendor", itemID=250124, currency="1000", currencytype="Order Resources"}},
      {decorID=14361, decorType="Ornamental", source={type="vendor", itemID=260584, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60962}}},
    }
  },
  {
    title="Mrgrgrl",
    source={
      id=256826,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="641:6872:9510",
    },
    items={
      --       {decorID=11908, decorType="Misc Accents", source={type="vendor", itemID=258222, currency="600", currencytype="Order Resources"}, requirements={quest={id=41143}}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Mynde",
    source={
      id=255101,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4558:6915",
    },
    items={
      {decorID=11483, decorType="Floor", source={type="vendor", itemID=257393, currency="50", currencytype="Ancient Mana"}},
      {decorID=11708, decorType="Floor", source={type="vendor", itemID=257598, currency="125", currencytype="Ancient Mana"}},
    }
  },
  {
    title="Berazus",
    source={
      id=89939,
      type="vendor",
      faction="Horde",
      zone="Azsuna",
      worldmap="630:4780:2360",
    },
    items={
      {decorID=2530, decorType="Ornamental", source={type="vendor", itemID=246864, currency="1000", currencytype="Order Resources"}, requirements={quest={id=37470}}},
    }
  },
}
