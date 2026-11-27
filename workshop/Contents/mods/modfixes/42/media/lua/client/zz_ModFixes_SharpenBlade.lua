-- Bug Zapper 9000 replaces the blade input of the SharpenBlade recipe to add the
-- katana. It removes the old input from the recipe's inputs, but not from its
-- io lines, and loads the new one after the whetstone. The client sends the
-- chosen items by io line index, and Bug Zapper's file only runs on the client,
-- so in multiplayer the server gets the blade for an index it doesn't have and
-- the action does nothing. This puts the new blade input back in the place of
-- the old one, so the indexes match the server's recipe again.

if getActivatedMods():contains("BugZapper9000") or getActivatedMods():contains("\\BugZapper9000") then
    local recipe = getScriptManager():getCraftRecipe("SharpenBlade")
    if recipe then
        local inputs = recipe:getInputs()
        local outputs = recipe:getOutputs()
        local ioLines = recipe:getIoLines()

        local staleIndex, blade
        for i = 0, ioLines:size() - 1 do
            local line = ioLines:get(i)
            if inputs:contains(line) then
                if string.find(line:getOriginalLine(), "IsSharpenable", 1, true) then
                    blade = line
                end
            elseif not outputs:contains(line) and not staleIndex then
                staleIndex = i
            end
        end

        if staleIndex and blade then
            local order = {}
            for i = 0, ioLines:size() - 1 do
                local line = ioLines:get(i)
                if i == staleIndex then
                    table.insert(order, blade)
                elseif line ~= blade then
                    table.insert(order, line)
                end
            end

            ioLines:clear()
            inputs:clear()
            for _, line in ipairs(order) do
                ioLines:add(line)
                if not outputs:contains(line) then
                    inputs:add(line)
                end
            end
        end
    end
end
