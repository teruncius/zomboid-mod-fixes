-- Restores the Mechanics XP of installing and uninstalling vehicle parts.
--
-- Bug Zapper 9000 replaces both complete() functions with a copy that passes a
-- string to sendObjectChange. Since the method takes an IsoObjectChange the call
-- throws, before addMechanicsItem and addXp run. These are the vanilla 42.21
-- functions, with Bug Zapper's fix for failed uninstalls always damaging the part.
--
-- The zz_ prefix and loadModAfter keep this after Bug Zapper's Mechanic.lua. It
-- stays in shared so that damnlibGlass, which loads from server, wraps this copy.

if getActivatedMods():contains("BugZapper9000") or getActivatedMods():contains("\\BugZapper9000") then

require "Vehicles/TimedActions/ISInstallVehiclePart"
require "Vehicles/TimedActions/ISUninstallVehiclePart"

function ISInstallVehiclePart:complete()
    if self.item == nil then
        return false
    end
   	if self.vehicle then
    	if not self.part then
    		print('no such part ',self.part)
    		return false
    	end
	    self.item:setJobDelta(0)
--	    self.character:addMechanicsItem(self.item:getID() .. self.vehicle:getMechanicalID() .. "1", getGameTime():getCalender():getTimeInMillis());

	    self.character:removeFromHands(self.item)
	    self.character:getInventory():DoRemoveItem(self.item)
	    sendRemoveItemFromContainer(self.character:getInventory(),self.item)

        local perksTable = VehicleUtils.getPerksTableForChr(self.part:getTable("install").skills, self.character)

        local keyvalues = self.part:getTable("install");
        local perks = keyvalues.skills;
        local success, failure = VehicleUtils.calculateInstallationSuccess(perks, self.character, perksTable);
        if not instanceof(self.item, "InventoryItem") then
            print('item is nil')
            return
        end
        if instanceof(self.item, "Radio") and self.item:getDeviceData() ~= nil then
            local presets = self.item:getDeviceData():getDevicePresets()
            if self.part:getDeviceData() == nil then
                self.part:createSignalDevice()
            end
            self.part:getDeviceData():cloneDevicePresets(presets)
        end
        if ZombRand(100) < success then
            self.part:setInventoryItem(self.item, self.character:getPerkLevel(Perks.Mechanics))
            local tbl = self.part:getTable("install")
            if tbl and tbl.complete then
                VehicleUtils.callLua(tbl.complete, self.vehicle, self.part)
            end
            self.vehicle:transmitPartItem(self.part)
            self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = true})
            self.character:addMechanicsItem(self.item:getID() .. self.vehicle:getMechanicalID() .. "1", self.part, getGameTime():getCalender():getTimeInMillis());
        elseif ZombRand(100) < failure then
            self.item:setCondition(self.item:getCondition() - ZombRand(5,10));
            self.character:getInventory():AddItem(self.item);
            sendAddItemToContainer(self.character:getInventory(), self.item);
            playServerSound("PZ_MetalSnap", self.character:getCurrentSquare());
            self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = false})
            addXp(self.character, Perks.Mechanics, 1);
        else
            self.character:getInventory():AddItem(self.item);
            sendAddItemToContainer(self.character:getInventory(), self.item);
            self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = false})
            addXp(self.character, Perks.Mechanics, 1);
        end
    else
    	print('no such vehicle id=',self.vehicle)
    	return false
    end

	return true
end

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
