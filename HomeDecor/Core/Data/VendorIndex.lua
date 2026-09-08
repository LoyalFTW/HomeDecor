local _, NS = ...

local VendorIndex = { byNPC = {}, byItem = {} }
NS.Systems.VendorIndex = VendorIndex

function VendorIndex:Rebuild()
  wipe(self.byNPC)
  wipe(self.byItem)
  local records = NS.Systems.Catalog.ordered
  for index = 1, #records do
    local record = records[index]
    local npcID = record.sourceType == "vendor" and tonumber(record.sourceID)
    if npcID then
      local vendorRecords = self.byNPC[npcID]
      if not vendorRecords then
        vendorRecords = {}
        self.byNPC[npcID] = vendorRecords
      end
      vendorRecords[#vendorRecords + 1] = record
    end
    if record.sourceType == "vendor" then
      local itemID = tonumber(record.itemID)
      if itemID then
        local itemRecords = self.byItem[itemID]
        if not itemRecords then
          itemRecords = {}
          self.byItem[itemID] = itemRecords
        end
        itemRecords[#itemRecords + 1] = record
      end
    end
  end
end

function VendorIndex:Get(npcID)
  return self.byNPC[tonumber(npcID)]
end

function VendorIndex:GetByItem(itemID)
  return self.byItem[tonumber(itemID)]
end
