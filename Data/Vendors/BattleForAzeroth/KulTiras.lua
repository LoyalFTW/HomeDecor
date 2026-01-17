local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["BattleForAzeroth"] = NS.Data.Vendors["BattleForAzeroth"] or {}

NS.Data.Vendors["BattleForAzeroth"]["KulTiras"] = {

  {
    title="Pearl Barlow",
    source={
      id=252345,
      type="vendor",
      faction="Alliance",
      zone="Tiragarde Sound",
      worldmap="1161:7073:1566",
    },
    items={
      {decorID=1704, title="Old Salt's Fireplace", decorType="Large Lights", source={type="vendor", itemID=245271, currency="800", currencytype="War Resources"}, requirements={achievement={id=12582, title="Come Sail Away"}, rep="true"}},
      {decorID=9035, title="Admiralty's Upholstered Chair", decorType="Seating", source={type="vendor", itemID=252386, currency="400", currencytype="War Resources"}, requirements={quest={id=50972, title="Proudmoore's Parley"}, rep="true"}},
      {decorID=9049, title="Tiragarde Emblem", decorType="Wall Hangings", source={type="vendor", itemID=252400, currency="500", currencytype="War Resources"}, requirements={quest={id=53887, title="War Marches On"}, rep="true"}},
      {decorID=9052, title="Admiral's Bed", decorType="Beds", source={type="vendor", itemID=252403, currency="550", currencytype="War Resources"}, requirements={quest={id=53720, title="Allegiance of Kul Tiras"}, rep="true"}},
      {decorID=9055, title="Green Boralus Market Tent", decorType="Large Structures", source={type="vendor", itemID=252406, currency="375", currencytype="War Resources"}, requirements={quest={id=47489, title="Stow and Go"}, rep="true"}},
      {decorID=9140, title="Tiragarde Treasure Chest", decorType="Storage", source={type="vendor", itemID=252653, currency="650", currencytype="War Resources"}, requirements={achievement={id=13049, title="The Long Con"}, rep="true"}},
      {decorID=9141, title="Proudmoore Green Drape", decorType="Wall Hangings", source={type="vendor", itemID=252654, currency="300", currencytype="War Resources"}, requirements={achievement={id=12997, title="The Pride of Kul Tiras"}, rep="true"}},
      {decorID=9166, title="Seaworthy Boralus Bell", decorType="Misc Structural", source={type="vendor", itemID=252754, currency="800", currencytype="War Resources"}, requirements={quest={id=55045, title="My Brother's Keeper"}, rep="true"}},
    }
  },
  {
    title="Delphine",
    source={
      id=252316,
      type="vendor",
      faction="Alliance",
      zone="Tiragarde Sound",
      worldmap="895:5340:3120",
    },
    items={
      {decorID=9041, title="Admiral's Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=252392, currency="250", currencytype="War Resources"}, requirements={quest={id=48089, title="Mountain Sounds"}, rep="true"}},
      {decorID=9054, title="Admiral's Low-Hanging Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=252405, currency="250", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Caspian",
    source={
      id=252313,
      type="vendor",
      faction="Alliance",
      zone="Stormsong Valley",
      worldmap="942:5960:6959",
    },
    items={
      {decorID=1900, title="Sagehold Window", decorType="Windows", source={type="vendor", itemID=245984, currency="350", currencytype="War Resources"}, requirements={quest={id=50783, title="The Abyssal Council"}, rep="true"}},
      {decorID=9043, title="Bowhull Bookcase", decorType="Storage", source={type="vendor", itemID=252394, currency="550", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9044, title="Brennadam Coop", decorType="Large Structures", source={type="vendor", itemID=252395, currency="450", currencytype="War Resources"}, requirements={quest={id=51401, title="Carry On"}, rep="true"}},
      {decorID=9045, title="Admiralty's Copper Lantern", decorType="Small Lights", source={type="vendor", itemID=252396, currency="125", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9047, title="Stormsong Water Pump", decorType="Misc Structural", source={type="vendor", itemID=252398, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9139, title="Copper Stormsong Well", decorType="Large Structures", source={type="vendor", itemID=252652, currency="800", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9142, title="Copper Tidesage's Sconce", decorType="Wall Lights", source={type="vendor", itemID=252655, currency="175", currencytype="War Resources"}, requirements={quest={id=50611, title="Storm's Vengeance"}, rep="true"}},
    }
  },
  {
    title="Stolen Royal Vendorbot",
    source={
      id=150716,
      type="vendor",
      faction="Neutral",
      zone="Mechagon",
      worldmap="1462:7370:3690",
    },
    items={
      {decorID=2322, title="Gnomish T.O.O.L.B.O.X.", decorType="Ornamental", source={type="vendor", itemID=246479, currency="5", currencytype="Community Coupons"}, requirements={achievement={id=13723, title="M.C., Hammered"}, rep="true"}},
      {decorID=2323, title="Automated Gnomeregan Guardian", decorType="Large Structures", source={type="vendor", itemID=246480, currency="1000", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2326, title="Redundant Reclamation Rig", decorType="Misc Structural", source={type="vendor", itemID=246483}, requirements={achievement={id=13473, title="Diversified Investments"}, rep="true"}},
      {decorID=2327, title="Mechagon Hanging Floodlight", decorType="Ceiling Lights", source={type="vendor", itemID=246484}, requirements={rep="true"}},
      {decorID=2337, title="Small Emergency Warning Lamp", decorType="Large Lights", source={type="vendor", itemID=246497, currency="1000", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2338, title="Emergency Warning Lamp", decorType="Large Lights", source={type="vendor", itemID=246498, currency="300", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2339, title="Mechagon Eyelight Lamp", decorType="Large Lights", source={type="vendor", itemID=246499, currency="300", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2341, title="Gnomish Safety Flamethrower", decorType="Misc Accents", source={type="vendor", itemID=246501, currency="300", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2343, title="Large H.O.M.E. Cog", decorType="Misc Accents", source={type="vendor", itemID=246503, currency="300", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2430, title="Screw-Sealed Stembarrel", decorType="Storage", source={type="vendor", itemID=246598, currency="250", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=13477, title="Junkyard Apprentice"}, rep="true"}},
      {decorID=2433, title="Bolt Chair", decorType="Seating", source={type="vendor", itemID=246601, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=2435, title="Gnomish Cog Stack", decorType="Misc Furnishings", source={type="vendor", itemID=246603, currency="5", currencytype="Community Coupons"}, requirements={achievement={id=13475, title="Junkyard Scavenger"}, rep="true"}},
      {decorID=2437, title="Mecha-Storage Mecha-Chest", decorType="Storage", source={type="vendor", itemID=246605, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
      {decorID=2466, title="Gnomish Sprocket Table", decorType="Tables and Desks", source={type="vendor", itemID=246701, currency="450", currencytype="War Resources"}, requirements={quest={id=55736, title="Welcome to the Resistance"}, rep="true"}},
      {decorID=2467, title="Double-Sprocket Table", decorType="Tables and Desks", source={type="vendor", itemID=246703, currency="750", currencytype="War Resources"}, requirements={quest={id=55736, title="Welcome to the Resistance"}, rep="true"}},
    }
  },
  {
    title="Provisioner Fray",
    source={
      id=135808,
      type="vendor",
      faction="Alliance",
      zone="Boralus",
      worldmap="1161:6759:2180",
    },
    items={
      {decorID=2091, title="Boralus String Lights", decorType="Ceiling Lights", source={type="vendor", itemID=246222, currency="75", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=8984, title="Tidesage's Bookcase", decorType="Storage", source={type="vendor", itemID=252036, currency="500", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9036, title="Boralus Fence", decorType="Misc Structural", source={type="vendor", itemID=252387, currency="100", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9037, title="Boralus Fencepost", decorType="Misc Structural", source={type="vendor", itemID=252388, currency="50", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9051, title="Tidesage's Double Bookshelves", decorType="Storage", source={type="vendor", itemID=252402, currency="450", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Toraan the Revered",
    source={
      id=127151,
      type="vendor",
      faction="Horde",
      zone="The Vindicaar",
      worldmap="940:6822:5691",
    },
    items={
      {decorID=930, title="Draenic Bookcase", decorType="Storage", source={type="vendor", itemID=245422, currency="500", currencytype="Garrison Resources"}, requirements={quest={id=47691, title="A Non-Prophet Organization"}, rep="true"}},
      {decorID=8189, title="Draenic Wooden Wall Shelf", decorType="Storage", source={type="vendor", itemID=251480, currency="75", currencytype="Order Resources"}, requirements={quest={id=44004, title="Bringer of the Light"}, rep="true"}},
    }
  },
  {
    title="Fiona",
    source={
      id=142115,
      type="vendor",
      faction="Alliance",
      zone="Boralus Harbor",
      worldmap="1161:6759:4079",
    },
    items={
      {decorID=4813, title="Goldshire Food Cart", decorType="Miscellaneous - All", source={type="vendor", itemID=248796, currency="1500", currencytype="Garrison Resources"}, requirements={achievement={id=5442, title="Full Caravan"}, rep="true"}},
    }
  },
  {
    title="Janey Forrest",
    source={
      id=246721,
      type="vendor",
      faction="Alliance",
      zone="Tiragarde Sound",
      worldmap="1161:5629:4582",
    },
    items={
      {decorID=9039, title="Small Hull'n'Home Table", decorType="Tables and Desks", source={type="vendor", itemID=252390, currency="450", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9040, title="Large Hull'n'Home Table", decorType="Tables and Desks", source={type="vendor", itemID=252391, currency="750", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9042, title="Hull'n'Home Dresser", decorType="Storage", source={type="vendor", itemID=252393, currency="500", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9053, title="Hull'n'Home Chair", decorType="Seating", source={type="vendor", itemID=252404, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=12210, title="Hull'n'Home Window", decorType="Windows", source={type="vendor", itemID=258765, currency="175", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="MOTHER",
    source={
      id=152194,
      type="vendor",
      faction="Neutral",
      zone="Chamber of Heart",
      worldmap="1473:5015:6693",
    },
    items={
      {decorID=3837, title="MOTHER's Titanic Brazier", decorType="Large Lights", source={type="vendor", itemID=247667, currency="10000", currencytype="Echoes of Ny'alotha"}, requirements={achievement={id=40953, title="A Farewell to Arms"}, rep="true"}},
      {decorID=3838, title="N'Zoth's Captured Eye", decorType="Ornamental", source={type="vendor", itemID=247668, currency="10000", currencytype="Echoes of Ny'alotha"}, requirements={achievement={id=40953, title="A Farewell to Arms"}, rep="true"}},
    }
  },
  {
    title="Plugger Spazzring",
    source={
      id=144129,
      type="vendor",
      faction="Neutral",
      zone="Blackrock Depths",
      worldmap="1186:4977:3222",
    },
    items={
      {decorID=1120, title="Replica Dark Iron Mole Machine", decorType="Large Structures", source={type="vendor", itemID=245291, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
}
