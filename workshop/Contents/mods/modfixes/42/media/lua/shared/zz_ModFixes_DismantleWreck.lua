-- msauce simple mods adds "Dismantle Car Wreck" to normal vehicles whose engine
-- condition is below 11, but queues vanilla's ISRemoveBurntVehicle for it.
-- ISRemoveBurntVehicle:new only keeps the vehicle if its script name contains
-- "Burnt" or "Smashed", so for these vehicles isValid fails and the action is
-- dropped after the walk. This keeps the vehicle for the ones msauce offers.
--
-- In shared, because the server creates the action again in multiplayer.

if getActivatedMods():contains("msauce.simple") or getActivatedMods():contains("\\msauce.simple") then

require "Vehicles/TimedActions/ISRemoveBurntVehicle"

local baseNew = ISRemoveBurntVehicle.new

local function isBrokenVehicle(vehicle)
    local engine = vehicle:getPartById("Engine")
    return engine ~= nil and engine:getCondition() < 11
end

function ISRemoveBurntVehicle:new(character, vehicle)
    local o = baseNew(self, character, vehicle)
    if o.vehicle == nil and vehicle ~= nil and isBrokenVehicle(vehicle) then
        o.vehicle = vehicle
        o.maxTime = o:getDuration()
    end
    return o
end

end
