-- Shared by the blade sharpening fix. Sets the inputs of the SharpenBlade recipe
-- to the vanilla blade input with the katana added, followed by the whetstone
-- input. The client sends the chosen items by io line index, so the client and
-- the server need the same inputs in the same order. The whetstone input is
-- kept as it is, because the recipe's Prop1 was set to it when the scripts
-- loaded. Clearing both lists first makes this safe to run more than once.

function ModFixesSetSharpenBladeInputs()
    local recipe = getScriptManager():getCraftRecipe("SharpenBlade")
    if not recipe or recipe:getOutputs():size() > 0 then
        return
    end

    local inputs = recipe:getInputs()
    local ioLines = recipe:getIoLines()
    local whetstone = recipe:getProp1()
    if not whetstone or not inputs:contains(whetstone) then
        return
    end

    inputs:clear()
    ioLines:clear()
    recipe:Load(recipe:getName(), "{ inputs { item 1 [Base.Katana] tags[base:sharpenable] mode:keep flags[IsSharpenable], } }")
    inputs:add(whetstone)
    ioLines:add(whetstone)
end
