-- Vanilla ISReloadWeaponAction.setReloadSpeed reads the worn ammo strap without a
-- nil check. With a fast reload tag from another item (chest rig, ALICE belt,
-- shoulder holster) and no strap, reloading a shotgun or loading a magazine with
-- a non-magazine gun in hand throws. The action's start() then never finishes,
-- so its update() throws every tick. This is the vanilla 42.22 function with the
-- nil checks added.

require "TimedActions/ISReloadWeaponAction"

function ISReloadWeaponAction.setReloadSpeed(character, rack)
	local baseReloadSpeed = 0.8;
	if rack then
		-- reloading skill has less impact on racking, panic does nothing
		baseReloadSpeed = baseReloadSpeed + (character:getPerkLevel(Perks.Reloading) * 0.04);
	else
		baseReloadSpeed = baseReloadSpeed + (character:getPerkLevel(Perks.Reloading) * 0.10);
		baseReloadSpeed = baseReloadSpeed - (character:getMoodles():getMoodleLevel(MoodleType.PANIC) * 0.05);
	end

	-- check for ammo straps
	local gun = character:getPrimaryHandItem();
	local strap = character:getWornItem(ItemBodyLocation.AMMO_STRAP);
	local strapName = strap and strap:getClothingItemName();
	local reloadFast = character:hasEquippedTag(ItemTag.RELOAD_FAST_SHELLS) or character:hasEquippedTag(ItemTag.RELOAD_FAST_BULLETS) or character:hasEquippedTag(ItemTag.RELOAD_FAST_MAGAZINES)
	local strapFound = false;
	if gun and (reloadFast or character:hasWornTag(ItemTag.RELOAD_FAST_MAGAZINES) or (strap and strap:getClothingItem())) then
		local shell = false;
		local magazine = false;
		if gun:getAmmoType() == AmmoType.SHOTGUN_SHELLS then
			shell = true;
		elseif gun:getMagazineType() then
			magazine = true;
		end
		if magazine and (character:hasEquippedTag(ItemTag.RELOAD_FAST_MAGAZINES) or character:hasWornTag(ItemTag.RELOAD_FAST_MAGAZINES)) then
			strapFound = true;
		elseif shell and (character:hasEquippedTag(ItemTag.RELOAD_FAST_SHELLS) or character:hasWornTag(ItemTag.RELOAD_FAST_SHELLS) or strapName == "AmmoStrap_Shells") then
			strapFound = true;
		elseif not shell and not magazine and (character:hasEquippedTag(ItemTag.RELOAD_FAST_BULLETS) or character:hasWornTag(ItemTag.RELOAD_FAST_BULLETS) or strapName == "AmmoStrap_Bullets") then
			strapFound = true;
		end
	end
	if strapFound then
		baseReloadSpeed = baseReloadSpeed * 1.15;
	end
	-- vehicles driver take bit longer to reload their weapon
	if character:getVehicle() and character:getVehicle():getDriver() == character then
		baseReloadSpeed = baseReloadSpeed * 0.8;
	end
	character:setVariable("ReloadSpeed", baseReloadSpeed);
end
