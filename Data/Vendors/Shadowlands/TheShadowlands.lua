local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Shadowlands"] = NS.Data.Vendors["Shadowlands"] or {}

NS.Data.Vendors["Shadowlands"]["TheShadowlands"] = {

  {
    title="Sage Whiteheart",
    source={
      id=64032,
      type="vendor",
      faction="Alliance",
      zone="Shrine of Seven Stars, Vale of Eternal Blossoms, Vale of Eternal Blossoms",
      worldmap="1530:8520:6160",
    },
    items={
      {decorID=3869, decorType="Misc Structural", source={type="vendor", itemID=247729}, requirements={quest={id=31230}}},
      {decorID=15605, decorType="Misc Furnishings", source={type="vendor", itemID=264362}, requirements={quest={id=92980}}},
    }
  },
  {
    title="The Last Architect",
    source={
      id=253596,
      type="vendor",
      faction="Horde",
      zone="",
      worldmap="0:0000:0000",
    },
    items={
      --       {decorID=14583, decorType="Ornamental", source={type="vendor", itemID=262453}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Ve'nari",
    source={
      id=162804,
      type="vendor",
      faction="Alliance",
      zone="The Maw",
      worldmap="1543:4680:4160",
    },
    items={
      {decorID=4181, decorType="Large Structures", source={type="vendor", itemID=248125, currency="10000", currencytype="Stygia"}, requirements={achievement={id=20501}}},
    }
  },
  {
    title="Chachi the Artiste",
    source={
      id=174710,
      type="vendor",
      faction="Neutral",
      zone="Sinfall",
      worldmap="1699:5400:2480",
    },
    items={
      {decorID=756, decorType="Ornamental", source={type="vendor", itemID=245501, currency="1500", currencytype="Reservoir Anima"}},
    }
  },
}
