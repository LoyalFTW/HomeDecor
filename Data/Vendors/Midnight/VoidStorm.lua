local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Vendors = NS.Data.Vendors or {}

NS.Data.Vendors["Midnight"] = NS.Data.Vendors["Midnight"] or {}

NS.Data.Vendors["Midnight"]["VoidStorm"] = {

  {
    source={
      id=248328,
      type="vendor",
      faction="Neutral",
      zone="Voidstorm",
      worldmap="2405:5259:7290"
    },
    items={
        {decorID=5132, source={type="vendor", itemID=248964}},
        {decorID=14592, source={type="vendor", itemID=262462}},
        {decorID=14593, source={type="vendor", itemID=262463}},
        {decorID=14596, source={type="vendor", itemID=262466}},
        {decorID=14603, source={type="vendor", itemID=262473}},
        {decorID=14632, source={type="vendor", itemID=262607}},
        {decorID=14634, source={type="vendor", itemID=262609}},
        {decorID=15260, source={type="vendor", itemID=263499}},
        {decorID=15575, source={type="vendor", itemID=264337}},
        {decorID=15578, source={type="vendor", itemID=264339}},
        {decorID=15581, source={type="vendor", itemID=264341}},
        {decorID=15584, source={type="vendor", itemID=264344}},
        {decorID=15597, source={type="vendor", itemID=264351}},
        {decorID=15769, source={type="vendor", itemID=264509}},
    }
  },

  {
    source={
      id=259922,
      type="vendor",
      faction="Neutral",
      zone="Voidstorm",
      worldmap="2405:5266:7279"
    },
    items={
        {decorID=14554, source={type="vendor", itemID=262351}, requirements={quest={id=86513}}},
        {decorID=14602, source={type="vendor", itemID=262472}},
        {decorID=14631, source={type="vendor", itemID=262606}, requirements={quest={id=86521}}},
        {decorID=15071, source={type="vendor", itemID=263240}},
        {decorID=15579, source={type="vendor", itemID=264340}},
        {decorID=15757, source={type="vendor", itemID=264493}, requirements={achievement={id=62130}}},
        {decorID=15768, source={type="vendor", itemID=264508}},
        {decorID=15890, source={type="vendor", itemID=264656}, requirements={achievement={id=62291}}},
        {decorID=15891, source={type="vendor", itemID=264657}},
        {decorID=15894, source={type="vendor", itemID=264659}},
        {decorID=18617, source={type="vendor", itemID=267082}},
        {decorID=18800, source={type="vendor", itemID=267209}},
    }
  },

    {
    source={
      id=258328,
      type="vendor",
      faction="Neutral",
      zone="Masters' Perch",
      worldmap="2444:3935:8095"
    },
    items={
         {decorID=3922, source={type="vendor", itemID=247785}},
         {decorID=15488, source={type="vendor", itemID=264253}},
         {decorID=15585, source={type="vendor", itemID=264345}},
    }
  },

}