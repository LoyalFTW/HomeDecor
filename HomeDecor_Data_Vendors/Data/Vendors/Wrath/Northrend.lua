local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Wrath"] = NS.Data.Vendors["Wrath"] or {}

NS.Data.Vendors["Wrath"]["Northrend"] = {

  {
    source={
      id=25206,
      type="vendor",
      faction="Neutral",
      zone="Borean Tundra",
      worldmap="114:4304:1381"
    },
    items={
      {decorID=11906, source={type="vendor", itemID=258220}, requirements={quest={id=11566}}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=27391,
      type="vendor",
      faction="Alliance",
      zone="Grizzly Hills",
      worldmap="116:3240:5980"
    },
    items={
      {decorID=4448, source={type="vendor", itemID=248622, currency="5000000", currencytype="money"}, requirements={quest={id=12227}}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=28038,
      type="vendor",
      faction="Neutral",
      zone="Nesingwary Base Camp",
      worldmap="119:2680:5920"
    },
    items={
      {decorID=4839, source={type="vendor", itemID=248807, currency="5000000", currencytype="money"}, requirements={achievement={id=938}}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
    }
  },

}
