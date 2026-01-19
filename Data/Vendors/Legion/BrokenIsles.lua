local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Legion"] = NS.Data.Vendors["Legion"] or {}

NS.Data.Vendors["Legion"]["BrokenIsles"] = {

   -- {
   --Legion Remix not sure if it'll be added back some where else.   title="Domelius",
   -- source={
   --   id=251042,
   --   type="vendor",
   --  faction="Neutral",
   --   zone="Dalaran",
   --   worldmap="619:5506:7797",
   -- },
   -- items={
   --   {decorID=7610, title="Tome of the Corrupt", decorType="Ornamental", source={type="vendor", itemID=250307, currency="10000", currencytype="Bronze"}, requirements={achievement={id=42318, title="Court of Farondis"}, rep="true"}},
   --   {decorID=7620, title="Vrykul Lord's Throne", decorType="Seating", source={type="vendor", itemID=250402, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42658, title="Valarjar"}, rep="true"}},
   --   {decorID=7621, title="Legion's Holo-Communicator", decorType="Miscellaneous - All", source={type="vendor", itemID=250403, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42692, title="Broken Isles Dungeoneer"}, rep="true"}},
   --   {decorID=7622, title="Hanging Felsteel Chain", decorType="Misc Accents", source={type="vendor", itemID=250404, currency="5000", currencytype="Bronze"}, requirements={rep="true"}},
   --   {decorID=7623, title="Legion's Fel Torch", decorType="Large Lights", source={type="vendor", itemID=250405, currency="5000", currencytype="Bronze"}, requirements={achievement={id=61060, title="Power of the Obelisks II"}, rep="true"}},
   --   {decorID=7624, title="Corruption Pit", decorType="Large Structures", source={type="vendor", itemID=250406, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42321, title="Legion Remix Raids"}, rep="true"}},
   --   {decorID=7625, title="Legion's Fel Brazier", decorType="Large Lights", source={type="vendor", itemID=250407, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42619, title="Dreamweavers"}, rep="true"}},
   --   {decorID=7658, title="Vertical Felsteel Chain", decorType="Misc Accents", source={type="vendor", itemID=250622, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42675, title="Defending the Broken Isles III"}, rep="true"}},
   --   {decorID=7686, title="Legion Torture Rack", decorType="Large Structures", source={type="vendor", itemID=250689, currency="10000", currencytype="Bronze"}, requirements={achievement={id=61054, title="Heroic Broken Isles World Quests III"}, rep="true"}},
   --   {decorID=7687, title="Eredar Lord's Fel Torch", decorType="Large Lights", source={type="vendor", itemID=250690, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42627, title="Argussian Reach"}, rep="true"}},
   --   {decorID=7690, title="Altar of the Corrupted Flames", decorType="Ornamental", source={type="vendor", itemID=250693, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42674, title="Broken Isles World Quests V"}, rep="true"}},
   --   {decorID=8810, title="Sentinel's Moonwing Gaze", decorType="Misc Accents", source={type="vendor", itemID=251778, currency="30000", currencytype="Bronze"}, requirements={achievement={id=61218, title="The Wardens"}, rep="true"}},
   --   {decorID=8811, title="Fel Fountain", decorType="Large Structures", source={type="vendor", itemID=251779, currency="30000", currencytype="Bronze"}, requirements={achievement={id=42689, title="Timeworn Keystone Master"}, rep="true"}},
   --   {decorID=9165, title="Demonic Storage Chest", decorType="Storage", source={type="vendor", itemID=252753, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42655, title="The Armies of Legionfall"}, rep="true"}},
   --  {decorID=11278, title="Large Legion Candle", decorType="Small Lights", source={type="vendor", itemID=256677, currency="5000", currencytype="Bronze"}, requirements={achievement={id=42628, title="The Nightfallen"}, rep="true"}},
   --   {decorID=11279, title="Small Legion Candle", decorType="Small Lights", source={type="vendor", itemID=256678, currency="2500", currencytype="Bronze"}, requirements={rep="true"}},
   --   {decorID=11942, title="Hanging Felsteel Cage", decorType="Misc Structural", source={type="vendor", itemID=258299, currency="20000", currencytype="Bronze"}, requirements={achievement={id=42547, title="Highmountain Tribe"}, rep="true"}},
   -- }
   --},
  {
    title="First Arcanist Thalyssra",
    source={
      id=115736,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:3649:4583",
    },
    items={
      {decorID=1440, title="Nightborne Fireplace", decorType="Large Lights", source={type="vendor", itemID=244536, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2516, title="\"Fruit of the Arcan'dor\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=246850, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=3983, title="Suramar Library", decorType="Storage", source={type="vendor", itemID=247844, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=3984, title="Nightborne Bench", decorType="Seating", source={type="vendor", itemID=247845, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=3985, title="Arcwine Counter", decorType="Tables and Desks", source={type="vendor", itemID=247847, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4024, title="Suramar Sconce", decorType="Wall Lights", source={type="vendor", itemID=247910, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4035, title="Nightborne Wall Shelf", decorType="Storage", source={type="vendor", itemID=247921, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4038, title="Suramar Street Light", decorType="Large Lights", source={type="vendor", itemID=247924, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Outfitter Reynolds",
    source={
      id=103693,
      type="vendor",
      faction="Neutral",
      zone="Trueshot Lodge",
      worldmap="739:4456:4888",
    },
    items={
      {decorID=1740, title="Trueshot Lodge Fireplace", decorType="Large Lights", source={type="vendor", itemID=245549, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=4042, title="Trueshot Skeletal Dragon Head", decorType="Wall Hangings", source={type="vendor", itemID=248011, currency="1500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5877, title="Trueshot Lodge Weapon Rack", decorType="Storage", source={type="vendor", itemID=250110, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5890, title="Replica Altar of the Eternal Hunt", decorType="Ornamental", source={type="vendor", itemID=250125, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42290, title="Hidden Potential of the Huntmaster"}, rep="true"}},
      {decorID=5891, title="Unseen Path Archer's Gallery", decorType="Ornamental", source={type="vendor", itemID=250126, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60984, title="Raise an Army for the Trueshot Lodge"}, rep="true"}},
      {decorID=5892, title="Replica Tales of the Hunt", decorType="Ornamental", source={type="vendor", itemID=250127, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60965, title="Legendary Research of the Unseen Path"}, rep="true"}},
      {decorID=5893, title="Banner of the Unseen Path", decorType="Ornamental", source={type="vendor", itemID=250128, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Gigi Gigavoid",
    source={
      id=112434,
      type="vendor",
      faction="Alliance",
      zone="Dreadscar Rift",
      worldmap="717:5876:3269",
    },
    items={
      {decorID=5117, title="Replica Felblood Altar", decorType="Miscellaneous - All", source={type="vendor", itemID=248940, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42297, title="Hidden Potential of the Netherlord"}, rep="true"}},
      {decorID=5120, title="Black Harvest Banner", decorType="Ornamental", source={type="vendor", itemID=248943, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5127, title="Dreadscar Bookcase", decorType="Storage", source={type="vendor", itemID=248959, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5128, title="Dreadscar Dais", decorType="Floor", source={type="vendor", itemID=248960, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42281, title="The Netherlord's Campaign"}, rep="true"}},
      {decorID=5292, title="Black Harvest Orrery", decorType="Large Structures", source={type="vendor", itemID=249004, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=11307, title="Replica Tome of Blighted Implements", decorType="Misc Accents", source={type="vendor", itemID=256907, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60972, title="Legendary Research of the Black Harvest"}, rep="true"}},
      {decorID=15477, title="Dreadscar Battle Planning Map", decorType="Miscellaneous - All", source={type="vendor", itemID=264242, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60991, title="Raise an Army for the Dreadscar Rift"}, rep="true"}},
    }
  },
  {
    title="Halenthos Brightstride",
    source={
      id=252043,
      type="vendor",
      faction="Alliance",
      zone="Dalaran",
      worldmap="627:6745:3389",
    },
    items={
      {decorID=947, title="Dark Ship's Lantern", decorType="Wall Lights", source={type="vendor", itemID=245411, currency="150", currencytype="War Resources"}, requirements={quest={id=38882, title="A New Life for Undeath"}, rep="true"}},
      {decorID=9267, title="Blightfire Candle", decorType="Small Lights", source={type="vendor", itemID=253251, currency="150", currencytype="War Resources"}, requirements={quest={id=39801, title="The Splintered Fleet"}, rep="true"}},
    }
  },
  {
    title="Corbin Branbell",
    source={
      id=252498,
      type="vendor",
      faction="Horde",
      zone="Val'sharah",
      worldmap="641:4209:5938",
    },
    items={
      {decorID=1801, title="Bradensbrook Smoke Lantern", decorType="Small Lights", source={type="vendor", itemID=245615, currency="350", currencytype="Order Resources"}, requirements={quest={id=39117, title="Shriek No More"}, rep="true"}},
      {decorID=1802, title="Bradensbrook Thorned Well", decorType="Large Structures", source={type="vendor", itemID=245616, currency="1000", currencytype="Order Resources"}, requirements={quest={id=46107, title="Source of the Corruption"}, rep="true"}},
    }
  },
  {
    title="Amurra Thistledew",
    source={
      id=112323,
      type="vendor",
      faction="Neutral",
      zone="The Dreamgrove",
      worldmap="747:4002:1772",
    },
    items={
      {decorID=1741, title="Runed Dreamweaver Moonstone", decorType="Ornamental", source={type="vendor", itemID=245550, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=2086, title="Sprouting Lamppost", decorType="Large Lights", source={type="vendor", itemID=246216, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5878, title="Replica Tome of the Ancients", decorType="Misc Furnishings", source={type="vendor", itemID=250111, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60964, title="Legendary Research of the Dreamgrove"}, rep="true"}},
      {decorID=5897, title="Dreamweaver Banner", decorType="Wall Hangings", source={type="vendor", itemID=250133, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5898, title="Seed of Ages Cutting", decorType="Ornamental", source={type="vendor", itemID=250134, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42289, title="Hidden Potential of the Archdruid"}, rep="true"}},
      {decorID=7873, title="Cenarion Arch", decorType="Large Structures", source={type="vendor", itemID=251013, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60983, title="Raise an Army for the Dreamgrove"}, rep="true"}},
      {decorID=14358, title="Brazier of Elune", decorType="Large Lights", source={type="vendor", itemID=260581, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42272, title="The Archdruid's Campaign"}, rep="true"}},
    }
  },
  {
    title="Selfira Ambergrove",
    source={
      id=253387,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:5426:7236",
    },
    items={
      {decorID=675, title="Cenarion Privacy Screen", decorType="Misc Accents", source={type="vendor", itemID=238859, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=676, title="Deluxe Val'sharah Bed", decorType="Beds", source={type="vendor", itemID=238860, currency="700", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=677, title="Cenarion Rectangular Rug", decorType="Floor", source={type="vendor", itemID=238861, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1695, title="Kaldorei Washbasin", decorType="Food and Drink", source={type="vendor", itemID=245261, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1881, title="Shala'nir Feather Bed", decorType="Beds", source={type="vendor", itemID=245697, currency="600", currencytype="Order Resources"}, requirements={achievement={id=10698, title="That's Val'sharah Folks!"}, rep="true"}},
      {decorID=1884, title="Kaldorei Cushioned Seat", decorType="Seating", source={type="vendor", itemID=245700, currency="250", currencytype="Order Resources"}, requirements={quest={id=38663, title="The Die is Cast"}, rep="true"}},
      {decorID=1886, title="Kaldorei Wall Shelf", decorType="Storage", source={type="vendor", itemID=245702, currency="75", currencytype="Order Resources"}, requirements={quest={id=38147, title="Entangled Dreams"}, rep="true"}},
      {decorID=1887, title="Kaldorei Treasure Trove", decorType="Storage", source={type="vendor", itemID=245703, currency="750", currencytype="Order Resources"}, requirements={achievement={id=11258, title="Treasures of Val'sharah"}, rep="true"}},
      {decorID=1889, title="Crescent Moon Lamppost", decorType="Large Lights", source={type="vendor", itemID=245739, currency="300", currencytype="Order Resources"}, requirements={quest={id=40890, title="The Tears of Elune"}, rep="true"}},
      {decorID=8195, title="Moon-Blessed Barrel", decorType="Storage", source={type="vendor", itemID=251494, currency="200", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=15453, title="Cenarion Round Rug", decorType="Floor", source={type="vendor", itemID=264168, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Sylvia Hartshorn",
    source={
      id=106901,
      type="vendor",
      faction="Horde",
      zone="Val'sharah",
      worldmap="641:5470:7325",
    },
    items={
      {decorID=675, title="Cenarion Privacy Screen", decorType="Misc Accents", source={type="vendor", itemID=238859, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=677, title="Cenarion Rectangular Rug", decorType="Floor", source={type="vendor", itemID=238861, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1695, title="Kaldorei Washbasin", decorType="Food and Drink", source={type="vendor", itemID=245261, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=8195, title="Moon-Blessed Barrel", decorType="Storage", source={type="vendor", itemID=251494, currency="200", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=15453, title="Cenarion Round Rug", decorType="Floor", source={type="vendor", itemID=264168, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Meridelle Lightspark",
    source={
      id=112401,
      type="vendor",
      faction="Horde",
      zone="Netherlight Temple",
      worldmap="702:3861:2377",
    },
    items={
      {decorID=7606, title="Netherlight Conclave Voidwell", decorType="Misc Furnishings", source={type="vendor", itemID=250302, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7607, title="Conclave Pedestal", decorType="Uncategorized", source={type="vendor", itemID=250303, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7608, title="Netherlight Lightwell", decorType="Small Lights", source={type="vendor", itemID=250304, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7821, title="Netherlight Conclave Banner", decorType="Wall Hangings", source={type="vendor", itemID=250789, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7822, title="Replica Altar of Light and Shadow", decorType="Ornamental", source={type="vendor", itemID=250790, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42294, title="Hidden Potential of the High Priest"}, rep="true"}},
      {decorID=7823, title="Replica Word of the Conclave", decorType="Ornamental", source={type="vendor", itemID=250791, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60969, title="Legendary Research of the Netherlight Conclave"}, rep="true"}},
      {decorID=7824, title="Scroll of the Conclave", decorType="Ornamental", source={type="vendor", itemID=250792, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42277, title="The High Priest's Campaign"}, rep="true"}},
      {decorID=8768, title="Netherlight Command Map", decorType="Uncategorized", source={type="vendor", itemID=251636, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60988, title="Raise an Army for the Netherlight Temple"}, rep="true"}},
    }
  },
  {
    title="Jackson Watkins",
    source={
      id=112440,
      type="vendor",
      faction="Neutral",
      zone="Hall of the Guardian",
      worldmap="735:4475:5787",
    },
    items={
      {decorID=750, title="Tirisgarde Book Tempest", decorType="Ornamental", source={type="vendor", itemID=245429, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42274, title="The Archmage's Campaign"}, rep="true"}},
      {decorID=5894, title="Tirisgarde Candle", decorType="Small Lights", source={type="vendor", itemID=250130, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5895, title="Tirisgarde War Map", decorType="Misc Furnishings", source={type="vendor", itemID=250131, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=60985, title="Raise an Army for the Hall of the Guardian"}, rep="true"}},
      {decorID=5896, title="Tirisgarde Brazier", decorType="Large Lights", source={type="vendor", itemID=250132, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7579, title="Tirisgarde Banner", decorType="Wall Hangings", source={type="vendor", itemID=250239, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7609, title="Conjured Altar of the Guardian", decorType="Ornamental", source={type="vendor", itemID=250306, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42291, title="Hidden Potential of the Archmage"}, rep="true"}},
      {decorID=11275, title="Conjured Archive of the Tirisgarde", decorType="Ornamental", source={type="vendor", itemID=256674, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60966, title="Legendary Research of the Tirisgarde"}, rep="true"}},
    }
  },
  {
    title="Jocenna",
    source={
      id=252969,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4963:6283",
    },
    items={
      {decorID=752, title="\"Night on the Jeweled Estate\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=245448, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=11124, title="Good Suramaritan"}, rep="true"}},
      {decorID=1747, title="Elaborate Suramar Window", decorType="Windows", source={type="vendor", itemID=245558, currency="225", currencytype="Order Resources"}, requirements={quest={id=44955, title="Visitor in Shal'Aran"}, rep="true"}},
      {decorID=3981, title="Nightborne Merchant's Stall", decorType="Large Structures", source={type="vendor", itemID=247842, currency="600", currencytype="Order Resources"}, requirements={quest={id=44756, title="Sign of the Dusk Lily"}, rep="true"}},
      {decorID=3982, title="Deluxe Suramar Sleeper", decorType="Beds", source={type="vendor", itemID=247843, currency="1200", currencytype="Order Resources"}, requirements={achievement={id=11340, title="Insurrection"}, rep="true"}},
      {decorID=4025, title="Shal'dorei Seat", decorType="Seating", source={type="vendor", itemID=247911, currency="100", currencytype="Order Resources"}, requirements={quest={id=43318, title="Ly'leth's Champion"}, rep="true"}},
      {decorID=4028, title="Covered Ornate Suramar Table", decorType="Tables and Desks", source={type="vendor", itemID=247914, currency="400", currencytype="Order Resources"}, requirements={quest={id=44052, title="And They Will Tremble"}, rep="true"}},
      {decorID=4031, title="Covered Small Suramar Table", decorType="Tables and Desks", source={type="vendor", itemID=247917, currency="200", currencytype="Order Resources"}, requirements={quest={id=41915, title="The Master's Legacy"}, rep="true"}},
      {decorID=4040, title="Suramar Window", decorType="Windows", source={type="vendor", itemID=248009, currency="175", currencytype="Order Resources"}, requirements={quest={id=42489, title="Thalyssra's Drawers"}, rep="true"}},
    }
  },
  {
    title="Torv Dubstomp",
    source={
      id=108017,
      type="vendor",
      faction="Neutral",
      zone="Thunder Totem, Highmountain",
      worldmap="650:5280:8000",
    },
    items={
      {decorID=1235, title="Whitewash River Basket", decorType="Storage", source={type="vendor", itemID=245453, currency="500", currencytype="Order Resources"}, requirements={quest={id=42590, title="Moozy's Reunion"}, rep="true"}},
      {decorID=1251, title="Large Highmountain Drum", decorType="Misc Accents", source={type="vendor", itemID=245405, currency="500", currencytype="Order Resources"}, requirements={quest={id=42622, title="Ceremonial Drums"}, rep="true"}},
      {decorID=1287, title="Warbrave's Brazier", decorType="Large Lights", source={type="vendor", itemID=245456, currency="750", currencytype="Order Resources"}, requirements={quest={id=39579, title="The Backdoor"}, rep="true"}},
      {decorID=1291, title="Tauren Vertical Windmill", decorType="Large Structures", source={type="vendor", itemID=245461, currency="1000", currencytype="Order Resources"}, requirements={quest={id=39780, title="The Underking"}, rep="true"}},
      {decorID=1294, title="Riverbend Netting", decorType="Wall Hangings", source={type="vendor", itemID=245457, currency="500", currencytype="Order Resources"}, requirements={quest={id=39614, title="Fish Out of Water"}, rep="true"}},
      {decorID=1307, title="Skyhorn Storage Chest", decorType="Storage", source={type="vendor", itemID=245460, currency="750", currencytype="Order Resources"}, requirements={achievement={id=11257, title="Treasures of Highmountain"}, rep="true"}},
      {decorID=1309, title="Dried Whitewash Corn", decorType="Food and Drink", source={type="vendor", itemID=245409, currency="500", currencytype="Order Resources"}, requirements={quest={id=39496, title="The Flow of the River"}, rep="true"}},
      {decorID=11315, title="Tauren Jeweler's Roller", decorType="Misc Accents", source={type="vendor", itemID=256913, currency="500", currencytype="Order Resources"}, requirements={achievement={id=10996, title="Got to Ketchum All"}, rep="true"}},
      {decorID=11487, title="Tauren Storyteller's Frame", decorType="Misc Accents", source={type="vendor", itemID=257397, currency="750", currencytype="Order Resources"}, requirements={quest={id=39992, title="Huln's War - The Nathrezim"}, rep="true"}},
      {decorID=11491, title="Skyhorn Banner", decorType="Wall Hangings", source={type="vendor", itemID=257401, currency="1000", currencytype="Order Resources"}, requirements={quest={id=39387, title="The Skies of Highmountain"}, rep="true"}},
      {decorID=11751, title="Skyhorn Arrow Kite", decorType="Ornamental", source={type="vendor", itemID=257721, currency="500", currencytype="Order Resources"}, requirements={achievement={id=10398, title="Drum Circle"}, rep="true"}},
      {decorID=11752, title="Hanging Arrow Kite", decorType="Ornamental", source={type="vendor", itemID=257722, currency="500", currencytype="Order Resources"}, requirements={quest={id=39426, title="Blood Debt"}, rep="true"}},
      {decorID=11753, title="Skyhorn Eagle Kite", decorType="Ornamental", source={type="vendor", itemID=257723, currency="750", currencytype="Order Resources"}, requirements={quest={id=39305, title="Empty Nest"}, rep="true"}},
      {decorID=14379, title="Kobold Trassure Pile", decorType="Misc Accents", source={type="vendor", itemID=260698, currency="200", currencytype="Order Resources"}, requirements={quest={id=39772, title="Can't Hold a Candle To You"}, rep="true"}},
    }
  },
  {
    title="Crafty Palu",
    source={
      id=108537,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:4162:1044",
    },
    items={
      --       {decorID=11905, title="Driftwood Barrel", decorType="Storage", source={type="vendor", itemID=258219, currency="175", currencytype="Order Resources"}, requirements={rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11907, title="Driftwood Junk Pile", decorType="Storage", source={type="vendor", itemID=258221, currency="450", currencytype="Order Resources"}, requirements={quest={id=40230, title="Oh, the Clawdacity!"}, rep="true"}}, -- Early Access / Midnight pre-patch
      --       {decorID=11909, title="Murloc's Wind Chimes", decorType="Ornamental", source={type="vendor", itemID=258223, currency="400", currencytype="Order Resources"}, requirements={achievement={id=11699, title="Grand Fin-ale"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Flamesmith Lanying",
    source={
      id=112318,
      type="vendor",
      faction="Neutral",
      zone="The Maelstrom",
      worldmap="726:3032:6069",
    },
    items={
      {decorID=7837, title="Elemental Altar of the Maelstrom", decorType="Ornamental", source={type="vendor", itemID=250914, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42296, title="Hidden Potential of the Farseer"}, rep="true"}},
      {decorID=7838, title="Replica Words of Wind and Earth", decorType="Ornamental", source={type="vendor", itemID=250915, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60971, title="Legendary Research of the Maelstrom"}, rep="true"}},
      {decorID=7839, title="Pedestal of the Maelstrom's Wisdom", decorType="Ornamental", source={type="vendor", itemID=250916, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7841, title="Maelstrom Banner", decorType="Ornamental", source={type="vendor", itemID=250918, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7874, title="Earthen Ring Scouting Map", decorType="Ornamental", source={type="vendor", itemID=251014, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60990, title="Raise an Army for the Maelstrom"}, rep="true"}},
      {decorID=7875, title="Maelstrom Chimes", decorType="Ornamental", source={type="vendor", itemID=251015, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=11493, title="Maelstrom Lava Lamp", decorType="Miscellaneous - All", source={type="vendor", itemID=257403, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42280, title="The Farseer's Campaign"}, rep="true"}},
    }
  },
  {
    title="Sileas Duskvine",
    source={
      id=253434,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="641:7992:7389",
    },
    items={
      {decorID=1885, title="Elven Round Table", decorType="Tables and Desks", source={type="vendor", itemID=245701, currency="175", currencytype="Order Resources"}, requirements={quest={id=40321, title="Feathersong's Redemption"}, rep="true"}},
    }
  },
  {
    title="Falara Nightsong",
    source={
      id=112407,
      type="vendor",
      faction="Neutral",
      zone="The Fel Hammer",
      worldmap="720:6100:5673",
    },
    items={
      {decorID=5525, title="Replica Cursed Forge of the Nathrezim", decorType="Large Structures", source={type="vendor", itemID=249457, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42288, title="Hidden Potential of the Slayer"}, rep="true"}},
      {decorID=5527, title="Illidari Glaiverest", decorType="Wall Hangings", source={type="vendor", itemID=249459, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42271, title="The Slayer's Campaign"}, rep="true"}},
      {decorID=5530, title="Illidari Banner", decorType="Wall Hangings", source={type="vendor", itemID=249462, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5531, title="Illidari Skull Sentinel", decorType="Miscellaneous - All", source={type="vendor", itemID=249463, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5555, title="Fel Hammer Scouting Map", decorType="Miscellaneous - All", source={type="vendor", itemID=249518, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60982, title="Raise an Army for the Fel Hammer"}, rep="true"}},
      {decorID=5575, title="Replica Tome of Fel Secrets", decorType="Ornamental", source={type="vendor", itemID=249690, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60963, title="Legendary Research of the Illidari"}, rep="true"}},
      {decorID=11276, title="Illidari Tent", decorType="Large Structures", source={type="vendor", itemID=256675, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Caydori Brightstar",
    source={
      id=112338,
      type="vendor",
      faction="Neutral",
      zone="Mandori Village",
      worldmap="709:5033:5913",
    },
    items={
      {decorID=5112, title="Five Dawns Weapon Rack", decorType="Storage", source={type="vendor", itemID=248935, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5113, title="Five Dawns Shrine of the Smoking Fish", decorType="Ornamental", source={type="vendor", itemID=248936, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5119, title="Five Dawns Planning Table", decorType="Tables and Desks", source={type="vendor", itemID=248942, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60986, title="Raise an Army for the Temple of Five Dawns"}, rep="true"}},
      {decorID=5126, title="Monastery Gong", decorType="Large Structures", source={type="vendor", itemID=248958, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42275, title="The Grandmaster's Campaign"}, rep="true"}},
      {decorID=11280, title="Replica Chronicle of Ages", decorType="Ornamental", source={type="vendor", itemID=256679, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60967, title="Legendary Research of Five Dawns"}, rep="true"}},
      {decorID=14644, title="Replica Forge of the Roaring Mountain", decorType="Misc Structural", source={type="vendor", itemID=262619, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42292, title="Hidden Potential of the Grandmaster"}, rep="true"}},
    }
  },
  {
    title="Ransa Greyfeather",
    source={
      id=106902,
      type="vendor",
      faction="Neutral",
      zone="Highmountain",
      worldmap="650:4588:6049",
    },
    items={
      {decorID=1231, title="Stonebull Canoe", decorType="Ornamental", source={type="vendor", itemID=245452, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1252, title="Tauren Waterwheel", decorType="Miscellaneous - All", source={type="vendor", itemID=243290, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1292, title="Tauren Windmill", decorType="Large Structures", source={type="vendor", itemID=243359, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1293, title="Small Highmountain Drum", decorType="Ornamental", source={type="vendor", itemID=245454, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1295, title="Riverbend Jar", decorType="Ornamental", source={type="vendor", itemID=245458, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1297, title="Highmountain Totem", decorType="Ornamental", source={type="vendor", itemID=245450, currency="2000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1703, title="Thunder Totem Kiln", decorType="Misc Accents", source={type="vendor", itemID=245270, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5136, title="Tauren Hanging Brazier", decorType="Wall Lights", source={type="vendor", itemID=248985, currency="750", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Hilseth Travelstride",
    source={
      id=112634,
      type="vendor",
      faction="Alliance",
      zone="Val'sharah",
      worldmap="641:5714:7191",
    },
    items={
      {decorID=679, title="Kaldorei Desk", decorType="Tables and Desks", source={type="vendor", itemID=238863, currency="300", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=1694, title="Kaldorei Chef's Table", decorType="Tables and Desks", source={type="vendor", itemID=245260, currency="400", currencytype="Order Resources"}, requirements={rep="true"}},
    }
  },
  {
    title="Myria Glenbrook",
    source={
      id=109306,
      type="vendor",
      faction="Neutral",
      zone="Val'sharah",
      worldmap="641:6020:8486",
    },
    items={
      {decorID=1692, title="Val'sharah Bookcase", decorType="Storage", source={type="vendor", itemID=245258, currency="75", currencytype="Order Resources"}, requirements={quest={id=42751, title="Moon Reaver"}, rep="true"}},
      {decorID=1882, title="Kaldorei Stone Fence", decorType="Misc Structural", source={type="vendor", itemID=245698, currency="450", currencytype="Resonance Crystals"}, requirements={quest={id=40573, title="The Nightmare Lord"}, rep="true"}},
      {decorID=1883, title="Kaldorei Stone Fencepost", decorType="Misc Structural", source={type="vendor", itemID=245699, currency="350", currencytype="Resonance Crystals"}, requirements={quest={id=40573, title="The Nightmare Lord"}, rep="true"}},
    }
  },
  {
    title="Leyweaver Inondra",
    source={
      id=93971,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4032:6973",
    },
    items={
      {decorID=4026, title="Large Traditional Shal'dorei Rug", decorType="Floor", source={type="vendor", itemID=247912, currency="250", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=4033, title="Traditional Shal'dorei Rug", decorType="Floor", source={type="vendor", itemID=247919, currency="150", currencytype="Ancient Mana"}, requirements={rep="true"}},
    }
  },
  {
    title="Kelsey Steelspark",
    source={
      id=105986,
      type="vendor",
      faction="Neutral",
      zone="The Hall of Shadows",
      worldmap="626:2692:3683",
    },
    items={
      {decorID=7815, title="Uncrowned Apothecary's Cabinet", decorType="Storage", source={type="vendor", itemID=250783, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7816, title="Uncrowned Apothecary's Supplies", decorType="Ornamental", source={type="vendor", itemID=250784, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7817, title="Uncrowned Banner", decorType="Wall Hangings", source={type="vendor", itemID=250785, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=7818, title="Uncrowned Planning Table", decorType="Tables and Desks", source={type="vendor", itemID=250786, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60989, title="Raise an Army for the Hall of Shadows"}, rep="true"}},
      {decorID=7819, title="Replica Crucible of the Uncrowned", decorType="Ornamental", source={type="vendor", itemID=250787, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42295, title="Hidden Potential of the Shadowblade"}, rep="true"}},
      {decorID=7820, title="Stolen Copy of the Blood Ledger", decorType="Misc Furnishings", source={type="vendor", itemID=250788, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60970, title="Legendary Research of the Uncrowned"}, rep="true"}},
      {decorID=11493, title="Maelstrom Lava Lamp", decorType="Miscellaneous - All", source={type="vendor", itemID=257403, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42280, title="The Farseer's Campaign"}, rep="true"}},
      {decorID=14461, title="Uncrowned Market Stall", decorType="Large Structures", source={type="vendor", itemID=260776, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42279, title="The Shadowblade's Campaign"}, rep="true"}},
    }
  },
  {
    title="Sundries Merchant",
    source={
      id=248594,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:5090:7778",
    },
    items={
      {decorID=1444, title="Small Purple Suramar Seat Cushion", decorType="Seating", source={type="vendor", itemID=244654, currency="100", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1464, title="Teal Suramar Seat Cushion", decorType="Seating", source={type="vendor", itemID=244676, currency="200", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1465, title="Purple Suramar Seat Cushion", decorType="Seating", source={type="vendor", itemID=244677, currency="300", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1466, title="Small Red Suramar Seat Cushion", decorType="Seating", source={type="vendor", itemID=244678, currency="100", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1919, title="Orange Suramar Seat Cushion", decorType="Seating", source={type="vendor", itemID=246001, currency="200", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=1920, title="Red Suramar Seat Cushion", decorType="Seating", source={type="vendor", itemID=246002, currency="300", currencytype="Ancient Mana"}, requirements={rep="true"}},
    }
  },
  {
    title="Rasil Fireborne",
    source={
      id=112716,
      type="vendor",
      faction="Alliance",
      zone="Dalaran",
      worldmap="626:4340:4940",
    },
    items={
      {decorID=2517, title="\"Raising Your Eyes\" Painting", decorType="Wall Hangings", source={type="vendor", itemID=246851, currency="600", currencytype="Honor"}, requirements={rep="true"}},
    }
  },
  {
    title="Quartermaster Durnolf",
    source={
      id=112392,
      type="vendor",
      faction="Horde",
      zone="Skyhold",
      worldmap="695:5549:2591",
    },
    items={
      {decorID=5526, title="Replica Forge of Odyn", decorType="Large Structures", source={type="vendor", itemID=249458, currency="5000", currencytype="Order Resources"}, requirements={achievement={id=42298, title="Hidden Potential of the Battlelord"}, rep="true"}},
      {decorID=5528, title="Skyhold Brazier", decorType="Large Lights", source={type="vendor", itemID=249460, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5529, title="Skyhold War Table", decorType="Tables and Desks", source={type="vendor", itemID=249461, currency="2000", currencytype="Order Resources"}, requirements={achievement={id=60992, title="Raise an Army for Skyhold"}, rep="true"}},
      {decorID=5532, title="Valarjar Banner", decorType="Wall Hangings", source={type="vendor", itemID=249464, currency="1000", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=5534, title="Valarjar Shield Wall", decorType="Wall Hangings", source={type="vendor", itemID=249466, currency="1500", currencytype="Order Resources"}, requirements={achievement={id=42282, title="The Battlelord's Campaign"}, rep="true"}},
      {decorID=5562, title="Skyhold Spear Rack", decorType="Storage", source={type="vendor", itemID=249551, currency="500", currencytype="Order Resources"}, requirements={rep="true"}},
      {decorID=11486, title="Replica Saga of the Valarjar", decorType="Miscellaneous - All", source={type="vendor", itemID=257396, currency="3000", currencytype="Order Resources"}, requirements={achievement={id=60973, title="Legendary Research of the Valarjar"}, rep="true"}},
    }
  },
  {
    title="Mrgrgrl",
    source={
      id=256826,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="641:6872:9510",
    },
    items={
      --       {decorID=11908, title="Shellscale Standard", decorType="Misc Accents", source={type="vendor", itemID=258222, currency="600", currencytype="Order Resources"}, requirements={quest={id=41143, title="Mglrgrs Of Our Grmlgrlr"}, rep="true"}}, -- Early Access / Midnight pre-patch
    }
  },
  {
    title="Mynde",
    source={
      id=255101,
      type="vendor",
      faction="Neutral",
      zone="Suramar",
      worldmap="680:4558:6915",
    },
    items={
      {decorID=11483, title="Suramar Stepping Stone", decorType="Floor", source={type="vendor", itemID=257393, currency="50", currencytype="Ancient Mana"}, requirements={rep="true"}},
      {decorID=11708, title="Suramar Stepping Stone Set", decorType="Floor", source={type="vendor", itemID=257598, currency="125", currencytype="Ancient Mana"}, requirements={rep="true"}},
    }
  },
  {
    title="Berazus",
    source={
      id=89939,
      type="vendor",
      faction="Horde",
      zone="Azsuna",
      worldmap="630:4780:2360",
    },
    items={
      {decorID=2530, title="Tome of the Lost Dragon", decorType="Ornamental", source={type="vendor", itemID=246864, currency="1000", currencytype="Order Resources"}, requirements={quest={id=37470, title="The Head of the Snake"}, rep="true"}},
    }
  },
}
