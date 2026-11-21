-- Real USA draws the places of read travel guides on the world map with
-- drawTextureScaledAspect, but passes the icon's file path instead of a
-- Texture, so it throws every frame while the map shows print media. Its
-- symbolTexture helper is local, so this lets the world map's
-- drawTextureScaledAspect take a path too and loads the texture for it.

if getActivatedMods():contains("RealUSA") or getActivatedMods():contains("\\RealUSA") then

require "ISUI/Maps/ISWorldMap"

local baseDrawTextureScaledAspect = ISWorldMap.drawTextureScaledAspect
function ISWorldMap:drawTextureScaledAspect(texture, ...)
    if type(texture) == "string" then
        texture = getTexture(texture)
        if not texture then
            return
        end
    end
    return baseDrawTextureScaledAspect(self, texture, ...)
end

end
