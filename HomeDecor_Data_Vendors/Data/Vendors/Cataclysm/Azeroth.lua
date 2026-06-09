local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Cataclysm"] = NS.Data.Vendors["Cataclysm"] or {}

NS.Data.Vendors["Cataclysm"]["Azeroth"] = {

  {
    source={
      id=49386,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap=""
    },
    items={
      {decorID=1998, source={type="vendor", itemID=246108}},
      {decorID=2242, source={type="vendor", itemID=246425}},
    }
  },

  {
    source={
      id=249196,
      type="vendor",
      faction="Neutral",
      zone="Twilight Highlands",
      worldmap=""
    },
    items={
      {decorID=714, source={type="vendor", itemID=245284, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, requirements={rep="true"}},
      {decorID=1227, source={type="vendor", itemID=251997, costs={{currency="5000", currencytype=2815},{currency="75", currencytype=3319}}}, requirements={rep="true"}},
      {decorID=1236, source={type="vendor", itemID=245330, costs={{currency="3000", currencytype=2815},{currency="50", currencytype=3319}}}, requirements={rep="true"}},
    }
  },

}
