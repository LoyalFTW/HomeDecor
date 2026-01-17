local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["WarWithin"] = NS.Data.Vendors["WarWithin"] or {}

NS.Data.Vendors["WarWithin"]["KhazAlgar"] = {

  {
    title="Corlen Hordralin",
    source={
      id=252915,
      type="vendor",
      faction="Neutral",
      zone="The Bazaar, Silvermoon City",
      worldmap="2393:4420:6280",
    },
    items={
      --       {decorID=9479, title="\"Silvermoon in Summer\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253602}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9480, title="\"The Last Day of the Semester\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253603}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9481, title="\"A Bridge Over Calm Waters\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253604}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9482, title="\"Family Portrait\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253605}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9484, title="\"Eversong in Bloom\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253607}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9485, title="\"Nature's Strength\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253608}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9491, title="\"Brunch and a Book\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253614}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9492, title="\"Autumnal Eversong\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253615}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9493, title="\"Isolation\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253616}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9494, title="\"Reclamation\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253617}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9495, title="\"The Light Blooms\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253618}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9496, title="\"The Fallen Protectors\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253619}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9497, title="\"River's Protectors\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=253620}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Val'zuun",
    source={
      id=105333,
      type="vendor",
      faction="Neutral",
      zone="Dalaran",
      worldmap="628:6736:6322",
    },
    items={
      {decorID=7610, title="Tome of the Corrupt", decorType="Ornamental", source={type="vendor", itemID=250307, currency="10000", currencytype="Bronze"}, requirements={achievement={id=42318, title="Court of Farondis"}, rep="true"}},
      {decorID=7620, title="Vrykul Lord's Throne", decorType="Seating", source={type="vendor", itemID=250402, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42658, title="Valarjar"}, rep="true"}},
      {decorID=7621, title="Legion's Holo-Communicator", decorType="Miscellaneous - All", source={type="vendor", itemID=250403, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42692, title="Broken Isles Dungeoneer"}, rep="true"}},
      {decorID=7622, title="Hanging Felsteel Chain", decorType="Misc Accents", source={type="vendor", itemID=250404, currency="5000", currencytype="Bronze"}, requirements={rep="true"}},
      {decorID=7623, title="Legion's Fel Torch", decorType="Large Lights", source={type="vendor", itemID=250405, currency="5000", currencytype="Bronze"}, requirements={achievement={id=61060, title="Power of the Obelisks II"}, rep="true"}},
      {decorID=7624, title="Corruption Pit", decorType="Large Structures", source={type="vendor", itemID=250406, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42321, title="Legion Remix Raids"}, rep="true"}},
      {decorID=7625, title="Legion's Fel Brazier", decorType="Large Lights", source={type="vendor", itemID=250407, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42619, title="Dreamweavers"}, rep="true"}},
      {decorID=7658, title="Vertical Felsteel Chain", decorType="Misc Accents", source={type="vendor", itemID=250622, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42675, title="Defending the Broken Isles III"}, rep="true"}},
      {decorID=7686, title="Legion Torture Rack", decorType="Large Structures", source={type="vendor", itemID=250689, currency="10000", currencytype="Bronze"}, requirements={achievement={id=61054, title="Heroic Broken Isles World Quests III"}, rep="true"}},
      {decorID=7687, title="Eredar Lord's Fel Torch", decorType="Large Lights", source={type="vendor", itemID=250690, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42627, title="Argussian Reach"}, rep="true"}},
      {decorID=7690, title="Altar of the Corrupted Flames", decorType="Ornamental", source={type="vendor", itemID=250693, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42674, title="Broken Isles World Quests V"}, rep="true"}},
      {decorID=8810, title="Sentinel's Moonwing Gaze", decorType="Misc Accents", source={type="vendor", itemID=251778, currency="30000", currencytype="Bronze"}, requirements={achievement={id=61218, title="The Wardens"}, rep="true"}},
      {decorID=8811, title="Fel Fountain", decorType="Large Structures", source={type="vendor", itemID=251779, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42689, title="Timeworn Keystone Master"}, rep="true"}},
      {decorID=9165, title="Demonic Storage Chest", decorType="Storage", source={type="vendor", itemID=252753, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42655, title="The Armies of Legionfall"}, rep="true"}},
      {decorID=11278, title="Large Legion Candle", decorType="Small Lights", source={type="vendor", itemID=256677, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42628, title="The Nightfallen"}, rep="true"}},
      {decorID=11279, title="Small Legion Candle", decorType="Small Lights", source={type="vendor", itemID=256678, currency="2500", currencytype="Bronze"}, requirements={rep="true"}},
      {decorID=11942, title="Hanging Felsteel Cage", decorType="Misc Structural", source={type="vendor", itemID=258299, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42547, title="Highmountain Tribe"}, rep="true"}},
    }
  },
  {
    title="Maku",
    source={
      id=255114,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5311:5092",
    },
    items={
      --       {decorID=1080, title="Replica Sky's Hope", decorType="Ornamental", source={type="vendor", itemID=253443}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1147, title="Rutaani Sporepod", decorType="Uncategorized", source={type="vendor", itemID=253467}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1726, title="Sturdy Haranir Handcart", decorType="Misc Furnishings", source={type="vendor", itemID=245535}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2224, title="Stoppered Spring Water Gourd", decorType="Misc Furnishings", source={type="vendor", itemID=246407}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2232, title="Ruddy Haranir Pigment Bowl", decorType="Misc Furnishings", source={type="vendor", itemID=246415}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2605, title="Rustic Harandar Planter", decorType="Misc Furnishings", source={type="vendor", itemID=247234, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8993, title="Fungal Pergola", decorType="Miscellaneous - All", source={type="vendor", itemID=252045}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10327, title="Root-Woven Door", decorType="Misc Furnishings", source={type="vendor", itemID=254319}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10778, title="Root-Woven Window", decorType="Misc Furnishings", source={type="vendor", itemID=254878}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14639, title="Harandar Runestone", decorType="Ornamental", source={type="vendor", itemID=262614, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14799, title="Harandar Anvil", decorType="Ornamental", source={type="vendor", itemID=262906}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14809, title="Ward of the Shul'ka", decorType="Ornamental", source={type="vendor", itemID=263020}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14823, title="Replica Wey'nan's Ward", decorType="Ornamental", source={type="vendor", itemID=263037}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14827, title="Replica Root of the World", decorType="Ornamental", source={type="vendor", itemID=263041}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14968, title="Harandar Glowvine Lantern", decorType="Small Lights", source={type="vendor", itemID=263196}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15155, title="Bubbling Haranir Cauldron", decorType="Uncategorized", source={type="vendor", itemID=263315}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15463, title="Harandar Charcuterie Board", decorType="Food and Drink", source={type="vendor", itemID=264178}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15494, title="On'ohia's Call", decorType="Wall Hangings", source={type="vendor", itemID=264259}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15497, title="Haranir Whistling Arrow", decorType="Ornamental", source={type="vendor", itemID=264262}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17516, title="Fungarian Vine Fence", decorType="Walls and Columns", source={type="vendor", itemID=265792}, requirements={achievement={id=62290, title="Harandar: The Highest Peaks"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17886, title="Altar of the Shul'ka", decorType="Uncategorized", source={type="vendor", itemID=266259}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Chel the Chip",
    source={
      id=257633,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2437:1737:3808",
    },
    items={
      --       {decorID=11323, title="Amani Crafter's Tool Rack", decorType="Ornamental", source={type="vendor", itemID=256923}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15484, title="Woodblock Stool", decorType="Seating", source={type="vendor", itemID=264249}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15489, title="Three-Tier Zul'Aman Shelf", decorType="Storage", source={type="vendor", itemID=264254}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15851, title="Amani Slate Bench", decorType="Seating", source={type="vendor", itemID=264655, currency="150", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Magovu",
    source={
      id=240279,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4595:6592",
    },
    items={
      --       {decorID=11324, title="Hash'ey Heartbroth Cauldron", decorType="Ornamental", source={type="vendor", itemID=256924}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11326, title="Empty Amani Cauldron", decorType="Ornamental", source={type="vendor", itemID=256926}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11327, title="Carved Idol of Nalorakk, Loa of War", decorType="Ornamental", source={type="vendor", itemID=256927}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11333, title="Carved Idol of Jan'alai, Loa of Fire", decorType="Ornamental", source={type="vendor", itemID=256933}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11334, title="Boiling Amani Cauldron", decorType="Ornamental", source={type="vendor", itemID=256934}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11936, title="Carved Idol of Halazzi, Loa of the Hunt", decorType="Ornamental", source={type="vendor", itemID=258290}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=12154, title="Burning Amani Pinecone", decorType="Small Lights", source={type="vendor", itemID=258549}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14204, title="Visage of Akil'zon, Loa of Victory", decorType="Wall Hangings", source={type="vendor", itemID=260202}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14350, title="Visage of Nalorakk, Loa of War", decorType="Wall Hangings", source={type="vendor", itemID=260514}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14351, title="Visage of Halazzi, Loa of the Hunt", decorType="Wall Hangings", source={type="vendor", itemID=260515}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14352, title="Visage of Jan'alai, Loa of Fire", decorType="Wall Hangings", source={type="vendor", itemID=260516}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15158, title="Simple Amani Basket", decorType="Storage", source={type="vendor", itemID=263318, currency="1000", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15160, title="Rope-Bound Amani Basket", decorType="Storage", source={type="vendor", itemID=263320, currency="1000", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15571, title="Amani Incense Burner", decorType="Miscellaneous - All", source={type="vendor", itemID=264333}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15596, title="Carved Idol of Akil'zon, Loa of Victory", decorType="Ornamental", source={type="vendor", itemID=264350}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Tajaka Sawtusk",
    source={
      id=254944,
      type="vendor",
      faction="Neutral",
      zone="Zul'Aman",
      worldmap="2437:4604:6608",
    },
    items={
      --       {decorID=1148, title="Ritual-Cursed Sarcophagus", decorType="Tables and Desks", source={type="vendor", itemID=253469}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10858, title="Zul'Aman Ancestral Fountain", decorType="Large Structures", source={type="vendor", itemID=255648, currency="2000", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11325, title="Amani Spearhunter's Spit", decorType="Uncategorized", source={type="vendor", itemID=256925}, requirements={achievement={id=62289, title="Zul'Aman: The Highest Peaks"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11328, title="Banner of the Amani Tribe", decorType="Ornamental", source={type="vendor", itemID=256928}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15490, title="Amani Trophy Frame", decorType="Wall Hangings", source={type="vendor", itemID=264255}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15492, title="Zul'Aman Armament Rest", decorType="Miscellaneous - All", source={type="vendor", itemID=264257}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15572, title="Amani War Drum", decorType="Miscellaneous - All", source={type="vendor", itemID=264334, currency="400", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15573, title="Colossal Amani Stone Visage", decorType="Miscellaneous - All", source={type="vendor", itemID=264335, currency="400", currencytype="War Resources"}, requirements={achievement={id=62122, title="Tallest Tree in the Forest"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15743, title="Skyweave Amani Tapestry", decorType="Wall Hangings", source={type="vendor", itemID=264479, currency="1200", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15744, title="Greenvine Amani Tapestry", decorType="Wall Hangings", source={type="vendor", itemID=264480, currency="1200", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15745, title="Earthhide Amani Tapestry", decorType="Wall Hangings", source={type="vendor", itemID=264481, currency="1200", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16092, title="Zul'Aman Flame Cradle", decorType="Ceiling Lights", source={type="vendor", itemID=264715}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Telemancer Astrandis",
    source={
      id=242399,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5253:7887",
    },
    items={
      --       {decorID=15399, title="Fungal Chest", decorType="Storage", source={type="vendor", itemID=263994, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15400, title="Delver's Bountiful Coffer", decorType="Storage", source={type="vendor", itemID=263995, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15401, title="Twilight Tabernacle", decorType="Storage", source={type="vendor", itemID=263996, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15412, title="Corewarden's Spoils", decorType="Storage", source={type="vendor", itemID=264007, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15413, title="Root-Wrapped Reliquary", decorType="Storage", source={type="vendor", itemID=264008, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15455, title="Ancient Kaldorei Coffer", decorType="Storage", source={type="vendor", itemID=264170, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15460, title="Amani Strongbox", decorType="Storage", source={type="vendor", itemID=264175, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Morta Gage",
    source={
      id=252873,
      type="vendor",
      faction="Alliance",
      zone="Arcantina",
      worldmap="2541:4200:5000",
    },
    items={
      --       {decorID=9248, title="Dried Gilnean Roses", decorType="Small Foliage", source={type="vendor", itemID=253174, currency="750", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9249, title="Hyjal Climbing Vine", decorType="Small Foliage", source={type="vendor", itemID=253175, currency="2500", currencytype="Voidlight Marl"}, requirements={quest={id=92323, title="Where the Fire Once Burned"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9250, title="Ancient Zandalari Ritual Scroll", decorType="Ornamental", source={type="vendor", itemID=253176, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92322, title="Timear Foresees a Proof of Demise!"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9251, title="Pylon Fragment", decorType="Ornamental", source={type="vendor", itemID=253177, currency="2500", currencytype="Voidlight Marl"}, requirements={quest={id=92324, title="Uncrowned's Cold Case"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9252, title="Inactive Filigree Moon Lamp", decorType="Ornamental", source={type="vendor", itemID=253178, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92320, title="Still Behind Enemy Portals"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9253, title="Ornamental Proudmoore Anchor", decorType="Ornamental", source={type="vendor", itemID=253179, currency="2500", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9439, title="Scarred Orcish Spear", decorType="Misc Furnishings", source={type="vendor", itemID=253542, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92319, title="A Favor to Axe"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9440, title="Clefthoof Hide Rug", decorType="Floor", source={type="vendor", itemID=253543, currency="750", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9441, title="Weathered History of the Warchiefs", decorType="Ornamental", source={type="vendor", itemID=253544, currency="750", currencytype="Voidlight Marl"}, requirements={quest={id=92325, title="Hellscream's Heritage"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9475, title="Banner of the Ebon Blade", decorType="Wall Hangings", source={type="vendor", itemID=253598, currency="8000", currencytype="Voidlight Marl"}, requirements={quest={id=92321, title="A Frostbitten Tally"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9624, title="Sandy Vulpera Banner", decorType="Ornamental", source={type="vendor", itemID=253700, currency="2500", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Om'sirik",
    source={
      id=235252,
      type="vendor",
      faction="Neutral",
      zone="K'aresh",
      worldmap="2472:4033:2936",
    },
    items={
      {decorID=3891, title="Deactivated K'areshi Warp Cannon", decorType="Large Structures", source={type="vendor", itemID=247751, currency="2000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=11948, title="K'areshi Warp Platform", decorType="Large Structures", source={type="vendor", itemID=258306, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=11952, title="K'areshi Protectorate Portal", decorType="Large Structures", source={type="vendor", itemID=258320, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12195, title="Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258666, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12196, title="Angled Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258667, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12197, title="Long Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258668, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12198, title="Corner Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258669, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12211, title="Exposed Corner Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258766, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12212, title="Exposed Long Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258767, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12217, title="Exposed Intersecting Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258835, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12218, title="Reinforced Corner Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258836, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12220, title="Exposed Angled Ethereal Pipe Segment", decorType="Large Structures", source={type="vendor", itemID=258885, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Hesta Forlath",
    source={
      id=252916,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4405:6276",
    },
    items={
      --       {decorID=1446, title="Silvermoon Painter's Cushion", decorType="Seating", source={type="vendor", itemID=244656, currency="200", currencytype="Ancient Mana"}, requirements={achievement={id=62185, title="Ever Painting"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9483, title="\"Brunch and a Book\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253606}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9486, title="\"River's Protectors\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253609}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9487, title="\"Isolation\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253610}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9488, title="\"The Fallen Protectors\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253611}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9489, title="\"Autumnal Eversong\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253612}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9490, title="\"Reclamation\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253613}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9628, title="Fresh Canvas", decorType="Wall Hangings", source={type="vendor", itemID=253704}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9629, title="\"The Light Blooms\" Unframed Painting", decorType="Wall Hangings", source={type="vendor", itemID=253705}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Caeris Fairdawn",
    source={
      id=240838,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4346:4742",
    },
    items={
      --       {decorID=1896, title="Silvermoon Sanctum Focus", decorType="Ornamental", source={type="vendor", itemID=245941}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1901, title="Floating Azure Lantern", decorType="Small Lights", source={type="vendor", itemID=245985}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=5564, title="Reverent Sin'dorei Statue", decorType="Large Structures", source={type="vendor", itemID=249559, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10944, title="Silvermoon Gemmed Chair", decorType="Seating", source={type="vendor", itemID=256040, currency="750", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11502, title="Bejeweled Silvermoon Chandelier", decorType="Misc Furnishings", source={type="vendor", itemID=257421}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11503, title="Gilded Sunfury Chair", decorType="Seating", source={type="vendor", itemID=257422, currency="750", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14971, title="Crimson Silvermoon Runner", decorType="Floor", source={type="vendor", itemID=263205}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14972, title="Plum Eversong Rug", decorType="Floor", source={type="vendor", itemID=263206}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14979, title="Gilded Lightwood Wardrobe", decorType="Storage", source={type="vendor", itemID=263216}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14985, title="Gilded Sky-Blue Drapery", decorType="Wall Hangings", source={type="vendor", itemID=263223, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15059, title="Grand Lightwood Table", decorType="Tables and Desks", source={type="vendor", itemID=263228}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15060, title="Ornate Lightwood Table", decorType="Tables and Desks", source={type="vendor", itemID=263229}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15063, title="Floating Spire Shelf", decorType="Storage", source={type="vendor", itemID=263232}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15065, title="Turning Silvermoon Archives", decorType="Storage", source={type="vendor", itemID=263234}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15499, title="Gilded Vigil Post", decorType="Misc Lighting", source={type="vendor", itemID=264264}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15500, title="Sanctified Flame Lantern", decorType="Misc Lighting", source={type="vendor", itemID=264265, currency="300", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Second Chair Pawdo",
    source={
      id=252312,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5284:6800",
    },
    items={
      {decorID=1693, title="Small Val'sharah Bookcase", decorType="Storage", source={type="vendor", itemID=245259, currency="75", currencytype="Order Resources"}, requirements={quest={id=38147, title="Entangled Dreams"}, rep="true"}},
      {decorID=1861, title="Filigree Moon Lamp", decorType="Small Lights", source={type="vendor", itemID=245655, currency="10", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2330, title="Gnomish Tesla Coil", decorType="Misc Structural", source={type="vendor", itemID=246487}, requirements={quest={id=40573, title="The Nightmare Lord"}, rep="true"}},
      {decorID=2433, title="Bolt Chair", decorType="Seating", source={type="vendor", itemID=166846, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=4022, title="Nightborne Lantern", decorType="Small Lights", source={type="vendor", itemID=247908, currency="10", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=4029, title="Square Suramar Table", decorType="Tables and Desks", source={type="vendor", itemID=247915, currency="400", currencytype="Order Resources"}, requirements={quest={id=44052, title="And They Will Tremble"}, rep="true"}},
      {decorID=4172, title="Valdrakken Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=248116, currency="150", currencytype="Dragon Isles Supplies"}, requirements={quest={id=70745, title="Enforced Relaxation"}, rep="true"}},
      {decorID=5111, title="Golden Cloud Serpent Treasure Chest", decorType="Storage", source={type="vendor", itemID=248934, currency="650", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=9242, title="Earthen Storage Crate", decorType="Storage", source={type="vendor", itemID=253168, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=9247, title="Meadery Storage Barrel", decorType="Storage", source={type="vendor", itemID=253173, currency="850", currencytype="Resonance Crystals"}, requirements={quest={id=92572, title="Furniture Favor"}, rep="true"}},
      {decorID=10962, title="Draconic Sconce", decorType="Wall Hangings", source={type="vendor", itemID=256168, currency="10", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
    }
  },
  {
    title="Garnett",
    source={
      id=252910,
      type="vendor",
      faction="Horde",
      zone="Dornogal",
      worldmap="2339:5468:5724",
    },
    items={
      {decorID=9168, title="Stonelight Countertop", decorType="Tables and Desks", source={type="vendor", itemID=252756, currency="800", currencytype="Resonance Crystals"}, requirements={quest={id=79530, title="Bad Business"}, rep="true"}},
      {decorID=9169, title="Boulder Springs Recliner", decorType="Seating", source={type="vendor", itemID=252757, currency="900", currencytype="Resonance Crystals"}, requirements={achievement={id=20595, title="Sojourner of Isle of Dorn"}, rep="true"}},
      {decorID=9181, title="Rambleshire Resting Platform", decorType="Beds", source={type="vendor", itemID=253023, currency="1000", currencytype="Resonance Crystals"}, requirements={achievement={id=40504, title="Rocked to Sleep"}, rep="true"}},
      {decorID=9182, title="Fallside Lantern", decorType="Small Lights", source={type="vendor", itemID=253034, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=82895, title="The Weight of Duty"}, rep="true"}},
      {decorID=9185, title="Dornogal Brazier", decorType="Large Lights", source={type="vendor", itemID=253037, currency="600", currencytype="Resonance Crystals"}, requirements={achievement={id=40859, title="We're Here All Night"}, rep="true"}},
      {decorID=9186, title="Dornogal Hanging Lantern", decorType="Ceiling Lights", source={type="vendor", itemID=253038, currency="500", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=9237, title="Fallside Storage Tent", decorType="Large Structures", source={type="vendor", itemID=253163, currency="900", currencytype="Resonance Crystals"}, requirements={achievement={id=19408, title="Professional Algari Master"}, rep="true"}},
    }
  },
  {
    title="Gabbun",
    source={
      id=256783,
      type="vendor",
      faction="Alliance",
      zone="The Ringing Deeps",
      worldmap="2214:4335:3327",
    },
    items={
      --       {decorID=11930, title="Kobold Digger's Chair", decorType="Seating", source={type="vendor", itemID=258262, currency="400", currencytype="War Resources"}, requirements={quest={id=79510, title="The Wickless Candle"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11931, title="Kobold Candle Trio", decorType="Small Lights", source={type="vendor", itemID=258264, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=78642, title="New Candle, New Hope"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11932, title="Kobold Wagon", decorType="Miscellaneous - All", source={type="vendor", itemID=258265, currency="1200", currencytype="Resonance Crystals"}, requirements={quest={id=80516, title="Bump off the Boss"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11933, title="Candle-Festooned Wooden Awning", decorType="Large Structures", source={type="vendor", itemID=258267, currency="1000", currencytype="Order Resources"}, requirements={quest={id=79565, title="Janky Candles"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Ta'sam",
    source={
      id=235314,
      type="vendor",
      faction="Neutral",
      zone="Tazavesh, the Veiled Market, K'aresh",
      worldmap="2472:4320:3479",
    },
    items={
      {decorID=14359, title="Cartel Collector's Cage", decorType="Miscellaneous - All", source={type="vendor", itemID=260582, currency="500", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Stacks Topskimmer",
    source={
      id=251911,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:4319:5047",
    },
    items={
      {decorID=825, title="Cozy Four-Pipe Bed", decorType="Beds", source={type="vendor", itemID=245306, currency="1200", currencytype="Resonance Crystals"}, requirements={quest={id=86408, title="My Hole in the Wall"}, rep="true"}},
      {decorID=827, title="Rocket-Unpowered Rocket", decorType="Miscellaneous - All", source={type="vendor", itemID=245303, currency="800", currencytype="Resonance Crystals"}, requirements={quest={id=85780, title="Right Where We Want Him"}, rep="true"}},
      {decorID=1257, title="Undermine Round Table", decorType="Tables and Desks", source={type="vendor", itemID=245314, currency="850", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1258, title="Undermine Rectangular Table", decorType="Tables and Desks", source={type="vendor", itemID=243312, currency="900", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1262, title="Undermine Fencepost", decorType="Misc Structural", source={type="vendor", itemID=245319, currency="350", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1263, title="Undermine Fence", decorType="Misc Structural", source={type="vendor", itemID=245318, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1266, title="Undermine Market Stall", decorType="Large Structures", source={type="vendor", itemID=245325, currency="1000", currencytype="Resonance Crystals"}, requirements={quest={id=85711, title="Unsolicited Feedback"}, rep="true"}},
      {decorID=1267, title="Cartel Head's Schmancy Desk", decorType="Tables and Desks", source={type="vendor", itemID=243321, currency="1000", currencytype="Resonance Crystals"}, requirements={quest={id=87297, title="Cashing the Check"}, rep="true"}},
      {decorID=1271, title="Rocket-Powered Fountain", decorType="Large Structures", source={type="vendor", itemID=245324, currency="1500", currencytype="Resonance Crystals"}, requirements={achievement={id=40894, title="Sojourner of Undermine"}, rep="true"}},
      {decorID=1274, title="\"Elegant\" Lawn Flamingo", decorType="Ornamental", source={type="vendor", itemID=245308, currency="750", currencytype="Resonance Crystals"}, requirements={quest={id=87008, title="Ad-Hoc Wedding Planner"}, rep="true"}},
      {decorID=1276, title="Reinforced Goblin Umbrella", decorType="Ornamental", source={type="vendor", itemID=245310, currency="800", currencytype="Resonance Crystals"}, requirements={quest={id=83176, title="Just a Hunch"}, rep="true"}},
      {decorID=11455, title="Drained Dark Heart of Galakrond", decorType="Misc Accents", source={type="vendor", itemID=257353, currency="300", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=61451, title="Worldsoul-Searching"}, rep="true"}},
      {decorID=14381, title="Gob-chanical Trash Heap", decorType="Misc Accents", source={type="vendor", itemID=260700, currency="300", currencytype="Resonance Crystals"}, requirements={quest={id=84675, title="Showdown in the Attic"}, rep="true"}},
    }
  },
  {
    title="\"Den\" Nightshade",
    source={
      id=257307,
      type="vendor",
      faction="Alliance",
      zone="",
      worldmap="0:0000:0000",
    },
    items={
      --       {decorID=14677, title="Complete Guide to K'areshi Wrappings, Vol. 11", decorType="Ornamental", source={type="vendor", itemID=262664, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14678, title="K'areshi Holo-Crystal Projector", decorType="Miscellaneous - All", source={type="vendor", itemID=262665, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14679, title="K'areshi Incense Burner", decorType="Miscellaneous - All", source={type="vendor", itemID=262666, currency="2", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14793, title="Consortium Glowpost", decorType="Large Lights", source={type="vendor", itemID=262884, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14800, title="Tazaveshi Hookah", decorType="Miscellaneous - All", source={type="vendor", itemID=262907, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14829, title="Consortium Energy Barrel", decorType="Storage", source={type="vendor", itemID=263043, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14830, title="Empty Consortium Energy Barrel", decorType="Storage", source={type="vendor", itemID=263044, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14831, title="Consortium Energy Collector", decorType="Large Lights", source={type="vendor", itemID=263045, currency="20", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14832, title="Consortium Energy Crate", decorType="Storage", source={type="vendor", itemID=263046, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14833, title="Empty Consortium Energy Crate", decorType="Storage", source={type="vendor", itemID=263047, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14834, title="Consortium Energy Banner", decorType="Ornamental", source={type="vendor", itemID=263048, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Chert",
    source={
      id=252887,
      type="vendor",
      faction="Neutral",
      zone="The Ringing Deeps",
      worldmap="2214:4340:3300",
    },
    items={
      {decorID=9178, title="Earthen Etched Throne", decorType="Seating", source={type="vendor", itemID=253020, currency="500", currencytype="Resonance Crystals"}, requirements={quest={id=78761, title="Into the Machine"}, rep="true"}},
      {decorID=9188, title="Coreway Sentinel Lamppost", decorType="Misc Structural", source={type="vendor", itemID=253040, currency="650", currencytype="Resonance Crystals"}, requirements={quest={id=82144, title="On the Road"}, rep="true"}},
      {decorID=9236, title="Earthen Chain Wall Shelf", decorType="Storage", source={type="vendor", itemID=253162, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=9246, title="Gundargaz Grand Keg", decorType="Storage", source={type="vendor", itemID=253172, currency="850", currencytype="Resonance Crystals"}, requirements={quest={id=83160, title="Cinderbrew Reserve"}, rep="true"}},
    }
  },
  {
    title="Void Researcher Aemely",
    source={
      id=259922,
      type="vendor",
      faction="Neutral",
      zone="Voidstorm",
      worldmap="2405:5266:7279",
    },
    items={
      --       {decorID=14554, title="Ornate Cosmic Rug", decorType="Floor", source={type="vendor", itemID=262351}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14602, title="Cosmic Kettle", decorType="Food and Drink", source={type="vendor", itemID=262472, currency="2", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14631, title="Smoldering Energy Forge", decorType="Uncategorized", source={type="vendor", itemID=262606}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15071, title="Sturdy Void Elf Crate", decorType="Storage", source={type="vendor", itemID=263240}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15579, title="Cosmic Barrel", decorType="Storage", source={type="vendor", itemID=264340, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15597, title="Ornate Void Elf Banner", decorType="Miscellaneous - All", source={type="vendor", itemID=264351}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15768, title="Sturdy Void Elf Barricade", decorType="Miscellaneous - All", source={type="vendor", itemID=264508}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15890, title="Void Elf Weapon Rack", decorType="Miscellaneous - All", source={type="vendor", itemID=264656}, requirements={achievement={id=62291, title="Voidstorm: The Highest Peaks"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15891, title="Open Sturdy Void Elf Trunk", decorType="Storage", source={type="vendor", itemID=264657, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15894, title="Cosmic Traveler's Satchel", decorType="Storage", source={type="vendor", itemID=264659}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=18617, title="Ornate Cosmic Table", decorType="Tables and Desks", source={type="vendor", itemID=267082}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=18800, title="Open Void Elf Bedroll", decorType="Uncategorized", source={type="vendor", itemID=267209}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Void Researcher Anomander",
    source={
      id=248328,
      type="vendor",
      faction="Neutral",
      zone="Voidstorm",
      worldmap="2405:5259:7290",
    },
    items={
      --       {decorID=5132, title="Cosmic Void Table", decorType="Tables and Desks", source={type="vendor", itemID=248964}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14592, title="Dark Void Inkwell", decorType="Ornamental", source={type="vendor", itemID=262462}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14593, title="Cosmic Void Ashwell", decorType="Ornamental", source={type="vendor", itemID=262463}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14596, title="Void Elf Table", decorType="Tables and Desks", source={type="vendor", itemID=262466}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14603, title="Cosmic Chalice", decorType="Food and Drink", source={type="vendor", itemID=262473}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14632, title="Void Elf Throne", decorType="Seating", source={type="vendor", itemID=262607}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14634, title="Void Elf Floating Lantern", decorType="Small Lights", source={type="vendor", itemID=262609}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15260, title="Sturdy Void Elf Trunk", decorType="Storage", source={type="vendor", itemID=263499, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15575, title="Cosmic Void Training Dummy", decorType="Miscellaneous - All", source={type="vendor", itemID=264337}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15578, title="Cosmic Void Summoning Crystal", decorType="Miscellaneous - All", source={type="vendor", itemID=264339}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15581, title="Cosmic Void Crate", decorType="Storage", source={type="vendor", itemID=264341, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15584, title="Cosmic Void Orb", decorType="Small Lights", source={type="vendor", itemID=264344}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15597, title="Ornate Void Elf Banner", decorType="Miscellaneous - All", source={type="vendor", itemID=264351}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15769, title="Void Elf Barrel", decorType="Storage", source={type="vendor", itemID=264509, currency="10", currencytype="Voidlight Marl"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=18800, title="Open Void Elf Bedroll", decorType="Uncategorized", source={type="vendor", itemID=267209}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Neriv",
    source={
      id=242726,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4349:4765",
    },
    items={
      --       {decorID=2459, title="Murder Row Wine Decanter", decorType="Food and Drink", source={type="vendor", itemID=246692, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=7782, title="Crimson Lightwood Privacy Screen", decorType="Misc Furnishings", source={type="vendor", itemID=250772, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Dennia Silvertongue",
    source={
      id=256828,
      type="vendor",
      faction="Horde",
      zone="Silvermoon City",
      worldmap="2393:5117:5645",
    },
    items={
      {decorID=1458, title="Light-Infused Fountain", decorType="Large Structures", source={type="vendor", itemID=244668, currency="2000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
      {decorID=1894, title="Void-Corrupted Fountain", decorType="Large Structures", source={type="vendor", itemID=245939, currency="2000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
      {decorID=2231, title="Light-Infused Rotunda", decorType="Large Structures", source={type="vendor", itemID=246414, currency="600", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4843, title="Void-Corrupted Rotunda", decorType="Large Structures", source={type="vendor", itemID=248809}, requirements={rep="true"}},
      {decorID=9149, title="\"The High Exarch\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=252666, currency="1000", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=9150, title="\"The Ranger of the Void\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=252667, currency="1000", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=9151, title="\"The Harbinger\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=252668, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=9152, title="\"The Redeemer\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=252669, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      --       {decorID=15070, title="Cuddly Tan Grrgle", decorType="Floor", source={type="vendor", itemID=263239}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15072, title="Cuddly Seafoam Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263241}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15073, title="Cuddly Saffron Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263242}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15074, title="Cuddly Sage Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263243}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15142, title="Cuddly Lavender Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263292}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15143, title="Cuddly Pink Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263293}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15144, title="Cuddly Gold-Colored Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263294}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15145, title="Cuddly Lime Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263295}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15146, title="Cuddly Orange Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263296}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15147, title="Cuddly Cerulean Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263297}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15148, title="Cuddly Alliance Blue Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263298}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15149, title="Cuddly Horde Red Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263299}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15150, title="Cuddly Purple Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263300}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15151, title="Cuddly Green Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263301}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15152, title="Cuddly Red Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263302}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15153, title="Cuddly Blue Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=263303}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16027, title="Cuddly Seagreen Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264680}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16028, title="Cuddly Brown Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264681}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16029, title="Cuddly Flaxen Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264682}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16030, title="Cuddly Sanguine Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264683}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16031, title="Cuddly Gumball Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264684}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16032, title="Cuddly Violet Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264685}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16033, title="Cuddly Olive Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264686}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16034, title="Cuddly Plum Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264687}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16035, title="Cuddly Tangerine Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264688}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16036, title="Cuddly Sapphire Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264689}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16037, title="Cuddly Clover Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264690}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16038, title="Cuddly Peach Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=264691}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16811, title="Cuddly Tomato Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265387}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16812, title="Cuddly Lemon Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265388}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16813, title="Cuddly Cotton Candy Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265389}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16814, title="Cuddly Mint Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265390}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16815, title="Cuddly Magenta Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265391}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16816, title="Cuddly Sunset Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265392}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16817, title="Cuddly Mauve Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265393}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16818, title="Cuddly Pearl Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265394}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16819, title="Cuddly Charcoal Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265395}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16820, title="Cuddly Onyx Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265396}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16821, title="Cuddly Bright Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265397}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16822, title="Cuddly Juniper Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265398}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16964, title="Cuddly Basil Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265544}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16965, title="Cuddly Void Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265545}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16966, title="Cuddly Fel Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265546}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16967, title="Cuddly Spectral Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265547}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16968, title="Cuddly Emerald Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265548}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16969, title="Cuddly Metallic Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265549}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16970, title="Cuddly Verdant Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265550}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16971, title="Cuddly Cobalt Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265551}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16972, title="Cuddly Teal Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265552}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=16973, title="Cuddly Ochre Grrgle", decorType="Miscellaneous - All", source={type="vendor", itemID=265553}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Velerd",
    source={
      id=219217,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:5520:7640",
    },
    items={
      {decorID=3890, title="Deephaul Crystal", decorType="Ornamental", source={type="vendor", itemID=247750, currency="2500", currencytype="Honor"}, requirements={achievement={id=40612, title="Sprinting in the Ravine"}, rep="true"}},
      {decorID=9244, title="Earthen Contender's Target", decorType="Misc Accents", source={type="vendor", itemID=253170, currency="750", currencytype="Honor"}, requirements={achievement={id=40210, title="Deephaul Ravine Victory"}, rep="true"}},
    }
  },
  {
    title="Sathren Azuredawn",
    source={
      id=259864,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2437:0314:1871",
    },
    items={
      --       {decorID=1159, title="Sin'dorei Honor Stone", decorType="Ornamental", source={type="vendor", itemID=253485}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1160, title="Diamond Honor Stone", decorType="Ornamental", source={type="vendor", itemID=253488}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1173, title="Gemmed Eversong Lantern", decorType="Small Lights", source={type="vendor", itemID=243106, currency="150", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1195, title="Silvermoon Library Bookcase", decorType="Storage", source={type="vendor", itemID=245282, currency="500", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1442, title="Silvermoon Sundial", decorType="Ornamental", source={type="vendor", itemID=244538}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1489, title="Majestic Lightwood Table", decorType="Tables and Desks", source={type="vendor", itemID=244783, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=1908, title="Ornate Silvermoon Candelabra", decorType="Small Lights", source={type="vendor", itemID=245992}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8872, title="Eversong Feast Platter", decorType="Food and Drink", source={type="vendor", itemID=251909, currency="500", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8874, title="Eversong Dessert Platter", decorType="Food and Drink", source={type="vendor", itemID=251911, currency="500", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8875, title="Goldenmist Grapes", decorType="Food and Drink", source={type="vendor", itemID=251912, currency="500", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10542, title="\"Eversong Lantern\" Painting", decorType="Uncategorized", source={type="vendor", itemID=254773, currency="1500", currencytype="Garrison Resources"}, requirements={achievement={id=62288, title="Eversong Woods: The Highest Peaks"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11470, title="Silvermoon Energy Focus", decorType="Ornamental", source={type="vendor", itemID=257367, currency="250", currencytype="Dragon Isles Supplies"}, requirements={achievement={id=61507, title="A Bloody Song"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14977, title="Gilded Eversong Cup", decorType="Food and Drink", source={type="vendor", itemID=263211}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15062, title="Silvermoon Curio Shelves", decorType="Storage", source={type="vendor", itemID=263231, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15483, title="Sin'dorei Storage Jar", decorType="Ornamental", source={type="vendor", itemID=264248}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Armorer Goldcrest",
    source={
      id=242725,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4354:4750",
    },
    items={
      --       {decorID=14970, title="Rack of Silvermoon Arms", decorType="Storage", source={type="vendor", itemID=263203, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15505, title="[DNT] [AUTOGEN] 12BE_BloodElf_Ritual_Tome_Bloodknight01_Open.m2", decorType="Ornamental", source={type="vendor", itemID=264270}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Waxmonger Squick",
    source={
      id=221390,
      type="vendor",
      faction="Neutral",
      zone="Gundargaz, Ringing Deeps",
      worldmap="2214:4320:3279",
    },
    items={
      {decorID=9236, title="Earthen Chain Wall Shelf", decorType="Storage", source={type="vendor", itemID=253162, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Auditor Balwurz",
    source={
      id=223728,
      type="vendor",
      faction="Neutral",
      zone="Dornogal",
      worldmap="2339:3920:2440",
    },
    items={
      {decorID=760, title="Literature of Dornogal", decorType="Ornamental", source={type="vendor", itemID=245295, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=761, title="Literature of Taelloch", decorType="Ornamental", source={type="vendor", itemID=245296, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=762, title="Literature of Gundargaz", decorType="Ornamental", source={type="vendor", itemID=245297, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1750, title="Ornate Ochre Window", decorType="Windows", source={type="vendor", itemID=245561, currency="620", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=9242, title="Earthen Storage Crate", decorType="Storage", source={type="vendor", itemID=253168, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Ranger Allorn",
    source={
      id=242724,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4344:4756",
    },
    items={
      --       {decorID=5564, title="Reverent Sin'dorei Statue", decorType="Large Structures", source={type="vendor", itemID=249559, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14978, title="Farstrider's Comfy Cushion", decorType="Misc Accents", source={type="vendor", itemID=263212, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14979, title="Gilded Lightwood Wardrobe", decorType="Storage", source={type="vendor", itemID=263216}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Mothkeeper Wew'tam",
    source={
      id=251259,
      type="vendor",
      faction="Alliance",
      zone="Harandar",
      worldmap="2413:4925:5433",
    },
    items={
      --       {decorID=14824, title="Haranir Reclined Bed", decorType="Beds", source={type="vendor", itemID=263038}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15478, title="Firm Haranir Pillow", decorType="Ornamental", source={type="vendor", itemID=264243}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15480, title="Warm Haranir Blanket", decorType="Floor", source={type="vendor", itemID=264245}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Naynar",
    source={
      id=240407,
      type="vendor",
      faction="Alliance",
      zone="Harandar",
      worldmap="2413:5095:5073",
    },
    items={
      --       {decorID=2219, title="Hollowed Harandar Gourds", decorType="Misc Furnishings", source={type="vendor", itemID=246402}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2225, title="Haranir Herb Rack", decorType="Misc Furnishings", source={type="vendor", itemID=246408}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2588, title="Sealed Fungal Jar", decorType="Food and Drink", source={type="vendor", itemID=246959, currency="500", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2589, title="Opened Fungal Jar", decorType="Misc Furnishings", source={type="vendor", itemID=246960, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8916, title="Fungarian Sack", decorType="Misc Furnishings", source={type="vendor", itemID=251980, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14808, title="Haranir Pennant", decorType="Wall Hangings", source={type="vendor", itemID=263019}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14825, title="Harandar Flowering Lamp", decorType="Misc Lighting", source={type="vendor", itemID=263039}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14965, title="Harandar Glowvine Sconce", decorType="Wall Lights", source={type="vendor", itemID=263194}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=14967, title="Harandar Glowvine Lamppost", decorType="Large Lights", source={type="vendor", itemID=263195}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15502, title="Rutaani Birdfeeder", decorType="Misc Nature", source={type="vendor", itemID=264267}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15503, title="Rutaani Birdbath", decorType="Miscellaneous - All", source={type="vendor", itemID=264268}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15504, title="Rutaani Bird Perch", decorType="Misc Nature", source={type="vendor", itemID=264269}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Thraxadar",
    source={
      id=258328,
      type="vendor",
      faction="Neutral",
      zone="Masters' Perch",
      worldmap="2444:3935:8095",
    },
    items={
      --       {decorID=3922, title="Galactic Void-Scarred Banner", decorType="Ornamental", source={type="vendor", itemID=247785}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15488, title="Galactic Void-Scarred Barricade", decorType="Ornamental", source={type="vendor", itemID=264253}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15585, title="Galactic Commander's Orb", decorType="Small Lights", source={type="vendor", itemID=264345}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Ando the Gat",
    source={
      id=235621,
      type="vendor",
      faction="Horde",
      zone="Liberation of Undermine",
      worldmap="2406:4329:5189",
    },
    items={
      {decorID=828, title="Well-Lit Incontinental Loveseat", decorType="Seating", source={type="vendor", itemID=239213, currency="900", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1121, title="Gallagio L.U.C.K. Spinner", decorType="Ornamental", source={type="vendor", itemID=245302, currency="750", currencytype="Resonance Crystals"}, requirements={achievement={id=41119, title="One Rank Higher"}, rep="true"}},
    }
  },
  {
    title="Apprentice Diell",
    source={
      id=242723,
      type="vendor",
      faction="Neutral",
      zone="Eversong Woods",
      worldmap="2395:4352:4752",
    },
    items={
      --       {decorID=14995, title="Gentle Floating Planter", decorType="Misc Nature", source={type="vendor", itemID=263224, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=15013, title="Sunlit Glass Mirror", decorType="Wall Hangings", source={type="vendor", itemID=263225, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Naleidea Rivergleam",
    source={
      id=242398,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:5276:7790",
    },
    items={
      --       {decorID=2503, title="Hanging Mana Brazier", decorType="Ceiling Lights", source={type="vendor", itemID=246779, currency="400", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=7780, title="Silvermoon Privacy Screen", decorType="Misc Furnishings", source={type="vendor", itemID=250770, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Rocco Razzboom",
    source={
      id=231406,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:3915:2220",
    },
    items={
      {decorID=1259, title="Spring-Powered Undermine Chair", decorType="Seating", source={type="vendor", itemID=245313, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10889, title="Incontinental Table Lamp", decorType="Small Lights", source={type="vendor", itemID=255674, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Thripps",
    source={
      id=218202,
      type="vendor",
      faction="Horde",
      zone="City of Threads",
      worldmap="2213:5000:3160",
    },
    items={
      {decorID=2532, title="Kaheti Scribe's Records", decorType="Ornamental", source={type="vendor", itemID=246866, currency="1500", currencytype="Kej"}, requirements={achievement={id=40542, title="Smelling History"}, rep="true"}},
    }
  },
  {
    title="Street Food Vendor",
    source={
      id=239333,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:2620:4280",
    },
    items={
      {decorID=11128, title="Leftover Undermine Takeout", decorType="Food and Drink", source={type="vendor", itemID=256328, currency="350", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Melaris",
    source={
      id=243359,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4704:5166",
    },
    items={
      --       {decorID=15402, title="Midnight Alchemist's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=263997}, requirements={achievement={id=42788, title="Alchemizing at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Eriden",
    source={
      id=241451,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4364:5147",
    },
    items={
      --       {decorID=15403, title="Midnight Blacksmith's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=263998}, requirements={achievement={id=42792, title="Blacksmithing at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Quelis",
    source={
      id=257914,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:5644:6991",
    },
    items={
      --       {decorID=15404, title="Midnight Cook's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=263999}, requirements={achievement={id=42795, title="Cooking at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Lyna",
    source={
      id=243350,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4792:5344",
    },
    items={
      --       {decorID=15405, title="Midnight Enchanter's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264000}, requirements={achievement={id=42787, title="Enchanting at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Yatheon",
    source={
      id=241453,
      type="vendor",
      faction="Neutral",
      zone="Silvermoon City",
      worldmap="2393:4347:5374",
    },
    items={
      --       {decorID=15406, title="Midnight Engineer's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264001}, requirements={achievement={id=42798, title="Engineering at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Mowaia",
    source={
      id=258507,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5228:5411",
    },
    items={
      --       {decorID=15407, title="Midnight Fisher's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264002}, requirements={achievement={id=42797, title="Fishing at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Amwa'ana",
    source={
      id=258480,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5241:5062",
    },
    items={
      --       {decorID=15410, title="Midnight Jewelcrafter's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264005}, requirements={achievement={id=42789, title="Jewelcrafting at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Zaralda",
    source={
      id=243531,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4304:5599",
    },
    items={
      --       {decorID=15411, title="Midnight Leatherworker's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264006}, requirements={achievement={id=42786, title="Leatherworking at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Hawli",
    source={
      id=258540,
      type="vendor",
      faction="Neutral",
      zone="Harandar",
      worldmap="2413:5274:5069",
    },
    items={
      --       {decorID=15457, title="Midnight Miner's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264172}, requirements={achievement={id=42791, title="Mining at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Lelorian",
    source={
      id=243555,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4667:5119",
    },
    items={
      --       {decorID=15409, title="Midnight Scribe's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264004}, requirements={achievement={id=42796, title="Inscribing at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Deynna",
    source={
      id=243353,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:4823:5431",
    },
    items={
      --       {decorID=15459, title="Midnight Tailor's Shop Sign", decorType="Wall Hangings", source={type="vendor", itemID=264174}, requirements={achievement={id=42794, title="Tailoring at Midnight"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Sitch Lowdown",
    source={
      id=231396,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:3078:3893",
    },
    items={
      {decorID=1268, title="Undermine Bookcase", decorType="Storage", source={type="vendor", itemID=245307, currency="800", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=11127, title="Open Rust-Plated Storage Crate", decorType="Storage", source={type="vendor", itemID=256327, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Construct Ali'a",
    source={
      id=258181,
      type="vendor",
      faction="Alliance",
      zone="Silvermoon City",
      worldmap="2393:5579:6605",
    },
    items={
      --       {decorID=17439, title="Preyseeker's Magister Effigy", decorType="Ornamental", source={type="vendor", itemID=265681}, requirements={achievement={id=62167, title="Prey: Mad Magisters (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17440, title="Preyseeker's Tinker Effigy", decorType="Ornamental", source={type="vendor", itemID=265682}, requirements={achievement={id=62168, title="Prey: Insane Inventors (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17441, title="Preyseeker's Ethereal Effigy", decorType="Ornamental", source={type="vendor", itemID=265683}, requirements={achievement={id=62173, title="Prey: Ethereal Assassins (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17442, title="Preyseeker's Breaker Effigy", decorType="Ornamental", source={type="vendor", itemID=265684}, requirements={achievement={id=62174, title="Prey: Anger Management (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17443, title="Preyseeker's Amani Effigy", decorType="Ornamental", source={type="vendor", itemID=265685}, requirements={achievement={id=62175, title="Prey: Sadistic Shamans (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17444, title="Preyseeker's Rutaani Effigy", decorType="Ornamental", source={type="vendor", itemID=265686}, requirements={achievement={id=62177, title="Prey: Bloody Green Thumbs (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17446, title="Preyseeker's Vindicator Effigy", decorType="Ornamental", source={type="vendor", itemID=265687}, requirements={achievement={id=62178, title="Prey: Blinded By The Light (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17447, title="Preyseeker's Consul Effigy", decorType="Ornamental", source={type="vendor", itemID=265688}, requirements={achievement={id=62179, title="Prey: Outsmarting the Schemers (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17449, title="Preyseeker's Executor Effigy", decorType="Ornamental", source={type="vendor", itemID=265689}, requirements={achievement={id=62180, title="Prey: Dominating the Void (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17450, title="Preyseeker's Knight-Errant Effigy", decorType="Ornamental", source={type="vendor", itemID=265690}, requirements={achievement={id=62181, title="Prey: Chasing Death (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17452, title="Preyseeker's Wretched Effigy", decorType="Ornamental", source={type="vendor", itemID=265691}, requirements={achievement={id=62182, title="Prey: No Rest for the Wretched (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17453, title="Preyseeker's Thornspeaker Effigy", decorType="Ornamental", source={type="vendor", itemID=265692}, requirements={achievement={id=62183, title="Prey: A Thorn in the Side (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17454, title="Preyseeker's Twilight Effigy", decorType="Ornamental", source={type="vendor", itemID=265694}, requirements={achievement={id=62184, title="Prey: Breaking the Blade (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17455, title="Preyseeker's Magister Bust", decorType="Ornamental", source={type="vendor", itemID=265696}, requirements={achievement={id=62144, title="Prey: Mad Magisters (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17456, title="Preyseeker's Tinker Bust", decorType="Ornamental", source={type="vendor", itemID=265697}, requirements={achievement={id=62153, title="Prey: Insane Inventors (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17457, title="Preyseeker's Ethereal Bust", decorType="Ornamental", source={type="vendor", itemID=265698}, requirements={achievement={id=62155, title="Prey: Ethereal Assassins (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17458, title="Preyseeker's Breaker Bust", decorType="Ornamental", source={type="vendor", itemID=265699}, requirements={achievement={id=62156, title="Prey: Anger Management (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17459, title="Preyseeker's Amani Bust", decorType="Ornamental", source={type="vendor", itemID=265700}, requirements={achievement={id=62157, title="Prey: Sadistic Shamans (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17460, title="Preyseeker's Rutaani Bust", decorType="Ornamental", source={type="vendor", itemID=265701}, requirements={achievement={id=62159, title="Prey: Bloody Green Thumbs (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17462, title="Preyseeker's Vindicator Bust", decorType="Ornamental", source={type="vendor", itemID=265702}, requirements={achievement={id=62160, title="Prey: Blinded By The Light (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17464, title="Preyseeker's Consul Bust", decorType="Ornamental", source={type="vendor", itemID=265703}, requirements={achievement={id=62161, title="Prey: Outsmarting the Schemers (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17465, title="Preyseeker's Executor Bust", decorType="Ornamental", source={type="vendor", itemID=265704}, requirements={achievement={id=62162, title="Prey: Dominating the Void (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17467, title="Preyseeker's Knight-Errant Bust", decorType="Ornamental", source={type="vendor", itemID=265705}, requirements={achievement={id=62163, title="Prey: Chasing Death (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17469, title="Preyseeker's Wretched Bust", decorType="Ornamental", source={type="vendor", itemID=265706}, requirements={achievement={id=62164, title="Prey: No Rest for the Wretched (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17472, title="Preyseeker's Thornspeaker Bust", decorType="Ornamental", source={type="vendor", itemID=265707}, requirements={achievement={id=62165, title="Prey: A Thorn in the Side (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17474, title="Preyseeker's Twilight Bust", decorType="Ornamental", source={type="vendor", itemID=265708}, requirements={achievement={id=62166, title="Prey: Breaking the Blade (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17518, title="Preyseeker's Plinth", decorType="Misc Furnishings", source={type="vendor", itemID=265794, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17519, title="Preyseeker's Ornate Plinth", decorType="Misc Furnishings", source={type="vendor", itemID=265795, currency="100", currencytype="Brimming Arcana"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17520, title="Preyseeker's Ren'dorei Effigy", decorType="Ornamental", source={type="vendor", itemID=265796}, requirements={achievement={id=62169, title="Prey: A Different Kind of Void (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17521, title="Preyseeker's Farstrider Effigy", decorType="Ornamental", source={type="vendor", itemID=265797}, requirements={achievement={id=62176, title="Prey: The Fallen Farstriders (Nightmare)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17522, title="Preyseeker's Ren'dorei Bust", decorType="Ornamental", source={type="vendor", itemID=265798}, requirements={achievement={id=62154, title="Prey: A Different Kind of Void (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=17523, title="Preyseeker's Farstrider Bust", decorType="Ornamental", source={type="vendor", itemID=265799}, requirements={achievement={id=62158, title="Prey: The Fallen Farstriders (Hard)"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Boatswain Hardee",
    source={
      id=231405,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:6343:1680",
    },
    items={
      {decorID=4560, title="Relaxing Goblin Beach Chair with Cup Gripper", decorType="Seating", source={type="vendor", itemID=248758, currency="900", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10853, title="Undermine Alleyway Sconce", decorType="Wall Lights", source={type="vendor", itemID=255642, currency="475", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Lab Assistant Laszly",
    source={
      id=231408,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:2718:7254",
    },
    items={
      {decorID=1265, title="Rust-Plated Storage Barrel", decorType="Storage", source={type="vendor", itemID=245321, currency="400", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10852, title="Undermine Mechanic's Hanging Lamp", decorType="Ceiling Lights", source={type="vendor", itemID=255641, currency="500", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Blair Bass",
    source={
      id=226994,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:3400:7080",
    },
    items={
      {decorID=1277, title="Rusty Patchwork Tub", decorType="Misc Furnishings", source={type="vendor", itemID=245309, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Shredz the Scrapper",
    source={
      id=231407,
      type="vendor",
      faction="Horde",
      zone="Undermine",
      worldmap="2346:5334:7269",
    },
    items={
      {decorID=1269, title="Undermine Wall Shelf", decorType="Storage", source={type="vendor", itemID=245311, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=10857, title="Spring-Powered Pointer", decorType="Ornamental", source={type="vendor", itemID=255647, currency="650", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Jorid",
    source={
      id=219318,
      type="vendor",
      faction="Horde",
      zone="Dornogal",
      worldmap="2339:5700:6060",
    },
    items={
      {decorID=2533, title="Tome of Earthen Directives", decorType="Ornamental", source={type="vendor", itemID=246867, currency="750", currencytype="Resonance Crystals"}, requirements={achievement={id=41186, title="Slate of the Union"}, rep="true"}},
    }
  },
  {
    title="Smaks Topskimmer",
    source={
      id=231409,
      type="vendor",
      faction="Neutral",
      zone="Undermine",
      worldmap="2346:4380:5080",
    },
    items={
      {decorID=1257, title="Undermine Round Table", decorType="Tables and Desks", source={type="vendor", itemID=245314, currency="850", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1258, title="Undermine Rectangular Table", decorType="Tables and Desks", source={type="vendor", itemID=243312, currency="900", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1262, title="Undermine Fencepost", decorType="Misc Structural", source={type="vendor", itemID=245319, currency="350", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1263, title="Undermine Fence", decorType="Misc Structural", source={type="vendor", itemID=245318, currency="450", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
}
