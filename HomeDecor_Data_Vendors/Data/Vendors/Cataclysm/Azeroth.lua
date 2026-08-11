local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Cataclysm"] = NS.Data.Vendors["Cataclysm"] or {}

NS.Data.Vendors["Cataclysm"]["Azeroth"] = {

  {
    source={
      id=48258,
      type="vendor",
      faction="Alliance",
      zone="Felwood",
      worldmap="77:6160:2580"
    },
    items={
      {decorID=11301, source={type="vendor", itemID=256903, currency="750000", currencytype="money"}, requirements={quest={id=28337}}},
    }
  },

}
