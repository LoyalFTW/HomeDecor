local ADDON, NS = ...

NS.Data = NS.Data or {}
NS.Data.Shops = NS.Data.Shops or {}

NS.Data.Shops["Midnight"] = NS.Data.Shops["Midnight"] or {}
NS.Data.Shops["Midnight"]["QuelThalas"] = {
    {decorID=11287, source={type="shop", zone="Diablo 2 expansion bonus", itemID=256764, name="Diablo 2 expansion bonus"}, budgetCost=1, size="Small"},
    {decorID=12247, source={type="shop", zone="Diablo 4 pre-order", itemID=259055, name="Diablo 4 pre-order"}, colors={"Beige","Copper","Dark Gray"}, budgetCost=3, size="Large"},
    {decorID=12248, source={type="shop", zone="Diablo 4 pre-order", itemID=259056, name="Diablo 4 pre-order"}, colors={"Dark Gray","Red","Tan"}, budgetCost=3, size="Large"},
    {decorID=12249, source={type="shop", zone="Diablo 4 pre-order", itemID=259057, name="Diablo 4 pre-order"}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
    {decorID=12250, source={type="shop", zone="Diablo 4 pre-order", itemID=259058, name="Diablo 4 pre-order"}, colors={"Dark Gray","Tan"}, budgetCost=3, size="Medium"},
    {decorID=12251, source={type="shop", zone="Diablo 4 pre-order", itemID=259059, name="Diablo 4 pre-order"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12252, source={type="shop", zone="Diablo 4 pre-order", itemID=259060, name="Diablo 4 pre-order"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12253, source={type="shop", zone="Diablo 4 pre-order", itemID=259061, name="Diablo 4 pre-order"}, colors={"Black"}, budgetCost=1, size="Tiny"},
    {decorID=12254, source={type="shop", zone="Diablo 4 pre-order", itemID=259062, name="Diablo 4 pre-order"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12255, source={type="shop", zone="Diablo 4 pre-order", itemID=259063, name="Diablo 4 pre-order"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12256, source={type="shop", zone="Diablo 4 pre-order", itemID=259064, name="Diablo 4 pre-order"}, colors={"Black","Dark Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12257, source={type="shop", zone="Diablo 4 pre-order", itemID=259065, name="Diablo 4 pre-order"}, colors={"Beige","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12258, source={type="shop", zone="Diablo 4 pre-order", itemID=259066, name="Diablo 4 pre-order"}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Tiny"},
    {decorID=12259, source={type="shop", zone="Diablo 4 pre-order", itemID=259067, name="Diablo 4 pre-order"}, colors={"Beige","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12260, source={type="shop", zone="Diablo 4 pre-order", itemID=259068, name="Diablo 4 pre-order"}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Tiny"},
    {decorID=12261, source={type="shop", zone="Diablo 4 pre-order", itemID=259069, name="Diablo 4 pre-order"}, colors={"Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12262, source={type="shop", zone="Diablo 4 pre-order", itemID=259070, name="Diablo 4 pre-order"}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Tiny"},
    {decorID=14838, source={type="shop", zone="In-game shop", itemID=263052, name="In-game shop"}, colors={"Dark Brown","Orange","Royal Blue"}, budgetCost=1, size="Small"},
    {decorID=14839, source={type="shop", zone="In-game shop", itemID=263053, name="In-game shop"}, colors={"Deep Red","Gray","Royal Blue"}, budgetCost=1, size="Small"},
    {decorID=12173, source={type="shop", zone="Large Starter Decor Pack", itemID=258569, name="Large Starter Decor Pack"}, colors={"Dark Gray","Light Purple","Royal Blue"}, budgetCost=5, size="Large"},
    {decorID=7825, source={type="shop", zone="Lush Garden Decor Pack", itemID=250793, name="Lush Garden Decor Pack"}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=5, size="Large"},
    {decorID=7826, source={type="shop", zone="Lush Garden Decor Pack", itemID=250794, name="Lush Garden Decor Pack"}, colors={"Blue","Brown","Gray"}, budgetCost=1, size="Small"},
    {decorID=7827, source={type="shop", zone="Lush Garden Decor Pack", itemID=250795, name="Lush Garden Decor Pack"}, dyeable=true, colors={"Cyan","Navy Blue","Royal Blue"}, budgetCost=1, size="Small"},
    {decorID=7828, source={type="shop", zone="Lush Garden Decor Pack", itemID=250796, name="Lush Garden Decor Pack"}, dyeable=true, colors={"Dark Purple","Light Purple","Navy Blue"}, budgetCost=1, size="Small"},
    {decorID=9065, source={type="shop", zone="Lush Garden Decor Pack", itemID=252419, name="Lush Garden Decor Pack"}, colors={"Dark Brown","Forest Green","Olive"}, budgetCost=3, size="Small"},
    {decorID=9443, source={type="shop", zone="Lush Garden Decor Pack", itemID=253546, name="Lush Garden Decor Pack"}, colors={"Dark Brown","Olive","Orange"}, budgetCost=1, size="Small"},
    {decorID=11940, source={type="shop", zone="Lush Garden Decor Pack", itemID=258294, name="Lush Garden Decor Pack"}, colors={"Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"},
    {decorID=12171, source={type="shop", zone="Lush Garden Decor Pack", itemID=258567, name="Lush Garden Decor Pack"}, colors={"Brown","Dark Brown","Gray"}, budgetCost=3, size="Medium"},
    {decorID=12223, source={type="shop", zone="Lush Garden Decor Pack", itemID=258888, name="Lush Garden Decor Pack"}, colors={"Copper","Dark Brown","Royal Blue"}, budgetCost=5, size="Small"},
    {decorID=16039, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=264692, name="Lush Garden Decor Pack 2"}, budgetCost=3, size="Medium"},
    {decorID=17749, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=266070, name="Lush Garden Decor Pack 2"}, budgetCost=3, size="Small"},
    {decorID=17792, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=266162, name="Lush Garden Decor Pack 2"}, budgetCost=3, size="Large"},
    {decorID=17793, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=266163, name="Lush Garden Decor Pack 2"}, budgetCost=3, size="Small"},
    {decorID=17794, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=266164, name="Lush Garden Decor Pack 2"}, budgetCost=3, size="Medium"},
    {decorID=17795, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=266165, name="Lush Garden Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=18794, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=267203, name="Lush Garden Decor Pack 2"}, budgetCost=5, size="Huge"},
    {decorID=19848, source={type="shop", zone="Lush Garden Decor Pack 2", itemID=268550, name="Lush Garden Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=12244, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=259044, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Tiny"},
    {decorID=12245, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=259045, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Small"},
    {decorID=12246, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=259046, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Dark Brown","Royal Blue","Tan"}, budgetCost=1, size="Small"},
    {decorID=12264, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=259093, name="Roofus charity pet (The Roofus Pack)"}, colors={"Copper","Dark Brown","Tan"}, budgetCost=3, size="Medium"},
    {decorID=12265, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=259094, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Bronze","Dark Brown","Royal Blue"}, budgetCost=1, size="Medium"},
    {decorID=15547, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=264275, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Copper","Dark Gray","Deep Red"}, budgetCost=1, size="Medium"},
    {decorID=15548, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=264276, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Dark Gray","Deep Red","Tan"}, budgetCost=1, size="Medium"},
    {decorID=15549, source={type="shop", zone="Roofus charity pet (The Roofus Pack)", itemID=264277, name="Roofus charity pet (The Roofus Pack)"}, dyeable=true, colors={"Copper","Deep Red","Purple"}, budgetCost=1, size="Medium"},
    {decorID=14432, source={type="shop", zone="Small Starter Decor Pack", itemID=260727, name="Small Starter Decor Pack"}, colors={"Copper","Dark Gray","Royal Blue"}, budgetCost=1, size="Small"},
    {decorID=14433, source={type="shop", zone="Small Starter Decor Pack", itemID=260728, name="Small Starter Decor Pack"}, colors={"Brown","Deep Red"}, budgetCost=1, size="Small"},
    {decorID=7829, source={type="shop", zone="Spring Blossom Decor Pack", itemID=250797, name="Spring Blossom Decor Pack"}, colors={"Dark Gray","Gray","Tan"}, budgetCost=1, size="Small"},
    {decorID=7830, source={type="shop", zone="Spring Blossom Decor Pack", itemID=250798, name="Spring Blossom Decor Pack"}, colors={"Dark Brown","Gray","Light Purple"}, budgetCost=1, size="Medium"},
    {decorID=9444, source={type="shop", zone="Spring Blossom Decor Pack", itemID=253547, name="Spring Blossom Decor Pack"}, colors={"Dark Brown","Light Purple","Purple"}, budgetCost=1, size="Small"},
    {decorID=10356, source={type="shop", zone="Spring Blossom Decor Pack", itemID=254417, name="Spring Blossom Decor Pack"}, colors={"Crimson","Dark Gray","Light Purple"}, budgetCost=3, size="Large"},
    {decorID=12172, source={type="shop", zone="Spring Blossom Decor Pack", itemID=258568, name="Spring Blossom Decor Pack"}, colors={"Light Purple","Magenta","Purple"}, budgetCost=1, size="Medium"},
    {decorID=15140, source={type="shop", zone="Spring Blossom Decor Pack", itemID=263290, name="Spring Blossom Decor Pack"}, colors={"Brown","Dark Brown","Light Purple"}, budgetCost=5, size="Huge"},
    {decorID=15141, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=263291, name="Spring Blossom Decor Pack 2"}, colors={"Brown","Dark Brown","Teal"}, budgetCost=5, size="Huge"},
    {decorID=16974, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=265555, name="Spring Blossom Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=16975, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=265556, name="Spring Blossom Decor Pack 2"}, budgetCost=3, size="Large"},
    {decorID=16976, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=265557, name="Spring Blossom Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=16977, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=265558, name="Spring Blossom Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=16978, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=265559, name="Spring Blossom Decor Pack 2"}, budgetCost=3, size="Medium"},
    {decorID=17747, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=266068, name="Spring Blossom Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=17748, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=266069, name="Spring Blossom Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=17795, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=266165, name="Spring Blossom Decor Pack 2"}, budgetCost=1, size="Small"},
    {decorID=17796, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=266166, name="Spring Blossom Decor Pack 2"}, budgetCost=5, size="Medium"},
    {decorID=17797, source={type="shop", zone="Spring Blossom Decor Pack 2", itemID=266167, name="Spring Blossom Decor Pack 2"}, budgetCost=5, size="Huge"},
--     {decorID=9265, source={type="shop", zone="Unknown Promo/Shop item", itemID=253244, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=5, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=9273, source={type="shop", zone="Unknown Promo/Shop item", itemID=253257, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=5, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=9280, source={type="shop", zone="Unknown Promo/Shop item", itemID=253296, name="Unknown Promo/Shop item"}, budgetCost=1, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=16098, source={type="shop", zone="Unknown Promo/Shop item", itemID=264721, name="Unknown Promo/Shop item"}, colors={"Dark Brown","Light Brown","Royal Blue"}, budgetCost=5, size="Large"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=16099, source={type="shop", zone="Unknown Promo/Shop item", itemID=264722, name="Unknown Promo/Shop item"}, colors={"Dark Brown","Deep Red","Light Brown"}, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=16100, source={type="shop", zone="Unknown Promo/Shop item", itemID=264723, name="Unknown Promo/Shop item"}, colors={"Beige","Forest Green","Red"}, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=16101, source={type="shop", zone="Unknown Promo/Shop item", itemID=264724, name="Unknown Promo/Shop item"}, colors={"Beige","Brown","Teal"}, budgetCost=1, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=16102, source={type="shop", zone="Unknown Promo/Shop item", itemID=264725, name="Unknown Promo/Shop item"}, colors={"Forest Green","Gray","Purple"}, budgetCost=5, size="Large"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=17750, source={type="shop", zone="Unknown Promo/Shop item", itemID=266071, name="Unknown Promo/Shop item"}, colors={"Dark Brown","Dark Gray","Tan"}, budgetCost=3, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=21060, source={type="shop", zone="Unknown Promo/Shop item", itemID=269604, name="Unknown Promo/Shop item"}, colors={"Dark Brown","Deep Red","Tan"}, budgetCost=1, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=21061, source={type="shop", zone="Unknown Promo/Shop item", itemID=269605, name="Unknown Promo/Shop item"}, colors={"Dark Brown","Dark Gray","Gray"}, budgetCost=1, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=21945, source={type="shop", zone="Unknown Promo/Shop item", itemID=272353, name="Unknown Promo/Shop item"}, budgetCost=3, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=21946, source={type="shop", zone="Unknown Promo/Shop item", itemID=272354, name="Unknown Promo/Shop item"}, budgetCost=5, size="Large"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=21949, source={type="shop", zone="Unknown Promo/Shop item", itemID=272358, name="Unknown Promo/Shop item"}, budgetCost=1, size="Tiny"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=22144, source={type="shop", zone="Unknown Promo/Shop item", itemID=274784, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=22397, source={type="shop", zone="Unknown Promo/Shop item", itemID=274899, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=5, size="Large"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=22398, source={type="shop", zone="Unknown Promo/Shop item", itemID=274897, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=22895, source={type="shop", zone="Unknown Promo/Shop item", itemID=274901, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=23175, source={type="shop", zone="Unknown Promo/Shop item", itemID=274767, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=23868, source={type="shop", zone="Unknown Promo/Shop item", itemID=274903, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=23869, source={type="shop", zone="Unknown Promo/Shop item", itemID=274905, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=5, size="Large"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=23870, source={type="shop", zone="Unknown Promo/Shop item", itemID=274907, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=23883, source={type="shop", zone="Unknown Promo/Shop item", itemID=274786, name="Unknown Promo/Shop item"}, budgetCost=5, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=24196, source={type="shop", zone="Unknown Promo/Shop item", itemID=274788, name="Unknown Promo/Shop item"}, budgetCost=1, size="Small"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=24630, source={type="shop", zone="Unknown Promo/Shop item", itemID=274909, name="Unknown Promo/Shop item"}, dyeable=true, budgetCost=3, size="Medium"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=24753, source={type="shop", zone="Unknown Promo/Shop item", itemID=274988, name="Unknown Promo/Shop item"}, budgetCost=5, size="Huge"}, -- UNKNOWN PROMO/SHOP ITEM
--     {decorID=24755, source={type="shop", zone="Unknown Promo/Shop item", itemID=274991, name="Unknown Promo/Shop item"}, budgetCost=3, size="Large"}, -- UNKNOWN PROMO/SHOP ITEM
}

