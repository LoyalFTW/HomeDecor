local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Midnight"] = NS.Data.Vendors["Midnight"] or {}

NS.Data.Vendors["Midnight"]["FoundersPoint"] = {

  {
    source={
      id=255203,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5195:3831"
    },
    items={
      {decorID=373, source={type="vendor", itemID=245375, currency="1000000", currencytype="money"}, requirements={quest={id=92437}}, dyeable=true, colors={"Copper","Dark Brown","Gray"}, budgetCost=3, size="Large"},
      {decorID=374, source={type="vendor", itemID=245384, currency="500000", currencytype="money"}, requirements={quest={id=92961}}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=377, source={type="vendor", itemID=235675, currency="500000", currencytype="money"}, requirements={quest={id=92988}}, dyeable=true, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=378, source={type="vendor", itemID=245355, currency="500000", currencytype="money"}, requirements={quest={id=92962}}, dyeable=true, colors={"Black","Dark Brown","Gray"}, budgetCost=3, size="Large"},
      {decorID=379, source={type="vendor", itemID=245358, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=383, source={type="vendor", itemID=235677, currency="500000", currencytype="money"}, requirements={quest={id=92987}}, dyeable=true, colors={"Dark Gray","Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=388, source={type="vendor", itemID=245383, currency="1500000", currencytype="money"}, dyeable=true, colors={"Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=389, source={type="vendor", itemID=245356, currency="500000", currencytype="money"}, requirements={quest={id=92963}}, dyeable=true, colors={"Cyan","Dark Gray","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=390, source={type="vendor", itemID=245376, currency="1250000", currencytype="money"}, requirements={quest={id=92964}}, dyeable=true, colors={"Copper","Dark Brown","Gray"}, budgetCost=3, size="Large"},
      {decorID=478, source={type="vendor", itemID=245354, currency="250000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=483, source={type="vendor", itemID=245352, currency="500000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=484, source={type="vendor", itemID=245353, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=495, source={type="vendor", itemID=245336, currency="1000000", currencytype="money"}, requirements={quest={id=92984}}, dyeable=true, colors={"Dark Brown","Deep Red","Gray"}, budgetCost=3, size="Large"},
      {decorID=498, source={type="vendor", itemID=235633, currency="500000", currencytype="money"}, dyeable=true, colors={"Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=527, source={type="vendor", itemID=236675, currency="500000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=3, size="Huge"},
      {decorID=528, source={type="vendor", itemID=236676, currency="750000", currencytype="money"}, requirements={quest={id=92966}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Huge"},
      {decorID=529, source={type="vendor", itemID=236677, currency="1000000", currencytype="money"}, requirements={quest={id=92968}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=3, size="Huge"},
      {decorID=530, source={type="vendor", itemID=236678, currency="1000000", currencytype="money"}, requirements={quest={id=92967}}, colors={"Dark Brown","Gray","Tan"}, budgetCost=3, size="Huge"},
      {decorID=533, source={type="vendor", itemID=245392, currency="500000", currencytype="money"}, colors={"Dark Brown","White"}, budgetCost=3, size="Huge"},
      {decorID=534, source={type="vendor", itemID=245393, currency="1000000", currencytype="money"}, colors={"Dark Brown","Gray","White"}, budgetCost=3, size="Huge"},
      {decorID=535, source={type="vendor", itemID=245394, currency="1000000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Huge"},
      {decorID=536, source={type="vendor", itemID=245395, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Huge"},
      {decorID=726, source={type="vendor", itemID=239075, currency="500000", currencytype="money"}, requirements={quest={id=92986}}, dyeable=true, colors={"Beige","Dark Brown","Gray"}, budgetCost=1, size="Medium"},
      {decorID=1044, source={type="vendor", itemID=242255, currency="750000", currencytype="money"}, dyeable=true, colors={"Bronze","Dark Brown","Navy Blue"}, budgetCost=3, size="Medium"},
      {decorID=1083, source={type="vendor", itemID=245370, currency="1250000", currencytype="money"}, requirements={quest={id=93119}}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=1123, source={type="vendor", itemID=245334, currency="100000", currencytype="money"}, requirements={quest={id=92979}}, dyeable=true, colors={"Copper","Dark Brown","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=1244, source={type="vendor", itemID=245335, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=1434, source={type="vendor", itemID=244530, currency="750000", currencytype="money"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=1435, source={type="vendor", itemID=244531, currency="1000000", currencytype="money"}, requirements={quest={id=92982}}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=1454, source={type="vendor", itemID=244664, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Gray","Navy Blue"}, budgetCost=5, size="Large"},
      {decorID=1455, source={type="vendor", itemID=244665, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Navy Blue"}, budgetCost=5, size="Large"},
      {decorID=1456, source={type="vendor", itemID=244666, currency="500000", currencytype="money"}, dyeable=true, colors={"Navy Blue","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=1701, source={type="vendor", itemID=245267, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Gray","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
      {decorID=1702, source={type="vendor", itemID=245268, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Gray","Royal Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=1738, source={type="vendor", itemID=245547, currency="1000000", currencytype="money"}, requirements={quest={id=92981}}, dyeable=true, colors={"Copper","Dark Brown","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=1739, source={type="vendor", itemID=245548, currency="1000000", currencytype="money"}, requirements={quest={id=92977}}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=1745, source={type="vendor", itemID=245556, currency="1000000", currencytype="money"}, requirements={quest={id=92980}}, dyeable=true, colors={"Dark Brown","Gray","Teal"}, budgetCost=3, size="Medium"},
      {decorID=1991, source={type="vendor", itemID=246101, currency="100000", currencytype="money"}, requirements={quest={id=92973}}, dyeable=true, colors={"Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=1993, source={type="vendor", itemID=246103, currency="250000", currencytype="money"}, requirements={quest={id=92972}}, dyeable=true, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Small"},
      {decorID=1996, source={type="vendor", itemID=246106, currency="100000", currencytype="money"}, requirements={quest={id=92985}}, dyeable=true, colors={"Gray","Royal Blue","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=2099, source={type="vendor", itemID=246243, currency="500000", currencytype="money"}, requirements={quest={id=92976}}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=2100, source={type="vendor", itemID=246245, currency="1000000", currencytype="money"}, requirements={quest={id=92975}}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2101, source={type="vendor", itemID=246246, currency="1250000", currencytype="money"}, requirements={quest={id=92974}}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2102, source={type="vendor", itemID=246247, currency="750000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=2103, source={type="vendor", itemID=246248, currency="500000", currencytype="money"}, colors={"Copper","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2342, source={type="vendor", itemID=246502, currency="1000000", currencytype="money"}, requirements={quest={id=92996}}, dyeable=true, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=9064, source={type="vendor", itemID=252417, currency="500000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Royal Blue"}, budgetCost=1, size="Medium"},
      {decorID=9144, source={type="vendor", itemID=252659, currency="750000", currencytype="money"}, colors={"Cyan","Dark Brown","Royal Blue"}, budgetCost=3, size="Large"},
      {decorID=9471, source={type="vendor", itemID=253589, currency="750000", currencytype="money"}, requirements={quest={id=92989}}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=9473, source={type="vendor", itemID=253592, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Gray"}, budgetCost=1, size="Medium"},
      {decorID=9474, source={type="vendor", itemID=253593, currency="1250000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=12199, source={type="vendor", itemID=258670, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=21950, source={type="vendor", itemID=272359}, dyeable=true, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=255213,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5198:3841"
    },
    items={
      {decorID=479, source={type="vendor", itemID=245365, currency="1250000", currencytype="money"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=480, source={type="vendor", itemID=245366, currency="1500000", currencytype="money"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=481, source={type="vendor", itemID=245368, currency="1500000", currencytype="money"}, colors={"Copper","Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=482, source={type="vendor", itemID=245357, currency="1500000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=485, source={type="vendor", itemID=245377, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Huge"},
      {decorID=486, source={type="vendor", itemID=245378, currency="1250000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Huge"},
      {decorID=487, source={type="vendor", itemID=245360, currency="750000", currencytype="money"}, colors={"Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=488, source={type="vendor", itemID=245359, currency="1500000", currencytype="money"}, colors={"Dark Gray","Gray"}, budgetCost=5, size="Large"},
      {decorID=489, source={type="vendor", itemID=245379, currency="1250000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Navy Blue"}, budgetCost=5, size="Large"},
      {decorID=490, source={type="vendor", itemID=245380, currency="1250000", currencytype="money"}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=491, source={type="vendor", itemID=245382, currency="1250000", currencytype="money"}, colors={"Dark Brown","Gray","Navy Blue"}, budgetCost=5, size="Large"},
      {decorID=492, source={type="vendor", itemID=245385, currency="1000000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=493, source={type="vendor", itemID=245386, currency="1250000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=494, source={type="vendor", itemID=235523, currency="500000", currencytype="money"}, requirements={quest={id=92965}}, dyeable=true, colors={"Dark Brown","Dark Gray","Deep Red"}, budgetCost=1, size="Small"},
      {decorID=496, source={type="vendor", itemID=245372, currency="1000000", currencytype="money"}, requirements={quest={id=92983}}, dyeable=true, colors={"Dark Brown","Dark Gray","Deep Red"}, budgetCost=3, size="Medium"},
      {decorID=497, source={type="vendor", itemID=245374, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=770, source={type="vendor", itemID=245367, currency="1500000", currencytype="money"}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=5, size="Large"},
      {decorID=1122, source={type="vendor", itemID=242951, currency="750000", currencytype="money"}, requirements={quest={id=92969}}, dyeable=true, colors={"Dark Brown","Dark Gray","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=1280, source={type="vendor", itemID=243334, currency="500000", currencytype="money"}, requirements={quest={id=92978}}, dyeable=true, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=1457, source={type="vendor", itemID=244667, currency="1250000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=1742, source={type="vendor", itemID=245551, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1862, source={type="vendor", itemID=245656, currency="1500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Navy Blue","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=1863, source={type="vendor", itemID=245657, currency="1250000", currencytype="money"}, colors={"Dark Gray","Gray","Navy Blue"}, budgetCost=5, size="Large"},
      {decorID=1878, source={type="vendor", itemID=245662, currency="1000000", currencytype="money"}, requirements={quest={id=92999}}, dyeable=true, colors={"Copper","Dark Brown","Navy Blue"}, budgetCost=3, size="Large"},
      {decorID=1992, source={type="vendor", itemID=246102, currency="1250000", currencytype="money"}, requirements={quest={id=92998}}, dyeable=true, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=3, size="Large"},
      {decorID=1994, source={type="vendor", itemID=246104, currency="250000", currencytype="money"}, requirements={quest={id=92971}}, dyeable=true, colors={"Copper","Dark Brown","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=1995, source={type="vendor", itemID=246105, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Medium"},
      {decorID=1996, source={type="vendor", itemID=246106, currency="100000", currencytype="money"}, requirements={quest={id=92985}}, dyeable=true, colors={"Gray","Royal Blue","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=1997, source={type="vendor", itemID=246107, currency="1250000", currencytype="money"}, requirements={quest={id=92997}}, dyeable=true, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=1999, source={type="vendor", itemID=246109, currency="250000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Navy Blue"}, budgetCost=1, size="Small"},
      {decorID=2089, source={type="vendor", itemID=246219, currency="1000000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Gray"}, budgetCost=3, size="Large"},
      {decorID=2385, source={type="vendor", itemID=246588, currency="1500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Purple"}, budgetCost=3, size="Large"},
      {decorID=2496, source={type="vendor", itemID=246742, currency="750000", currencytype="money"}, requirements={quest={id=92970}}, dyeable=true, colors={"Copper","Dark Brown","Navy Blue"}, budgetCost=3, size="Medium"},
      {decorID=9472, source={type="vendor", itemID=253590, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Gray","Light Brown","Silver"}, budgetCost=3, size="Medium"},
      {decorID=14814, source={type="vendor", itemID=263025, currency="1000000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=255216,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5220:3783"
    },
    items={
      {decorID=80, source={type="vendor", itemID=235994, currency="1000000", currencytype="money"}, requirements={quest={id=93008}}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=984, source={type="vendor", itemID=241617, currency="500000", currencytype="money"}, requirements={quest={id=93143}}, dyeable=true, colors={"Dark Brown","Light Purple","Tan"}, budgetCost=1, size="Medium"},
      {decorID=985, source={type="vendor", itemID=241618, currency="100000", currencytype="money"}, requirements={quest={id=93000}}, colors={"Dark Brown","Purple","Tan"}, budgetCost=1, size="Small"},
      {decorID=987, source={type="vendor", itemID=241620, currency="1000000", currencytype="money"}, requirements={quest={id=93150}}, dyeable=true, colors={"Dark Brown","Purple","Tan"}, budgetCost=3, size="Medium"},
      {decorID=988, source={type="vendor", itemID=241621, currency="250000", currencytype="money"}, requirements={quest={id=93152}}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Small"},
      {decorID=989, source={type="vendor", itemID=241622, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Olive","Tan"}, budgetCost=3, size="Medium"},
      {decorID=994, source={type="vendor", itemID=253441, currency="1000000", currencytype="money"}, requirements={quest={id=93005}}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=5, size="Large"},
      {decorID=1153, source={type="vendor", itemID=253479, currency="500000", currencytype="money"}, requirements={quest={id=93006}}, dyeable=true, colors={"Dark Brown","Purple","Tan"}, budgetCost=1, size="Small"},
      {decorID=1162, source={type="vendor", itemID=253490, currency="750000", currencytype="money"}, requirements={quest={id=93002}}, dyeable=true, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1163, source={type="vendor", itemID=253493, currency="1000000", currencytype="money"}, requirements={quest={id=93147}}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1245, source={type="vendor", itemID=243242, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Purple","Light Purple","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1246, source={type="vendor", itemID=243243, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Purple","Light Purple","Tan"}, budgetCost=5, size="Large"},
      {decorID=1329, source={type="vendor", itemID=243495, currency="1000000", currencytype="money"}, requirements={quest={id=93149}}, dyeable=true, colors={"Dark Brown","Light Purple","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1487, source={type="vendor", itemID=244781, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Purple"}, budgetCost=3, size="Large"},
      {decorID=1770, source={type="vendor", itemID=245575, currency="1000000", currencytype="money"}, requirements={quest={id=92994}}, colors={"Black","Dark Brown"}, budgetCost=3, size="Huge"},
      {decorID=1771, source={type="vendor", itemID=245576, currency="500000", currencytype="money"}, requirements={quest={id=92993}}, colors={"Dark Brown","Dark Gray","White"}, budgetCost=3, size="Huge"},
      {decorID=1772, source={type="vendor", itemID=245578, currency="1000000", currencytype="money"}, requirements={quest={id=92992}}, colors={"Dark Brown","Dark Gray","Royal Blue"}, budgetCost=3, size="Huge"},
      {decorID=1773, source={type="vendor", itemID=245579, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Huge"},
      {decorID=1774, source={type="vendor", itemID=245581, currency="500000", currencytype="money"}, requirements={quest={id=93135}}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Huge"},
      {decorID=1775, source={type="vendor", itemID=245582, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=3, size="Huge"},
      {decorID=1776, source={type="vendor", itemID=245583, currency="1000000", currencytype="money"}, requirements={quest={id=93136}}, colors={"Dark Brown","Gray","Silver"}, budgetCost=3, size="Huge"},
      {decorID=1844, source={type="vendor", itemID=245649, currency="1000000", currencytype="money"}, requirements={quest={id=93137}}, colors={"Dark Brown","Gray","Orange"}, budgetCost=3, size="Huge"},
      {decorID=2104, source={type="vendor", itemID=246249, currency="500000", currencytype="money"}, requirements={quest={id=93140}}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Large"},
      {decorID=2105, source={type="vendor", itemID=246250, currency="1250000", currencytype="money"}, requirements={quest={id=93138}}, colors={"Dark Gray","Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=2106, source={type="vendor", itemID=246251, currency="750000", currencytype="money"}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Large"},
      {decorID=2107, source={type="vendor", itemID=246252, currency="500000", currencytype="money"}, colors={"Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=2108, source={type="vendor", itemID=246253, currency="1000000", currencytype="money"}, requirements={quest={id=93139}}, colors={"Dark Gray","Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=2109, source={type="vendor", itemID=246254, currency="500000", currencytype="money"}, requirements={quest={id=92991}}, colors={"Black","Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=2110, source={type="vendor", itemID=246255, currency="1250000", currencytype="money"}, requirements={quest={id=93009}}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2111, source={type="vendor", itemID=246256, currency="750000", currencytype="money"}, colors={"Black","Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=2112, source={type="vendor", itemID=246257, currency="500000", currencytype="money"}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2113, source={type="vendor", itemID=246258, currency="1000000", currencytype="money"}, requirements={quest={id=92990}}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2254, source={type="vendor", itemID=246431, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Purple","Light Purple"}, budgetCost=3, size="Medium"},
      {decorID=2458, source={type="vendor", itemID=246691, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Purple","Light Purple","Olive"}, budgetCost=3, size="Medium"},
      {decorID=2474, source={type="vendor", itemID=246711, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Light Purple","Tan"}, budgetCost=1, size="Small"},
      {decorID=2590, source={type="vendor", itemID=246961, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Purple","Light Purple","Tan"}, budgetCost=1, size="Small"},
      {decorID=3826, source={type="vendor", itemID=247501, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Olive","Tan"}, budgetCost=3, size="Medium"},
      {decorID=4562, source={type="vendor", itemID=248760, currency="500000", currencytype="money"}, requirements={quest={id=93134}}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=5563, source={type="vendor", itemID=249558, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Navy Blue","Tan"}, budgetCost=3, size="Medium"},
      {decorID=8917, source={type="vendor", itemID=251981, currency="500000", currencytype="money"}, requirements={quest={id=93141}}, dyeable=true, colors={"Dark Brown","Dark Purple","Gold"}, budgetCost=3, size="Medium"},
      {decorID=8918, source={type="vendor", itemID=251982, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Gold"}, budgetCost=1, size="Large"},
      {decorID=9254, source={type="vendor", itemID=253180, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Purple","Purple"}, budgetCost=5, size="Large"},
      {decorID=9255, source={type="vendor", itemID=253181, currency="500000", currencytype="money"}, requirements={quest={id=93007}}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Medium"},
      {decorID=10860, source={type="vendor", itemID=255650, currency="250000", currencytype="money"}, requirements={quest={id=92995}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=11719, source={type="vendor", itemID=257690, currency="1000000", currencytype="money"}, requirements={quest={id=93003}}, dyeable=true, colors={"Dark Brown","Light Purple","Tan"}, budgetCost=3, size="Large"},
      {decorID=15454, source={type="vendor", itemID=264169, currency="250000", currencytype="money"}, colors={"Copper","Dark Brown","Orange"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255218,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5220:3780"
    },
    items={
      {decorID=992, source={type="vendor", itemID=241625, currency="250000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Tan"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=255218,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5223:3777"
    },
    items={
      {decorID=986, source={type="vendor", itemID=253437, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Purple","Tan"}, budgetCost=3, size="Medium"},
      {decorID=990, source={type="vendor", itemID=241623, currency="100000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=991, source={type="vendor", itemID=253439, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1155, source={type="vendor", itemID=243088, currency="1000000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1165, source={type="vendor", itemID=253495, currency="1250000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1350, source={type="vendor", itemID=244118, currency="1000000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1356, source={type="vendor", itemID=244169, currency="1000000", currencytype="money"}, requirements={quest={id=93148}}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1486, source={type="vendor", itemID=244780, currency="1000000", currencytype="money"}, requirements={quest={id=93004}}, dyeable=true, colors={"Bronze","Dark Brown","Teal"}, budgetCost=3, size="Small"},
      {decorID=1488, source={type="vendor", itemID=244782, currency="500000", currencytype="money"}, requirements={quest={id=93001}}, dyeable=true, colors={"Cyan","Dark Brown","Teal"}, budgetCost=3, size="Medium"},
      {decorID=3827, source={type="vendor", itemID=247502, currency="1500000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=4484, source={type="vendor", itemID=248658, currency="250000", currencytype="money"}, colors={"Copper","Dark Brown","Tan"}, budgetCost=1, size="Small"},
      {decorID=11720, source={type="vendor", itemID=257691, currency="100000", currencytype="money"}, requirements={quest={id=93142}}, dyeable=true, colors={"Copper","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=11721, source={type="vendor", itemID=257692, currency="1000000", currencytype="money"}, requirements={quest={id=93151}}, dyeable=true, colors={"Dark Brown","Tan"}, budgetCost=3, size="Large"},
    }
  },

  {
    source={
      id=255221,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5340:4080"
    },
    items={
      {decorID=17873, source={type="vendor", itemID=266244, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=17874, source={type="vendor", itemID=266245, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=17918, source={type="vendor", itemID=266443, currency="500000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=17919, source={type="vendor", itemID=266444, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=255221,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5347:4093"
    },
    items={
      {decorID=520, source={type="vendor", itemID=245369, currency="250000", currencytype="money"}, colors={"Dark Brown","Deep Red","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=521, source={type="vendor", itemID=245371, currency="750000", currencytype="money"}, colors={"Dark Brown","Forest Green"}, budgetCost=5, size="Huge"},
      {decorID=771, source={type="vendor", itemID=245329, currency="250000", currencytype="money"}, colors={"Dark Brown","Olive","Orange"}, budgetCost=1, size="Small"},
      {decorID=772, source={type="vendor", itemID=245327, currency="500000", currencytype="money"}, colors={"Dark Brown","Forest Green","Teal"}, budgetCost=1, size="Large"},
      {decorID=773, source={type="vendor", itemID=245328, currency="250000", currencytype="money"}, colors={"Forest Green","Teal"}, budgetCost=1, size="Medium"},
      {decorID=1864, source={type="vendor", itemID=245658, currency="100000", currencytype="money"}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=1865, source={type="vendor", itemID=245659, currency="100000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=1866, source={type="vendor", itemID=245660, currency="100000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=1867, source={type="vendor", itemID=245661, currency="100000", currencytype="money"}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=4461, source={type="vendor", itemID=248635, currency="250000", currencytype="money"}, colors={"Beige","Dark Brown","Olive"}, budgetCost=1, size="Large"},
      {decorID=4465, source={type="vendor", itemID=248639, currency="250000", currencytype="money"}, colors={"Dark Brown","Navy Blue","Purple"}, budgetCost=1, size="Large"},
      {decorID=4466, source={type="vendor", itemID=248640, currency="250000", currencytype="money"}, colors={"Dark Brown","Dark Purple","Forest Green"}, budgetCost=1, size="Large"},
      {decorID=4467, source={type="vendor", itemID=248641, currency="250000", currencytype="money"}, colors={"Teal"}, budgetCost=1, size="Large"},
      {decorID=4468, source={type="vendor", itemID=248642, currency="500000", currencytype="money"}, colors={"Dark Brown","Deep Red","Forest Green"}, budgetCost=1, size="Large"},
      {decorID=4469, source={type="vendor", itemID=248643, currency="1250000", currencytype="money"}, colors={"Dark Brown","Forest Green","Teal"}, budgetCost=3, size="Huge"},
      {decorID=4470, source={type="vendor", itemID=248644, currency="250000", currencytype="money"}, colors={"Cyan","Forest Green","Teal"}, budgetCost=1, size="Medium"},
      {decorID=4471, source={type="vendor", itemID=248645, currency="250000", currencytype="money"}, colors={"Copper","Dark Brown","Olive"}, budgetCost=1, size="Large"},
      {decorID=4472, source={type="vendor", itemID=248646, currency="500000", currencytype="money"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=1, size="Large"},
      {decorID=4473, source={type="vendor", itemID=248647, currency="100000", currencytype="money"}, colors={"Amber","Dark Brown","Olive"}, budgetCost=1, size="Large"},
      {decorID=4474, source={type="vendor", itemID=248648, currency="500000", currencytype="money"}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=1, size="Large"},
      {decorID=4475, source={type="vendor", itemID=248649, currency="1250000", currencytype="money"}, colors={"Black","Olive"}, budgetCost=5, size="Huge"},
      {decorID=4822, source={type="vendor", itemID=248802, currency="100000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Medium"},
      {decorID=4823, source={type="vendor", itemID=248803, currency="250000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Medium"},
      {decorID=4845, source={type="vendor", itemID=248811, currency="100000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=1, size="Small"},
      {decorID=10855, source={type="vendor", itemID=255644, currency="1500000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Huge"},
      {decorID=10856, source={type="vendor", itemID=255646, currency="1500000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Huge"},
      {decorID=12189, source={type="vendor", itemID=258658, currency="1500000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Huge"},
      {decorID=12190, source={type="vendor", itemID=258659, currency="1500000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Huge"},
      {decorID=17868, source={type="vendor", itemID=266239, currency="1500000", currencytype="money"}, colors={"Forest Green","Olive","Tan"}, budgetCost=5, size="Large"},
      {decorID=17869, source={type="vendor", itemID=266240, currency="1500000", currencytype="money"}, colors={"Deep Red","Olive","Teal"}, budgetCost=5, size="Large"},
      {decorID=17870, source={type="vendor", itemID=266241, currency="1500000", currencytype="money"}, colors={"Cyan","Dark Brown","Royal Blue"}, budgetCost=5, size="Large"},
      {decorID=17871, source={type="vendor", itemID=266242, currency="1500000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=17872, source={type="vendor", itemID=266243, currency="1500000", currencytype="money"}, colors={"Dark Brown","Olive","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=255221,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5360:4080"
    },
    items={
      {decorID=4406, source={type="vendor", itemID=248337, currency="500000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=4407, source={type="vendor", itemID=248338, currency="500000", currencytype="money"}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=4408, source={type="vendor", itemID=248339, currency="500000", currencytype="money"}, colors={"Black"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=255222,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:6237:8015"
    },
    items={
      {decorID=81, source={type="vendor", itemID=245398, currency="1000000", currencytype="money"}, requirements={quest={id=93110}}, dyeable=true, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=522, source={type="vendor", itemID=236653, currency="750000", currencytype="money"}, colors={"Dark Gray","White"}, budgetCost=3, size="Huge"},
      {decorID=523, source={type="vendor", itemID=236654, currency="1000000", currencytype="money"}, requirements={quest={id=93073}}, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=3, size="Huge"},
      {decorID=524, source={type="vendor", itemID=236655, currency="1000000", currencytype="money"}, requirements={quest={id=93074}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Huge"},
      {decorID=525, source={type="vendor", itemID=236666, currency="500000", currencytype="money"}, requirements={quest={id=93075}}, colors={"Black","Dark Brown"}, budgetCost=3, size="Huge"},
      {decorID=526, source={type="vendor", itemID=236667, currency="500000", currencytype="money"}, colors={"Black","Dark Brown","Dark Gray"}, budgetCost=3, size="Huge"},
      {decorID=534, source={type="vendor", itemID=245393, currency="1000000", currencytype="money"}, colors={"Dark Brown","Gray","White"}, budgetCost=3, size="Huge"},
      {decorID=535, source={type="vendor", itemID=245394, currency="1000000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Huge"},
      {decorID=536, source={type="vendor", itemID=245395, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Huge"},
      {decorID=1437, source={type="vendor", itemID=244533, currency="500000", currencytype="money"}, requirements={quest={id=93078}}, colors={"Dark Gray","Light Brown","Teal"}, budgetCost=1, size="Medium"},
      {decorID=1438, source={type="vendor", itemID=244534, currency="500000", currencytype="money"}, requirements={quest={id=93079}}, dyeable=true, colors={"Dark Gray","Teal"}, budgetCost=5, size="Large"},
      {decorID=1451, source={type="vendor", itemID=244661, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=1452, source={type="vendor", itemID=244662, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=1453, source={type="vendor", itemID=244663, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=1698, source={type="vendor", itemID=245264, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=1699, source={type="vendor", itemID=245265, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=1700, source={type="vendor", itemID=245266, currency="500000", currencytype="money"}, requirements={quest={id=93080}}, dyeable=true, colors={"Cyan","Dark Gray","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=1723, source={type="vendor", itemID=245532, currency="500000", currencytype="money"}, requirements={quest={id=93081}}, dyeable=true, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=1736, source={type="vendor", itemID=245545, currency="250000", currencytype="money"}, requirements={quest={id=93083}}, dyeable=true, colors={"Bronze","Dark Gray","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=1744, source={type="vendor", itemID=245555, currency="1000000", currencytype="money"}, requirements={quest={id=93111}}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=1879, source={type="vendor", itemID=245680, currency="750000", currencytype="money"}, requirements={quest={id=93109}}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=1977, source={type="vendor", itemID=246036, currency="750000", currencytype="money"}, requirements={quest={id=93091}}, dyeable=true, colors={"Copper","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=1978, source={type="vendor", itemID=246037, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=1979, source={type="vendor", itemID=246038, currency="750000", currencytype="money"}, colors={"Dark Brown","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=2092, source={type="vendor", itemID=246223, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=2093, source={type="vendor", itemID=246224, currency="750000", currencytype="money"}, requirements={quest={id=93099}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=2094, source={type="vendor", itemID=246225, currency="500000", currencytype="money"}, colors={"Copper","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=2114, source={type="vendor", itemID=246259, currency="500000", currencytype="money"}, requirements={quest={id=93085}}, colors={"Dark Brown"}, budgetCost=1, size="Large"},
      {decorID=2115, source={type="vendor", itemID=246260, currency="1000000", currencytype="money"}, requirements={quest={id=93087}}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2116, source={type="vendor", itemID=246261, currency="1250000", currencytype="money"}, requirements={quest={id=93088}}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2117, source={type="vendor", itemID=246262, currency="750000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=3, size="Large"},
      {decorID=2118, source={type="vendor", itemID=246263, currency="500000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=2384, source={type="vendor", itemID=246587, currency="250000", currencytype="money"}, requirements={quest={id=93100}}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=2439, source={type="vendor", itemID=246607, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Large"},
      {decorID=2440, source={type="vendor", itemID=246608, currency="1250000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Large"},
      {decorID=2441, source={type="vendor", itemID=246609, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Olive"}, budgetCost=5, size="Large"},
      {decorID=2442, source={type="vendor", itemID=246610, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Tan","Teal"}, budgetCost=3, size="Large"},
      {decorID=2445, source={type="vendor", itemID=246613, currency="1250000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=3, size="Large"},
      {decorID=2446, source={type="vendor", itemID=246614, currency="1000000", currencytype="money"}, requirements={quest={id=93115}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=3, size="Large"},
      {decorID=2454, source={type="vendor", itemID=246687, currency="100000", currencytype="money"}, requirements={quest={id=93101}}, dyeable=true, colors={"Amber","Dark Brown","Olive"}, budgetCost=1, size="Tiny"},
      {decorID=2535, source={type="vendor", itemID=246869, currency="750000", currencytype="money"}, requirements={quest={id=93132}}, colors={"Dark Brown","Olive","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=2545, source={type="vendor", itemID=246879, currency="250000", currencytype="money"}, colors={"Copper","Dark Gray","Olive"}, budgetCost=3, size="Large"},
      {decorID=2592, source={type="vendor", itemID=247221, currency="500000", currencytype="money"}, requirements={quest={id=93106}}, dyeable=true, colors={"Dark Gray","Light Brown","Olive"}, budgetCost=1, size="Medium"},
      {decorID=4386, source={type="vendor", itemID=248246, currency="750000", currencytype="money"}, requirements={quest={id=93107}}, dyeable=true, colors={"Dark Brown","Light Brown","Olive"}, budgetCost=3, size="Medium"},
      {decorID=5853, source={type="vendor", itemID=250093, currency="750000", currencytype="money"}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=5854, source={type="vendor", itemID=250094, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=7836, source={type="vendor", itemID=250913, currency="750000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=7842, source={type="vendor", itemID=250920, currency="250000", currencytype="money"}, requirements={quest={id=93102}}, colors={"Copper","Dark Brown","Olive"}, budgetCost=3, size="Medium"},
      {decorID=8771, source={type="vendor", itemID=251639, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=8907, source={type="vendor", itemID=251973, currency="500000", currencytype="money"}, requirements={quest={id=93108}}, colors={"Copper","Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=8910, source={type="vendor", itemID=251974, currency="500000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=8911, source={type="vendor", itemID=251975, currency="250000", currencytype="money"}, colors={"Brown","Dark Gray","Olive"}, budgetCost=3, size="Medium"},
      {decorID=8912, source={type="vendor", itemID=251976, currency="500000", currencytype="money"}, colors={"Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=9143, source={type="vendor", itemID=252657, currency="500000", currencytype="money"}, dyeable=true, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=10324, source={type="vendor", itemID=254316, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=10367, source={type="vendor", itemID=254560, currency="500000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Medium"},
      {decorID=10952, source={type="vendor", itemID=256050, currency="750000", currencytype="money"}, colors={"Copper","Dark Gray","Teal"}, budgetCost=3, size="Large"},
      {decorID=11480, source={type="vendor", itemID=257389, currency="500000", currencytype="money"}, dyeable=true, colors={"Cyan","Dark Gray","Royal Blue"}, budgetCost=3, size="Medium"},
      {decorID=11874, source={type="vendor", itemID=258148, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
    }
  },

  {
    source={
      id=255228,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:6165:7902"
    },
    items={
      {decorID=1436, source={type="vendor", itemID=244532, currency="100000", currencytype="money"}, requirements={quest={id=93077}}, dyeable=true, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Tiny"},
      {decorID=1439, source={type="vendor", itemID=244535, currency="1500000", currencytype="money"}, colors={"Dark Gray","Gray","Light Brown"}, budgetCost=5, size="Huge"},
      {decorID=1724, source={type="vendor", itemID=245533, currency="500000", currencytype="money"}, requirements={quest={id=93082}}, colors={"Dark Brown","Gold","Olive"}, budgetCost=1, size="Small"},
      {decorID=1737, source={type="vendor", itemID=245546, currency="500000", currencytype="money"}, requirements={quest={id=93084}}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=2087, source={type="vendor", itemID=246217, currency="750000", currencytype="money"}, requirements={quest={id=93097}}, colors={"Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=2088, source={type="vendor", itemID=246218, currency="250000", currencytype="money"}, requirements={quest={id=93098}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=2090, source={type="vendor", itemID=246220, currency="1250000", currencytype="money"}, colors={"Dark Brown","Light Brown"}, budgetCost=3, size="Medium"},
      {decorID=2098, source={type="vendor", itemID=246241, currency="100000", currencytype="money"}, requirements={quest={id=93103}}, colors={"Dark Brown","Dark Gray","Silver"}, budgetCost=1, size="Small"},
      {decorID=2443, source={type="vendor", itemID=246611, currency="1250000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=2444, source={type="vendor", itemID=246612, currency="1000000", currencytype="money"}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=3, size="Large"},
      {decorID=2447, source={type="vendor", itemID=246615, currency="100000", currencytype="money"}, colors={"Copper","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=2448, source={type="vendor", itemID=246616, currency="250000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=2534, source={type="vendor", itemID=246868, currency="1000000", currencytype="money"}, requirements={quest={id=93131}}, dyeable=true, colors={"Dark Brown","Tan"}, budgetCost=3, size="Medium"},
      {decorID=2546, source={type="vendor", itemID=246880, currency="100000", currencytype="money"}, requirements={quest={id=93104}}, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=2547, source={type="vendor", itemID=246881, currency="100000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Medium"},
      {decorID=2548, source={type="vendor", itemID=246882, currency="1000000", currencytype="money"}, requirements={quest={id=93133}}, dyeable=true, colors={"Dark Brown","Dark Gray"}, budgetCost=3, size="Medium"},
      {decorID=2549, source={type="vendor", itemID=246883, currency="250000", currencytype="money"}, requirements={quest={id=93105}}, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=1, size="Small"},
      {decorID=2550, source={type="vendor", itemID=246884, currency="250000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
      {decorID=5561, source={type="vendor", itemID=249550, currency="1500000", currencytype="money"}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=8236, source={type="vendor", itemID=251545, currency="1000000", currencytype="money"}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=8769, source={type="vendor", itemID=251637, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=8770, source={type="vendor", itemID=251638, currency="1500000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=10791, source={type="vendor", itemID=254893, currency="1500000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Teal"}, budgetCost=5, size="Huge"},
      {decorID=10892, source={type="vendor", itemID=255708, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Large"},
      {decorID=11139, source={type="vendor", itemID=256357, currency="750000", currencytype="money"}, dyeable=true, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=1, size="Medium"},
      {decorID=11437, source={type="vendor", itemID=257099, currency="1000000", currencytype="money"}, dyeable=true, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=255230,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:6223:8030"
    },
    items={
      {decorID=4406, source={type="vendor", itemID=248337, currency="500000", currencytype="money"}, colors={"Dark Brown","Dark Gray"}, budgetCost=5, size="Large"},
      {decorID=4407, source={type="vendor", itemID=248338, currency="500000", currencytype="money"}, colors={"Black","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=4408, source={type="vendor", itemID=248339, currency="500000", currencytype="money"}, colors={"Black"}, budgetCost=5, size="Large"},
      {decorID=4451, source={type="vendor", itemID=248625, currency="1500000", currencytype="money"}, colors={"Dark Brown","Light Brown","Olive"}, budgetCost=5, size="Huge"},
      {decorID=4452, source={type="vendor", itemID=248626, currency="750000", currencytype="money"}, colors={"Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=4453, source={type="vendor", itemID=248627, currency="100000", currencytype="money"}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=1, size="Large"},
      {decorID=4454, source={type="vendor", itemID=248628, currency="1500000", currencytype="money"}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=5, size="Huge"},
      {decorID=4455, source={type="vendor", itemID=248629, currency="250000", currencytype="money"}, colors={"Dark Brown","Dark Purple","Navy Blue"}, budgetCost=3, size="Medium"},
      {decorID=4456, source={type="vendor", itemID=248630, currency="250000", currencytype="money"}, colors={"Dark Brown","Forest Green"}, budgetCost=1, size="Large"},
      {decorID=4457, source={type="vendor", itemID=248631, currency="1000000", currencytype="money"}, colors={"Brown","Dark Purple","Purple"}, budgetCost=3, size="Large"},
      {decorID=4458, source={type="vendor", itemID=248632, currency="750000", currencytype="money"}, colors={"Bronze","Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=4459, source={type="vendor", itemID=248633, currency="500000", currencytype="money"}, colors={"Brown","Dark Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=4460, source={type="vendor", itemID=248634, currency="1250000", currencytype="money"}, colors={"Dark Brown","Light Brown","Olive"}, budgetCost=5, size="Huge"},
      {decorID=4462, source={type="vendor", itemID=248636, currency="750000", currencytype="money"}, colors={"Dark Brown","Light Brown","Olive"}, budgetCost=3, size="Large"},
      {decorID=4463, source={type="vendor", itemID=248637, currency="100000", currencytype="money"}, colors={"Dark Brown","Light Brown","Purple"}, budgetCost=1, size="Small"},
      {decorID=4464, source={type="vendor", itemID=248638, currency="250000", currencytype="money"}, colors={"Brown","Dark Brown","Red"}, budgetCost=1, size="Medium"},
      {decorID=4476, source={type="vendor", itemID=248650, currency="100000", currencytype="money"}, colors={"Dark Brown","Light Brown","Orange"}, budgetCost=1, size="Large"},
      {decorID=11461, source={type="vendor", itemID=257359, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=11479, source={type="vendor", itemID=257388, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=11481, source={type="vendor", itemID=257390, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Gray"}, budgetCost=1, size="Large"},
      {decorID=11482, source={type="vendor", itemID=257392, currency="100000", currencytype="money"}, dyeable=true, colors={"Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=14382, source={type="vendor", itemID=260701, currency="250000", currencytype="money"}, colors={"Brown","Dark Brown","Red"}, budgetCost=1, size="Medium"},
      {decorID=14383, source={type="vendor", itemID=260702, currency="750000", currencytype="money"}, colors={"Copper","Dark Brown","Light Brown"}, budgetCost=1, size="Medium"},
      {decorID=17863, source={type="vendor", itemID=266234, currency="1500000", currencytype="money"}, colors={"Dark Brown","Deep Red","Olive"}, budgetCost=5, size="Large"},
      {decorID=17864, source={type="vendor", itemID=266235, currency="1500000", currencytype="money"}, colors={"Bronze","Dark Brown","Light Brown"}, budgetCost=5, size="Large"},
      {decorID=17865, source={type="vendor", itemID=266236, currency="1500000", currencytype="money"}, colors={"Brown","Dark Brown","Olive"}, budgetCost=5, size="Large"},
      {decorID=17866, source={type="vendor", itemID=266237, currency="1500000", currencytype="money"}, colors={"Dark Brown","Deep Red","Forest Green"}, budgetCost=5, size="Large"},
      {decorID=17867, source={type="vendor", itemID=266238, currency="1500000", currencytype="money"}, colors={"Bronze","Dark Brown"}, budgetCost=5, size="Large"},
      {decorID=17873, source={type="vendor", itemID=266244, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=17874, source={type="vendor", itemID=266245, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=17918, source={type="vendor", itemID=266443, currency="500000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=3, size="Large"},
      {decorID=17919, source={type="vendor", itemID=266444, currency="750000", currencytype="money"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Medium"},
    }
  },

  {
    source={
      id=256750,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5830:6168"
    },
    items={
      {decorID=721, source={type="vendor", itemID=245400, currency="100000", currencytype="money"}, colors={"Black"}, budgetCost=1, size="Small"},
      {decorID=722, source={type="vendor", itemID=245401, currency="100000", currencytype="money"}, colors={"Dark Gray","Silver"}, budgetCost=1, size="Small"},
      {decorID=723, source={type="vendor", itemID=245402, currency="100000", currencytype="money"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=724, source={type="vendor", itemID=245403, currency="100000", currencytype="money"}, colors={"Black"}, budgetCost=1, size="Small"},
      {decorID=725, source={type="vendor", itemID=245404, currency="100000", currencytype="money"}, colors={"Dark Gray"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=257897,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5304:3805"
    },
    items={
      {decorID=16227, source={type="vendor", itemID=264915, currency="15", currencytype=3363}, colors={"Dark Brown","Purple","Teal"}, budgetCost=3, size="Medium"},
      {decorID=16228, source={type="vendor", itemID=264916, currency="20", currencytype=3363}, colors={"Brown","Dark Brown","Dark Gray"}, budgetCost=5, size="Huge"},
      {decorID=16229, source={type="vendor", itemID=264917, currency="5", currencytype=3363}, colors={"Dark Brown"}, budgetCost=1, size="Tiny"},
      {decorID=16230, source={type="vendor", itemID=264918, currency="2", currencytype=3363}, colors={"Bronze","Dark Brown"}, budgetCost=1, size="Small"},
      {decorID=16231, source={type="vendor", itemID=264919, currency="20", currencytype=3363}, colors={"Dark Brown","Dark Purple","Purple"}, budgetCost=5, size="Huge"},
      {decorID=16232, source={type="vendor", itemID=264920, currency="5", currencytype=3363}, colors={"Dark Brown","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=16233, source={type="vendor", itemID=264921, currency="20", currencytype=3363}, colors={"Dark Brown","Royal Blue"}, budgetCost=5, size="Huge"},
      {decorID=16234, source={type="vendor", itemID=264922, currency="2", currencytype=3363}, colors={"Copper","Dark Brown","Dark Gray"}, budgetCost=1, size="Small"},
      {decorID=16235, source={type="vendor", itemID=264923, currency="15", currencytype=3363}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=16236, source={type="vendor", itemID=264924, currency="10", currencytype=3363}, colors={"Dark Brown"}, budgetCost=3, size="Medium"},
      {decorID=16237, source={type="vendor", itemID=264925, currency="5", currencytype=3363}, colors={"Dark Gray","Tan"}, budgetCost=1, size="Small"},
      {decorID=16315, source={type="vendor", itemID=265032, currency="5", currencytype=3363}, colors={"Dark Gray","Deep Red","Light Brown"}, budgetCost=1, size="Small"},
      {decorID=16962, source={type="vendor", itemID=265541, currency="1", currencytype=3363}, colors={"Black","Dark Brown"}, budgetCost=1, size="Small"},
    }
  },

  {
    source={
      id=260485,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2351:5427:5605"
    },
    items={
      {decorID=22916, source={type="vendor", itemID=274518}, budgetCost=3, size="Large"},
      {decorID=22918, source={type="vendor", itemID=274523}, budgetCost=3, size="Medium"},
      {decorID=22924, source={type="vendor", itemID=274533}, budgetCost=3, size="Medium"},
      {decorID=22925, source={type="vendor", itemID=274535}, budgetCost=5, size="Huge"},
      {decorID=22926, source={type="vendor", itemID=274537}, budgetCost=5, size="Huge"},
    }
  },

  {
    source={
      id=265551,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2351:5420:5597"
    },
    items={
      {decorID=23176, source={type="vendor", itemID=276650}, size="Huge"},
      {decorID=23177, source={type="vendor", itemID=276626}, size="Huge"},
      {decorID=23178, source={type="vendor", itemID=276669}, size="Medium"},
      {decorID=23181, source={type="vendor", itemID=276658}, size="Large"},
      {decorID=23182, source={type="vendor", itemID=276663}, size="Large"},
      {decorID=23184, source={type="vendor", itemID=276667}, size="Large"},
      {decorID=23185, source={type="vendor", itemID=276661}, size="Large"},
      {decorID=23186, source={type="vendor", itemID=276652}, size="Huge"},
    }
  },

  {
    source={
      id=267795,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2352:5316:4004"
    },
    items={
      {decorID=25101, source={type="vendor", itemID=277142}, budgetCost=5, size="Small"},
      {decorID=25102, source={type="vendor", itemID=277144}, budgetCost=5, size="Small"},
      {decorID=25103, source={type="vendor", itemID=277149}, budgetCost=5, size="Small"},
      {decorID=25105, source={type="vendor", itemID=277138}, budgetCost=5, size="Medium"},
      {decorID=25106, source={type="vendor", itemID=277160}, budgetCost=5, size="Medium"},
      {decorID=25121, source={type="vendor", itemID=277121}, budgetCost=5, size="Small"},
      {decorID=25122, source={type="vendor", itemID=277163}, budgetCost=5, size="Small"},
    }
  },

  {
    source={
      id=268106,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2351:5487:5730"
    },
    items={
      {decorID=26365, source={type="vendor", itemID=280240}, budgetCost=3, size="Medium"},
      {decorID=26371, source={type="vendor", itemID=280234}, budgetCost=3, size="Medium"},
      {decorID=26386, source={type="vendor", itemID=280238}, budgetCost=3, size="Medium"},
      {decorID=26387, source={type="vendor", itemID=280232}, budgetCost=5, size="Large"},
      {decorID=26483, source={type="vendor", itemID=280223}, budgetCost=5, size="Large"},
      {decorID=26564, source={type="vendor", itemID=280225}, budgetCost=5, size="Large"},
    }
  },

  {
    source={
      id=271173,
      type="vendor",
      faction="Neutral",
      zone="Founder's Point",
      worldmap="2351:5489:5728"
    },
    items={
      {decorID=26613, source={type="vendor", itemID=280246}, budgetCost=5, size="Large"},
      {decorID=26614, source={type="vendor", itemID=280249}, budgetCost=1, size="Small"},
      {decorID=26621, source={type="vendor", itemID=280257}, budgetCost=3, size="Medium"},
      {decorID=26789, source={type="vendor", itemID=280265}, budgetCost=3, size="Medium"},
      {decorID=26936, source={type="vendor", itemID=280273}, budgetCost=5, size="Large"},
      {decorID=26937, source={type="vendor", itemID=280271}, budgetCost=5, size="Large"},
    }
  },

}
