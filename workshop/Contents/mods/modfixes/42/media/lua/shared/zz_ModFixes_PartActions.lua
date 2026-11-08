-- Vanilla 42.21 ISUninstallVehiclePart:complete() with one change: a failed
-- uninstall only damages the part on a failure roll. Vanilla compares the wrong
-- way round, so every failed uninstall damages it.

if getActivatedMods():contains("\\BugZapper9000") then

require "Vehicles/TimedActions/ISUninstallVehiclePart"

function ISUninstallVehiclePart:complete()
    if self.vehicle then
    	if not self.part then
    		print('no such part '..tostring(self.part))
    		return false
    	end
	    local perksTable = VehicleUtils.getPerksTableForChr(self.part:getTable("install").skills, self.character)
    	local keyvalues = self.part:getTable("install");
    	local perks = keyvalues.skills;
    	local success, failure = VehicleUtils.calculateInstallationSuccess(perks, self.character, perksTable);
    	local item = self.part:getInventoryItem()
    	if not item then
    		print('part already uninstalled ', self.part)
    		return false
    	end
    	if instanceof(item, "Radio") and item:getDeviceData() ~= nil then
            if self.part:getDeviceData() == nil then
                self.part:createSignalDevice()
            end
    		local presets = self.part:getDeviceData():getDevicePresets()
    		item:getDeviceData():cloneDevicePresets(presets)
    	end
    	if ZombRand(100) < success then
			item:setItemCapacity(self.part:getContainerContentAmount());
			self.part:setInventoryItem(nil)
    		local tbl = self.part:getTable("uninstall")
    		if tbl and tbl.complete then
        		VehicleUtils.callLua(tbl.complete, self.vehicle, self.part, item)
    		end
    		self.vehicle:transmitPartItem(self.part)
    		-- this is so player don't go over inventory capacity when removing parts
    		if self.character:getInventory():hasRoomFor(self.character, item) then
    			self.character:getInventory():AddItem(item);
    			sendAddItemToContainer(self.character:getInventory(), item);
    		else
    			local square = self.character:getCurrentSquare()
    			local dropX,dropY,dropZ = ISTransferAction.GetDropItemOffset(self.character, square, item)
    			self.character:getCurrentSquare():AddWorldInventoryItem(item, dropX, dropY, dropZ);
				if not isServer() then
					ISInventoryPage.renderDirty = true
				end
			end
   			self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = true})
   			self.character:addMechanicsItem(item:getID() .. self.vehicle:getMechanicalID() .. "0", self.part, getGameTime():getCalender():getTimeInMillis());
   		elseif ZombRand(100) < failure then
   			self.part:setCondition(self.part:getCondition() - ZombRand(5,10));
   			self.vehicle:transmitPartCondition(self.part)
   			playServerSound("PZ_MetalSnap", self.character:getCurrentSquare());
   			self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = false})
   			addXp(self.character, Perks.Mechanics, 1);
   		end
   	else
   		print('no such vehicle id=', self.vehicle)
   		return false
   	end

	return true
end

end
