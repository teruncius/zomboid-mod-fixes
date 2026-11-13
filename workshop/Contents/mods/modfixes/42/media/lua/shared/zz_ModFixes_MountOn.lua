-- Shared by the weapon part fixes. DoParam replaces a part's whole MountOn list
-- and the script Item has no getter for it, so this reads the current list from
-- a new instance of the part, appends the weapon and writes the full list back.
-- This keeps the weapons that the game and other mods put in the list.

function ModFixesAddMountOn(partName, weapon)
    local script = ScriptManager.instance:getItem(partName)
    local part = script and instanceItem(partName)
    if not part then
        return
    end

    local current = part:getMountOn()
    local weapons = {}
    for i = 0, current:size() - 1 do
        local name = current:get(i)
        if name == weapon then
            return
        end
        table.insert(weapons, name)
    end
    table.insert(weapons, weapon)

    script:DoParam("MountOn = " .. table.concat(weapons, ";"))
end
