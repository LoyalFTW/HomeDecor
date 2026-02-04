local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Wrath"] = NS.Data.Vendors["Wrath"] or {}

NS.Data.Vendors["Wrath"]["Northrend"] = {

  {
    source={
      id=25206,
      type="vendor",
      faction="Horde",
      zone="Borean Tundra",
      worldmap="114:4304:1381"},
    items={
      {decorID=11906,  source={type="vendor", itemID=258220, currency="1000", currencytype="Order Resources"}, requirements={quest={id=11566}}}}
  },
  {
    source={
      id=28038,
      type="vendor",
      faction="Neutral",
      zone="Sholazar Basin",
      worldmap="119:2680:5920"},
    items={
      {decorID=4839,  source={type="vendor", itemID=248807, currency="1000", currencytype="Order Resources"}, requirements={achievement={id=938}}}}
  },
  {
    source={
      id=27391,
      type="vendor",
      faction="Alliance",
      zone="Grizzly Hills",
      worldmap="116:3240:5980"},
    items={
      {decorID=4448,  source={type="vendor", itemID=248622, currency="1000", currencytype="Order Resources"}, requirements={quest={id=12227}}}}
  }}
