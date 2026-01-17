local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Wrath"] = NS.Data.Vendors["Wrath"] or {}

NS.Data.Vendors["Wrath"]["Northrend"] = {

  {
    title="Ahlurglgr",
    source={
      id=25206,
      type="vendor",
      faction="Horde",
      zone="Borean Tundra",
      worldmap="114:4304:1381",
    },
    items={
      --       {decorID=11906, title="Murloc Driftwood Hut", decorType="Large Structures", source={type="vendor", itemID=258220, currency="1000", currencytype="Order Resources"}, requirements={quest={id=11566, title="Surrender... Not!"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Purser Boulian",
    source={
      id=28038,
      type="vendor",
      faction="Neutral",
      zone="Sholazar Basin",
      worldmap="119:2680:5920",
    },
    items={
      {decorID=4839, title="Nesingwary Mounted Shoveltusk Head", decorType="Wall Hangings", source={type="vendor", itemID=248807, currency="1000", currencytype="Order Resources"}, requirements={achievement={id=938, title="The Snows of Northrend"}, rep="true"}},
    }
  },
  {
    title="Woodsman Drake",
    source={
      id=27391,
      type="vendor",
      faction="Alliance",
      zone="Grizzly Hills",
      worldmap="116:3240:5980",
    },
    items={
      {decorID=4448, title="Wooden Outhouse", decorType="Large Structures", source={type="vendor", itemID=248622, currency="1000", currencytype="Order Resources"}, requirements={quest={id=12227, title="Doing Your Duty"}, rep="true"}},
    }
  },
}
