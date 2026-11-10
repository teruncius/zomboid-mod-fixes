-- Real USA's map uses floors_exterior_natural_01 tiles that 42.22 still defines
-- but no longer ships textures for, so those floors render black. This points
-- each sprite that has no texture at a placeholder texture. Only the texture
-- changes; the sprite name and the save stay the same. Sprites that have a
-- texture are left alone.

if getActivatedMods():contains("RealUSA") or getActivatedMods():contains("\\RealUSA") then

local DIRT = "blends_natural_01_64"

-- missing sprite = placeholder texture
local PLACEHOLDERS = {
    floors_exterior_natural_01_0 = DIRT,
    floors_exterior_natural_01_1 = DIRT,
    floors_exterior_natural_01_2 = DIRT,
    floors_exterior_natural_01_13 = "floors_exterior_natural_01_9",
    floors_exterior_natural_01_14 = "floors_exterior_natural_01_10",
    floors_exterior_natural_01_18 = "floors_exterior_natural_01_16",
    floors_exterior_natural_01_19 = "floors_exterior_natural_01_17",
    floors_exterior_natural_01_40 = DIRT,
    floors_exterior_natural_01_42 = DIRT,
    floors_exterior_natural_01_43 = DIRT,
    floors_exterior_natural_01_48 = DIRT,
    floors_exterior_natural_01_49 = DIRT,
    floors_exterior_natural_01_50 = DIRT,
    floors_exterior_natural_01_51 = DIRT,
}

local function replaceMissingTextures()
    for name, placeholder in pairs(PLACEHOLDERS) do
        local sprite = getSprite(name)
        if sprite and sprite:hasNoTextures() and getTexture(placeholder) then
            sprite:ReplaceCurrentAnimFrames(placeholder)
        end
    end
end

Events.OnGameStart.Add(replaceMissingTextures)

end
