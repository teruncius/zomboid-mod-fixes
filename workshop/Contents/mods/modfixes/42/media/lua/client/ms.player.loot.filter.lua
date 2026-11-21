-- Replaces msauce simple mods' ms.player.loot.filter.lua (same path, so this
-- file is loaded instead). With its inventory filter on, it hides key rings by
-- returning nil from ISInventoryPage:addContainerButton. Mods that wrap the
-- function and use the button, like CleanUI, then throw. Copy of the mod's file
-- that adds the key ring button and takes it back out of the list instead, and
-- returns it.

if getActivatedMods():contains("msauce.simple") or getActivatedMods():contains("\\msauce.simple") then

local ms_tools = require("ms.h.tools")

local ISIPAddButton      = ISInventoryPage.addContainerButton
function ISInventoryPage:addContainerButton(container, texture, name, tooltip)

    if not ms_42_settings.isSandboxEnable("sPlayerInvFilter") then return ISIPAddButton(self, container, texture, name, tooltip) end
    if not ms_42_settings.isEnable("sPlayerInvFilter") then return ISIPAddButton(self, container, texture, name, tooltip) end
    if not string.contains(container:getType(), "KeyRing") then return ISIPAddButton(self, container, texture, name, tooltip) end
    if ISInventoryPage.pre_reorder_addContainerButton then return ISIPAddButton(self, container, texture, name, tooltip) end

    local button = ISIPAddButton(self, container, texture, name, tooltip)
    if button and self.backpacks[#self.backpacks] == button then
        table.remove(self.backpacks, #self.backpacks)
        self.containerButtonPanel:removeChild(button)
        self.buttonPool = self.buttonPool or {}
        table.insert(self.buttonPool, button)
    end
    return button

end

local basePageBackpackRMD = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
    basePageBackpackRMD(self, x, y)

    if not ms_42_settings.isSandboxEnable("sPlayerInvFilter") then return end
    if self.inventory:getType() ~= "none" then return end
    ms_42_settings.toggleSetting("sPlayerInvFilter", "on")
    ISInventoryPage.dirtyUI()
end


local basePaneRefresh = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    basePaneRefresh(self)

    if not ms_42_settings.isSandboxEnable("sPlayerInvFilter") then return end
    if not ms_42_settings.isEnable("sPlayerInvFilter") then return end
    if self.inventory:getType() ~= "none" then return end

    local playerObj   = ms_tools.player.getObject(self.player)
    local newItemList = {}

    for _, v in ipairs(self.itemslist) do
        for _, item in ipairs(v.items) do
            if string.contains(item:getType(), "KeyRing") then
                break
            end
            if not item.isEquipped or not item:isEquipped() then
                table.insert(newItemList, v)
                break
            end
            if item == playerObj:getPrimaryHandItem() or item == playerObj:getSecondaryHandItem() then
                table.insert(newItemList, v)
                break
            end
        end
    end

    self.itemslist = newItemList
end

end
