local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["Kalimdor"] = {

  {
    source={
      id=1465,
      type="vendor",
      faction="Alliance",
      zone="Thelsamar, Loch Modan",
      worldmap="48:3560:4900"
    },
    items={
      {decorID=2239, source={type="vendor", itemID=246422, currency="285", currencytype="gold"}, requirements={quest={id=26868}}},
    }
  },

  {
    source={
      id=2483,
      type="vendor",
      faction="Neutral",
      zone="Stranglethorn Vale",
      worldmap="50:4380:2320"
    },
    items={
      {decorID=4841, source={type="vendor", itemID=248808, currency="450", currencytype="gold"}, requirements={achievement={id=940}}},
    }
  },

  {
    source={
      id=3178,
      type="vendor",
      faction="Neutral",
      zone="Wetlands",
      worldmap="56:627:5745"
    },
    items={
      {decorID=11495, source={type="vendor", itemID=257405}},
    }
  },

  {
    source={
      id=23995,
      type="vendor",
      faction="Neutral",
      zone="Mudsprocket, Dustwallow Marsh",
      worldmap="70:4190:7390"
    },
    items={
      {decorID=1674, source={type="vendor", itemID=244852, currency="250", currencytype="gold"}, requirements={achievement={id=4405}}},
    }
  },

  {
    source={
      id=50307,
      type="vendor",
      faction="Alliance",
      zone="Darnassus",
      worldmap="89:3720:4760"
    },
    items={
      {decorID=858, source={type="vendor", itemID=245518, currency="150", currencytype="gold"}, requirements={quest={id=24675}}},
      {decorID=1794, source={type="vendor", itemID=245603, currency="350", currencytype="gold"}, requirements={rep="true"}},
      {decorID=1796, source={type="vendor", itemID=245605, currency="300", currencytype="gold"}, requirements={rep="true"}},
      {decorID=1829, source={type="vendor", itemID=245620, currency="50", currencytype="gold"}, requirements={quest={id=14402}}},
    }
  },

  {
    source={
      id=50483,
      type="vendor",
      faction="Horde",
      zone="Thunder Bluff",
      worldmap="88:4620:5060"
    },
    items={
      {decorID=1281, source={type="vendor", itemID=243335, currency="160", currencytype="gold"}, requirements={quest={id=26397}}},
    }
  },

  {
    source={
      id=50488,
      type="vendor",
      faction="Horde",
      zone="Orgrimmar",
      worldmap="85:5020:5840"
    },
    items={
      {decorID=9242, source={type="vendor", itemID=253168, currency="80", currencytype="silver"}},
    }
  },

  {
    source={
      id=216888,
      type="vendor",
      faction="Alliance",
      zone="Ruins of Gilneas",
      worldmap="218:6199:3672"
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
      id=254606,
      type="vendor",
      faction="Horde",
      zone="Orgrimmar",
      worldmap="85:3880:7193"
    },
    items={
      {decorID=3867, source={type="vendor", itemID=247727, currency="5000", currencytype=1792}, requirements={achievement={id=5223}}},
      {decorID=3880, source={type="vendor", itemID=247740, currency="2000", currencytype=1792}, requirements={achievement={id=6981}}},
      {decorID=3881, source={type="vendor", itemID=247741, currency="1000", currencytype=1792}, requirements={achievement={id=6981}}},
      {decorID=3885, source={type="vendor", itemID=247745, currency="1000", currencytype=1792}, requirements={achievement={id=229}}},
      {decorID=3887, source={type="vendor", itemID=247747, currency="800", currencytype=1792}, requirements={achievement={id=167}}},
      {decorID=3890, source={type="vendor", itemID=247750, currency="2500", currencytype=1792}, requirements={achievement={id=40612}}},
      {decorID=3893, source={type="vendor", itemID=247756, currency="1000", currencytype=1792}, requirements={achievement={id=1157}}},
      {decorID=3896, source={type="vendor", itemID=247759, currency="600", currencytype=1792}, requirements={achievement={id=1153}}},
      {decorID=3897, source={type="vendor", itemID=247760, currency="1200", currencytype=1792}, requirements={achievement={id=222}}},
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
      id=261262,
      type="vendor",
      faction="Neutral",
      zone="Orgrimmar",
      worldmap="1535:2862:1429"
    },
    items={
      {decorID=11287, source={type="vendor", itemID=256764}},
      {decorID=14467, source={type="vendor", itemID=260785, currency="1425", currencytype="gold"}, requirements={achievement={id=62387}}},
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
