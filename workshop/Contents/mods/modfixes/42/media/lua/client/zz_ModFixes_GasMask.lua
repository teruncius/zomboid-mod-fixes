-- Bug Zapper 9000 gives the improvised gas mask recipe an OnCreate that removes
-- the filter, while its matching output change no longer applies in 42.21. This
-- puts the vanilla OnCreate back.

if getActivatedMods():contains("\\BugZapper9000") then
    local recipe = getScriptManager():getCraftRecipe("MakeImprovisedGasMask")
    if recipe then
        recipe:Load(recipe:getName(), "{ OnCreate = RecipeCodeOnCreate.assignRagFilterLife, }")
    end
end
