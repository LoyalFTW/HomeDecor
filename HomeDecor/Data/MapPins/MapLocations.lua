local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.MapPinVendors = {
  [17] = {
    { id = 44337, mapID = 17, x = 0.458, y = 0.886, zone = "Surwich, Blasted Lands", faction = "Alliance" },
  },
  [21] = {
    { id = 2140, mapID = 21, x = 0.4406, y = 0.3968, zone = "Silverpine Forest", faction = "Horde" },
  },
  [23] = {
    { id = 45417, mapID = 23, x = 0.738, y = 0.522, zone = "Light's Hope Chapel", faction = "Neutral" },
    { id = 100196, mapID = 23, x = 0.7564, y = 0.4909, zone = "Sanctum of Light", faction = "Neutral" },
    { id = 142115, mapID = 23, x = 0.738, y = 0.522, zone = "Boralus Harbor", faction = "Alliance" },
  },
  [25] = {
    { id = 13217, mapID = 25, x = 0.448, y = 0.464, zone = "Hillsbrad Foothills", faction = "Alliance" },
  },
  [32] = {
    { id = 14624, mapID = 32, x = 0.386, y = 0.287, zone = "Searing Gorge", faction = "Horde" },
  },
  [36] = {
    { id = 115805, mapID = 36, x = 0.468, y = 0.446, zone = "Burning Steppes", faction = "Horde" },
  },
  [47] = {
    { id = 44114, mapID = 47, x = 0.2027, y = 0.5835, zone = "Duskwood", faction = "Alliance" },
  },
  [48] = {
    { id = 1465, mapID = 48, x = 0.356, y = 0.49, zone = "Thelsamar, Loch Modan", faction = "Alliance" },
  },
  [50] = {
    { id = 2483, mapID = 50, x = 0.438, y = 0.232, zone = "Stranglethorn Vale", faction = "Neutral" },
  },
  [56] = {
    { id = 3178, mapID = 56, x = 0.0627, y = 0.5745, zone = "Wetlands", faction = "Neutral" },
  },
  [70] = {
    { id = 23995, mapID = 70, x = 0.419, y = 0.739, zone = "Mudsprocket, Dustwallow Marsh", faction = "Neutral" },
  },
  [84] = {
    { id = 49877, mapID = 84, x = 0.6775, y = 0.7306, zone = "Stormwind City", faction = "Alliance" },
    { id = 254603, mapID = 84, x = 0.778, y = 0.658, zone = "Stormwind City", faction = "Alliance" },
    { id = 256071, mapID = 84, x = 0.4926, y = 0.8009, zone = "Stormwind City", faction = "Alliance" },
    { id = 261231, mapID = 84, x = 0.4851, y = 0.6876, zone = "Stormwind City", faction = "Neutral" },
  },
  [85] = {
    { id = 50488, mapID = 85, x = 0.502, y = 0.584, zone = "Orgrimmar", faction = "Horde" },
    { id = 254606, mapID = 85, x = 0.388, y = 0.7193, zone = "Orgrimmar", faction = "Horde" },
    { id = 261262, mapID = 85, x = 0.4837, y = 0.8115, zone = "Orgrimmar", faction = "Neutral" },
  },
  [86] = {
    { id = 256119, mapID = 86, x = 0.9987, y = 0.121, zone = "Orgrimmar", faction = "Horde" },
  },
  [87] = {
    { id = 50309, mapID = 87, x = 0.556, y = 0.482, zone = "Ironforge", faction = "Alliance" },
    { id = 253232, mapID = 87, x = 0.758, y = 0.094, zone = "The Library, Ironforge", faction = "Alliance" },
    { id = 253235, mapID = 87, x = 0.2481, y = 0.4396, zone = "Dun Morogh", faction = "Alliance" },
  },
  [88] = {
    { id = 50483, mapID = 88, x = 0.462, y = 0.506, zone = "Thunder Bluff", faction = "Horde" },
  },
  [89] = {
    { id = 50307, mapID = 89, x = 0.372, y = 0.476, zone = "Darnassus", faction = "Alliance" },
  },
  [90] = {
    { id = 50304, mapID = 90, x = 0.632, y = 0.49, zone = "Undercity, Orgrimmar", faction = "Horde" },
  },
  [95] = {
    { id = 16528, mapID = 95, x = 0.476, y = 0.324, zone = "Ghostlands", faction = "Horde" },
  },
  [114] = {
    { id = 25206, mapID = 114, x = 0.4304, y = 0.1381, zone = "Borean Tundra", faction = "Horde" },
  },
  [116] = {
    { id = 27391, mapID = 116, x = 0.324, y = 0.598, zone = "Grizzly Hills", faction = "Alliance" },
  },
  [119] = {
    { id = 28038, mapID = 119, x = 0.268, y = 0.592, zone = "Sholazar Basin", faction = "Neutral" },
  },
  [217] = {
    { id = 211065, mapID = 217, x = 0.604, y = 0.924, zone = "Stormglen Village, Gilneas", faction = "Alliance" },
  },
  [218] = {
    { id = 216888, mapID = 218, x = 0.6199, y = 0.3672, zone = "Ruins of Gilneas", faction = "Alliance" },
  },
  [241] = {
    { id = 49386, mapID = 241, x = 0.4861, y = 0.3068, zone = "Twilight Highlands", faction = "Neutral" },
    { id = 249196, mapID = 241, x = 0.496, y = 0.812, zone = "Twilight Highlands", faction = "Neutral" },
    { id = 253227, mapID = 241, x = 0.4974, y = 0.2957, zone = "Twilight Highlands", faction = "Neutral" },
  },
  [371] = {
    { id = 58414, mapID = 371, x = 0.567, y = 0.4438, zone = "The Jade Forest", faction = "Neutral" },
  },
  [376] = {
    { id = 58706, mapID = 376, x = 0.532, y = 0.518, zone = "Valley of the Four Winds", faction = "Horde" },
  },
  [379] = {
    { id = 59698, mapID = 379, x = 0.5724, y = 0.6096, zone = "Kun-Lai Summit", faction = "Horde" },
  },
  [390] = {
    { id = 64001, mapID = 390, x = 0.628, y = 0.232, zone = "Vale of Eternal Blossoms", faction = "Horde" },
    { id = 64605, mapID = 390, x = 0.8223, y = 0.2933, zone = "Vale of Eternal Blossoms", faction = "Horde" },
  },
  [433] = {
    { id = 62088, mapID = 433, x = 0.2388, y = 0.2179, zone = "Vale of Eternal Blossoms", faction = "Horde" },
  },
  [469] = {
    { id = 1247, mapID = 469, x = 0.9392, y = 0.7091, zone = "Dun Morogh", faction = "Alliance" },
  },
  [499] = {
    { id = 68363, mapID = 499, x = 0.51, y = 0.3, zone = "Bizmo's Brawlpub", faction = "Alliance" },
  },
  [500] = {
    { id = 151941, mapID = 500, x = 0.5425, y = 0.2513, zone = "Deeprun Tram", faction = "Neutral" },
  },
  [503] = {
    { id = 68364, mapID = 503, x = 0.52, y = 0.278, zone = "Brawl'gar Arena", faction = "Horde" },
    { id = 145695, mapID = 503, x = 0.5084, y = 0.2913, zone = "Brawl'gar Arena", faction = "Neutral" },
  },
  [525] = {
    { id = 76872, mapID = 525, x = 0.48, y = 0.66, zone = "Frostwall", faction = "Horde" },
    { id = 79812, mapID = 525, x = 0.48, y = 0.66, zone = "Frostwall", faction = "Horde" },
    { id = 87015, mapID = 525, x = 0.48, y = 0.66, zone = "Frostwall", faction = "Horde" },
    { id = 87312, mapID = 525, x = 0.48, y = 0.66, zone = "Frostwall", faction = "Neutral" },
  },
  [535] = {
    { id = 256946, mapID = 535, x = 0.7041, y = 0.5754, zone = "Talador", faction = "Neutral" },
  },
  [539] = {
    { id = 81133, mapID = 539, x = 0.462, y = 0.393, zone = "Shadowmoon Valley (Draenor)", faction = "Alliance" },
    { id = 85427, mapID = 539, x = 0.31, y = 0.15, zone = "Lunarfall", faction = "Alliance" },
    { id = 86779, mapID = 539, x = 0.31, y = 0.15, zone = "Lunarfall", faction = "Horde" },
    { id = 88220, mapID = 539, x = 0.31, y = 0.15, zone = "Lunarfall", faction = "Alliance" },
  },
  [542] = {
    { id = 87775, mapID = 542, x = 0.467, y = 0.4496, zone = "Spires of Arak", faction = "Neutral" },
  },
  [579] = {
    { id = 78564, mapID = 579, x = 0.378, y = 0.334, zone = "Lunarfall", faction = "Alliance" },
    { id = 88223, mapID = 579, x = 0.378, y = 0.334, zone = "Lunarfall", faction = "Neutral" },
  },
  [582] = {
    { id = 78564, mapID = 582, x = 0.385, y = 0.314, zone = "Lunarfall", faction = "Alliance" },
    { id = 88223, mapID = 582, x = 0.385, y = 0.314, zone = "Lunarfall", faction = "Neutral" },
  },
  [585] = {
    { id = 86776, mapID = 585, x = 0.514, y = 0.62, zone = "Frostwall", faction = "Horde" },
  },
  [590] = {
    { id = 79774, mapID = 590, x = 0.438, y = 0.474, zone = "Frostwall", faction = "Horde" },
  },
  [619] = {
    { id = 251042, mapID = 619, x = 0.5506, y = 0.7797, zone = "Dalaran", faction = "Neutral" },
  },
  [622] = {
    { id = 85932, mapID = 622, x = 0.464, y = 0.746, zone = "Stormshield, Ashran", faction = "Alliance" },
    { id = 85946, mapID = 622, x = 0.4449, y = 0.7483, zone = "Stormshield", faction = "Alliance" },
    { id = 85950, mapID = 622, x = 0.4097, y = 0.5954, zone = "Stormshield", faction = "Alliance" },
  },
  [624] = {
    { id = 86037, mapID = 624, x = 0.5348, y = 0.5974, zone = "Warspear", faction = "Horde" },
  },
  [626] = {
    { id = 105986, mapID = 626, x = 0.2692, y = 0.3683, zone = "The Hall of Shadows", faction = "Neutral" },
    { id = 112716, mapID = 626, x = 0.434, y = 0.494, zone = "Dalaran", faction = "Alliance" },
  },
  [627] = {
    { id = 252043, mapID = 627, x = 0.6746, y = 0.3389, zone = "Dalaran", faction = "Alliance" },
  },
  [628] = {
    { id = 105333, mapID = 628, x = 0.6736, y = 0.6322, zone = "Dalaran", faction = "Neutral" },
  },
  [630] = {
    { id = 89939, mapID = 630, x = 0.478, y = 0.236, zone = "Azsuna", faction = "Horde" },
  },
  [641] = {
    { id = 106901, mapID = 641, x = 0.547, y = 0.7325, zone = "Val'sharah", faction = "Horde" },
    { id = 109306, mapID = 641, x = 0.602, y = 0.8486, zone = "Val'sharah", faction = "Neutral" },
    { id = 112634, mapID = 641, x = 0.5714, y = 0.7191, zone = "Val'sharah", faction = "Alliance" },
    { id = 252498, mapID = 641, x = 0.4209, y = 0.5938, zone = "Val'sharah", faction = "Horde" },
    { id = 253387, mapID = 641, x = 0.5426, y = 0.7236, zone = "Val'sharah", faction = "Neutral" },
    { id = 253434, mapID = 641, x = 0.7992, y = 0.7389, zone = "Suramar", faction = "Neutral" },
  },
  [647] = {
    { id = 93550, mapID = 647, x = 0.439, y = 0.3717, zone = "Acherus: The Ebon Hold", faction = "Horde" },
  },
  [650] = {
    { id = 106902, mapID = 650, x = 0.4588, y = 0.6049, zone = "Highmountain", faction = "Neutral" },
    { id = 108537, mapID = 650, x = 0.4162, y = 0.1044, zone = "Highmountain", faction = "Neutral" },
  },
  [652] = {
    { id = 108017, mapID = 652, x = 0.547, y = 0.774, zone = "Thunder Totem, Highmountain", faction = "Neutral" },
  },
  [680] = {
    { id = 93971, mapID = 680, x = 0.4032, y = 0.6973, zone = "Suramar", faction = "Neutral" },
    { id = 97140, mapID = 680, x = 0.3713, y = 0.4655, zone = "Suramar", faction = "Horde" },
    { id = 115736, mapID = 680, x = 0.3713, y = 0.4655, zone = "Suramar", faction = "Neutral" },
    { id = 248594, mapID = 680, x = 0.509, y = 0.7778, zone = "Suramar", faction = "Neutral" },
    { id = 252969, mapID = 680, x = 0.4963, y = 0.6283, zone = "Suramar", faction = "Neutral" },
    { id = 255101, mapID = 680, x = 0.4558, y = 0.6915, zone = "Suramar", faction = "Neutral" },
    { id = 256826, mapID = 680, x = 0.1511, y = 0.5333, zone = "Suramar", faction = "Neutral" },
  },
  [695] = {
    { id = 112392, mapID = 695, x = 0.5549, y = 0.2591, zone = "Skyhold", faction = "Horde" },
  },
  [702] = {
    { id = 112401, mapID = 702, x = 0.3862, y = 0.2377, zone = "Netherlight Temple", faction = "Horde" },
  },
  [709] = {
    { id = 112338, mapID = 709, x = 0.5033, y = 0.5913, zone = "Mandori Village", faction = "Neutral" },
  },
  [717] = {
    { id = 112434, mapID = 717, x = 0.5876, y = 0.3269, zone = "Dreadscar Rift", faction = "Alliance" },
  },
  [720] = {
    { id = 112407, mapID = 720, x = 0.61, y = 0.5673, zone = "The Fel Hammer", faction = "Neutral" },
  },
  [726] = {
    { id = 112318, mapID = 726, x = 0.3032, y = 0.6069, zone = "The Maelstrom", faction = "Alliance" },
  },
  [735] = {
    { id = 112440, mapID = 735, x = 0.4475, y = 0.5787, zone = "Hall of the Guardian", faction = "Neutral" },
  },
  [739] = {
    { id = 103693, mapID = 739, x = 0.4456, y = 0.4888, zone = "Trueshot Lodge", faction = "Neutral" },
  },
  [747] = {
    { id = 112323, mapID = 747, x = 0.4002, y = 0.1772, zone = "The Dreamgrove", faction = "Neutral" },
  },
  [862] = {
    { id = 251921, mapID = 862, x = 0.58, y = 0.626, zone = "Port of Zandalar, Dazar'alor", faction = "Horde" },
  },
  [863] = {
    { id = 135459, mapID = 863, x = 0.3911, y = 0.7947, zone = "Nazmir", faction = "Horde" },
  },
  [895] = {
    { id = 252316, mapID = 895, x = 0.534, y = 0.312, zone = "Tiragarde Sound", faction = "Alliance" },
  },
  [940] = {
    { id = 127151, mapID = 940, x = 0.6822, y = 0.5691, zone = "The Vindicaar", faction = "Horde" },
  },
  [942] = {
    { id = 252313, mapID = 942, x = 0.596, y = 0.696, zone = "Stormsong Valley", faction = "Alliance" },
  },
  [1161] = {
    { id = 135808, mapID = 1161, x = 0.676, y = 0.218, zone = "Boralus", faction = "Alliance" },
    { id = 246721, mapID = 1161, x = 0.5629, y = 0.4582, zone = "Tiragarde Sound", faction = "Alliance" },
    { id = 252345, mapID = 1161, x = 0.7074, y = 0.1566, zone = "Tiragarde Sound", faction = "Alliance" },
  },
  [1163] = {
    { id = 148923, mapID = 1163, x = 0.446, y = 0.944, zone = "Port of Zandalar, Dazar'alor", faction = "Horde" },
  },
  [1164] = {
    { id = 252326, mapID = 1164, x = 0.3694, y = 0.5917, zone = "Zuldazar", faction = "Horde" },
  },
  [1165] = {
    { id = 148924, mapID = 1165, x = 0.5122, y = 0.9508, zone = "Zuldazar", faction = "Horde" },
  },
  [1186] = {
    { id = 144129, mapID = 1186, x = 0.4977, y = 0.3222, zone = "Blackrock Depths", faction = "Neutral" },
  },
  [1462] = {
    { id = 150716, mapID = 1462, x = 0.737, y = 0.3691, zone = "Mechagon", faction = "Neutral" },
  },
  [1473] = {
    { id = 152194, mapID = 1473, x = 0.5015, y = 0.6693, zone = "Chamber of Heart", faction = "Neutral" },
  },
  [1530] = {
    { id = 64032, mapID = 1530, x = 0.852, y = 0.616, zone = "Vale of Eternal Blossoms", faction = "Alliance" },
  },
  [1543] = {
    { id = 162804, mapID = 1543, x = 0.468, y = 0.416, zone = "The Maw", faction = "Alliance" },
  },
  [1699] = {
    { id = 174710, mapID = 1699, x = 0.54, y = 0.248, zone = "Sinfall", faction = "Neutral" },
  },
  [2022] = {
    { id = 188265, mapID = 2022, x = 0.478, y = 0.822, zone = "Dragonscale Basecamp", faction = "Neutral" },
    { id = 189226, mapID = 2022, x = 0.47, y = 0.826, zone = "Dragonscale Basecamp", faction = "Neutral" },
    { id = 190155, mapID = 2022, x = 0.5499, y = 0.3078, zone = "The Waking Shores", faction = "Horde" },
    { id = 191025, mapID = 2022, x = 0.62, y = 0.738, zone = "Ruby Lifeshrine, The Waking Shores", faction = "Neutral" },
    { id = 210608, mapID = 2022, x = 0.584, y = 0.678, zone = "All Dragonflight Zones, moves with the Dreamsurge Event", faction = "Neutral" },
  },
  [2025] = {
    { id = 209192, mapID = 2025, x = 0.614, y = 0.314, zone = "Thaldraszus", faction = "Neutral" },
    { id = 209220, mapID = 2025, x = 0.522, y = 0.808, zone = "Eon's Fringe, Thaldraszus", faction = "Neutral" },
  },
  [2112] = {
    { id = 193015, mapID = 2112, x = 0.582, y = 0.356, zone = "Valdrakken", faction = "Neutral" },
    { id = 193659, mapID = 2112, x = 0.368, y = 0.506, zone = "Valdrakken", faction = "Neutral" },
    { id = 196637, mapID = 2112, x = 0.2552, y = 0.3365, zone = "Valdrakken", faction = "Neutral" },
    { id = 199605, mapID = 2112, x = 0.584, y = 0.574, zone = "Valdrakken", faction = "Neutral" },
    { id = 253067, mapID = 2112, x = 0.7153, y = 0.4962, zone = "Valdrakken", faction = "Horde" },
  },
  [2151] = {
    { id = 253086, mapID = 2151, x = 0.352, y = 0.57, zone = "The Forbidden Reach", faction = "Neutral" },
  },
  [2213] = {
    { id = 218202, mapID = 2213, x = 0.5, y = 0.316, zone = "City of Threads", faction = "Horde" },
  },
  [2214] = {
    { id = 221390, mapID = 2214, x = 0.432, y = 0.328, zone = "Gundargaz, Ringing Deeps", faction = "Neutral" },
    { id = 252887, mapID = 2214, x = 0.434, y = 0.33, zone = "The Ringing Deeps", faction = "Neutral" },
    { id = 256783, mapID = 2214, x = 0.4335, y = 0.3327, zone = "The Ringing Deeps", faction = "Alliance" },
  },
  [2215] = {
    { id = 217642, mapID = 2215, x = 0.428, y = 0.5583, zone = "Hallowfall", faction = "Neutral" },
    { id = 240852, mapID = 2215, x = 0.2828, y = 0.5618, zone = "Hallowfall", faction = "Neutral" },
  },
  [2239] = {
    { id = 216284, mapID = 2239, x = 0.54, y = 0.608, zone = "Amirdrassil", faction = "Alliance" },
    { id = 216285, mapID = 2239, x = 0.484, y = 0.536, zone = "Amirdrassil", faction = "Neutral" },
    { id = 216286, mapID = 2239, x = 0.466, y = 0.706, zone = "Amirdrassil", faction = "Alliance" },
  },
  [2248] = {
    { id = 226205, mapID = 2248, x = 0.744, y = 0.452, zone = "Isle of Dorn", faction = "Neutral" },
    { id = 252901, mapID = 2248, x = 0.42, y = 0.73, zone = "Freywold Village, Isle of Dorn", faction = "Neutral" },
  },
  [2339] = {
    { id = 219217, mapID = 2339, x = 0.552, y = 0.764, zone = "Dornogal", faction = "Neutral" },
    { id = 219318, mapID = 2339, x = 0.57, y = 0.606, zone = "Dornogal", faction = "Horde" },
    { id = 223728, mapID = 2339, x = 0.392, y = 0.244, zone = "Dornogal", faction = "Neutral" },
    { id = 252312, mapID = 2339, x = 0.5284, y = 0.68, zone = "Dornogal", faction = "Neutral" },
    { id = 252910, mapID = 2339, x = 0.5468, y = 0.5724, zone = "Dornogal", faction = "Horde" },
  },
  [2346] = {
    { id = 226994, mapID = 2346, x = 0.34, y = 0.708, zone = "Undermine", faction = "Neutral" },
    { id = 231396, mapID = 2346, x = 0.3078, y = 0.3893, zone = "Undermine", faction = "Horde" },
    { id = 231405, mapID = 2346, x = 0.6343, y = 0.168, zone = "Undermine", faction = "Horde" },
    { id = 231406, mapID = 2346, x = 0.3916, y = 0.222, zone = "Undermine", faction = "Horde" },
    { id = 231407, mapID = 2346, x = 0.5334, y = 0.7269, zone = "Undermine", faction = "Horde" },
    { id = 231408, mapID = 2346, x = 0.2718, y = 0.7254, zone = "Undermine", faction = "Horde" },
    { id = 231409, mapID = 2346, x = 0.438, y = 0.508, zone = "Undermine", faction = "Neutral" },
    { id = 239333, mapID = 2346, x = 0.262, y = 0.428, zone = "Undermine", faction = "Horde" },
    { id = 251911, mapID = 2346, x = 0.4319, y = 0.5047, zone = "Undermine", faction = "Neutral" },
  },
  [2351] = {
    { id = 240465, mapID = 2351, x = 0.6829, y = 0.755, zone = "Razorwind Shores", faction = "Horde" },
    { id = 248525, mapID = 2351, x = 0.5413, y = 0.5598, zone = "Moderate Mechanization", faction = "Horde" },
    { id = 249684, mapID = 2351, x = 0.5436, y = 0.5612, zone = "Friend of the Grummles", faction = "Horde" },
    { id = 250820, mapID = 2351, x = 0.542, y = 0.562, zone = "Reaching Beyond the Possible", faction = "Horde" },
    { id = 252605, mapID = 2351, x = 0.544, y = 0.562, zone = "Consortium Consternation", faction = "Horde" },
    { id = 252917, mapID = 2351, x = 0.5436, y = 0.5597, zone = "Artistic Aid", faction = "Horde" },
    { id = 253596, mapID = 2351, x = 0.538, y = 0.574, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255278, mapID = 2351, x = 0.5412, y = 0.5911, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255297, mapID = 2351, x = 0.5413, y = 0.5905, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255298, mapID = 2351, x = 0.5356, y = 0.5849, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255299, mapID = 2351, x = 0.5348, y = 0.5853, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255301, mapID = 2351, x = 0.54, y = 0.584, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255319, mapID = 2351, x = 0.403, y = 0.73, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255325, mapID = 2351, x = 0.398, y = 0.728, zone = "Razorwind Shores", faction = "Horde" },
    { id = 255326, mapID = 2351, x = 0.3991, y = 0.733, zone = "Razorwind Shores", faction = "Horde" },
    { id = 257307, mapID = 2351, x = 0.544, y = 0.562, zone = "Consortium Consternation", faction = "Horde" },
  },
  [2352] = {
    { id = 255203, mapID = 2352, x = 0.5195, y = 0.3831, zone = "Founder's Point", faction = "Alliance" },
    { id = 255213, mapID = 2352, x = 0.52, y = 0.384, zone = "Founder's Point", faction = "Alliance" },
    { id = 255216, mapID = 2352, x = 0.522, y = 0.38, zone = "Founder's Point", faction = "Alliance" },
    { id = 255218, mapID = 2352, x = 0.522, y = 0.378, zone = "Founder's Point", faction = "Alliance" },
    { id = 255221, mapID = 2352, x = 0.5347, y = 0.4093, zone = "Founder's Point", faction = "Alliance" },
    { id = 255222, mapID = 2352, x = 0.624, y = 0.802, zone = "Founder's Point", faction = "Alliance" },
    { id = 255228, mapID = 2352, x = 0.624, y = 0.8, zone = "Founder's Point", faction = "Alliance" },
    { id = 255230, mapID = 2352, x = 0.6223, y = 0.803, zone = "Founder's Point", faction = "Alliance" },
    { id = 256750, mapID = 2352, x = 0.583, y = 0.6168, zone = "Founder's Point", faction = "Alliance" },
    { id = 257897, mapID = 2352, x = 0.5304, y = 0.3805, zone = "Smell Sensation", faction = "Neutral" },
  },
  [2393] = {
    { id = 224353, mapID = 2393, x = 0.4315, y = 0.5537, zone = "Orgrimmar", faction = "Neutral" },
    { id = 241451, mapID = 2393, x = 0.4364, y = 0.5147, zone = "Silvermoon City", faction = "Alliance" },
    { id = 241453, mapID = 2393, x = 0.4347, y = 0.5374, zone = "Silvermoon City", faction = "Neutral" },
    { id = 242398, mapID = 2393, x = 0.5276, y = 0.779, zone = "Silvermoon City", faction = "Neutral" },
    { id = 242399, mapID = 2393, x = 0.5253, y = 0.7887, zone = "Silvermoon City", faction = "Neutral" },
    { id = 243350, mapID = 2393, x = 0.4792, y = 0.5344, zone = "Silvermoon City", faction = "Alliance" },
    { id = 243353, mapID = 2393, x = 0.4823, y = 0.5431, zone = "Silvermoon City", faction = "Alliance" },
    { id = 243359, mapID = 2393, x = 0.4704, y = 0.5166, zone = "Silvermoon City", faction = "Alliance" },
    { id = 243531, mapID = 2393, x = 0.4304, y = 0.5599, zone = "Silvermoon City", faction = "Alliance" },
    { id = 243555, mapID = 2393, x = 0.4667, y = 0.5119, zone = "Silvermoon City", faction = "Alliance" },
    { id = 250982, mapID = 2393, x = 0.522, y = 0.474, zone = "Silvermoon City", faction = "Horde" },
    { id = 251091, mapID = 2393, x = 0.5072, y = 0.5608, zone = "Silvermoon City", faction = "Neutral" },
    { id = 252915, mapID = 2393, x = 0.442, y = 0.628, zone = "The Bazaar, Silvermoon City", faction = "Neutral" },
    { id = 252916, mapID = 2393, x = 0.4405, y = 0.6276, zone = "Silvermoon City", faction = "Neutral" },
    { id = 255495, mapID = 2393, x = 0.4768, y = 0.5055, zone = "Silvermoon City", faction = "Neutral" },
    { id = 256009, mapID = 2393, x = 0.4315, y = 0.5537, zone = "Silvermoon City", faction = "Alliance" },
    { id = 256026, mapID = 2393, x = 0.483, y = 0.5131, zone = "Silvermoon City", faction = "Neutral" },
    { id = 256828, mapID = 2393, x = 0.5117, y = 0.5645, zone = "Silvermoon City", faction = "Horde" },
    { id = 257914, mapID = 2393, x = 0.5644, y = 0.6991, zone = "Silvermoon City", faction = "Alliance" },
    { id = 258181, mapID = 2393, x = 0.5579, y = 0.6605, zone = "Silvermoon City", faction = "Alliance" },
    { id = 264056, mapID = 2393, x = 0.3163, y = 0.7667, zone = "Silvermoon City", faction = "Neutral" },
  },
  [2395] = {
    { id = 240838, mapID = 2395, x = 0.4346, y = 0.4742, zone = "Eversong Woods", faction = "Neutral" },
    { id = 242723, mapID = 2395, x = 0.4352, y = 0.4752, zone = "Eversong Woods", faction = "Neutral" },
    { id = 242724, mapID = 2395, x = 0.4344, y = 0.4756, zone = "Eversong Woods", faction = "Neutral" },
    { id = 242725, mapID = 2395, x = 0.4354, y = 0.475, zone = "Eversong Woods", faction = "Neutral" },
    { id = 242726, mapID = 2395, x = 0.4349, y = 0.4765, zone = "Eversong Woods", faction = "Neutral" },
  },
  [2405] = {
    { id = 248328, mapID = 2405, x = 0.5259, y = 0.729, zone = "Voidstorm", faction = "Neutral" },
    { id = 259922, mapID = 2405, x = 0.5266, y = 0.7279, zone = "Voidstorm", faction = "Neutral" },
  },
  [2406] = {
    { id = 235621, mapID = 2406, x = 0.4329, y = 0.5189, zone = "Liberation of Undermine", faction = "Horde" },
  },
  [2413] = {
    { id = 240407, mapID = 2413, x = 0.5095, y = 0.5073, zone = "Harandar", faction = "Alliance" },
    { id = 251259, mapID = 2413, x = 0.4925, y = 0.5433, zone = "Harandar", faction = "Alliance" },
    { id = 252650, mapID = 2413, x = 0.5368, y = 0.5532, zone = "Harandar", faction = "Neutral" },
    { id = 255114, mapID = 2413, x = 0.5311, y = 0.5092, zone = "Harandar", faction = "Neutral" },
    { id = 258480, mapID = 2413, x = 0.5241, y = 0.5062, zone = "Harandar", faction = "Neutral" },
    { id = 258507, mapID = 2413, x = 0.5228, y = 0.5411, zone = "Harandar", faction = "Neutral" },
    { id = 258540, mapID = 2413, x = 0.5274, y = 0.5069, zone = "Harandar", faction = "Neutral" },
  },
  [2437] = {
    { id = 240279, mapID = 2437, x = 0.4595, y = 0.6592, zone = "Zul'Aman", faction = "Neutral" },
    { id = 241928, mapID = 2437, x = 0.3156, y = 0.2626, zone = "Zul'Aman", faction = "Neutral" },
    { id = 248658, mapID = 2437, x = 0.3156, y = 0.2626, zone = "Harandar", faction = "Neutral" },
    { id = 253035, mapID = 2437, x = 0.3847, y = 0.2245, zone = "Zul'Aman", faction = "Neutral" },
    { id = 254944, mapID = 2437, x = 0.4604, y = 0.6608, zone = "Zul'Aman", faction = "Neutral" },
    { id = 255095, mapID = 2437, x = 0.4522, y = 0.6984, zone = "Zul'Aman", faction = "Neutral" },
    { id = 255098, mapID = 2437, x = 0.4532, y = 0.6983, zone = "Zul'Aman", faction = "Neutral" },
    { id = 257633, mapID = 2437, x = 0.3156, y = 0.2626, zone = "Eversong Woods", faction = "Neutral" },
    { id = 258885, mapID = 2437, x = 0.3867, y = 0.2374, zone = "Zul'Aman", faction = "Neutral" },
    { id = 259864, mapID = 2437, x = 0.0314, y = 0.1871, zone = "Eversong Woods", faction = "Neutral" },
    { id = 260180, mapID = 2437, x = 0.6846, y = 0.199, zone = "Zul'Aman", faction = "Neutral" },
    { id = 257632, mapID = 2437, x = 0.3156, y = 0.2626, zone = "Voidstorm", faction = "Neutral" },
  },
  [2444] = {
    { id = 258328, mapID = 2444, x = 0.3935, y = 0.8095, zone = "Masters' Perch", faction = "Neutral" },
  },
  [2472] = {
    { id = 235252, mapID = 2472, x = 0.4033, y = 0.2936, zone = "K'aresh", faction = "Neutral" },
    { id = 235314, mapID = 2472, x = 0.432, y = 0.348, zone = "Tazavesh, the Veiled Market, K'aresh", faction = "Neutral" },
  },
  [2541] = {
    { id = 252873, mapID = 2541, x = 0.4194, y = 0.4978, zone = "Arcantina", faction = "Alliance" },
  },
}

return NS.Data.MapPinVendors

