local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BurningCrusade"] = NS.Data.Vendors["BurningCrusade"] or {}

NS.Data.Vendors["BurningCrusade"]["Outland"] = {
  {
    title="Provisioner Vredigar",
    source={
      id=16528,
      type="vendor",
      faction="Horde",
      zone="Ghostlands",
      worldmap="95:4760:3240",
    },
    items={
      {decorID=10950, title="Sin'dorei Sleeper", decorType="Beds", source={type="vendor", itemID=256049, currency="1200", currencytype="Order Resources"}, requirements={rep="true"}},
      -- { decorID=925, title="Elodor Barrel", decorType="Storage", source={type="quest", itemID=1230952}, requirements={quest={id=38201, title="Missive: Assault on Shattrath Harbor"}, rep="true"}},   -- No vendor
	  {decorID=11500, title="Sin'dorei Crafter's Forge", decorType="Uncategorized", source={type="vendor", itemID=257419, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
}
