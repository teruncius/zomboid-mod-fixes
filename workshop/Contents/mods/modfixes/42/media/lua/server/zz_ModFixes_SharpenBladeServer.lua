-- Gives the server the same SharpenBlade inputs as the client, so the katana
-- can be sharpened in multiplayer. See zz_ModFixes_SharpenBlade.lua.

if getActivatedMods():contains("BugZapper9000") or getActivatedMods():contains("\\BugZapper9000") then
    require "zz_ModFixes_SharpenBladeInputs"
    ModFixesSetSharpenBladeInputs()
end
