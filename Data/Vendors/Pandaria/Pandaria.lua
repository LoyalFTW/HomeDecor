local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Pandaria"] = NS.Data.Vendors["Pandaria"] or {}

NS.Data.Vendors["Pandaria"]["Pandaria"] = {

  {
    title="Sergeant Crowler",
    source={
      id=78564,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall",
      worldmap="582:3850:3140",
    },
    items={
      {decorID=4403, title="Stormwind Wooden Bench", decorType="Seating", source={type="vendor", itemID=248334, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=36404, title="Clearing the Garden"}, rep="true"}},
      {decorID=4404, title="Stormwind Wooden Stool", decorType="Seating", source={type="vendor", itemID=248335, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=36202, title="Anglin' In Our Garrison"}, rep="true"}},
      {decorID=4485, title="Stormwind Workbench", decorType="Tables and Desks", source={type="vendor", itemID=248660, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=34192, title="Things Are Not Goren Our Way"}, rep="true"}},
      {decorID=4486, title="Northshire Scribe's Desk", decorType="Tables and Desks", source={type="vendor", itemID=248661, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=36592, title="Bigger is Better"}, rep="true"}},
      {decorID=4816, title="Wooden Storage Crate", decorType="Storage", source={type="vendor", itemID=248799, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=34586, title="Establish Your Garrison"}, rep="true"}},
      {decorID=4818, title="Architect's Drafting Table", decorType="Miscellaneous - All", source={type="vendor", itemID=248800, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=36615, title="My Very Own Castle"}, rep="true"}},
      {decorID=4844, title="Rough Wooden Chair", decorType="Seating", source={type="vendor", itemID=248810, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=35176, title="Keeping it Together"}, rep="true"}},
    }
  },
  {
    title="Tan Shin Tiao",
    source={
      id=64605,
      type="vendor",
      faction="Horde",
      zone="Vale of Eternal Blossoms",
      worldmap="390:8223:2933",
    },
    items={
      {decorID=1172, title="Pandaren Cradle Stool", decorType="Seating", source={type="vendor", itemID=245512, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=3832, title="Pandaren Scholar's Lectern", decorType="Tables and Desks", source={type="vendor", itemID=247662, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=3833, title="Pandaren Scholar's Bookcase", decorType="Storage", source={type="vendor", itemID=247663, currency="500", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=3993, title="Pandaren Lacquered Crate", decorType="Storage", source={type="vendor", itemID=247855, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=3995, title="Shaohao Ceremonial Bell", decorType="Large Structures", source={type="vendor", itemID=247858, currency="1500", currencytype="Order Resources"}, requirements={quest={id=32816, title="Path of the Last Emperor"}, rep="true"}},
      {decorID=11873, title="Empty Lorewalker's Bookcase", decorType="Storage", source={type="vendor", itemID=258147, currency="500", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Ribchewer",
    source={
      id=86776,
      type="vendor",
      faction="Horde",
      zone="Frostwall",
      worldmap="585:5140:6200",
    },
    items={
      {decorID=1354, title="Orcish Communal Stove", decorType="Food and Drink", source={type="vendor", itemID=245444, currency="250", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1355, title="Frostwolf Axe-Dart Board", decorType="Wall Hangings", source={type="vendor", itemID=245445, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1413, title="Orcish Lumberjack's Stool", decorType="Seating", source={type="vendor", itemID=244321, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1414, title="Frostwolf Banded Stool", decorType="Seating", source={type="vendor", itemID=244322, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Sergeant Grimjaw",
    source={
      id=79774,
      type="vendor",
      faction="Horde",
      zone="Frostwall",
      worldmap="590:4380:4740",
    },
    items={
      {decorID=1318, title="Frostwolf Bookcase", decorType="Storage", source={type="vendor", itemID=245438, currency="500", currencytype="Garrison Resources"}, requirements={quest={id=93100, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1353, title="Frostwolf Round Table", decorType="Tables and Desks", source={type="vendor", itemID=245443, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=34586, title="Establish Your Garrison"}, rep="true"}},
      {decorID=1407, title="Orcish Warlord's Planning Table", decorType="Tables and Desks", source={type="vendor", itemID=244315, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=36614, title="My Very Own Fortress"}, rep="true"}},
      {decorID=1408, title="Warsong Workbench", decorType="Tables and Desks", source={type="vendor", itemID=244316, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=34192, title="Things Are Not Goren Our Way"}, rep="true"}},
      {decorID=1412, title="Youngling's Courser Toys", decorType="Misc Accents", source={type="vendor", itemID=244320, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=42622, title="Ceremonial Drums"}, rep="true"}},
      {decorID=1443, title="Orcish Scribe's Drafting Table", decorType="Tables and Desks", source={type="vendor", itemID=244653, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=36592, title="Bigger is Better"}, rep="true"}},
    }
  },
  {
    title="Sage Lotusbloom",
    source={
      id=64001,
      type="vendor",
      faction="Horde",
      zone="Shrine of Two Moons, Vale of Eternal Blossoms, Vale of Eternal Blossoms",
      worldmap="390:6280:2320",
    },
    items={
      {decorID=3869, title="Pandaren Stone Lamppost", decorType="Misc Structural", source={type="vendor", itemID=247729}, requirements={quest={id=31230, title="Welcome to Dawn's Blossom"}, rep="true"}},
      {decorID=15605, title="Golden Pandaren Privacy Screen", decorType="Misc Furnishings", source={type="vendor", itemID=264362}, requirements={quest={id=30000, title="The Jade Serpent"}, rep="true"}},
    }
  },
    {
    title="Sage Whiteheart",
    source={
      id=64032,
      type="vendor",
      faction="Alliance",
      zone="Shrine of Seven Stars, Vale of Eternal Blossoms, Vale of Eternal Blossoms",
      worldmap="1530:8520:6160",
    },
    items={
      {decorID=3869, title="Pandaren Stone Lamppost", decorType="Misc Structural", source={type="vendor", itemID=247729}, requirements={quest={id=31230, title="Welcome to Dawn's Blossom"}, rep="true"}},
      {decorID=15605, title="Golden Pandaren Privacy Screen", decorType="Misc Furnishings", source={type="vendor", itemID=264362}, requirements={quest={id=92980, title="Decor Treasure Hunt"}, rep="true"}},
    }
  },
  {
    title="Brother Furtrim",
    source={
      id=59698,
      type="vendor",
      faction="Horde",
      zone="Kun-Lai Summit",
      worldmap="379:5724:6096",
    },
    items={
      {decorID=15595, title="Kun-Lai Lacquered Rickshaw", decorType="Miscellaneous - All", source={type="vendor", itemID=264349, currency="500", currencytype="War Resources"}, requirements={quest={id=30612, title="The Leader Hozen"}, rep="true"}},
    }
  },
  {
    title="San Redscale",
    source={
      id=58414,
      type="vendor",
      faction="Neutral",
      zone="The Jade Forest",
      worldmap="371:5670:4438",
    },
    items={
      {decorID=3870, title="Red Crane Kite", decorType="Ornamental", source={type="vendor", itemID=247730, currency="600", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=3872, title="Lucky Hanging Lantern", decorType="Ornamental", source={type="vendor", itemID=247732, currency="600", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Gina Mudclaw",
    source={
      id=58706,
      type="vendor",
      faction="Horde",
      zone="Valley of the Four Winds",
      worldmap="376:5320:5180",
    },
    items={
      {decorID=1201, title="Pandaren Cooking Table", decorType="Tables and Desks", source={type="vendor", itemID=245508, currency="300", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=3840, title="Pandaren Pantry", decorType="Storage", source={type="vendor", itemID=247670, currency="500", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=3874, title="Paw'don Well", decorType="Misc Structural", source={type="vendor", itemID=247734}, requirements={rep="true"}},
      {decorID=3877, title="Stormstout Brew Keg", decorType="Misc Accents", source={type="vendor", itemID=247737, currency="300", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4488, title="Wooden Doghouse", decorType="Miscellaneous - All", source={type="vendor", itemID=248663}, requirements={quest={id=30526, title="Lost and Lonely"}, rep="true"}},
    }
  },
  {
    title="Lali the Assistant",
    source={
      id=62088,
      type="vendor",
      faction="Horde",
      zone="Vale of Eternal Blossoms",
      worldmap="390:8280:3080",
    },
    items={
      {decorID=767, title="Tome of Silvermoon Intrigue", decorType="Ornamental", source={type="vendor", itemID=245332, currency="750", currencytype="Resonance Crystals"}, requirements={achievement={id=61467, title="Lorewalking: The Elves of Quel'Thalas"}, rep="true"}},
      {decorID=11453, title="Tale of the Penultimate Lich King", decorType="Ornamental", source={type="vendor", itemID=257351, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=42189, title="Lorewalking: The Lich King"}, rep="true"}},
      {decorID=11456, title="Scroll of K'aresh's Fall", decorType="Uncategorized", source={type="vendor", itemID=257354, currency="1000", currencytype="Resonance Crystals"}, requirements={achievement={id=42187, title="Lorewalking: Ethereal Wisdom"}, rep="true"}},
      {decorID=11457, title="Tome of the Survivor", decorType="Ornamental", source={type="vendor", itemID=257355, currency="1500", currencytype="Reservoir Anima"}, requirements={achievement={id=42188, title="Lorewalking: Blade's Bane"}, rep="true"}},
    }
  },
}
