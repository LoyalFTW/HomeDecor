local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local DecorIndex = {}
NS.Systems.DecorIndex = DecorIndex

function DecorIndex:Build()
    wipe(self)

    self.byAchievement = {}
    self.byQuest = {}

    if not NS.Data or not NS.Data.Vendors then return end

    for _, expTbl in pairs(NS.Data.Vendors) do
        for _, zoneTbl in pairs(expTbl or {}) do
            for _, vendor in ipairs(zoneTbl or {}) do
                if vendor and vendor.items then
                    for _, it in ipairs(vendor.items) do
                        if it and it.decorID then
                            local cur = self[it.decorID]
                            if not cur then
                                self[it.decorID] = {
                                    item    = it,
                                    vendor   = vendor,       
                                    vendors  = { vendor },    
                                    source   = vendor.source,
                                }
                            else
                                cur.vendors = cur.vendors or {}
                                table.insert(cur.vendors, vendor)
                            end

                            local req = it.requirements
                            if req then
                                if req.achievement and req.achievement.id then
                                    local id = req.achievement.id
                                    self.byAchievement[id] = self.byAchievement[id] or {}
                                    table.insert(self.byAchievement[id], it.decorID)
                                end

                                if req.quest and req.quest.id then
                                    local id = req.quest.id
                                    self.byQuest[id] = self.byQuest[id] or {}
                                    table.insert(self.byQuest[id], it.decorID)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

return DecorIndex
