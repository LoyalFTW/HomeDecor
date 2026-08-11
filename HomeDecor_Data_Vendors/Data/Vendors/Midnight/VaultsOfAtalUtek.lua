local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Midnight"] = NS.Data.Vendors["Midnight"] or {}

NS.Data.Vendors["Midnight"]["Vaults of Atal'Utek"] = {

  {
    source={
      id=272751,
      type="vendor",
      faction="Neutral",
      zone="Vaults of Atal'Utek",
      worldmap="2509:5100:6240"
    },
    items={
      {decorID=25137, source={type="vendor", itemID=281573}, budgetCost=1, size="Large"},
      {decorID=25138, source={type="vendor", itemID=281577}, budgetCost=1, size="Small"},
      {decorID=26204, source={type="vendor", itemID=281620}, budgetCost=3, size="Medium"},
    }
  },

}
