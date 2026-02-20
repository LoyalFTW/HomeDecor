local ADDON, NS = ...

NS.Data = NS.Data or {}

NS.Data.Trainers = {

  Alchemy = {
    Classic = {
      { source={ id=1215,  type="trainer", faction="Alliance", name="Alchemist Mallory", zone="Elwynn Forest",        worldmap="37:3980:4830" } },
      { source={ id=3347,  type="trainer", faction="Horde",    name="Yelmak",            zone="Orgrimmar",            worldmap="85:5560:4660" } },
    },
    Outland = {
      { source={ id=18802, type="trainer", faction="Alliance", name="Alchemist Gribble",      zone="Hellfire Peninsula", worldmap="100:5380:6580" } },
      { source={ id=16588, type="trainer", faction="Horde",    name="Apothecary Antonivich",  zone="Hellfire Peninsula", worldmap="100:5240:3650" } },
      { source={ id=33630, type="trainer", faction="Neutral",  name="Aelthin",                zone="Shattrath City",     worldmap="111:3820:7110", note="Scryers" } },
      { source={ id=33674, type="trainer", faction="Neutral",  name="Alchemist Kanhu",        zone="Shattrath City",     worldmap="111:3870:3010", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28703, type="trainer", faction="Neutral",  name="Linzy Blackbolt",   zone="Dalaran",              worldmap="125:4240:3200" } },
    },
    Cataclysm = {
      { source={ id=1215,  type="trainer", faction="Alliance", name="Alchemist Mallory", zone="Elwynn Forest",        worldmap="37:3980:4830" } },
      { source={ id=3347,  type="trainer", faction="Horde",    name="Yelmak",            zone="Orgrimmar",            worldmap="85:5560:4660" } },
    },
    Pandaria = {
      { source={ id=56777, type="trainer", faction="Neutral",  name="Ni Gentlepaw",      zone="The Jade Forest",      worldmap="371:4650:4590" } },
    },
    Draenor = {
      { source={ id=85905, type="trainer", faction="Alliance", name="Jaiden Trask",      zone="Stormshield, Ashran",  worldmap="622:3640:6920" } },
      { source={ id=87542, type="trainer", faction="Horde",    name="Joshua Alvarez",    zone="Warspear, Ashran",     worldmap="624:6060:2720" } },
    },
    Legion = {
      { source={ id=92458, type="trainer", faction="Neutral",  name="Deucus Valdera",    zone="Dalaran",              worldmap="628:4130:3340" } },
    },
    ["Kul Tiran"] = {
      { source={ id=132228, type="trainer", faction="Alliance", name="Elric Whalgrene",  zone="Boralus",              worldmap="1161:5410:8920" } },
      { source={ id=122703, type="trainer", faction="Horde",    name="Clever Kumali",    zone="Dazar'alor",           worldmap="1163:4220:3800" } },
    },
    Shadowlands = {
      { source={ id=156687, type="trainer", faction="Neutral",  name="Elixirist Au'pyr", zone="Oribos",               worldmap="1669:3920:4040" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185545, type="trainer", faction="Neutral",  name="Conflago",         zone="Valdrakken",           worldmap="2112:3640:7140" } },
    },
    ["Khaz Algar"] = {
      { source={ id=226868, type="trainer", faction="Neutral",  name="Tarig",            zone="Dornogal",             worldmap="2339:4740:7060" } },
    },
  },

  Blacksmithing = {
    Classic = {
      { source={ id=514,   type="trainer", faction="Alliance", name="Smith Argus",       zone="Stormwind City",       worldmap="84:6480:4820" } },
      { source={ id=3355,  type="trainer", faction="Horde",    name="Saru Steelfury",    zone="Orgrimmar",            worldmap="85:7640:3440" } },
    },
    Outland = {
      { source={ id=16823, type="trainer", faction="Neutral",  name="Kradu Grimblade",   zone="Shattrath City",       worldmap="111:6980:4240", note="Lower City" } },
      { source={ id=33631, type="trainer", faction="Neutral",  name="Barien",            zone="Shattrath City",       worldmap="111:4330:6480", note="Scryers" } },
      { source={ id=33675, type="trainer", faction="Neutral",  name="Onodo",             zone="Shattrath City",       worldmap="111:3760:3120", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28694, type="trainer", faction="Neutral",  name="Alard Schmied",     zone="Dalaran",              worldmap="125:4580:2740" } },
    },
    Cataclysm = {
      { source={ id=514,   type="trainer", faction="Alliance", name="Smith Argus",       zone="Stormwind City",       worldmap="84:6480:4820" } },
      { source={ id=3355,  type="trainer", faction="Horde",    name="Saru Steelfury",    zone="Orgrimmar",            worldmap="85:7640:3440" } },
    },
    Pandaria = {
      { source={ id=65114, type="trainer", faction="Neutral",  name="Len the Hammer",    zone="The Jade Forest",      worldmap="371:4840:3680" } },
    },
    Draenor = {
      { source={ id=85908, type="trainer", faction="Alliance", name="Aimee Goldforge",   zone="Stormshield, Ashran",  worldmap="622:4880:4820" } },
      { source={ id=87550, type="trainer", faction="Horde",    name="Nonn Threeratchet", zone="Warspear, Ashran",     worldmap="624:7520:3760" } },
    },
    Legion = {
      { source={ id=92183, type="trainer", faction="Neutral",  name="Alard Schmied",     zone="Dalaran",              worldmap="628:4500:2960" } },
    },
    ["Kul Tiran"] = {
      { source={ id=121193, type="trainer", faction="Alliance", name="Grix \"Ironfists\" Barlow", zone="Boralus",     worldmap="1161:7340:840" } },
      { source={ id=127112, type="trainer", faction="Horde",    name="Forgemaster Zak'aal",       zone="Dazar'alor",  worldmap="1163:4360:3860" } },
    },
    Shadowlands = {
      { source={ id=156666, type="trainer", faction="Neutral",  name="Smith Au'berk",    zone="Oribos",               worldmap="1669:4050:3140" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185546, type="trainer", faction="Neutral",  name="Metalshaper Kuroko", zone="Valdrakken",         worldmap="2112:3700:4700" } },
    },
    ["Khaz Algar"] = {
      { source={ id=223644, type="trainer", faction="Neutral",  name="Darean",           zone="Dornogal",             worldmap="2339:4910:6350" } },
    },
  },

  Cooking = {
    Pandaria = {
      { source={ id=58715, type="trainer", faction="Neutral",  name="Yan Ironpaw",       zone="Valley of the Four Winds", worldmap="376:5260:5160" } },
    },
    Draenor = {
      { source={ id=77364, type="trainer", faction="Alliance", name="Elton Black",       zone="Stormshield, Ashran",  worldmap="622:5180:5940" } },
      { source={ id=79823, type="trainer", faction="Horde",    name="Guy Fireeye",       zone="Warspear, Ashran",     worldmap="624:4260:5480" } },
    },
    ["Kul Tiran"] = {
      { source={ id=136052, type="trainer", faction="Alliance", name="\"Cap'n\" Byron Mehlsack", zone="Boralus",      worldmap="1161:7120:1080" } },
      { source={ id=122704, type="trainer", faction="Horde",    name="T'sarah the Royal Chef",   zone="Dazar'alor",   worldmap="1163:4220:3560" } },
    },
    Shadowlands = {
      { source={ id=156672, type="trainer", faction="Neutral",  name="Chef Au'krut",     zone="Oribos",               worldmap="1669:4700:2360" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185553, type="trainer", faction="Neutral",  name="Erugosa",          zone="Valdrakken",           worldmap="2112:4600:4600" } },
    },
    ["Khaz Algar"] = {
      { source={ id=229110, type="trainer", faction="Neutral",  name="Athodas",          zone="Dornogal",             worldmap="2339:4430:4560" } },
    },
  },

  Enchanting = {
    Classic = {
      { source={ id=1317,  type="trainer", faction="Alliance", name="Lucan Cordell",     zone="Stormwind City",       worldmap="84:5300:7440" } },
      { source={ id=3345,  type="trainer", faction="Horde",    name="Godan",             zone="Orgrimmar",            worldmap="85:5340:4940" } },
    },
    Outland = {
      { source={ id=19251, type="trainer", faction="Neutral",  name="Johan Barnes",        zone="Hellfire Peninsula", worldmap="100:5360:6600" } },
      { source={ id=33633, type="trainer", faction="Neutral",  name="Enchantress Andiala", zone="Shattrath City",     worldmap="111:5570:7480", note="Scryers" } },
      { source={ id=33676, type="trainer", faction="Neutral",  name="Zurii",               zone="Shattrath City",     worldmap="111:3640:4440", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28693, type="trainer", faction="Neutral",  name="Enchanter Nalthanis", zone="Dalaran",            worldmap="125:3940:4120" } },
    },
    Cataclysm = {
      { source={ id=1317,  type="trainer", faction="Alliance", name="Lucan Cordell",     zone="Stormwind City",       worldmap="84:5300:7440" } },
      { source={ id=3345,  type="trainer", faction="Horde",    name="Godan",             zone="Orgrimmar",            worldmap="85:5340:4940" } },
    },
    Pandaria = {
      { source={ id=65127, type="trainer", faction="Neutral",  name="Lai the Spellpaw",  zone="The Jade Forest",      worldmap="371:4680:4290" } },
    },
    Draenor = {
      { source={ id=85914, type="trainer", faction="Alliance", name="Bil Sparktonic",    zone="Stormshield, Ashran",  worldmap="622:5640:6440" } },
      { source={ id=86027, type="trainer", faction="Horde",    name="Hane'ke",           zone="Warspear, Ashran",     worldmap="624:7840:5240" } },
    },
    Legion = {
      { source={ id=93531, type="trainer", faction="Neutral",  name="Enchanter Nalthanis", zone="Dalaran",            worldmap="628:3850:4120" } },
    },
    ["Kul Tiran"] = {
      { source={ id=136041, type="trainer", faction="Alliance", name="Emily Fairweather", zone="Boralus",             worldmap="1161:7400:1140" } },
      { source={ id=122702, type="trainer", faction="Horde",    name="Enchantress Quinni", zone="Dazar'alor",         worldmap="1163:4700:3540" } },
    },
    Shadowlands = {
      { source={ id=156683, type="trainer", faction="Neutral",  name="Imbuer Au'vresh",  zone="Oribos",               worldmap="1669:4820:2900" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185549, type="trainer", faction="Neutral",  name="Soragosa",         zone="Valdrakken",           worldmap="2112:3000:6100" } },
    },
    ["Khaz Algar"] = {
      { source={ id=219085, type="trainer", faction="Neutral",  name="Nagad",            zone="Dornogal",             worldmap="2339:5250:7120" } },
    },
  },

  Engineering = {
    Classic = {
      { source={ id=5174,  type="trainer", faction="Alliance", name="Lilliam Sparkspindle", zone="Stormwind City",    worldmap="84:6280:3200" } },
      { source={ id=11017, type="trainer", faction="Horde",    name="Roxxik",               zone="Orgrimmar",         worldmap="85:5660:5650" } },
    },
    Outland = {
      { source={ id=19576, type="trainer", faction="Neutral",  name="Zebig",             zone="Shattrath City",       worldmap="111:3760:4240" } },
      { source={ id=33634, type="trainer", faction="Neutral",  name="Engineer Sinbei",   zone="Shattrath City",       worldmap="111:4370:6510", note="Scryers" } },
      { source={ id=33677, type="trainer", faction="Neutral",  name="Technician Mihila", zone="Shattrath City",       worldmap="111:3770:3170", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28697, type="trainer", faction="Neutral",  name="Timofey Oshenko",   zone="Dalaran",              worldmap="125:3880:2580" } },
    },
    Cataclysm = {
      { source={ id=5174,  type="trainer", faction="Alliance", name="Lilliam Sparkspindle", zone="Stormwind City",    worldmap="84:6280:3200" } },
      { source={ id=11017, type="trainer", faction="Horde",    name="Roxxik",               zone="Orgrimmar",         worldmap="85:5660:5650" } },
    },
    Pandaria = {
      { source={ id=55143, type="trainer", faction="Neutral",  name="Sally Fizzlefury",  zone="Valley of the Four Winds", worldmap="376:1610:8330" } },
    },
    Draenor = {
      { source={ id=85916, type="trainer", faction="Alliance", name="Hilda Copperfuze",  zone="Stormshield, Ashran",  worldmap="622:5980:3840" } },
      { source={ id=87552, type="trainer", faction="Horde",    name="Nik Steelrings",    zone="Warspear, Ashran",     worldmap="624:7050:3900" } },
    },
    Legion = {
      { source={ id=93520, type="trainer", faction="Neutral",  name="Timofey Oshenko",   zone="Dalaran",              worldmap="628:3820:2650" } },
    },
    ["Kul Tiran"] = {
      { source={ id=122709, type="trainer", faction="Alliance", name="Layla Evenkeel",   zone="Boralus",              worldmap="1161:5620:8500" } },
      { source={ id=131840, type="trainer", faction="Horde",    name="Shuga Blastcaps",  zone="Dazar'alor",           worldmap="1163:4500:4000" } },
    },
    Shadowlands = {
      { source={ id=156691, type="trainer", faction="Neutral",  name="Machinist Au'gur", zone="Oribos",               worldmap="1669:3800:4470" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185548, type="trainer", faction="Neutral",  name="Clinkyclick Shatterboom", zone="Valdrakken",    worldmap="2112:4200:4800" } },
    },
    ["Khaz Algar"] = {
      { source={ id=219099, type="trainer", faction="Neutral",  name="Thermalseer Arhdas", zone="Dornogal",           worldmap="2339:4910:5610" } },
    },
  },

  Inscription = {
    Classic = {
      { source={ id=30713, type="trainer", faction="Alliance", name="Catarina Stanford", zone="Stormwind City",       worldmap="84:4950:7490" } },
      { source={ id=30706, type="trainer", faction="Horde",    name="Jo'mah",            zone="Orgrimmar",            worldmap="85:3560:6920" } },
    },
    Outland = {
      { source={ id=33638, type="trainer", faction="Neutral",  name="Scribe Lanloer",    zone="Shattrath City",       worldmap="111:5600:7440", note="Scryers" } },
      { source={ id=33679, type="trainer", faction="Neutral",  name="Recorder Lidio",    zone="Shattrath City",       worldmap="111:3610:4390", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28702, type="trainer", faction="Neutral",  name="Professor Pallin",  zone="Dalaran",              worldmap="125:4260:3780" } },
    },
    Cataclysm = {
      { source={ id=30713, type="trainer", faction="Alliance", name="Catarina Stanford", zone="Stormwind City",       worldmap="84:4950:7490" } },
      { source={ id=30706, type="trainer", faction="Horde",    name="Jo'mah",            zone="Orgrimmar",            worldmap="85:3560:6920" } },
    },
    Pandaria = {
      { source={ id=64691, type="trainer", faction="Neutral",  name="Inkmaster Wei",     zone="The Jade Forest",      worldmap="371:5500:4500" } },
    },
    Draenor = {
      { source={ id=85911, type="trainer", faction="Alliance", name="Scribe Chi-Yuan",   zone="Stormshield, Ashran",  worldmap="622:6260:3400" } },
      { source={ id=86015, type="trainer", faction="Horde",    name="Joro'man",          zone="Warspear, Ashran",     worldmap="624:7380:3120" } },
    },
    Legion = {
      { source={ id=92195, type="trainer", faction="Neutral",  name="Professor Pallin",  zone="Dalaran",              worldmap="628:4130:3700" } },
    },
    ["Kul Tiran"] = {
      { source={ id=130399, type="trainer", faction="Alliance", name="Zooey Inksprocket", zone="Boralus",             worldmap="1161:7340:630" } },
      { source={ id=122711, type="trainer", faction="Horde",    name="Chronicler Kizani", zone="Dazar'alor",          worldmap="1163:4230:3960" } },
    },
    Shadowlands = {
      { source={ id=156685, type="trainer", faction="Neutral",  name="Scribe Au'tehshi", zone="Oribos",               worldmap="1669:3680:3640" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185552, type="trainer", faction="Neutral",  name="Talendara",        zone="Valdrakken",           worldmap="2112:3800:7300" } },
    },
    ["Khaz Algar"] = {
      { source={ id=217128, type="trainer", faction="Neutral",  name="Brrigan",          zone="Dornogal",             worldmap="2339:4860:7120" } },
    },
  },

  Jewelcrafting = {
    Classic = {
      { source={ id=15501, type="trainer", faction="Alliance", name="Theresa Denman",    zone="Stormwind City",       worldmap="84:6350:6160" } },
      { source={ id=15512, type="trainer", faction="Horde",    name="Lugrah",            zone="Orgrimmar",            worldmap="85:7250:3430" } },
    },
    Outland = {
      { source={ id=19539, type="trainer", faction="Neutral",  name="Hamanar",           zone="Shattrath City",       worldmap="111:3570:2060", note="Lower City" } },
      { source={ id=33637, type="trainer", faction="Neutral",  name="Kirembri Silverman", zone="Shattrath City",      worldmap="111:5820:7500", note="Scryers" } },
      { source={ id=33680, type="trainer", faction="Neutral",  name="Nemiha",            zone="Shattrath City",       worldmap="111:3600:4780", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28701, type="trainer", faction="Neutral",  name="Timothy Jones",     zone="Dalaran",              worldmap="125:4030:3510" } },
    },
    Cataclysm = {
      { source={ id=15501, type="trainer", faction="Alliance", name="Theresa Denman",    zone="Stormwind City",       worldmap="84:6350:6160" } },
      { source={ id=15512, type="trainer", faction="Horde",    name="Lugrah",            zone="Orgrimmar",            worldmap="85:7250:3430" } },
    },
    Pandaria = {
      { source={ id=65098, type="trainer", faction="Neutral",  name="Mai the Jade Shaper", zone="The Jade Forest",    worldmap="371:4800:3500" } },
    },
    Draenor = {
      { source={ id=85916, type="trainer", faction="Alliance", name="Artificer Nissea",  zone="Stormshield, Ashran",  worldmap="622:4380:3420" } },
      { source={ id=86022, type="trainer", faction="Horde",    name="Alixander Swiftsteel", zone="Warspear, Ashran",  worldmap="624:7360:3540" } },
    },
    Legion = {
      { source={ id=93527, type="trainer", faction="Neutral",  name="Timothy Jones",     zone="Dalaran",              worldmap="628:4010:3530" } },
    },
    ["Kul Tiran"] = {
      { source={ id=122694, type="trainer", faction="Alliance", name="Samuel D. Colton III", zone="Boralus",          worldmap="1161:5460:8610" } },
      { source={ id=122695, type="trainer", faction="Horde",    name="Seshuli",              zone="Dazar'alor",       worldmap="1163:4700:3780" } },
    },
    Shadowlands = {
      { source={ id=156663, type="trainer", faction="Neutral",  name="Appraiser Au'vesk", zone="Oribos",              worldmap="1669:3520:4180" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185550, type="trainer", faction="Neutral",  name="Tuluradormi",       zone="Valdrakken",          worldmap="2112:4000:6100" } },
    },
    ["Khaz Algar"] = {
      { source={ id=217129, type="trainer", faction="Neutral",  name="Makir",             zone="Dornogal",            worldmap="2339:4970:7120" } },
    },
  },

  Leatherworking = {
    Classic = {
      { source={ id=7866,  type="trainer", faction="Alliance", name="Simon Tanner",      zone="Stormwind City",       worldmap="84:7180:6280" } },
      { source={ id=3365,  type="trainer", faction="Horde",    name="Karolek",           zone="Orgrimmar",            worldmap="85:6080:5480" } },
    },
    Outland = {
      { source={ id=18771, type="trainer", faction="Neutral",  name="Darmari",           zone="Shattrath City",       worldmap="111:6720:6760", note="Lower City" } },
      { source={ id=33635, type="trainer", faction="Neutral",  name="Daenril",           zone="Shattrath City",       worldmap="111:4140:6330", note="Scryers" } },
      { source={ id=33681, type="trainer", faction="Neutral",  name="Korim",             zone="Shattrath City",       worldmap="111:3760:2780", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28700, type="trainer", faction="Neutral",  name="Diane Cannings",    zone="Dalaran",              worldmap="125:3500:2860" } },
    },
    Cataclysm = {
      { source={ id=7866,  type="trainer", faction="Alliance", name="Simon Tanner",      zone="Stormwind City",       worldmap="84:7180:6280" } },
      { source={ id=3365,  type="trainer", faction="Horde",    name="Karolek",           zone="Orgrimmar",            worldmap="85:6080:5480" } },
    },
    Pandaria = {
      { source={ id=65121, type="trainer", faction="Neutral",  name="Clean Pelt",        zone="Kun-Lai Summit",       worldmap="379:6460:6080" } },
    },
    Draenor = {
      { source={ id=85909, type="trainer", faction="Alliance", name="Jistun Sharpfeather", zone="Stormshield, Ashran", worldmap="622:5140:4180" } },
      { source={ id=87549, type="trainer", faction="Horde",    name="Garm Gladestride",    zone="Warspear, Ashran",   worldmap="624:5030:2750" } },
    },
    Legion = {
      { source={ id=93523, type="trainer", faction="Neutral",  name="Namha Moonwater",   zone="Dalaran",              worldmap="628:3540:2960" } },
    },
    ["Kul Tiran"] = {
      { source={ id=136062, type="trainer", faction="Alliance", name="Cassandra Brennor", zone="Boralus",             worldmap="1161:7550:1260" } },
      { source={ id=122698, type="trainer", faction="Horde",    name="Xanjo",             zone="Dazar'alor",          worldmap="1163:4400:3460" } },
    },
    Shadowlands = {
      { source={ id=156669, type="trainer", faction="Neutral",  name="Tanner Au'qil",    zone="Oribos",               worldmap="1669:4260:2680" } },
    },
    ["Dragon Isles"] = {
      { source={ id=185551, type="trainer", faction="Neutral",  name="Hideshaper Koruz", zone="Valdrakken",           worldmap="2112:2800:6100" } },
    },
    ["Khaz Algar"] = {
      { source={ id=219080, type="trainer", faction="Neutral",  name="Marbb",            zone="Dornogal",             worldmap="2339:5460:5800" } },
    },
  },

  Tailoring = {
    Classic = {
      { source={ id=1346,  type="trainer", faction="Alliance", name="Georgio Bolero",    zone="Stormwind City",       worldmap="84:5320:8160" } },
      { source={ id=3363,  type="trainer", faction="Horde",    name="Magar",             zone="Orgrimmar",            worldmap="85:6080:5910" } },
    },
    Outland = {
      { source={ id=33636, type="trainer", faction="Neutral",  name="Miralisse",         zone="Shattrath City",       worldmap="111:4130:6360", note="Scryers" } },
      { source={ id=33684, type="trainer", faction="Neutral",  name="Weaver Aoa",        zone="Shattrath City",       worldmap="111:3770:2710", note="Aldor" } },
    },
    Northrend = {
      { source={ id=28699, type="trainer", faction="Neutral",  name="Charles Worth",     zone="Dalaran",              worldmap="125:3630:3340" } },
    },
    Cataclysm = {
      { source={ id=1346,  type="trainer", faction="Alliance", name="Georgio Bolero",    zone="Stormwind City",       worldmap="84:5320:8160" } },
      { source={ id=3363,  type="trainer", faction="Horde",    name="Magar",             zone="Orgrimmar",            worldmap="85:6080:5910" } },
    },
    Pandaria = {
      { source={ id=57405, type="trainer", faction="Neutral",  name="Silkmaster Tsai",   zone="Valley of the Four Winds", worldmap="376:6260:5960" } },
    },
    Draenor = {
      { source={ id=85910, type="trainer", faction="Alliance", name="Joshua Fuesting",   zone="Stormshield, Ashran",  worldmap="622:5160:3720" } },
      { source={ id=86004, type="trainer", faction="Horde",    name="Saesha Silverblood", zone="Warspear, Ashran",    worldmap="624:7380:3680" } },
    },
    Legion = {
      { source={ id=93542, type="trainer", faction="Neutral",  name="Tanithria",         zone="Dalaran",              worldmap="628:4420:3180" } },
    },
    ["Kul Tiran"] = {
      { source={ id=136071, type="trainer", faction="Alliance", name="Daniel Brineweaver", zone="Boralus",            worldmap="1161:5340:8550" } },
      { source={ id=122700, type="trainer", faction="Horde",    name="Pin'jin the Patient", zone="Dazar'alor",        worldmap="1163:4440:3380" } },
    },
    Shadowlands = {
      { source={ id=156681, type="trainer", faction="Neutral",  name="Stitcher Au'phes", zone="Oribos",               worldmap="1669:4540:3180" } },
    },
    ["Dragon Isles"] = {
      { source={ id=195850, type="trainer", faction="Neutral",  name="Threadfinder Pax", zone="Valdrakken",           worldmap="2112:3200:6700" } },
    },
    ["Khaz Algar"] = {
      { source={ id=219094, type="trainer", faction="Neutral",  name="Kotag",            zone="Dornogal",             worldmap="2339:5480:6360" } },
    },
  },

}

return NS.Data.Trainers
