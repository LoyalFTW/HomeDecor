local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Warlords"] = NS.Data.Vendors["Warlords"] or {}

NS.Data.Vendors["Warlords"]["Draenor"] = {

  {
    title="Ravenspeaker Skeega",
    source={
      id=86037,
      type="vendor",
      faction="Horde",
      zone="Warspear",
      worldmap="624:5348:5974",
    },
    items={
      --       {decorID=12203, title="Arakkoan Alchemy Tools", decorType="Ornamental", source={type="vendor", itemID=258743, currency="800", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=12206, title="High Arakkoan Alchemist's Shelf", decorType="Storage", source={type="vendor", itemID=258746, currency="1500", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=12207, title="High Arakkoan Shelf", decorType="Storage", source={type="vendor", itemID=258747, currency="700", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Shadow-Sage Brakoss",
    source={
      id=85946,
      type="vendor",
      faction="Alliance",
      zone="Stormshield, Ashran",
      worldmap="622:4440:7520",
    },
    items={
      --       {decorID=12203, title="Arakkoan Alchemy Tools", decorType="Ornamental", source={type="vendor", itemID=258743, currency="800", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=12206, title="High Arakkoan Alchemist's Shelf", decorType="Storage", source={type="vendor", itemID=258746, currency="1500", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=12207, title="High Arakkoan Shelf", decorType="Storage", source={type="vendor", itemID=258747, currency="700", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Kil'rip",
    source={
      id=87015,
      type="vendor",
      faction="Horde",
      zone="Frostwall",
      worldmap="525:4800:6600",
    },
    items={
      {decorID=1317, title="Draenor Cookpot", decorType="Food and Drink", source={type="vendor", itemID=245431, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
      {decorID=1322, title="Blackrock Strongbox", decorType="Storage", source={type="vendor", itemID=245433, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
    }
  },
  {
    title="Vindicator Nuurem",
    source={
      id=85932,
      type="vendor",
      faction="Alliance",
      zone="Stormshield, Ashran",
      worldmap="622:4640:7459",
    },
    items={
      {decorID=927, title="Spherical Draenic Topiary", decorType="Bushes", source={type="vendor", itemID=245423, currency="250", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8185, title="Embroidered Embaari Tent", decorType="Large Structures", source={type="vendor", itemID=251476, currency="1000", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8188, title="Shadowmoon Greenhouse", decorType="Large Structures", source={type="vendor", itemID=251479, currency="1500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8190, title="Elodor Armory Rack", decorType="Ornamental", source={type="vendor", itemID=251481, currency="500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8192, title="Draenethyst Lantern", decorType="Small Lights", source={type="vendor", itemID=251483, currency="250", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8193, title="\"Dawning Hope\" Mosaic", decorType="Wall Hangings", source={type="vendor", itemID=251484, currency="1000", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8194, title="Small Karabor Fountain", decorType="Large Structures", source={type="vendor", itemID=251493, currency="500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=8242, title="Grand Draenethyst Lamp", decorType="Large Lights", source={type="vendor", itemID=251551, currency="1500", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Trader Caerel",
    source={
      id=85950,
      type="vendor",
      faction="Alliance",
      zone="Stormshield",
      worldmap="622:4097:5954",
    },
    items={
      {decorID=928, title="Hanging Draenethyst Light", decorType="Ceiling Lights", source={type="vendor", itemID=245425, currency="500", currencytype="Apexis Crystal"}, requirements={quest={id=35396, title="The Dark Heart of Oshu'gun"}, rep="true"}},
      {decorID=8177, title="Draenic Fencepost", decorType="Misc Structural", source={type="vendor", itemID=251330, currency="300", currencytype="Apexis Crystal"}, requirements={quest={id=34792, title="The Traitor's True Name"}, rep="true"}},
      {decorID=8186, title="Draenic Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=251477, currency="1000", currencytype="Garrison Resources"}, requirements={quest={id=36169, title="The Trial of Champions"}, rep="true"}},
      {decorID=8187, title="Square Draenic Table", decorType="Tables and Desks", source={type="vendor", itemID=251478, currency="1000", currencytype="Garrison Resources"}, requirements={quest={id=35196, title="Forging Ahead"}, rep="true"}},
      {decorID=8239, title="Draenic Fence", decorType="Misc Structural", source={type="vendor", itemID=251548, currency="500", currencytype="Apexis Crystal"}, requirements={quest={id=34792, title="The Traitor's True Name"}, rep="true"}},
      {decorID=8240, title="Emblem of the Naaru's Blessing", decorType="Wall Hangings", source={type="vendor", itemID=251549, currency="2000", currencytype="Garrison Resources"}, requirements={quest={id=37322, title="The Prophet's Final Message"}, rep="true"}},
      {decorID=8772, title="Draenic Forge", decorType="Uncategorized", source={type="vendor", itemID=251640, currency="1000", currencytype="Apexis Crystal"}, requirements={quest={id=34099, title="The Battle for Shattrath"}, rep="true"}},
      {decorID=8785, title="Draenethyst Lamppost", decorType="Large Lights", source={type="vendor", itemID=251653, currency="1000", currencytype="Garrison Resources"}, requirements={quest={id=35685, title="Socrethar's Demise"}, rep="true"}},
      {decorID=8786, title="Large Karabor Fountain", decorType="Large Structures", source={type="vendor", itemID=251654, currency="2000", currencytype="Apexis Crystal"}, requirements={quest={id=33256, title="The Defense of Karabor"}, rep="true"}},
    }
  },
  {
    title="Maaria",
    source={
      id=85427,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall",
      worldmap="539:3100:1500",
    },
    items={
      {decorID=931, title="Draenic Storage Chest", decorType="Storage", source={type="vendor", itemID=245424, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
      {decorID=8235, title="Telredor Recliner", decorType="Seating", source={type="vendor", itemID=251544, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
    }
  },
  {
    title="Krixel Pinchwhistle",
    source={
      id=86779,
      type="vendor",
      faction="Horde",
      zone="Lunarfall",
      worldmap="539:3100:1500",
    },
    items={
      {decorID=1354, title="Orcish Communal Stove", decorType="Food and Drink", source={type="vendor", itemID=245444, currency="250", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1355, title="Frostwolf Axe-Dart Board", decorType="Wall Hangings", source={type="vendor", itemID=245445, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1413, title="Orcish Lumberjack's Stool", decorType="Seating", source={type="vendor", itemID=244321, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1414, title="Frostwolf Banded Stool", decorType="Seating", source={type="vendor", itemID=244322, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Ruuan the Seer",
    source={
      id=87775,
      type="vendor",
      faction="Neutral",
      zone="Spires of Arak",
      worldmap="542:4670:4496",
    },
    items={
       {decorID=12200, title="Glorious Pendant of Rukhmar", decorType="Ornamental", source={type="vendor", itemID=258740, currency="800", currencytype="Apexis Crystal"}, requirements={achievement={id=9415, title="Secrets of Skettis"}, rep="true"}}, 
       {decorID=12201, title="Writings of Reshad the Outcast", decorType="Ornamental", source={type="vendor", itemID=258741, currency="1200", currencytype="Resonance Crystals"}, requirements={quest={id=35671, title="A Gathering of Shadows"}, rep="true"}},
       {decorID=12205, title="High Arakkoan Library Shelf", decorType="Storage", source={type="vendor", itemID=258745, currency="700", currencytype="Apexis Crystal"}, requirements={quest={id=35704, title="When All Is Aligned"}, rep="true"}},
      --       {decorID=12208, title="\"Rising Glory of Rukhmar\" Statue", decorType="Misc Accents", source={type="vendor", itemID=258748, currency="1000", currencytype="Garrison Resources"}, requirements={quest={id=35273, title="Hot Seat"}, rep="true"}}, -- Early Access / Midnight pre-patch
       {decorID=12209, title="Uncorrupted Eye of Terokk", decorType="Ornamental", source={type="vendor", itemID=258749, currency="10000", currencytype="Echoes of Ny'alotha"}, requirements={quest={id=35896, title="The Avatar of Terokk"}, rep="true"}},
    }
  },
  {
    title="Artificer Kallaes",
    source={
      id=81133,
      type="vendor",
      faction="Alliance",
      zone="Shadowmoon Valley (Draenor",
      worldmap="539:4620:3929",
    },
    items={
      {decorID=11451, title="Naaru Crystal Icon", decorType="Miscellaneous - All", source={type="vendor", itemID=257349, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Moz'def",
    source={
      id=79812,
      type="vendor",
      faction="Horde",
      zone="Frostwall",
      worldmap="525:4800:6600",
    },
    items={
      {decorID=1326, title="Orc-Forged Weaponry", decorType="Storage", source={type="vendor", itemID=245437, currency="500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1352, title="Warsong Footrest", decorType="Seating", source={type="vendor", itemID=245442, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Supplymaster Eri",
    source={
      id=76872,
      type="vendor",
      faction="Horde",
      zone="Frostwall",
      worldmap="525:4800:6600",
    },
    items={
      {decorID=1416, title="Peon's Work Bucket", decorType="Misc Accents", source={type="vendor", itemID=244324, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Sergeant Crowler",
    source={
      id=78564,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall",
      worldmap="579:3779:3340",
    },
    items={
      {decorID=126, title="Rolled Scroll", decorType="Ornamental", source={type="vendor", itemID=245275, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Peter",
    source={
      id=88220,
      type="vendor",
      faction="Alliance",
      zone="Lunarfall",
      worldmap="539:3100:1500",
    },
    items={
      {decorID=751, title="Wooden Mug", decorType="Food and Drink", source={type="vendor", itemID=239162, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Vora Strongarm",
    source={
      id=87312,
      type="vendor",
      faction="Neutral",
      zone="Frostwall",
      worldmap="525:4800:6600",
    },
    items={
      {decorID=751, title="Wooden Mug", decorType="Food and Drink", source={type="vendor", itemID=239162, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
}
