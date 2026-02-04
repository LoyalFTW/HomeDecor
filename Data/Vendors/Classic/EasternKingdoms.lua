local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["EasternKingdoms"] = {
     {

    source={
      id=249196,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4960:8120"},
    items={
	  {decorID=714,  source={type="vendor", itemID=245284, currency="2000", currencytype="Honor"}},
	  {decorID=1236,  source={type="vendor", itemID=245330, currency="2000", currencytype="Honor"}},
	  {decorID=1227,  source={type="vendor", itemID=251997, currency="2000", currencytype="Honor"}}}
  },
  {
    source={
      id=254603,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City",
      worldmap="84:7780:6580"},
    items={
      {decorID=3880,  source={type="vendor", itemID=247740, currency="2000", currencytype="Honor"}, requirements={achievement={id=6981}}},
      {decorID=3881,  source={type="vendor", itemID=247741, currency="1000", currencytype="Honor"}, requirements={achievement={id=6981}}},
      {decorID=3884,  source={type="vendor", itemID=247744, currency="1000", currencytype="Honor"}, requirements={achievement={id=231}}},
      {decorID=3886,  source={type="vendor", itemID=247746, currency="800", currencytype="Honor"}, requirements={achievement={id=200}}},
      {decorID=3890,  source={type="vendor", itemID=247750, currency="2500", currencytype="Honor"}, requirements={achievement={id=40612}}},
      {decorID=3893,  source={type="vendor", itemID=247756, currency="1000", currencytype="Honor"}, requirements={achievement={id=1157}}},
      {decorID=3894,  source={type="vendor", itemID=247757, currency="600", currencytype="Honor"}, requirements={achievement={id=158}}},
      {decorID=3895,  source={type="vendor", itemID=247758, currency="1200", currencytype="Honor"}, requirements={achievement={id=221}}},
      {decorID=3898,  source={type="vendor", itemID=247761, currency="400", currencytype="Honor"}, requirements={achievement={id=212}}},
      {decorID=3899,  source={type="vendor", itemID=247762, currency="300", currencytype="Honor"}, requirements={achievement={id=213}}},
      {decorID=3900,  source={type="vendor", itemID=247763, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61683}}},
      {decorID=3902,  source={type="vendor", itemID=247765, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61687}}},
      {decorID=3903,  source={type="vendor", itemID=247766, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61688}}},
      {decorID=3905,  source={type="vendor", itemID=247768, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=61684}}},
      {decorID=3906,  source={type="vendor", itemID=247769, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61685}}},
      {decorID=3907,  source={type="vendor", itemID=247770, currency="1000", currencytype="Honor"}, requirements={achievement={id=61686}}},
      {decorID=9244,  source={type="vendor", itemID=253170, currency="750", currencytype="Honor"}, requirements={achievement={id=40210}}},
      {decorID=11296,  source={type="vendor", itemID=256896, currency="450", currencytype="Honor"}, requirements={achievement={id=5245}}}}
  },
  {
    source={
      id=211065,
      type="vendor",
      faction="Alliance",
      zone="Stormglen Village, Gilneas",
      worldmap="217:6040:9240"},
    items={
      {decorID=857, source={type="vendor", itemID=245520, currency="100", currencytype="Garrison Resources"}, requirements={achievement={id=19719}}},
      {decorID=859,  source={type="vendor", itemID=245516, currency="300", currencytype="Garrison Resources"}},
      {decorID=860,  source={type="vendor", itemID=245515, currency="550", currencytype="War Resources"}},
      {decorID=1795,  source={type="vendor", itemID=245604}},
      {decorID=1826,  source={type="vendor", itemID=245617}},
      {decorID=11944,  source={type="vendor", itemID=258301}}}
  },
  {
    source={
      id=255221,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:5347:4093"},
    items={
      {decorID=520,  source={type="vendor", itemID=245369}},
      {decorID=521,  source={type="vendor", itemID=245371}},
      {decorID=771,  source={type="vendor", itemID=245329}},
      {decorID=772,  source={type="vendor", itemID=245327}},
      {decorID=773,  source={type="vendor", itemID=245328, currency="250", currencytype="Garrison Resources"}},
      {decorID=1864,  source={type="vendor", itemID=245658}},
      {decorID=1865,  source={type="vendor", itemID=245659}},
      {decorID=1866,  source={type="vendor", itemID=245660}},
      {decorID=1867,  source={type="vendor", itemID=245661}},
      {decorID=4406,  source={type="vendor", itemID=248337}},
      {decorID=4407,  source={type="vendor", itemID=248338}},
      {decorID=4408,  source={type="vendor", itemID=248339}},
      {decorID=4461,  source={type="vendor", itemID=248635}},
      {decorID=4465,  source={type="vendor", itemID=248639}},
      {decorID=4466,  source={type="vendor", itemID=248640}},
      {decorID=4467,  source={type="vendor", itemID=248641}},
      {decorID=4468,  source={type="vendor", itemID=248642}},
      {decorID=4469,  source={type="vendor", itemID=248643}},
      {decorID=4470,  source={type="vendor", itemID=248644}},
      {decorID=4471,  source={type="vendor", itemID=248645}},
      {decorID=4472,  source={type="vendor", itemID=248646}},
      {decorID=4473,  source={type="vendor", itemID=248647}},
      {decorID=4474,  source={type="vendor", itemID=248648}},
      {decorID=4475,  source={type="vendor", itemID=248649}},
      {decorID=4822,  source={type="vendor", itemID=248802}},
      {decorID=4823,  source={type="vendor", itemID=248803}},
      {decorID=4845,  source={type="vendor", itemID=248811}},
      {decorID=10855,  source={type="vendor", itemID=255644}},
      {decorID=10856,  source={type="vendor", itemID=255646}},
      {decorID=12189,  source={type="vendor", itemID=258658}},
      {decorID=12190,  source={type="vendor", itemID=258659}},
      {decorID=17868,  source={type="vendor", itemID=266239}}, -- Early Access / Midnight pre-patch
      {decorID=17869,  source={type="vendor", itemID=266240}}, -- Early Access / Midnight pre-patch
      {decorID=17870,  source={type="vendor", itemID=266241}}, -- Early Access / Midnight pre-patch
      {decorID=17871,  source={type="vendor", itemID=266242}}, -- Early Access / Midnight pre-patch
      {decorID=17872,  source={type="vendor", itemID=266243}}, -- Early Access / Midnight pre-patch
      {decorID=17873,  source={type="vendor", itemID=266244}},
      {decorID=17874,  source={type="vendor", itemID=266245}},
      {decorID=17918,  source={type="vendor", itemID=266443}},
      {decorID=17919,  source={type="vendor", itemID=266444}}}
  },
  {
    source={
      id=255216,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:5220:3800"},
    items={
      {decorID=80,  source={type="vendor", itemID=235994, currency="1000", currencytype="Order Resources"}, requirements={quest={id=93008}}},
      {decorID=984,  source={type="vendor", itemID=241617}, requirements={quest={id=93143}}},
      {decorID=985,  source={type="vendor", itemID=241618}, requirements={quest={id=93000}}},
      {decorID=987,  source={type="vendor", itemID=241620, currency="750", currencytype="Order Resources"}, requirements={quest={id=93150}}},
      {decorID=988,  source={type="vendor", itemID=241621, currency="200", currencytype="Order Resources"}, requirements={quest={id=93152}}},
      {decorID=989,  source={type="vendor", itemID=241622, currency="300", currencytype="War Resources"}},
      {decorID=994,  source={type="vendor", itemID=253441, currency="500", currencytype="Order Resources"}, requirements={quest={id=93005}}},
      {decorID=1153,  source={type="vendor", itemID=253479}, requirements={quest={id=93006}}},
      {decorID=1162,  source={type="vendor", itemID=253490, currency="300", currencytype="Order Resources"}, requirements={quest={id=93002}}},
      {decorID=1163,  source={type="vendor", itemID=253493, currency="500", currencytype="Order Resources"}, requirements={quest={id=93147}}},
      {decorID=1245,  source={type="vendor", itemID=243242, currency="250", currencytype="Dragon Isles Supplies"}},
      {decorID=1246,  source={type="vendor", itemID=243243, currency="250", currencytype="Dragon Isles Supplies"}},
      {decorID=1329,  source={type="vendor", itemID=243495}, requirements={quest={id=93149}}},
      {decorID=1487,  source={type="vendor", itemID=244781, currency="2000", currencytype="Order Resources"}},
      {decorID=1770,  source={type="vendor", itemID=245575, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92994}}},
      {decorID=1771,  source={type="vendor", itemID=245576, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92993}}},
      {decorID=1772,  source={type="vendor", itemID=245578, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92992}}},
      {decorID=1773,  source={type="vendor", itemID=245579, currency="500", currencytype="Dragon Isles Supplies"}},
      {decorID=1774,  source={type="vendor", itemID=245581}, requirements={quest={id=93135}}},
      {decorID=1775,  source={type="vendor", itemID=245582}},
      {decorID=1776,  source={type="vendor", itemID=245583}, requirements={quest={id=93136}}},
      {decorID=1844,  source={type="vendor", itemID=245649}, requirements={quest={id=93137}}},
      {decorID=2104,  source={type="vendor", itemID=246249}, requirements={quest={id=93140}}},
      {decorID=2105,  source={type="vendor", itemID=246250}, requirements={quest={id=93138}}},
      {decorID=2106,  source={type="vendor", itemID=246251}},
      {decorID=2107,  source={type="vendor", itemID=246252}},
      {decorID=2108,  source={type="vendor", itemID=246253}, requirements={quest={id=93139}}},
      {decorID=2109,  source={type="vendor", itemID=246254}, requirements={quest={id=92991}}},
      {decorID=2110,  source={type="vendor", itemID=246255}, requirements={quest={id=93009}}},
      {decorID=2111,  source={type="vendor", itemID=246256, currency="350", currencytype="Dragon Isles Supplies"}},
      {decorID=2112,  source={type="vendor", itemID=246257, currency="350", currencytype="Dragon Isles Supplies"}},
      {decorID=2113,  source={type="vendor", itemID=246258}, requirements={quest={id=92990}}},
      {decorID=2254,  source={type="vendor", itemID=246431, currency="2000", currencytype="Order Resources"}},
      {decorID=2458,  source={type="vendor", itemID=246691, currency="2000", currencytype="Order Resources"}},
      {decorID=2474,  source={type="vendor", itemID=246711, currency="750", currencytype="Dragon Isles Supplies"}},
      {decorID=2590,  source={type="vendor", itemID=246961, currency="750", currencytype="Dragon Isles Supplies"}},
      {decorID=3826,  source={type="vendor", itemID=247501}},
      {decorID=4562,  source={type="vendor", itemID=248760, currency="75", currencytype="Order Resources"}, requirements={quest={id=93134}}},
      {decorID=5563,  source={type="vendor", itemID=249558, currency="2000", currencytype="Order Resources"}},
      {decorID=8917,  source={type="vendor", itemID=251981}, requirements={quest={id=93141}}},
      {decorID=8918,  source={type="vendor", itemID=251982}},
	  {decorID=9254,  source={type="vendor", itemID=253180, currency="1200", currencytype="Order Resources"}},
      {decorID=9255,  source={type="vendor", itemID=253181, currency="500", currencytype="Order Resources"}, requirements={quest={id=93007}}},
      {decorID=10860,  source={type="vendor", itemID=255650, currency="10", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92995}}},
      {decorID=11719,  source={type="vendor", itemID=257690}, requirements={quest={id=93003}}},
      {decorID=15454,  source={type="vendor", itemID=264169}}}
  },
  {
    source={
      id=255213,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:5200:3840"},
    items={
      {decorID=479,  source={type="vendor", itemID=245365}},
      {decorID=480,  source={type="vendor", itemID=245366}},
      {decorID=481,  source={type="vendor", itemID=245368}},
      {decorID=482,  source={type="vendor", itemID=245357}},
      {decorID=485,  source={type="vendor", itemID=245377}},
      {decorID=486,  source={type="vendor", itemID=245378}},
      {decorID=487,  source={type="vendor", itemID=245360, currency="500", currencytype="Garrison Resources"}},
      {decorID=488,  source={type="vendor", itemID=245359, currency="2000", currencytype="Apexis Crystal"}},
      {decorID=489,  source={type="vendor", itemID=245379}},
      {decorID=490,  source={type="vendor", itemID=245380}},
      {decorID=491,  source={type="vendor", itemID=245382}},
      {decorID=492,  source={type="vendor", itemID=245385, currency="1000", currencytype="Order Resources"}},
      {decorID=493,  source={type="vendor", itemID=245386}},
      {decorID=494,  source={type="vendor", itemID=235523, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=92965}}},
      {decorID=496,  source={type="vendor", itemID=245372}, requirements={quest={id=92983}}},
      {decorID=497,  source={type="vendor", itemID=245374}},
      {decorID=770,  source={type="vendor", itemID=245367}},
      {decorID=1122,  source={type="vendor", itemID=242951}, requirements={quest={id=92969}}},
      {decorID=1280,  source={type="vendor", itemID=243334}, requirements={quest={id=92978}}},
      {decorID=1457,  source={type="vendor", itemID=244667, currency="300", currencytype="Garrison Resources"}},
      {decorID=1742,  source={type="vendor", itemID=245551, currency="300", currencytype="Order Resources"}},
      {decorID=1862,  source={type="vendor", itemID=245656}},
      {decorID=1863,  source={type="vendor", itemID=245657, currency="500", currencytype="Garrison Resources"}},
      {decorID=1878,  source={type="vendor", itemID=245662}, requirements={quest={id=92999}}},
      {decorID=1992,  source={type="vendor", itemID=246102}, requirements={quest={id=92998}}},
      {decorID=1994,  source={type="vendor", itemID=246104}, requirements={quest={id=92971}}},
      {decorID=1995,  source={type="vendor", itemID=246105}},
      {decorID=1996,  source={type="vendor", itemID=246106, currency="350", currencytype="Order Resources"}, requirements={quest={id=92985}}},
      {decorID=1997,  source={type="vendor", itemID=246107}, requirements={quest={id=92997}}},
      {decorID=1999,  source={type="vendor", itemID=246109}},
      {decorID=2089,  source={type="vendor", itemID=246219}},
      {decorID=2385,  source={type="vendor", itemID=246588}},
      {decorID=2496,  source={type="vendor", itemID=246742}, requirements={quest={id=92970}}},
      {decorID=9472,  source={type="vendor", itemID=253590}},
      {decorID=14814,  source={type="vendor", itemID=263025, currency="100", currencytype="Garrison Resources"}}}
  },
  {
    source={
      id=255230,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:6223:8030"},
    items={
      {decorID=4406,  source={type="vendor", itemID=248337}},
      {decorID=4407,  source={type="vendor", itemID=248338}},
      {decorID=4408,  source={type="vendor", itemID=248339}},
      {decorID=4451,  source={type="vendor", itemID=248625}},
      {decorID=4452,  source={type="vendor", itemID=248626}},
      {decorID=4453,  source={type="vendor", itemID=248627}},
      {decorID=4454,  source={type="vendor", itemID=248628}},
      {decorID=4455,  source={type="vendor", itemID=248629, currency="250", currencytype="Garrison Resources"}},
      {decorID=4456,  source={type="vendor", itemID=248630}},
      {decorID=4457,  source={type="vendor", itemID=248631}},
      {decorID=4458,  source={type="vendor", itemID=248632}},
      {decorID=4459,  source={type="vendor", itemID=248633}},
      {decorID=4460,  source={type="vendor", itemID=248634}},
      {decorID=4462,  source={type="vendor", itemID=248636}},
      {decorID=4463,  source={type="vendor", itemID=248637}},
      {decorID=4464,  source={type="vendor", itemID=248638}},
      {decorID=4476,  source={type="vendor", itemID=248650}},
      {decorID=11461,  source={type="vendor", itemID=257359}},
      {decorID=11479,  source={type="vendor", itemID=257388}},
      {decorID=11481,  source={type="vendor", itemID=257390}},
      {decorID=11482,  source={type="vendor", itemID=257392}},
      {decorID=14382,  source={type="vendor", itemID=260701}},
      {decorID=14383,  source={type="vendor", itemID=260702}},
      {decorID=17863,  source={type="vendor", itemID=266234}},
      {decorID=17864,  source={type="vendor", itemID=266235}},
      {decorID=17865,  source={type="vendor", itemID=266236}},
      {decorID=17866,  source={type="vendor", itemID=266237}},
      {decorID=17867,  source={type="vendor", itemID=266238}},
      {decorID=17873,  source={type="vendor", itemID=266244}},
      {decorID=17874,  source={type="vendor", itemID=266245}},
      {decorID=17918,  source={type="vendor", itemID=266443}},
      {decorID=17919,  source={type="vendor", itemID=266444}}}
  },
  {
    source={
      id=256750,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:5830:6168"},
    items={
      {decorID=721,  source={type="vendor", itemID=245400, currency="300", currencytype="Resonance Crystals"}},
      {decorID=722,  source={type="vendor", itemID=245401, currency="300", currencytype="Resonance Crystals"}},
      {decorID=723,  source={type="vendor", itemID=245402, currency="200", currencytype="War Resources"}},
      {decorID=724,  source={type="vendor", itemID=245403, currency="300", currencytype="Resonance Crystals"}},
      {decorID=725,  source={type="vendor", itemID=245404, currency="200", currencytype="War Resources"}}}
  },
  {
    source={
      id=257897,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5304:3804"},
    items={
      {decorID=16227,  source={type="vendor", itemID=264915}}, 
      {decorID=16228,  source={type="vendor", itemID=264916}}, 
      {decorID=16229,  source={type="vendor", itemID=264917}}, 
      {decorID=16230,  source={type="vendor", itemID=264918}},
      {decorID=16231,  source={type="vendor", itemID=264919, currency="5000", currencytype="Honor"}}, 
      {decorID=16232,  source={type="vendor", itemID=264920, currency="1000", currencytype="Voidlight Marl"}}, 
      {decorID=16233,  source={type="vendor", itemID=264921}}, 
      {decorID=16234,  source={type="vendor", itemID=264922}}, 
      {decorID=16235,  source={type="vendor", itemID=264923}}, 
      {decorID=16236,  source={type="vendor", itemID=264924, currency="250", currencytype="Dragon Isles Supplies"}}, 
      {decorID=16237,  source={type="vendor", itemID=264925}}, 
      {decorID=16315,  source={type="vendor", itemID=265032, currency="500", currencytype="Order Resources"}}, 
      {decorID=16962,  source={type="vendor", itemID=265541, currency="1000", currencytype="Honor"}}}
  },
    {
    source={
      id=68363,
      type="vendor",
      faction="Alliance",
      zone="Bizmo's Brawlpub",
      worldmap="499:5100:3000"},
    items={
      {decorID=10913,  source={type="vendor", itemID=255840, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12263,  source={type="vendor", itemID=259071, currency="750", currencytype="Honor"}, requirements={rep="true"}},
      {decorID=14815,  source={type="vendor", itemID=263026, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}}}
  },
  {
    source={
      id=255203,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:5195:3831"},
    items={
      {decorID=373,  source={type="vendor", itemID=245375}, requirements={quest={id=92437}}},
      {decorID=374,  source={type="vendor", itemID=245384}, requirements={quest={id=92961}}},
      {decorID=377,  source={type="vendor", itemID=235675, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=92988}}},
      {decorID=378,  source={type="vendor", itemID=245355}, requirements={quest={id=92962}}},
      {decorID=379,  source={type="vendor", itemID=245358, currency="100", currencytype="Garrison Resources"}},
      {decorID=383,  source={type="vendor", itemID=235677, currency="800", currencytype="War Resources"}, requirements={quest={id=92987}}},
      {decorID=388,  source={type="vendor", itemID=245383, currency="1000", currencytype="Garrison Resources"}},
      {decorID=389,  source={type="vendor", itemID=245356, currency="350", currencytype="War Resources"}, requirements={quest={id=92963}}},
      {decorID=390,  source={type="vendor", itemID=245376}, requirements={quest={id=92964}}},
      {decorID=478,  source={type="vendor", itemID=245354}},
      {decorID=483,  source={type="vendor", itemID=245352}},
      {decorID=484,  source={type="vendor", itemID=245353}},
      {decorID=495,  source={type="vendor", itemID=245336}, requirements={quest={id=92984}}},
      {decorID=498,  source={type="vendor", itemID=235633, currency="250", currencytype="Dragon Isles Supplies"}},
      {decorID=527,  source={type="vendor", itemID=236675}},
      {decorID=528,  source={type="vendor", itemID=236676}, requirements={quest={id=92966}}},
      {decorID=529,  source={type="vendor", itemID=236677}, requirements={quest={id=92968}}},
      {decorID=530,  source={type="vendor", itemID=236678}, requirements={quest={id=92967}}},
      {decorID=533,  source={type="vendor", itemID=245392}},
      {decorID=534,  source={type="vendor", itemID=245393}},
      {decorID=535,  source={type="vendor", itemID=245394}},
      {decorID=536,  source={type="vendor", itemID=245395}},
      {decorID=726,  source={type="vendor", itemID=239075}, requirements={quest={id=92986}}},
      {decorID=1044,  source={type="vendor", itemID=242255, currency="750", currencytype="Order Resources"}},
      -- Says Test Item?{decorID=1083,  source={type="vendor", itemID=245370, currency="550", currencytype="War Resources"}, requirements={quest={id=93119}}},
      {decorID=1123,  source={type="vendor", itemID=245334}, requirements={quest={id=92979}}},
      {decorID=1244,  source={type="vendor", itemID=245335}},
      {decorID=1434,  source={type="vendor", itemID=244530}},
      {decorID=1435,  source={type="vendor", itemID=244531}, requirements={quest={id=92982}}},
      {decorID=1454,  source={type="vendor", itemID=244664}},
      {decorID=1455,  source={type="vendor", itemID=244665, currency="1000", currencytype="Garrison Resources"}},
      {decorID=1456,  source={type="vendor", itemID=244666, currency="300", currencytype="War Resources"}},
      {decorID=1701,  source={type="vendor", itemID=245267}},
      {decorID=1702,  source={type="vendor", itemID=245268}},
      {decorID=1738,  source={type="vendor", itemID=245547}, requirements={quest={id=92981}}},
      {decorID=1739,  source={type="vendor", itemID=245548}, requirements={quest={id=92977}}},
      {decorID=1745,  source={type="vendor", itemID=245556}, requirements={quest={id=92980}}},
      {decorID=1991,  source={type="vendor", itemID=246101, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=92973}}},
      {decorID=1993,  source={type="vendor", itemID=246103}, requirements={quest={id=92972}}},
      {decorID=1996,  source={type="vendor", itemID=246106, currency="350", currencytype="Order Resources"}, requirements={quest={id=92985}}},
      {decorID=2099,  source={type="vendor", itemID=246243}, requirements={quest={id=92976}}},
      {decorID=2100,  source={type="vendor", itemID=246245}, requirements={quest={id=92975}}},
      {decorID=2101,  source={type="vendor", itemID=246246}, requirements={quest={id=92974}}},
      {decorID=2102,  source={type="vendor", itemID=246247}},
      {decorID=2103,  source={type="vendor", itemID=246248}},
      {decorID=2342,  source={type="vendor", itemID=246502}, requirements={quest={id=92996}}},
      {decorID=9064,  source={type="vendor", itemID=252417}},
      {decorID=9144,  source={type="vendor", itemID=252659}},
      {decorID=9471,  source={type="vendor", itemID=253589}, requirements={quest={id=92989}}},
      {decorID=9473,  source={type="vendor", itemID=253592}},
      {decorID=9474,  source={type="vendor", itemID=253593}},
      {decorID=12199,  source={type="vendor", itemID=258670}}}
  },
  {
    source={
      id=255218,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:5220:3779"},
    items={
      {decorID=986,  source={type="vendor", itemID=253437, currency="750", currencytype="Order Resources"}},
      {decorID=990,  source={type="vendor", itemID=241623}, requirements={quest={id=93142}}},
	  {decorID=991,  source={type="vendor", itemID=253439, currency="750", currencytype="Order Resources"}},
      --       {decorID=992,  source={type="vendor", itemID=241625}}, -- Early Access / Midnight pre-patch
      {decorID=1155,  source={type="vendor", itemID=243088, currency="500", currencytype="Order Resources"}},
      {decorID=1165,  source={type="vendor", itemID=253495, currency="750", currencytype="Order Resources"}},
      {decorID=1350,  source={type="vendor", itemID=244118, currency="350", currencytype="Dragon Isles Supplies"}},
      {decorID=1356,  source={type="vendor", itemID=244169, currency="350", currencytype="Dragon Isles Supplies"}, requirements={quest={id=93148}}},
      {decorID=1486,  source={type="vendor", itemID=244780, currency="175", currencytype="Order Resources"}, requirements={quest={id=93004}}},
      {decorID=1488,  source={type="vendor", itemID=244782, currency="175", currencytype="Order Resources"}, requirements={quest={id=93001}}},
      {decorID=3827,  source={type="vendor", itemID=247502}},
      {decorID=4484,  source={type="vendor", itemID=248658}},
      {decorID=11720,  source={type="vendor", itemID=257691}, requirements={quest={id=93142}}},
	  {decorID=11721,  source={type="vendor", itemID=257692, currency="400", currencytype="Order Resources"}, requirements={quest={id=93151}}}}
  },
  {
    source={
      id=49877,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City, Trade District, Stormwind",
      worldmap="84:6779:7305"},
    items={
      {decorID=4402,  source={type="vendor", itemID=248333, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=4405,  source={type="vendor", itemID=248336, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=59583}}},
      {decorID=4443,  source={type="vendor", itemID=248617, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=4444,  source={type="vendor", itemID=248618, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=26270}}},
      {decorID=4445,  source={type="vendor", itemID=248619, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4446,  source={type="vendor", itemID=248620, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=4447,  source={type="vendor", itemID=248621, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=26390}}},
      {decorID=4487,  source={type="vendor", itemID=248662, currency="1000", currencytype="Order Resources"}, requirements={quest={id=543}}},
      {decorID=4490,  source={type="vendor", itemID=248665, currency="1500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=4811,  source={type="vendor", itemID=248794}, requirements={rep="true"}},
      {decorID=4812,  source={type="vendor", itemID=248795}, requirements={rep="true"}},
      {decorID=4814,  source={type="vendor", itemID=248797, currency="350", currencytype="Order Resources"}, requirements={quest={id=26229}}},
      {decorID=4815,  source={type="vendor", itemID=248798, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=54}}},
      {decorID=4819,  source={type="vendor", itemID=248801, currency="1500", currencytype="Order Resources"}, requirements={quest={id=26297}}},
      {decorID=5115,  source={type="vendor", itemID=248938, currency="350", currencytype="Order Resources"}, requirements={quest={id=60}}},
      {decorID=5116,  source={type="vendor", itemID=248939, currency="300", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=9242,  source={type="vendor", itemID=253168, currency="600", currencytype="Resonance Crystals"}},
      {decorID=11274,  source={type="vendor", itemID=256673}, requirements={quest={id=7604}}}}
  },
  {
    source={
      id=255222,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:6240:8020"},
    items={
	  {decorID=1482,  source={type="vendor", itemID=244778, currency="2", currencytype="Silver"}},
      {decorID=81,  source={type="vendor", itemID=245398}, requirements={quest={id=93110}}},
      {decorID=522,  source={type="vendor", itemID=236653}},
      {decorID=523,  source={type="vendor", itemID=236654}, requirements={quest={id=93073}}},
      {decorID=524,  source={type="vendor", itemID=236655}, requirements={quest={id=93074}}},
      {decorID=525,  source={type="vendor", itemID=236666}, requirements={quest={id=93075}}},
      {decorID=526,  source={type="vendor", itemID=236667}},
      {decorID=534,  source={type="vendor", itemID=245393}},
      {decorID=535,  source={type="vendor", itemID=245394}},
      {decorID=536,  source={type="vendor", itemID=245395}},
      {decorID=1437,  source={type="vendor", itemID=244533}, requirements={quest={id=93078}}},
      {decorID=1438,  source={type="vendor", itemID=244534, currency="5000", currencytype="Honor"}, requirements={quest={id=93079}}},
      {decorID=1451,  source={type="vendor", itemID=244661, currency="150", currencytype="Garrison Resources"}},
      {decorID=1452,  source={type="vendor", itemID=244662, currency="150", currencytype="Garrison Resources"}},
      {decorID=1453,  source={type="vendor", itemID=244663, currency="150", currencytype="Garrison Resources"}},
      {decorID=1698,  source={type="vendor", itemID=245264, currency="300", currencytype="Garrison Resources"}},
      {decorID=1699,  source={type="vendor", itemID=245265}},
      {decorID=1700,  source={type="vendor", itemID=245266, currency="175", currencytype="Order Resources"}, requirements={quest={id=93080}}},
      {decorID=1723,  source={type="vendor", itemID=245532, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93081}}},
      {decorID=1736,  source={type="vendor", itemID=245545, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=93083}}},
      {decorID=1744,  source={type="vendor", itemID=245555, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=93111}}},
      {decorID=1879,  source={type="vendor", itemID=245680, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=93109}}},
      {decorID=1977,  source={type="vendor", itemID=246036, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93091}}},
      {decorID=1978,  source={type="vendor", itemID=246037}},
      {decorID=1979,  source={type="vendor", itemID=246038, currency="250", currencytype="Ancient Mana"}},
      {decorID=2092,  source={type="vendor", itemID=246223}},
      {decorID=2093,  source={type="vendor", itemID=246224, currency="500", currencytype="Garrison Resources"}, requirements={quest={id=93099}}},
      {decorID=2094,  source={type="vendor", itemID=246225, currency="150", currencytype="War Resources"}},
      {decorID=2114,  source={type="vendor", itemID=246259}, requirements={quest={id=93085}}},
      {decorID=2115,  source={type="vendor", itemID=246260}, requirements={quest={id=93087}}},
      {decorID=2116,  source={type="vendor", itemID=246261}, requirements={quest={id=93088}}},
      {decorID=2117,  source={type="vendor", itemID=246262}},
      {decorID=2118,  source={type="vendor", itemID=246263}},
      {decorID=2384,  source={type="vendor", itemID=246587, currency="500", currencytype="Garrison Resources"}, requirements={quest={id=93100}}},
      {decorID=2439,  source={type="vendor", itemID=246607, currency="300", currencytype="Garrison Resources"}},
      {decorID=2440,  source={type="vendor", itemID=246608, currency="300", currencytype="Garrison Resources"}},
      {decorID=2441,  source={type="vendor", itemID=246609, currency="750", currencytype="Order Resources"}},
      {decorID=2442,  source={type="vendor", itemID=246610, currency="250", currencytype="Dragon Isles Supplies"}},
      {decorID=2445,  source={type="vendor", itemID=246613, currency="300", currencytype="Garrison Resources"}},
      {decorID=2446,  source={type="vendor", itemID=246614, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=93115}}},
      {decorID=2454,  source={type="vendor", itemID=246687, currency="300", currencytype="War Resources"}, requirements={quest={id=93101}}},
      {decorID=2535,  source={type="vendor", itemID=246869, currency="1000", currencytype="Order Resources"}, requirements={quest={id=93132}}},
      {decorID=2545,  source={type="vendor", itemID=246879, currency="150", currencytype="Dragon Isles Supplies"}},
      {decorID=2592,  source={type="vendor", itemID=247221, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93106}}},
      {decorID=4386,  source={type="vendor", itemID=248246, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=93107}}},
      {decorID=5853,  source={type="vendor", itemID=250093}},
      {decorID=5854,  source={type="vendor", itemID=250094}},
      {decorID=7836,  source={type="vendor", itemID=250913, currency="300", currencytype="Garrison Resources"}},
      {decorID=7842,  source={type="vendor", itemID=250920, currency="150", currencytype="Dragon Isles Supplies"}, requirements={quest={id=93102}}},
      {decorID=8771,  source={type="vendor", itemID=251639}},
      {decorID=8907,  source={type="vendor", itemID=251973, currency="500", currencytype="Order Resources"}, requirements={quest={id=93108}}},
      {decorID=8910,  source={type="vendor", itemID=251974}},
      {decorID=8911,  source={type="vendor", itemID=251975, currency="150", currencytype="Dragon Isles Supplies"}},
      {decorID=8912,  source={type="vendor", itemID=251976}},
      {decorID=9143,  source={type="vendor", itemID=252657, currency="150", currencytype="Garrison Resources"}},
      {decorID=10324,  source={type="vendor", itemID=254316, currency="550", currencytype="War Resources"}},
      {decorID=10367,  source={type="vendor", itemID=254560, currency="300", currencytype="Garrison Resources"}},
      {decorID=10952,  source={type="vendor", itemID=256050, currency="5000", currencytype="Honor"}},
      {decorID=11480,  source={type="vendor", itemID=257389, currency="175", currencytype="Order Resources"}},
      {decorID=11874,  source={type="vendor", itemID=258148}}}
  },
  {
    source={
      id=255228,
      type="vendor",
      faction="Alliance",
      zone="Founder's Point",
      worldmap="2352:6240:8000"},
    items={
      {decorID=1436,  source={type="vendor", itemID=244532, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93077}}},
      {decorID=1439,  source={type="vendor", itemID=244535, currency="900", currencytype="Resonance Crystals"}},
      {decorID=1724,  source={type="vendor", itemID=245533, currency="600", currencytype="Resonance Crystals"}, requirements={quest={id=93082}}},
      {decorID=1737,  source={type="vendor", itemID=245546}, requirements={quest={id=93084}}},
      {decorID=2087,  source={type="vendor", itemID=246217, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93097}}},
      {decorID=2088,  source={type="vendor", itemID=246218}, requirements={quest={id=93098}}},
      {decorID=2090,  source={type="vendor", itemID=246220, currency="100", currencytype="Garrison Resources"}},
      {decorID=2098,  source={type="vendor", itemID=246241, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93103}}},
      {decorID=2443,  source={type="vendor", itemID=246611, currency="500", currencytype="Garrison Resources"}},
      {decorID=2444,  source={type="vendor", itemID=246612, currency="300", currencytype="Garrison Resources"}},
      {decorID=2447,  source={type="vendor", itemID=246615}},
      {decorID=2448,  source={type="vendor", itemID=246616}},
      {decorID=2534,  source={type="vendor", itemID=246868}, requirements={quest={id=93131}}},
      {decorID=2546,  source={type="vendor", itemID=246880, currency="150", currencytype="War Resources"}, requirements={quest={id=93104}}},
      {decorID=2547,  source={type="vendor", itemID=246881, currency="150", currencytype="War Resources"}},
      {decorID=2548,  source={type="vendor", itemID=246882, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93133}}},
      {decorID=2549,  source={type="vendor", itemID=246883, currency="150", currencytype="War Resources"}, requirements={quest={id=93105}}},
      {decorID=2550,  source={type="vendor", itemID=246884, currency="150", currencytype="War Resources"}},
      {decorID=5561,  source={type="vendor", itemID=249550, currency="400", currencytype="War Resources"}},
      {decorID=8236,  source={type="vendor", itemID=251545}},
      {decorID=8769,  source={type="vendor", itemID=251637}},
      {decorID=8770,  source={type="vendor", itemID=251638}},
      {decorID=10791,  source={type="vendor", itemID=254893}},
      {decorID=10892,  source={type="vendor", itemID=255708}},
      {decorID=11139,  source={type="vendor", itemID=256357, currency="100", currencytype="Garrison Resources"}},
      {decorID=11437,  source={type="vendor", itemID=257099}}}
  },
  {
    source={
      id=253235,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh",
      worldmap="87:2472:4393"},
    items={
      {decorID=1118,  source={type="vendor", itemID=245427, currency="900", currencytype="Resonance Crystals"}, requirements={quest={id=53566}}},
      {decorID=1216,  source={type="vendor", itemID=245426, currency="600", currencytype="Resonance Crystals"}, requirements={achievement={id=4859}}},
      {decorID=2243,  source={type="vendor", itemID=246426, currency="400", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2333,  source={type="vendor", itemID=246490}, requirements={rep="true"}},
      {decorID=2334,  source={type="vendor", itemID=246491}, requirements={rep="true"}},
      {decorID=8982,  source={type="vendor", itemID=252010, currency="400", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=11133,  source={type="vendor", itemID=256333, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=11160,  source={type="vendor", itemID=256425}, requirements={achievement={id=8316}}}}
  },
  {
    source={
      id=253227,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4974:2957"},
    items={
      {decorID=1998,  source={type="vendor", itemID=246108, currency="750", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=2242,  source={type="vendor", itemID=246425, currency="175", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2244,  source={type="vendor", itemID=246427, currency="1000", currencytype="Order Resources"}, requirements={quest={id=28244}}},
      {decorID=2245,  source={type="vendor", itemID=246428, currency="2000", currencytype="Apexis Crystal"}, requirements={quest={id=28655}}}}
  },
  {
    source={
      id=49386,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap="241:4861:3068"},
    items={
      {decorID=1998,  source={type="vendor", itemID=246108, currency="750", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=2242,  source={type="vendor", itemID=246425, currency="175", currencytype="Order Resources"}, requirements={rep="true"}}}
  },
  {
    source={
      id=45417,
      type="vendor",
      faction="Neutral",
      zone="Light's Hope Chapel",
      worldmap="23:7380:5220"},
    items={
      {decorID=4813,  source={type="vendor", itemID=248796, currency="1500", currencytype="Garrison Resources"}, requirements={achievement={id=5442}}}}
  },
  {
    source={
      id=253232,
      type="vendor",
      faction="Alliance",
      zone="The Library, Ironforge",
      worldmap="87:7580:0940"},
    items={
      {decorID=2228,  source={type="vendor", itemID=246411, currency="500", currencytype="Garrison Resources"}},
      {decorID=2229,  source={type="vendor", itemID=246412, currency="550", currencytype="War Resources"}}}
  },
  {
    source={
      id=50309,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh, Ironforge",
      worldmap="87:5560:4820"},
    items={
      {decorID=2243,  source={type="vendor", itemID=246426, currency="400", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2333,  source={type="vendor", itemID=246490}, requirements={rep="true"}},
      {decorID=2334,  source={type="vendor", itemID=246491}, requirements={rep="true"}},
      {decorID=8982,  source={type="vendor", itemID=252010, currency="400", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=11133,  source={type="vendor", itemID=256333, currency="750", currencytype="Order Resources"}, requirements={rep="true"}}}
  },
  {
    source={
      id=1247,
      type="vendor",
      faction="Alliance",
      zone="Dun Morogh",
      worldmap="27:5440:5080"},
    items={
      {decorID=11130,  source={type="vendor", itemID=256330, currency="550", currencytype="War Resources"}}}
  },
  {
    source={
      id=50304,
      type="vendor",
      faction="Horde",
      zone="Undercity, Orgrimmar",
      worldmap="90:6320:4900"},
    items={
      {decorID=923,  source={type="vendor", itemID=245504, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=27098}}},
      {decorID=924,  source={type="vendor", itemID=245505, currency="350", currencytype="Resonance Crystals"}, requirements={quest={id=27098}}}}
  },
  {
    source={
      id=256119,
      type="vendor",
      faction="Horde",
      zone="Orgrimmar",
      worldmap="86:9987:1210"},
    items={
      {decorID=766,  source={type="vendor", itemID=239177, currency="1200", currencytype="Resonance Crystals"}},
      {decorID=768,  source={type="vendor", itemID=239179, currency="3000", currencytype="Order Resources"}},
      {decorID=2511,  source={type="vendor", itemID=246845, currency="750", currencytype="Resonance Crystals"}},
      {decorID=2513,  source={type="vendor", itemID=246847, currency="750", currencytype="Resonance Crystals"}},
      {decorID=2514,  source={type="vendor", itemID=246848, currency="1200", currencytype="Resonance Crystals"}},
      {decorID=2526,  source={type="vendor", itemID=246860, currency="750", currencytype="Resonance Crystals"}}}
  },
  {
    source={
      id=256071,
      type="vendor",
      faction="Alliance",
      zone="Stormwind City",
      worldmap="84:4926:8009"},
    items={
      {decorID=766,  source={type="vendor", itemID=239177, currency="1200", currencytype="Resonance Crystals"}},
      {decorID=768,  source={type="vendor", itemID=239179, currency="3000", currencytype="Order Resources"}},
      {decorID=2511,  source={type="vendor", itemID=246845, currency="750", currencytype="Resonance Crystals"}},
      {decorID=2513,  source={type="vendor", itemID=246847, currency="750", currencytype="Resonance Crystals"}},
      {decorID=2514,  source={type="vendor", itemID=246848, currency="1200", currencytype="Resonance Crystals"}},
      {decorID=2526,  source={type="vendor", itemID=246860, currency="750", currencytype="Resonance Crystals"}}}
  },
  {
    source={
      id=100196,
      type="vendor",
      faction="Neutral",
      zone="Sanctum of Light",
      worldmap="23:7564:4909"},
    items={
      {decorID=7571,  source={type="vendor", itemID=250230, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42293}}},
      {decorID=7572,  source={type="vendor", itemID=250231, currency="500", currencytype="Order Resources"}},
      {decorID=7573,  source={type="vendor", itemID=250232, currency="500", currencytype="Order Resources"}},
      {decorID=7574,  source={type="vendor", itemID=250233, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60968}}},
      {decorID=7575,  source={type="vendor", itemID=250234, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42276}}},
      {decorID=7576,  source={type="vendor", itemID=250235, currency="1000", currencytype="Order Resources"}},
      {decorID=7577,  source={type="vendor", itemID=250236, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60987}}}}
  },
  {
    source={
      id=14624,
      type="vendor",
      faction="Horde",
      zone="Searing Gorge",
      worldmap="32:3860:2870"},
    items={
      {decorID=1315,  source={type="vendor", itemID=245333}, requirements={quest={id=28035}}},
      {decorID=2226,  source={type="vendor", itemID=246409, currency="750", currencytype="Honor"}, requirements={quest={id=28064}}}}
  },
  {
    source={
      id=115805,
      type="vendor",
      faction="Horde",
      zone="Burning Steppes",
      worldmap="36:4680:4460"},
    items={
      {decorID=11131,  source={type="vendor", itemID=256331, currency="1000", currencytype="Garrison Resources"}, requirements={quest={id=35685}}}}
  },
  {
    source={
      id=44114,
      type="vendor",
      faction="Alliance",
      zone="Duskwood",
      worldmap="47:2027:5835"},
    items={
      {decorID=1833,  source={type="vendor", itemID=245624, currency="1000", currencytype="Order Resources"}, requirements={quest={id=26760}}},
      {decorID=11305,  source={type="vendor", itemID=256905}, requirements={quest={id=26754}}}}
  },
  {
    source={
      id=13217,
      type="vendor",
      faction="Alliance",
      zone="Hillsbrad Foothills",
      worldmap="25:4480:4640"},
    items={
      {decorID=2241,  source={type="vendor", itemID=246424}}}
  },
  {
    source={
      id=2140,
      type="vendor",
      faction="Horde",
      zone="Silverpine Forest",
      worldmap="21:4406:3968"},
    items={
      {decorID=11498,  source={type="vendor", itemID=257412, currency="175", currencytype="Order Resources"}, requirements={quest={id=27550}}}}
  },
  {
    source={
      id=44337,
      type="vendor",
      faction="Alliance",
      zone="Surwich, Blasted Lands",
      worldmap="17:4580:8860"},
    items={
      {decorID=1481,  source={type="vendor", itemID=244777, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=80516}}}}
  }}
