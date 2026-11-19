-- Lets RadArchery's quivers hold its crossbow bolts. The quivers' accept function
-- only takes items with the radarchery:arrow tag, which the bolts don't have, so
-- the bolts can't go in. This also accepts the whole bolts from RadArchery's bolt
-- list. Broken bolts stay out, like broken arrows. Loading the crossbow moves the
-- bolt from the quiver to the main inventory first, like vanilla ammo.
--
-- In server, because vanilla resets AcceptItemFunction after lua/shared runs.

if getActivatedMods():contains("RadArcheryRestrung") or getActivatedMods():contains("\\RadArcheryRestrung") then

require "RadArcheryQuiver"

local original = AcceptItemFunction and AcceptItemFunction.RadArchery_Quiver

if original then
    AcceptItemFunction.RadArchery_Quiver = function(container, item)
        if original(container, item) then
            return true
        end
        if container == nil or item == nil then
            return false
        end
        local bolts = RadArchery and RadArchery.BoltByItemKey
        return bolts ~= nil and bolts[item:getFullType()] ~= nil
    end
end

end
