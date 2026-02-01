local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Legion"] = NS.Data.Vendors["Legion"] or {}

NS.Data.Vendors["Legion"]["ClassHalls"] = {

  {
    title="Quartermaster Ozorg",
    source={
      id=93550,
      type="vendor",
      faction="Horde",
      zone="Acherus: Ebon Hold, Acherus: The Ebon Hold",
      worldmap="647:4390:3717",
    },
    items={
      {decorID=5575, decorType="Ornamental", source={type="vendor", itemID=249690, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60963}}},
      {decorID=5879, decorType="Tables and Desks", source={type="vendor", itemID=250112, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60981}}},
      {decorID=5880, decorType="Ornamental", source={type="vendor", itemID=250113, currency="500", currencytype="Order Resources"}},
      {decorID=5881, decorType="Tables and Desks", source={type="vendor", itemID=250114, currency="500", currencytype="Order Resources"}},
      {decorID=5882, decorType="Storage", source={type="vendor", itemID=250115, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42270}}},
      {decorID=5888, decorType="Large Structures", source={type="vendor", itemID=250123, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42287}}},
      {decorID=5889, decorType="Wall Hangings", source={type="vendor", itemID=250124, currency="1000", currencytype="Order Resources"}},
      {decorID=14361, decorType="Ornamental", source={type="vendor", itemID=260584, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60962}}},
    }
  },
}
