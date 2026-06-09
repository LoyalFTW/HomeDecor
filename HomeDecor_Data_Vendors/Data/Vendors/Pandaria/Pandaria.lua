local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Pandaria"] = NS.Data.Vendors["Pandaria"] or {}

NS.Data.Vendors["Pandaria"]["Pandaria"] = {

  {
    source={
      id=58414,
      type="vendor",
      faction="Neutral",
      zone="The Jade Forest - Arboretum",
      worldmap="371:5670:4440"
    },
    items={
      {decorID=3870, source={type="vendor", itemID=247730}, requirements={rep="true"}},
      {decorID=3872, source={type="vendor", itemID=247732}, requirements={rep="true"}},
    }
  },

  {
    source={
      id=58706,
      type="vendor",
      faction="Neutral",
      zone="Valley of the Four Winds - Halfhill",
      worldmap="376:5320:5160"
    },
    items={
      {decorID=1201, source={type="vendor", itemID=245508}, requirements={rep="true"}},
      {decorID=3840, source={type="vendor", itemID=247670}, requirements={rep="true"}},
      {decorID=3874, source={type="vendor", itemID=247734}, requirements={rep="true"}},
      {decorID=3877, source={type="vendor", itemID=247737}, requirements={rep="true"}},
      {decorID=4488, source={type="vendor", itemID=248663}, requirements={quest={id=30526}}},
    }
  },

  {
    source={
      id=59698,
      type="vendor",
      faction="Neutral",
      zone="Kun-Lai Summit - One Keg",
      worldmap="379:5720:6100"
    },
    items={
      {decorID=15595, source={type="vendor", itemID=264349}, requirements={quest={id=30612}}},
    }
  },

  {
    source={
      id=59908,
      type="vendor",
      faction="Neutral",
      zone="Either Shrine in Vale of Eternal Blossoms",
      worldmap="390:6320:2210"
    },
    items={
--       {decorID=3879, source={type="vendor", itemID=247739}, requirements={quest={id=30612}}}, -- DNT / do not use
    }
  },

  {
    source={
      id=62088,
      type="vendor",
      faction="Neutral",
      zone="The Jade Forest - Dawn's Blossom",
      worldmap="371:4700:4800"
    },
    items={
      {decorID=767, source={type="vendor", itemID=245332}, requirements={achievement={id=61467}}},
      {decorID=11453, source={type="vendor", itemID=257351}, requirements={achievement={id=42189}}},
      {decorID=11456, source={type="vendor", itemID=257354}, requirements={achievement={id=42187}}},
      {decorID=11457, source={type="vendor", itemID=257355}, requirements={achievement={id=42188}}},
      {decorID=21857, source={type="vendor", itemID=271971}, requirements={achievement={id=61442}}},
    }
  },

  {
    source={
      id=64001,
      type="vendor",
      faction="Neutral",
      zone="Shrine of Two Moons, Vale of Eternal Blossoms",
      worldmap="390:6280:2320"
    },
    items={
      {decorID=3869, source={type="vendor", itemID=247729}, requirements={quest={id=31230}}},
    }
  },

  {
    source={
      id=64001,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms",
      worldmap="390:6280:2320"
    },
    items={
      {decorID=15605, source={type="vendor", itemID=264362}, requirements={quest={id=30000}}},
    }
  },

  {
    source={
      id=64032,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms - Shrine of Seven Stars",
      worldmap="390:8520:6160"
    },
    items={
      {decorID=3869, source={type="vendor", itemID=247729}, requirements={quest={id=31230}}},
    }
  },

  {
    source={
      id=64605,
      type="vendor",
      faction="Neutral",
      zone="Vale of Eternal Blossoms",
      worldmap="390:8220:2940"
    },
    items={
      {decorID=1172, source={type="vendor", itemID=245512}, requirements={rep="true"}},
      {decorID=3832, source={type="vendor", itemID=247662}, requirements={rep="true"}},
      {decorID=3833, source={type="vendor", itemID=247663}, requirements={rep="true"}},
      {decorID=3993, source={type="vendor", itemID=247855}, requirements={rep="true"}},
      {decorID=3995, source={type="vendor", itemID=247858}, requirements={quest={id=32816}}},
      {decorID=11873, source={type="vendor", itemID=258147}, requirements={rep="true"}},
    }
  },

}
