-- Stops Project Summer Car's cabin temperature update from throwing on vehicles
-- whose Windshield part has no window. Copy of its 42.15 function with a nil check.

if getActivatedMods():contains("ProjectSummerCar") or getActivatedMods():contains("\\ProjectSummerCar") then

require "Project_Summer_Car_Server"

function Vehicles.Update.PassengerCompartment(vehicle, part, elapsedMinutes)
	local pc = vehicle:getPartById("PassengerCompartment")
	
	local windowCount = 0;
	local windowOpen = 0;
	local windshield = vehicle:getPartById("Windshield")
	local windshieldBroken = false; 
	if windshield then
		local windshieldWindow = windshield:getWindow()
		windshieldBroken = windshieldWindow ~= nil and windshieldWindow:isDestroyed()
	end
	
	
	for x = 0, vehicle:getPartCount()-1 do
		local part = vehicle:getPartByIndex(x)
		--local window = part:getScriptPart().window
		--if window then -- requires starlit
		local window = part:getWindow()
		if window then
			windowCount = windowCount + 1
			if window:isDestroyed() or window:isOpen() then
				windowOpen = windowOpen + 1
			end
		end
		--print("Windows ", part:getId())
	end
	--print("Windows Count: ", windowCount, " / ", windowOpen)
	
	if RainManager.isRaining() and windshieldBroken then
		if vehicle:getDriver() then
			-- Todo: Make clothing wet too? 
			
			--TODO: FIXME!!!!
			--vehicle:getDriver():getBodyDamage():setWetness(vehicle:getDriver():getBodyDamage():getWetness() + math.max(0,vehicle:getCurrentSpeedKmHour()-10) * elapsedMinutes * 0.1)
		end
	end
	
	
	local heater = vehicle:getHeater();
	if not pc or not heater then return end
	
	local pcData = pc:getModData()
	if not pcData.windowtemperature then pcData.windowtemperature = 0.0; end
	if not pcData.temperature then pcData.temperature = 0.0; end
	local speedFactor = (math.abs(vehicle:getCurrentSpeedKmHour()) + 10) / 100 -- Instead add current wind speed?
	-- Todo: Apply real life windchill factor
	local windchill = speedFactor * 10;
	
	--vehicle:getSquare():isInARoom() // Was used to change temps slightly but.. why bother?
	
	if windowOpen > 0 then
		local oldtemp = pcData.temperature;
		pcData.temperature = oldtemp - (0.1 * oldtemp * speedFactor * math.min(3,windowOpen)); -- Slowly lowers the AC back to 0c
		if (oldtemp > 0) ~= (pcData.temperature > 0) then
			pcData.temperature = 0; -- reset to 0 if we crossed 0
		end
		
		pcData.windowtemperature = -windchill * math.min(3,windowOpen); --Applies windchill offset instantly. up to 3 windows being open matters. 
	else
		if not heater:getModData().active then
			pcData.windowtemperature = math.min(pcData.windowtemperature + 0.5 * elapsedMinutes, 5); -- Slowly set window offset to 5c (Body heat building up. Maybe consider sun on car?)
		else
			pcData.windowtemperature = math.max(pcData.windowtemperature - 0.5 * elapsedMinutes, 0); -- Slowly drop window offset to 0c (Body heat vented)
		end
	end
		-- IDEA: toxicity by piping exhaust
end

end
