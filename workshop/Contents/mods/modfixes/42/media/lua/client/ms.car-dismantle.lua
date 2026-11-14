-- Replaces msauce simple mods' ms.car-dismantle.lua (same path, so this file is
-- loaded instead). Its welding mask check calls item:hasTag("WeldingMask"), but
-- hasTag only takes an ItemTag now, so it throws for every item in the
-- inventory when the vehicle menu opens. Copy of the mod's file with the check
-- from vanilla ISVehicleMenu.

if getActivatedMods():contains("msauce.simple") or getActivatedMods():contains("\\msauce.simple") then

local ms_tools = require("ms.h.tools")
local baseFMOV = ISVehicleMenu.FillMenuOutsideVehicle

local function predicateWeldingMask(item)
    return item:hasTag(ItemTag.WELDING_MASK) or item:getType() == "WeldingMask"
end
local function comparatorDrainableUsesInt(item1, item2)
    return item1:getCurrentUses() - item2:getCurrentUses()
end

function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    baseFMOV(player, context, vehicle, test)

    local playerObj = ms_tools.player.getObject(player)

    -- remove broken vehicles
    if not(string.match(vehicle:getScript():getName(), "Burnt") or string.match(vehicle:getScript():getName(), "Smashed")) and
            vehicle:getPartById("Engine"):getCondition() < 11 then
        local option = context:addOption(getText("ContextMenu_RemoveBurntVehicle") , playerObj, ISVehicleMenu.onRemoveBurntVehicle, vehicle);
        local toolTip = ISToolTip:new();
        toolTip:initialise();
        toolTip:setVisible(false);
        option.toolTip = toolTip;
        toolTip:setName(getText("ContextMenu_RemoveBurntVehicle"));
        toolTip.description = getText("Tooltip_removeBurntVehicle") .. " <LINE> <LINE> ";

        if playerObj:getInventory():containsEvalRecurse(predicateWeldingMask) then
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.WeldingMask") .. " 1/1";
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingMask") .. " 0/1";
            option.notAvailable = true;
        end

        local blowTorch = playerObj:getInventory():getBestTypeEvalRecurse("Base.BlowTorch", comparatorDrainableUsesInt)
        if blowTorch then
            local blowTorchUseLeft = blowTorch:getCurrentUses();
            if blowTorchUseLeft >= 10 then
                toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. 10;
            else
                toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. 10;
                option.notAvailable = true;
            end
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " 0/10";
            option.notAvailable = true;
        end
    end

end

end
