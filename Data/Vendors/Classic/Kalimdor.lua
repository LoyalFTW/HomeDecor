local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Classic"] = NS.Data.Vendors["Classic"] or {}

NS.Data.Vendors["Classic"]["Kalimdor"] = {
  {
    title="Hesta Forlath",
    source={
      id=252917,
      type="vendor",
      faction="Neutral",
      zone="Razorwind Shores",
      worldmap="2351:5436:5597",
    },
    items={
      --       {decorID=9419, title="Thalassian Chest", decorType="Storage", source={type="vendor", itemID=253522, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9420, title="Astalor's Hookah", decorType="Misc Accents", source={type="vendor", itemID=253523, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9421, title="590 Quel'Lithien Red Display Bottle", decorType="Food and Drink", source={type="vendor", itemID=253524, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9422, title="Thalassian Academy Dictation Device", decorType="Misc Accents", source={type="vendor", itemID=253525, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9423, title="Sin'dorei Wine Display", decorType="Misc Accents", source={type="vendor", itemID=253526, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9476, title="Artisanal Display Tent", decorType="Large Structures", source={type="vendor", itemID=253599, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9477, title="Eversong Crystal Glass", decorType="Food and Drink", source={type="vendor", itemID=253600, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=9478, title="590 Quel'Lithien Red", decorType="Food and Drink", source={type="vendor", itemID=253601, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10273, title="Sin'dorei Artisan's Easel", decorType="Misc Accents", source={type="vendor", itemID=254235, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Samantha Buckley",
    source={
      id=216888,
      type="vendor",
      faction="Alliance",
      zone="Ruins of Gilneas",
      worldmap="218:6199:3672",
    },
    items={
      {decorID=857, title="Gilnean Celebration Keg", decorType="Food and Drink", source={type="vendor", itemID=245520, currency="100", currencytype="Garrison Resources"}, requirements={achievement={id=19719, title="Reclamation of Gilneas"}, rep="true"}},
      {decorID=859, title="Gilnean Bench", decorType="Seating", source={type="vendor", itemID=245516, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=860, title="Gilnean Wooden Bed", decorType="Beds", source={type="vendor", itemID=245515, currency="550", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=1795, title="Arched Rose Trellis", decorType="Misc Nature", source={type="vendor", itemID=245604}, requirements={rep="true"}},
      {decorID=1826, title="Gilnean Stocks", decorType="Ornamental", source={type="vendor", itemID=245617}, requirements={rep="true"}},
      {decorID=11944, title="Gilnean Washing Line", decorType="Ornamental", source={type="vendor", itemID=258301}, requirements={rep="true"}},
    }
  },
  {
    title="\"Yen\" Malone",
    source={
      id=255319,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:4029:7300",
    },
    items={
      {decorID=520, title="Gift of Gilneas", decorType="Small Foliage", source={type="vendor", itemID=245369}, requirements={rep="true"}},
      {decorID=521, title="Charming Laurel Tree", decorType="Large Foliage", source={type="vendor", itemID=245371}, requirements={rep="true"}},
      {decorID=771, title="Small Poppy Cluster", decorType="Small Foliage", source={type="vendor", itemID=245329}, requirements={rep="true"}},
      {decorID=772, title="Creeping Corner Ivy", decorType="Small Foliage", source={type="vendor", itemID=245327}, requirements={rep="true"}},
      {decorID=773, title="Small Boxwood Bush", decorType="Bushes", source={type="vendor", itemID=245328, currency="250", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1864, title="Elwynn Cobblestone Round", decorType="Floor", source={type="vendor", itemID=245658}, requirements={rep="true"}},
      {decorID=1865, title="Elwynn Cobblestone", decorType="Floor", source={type="vendor", itemID=245659}, requirements={rep="true"}},
      {decorID=1866, title="Elwynn Cobblestone Pair", decorType="Floor", source={type="vendor", itemID=245660}, requirements={rep="true"}},
      {decorID=1867, title="Elwynn Cobblestone Cluster", decorType="Floor", source={type="vendor", itemID=245661}, requirements={rep="true"}},
      {decorID=4461, title="Elwynn Whitebrush", decorType="Bushes", source={type="vendor", itemID=248635}, requirements={rep="true"}},
      {decorID=4465, title="Gloomrose", decorType="Large Foliage", source={type="vendor", itemID=248639}, requirements={rep="true"}},
      {decorID=4466, title="Duskberry Bush", decorType="Bushes", source={type="vendor", itemID=248640}, requirements={rep="true"}},
      {decorID=4467, title="Duskwood Shadebrush", decorType="Bushes", source={type="vendor", itemID=248641}, requirements={rep="true"}},
      {decorID=4468, title="Creeping Lattice Ivy", decorType="Misc Nature", source={type="vendor", itemID=248642}, requirements={rep="true"}},
      {decorID=4469, title="Duskwood Sycamore Shrub", decorType="Bushes", source={type="vendor", itemID=248643}, requirements={rep="true"}},
      {decorID=4470, title="Spiritbloom Flower", decorType="Small Foliage", source={type="vendor", itemID=248644}, requirements={rep="true"}},
      {decorID=4471, title="Pink Gilnean Rose", decorType="Large Foliage", source={type="vendor", itemID=248645}, requirements={rep="true"}},
      {decorID=4472, title="Silvermoon Sunrise Bush", decorType="Bushes", source={type="vendor", itemID=248646}, requirements={rep="true"}},
      {decorID=4473, title="Founder's Point Blooming Grass Patch", decorType="Ground Cover", source={type="vendor", itemID=248647}, requirements={rep="true"}},
      {decorID=4474, title="Autumn Leaf Pile", decorType="Ground Cover", source={type="vendor", itemID=248648}, requirements={rep="true"}},
      {decorID=4475, title="Young Chestnut Tree", decorType="Large Foliage", source={type="vendor", itemID=248649}, requirements={rep="true"}},
      {decorID=4822, title="Elwynn Grass Patch", decorType="Ground Cover", source={type="vendor", itemID=248802}, requirements={rep="true"}},
      {decorID=4823, title="Elwynn Grass Spread", decorType="Ground Cover", source={type="vendor", itemID=248803}, requirements={rep="true"}},
      {decorID=4845, title="Elwynn Small Grass Patch", decorType="Ground Cover", source={type="vendor", itemID=248811}, requirements={rep="true"}},
      {decorID=10855, title="Elwynn Apple Tree", decorType="Large Foliage", source={type="vendor", itemID=255644}, requirements={rep="true"}},
      {decorID=10856, title="Founder's Point Apple Tree", decorType="Large Foliage", source={type="vendor", itemID=255646}, requirements={rep="true"}},
      {decorID=12189, title="Elwynn Autumn Apple Tree", decorType="Large Foliage", source={type="vendor", itemID=258658}, requirements={rep="true"}},
      {decorID=12190, title="Founder's Point Autumn Apple Tree", decorType="Large Foliage", source={type="vendor", itemID=258659}, requirements={rep="true"}},
      {decorID=17868, title="Outer Banks Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266239}, requirements={rep="true"}},
      {decorID=17869, title="Founder's Point Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266240}, requirements={rep="true"}},
      {decorID=17870, title="Brumewood Hollow Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266241}, requirements={rep="true"}},
      {decorID=17871, title="Gilded Oaks Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266242}, requirements={rep="true"}},
      {decorID=17872, title="Stoneveil Ridge Large Garden Cluster", decorType="Ground Cover", source={type="vendor", itemID=266243}, requirements={rep="true"}},
   
	}
  },
  {
    title="Botanist Boh'an",
    source={
      id=255301,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:5400:5840",
    },
    items={
      {decorID=4406, title="Round-Top Boulder", decorType="Miscellaneous - All", source={type="vendor", itemID=248337}, requirements={rep="true"}},
      {decorID=4407, title="Flat Boulder", decorType="Miscellaneous - All", source={type="vendor", itemID=248338}, requirements={rep="true"}},
      {decorID=4408, title="Hilltop Boulder", decorType="Miscellaneous - All", source={type="vendor", itemID=248339}, requirements={rep="true"}},
      {decorID=4451, title="Razorwind Succulent Palm", decorType="Large Foliage", source={type="vendor", itemID=248625}, requirements={rep="true"}},
      {decorID=4452, title="Razorwind Fighting Cactus", decorType="Large Foliage", source={type="vendor", itemID=248626}, requirements={rep="true"}},
      {decorID=4453, title="Razorwind Tumbleweed", decorType="Miscellaneous - All", source={type="vendor", itemID=248627}, requirements={rep="true"}},
      {decorID=4454, title="Razorwind Palm Tree", decorType="Large Foliage", source={type="vendor", itemID=248628}, requirements={rep="true"}},
      {decorID=4455, title="Nagrand Blueberry Bush", decorType="Bushes", source={type="vendor", itemID=248629, currency="250", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=17867, title="Cragthorn Highlands Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266238}, requirements={rep="true"}},
      {decorID=17865, title="Razorwind Blooms Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266236}, requirements={rep="true"}},
      {decorID=17864, title="Razorwind Cactus Large Garden Cluster", decorType="Ground Cover", source={type="vendor", itemID=266235}, requirements={rep="true"}},
      {decorID=4456, title="Barrens Hosta Bush", decorType="Bushes", source={type="vendor", itemID=248630}, requirements={rep="true"}},
      {decorID=4457, title="Azsharan Firespear Tree", decorType="Bushes", source={type="vendor", itemID=248631}, requirements={rep="true"}},
      {decorID=4458, title="Hardy Razorwind Grass Patch", decorType="Ground Cover", source={type="vendor", itemID=248632}, requirements={rep="true"}},
      {decorID=4459, title="Flowering Durotar Cactus", decorType="Large Foliage", source={type="vendor", itemID=248633}, requirements={rep="true"}},
      {decorID=4460, title="Razorwind Acacia Tree", decorType="Large Foliage", source={type="vendor", itemID=248634}, requirements={rep="true"}},
      {decorID=4462, title="Razorwind Gobtree", decorType="Bushes", source={type="vendor", itemID=248636}, requirements={rep="true"}},
      {decorID=4463, title="Sunset Aster Flowers", decorType="Small Foliage", source={type="vendor", itemID=248637}, requirements={rep="true"}},
      {decorID=17919, title="Granite Cobblestone Path", decorType="Floor", source={type="vendor", itemID=266444}, requirements={rep="true"}},
      {decorID=17874, title="Granite Cobblestone Path Arc", decorType="Floor", source={type="vendor", itemID=266245}, requirements={rep="true"}},
      {decorID=17918, title="Granite Cobblestone Long Path", decorType="Floor", source={type="vendor", itemID=266443}, requirements={rep="true"}},
      {decorID=17873, title="Granite Cobblestone Path Corner", decorType="Floor", source={type="vendor", itemID=266244}, requirements={rep="true"}},
      {decorID=4464, title="Pink Razorwind Paintbrush", decorType="Small Foliage", source={type="vendor", itemID=248638}, requirements={rep="true"}},
      {decorID=4476, title="Razorwind Flamebrush", decorType="Bushes", source={type="vendor", itemID=248650}, requirements={rep="true"}},
      {decorID=11461, title="Slate Cobblestone Pair", decorType="Floor", source={type="vendor", itemID=257359}, requirements={rep="true"}},
      {decorID=11479, title="Slate Cobblestone", decorType="Floor", source={type="vendor", itemID=257388}, requirements={rep="true"}},
      {decorID=11481, title="Slate Cobblestone Path", decorType="Floor", source={type="vendor", itemID=257390}, requirements={rep="true"}},
      {decorID=11482, title="Slate Cobblestone Trio", decorType="Floor", source={type="vendor", itemID=257392}, requirements={rep="true"}},
      {decorID=17863, title="Saltfang Shoals Large Garden Cluster", decorType="Bushes", source={type="vendor", itemID=266234}, requirements={rep="true"}},
      {decorID=14382, title="Red Razorwind Paintbrush", decorType="Ground Cover", source={type="vendor", itemID=260701}, requirements={rep="true"}},
      {decorID=14383, title="Dry Razorwind Grass Patch", decorType="Ground Cover", source={type="vendor", itemID=260702}, requirements={rep="true"}},
    }
  },
    {
    title="Paul North",
    source={
      id=68364,
      type="vendor",
      faction="Horde",
      zone="Brawl'gar Arena",
      worldmap="503:5200:2780",
    },
    items={
      {decorID=10913, title="Champion Brawler's Gloves", decorType="Uncategorized", source={type="vendor", itemID=255840, currency="1000", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=12263, title="Brawler's Guild Punching Bag", decorType="Misc Accents", source={type="vendor", itemID=259071, currency="750", currencytype="Honor"}, requirements={rep="true"}},
      {decorID=14815, title="Brawler's Barricade", decorType="Miscellaneous - All", source={type="vendor", itemID=263026, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
    }
  },
  {
    title="Stuart Fleming",
    source={
      id=3178,
      type="vendor",
      faction="Neutral",
      zone="Wetlands",
      worldmap="56:0627:5745",
    },
    items={
      {decorID=11495, title="Baradin Bay Fishing Rack", decorType="Storage", source={type="vendor", itemID=257405, currency="600", currencytype="Honor"}, requirements={rep="true"}},
    }
  },
  {
    title="Jehzar Starfall",
    source={
      id=255298,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:5356:5849",
    },
    items={
      {decorID=80, title="Ornate Stonework Fireplace", decorType="Large Lights", source={type="vendor", itemID=235994, currency="1000", currencytype="Order Resources"}, requirements={quest={id=93008, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=984, title="Elegant Padded Chair", decorType="Seating", source={type="vendor", itemID=241617}, requirements={quest={id=93143, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=985, title="Elegant Padded Footstool", decorType="Seating", source={type="vendor", itemID=241618}, requirements={quest={id=93000, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=987, title="Elegant Wooden Dresser", decorType="Storage", source={type="vendor", itemID=241620, currency="750", currencytype="Order Resources"}, requirements={quest={id=93150, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=988, title="Small Elegant End Table", decorType="Tables and Desks", source={type="vendor", itemID=241621, currency="200", currencytype="Order Resources"}, requirements={quest={id=93152, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=989, title="Ornate Weapon Rack", decorType="Storage", source={type="vendor", itemID=241622, currency="300", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=994, title="Grand Elven Bookcase", decorType="Storage", source={type="vendor", itemID=253441, currency="500", currencytype="Order Resources"}, requirements={quest={id=93005, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1153, title="Small Elegant Padded Chair", decorType="Seating", source={type="vendor", itemID=253479}, requirements={quest={id=93006, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1162, title="Elegant Elven Desk", decorType="Uncategorized", source={type="vendor", itemID=253490, currency="300", currencytype="Order Resources"}, requirements={quest={id=93002, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1163, title="Carved Elven Bookcase", decorType="Storage", source={type="vendor", itemID=253493, currency="500", currencytype="Order Resources"}, requirements={quest={id=93147, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1245, title="Circular Elven Floor Rug", decorType="Floor", source={type="vendor", itemID=243242, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1246, title="Rectangular Elven Floor Rug", decorType="Floor", source={type="vendor", itemID=243243, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1329, title="Elegant Padded Divan", decorType="Seating", source={type="vendor", itemID=243495}, requirements={quest={id=93149, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1487, title="Elegant Wall Drape", decorType="Ornamental", source={type="vendor", itemID=244781, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1770, title="Bel'ameth Interior Wall", decorType="Walls and Columns", source={type="vendor", itemID=245575, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92994, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1771, title="Bel'ameth Round Interior Pillar", decorType="Walls and Columns", source={type="vendor", itemID=245576, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92993, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1772, title="Bel'ameth Interior Doorway", decorType="Walls and Columns", source={type="vendor", itemID=245578, currency="500", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92992, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1773, title="Bel'ameth Interior Narrow Wall", decorType="Walls and Columns", source={type="vendor", itemID=245579, currency="500", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1774, title="Silvermoon Round Interior Pillar", decorType="Walls and Columns", source={type="vendor", itemID=245581}, requirements={quest={id=93135, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1775, title="Silvermoon Interior Narrow Wall", decorType="Walls and Columns", source={type="vendor", itemID=245582}, requirements={rep="true"}},
      {decorID=1776, title="Silvermoon Interior Wall", decorType="Walls and Columns", source={type="vendor", itemID=245583}, requirements={quest={id=93136, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1844, title="Silvermoon Interior Doorway", decorType="Walls and Columns", source={type="vendor", itemID=245649}, requirements={quest={id=93137, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2104, title="Silvermoon Beam Platform", decorType="Walls and Columns", source={type="vendor", itemID=246249}, requirements={quest={id=93140, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2105, title="Silvermoon Large Platform", decorType="Walls and Columns", source={type="vendor", itemID=246250}, requirements={quest={id=93138, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2106, title="Silvermoon Small Platform", decorType="Walls and Columns", source={type="vendor", itemID=246251}, requirements={rep="true"}},
      {decorID=2107, title="Silvermoon Angled Platform", decorType="Walls and Columns", source={type="vendor", itemID=246252}, requirements={rep="true"}},
      {decorID=2108, title="Silvermoon Round Platform", decorType="Walls and Columns", source={type="vendor", itemID=246253}, requirements={quest={id=93139, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2109, title="Bel'ameth Beam Platform", decorType="Walls and Columns", source={type="vendor", itemID=246254}, requirements={quest={id=92991, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2110, title="Bel'ameth Large Platform", decorType="Walls and Columns", source={type="vendor", itemID=246255}, requirements={quest={id=93009, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2111, title="Bel'ameth Small Platform", decorType="Walls and Columns", source={type="vendor", itemID=246256, currency="350", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2112, title="Bel'ameth Angled Platform", decorType="Walls and Columns", source={type="vendor", itemID=246257, currency="350", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2113, title="Bel'ameth Round Platform", decorType="Walls and Columns", source={type="vendor", itemID=246258}, requirements={quest={id=92990, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2254, title="Elegant Tied Curtain", decorType="Ornamental", source={type="vendor", itemID=246431, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2458, title="Grand Elven Wall Curtain", decorType="Ornamental", source={type="vendor", itemID=246691, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2474, title="Elegant Pillow Roll", decorType="Ornamental", source={type="vendor", itemID=246711, currency="750", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2590, title="Elegant Seat Cushion", decorType="Ornamental", source={type="vendor", itemID=246961, currency="750", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=3826, title="Elegant Carved Door", decorType="Doors", source={type="vendor", itemID=247501}, requirements={rep="true"}},
      {decorID=4562, title="Lovely Elven Shelf", decorType="Storage", source={type="vendor", itemID=248760, currency="75", currencytype="Order Resources"}, requirements={quest={id=93134, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=5563, title="Elven Standing Mirror", decorType="Ornamental", source={type="vendor", itemID=249558, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=8917, title="Elegant Elven Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=251981}, requirements={quest={id=93141, title="Decor Treasure Hunt"}, rep="true"}},
      --       {decorID=8918, title="Gilded Silvermoon Candelabra", decorType="Large Lights", source={type="vendor", itemID=251982, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      {decorID=9254, title="Elegant Elven Canopy Bed", decorType="Beds", source={type="vendor", itemID=253180, currency="1200", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=9255, title="Gemmed Elven Chest", decorType="Storage", source={type="vendor", itemID=253181, currency="500", currencytype="Order Resources"}, requirements={quest={id=93007, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=10860, title="Elegant Table Lamp", decorType="Small Lights", source={type="vendor", itemID=255650, currency="10", currencytype="Dragon Isles Supplies"}, requirements={quest={id=92995, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=11719, title="Elegant Padded Chaise", decorType="Seating", source={type="vendor", itemID=257690}, requirements={quest={id=93003, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=15454, title="Homestone Doormat", decorType="Floor", source={type="vendor", itemID=264169}, requirements={rep="true"}},
    }
  },
  {
    title="Joruh",
    source={
      id=254606,
      type="vendor",
      faction="Horde",
      zone="Orgrimmar",
      worldmap="85:3879:7193",
    },
    items={
      {decorID=3867, title="Iron Dragonmaw Gate", decorType="Doors", source={type="vendor", itemID=247727, currency="5000", currencytype="Honor"}, requirements={achievement={id=5223, title="Master of Twin Peaks"}, rep="true"}},
      {decorID=3880, title="Kotmogu Pedestal", decorType="Ornamental", source={type="vendor", itemID=247740, currency="2000", currencytype="Honor"}, requirements={achievement={id=6981, title="Master of Temple of Kotmogu"}, rep="true"}},
      {decorID=3881, title="Kotmogu Orb of Power", decorType="Uncategorized", source={type="vendor", itemID=247741, currency="1000", currencytype="Honor"}, requirements={achievement={id=6981, title="Master of Temple of Kotmogu"}, rep="true"}},
      {decorID=3885, title="Horde Dueling Flag", decorType="Ornamental", source={type="vendor", itemID=247745, currency="1000", currencytype="Honor"}, requirements={achievement={id=229, title="The Grim Reaper"}, rep="true"}},
      {decorID=3887, title="Warsong Outriders Flag", decorType="Ornamental", source={type="vendor", itemID=247747, currency="800", currencytype="Honor"}, requirements={achievement={id=167, title="Warsong Gulch Veteran"}, rep="true"}},
      {decorID=3890, title="Deephaul Crystal", decorType="Ornamental", source={type="vendor", itemID=247750, currency="2500", currencytype="Honor"}, requirements={achievement={id=40612, title="Sprinting in the Ravine"}, rep="true"}},
      {decorID=3893, title="Challenger's Dueling Flag", decorType="Ornamental", source={type="vendor", itemID=247756, currency="1000", currencytype="Honor"}, requirements={achievement={id=1157, title="Duel-icious"}, rep="true"}},
      {decorID=3896, title="Horde Battlefield Banner", decorType="Ornamental", source={type="vendor", itemID=247759, currency="600", currencytype="Honor"}, requirements={achievement={id=1153, title="Overly Defensive"}, rep="true"}},
      {decorID=3897, title="Fortified Horde Banner", decorType="Ornamental", source={type="vendor", itemID=247760, currency="1200", currencytype="Honor"}, requirements={achievement={id=222, title="Tower Defense"}, rep="true"}},
      {decorID=3898, title="Uncontested Battlefield Banner", decorType="Ornamental", source={type="vendor", itemID=247761, currency="400", currencytype="Honor"}, requirements={achievement={id=212, title="Storm Capper"}, rep="true"}},
      {decorID=3899, title="Netherstorm Battlefield Flag", decorType="Ornamental", source={type="vendor", itemID=247762, currency="300", currencytype="Honor"}, requirements={achievement={id=213, title="Stormtrooper"}, rep="true"}},
      {decorID=3900, title="Berserker's Empowerment", decorType="Ornamental", source={type="vendor", itemID=247763, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61683, title="Entering Battle"}, rep="true"}},
      {decorID=3902, title="Healer's Empowerment", decorType="Ornamental", source={type="vendor", itemID=247765, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61687, title="Champion in Battle"}, rep="true"}},
      {decorID=3903, title="Runner's Empowerment", decorType="Ornamental", source={type="vendor", itemID=247766, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61688, title="Master in Battle"}, rep="true"}},
      {decorID=3905, title="Guardian's Empowerment", decorType="Ornamental", source={type="vendor", itemID=247768, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=61684, title="Progressing in Battle"}, rep="true"}},
      {decorID=3906, title="Chaotic Empowerment", decorType="Ornamental", source={type="vendor", itemID=247769, currency="1200", currencytype="Resonance Crystals"}, requirements={achievement={id=61685, title="Proficient in Battle"}, rep="true"}},
      {decorID=3907, title="Mysterious Empowerment", decorType="Ornamental", source={type="vendor", itemID=247770, currency="1000", currencytype="Honor"}, requirements={achievement={id=61686, title="Expert in Battle"}, rep="true"}},
      {decorID=9244, title="Earthen Contender's Target", decorType="Misc Accents", source={type="vendor", itemID=253170, currency="750", currencytype="Honor"}, requirements={achievement={id=40210, title="Deephaul Ravine Victory"}, rep="true"}},
      {decorID=11296, title="Smoke Lamppost", decorType="Large Lights", source={type="vendor", itemID=256896, currency="450", currencytype="Honor"}, requirements={achievement={id=5245, title="Battle for Gilneas Victory"}, rep="true"}},
    }
  },
  {
    title="Pascal-K1N6",
    source={
      id=248525,
      type="vendor",
      faction="Neutral",
      zone="Razorwind Shores",
      worldmap="2351:5413:5598",
    },
    items={
      --       {decorID=10339, title="Triple-Tested Steam Valve", decorType="Ornamental", source={type="vendor", itemID=254400, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10340, title="Mad Science Blueprints", decorType="Ornamental", source={type="vendor", itemID=254401, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10341, title="Safety Electrical Cabling", decorType="Miscellaneous - All", source={type="vendor", itemID=254402, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10342, title="Mechagon Control Console", decorType="Ornamental", source={type="vendor", itemID=254403, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10343, title="Sticky Lever", decorType="Uncategorized", source={type="vendor", itemID=254404}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10344, title="Dual-Action Turbo Pro Lever", decorType="Uncategorized", source={type="vendor", itemID=254405}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10345, title="Mechanical Gauge", decorType="Uncategorized", source={type="vendor", itemID=254406}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10346, title="Dual Mechanical Gauge", decorType="Ornamental", source={type="vendor", itemID=254407, currency="150", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10347, title="Lively Pistons", decorType="Uncategorized", source={type="vendor", itemID=254408}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10348, title="Sturdy Drive Belt", decorType="Ornamental", source={type="vendor", itemID=254409, currency="150", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10349, title="Blue-Glo Lantern", decorType="Small Lights", source={type="vendor", itemID=254410, currency="150", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10350, title="Z-205 Mechanical Device", decorType="Ornamental", source={type="vendor", itemID=254411, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10351, title="Well-Oiled Machine Cog", decorType="Ornamental", source={type="vendor", itemID=254412, currency="150", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10352, title="Jury-Rigged Electrical Couple", decorType="Ornamental", source={type="vendor", itemID=254413, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10354, title="Miniature Charging Station", decorType="Large Lights", source={type="vendor", itemID=254415, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10355, title="Galvanic Storage and Maintenance Device", decorType="Large Lights", source={type="vendor", itemID=254416, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=10537, title="Ineffective Mechanical Privacy Screen", decorType="Misc Furnishings", source={type="vendor", itemID=254766}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="\"Len\" Splinthoof",
    source={
      id=255326,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:3990:7330",
    },
    items={
      {decorID=479, title="Empty Stormwind Market Stand", decorType="Large Structures", source={type="vendor", itemID=245365}, requirements={rep="true"}},
      {decorID=480, title="Stormwind Bean Seller's Stand", decorType="Large Structures", source={type="vendor", itemID=245366}, requirements={rep="true"}},
      {decorID=481, title="Stormwind Spice Merchant's Stand", decorType="Miscellaneous - All", source={type="vendor", itemID=245368}, requirements={rep="true"}},
      {decorID=482, title="Gryphon Roost", decorType="Miscellaneous - All", source={type="vendor", itemID=245357}, requirements={rep="true"}},
      {decorID=485, title="Open-Air Sturdy Tent", decorType="Large Structures", source={type="vendor", itemID=245377}, requirements={rep="true"}},
      {decorID=486, title="Sturdy Sheltering Tent", decorType="Large Structures", source={type="vendor", itemID=245378}, requirements={rep="true"}},
      {decorID=487, title="Small Stonework Fountain", decorType="Large Structures", source={type="vendor", itemID=245360, currency="500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=488, title="Large Stonework Fountain", decorType="Large Structures", source={type="vendor", itemID=245359, currency="2000", currencytype="Apexis Crystal"}, requirements={rep="true"}},
      {decorID=489, title="Sturdy Roofed Wagon", decorType="Miscellaneous - All", source={type="vendor", itemID=245379}, requirements={rep="true"}},
      {decorID=490, title="Sturdy Open Wagon", decorType="Miscellaneous - All", source={type="vendor", itemID=245380}, requirements={rep="true"}},
      {decorID=491, title="Sturdy Covered Wagon", decorType="Miscellaneous - All", source={type="vendor", itemID=245382}, requirements={rep="true"}},
      {decorID=492, title="Well-Built Well", decorType="Large Structures", source={type="vendor", itemID=245385, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=493, title="Sturdy Wooden Wheelbarrow", decorType="Miscellaneous - All", source={type="vendor", itemID=245386}, requirements={rep="true"}},
      {decorID=494, title="Sturdy Wooden Chair", decorType="Seating", source={type="vendor", itemID=235523, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=92965, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=496, title="Covered Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=245372}, requirements={quest={id=92983, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=497, title="Sturdy Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=245374}, requirements={rep="true"}},
      {decorID=770, title="Stormwind Produce Seller's Stand", decorType="Miscellaneous - All", source={type="vendor", itemID=245367}, requirements={rep="true"}},
      {decorID=1122, title="Sturdy Wooden Bench", decorType="Seating", source={type="vendor", itemID=242951}, requirements={quest={id=92969, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1280, title="Reinforced Wooden Chest", decorType="Storage", source={type="vendor", itemID=243334}, requirements={quest={id=92978, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1457, title="Restful Wooden Bench", decorType="Seating", source={type="vendor", itemID=244667, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1742, title="Worker's Wooden Desk", decorType="Tables and Desks", source={type="vendor", itemID=245551, currency="300", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1862, title="Wooden Gazebo", decorType="Large Structures", source={type="vendor", itemID=245656}, requirements={rep="true"}},
      {decorID=1863, title="Stonework Fountain", decorType="Large Structures", source={type="vendor", itemID=245657, currency="500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1878, title="Carved Wooden Bar Table", decorType="Tables and Desks", source={type="vendor", itemID=245662}, requirements={quest={id=92999, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1992, title="Large Covered Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=246102}, requirements={quest={id=92998, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1994, title="Carved Wooden Crate", decorType="Storage", source={type="vendor", itemID=246104}, requirements={quest={id=92971, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1995, title="Sturdy Weapon Rack", decorType="Storage", source={type="vendor", itemID=246105}, requirements={rep="true"}},
      {decorID=1996, title="Wooden Chamberstick", decorType="Small Lights", source={type="vendor", itemID=246106, currency="350", currencytype="Order Resources"}, requirements={quest={id=92985, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1997, title="Large Sturdy Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=246107}, requirements={quest={id=92997, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1999, title="Open Carved Wooden Crate", decorType="Storage", source={type="vendor", itemID=246109}, requirements={rep="true"}},
      {decorID=2089, title="Weather-Treated Wooden Table", decorType="Tables and Desks", source={type="vendor", itemID=246219}, requirements={rep="true"}},
      {decorID=2385, title="Sturdy Wooden Trellis", decorType="Misc Structural", source={type="vendor", itemID=246588}, requirements={rep="true"}},
      {decorID=2496, title="Tall Sturdy Wooden Chair", decorType="Seating", source={type="vendor", itemID=246742}, requirements={quest={id=92970, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=9472, title="Coal-Fired Stovetop", decorType="Uncategorized", source={type="vendor", itemID=253590}, requirements={rep="true"}},
      {decorID=14814, title="Sturdy Wine Press", decorType="Storage", source={type="vendor", itemID=263025, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Lonomia",
    source={
      id=240465,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:6829:7550",
    },
    items={
      {decorID=721, title="Ceiling Cobweb", decorType="Misc Accents", source={type="vendor", itemID=245400, currency="300", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=722, title="Tented Cobweb", decorType="Misc Accents", source={type="vendor", itemID=245401, currency="300", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=723, title="Small Dangling Cobweb", decorType="Misc Accents", source={type="vendor", itemID=245402, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=724, title="Large Dangling Cobweb", decorType="Misc Accents", source={type="vendor", itemID=245403, currency="300", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=725, title="Pillar Cobweb", decorType="Misc Accents", source={type="vendor", itemID=245404, currency="200", currencytype="War Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Brother Dovetail",
    source={
      id=249684,
      type="vendor",
      faction="Neutral",
      zone="Razorwind Shores",
      worldmap="2351:5436:5612",
    },
    items={
      --       {decorID=2453, title="Grummle Sleeping Bag", decorType="Beds", source={type="vendor", itemID=246686, currency="700", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2495, title="Grummle Bedroll", decorType="Beds", source={type="vendor", itemID=246741, currency="550", currencytype="War Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=2510, title="Kafa Press", decorType="Food and Drink", source={type="vendor", itemID=246838}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=4424, title="Grummle Kafa Refinery", decorType="Miscellaneous - All", source={type="vendor", itemID=248402}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=4425, title="Grummle Tent", decorType="Large Structures", source={type="vendor", itemID=248403, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=4427, title="Kafa Creamer", decorType="Food and Drink", source={type="vendor", itemID=248405, currency="500", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=4428, title="Legerdemain Lounge Sign Board", decorType="Ornamental", source={type="vendor", itemID=248406, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=4429, title="Dalaran Kafa Table", decorType="Tables and Desks", source={type="vendor", itemID=248407, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8179, title="Pandaren Wooden Cart", decorType="Ornamental", source={type="vendor", itemID=251472}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8180, title="Commander's Kafa Mug", decorType="Food and Drink", source={type="vendor", itemID=251473, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8181, title="Ceramic Kafa Mug", decorType="Food and Drink", source={type="vendor", itemID=251474, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8182, title="Dalaran Kafa Grinder", decorType="Food and Drink", source={type="vendor", itemID=251475}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8987, title="Open Sack of Roasted Kafa", decorType="Food and Drink", source={type="vendor", itemID=252039, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8988, title="Sealed Sack of Roasted Kafa", decorType="Food and Drink", source={type="vendor", itemID=252040, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=8989, title="Dalaran Espresso Machine", decorType="Food and Drink", source={type="vendor", itemID=252041, currency="1000", currencytype="Apexis Crystal"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Lefton Farrer",
    source={
      id=255299,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:5348:5853",
    },
    items={
      {decorID=986, title="Elegant Covered Bench", decorType="Seating", source={type="vendor", itemID=253437, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      --       {decorID=990, title="Elegant Elven Barrel", decorType="Storage", source={type="vendor", itemID=241623}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      {decorID=991, title="Elegant Carved Bench", decorType="Seating", source={type="vendor", itemID=253439, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      --       {decorID=992, title="Open Elven Wood Crate", decorType="Storage", source={type="vendor", itemID=241625}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      {decorID=1155, title="Standing Ornate Weapon Rack", decorType="Storage", source={type="vendor", itemID=243088, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1165, title="Grand Elven Bench", decorType="Seating", source={type="vendor", itemID=253495, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1350, title="Rectangular Elegant Table", decorType="Tables and Desks", source={type="vendor", itemID=244118, currency="350", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=1356, title="Elegant Almond Table", decorType="Tables and Desks", source={type="vendor", itemID=244169, currency="350", currencytype="Dragon Isles Supplies"}, requirements={quest={id=93148, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1486, title="Circular Elven Table", decorType="Tables and Desks", source={type="vendor", itemID=244780, currency="175", currencytype="Order Resources"}, requirements={quest={id=93004, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1488, title="Elven Floral Window", decorType="Windows", source={type="vendor", itemID=244782, currency="175", currencytype="Order Resources"}, requirements={quest={id=93001, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=3827, title="Elven Woodvine Trellis", decorType="Misc Nature", source={type="vendor", itemID=247502}, requirements={rep="true"}},
      {decorID=4484, title="Elven Wood Crate", decorType="Storage", source={type="vendor", itemID=248658}, requirements={rep="true"}},
      {decorID=11720, title="Open Elegant Elven Barrel", decorType="Storage", source={type="vendor", itemID=257691}, requirements={quest={id=93142, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=11721, title="Elegant Curved Table", decorType="Tables and Desks", source={type="vendor", itemID=257692, currency="400", currencytype="Order Resources"}, requirements={quest={id=93151, title="Decor Treasure Hunt"}, rep="true"}},
    }
  },
  {
    title="Gronthul",
    source={
      id=255278,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:5412:5911",
    },
    items={
      {decorID=81, title="Tusked Fireplace", decorType="Large Lights", source={type="vendor", itemID=245398}, requirements={quest={id=93110, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=522, title="Orgrimmar Interior Narrow Wall", decorType="Walls and Columns", source={type="vendor", itemID=236653}, requirements={rep="true"}},
      {decorID=523, title="Orgrimmar Interior Doorway", decorType="Walls and Columns", source={type="vendor", itemID=236654}, requirements={quest={id=93073, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=524, title="Orgrimmar Interior Wall", decorType="Walls and Columns", source={type="vendor", itemID=236655}, requirements={quest={id=93074, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=525, title="Orgrimmar Round Interior Pillar", decorType="Walls and Columns", source={type="vendor", itemID=236666}, requirements={quest={id=93075, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=526, title="Orgrimmar Square Interior Pillar", decorType="Walls and Columns", source={type="vendor", itemID=236667}, requirements={rep="true"}},
      {decorID=534, title="Plain Interior Wall", decorType="Walls and Columns", source={type="vendor", itemID=245393}, requirements={rep="true"}},
      {decorID=535, title="Plain Interior Doorway", decorType="Walls and Columns", source={type="vendor", itemID=245394}, requirements={rep="true"}},
      {decorID=536, title="Plain Interior Narrow Wall", decorType="Walls and Columns", source={type="vendor", itemID=245395}, requirements={rep="true"}},
      {decorID=1437, title="Iron Chain Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=244533}, requirements={quest={id=93078, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1438, title="Iron-Reinforced Door", decorType="Doors", source={type="vendor", itemID=244534, currency="5000", currencytype="Honor"}, requirements={quest={id=93079, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1451, title="Tied-Open Leather Curtains", decorType="Wall Hangings", source={type="vendor", itemID=244661, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1452, title="Closed Leather Curtains", decorType="Wall Hangings", source={type="vendor", itemID=244662, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1453, title="Leather Valance", decorType="Wall Hangings", source={type="vendor", itemID=244663, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1698, title="Round Stitched Cushion", decorType="Seating", source={type="vendor", itemID=245264, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=1699, title="Stitched Pillow Roll", decorType="Seating", source={type="vendor", itemID=245265}, requirements={rep="true"}},
      {decorID=1700, title="Iron-Studded Wooden Window", decorType="Windows", source={type="vendor", itemID=245266, currency="175", currencytype="Order Resources"}, requirements={quest={id=93080, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1723, title="Orgrimmar Chair", decorType="Seating", source={type="vendor", itemID=245532, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93081, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1736, title="Orgrimmar Nightstand", decorType="Tables and Desks", source={type="vendor", itemID=245545, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=93083, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1744, title="Orgrimmar Tusked Bed", decorType="Beds", source={type="vendor", itemID=245555, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=93111, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1879, title="Orgrimmar Bureaucrat's Desk", decorType="Tables and Desks", source={type="vendor", itemID=245680, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=93109, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1977, title="High-Backed Orgrimmar Chair", decorType="Seating", source={type="vendor", itemID=246036, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93091, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1978, title="Iron-Reinforced Wooden Rack", decorType="Storage", source={type="vendor", itemID=246037}, requirements={rep="true"}},
      {decorID=1979, title="Stitched Leather Rug", decorType="Floor", source={type="vendor", itemID=246038, currency="250", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=2092, title="Cozy Hide-Covered Bench", decorType="Seating", source={type="vendor", itemID=246223}, requirements={rep="true"}},
      {decorID=2093, title="Large Orgrimmar Bookcase", decorType="Storage", source={type="vendor", itemID=246224, currency="500", currencytype="Garrison Resources"}, requirements={quest={id=93099, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2094, title="Small Leather Rug", decorType="Floor", source={type="vendor", itemID=246225, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=2114, title="Orgrimmar Beam Platform", decorType="Walls and Columns", source={type="vendor", itemID=246259}, requirements={quest={id=93085, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2115, title="Orgrimmar Round Platform", decorType="Walls and Columns", source={type="vendor", itemID=246260}, requirements={quest={id=93087, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2116, title="Orgrimmar Large Platform", decorType="Walls and Columns", source={type="vendor", itemID=246261}, requirements={quest={id=93088, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2117, title="Orgrimmar Small Platform", decorType="Walls and Columns", source={type="vendor", itemID=246262}, requirements={rep="true"}},
      {decorID=2118, title="Orgrimmar Angled Platform", decorType="Walls and Columns", source={type="vendor", itemID=246263}, requirements={rep="true"}},
      {decorID=2384, title="Short Orgrimmar Bookcase", decorType="Storage", source={type="vendor", itemID=246587, currency="500", currencytype="Garrison Resources"}, requirements={quest={id=93100, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2439, title="Durable Hex Table", decorType="Tables and Desks", source={type="vendor", itemID=246607, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2440, title="Long Leather-Clad Table", decorType="Tables and Desks", source={type="vendor", itemID=246608, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2441, title="Orgrimmar Open Dresser", decorType="Storage", source={type="vendor", itemID=246609, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2442, title="Razorwind Standing Mirror", decorType="Misc Furnishings", source={type="vendor", itemID=246610, currency="250", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2445, title="Long Durable Table", decorType="Tables and Desks", source={type="vendor", itemID=246613, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2446, title="Razorwind Bar Table", decorType="Tables and Desks", source={type="vendor", itemID=246614, currency="1500", currencytype="Garrison Resources"}, requirements={quest={id=93115, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2454, title="Tusked Candleholder", decorType="Small Lights", source={type="vendor", itemID=246687, currency="300", currencytype="War Resources"}, requirements={quest={id=93101, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2535, title="Razorwind Wall Mirror", decorType="Wall Hangings", source={type="vendor", itemID=246869, currency="1000", currencytype="Order Resources"}, requirements={quest={id=93132, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2545, title="Tusked Hanging Sconce", decorType="Wall Lights", source={type="vendor", itemID=246879, currency="150", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=2592, title="Small Orgrimmar Chair", decorType="Seating", source={type="vendor", itemID=247221, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93106, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=4386, title="Razorwind Storage Table", decorType="Tables and Desks", source={type="vendor", itemID=248246, currency="300", currencytype="Garrison Resources"}, requirements={quest={id=93107, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=5853, title="Tusked Weapon Rack", decorType="Uncategorized", source={type="vendor", itemID=250093}, requirements={rep="true"}},
      {decorID=5854, title="Empty Orgrimmar Bathtub", decorType="Misc Furnishings", source={type="vendor", itemID=250094}, requirements={rep="true"}},
      {decorID=7836, title="Small Razorwind Bar Table", decorType="Tables and Desks", source={type="vendor", itemID=250913, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=7842, title="Horned Hanging Sconce", decorType="Wall Lights", source={type="vendor", itemID=250920, currency="150", currencytype="Dragon Isles Supplies"}, requirements={quest={id=93102, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=8771, title="Hide-Covered Bench", decorType="Seating", source={type="vendor", itemID=251639}, requirements={rep="true"}},
      {decorID=8907, title="Hide-Covered Wall Shelf", decorType="Storage", source={type="vendor", itemID=251973, currency="500", currencytype="Order Resources"}, requirements={quest={id=93108, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=8910, title="Tusked Chandelier", decorType="Ceiling Lights", source={type="vendor", itemID=251974}, requirements={rep="true"}},
      {decorID=8911, title="Tusked Sconce", decorType="Wall Lights", source={type="vendor", itemID=251975, currency="150", currencytype="Dragon Isles Supplies"}, requirements={rep="true"}},
      {decorID=8912, title="Wolf Pelt Rug", decorType="Uncategorized", source={type="vendor", itemID=251976}, requirements={rep="true"}},
      {decorID=9143, title="Tied-Right Leather Curtains", decorType="Wall Hangings", source={type="vendor", itemID=252657, currency="150", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=10324, title="Small Orgrimmar Tusked Bed", decorType="Beds", source={type="vendor", itemID=254316, currency="550", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=10367, title="Small Razorwind Square Table", decorType="Tables and Desks", source={type="vendor", itemID=254560, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=10952, title="Razorwind Shores Front Door", decorType="Doors", source={type="vendor", itemID=256050, currency="5000", currencytype="Honor"}, requirements={rep="true"}},
      {decorID=11480, title="Iron-Reinforced Wooden Window", decorType="Windows", source={type="vendor", itemID=257389, currency="175", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=11874, title="Orgrimmar Bathtub", decorType="Miscellaneous - All", source={type="vendor", itemID=258148}, requirements={rep="true"}},
    }
  },
  {
    title="Hordranin",
    source={
      id=250820,
      type="vendor",
      faction="Neutral",
      zone="Razorwind Shores",
      worldmap="2351:5420:5620",
    },
    items={
      {decorID=7668, title="Forbidden Fork", decorType="Ornamental", source={type="vendor", itemID=250627, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7691, title="Draconic Metalshaper's Anvil", decorType="Ornamental", source={type="vendor", itemID=250694, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7692, title="Replica Grathardormu's Hammer", decorType="Wall Hangings", source={type="vendor", itemID=250695, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7693, title="Green Thumb's Watering Can", decorType="Ornamental", source={type="vendor", itemID=250696, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7694, title="Draconic Auctioneer's Lectern", decorType="Tables and Desks", source={type="vendor", itemID=250697, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7695, title="Obsidian Warder Pennant", decorType="Wall Hangings", source={type="vendor", itemID=250698, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7696, title="Dark Talon Pennant", decorType="Wall Hangings", source={type="vendor", itemID=250699, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7697, title="Roasted Ram Leg", decorType="Food and Drink", source={type="vendor", itemID=250700, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7698, title="Draconic Trader's Cart", decorType="Miscellaneous - All", source={type="vendor", itemID=250701, currency="20", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7699, title="Artisan's Measuring Scales", decorType="Ornamental", source={type="vendor", itemID=250702, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7700, title="War Creche Teaching Crystal", decorType="Ornamental", source={type="vendor", itemID=250703, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=7701, title="Ancient Weyrn Device", decorType="Misc Functional", source={type="vendor", itemID=250704, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}},
    }
  },
  {
    title="Shon'ja",
    source={
      id=255297,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:5413:5905",
    },
    items={
      {decorID=1436, title="Rugged Stool", decorType="Seating", source={type="vendor", itemID=244532, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93077, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1439, title="Tusked Gazebo", decorType="Large Structures", source={type="vendor", itemID=244535, currency="900", currencytype="Resonance Crystals"}, requirements={rep="true"}},
      {decorID=1724, title="Rugged Brazier", decorType="Large Lights", source={type="vendor", itemID=245533, currency="600", currencytype="Resonance Crystals"}, requirements={quest={id=93082, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=1737, title="Durable Wooden Chest", decorType="Storage", source={type="vendor", itemID=245546}, requirements={quest={id=93084, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2087, title="Short Orgrimmar Bench", decorType="Seating", source={type="vendor", itemID=246217, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93097, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2088, title="Iron-Reinforced Crate", decorType="Storage", source={type="vendor", itemID=246218}, requirements={quest={id=93098, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2090, title="Leather-Banded Wooden Bench", decorType="Seating", source={type="vendor", itemID=246220, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2098, title="Spiky Banded Barrel", decorType="Storage", source={type="vendor", itemID=246241, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93103, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2443, title="Razorwind Fountain", decorType="Large Structures", source={type="vendor", itemID=246611, currency="500", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2444, title="Logger's Picnic Table", decorType="Tables and Desks", source={type="vendor", itemID=246612, currency="300", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=2447, title="Open Spiky Banded Barrel", decorType="Storage", source={type="vendor", itemID=246615}, requirements={rep="true"}},
      {decorID=2448, title="Open Iron-Reinforced Crate", decorType="Storage", source={type="vendor", itemID=246616}, requirements={rep="true"}},
      {decorID=2534, title="Wide Hide-Covered Bench", decorType="Seating", source={type="vendor", itemID=246868}, requirements={quest={id=93131, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2546, title="Horned Banded Barrel", decorType="Storage", source={type="vendor", itemID=246880, currency="150", currencytype="War Resources"}, requirements={quest={id=93104, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2547, title="Open Horned Banded Barrel", decorType="Storage", source={type="vendor", itemID=246881, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=2548, title="Long Orgrimmar Bench", decorType="Seating", source={type="vendor", itemID=246882, currency="100", currencytype="Garrison Resources"}, requirements={quest={id=93133, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2549, title="Crude Banded Crate", decorType="Storage", source={type="vendor", itemID=246883, currency="150", currencytype="War Resources"}, requirements={quest={id=93105, title="Decor Treasure Hunt"}, rep="true"}},
      {decorID=2550, title="Open Crude Banded Crate", decorType="Storage", source={type="vendor", itemID=246884, currency="150", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=5561, title="Wind Rider Roost", decorType="Large Structures", source={type="vendor", itemID=249550, currency="400", currencytype="War Resources"}, requirements={rep="true"}},
      {decorID=8236, title="Razorwind Cooking Grill", decorType="Misc Furnishings", source={type="vendor", itemID=251545}, requirements={rep="true"}},
      {decorID=8769, title="Tusked Weapon Stand", decorType="Storage", source={type="vendor", itemID=251637}, requirements={rep="true"}},
      {decorID=8770, title="Jagged Orgrimmar Trellis", decorType="Uncategorized", source={type="vendor", itemID=251638}, requirements={rep="true"}},
      {decorID=10791, title="Large Razorwind Gazebo", decorType="Large Structures", source={type="vendor", itemID=254893}, requirements={rep="true"}},
      {decorID=10892, title="Small Jagged Orgrimmar Trellis", decorType="Misc Structural", source={type="vendor", itemID=255708}, requirements={rep="true"}},
      {decorID=11139, title="Razorwind Porch Chair", decorType="Seating", source={type="vendor", itemID=256357, currency="100", currencytype="Garrison Resources"}, requirements={rep="true"}},
      {decorID=11437, title="Razorwind Covered Well", decorType="Large Structures", source={type="vendor", itemID=257099}, requirements={rep="true"}},
    }
  },
  {
    title="Stone Guard Nargol",
    source={
      id=50488,
      type="vendor",
      faction="Horde",
      zone="Orgrimmar",
      worldmap="85:5020:5840",
    },
    items={
      {decorID=9242, title="Earthen Storage Crate", decorType="Storage", source={type="vendor", itemID=253168, currency="600", currencytype="Resonance Crystals"}, requirements={rep="true"}},
    }
  },
  {
    title="Lord Candren",
    source={
      id=50307,
      type="vendor",
      faction="Alliance",
      zone="Darnassus",
      worldmap="89:3720:4760",
    },
    items={
      {decorID=858, title="Worgen's Chicken Coop", decorType="Ornamental", source={type="vendor", itemID=245518}, requirements={quest={id=24675, title="Last Meal"}, rep="true"}},
      {decorID=1794, title="Gilnean Noble's Trellis", decorType="Misc Nature", source={type="vendor", itemID=245603, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1796, title="Gilnean Stone Wall", decorType="Misc Structural", source={type="vendor", itemID=245605, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1829, title="Little Wolf's Loo", decorType="Large Structures", source={type="vendor", itemID=245620, currency="1000", currencytype="Order Resources"}, requirements={quest={id=14402, title="Ready to Go"}, rep="true"}},
    }
  },
  {
    title="Axle",
    source={
      id=23995,
      type="vendor",
      faction="Neutral",
      zone="Mudsprocket, Dustwallow Marsh",
      worldmap="70:4190:7390",
    },
    items={
      {decorID=1674, title="Head of the Broodmother", decorType="Ornamental", source={type="vendor", itemID=244852, currency="1000", currencytype="Honor"}, requirements={achievement={id=4405, title="More Dots! (25 player)"}, rep="true"}},
    }
  },
  {
    title="Jaquilina Dramet",
    source={
      id=2483,
      type="vendor",
      faction="Neutral",
      zone="Stranglethorn Vale",
      worldmap="50:4380:2320",
    },
    items={
      {decorID=4841, title="Nesingwary Mounted Elk Head", decorType="Wall Hangings", source={type="vendor", itemID=248808, currency="1000", currencytype="Order Resources"}, requirements={achievement={id=940, title="The Green Hills of Stranglethorn"}, rep="true"}},
    }
  },
  {
    title="\"High Tides\" Ren",
    source={
      id=255325,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:3983:7276",
    },
    items={
      {decorID=1482, title="Sethraliss Priest's Pillow", decorType="Ornamental", source={type="vendor", itemID=244778, currency="2", currencytype="Silver"}, requirements={rep="true"}},
	  {decorID=388, title="\"Sunrise Canyon\" Painting", decorType="Accents", source={type="vendor", itemID=245383, currency="150", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=2342, title="Charming Couch", decorType="Furnishings", source={type="vendor", itemID=246502, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1701, title="Charming Seat Cushion", decorType="Furnishings", source={type="vendor", itemID=245267, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1702, title="Checkered Charming Seat Cushion", decorType="Furnishings", source={type="vendor", itemID=245268, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=498, title="Circular Woolen Rug", decorType="Accents", source={type="vendor", itemID=235633, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1455, title="Closed Folk Curtains", decorType="Accents", source={type="vendor", itemID=244665, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1456, title="Durable Folk Valance", decorType="Accents", source={type="vendor", itemID=244666, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1244, title="Empty Wicker Basket", decorType="Furnishings", source={type="vendor", itemID=245335, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=12199, title="Empty Wooden Bathtub", decorType="Furnishings", source={type="vendor", itemID=258670, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=9144, title="Founder's Point Front Doo", decorType="Structural", source={type="vendor", itemID=252659, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=389, title="Goldshire Window", decorType="Structural", source={type="vendor", itemID=245356, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1739, title="Iron-Reinforced Cupboard", decorType="Furnishings", source={type="vendor", itemID=245548, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1745, title="Iron-Reinforced Standing Mirror", decorType="Furnishings", source={type="vendor", itemID=245556, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=484, title="Open Wooden Coffin", decorType="Furnishings", source={type="vendor", itemID=245353, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=535, title="Plain Interior Doorway", decorType="Structural", source={type="vendor", itemID=245394, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=536, title="Plain Interior Narrow Wall", decorType="Structural", source={type="vendor", itemID=245395, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=534, title="Plain Interior Wall", decorType="Structural", source={type="vendor", itemID=245393, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=9064, title="Plush Cushioned Chair", decorType="Furnishings", source={type="vendor", itemID=252417, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1083, title="Secretive Bookcase Wall", decorType="Furnishings", source={type="vendor", itemID=245370, currency="125", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=9471, title="Short Wooden Cabinet", decorType="Furnishings", source={type="vendor", itemID=253589, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=379, title="Small Fruit Platter", decorType="Accents", source={type="vendor", itemID=245358, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1993, title="Small Wooden Nightstand", decorType="Furnishings", source={type="vendor", itemID=246103, currency="25", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1991, title="Small Wooden Stool", decorType="Furnishings", source={type="vendor", itemID=246101, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=2103, title="Stormwind Angled Platform", decorType="Structural", source={type="vendor", itemID=246248, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=2099, title="Stormwind Beam Platform", decorType="Structural", source={type="vendor", itemID=246243, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1044, title="Stormwind Hall Rug", decorType="Accents", source={type="vendor", itemID=242255, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=530, title="Stormwind Interior Doorway", decorType="Structural", source={type="vendor", itemID=236678, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=528, title="Stormwind Interior Narrow Wall", decorType="Structural", source={type="vendor", itemID=236676, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=527, title="Stormwind Interior Pillar", decorType="Structural", source={type="vendor", itemID=236675, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=529, title="Stormwind Interior Wall", decorType="Structural", source={type="vendor", itemID=236677, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=2101, title="Stormwind Large Platform", decorType="Structural", source={type="vendor", itemID=246246, currency="125", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=2100, title="Stormwind Round Platform", decorType="Structural", source={type="vendor", itemID=246245, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=2102, title="Stormwind Small Platform", decorType="Structural", source={type="vendor", itemID=246247, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1435, title="Sturdy Fireplace", decorType="Lighting", source={type="vendor", itemID=244531, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1434, title="Sturdy Wall Rack", decorType="Furnishings", source={type="vendor", itemID=244530, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=9474, title="Sturdy Wooden Bathtub", decorType="Furnishings", source={type="vendor", itemID=253593, currency="125", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=495, title="Sturdy Wooden Bed", decorType="Furnishings", source={type="vendor", itemID=245336, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=373, title="Sturdy Wooden Bookcase", decorType="Furnishings", source={type="vendor", itemID=245375, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=483, title="Sturdy Wooden Coffin", decorType="Furnishings", source={type="vendor", itemID=245352, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=378, title="Sturdy Wooden Interior Door", decorType="Structural", source={type="vendor", itemID=245355, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=533, title="Sturdy Wooden Interior Pillar", decorType="Structural", source={type="vendor", itemID=245392, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=374, title="Sturdy Wooden Shelf", decorType="Furnishings", source={type="vendor", itemID=245384, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=9473, title="Sturdy Wooden Washbasin", decorType="Furnishings", source={type="vendor", itemID=253592, currency="75", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=390, title="Tall Sturdy Wooden Bookcase", decorType="Furnishings", source={type="vendor", itemID=245376, currency="125", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=377, title="Three-Candle Wrought Iron Chandelier", decorType="Lighting", source={type="vendor", itemID=235675, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1454, title="Tied-Open Folk Curtains", decorType="Wall Hangings", source={type="vendor", itemID=244664, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1123, title="Wicker Basket", decorType="Furnishings", source={type="vendor", itemID=245334, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1738, title="Wide Charming Couch", decorType="Furnishings", source={type="vendor", itemID=245547, currency="100", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=1996, title="Wooden Chamberstick", decorType="Lighting", source={type="vendor", itemID=246106, currency="10", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=478, title="Wooden Coffin Lid", decorType="Furnishings", source={type="vendor", itemID=245354, currency="25", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=726, title="Wrought Iron Chandelier", decorType="Lighting", source={type="vendor", itemID=239075, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	  {decorID=383, title="Wrought Iron Floor Lamp", decorType="Lighting", source={type="vendor", itemID=235677, currency="50", currencytype="Gold"}, requirements={rep="true"}},
	 
    }
  },
  {
    title="Brave Tuho",
    source={
      id=50483,
      type="vendor",
      faction="Horde",
      zone="Thunder Bluff",
      worldmap="88:4620:5060",
    },
    items={
      {decorID=1281, title="Tauren Bluff Rug", decorType="Floor", source={type="vendor", itemID=243335, currency="750", currencytype="Order Resources"}, requirements={quest={id=26397, title="Walk With The Earth Mother"}, rep="true"}},
    }
  },
  {
    title="The Last Architect",
    source={
      id=253596,
      type="vendor",
      faction="Horde",
      zone="Razorwind Shores",
      worldmap="2351:5380:5740",
    },
    items={
      {decorID=14583, title="Hearthlight Armillary", decorType="Ornamental", source={type="vendor", itemID=262453}, requirements={rep="true"}},
    }
  },
  {
    title="Drac Roughcut",
    source={
      id=1465,
      type="vendor",
      faction="Alliance",
      zone="Thelsamar, Loch Modan",
      worldmap="48:3560:4900",
    },
    items={
      {decorID=2239, title="Thelsamar Hanging Lantern", decorType="Ceiling Lights", source={type="vendor", itemID=246422}, requirements={quest={id=26868, title="Axis of Awful"}, rep="true"}},
    }
  },
  {
    title="Aeeshna",
    source={
      id=252605,
      type="vendor",
      faction="Neutral",
      zone="Razorwind Shores",
      worldmap="2351:5440:5620",
    },
    items={
      {decorID=14677, title="Complete Guide to K'areshi Wrappings, Vol. 11", decorType="Ornamental", source={type="vendor", itemID=262664, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14678, title="K'areshi Holo-Crystal Projector", decorType="Miscellaneous - All", source={type="vendor", itemID=262665, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14679, title="K'areshi Incense Burner", decorType="Miscellaneous - All", source={type="vendor", itemID=262666, currency="2", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14680, title="Oath Scale", decorType="Miscellaneous - All", source={type="vendor", itemID=262667, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14793, title="Consortium Glowpost", decorType="Large Lights", source={type="vendor", itemID=262884, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14800, title="Tazaveshi Hookah", decorType="Miscellaneous - All", source={type="vendor", itemID=262907, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14829, title="Consortium Energy Barrel", decorType="Storage", source={type="vendor", itemID=263043, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14830, title="Empty Consortium Energy Barrel", decorType="Storage", source={type="vendor", itemID=263044, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14831, title="Consortium Energy Collector", decorType="Large Lights", source={type="vendor", itemID=263045, currency="20", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14832, title="Consortium Energy Crate", decorType="Storage", source={type="vendor", itemID=263046, currency="10", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14833, title="Empty Consortium Energy Crate", decorType="Storage", source={type="vendor", itemID=263047, currency="5", currencytype="Community Coupons"}, requirements={rep="true"}},
      {decorID=14834, title="Consortium Energy Banner", decorType="Ornamental", source={type="vendor", itemID=263048, currency="15", currencytype="Community Coupons"}, requirements={rep="true"}},
    }
  },
}
