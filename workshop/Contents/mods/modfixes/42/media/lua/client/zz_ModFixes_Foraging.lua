-- Bug Zapper 9000 fixes the item count range, but its copy lacks the 42.21 branch
-- that keeps the stored count of a restored icon. This has both.

if getActivatedMods():contains("\\BugZapper9000") then

function ISBaseIcon:initItemCount()
    if self.icon and self.icon.count then
        self.itemCount = self.icon.count
    elseif self.itemDef then
        if self.itemDef.minCount == self.itemDef.maxCount then
            self.itemCount = self.itemDef.minCount
        else
            self.itemCount = ZombRand(self.itemDef.minCount, self.itemDef.maxCount + 1)
        end
    end
end

end
