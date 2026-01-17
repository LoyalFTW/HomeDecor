local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Dragonflight"] = NS.Data.Vendors["Dragonflight"] or {}

NS.Data.Vendors["Dragonflight"]["DragonIsles"] = {

  {
    title="Mythrin'dir",
    source={
      id=216284,
      type="vendor",
      faction="Alliance",
      zone="Amirdrassil",
      worldmap="2239:5400:6080",
    },
    items={
      {decorID=1989, title="Bel'ameth Crafter's Tent", decorType="Large Structures", source={type="vendor", itemID=246091, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4561, title="Amirdrassil Stool", decorType="Seating", source={type="vendor", itemID=248759, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
  {
    title="Nalina Ironsong",
    source={
      id=217642,
      type="vendor",
      faction="Neutral",
      zone="Hallowfall",
      worldmap="2215:4280:5583",
    },
    items={
      {decorID=14360, title="Arathi Bartender's Shelves", decorType="Misc Furnishings", source={type="vendor", itemID=260583, currency="500", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Tethalash",
    source={
      id=196637,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:2552:3365",
    },
    items={
      {decorID=5556, title="Preserver's Censer", decorType="Ornamental", source={type="vendor", itemID=249545, currency="4000", currencytype="Mysterious Fragment"}, requirements={rep="true"}},
      {decorID=5558, title="Evoker's Elegant Rug", decorType="Floor", source={type="vendor", itemID=249547, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5559, title="Augmenter's Opal Banner", decorType="Ornamental", source={type="vendor", itemID=249548, currency="4000", currencytype="Mysterious Fragment"}, requirements={rep="true"}},
      {decorID=5560, title="Draconic Crafter's Table", decorType="Tables and Desks", source={type="vendor", itemID=249549, currency="200", currencytype="Dragon Isles Supplies"}, requirements={quest={id=26754, title="Morbent's Bane"}, rep="true"}},
      {decorID=5689, title="Devastator's Brazier", decorType="Large Lights", source={type="vendor", itemID=249824, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Ellandrieth",
    source={
      id=216285,
      type="vendor",
      faction="Neutral",
      zone="Amirdrassil",
      worldmap="2239:4840:5360",
    },
    items={
      {decorID=1834, title="Bel'ameth Bench", decorType="Seating", source={type="vendor", itemID=245625, currency="350", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1861, title="Filigree Moon Lamp", decorType="Small Lights", source={type="vendor", itemID=245655, currency="10", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1888, title="Bel'ameth Barrel", decorType="Storage", source={type="vendor", itemID=245704, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1987, title="Bel'ameth Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=246089, currency="350", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1990, title="Small Bel'ameth Tent", decorType="Large Structures", source={type="vendor", itemID=246100, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4423, title="Ornamental Kaldorei Glaive", decorType="Misc Accents", source={type="vendor", itemID=248401, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=76213, title="Honor of the Goddess"}, rep="true"}},
      {decorID=7896, title="Bel'ameth Traveler's Pack", decorType="Misc Accents", source={type="vendor", itemID=251022, currency="300", currencytype="Dragon Isles Supplies"}, requirements={quest={id=78864, title="The Returning"}, rep="true"}},
    }
  },
  {
    title="Cataloger Jakes",
    source={
      id=189226,
      type="vendor",
      faction="Neutral",
      zone="Dragonscale Basecamp",
      worldmap="2022:4700:8260",
    },
    items={
      {decorID=716, title="Reliquary Storage Crate", decorType="Storage", source={type="vendor", itemID=245285, currency="100", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=717, title="Long Sin'dorei Rug", decorType="Floor", source={type="vendor", itemID=245287, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=718, title="Circular Sin'dorei Rug", decorType="Floor", source={type="vendor", itemID=245288, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=720, title="Reliquary Telescope", decorType="Ornamental", source={type="vendor", itemID=238975, currency="750", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1177, title="Blood Elven Candelabra", decorType="Large Lights", source={type="vendor", itemID=245283, currency="400", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1181, title="Rectangular Sin'dorei Rug", decorType="Floor", source={type="vendor", itemID=245286, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
  {
    title="Rae'ana",
    source={
      id=188265,
      type="vendor",
      faction="Neutral",
      zone="Dragonscale Basecamp",
      worldmap="2022:4780:8220",
    },
    items={
      {decorID=716, title="Reliquary Storage Crate", decorType="Storage", source={type="vendor", itemID=245285, currency="100", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=717, title="Long Sin'dorei Rug", decorType="Floor", source={type="vendor", itemID=245287, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=718, title="Circular Sin'dorei Rug", decorType="Floor", source={type="vendor", itemID=245288, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=720, title="Reliquary Telescope", decorType="Ornamental", source={type="vendor", itemID=238975, currency="750", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1177, title="Blood Elven Candelabra", decorType="Large Lights", source={type="vendor", itemID=245283, currency="400", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1181, title="Rectangular Sin'dorei Rug", decorType="Floor", source={type="vendor", itemID=245286, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
  {
    title="Lars Bronsmaelt",
    source={
      id=240852,
      type="vendor",
      faction="Neutral",
      zone="Hallowfall",
      worldmap="2215:2828:5618",
    },
    items={
      {decorID=763, title="Collection of Arathi Scripture", decorType="Ornamental", source={type="vendor", itemID=245293, currency="1200", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Cendvin",
    source={
      id=226205,
      type="vendor",
      faction="Neutral",
      zone="Isle of Dorn",
      worldmap="2248:7440:4520",
    },
    items={
      {decorID=2470, title="Decorative Cinder Honeypot", decorType="Food and Drink", source={type="vendor", itemID=246707, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Unatos",
    source={
      id=193015,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:5820:3560",
    },
    items={
      {decorID=4159, title="Draconic Stone Table", decorType="Tables and Desks", source={type="vendor", itemID=248103, currency="300", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4168, title="Valdrakken Garden Fountain", decorType="Large Structures", source={type="vendor", itemID=248112, currency="400", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4478, title="Dragon's Grand Mirror", decorType="Misc Furnishings", source={type="vendor", itemID=248652, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=10962, title="Draconic Sconce", decorType="Wall Hangings", source={type="vendor", itemID=256168, currency="10", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=10963, title="Valdrakken Oven", decorType="Uncategorized", source={type="vendor", itemID=256169, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
  {
    title="Provisioner Thom",
    source={
      id=193659,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:3679:5060",
    },
    items={
      {decorID=7835, title="Draconic Crafter's Forge", decorType="Miscellaneous - All", source={type="vendor", itemID=250912, currency="600", currencytype="Dragon Isles Supplies"}, requirements={quest={id=72935, title="Archives Return"}, rep="true"}},
    }
  },
  {
    title="Silvrath",
    source={
      id=253067,
      type="vendor",
      faction="Horde",
      zone="Valdrakken",
      worldmap="2112:7153:4962",
    },
    items={
      {decorID=2469, title="Elegant Dracthyr's Tea Cup", decorType="Food and Drink", source={type="vendor", itemID=246706, currency="100", currencytype="Dragon Isles Supplies"}, requirements={quest={id=67047, title="Warm Away These Shivers"}, rep="true"}},
      {decorID=2594, title="Roast Riverbeast Platter", decorType="Food and Drink", source={type="vendor", itemID=247223, currency="175", currencytype="Dragon Isles Supplies"}, requirements={quest={id=67063, title="10,000 Years of Roasting"}, rep="true"}},
      {decorID=4159, title="Draconic Stone Table", decorType="Tables and Desks", source={type="vendor", itemID=248103, currency="300", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4160, title="Pentagonal Stone Table", decorType="Tables and Desks", source={type="vendor", itemID=248104, currency="150", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=17773, title="A Blue Dawn"}, rep="true"}},
      {decorID=4168, title="Valdrakken Garden Fountain", decorType="Large Structures", source={type="vendor", itemID=248112, currency="400", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4477, title="Draconic Memorial Stone", decorType="Miscellaneous - All", source={type="vendor", itemID=248651, currency="600", currencytype="Dragon Isles Supplies"}, requirements={quest={id=72935, title="Archives Return"}, rep="true"}},
      {decorID=4478, title="Dragon's Grand Mirror", decorType="Misc Furnishings", source={type="vendor", itemID=248652, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4479, title="Valdrakken Stone Stool", decorType="Seating", source={type="vendor", itemID=248653, currency="50", currencytype="Dragon Isles Supplies"}, requirements={quest={id=71097, title="A Helping Claw"}, rep="true"}},
      {decorID=4481, title="Elegant Dracthyr's Tea Set", decorType="Food and Drink", source={type="vendor", itemID=248655, currency="200", currencytype="Dragon Isles Supplies"}, requirements={quest={id=70880, title="To Cook With Finery"}, rep="true"}},
      {decorID=10963, title="Valdrakken Oven", decorType="Uncategorized", source={type="vendor", itemID=256169, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=11164, title="Valdrakken Lamppost", decorType="Large Lights", source={type="vendor", itemID=256429, currency="200", currencytype="Dragon Isles Supplies"}, requirements={quest={id=70745, title="Enforced Relaxation"}, rep="true"}},
    }
  },
  {
    title="Jolinth",
    source={
      id=253086,
      type="vendor",
      faction="Neutral",
      zone="The Forbidden Reach",
      worldmap="2151:3520:5700",
    },
    items={
      {decorID=4482, title="Dragon's Hoard Chest", decorType="Storage", source={type="vendor", itemID=248656, currency="1500", currencytype="Elemental Overflow"}, requirements={achievement={id=17529, title="Forbidden Spoils"}, rep="true"}},
    }
  },
  {
    title="Cinnabar",
    source={
      id=252901,
      type="vendor",
      faction="Neutral",
      zone="Freywold Village, Isle of Dorn",
      worldmap="2248:4200:7300",
    },
    items={
      {decorID=9179, title="Freywold Bench", decorType="Seating", source={type="vendor", itemID=253021, currency="400", currencytype="Resonance Crystals"}, requirements={quest={id=78999, title="Heart of a Hero"}, rep="true"}},
      {decorID=9183, title="Freywold Seat", decorType="Seating", source={type="vendor", itemID=253035, currency="300", currencytype="Resonance Crystals"}, requirements={quest={id=79703, title="Hope, An Anomaly"}, rep="true"}},
      {decorID=9240, title="Freywold Fountain", decorType="Large Structures", source={type="vendor", itemID=253166, currency="1100", currencytype="Resonance Crystals"}, requirements={quest={id=78759, title="To Wake a Giant"}, rep="true"}},
    }
  },
  {
    title="Moon Priestess Lasara",
    source={
      id=216286,
      type="vendor",
      faction="Alliance",
      zone="Amirdrassil",
      worldmap="2239:4660:7059",
    },
    items={
      {decorID=11454, title="Large Brazier of Elune", decorType="Small Lights", source={type="vendor", itemID=257352, currency="300", currencytype="Dragon Isles Supplies"}, requirements={quest={id=77283, title="A Multi-Front Battle"}, rep="true"}},
    }
  },
  {
    title="Celestine of the Harvest",
    source={
      id=210608,
      type="vendor",
      faction="Neutral",
      zone="Amirdrassil",
      worldmap="2022:5840:6780",
    },
    items={
      {decorID=10888, title="Moonclasp Satchel", decorType="Misc Accents", source={type="vendor", itemID=207026, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
  {
    title="Caretaker Azkra",
    source={
      id=190155,
      type="vendor",
      faction="Horde",
      zone="The Waking Shores",
      worldmap="2022:5499:3078",
    },
    items={
      {decorID=2529, title="Open Tome of the Dragon's Dedication", decorType="Ornamental", source={type="vendor", itemID=246863, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=66001, title="A Last Hope"}, rep="true"}},
    }
  },
  {
    title="Lifecaller Tzadrak",
    source={
      id=191025,
      type="vendor",
      faction="Neutral",
      zone="Ruby Lifeshrine, The Waking Shores",
      worldmap="2022:6200:7380",
    },
    items={
      {decorID=2529, title="Open Tome of the Dragon's Dedication", decorType="Ornamental", source={type="vendor", itemID=246863, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=66001, title="A Last Hope"}, rep="true"}},
    }
  },
  {
    title="Provisioner Aristta",
    source={
      id=209192,
      type="vendor",
      faction="Neutral",
      zone="Thaldraszus",
      worldmap="2025:6140:3140",
    },
    items={
      {decorID=4173, title="Studious Dracthyr's Tomes", decorType="Ornamental", source={type="vendor", itemID=248117, currency="4000", currencytype="Mysterious Fragment"}, requirements={rep="true"}},
    }
  },
  {
    title="Evantkis",
    source={
      id=199605,
      type="vendor",
      faction="Neutral",
      zone="Valdrakken",
      worldmap="2112:5840:5740",
    },
    items={
      {decorID=4180, title="The Great Hoard", decorType="Wall Hangings", source={type="vendor", itemID=248124, currency="7500", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=19458, title="A World Awoken"}, rep="true"}},
    }
  },
  {
    title="Ironus Coldsteel",
    source={
      id=209220,
      type="vendor",
      faction="Neutral",
      zone="Eon's Fringe, Thaldraszus",
      worldmap="2025:5220:8080",
    },
    items={
      {decorID=4161, title="Valdrakken Sconce", decorType="Wall Lights", source={type="vendor", itemID=248105, currency="150", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=19507, title="Fringe Benefits"}, rep="true"}},
    }
  },
}
