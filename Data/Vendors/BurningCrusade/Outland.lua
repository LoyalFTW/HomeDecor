local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BurningCrusade"] = NS.Data.Vendors["BurningCrusade"] or {}

NS.Data.Vendors["BurningCrusade"]["Outland"] = {
  {
    source={
      id=16528,
      type="vendor",
      faction="Horde",
      zone="Ghostlands",
      worldmap="95:4760:3240"},
    items={
      {decorID=10950,  source={type="vendor", itemID=256049, currency="1200", currencytype="Order Resources"}, requirements={rep="true"}}, 
	  {decorID=11500,  source={type="vendor", itemID=257419, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}}}
  },
    {
    source={
      id=256946,
      type="vendor",
      faction="Neutral",
      zone="Talador",
      worldmap="535:7040:5760"},
    items={
      {decorID=12202,  source={type="vendor", itemID=258742, currency="1500", currencytype="Order Resources"}, requirements={quest={id=33582}}}}
  }}
