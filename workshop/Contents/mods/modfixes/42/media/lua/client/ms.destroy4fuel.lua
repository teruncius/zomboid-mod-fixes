-- Replaces msauce simple mods' ms.destroy4fuel.lua (same path, so this file is
-- loaded instead). Its fire starter search calls item:hasTag("StartFire"), but
-- hasTag only takes an ItemTag now, so it throws when the fuel menu opens for
-- a campfire or stove. Copy of the mod's file with the tag from vanilla
-- ISCampingMenu.

if getActivatedMods():contains("msauce.simple") or getActivatedMods():contains("\\msauce.simple") then

local ms_tools = require("ms.h.tools")

local function getCFO(selectedContainer)
    local containerType = tostring(selectedContainer:getType())
    local square = selectedContainer:getParent():getSquare()
    local cfo
    if containerType == "campfire" then
        cfo = CCampfireSystem.instance:getLuaObjectAt(square:getX(), square:getY(), square:getZ())

    elseif containerType == "barbecue" then
        cfo = ms_tools.code.getISObject(square, "IsoBarbecue")

    elseif containerType == "woodstove" or containerType == "fireplace" then
        cfo = ms_tools.code.getISObject(square, "IsoFireplace")
    end

    return cfo
end

local function lightFire(playerObj, fuelItem, lighter)
    local container = lighter:getContainer()
    local containerType = tostring(container:getType())
    local campfire = getCFO(container)
    local fuelAmt = 0

    if containerType == "campfire" and campfire.isLit then
        return
    elseif campfire.isLit and campfire:isLit() then
        return
    end

    if campingLightFireType[fuelItem:getType()] and campingLightFireType[fuelItem:getType()] > 0 then
        fuelAmt = campingLightFireType[fuelItem:getType()]
    elseif campingLightFireCategory[fuelItem:getCategory()] and campingLightFireCategory[fuelItem:getCategory()] > 0 then
        fuelAmt = campingLightFireCategory[fuelItem:getCategory()]
    end

    if ISCampingMenu.walkToCampfire(playerObj, campfire:getSquare()) and fuelAmt > 0 then
        ISCampingMenu.toPlayerInventory(playerObj, fuelItem)
        ISCampingMenu.toPlayerInventory(playerObj, lighter)

        if playerObj:isEquipped(fuelItem) then ISTimedActionQueue.add(ISUnequipAction:new(playerObj, fuelItem, 50)) end
        if playerObj:isEquipped(lighter) then ISTimedActionQueue.add(ISUnequipAction:new(playerObj, lighter, 50)) end

        local previousAction
        if containerType == "campfire" then
            previousAction = ISLightFromLiterature:new(playerObj, fuelItem, lighter, campfire, fuelAmt, 100)
        elseif containerType == "barbecue" then
            previousAction = ISBBQLightFromLiterature:new(playerObj, fuelItem, lighter, campfire, 100)
        elseif containerType == "woodstove" or containerType == "fireplace" then
            previousAction = ISFireplaceLightFromLiterature:new(playerObj, fuelItem, lighter, campfire, fuelAmt, 100)
        end
        ISTimedActionQueue.add(previousAction)

        if lighter then
            local action = ISInventoryTransferAction:new(playerObj, lighter, playerObj:getInventory(), container, nil)
            action:setAllowMissingItems(true)
            ISTimedActionQueue.addAfter(previousAction, action)
        end
    end
end

local function addSelectedToFuel(playerObj, items, containerType)
    local square = items[1]:getContainer():getParent():getSquare()
    if not luautils.walkAdj(playerObj, square, true) then return end

    local cfo = getCFO(items[1]:getContainer())
    if not cfo then return end

    for i = 1, #items do
        ISCampingMenu.toPlayerInventory(playerObj, items[i])
        local fuelAmt = ISCampingMenu.getFuelDurationForItem(items[i])
        if instanceof(items[i], "Drainable") then
            items[i]:setUsedDelta(0)
        end

        if containerType == "campfire" then
            ISTimedActionQueue.add(ISAddFuelAction:new(playerObj, cfo, items[i], fuelAmt, 10))

        elseif containerType == "barbecue" then
            ISTimedActionQueue.add(ISBBQAddFuel:new(playerObj, cfo, items[i], fuelAmt, 10))

        elseif containerType == "woodstove" or containerType == "fireplace" then
            ISTimedActionQueue.add(ISFireplaceAddFuel:new(playerObj, cfo, items[i], fuelAmt, 10))

        end

    end
end

local function addSelectedToFuelMenu(player, context, items)
    local playerObj = getSpecificPlayer(player)
    if not ms_42_settings.mooSettings["sDestroyFuel"]:getValue() then return end

    local selectedItems = ms_tools.selection.getItems(items)
    local containerType = tostring(selectedItems[1]:getContainer():getType())

    if containerType == "fireplace"
            or (containerType == "barbecue" and not selectedItems[1]:getContainer():getParent():isPropaneBBQ())
            or containerType == "campfire"
            or containerType == "woodstove"
    then

        local fuelItems  = {}
        local fuelAmount = 0
        local recipeName = ""

        for _, item in pairs(selectedItems) do
            if ISCampingMenu.isValidFuel(item) then
                table.insert(fuelItems, item)
                local oneUnit = (ISCampingMenu.getFuelDurationForItem(item) or 0.0)
                fuelAmount = fuelAmount + oneUnit;
            end
        end

        if #fuelItems > 0 then
            local title = getTextOrNull("IGUI_ContainerTitle_" .. containerType)
            local subMenu = context:getNew(context)
            recipeName = campingText.addFuel .. " (" .. ISCampingMenu.timeString(fuelAmount) .. ")"
            subMenu:addOption(recipeName, playerObj, addSelectedToFuel, fuelItems, containerType)

            local allItems = fuelItems[1]:getContainer():getItems()
            local fireStarter
            for i = 0, allItems:size() - 1 do
                local item = allItems:get(i)
                if item:hasTag(ItemTag.START_FIRE) or type == "Lighter" or type == "Matches" then
                    fireStarter = item
                    break
                end
            end

            if fireStarter and ISCampingMenu.isValidTinder(fuelItems[1]) then
                recipeName = campingText.lightCampfire .. " (" .. ISCampingMenu.timeString(ISCampingMenu.getFuelDurationForItem(fuelItems[1])) .. ")"
                subMenu:addOption(recipeName, playerObj, lightFire, fuelItems[1], fireStarter)
            end

            context:addSubMenu(context:addOption(title .. ": "), subMenu)
        end

    end

    return context
end

Events.OnFillInventoryObjectContextMenu.Add(addSelectedToFuelMenu)

local function addFuelAmount(inventoryPage, state)
    if state ~= "end" then return end
    if ms_42_settings.mooSettings["sDestroyFuel"] and not ms_42_settings.mooSettings["sDestroyFuel"]:getValue() then return end

    for _, v in ipairs(inventoryPage.backpacks) do
        local containerType = tostring(v.inventory:getType())
        if not v.tooltip then
            v.tooltip = containerType
            if v.tooltip == "none" then
                v.tooltip = getText("IGUI_InventoryTooltip")
            else
                local containerTitle = getTextOrNull("IGUI_ContainerTitle_" .. tostring(v.inventory:getType()))
                if containerTitle then v.tooltip = containerTitle end
                if v.inventory:getType() ~= "floor" and v.inventory:getParent() and v.inventory:getParent():getModData().RenameContainer_CustomName then
                    v.tooltip = v.inventory:getParent():getModData().RenameContainer_CustomName
                end
                if v.inventory:getContainingItem() then
                    v.tooltip = v.inventory:getContainingItem():getName()
                end
            end
        end

        if containerType == "fireplace"
                or (containerType == "barbecue" and not v.inventory:getParent():isPropaneBBQ())
                or containerType == "campfire"
                or containerType == "woodstove"
        then
            local cfo = getCFO(v.inventory)
            if not cfo then return end

            local fuel = ISCampingMenu.timeString(0)
            if cfo.getFuelAmount then
                fuel = ISCampingMenu.timeString(round(cfo:getFuelAmount()))
            else
                fuel = ISCampingMenu.timeString(round(cfo["fuelAmt"]))
            end
            v.tooltip   = v.tooltip .. " <LINE> " .. getText("IGUI_BBQ_FuelAmount", fuel)

        end
    end
end

Events.OnRefreshInventoryWindowContainers.Add(addFuelAmount)


local baseINVPAGERMD = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)

    baseINVPAGERMD(self, x, y)
    if not ms_42_settings.mooSettings["sDestroyFuel"]:getValue() then return end

    local containerType = self.inventory:getType()
    if not(containerType == "fireplace" or containerType == "campfire" or containerType == "woodstove"
            or (containerType == "barbecue" and not self.inventory:getParent():isPropaneBBQ())) then return end

    if self.contextM == nil then
        self.contextM = ISContextMenu.get(self.parent.player, getMouseX() + 5, getMouseY() + 5)
    elseif self.contextM:isReallyVisible() == false then
        self.contextM = ISContextMenu.get(self.parent.player, getMouseX() + 5, getMouseY() + 5)
    end

    local campfireObj = getCFO(self.inventory)
    if not campfireObj then return end

    local fireState   = getText("IGUI_Fireplace_Unlit")
    local fuel        = 0
    local fuelString  = ""

    local optionTip   = ISToolTip:new()
    optionTip:initialise()
    optionTip:setVisible(false)

    if containerType == "campfire" and campfireObj.isLit then
        fireState = getText("IGUI_Fireplace_Burning")
    elseif campfireObj.isSmouldering and campfireObj:isSmouldering() then
        fireState = getText("IGUI_Fireplace_Smouldering")
    elseif campfireObj.isLit and campfireObj:isLit() then
        fireState = getText("IGUI_Fireplace_Burning")
    end

    if campfireObj.getFuelAmount then
        fuel = campfireObj:getFuelAmount()
    else
        fuel = campfireObj["fuelAmt"]
    end

    fuelString = ISCampingMenu.timeString(round(fuel))
    local oCampfire

    if containerType == "campfire" then
        oCampfire = CCampfireSystem.instance:getLuaObjectOnSquare(campfireObj:getSquare())
        local option = self.contextM:addOption(getText("ContextMenu_CampfireInfo"), nil, ISCampingMenu.onDisplayInfo, self.parent.player, oCampfire:getIsoObject(), oCampfire)
        option.toolTip = optionTip
        option.toolTip:setName(getText("IGUI_Campfire_Campfire"))
        option.toolTip.description = getText("IGUI_BBQ_FuelAmount", fuelString) .. " (" .. fireState .. ")"

        if campfireObj.isLit then
            self.contextM:addOption(getText("ContextMenu_Put_out_fire"), nil, ISCampingMenu.onPutOutCampfire, self.parent.player, oCampfire)
        end

        self.contextM:addOption(getText("ContextMenu_Remove_fire"), nil, ISCampingMenu.onRemoveCampfire, self.parent.player, campfireObj);

    elseif containerType == "barbecue" then
        local option = self.contextM:addOption(getText("ContextMenu_BBQInfo"), nil, ISBBQMenu.onDisplayInfo, self.parent.player, campfireObj)
        option.toolTip = optionTip
        option.toolTip:setName(getText("IGUI_Campfire_Campfire"))
        option.toolTip.description = getText("IGUI_BBQ_FuelAmount", fuelString) .. " (" .. fireState .. ")"

        if campfireObj:isLit() then
            self.contextM:addOption(getText("ContextMenu_Put_out_fire"), nil, ISBBQMenu.onExtinguish, self.parent.player, campfireObj)
        end

    else
        local option = self.contextM:addOption(getText("ContextMenu_FireplaceInfo"), nil, ISFireplaceMenu.onDisplayInfo, self.parent.player, campfireObj)
        option.toolTip = optionTip
        option.toolTip:setName(getText("IGUI_Fireplace_Fireplace"))
        option.toolTip.description = getText("IGUI_BBQ_FuelAmount", fuelString) .. " (" .. fireState .. ")"

        if campfireObj:isLit() then
            self.contextM:addOption(getText("ContextMenu_Put_out_fire"), nil, ISFireplaceMenu.onExtinguish, self.parent.player, campfireObj)
        end

    end

end

end
