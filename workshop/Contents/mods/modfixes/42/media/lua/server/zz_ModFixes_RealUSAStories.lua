-- Real USA lays story zones named Forest in town parks and along the roads,
-- and adds them to existing worlds too (RUSA_Stories.lua). The game rolls its
-- forest stories in them when one of their chunks loads, visited or not:
-- camps with tents, hunter and hermit camps, burials. So these show up in
-- towns. This removes the Forest story zones that lie in towns, listed in
-- zz_ModFixes_RealUSAStoriesData.lua, once the world's zones are loaded and
-- Real USA has added its own. The game saves the zones, so they stay removed.
-- Stories already placed stay where they are.

if getActivatedMods():contains("RealUSA") or getActivatedMods():contains("\\RealUSA") then
if not isClient() then

require "zz_ModFixes_RealUSAStoriesData"

local function removeUrbanStories()
    if not RealUSA or not RealUSA.inCountryWorld or not RealUSA.inCountryWorld() then
        return
    end
    local grid = getWorld():getMetaGrid()
    local zones = ModFixesRealUSAUrbanStories
    local removed = 0
    for i = 1, #zones, 4 do
        local zone = grid:getZoneWithBoundsAndType(zones[i], zones[i + 1], 0, zones[i + 2], zones[i + 3], "ZoneStory")
        if zone and zone:getName() == "Forest" then
            grid:removeZone(zone)
            removed = removed + 1
        end
    end
    if removed > 0 then
        print("[ModFixes] Real USA: removed " .. removed .. " Forest story zones in towns")
    end
end

Events.OnLoadedMapZones.Add(removeUrbanStories)

end
end
