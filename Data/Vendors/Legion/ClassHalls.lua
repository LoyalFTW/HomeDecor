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
      {decorID=5575, title="Replica Tome of Fel Secrets", decorType="Ornamental", source={type="vendor", itemID=249690, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60963, title="Legendary Research of the Illidari"}, rep="true"}},
      {decorID=5879, title="Ebon Blade Planning Map", decorType="Tables and Desks", source={type="vendor", itemID=250112, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60981, title="Raise an Army for Acherus"}, rep="true"}},
      {decorID=5880, title="Ebon Blade Tome", decorType="Ornamental", source={type="vendor", itemID=250113, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5881, title="Acherus Worktable", decorType="Tables and Desks", source={type="vendor", itemID=250114, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5882, title="Ebon Blade Weapon Rack", decorType="Storage", source={type="vendor", itemID=250115, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42270, title="The Deathlord's Campaign"}, rep="true"}},
      {decorID=5888, title="Replica Acherus Soul Forge", decorType="Large Structures", source={type="vendor", itemID=250123, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42287, title="Hidden Potential of the Deathlord"}, rep="true"}},
      {decorID=5889, title="Ebon Blade Banner", decorType="Wall Hangings", source={type="vendor", itemID=250124, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=14361, title="Replica Libram of the Dead", decorType="Ornamental", source={type="vendor", itemID=260584, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60962, title="Legendary Research of the Ebon Blade"}, rep="true"}},
    }
  },
}
