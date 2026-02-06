local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Legion"] = NS.Data.Vendors["Legion"] or {}

NS.Data.Vendors["Legion"]["ClassHalls"] = {

  {
    source={
      id=93550,
      type="vendor",
      faction="Horde",
      zone="Acherus: The Ebon Hold",
      worldmap="647:4390:3717"
    },
    items={
      {decorID=5575, source={type="vendor", itemID=249690}, requirements={achievement={id=60963}}},
      {decorID=5879, source={type="vendor", itemID=250112, currency="2000", currencytype=1220}, requirements={achievement={id=60981}}},
      {decorID=5880, source={type="vendor", itemID=250113, currency="500", currencytype=1220}},
      {decorID=5881, source={type="vendor", itemID=250114, currency="500", currencytype=1220}},
      {decorID=5882, source={type="vendor", itemID=250115, currency="1500", currencytype=1220}, requirements={achievement={id=42270}}},
      {decorID=5888, source={type="vendor", itemID=250123, currency="5000", currencytype=1220}, requirements={achievement={id=42287}}},
      {decorID=5889, source={type="vendor", itemID=250124, currency="1000", currencytype=1220}},
      {decorID=14361, source={type="vendor", itemID=260584, currency="3000", currencytype=1220}, requirements={achievement={id=60962}}},
    }
  },

}
