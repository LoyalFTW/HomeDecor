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
      zone="Shattrath",
      worldmap="111:4800:4620"
    },
    items={
      {decorID=10950, source={type="vendor", itemID=256049, currency="50000000", currencytype="money"}, colors={"Dark Brown","Deep Red","Silver"}, requirements={rep="true"}, budgetCost=5, size="Large"},
      {decorID=11500, source={type="vendor", itemID=257419, currency="50000000", currencytype="money"}, colors={"Amber","Dark Brown","Gray"}, requirements={rep="true"}, budgetCost=5, size="Large"},
    }
  },

}
