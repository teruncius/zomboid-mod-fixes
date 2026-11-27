-- Bug Zapper 9000 replaces the blade input of the SharpenBlade recipe to add the
-- katana, but only on the client. It removes the old input from the recipe's
-- inputs, but not from its io lines, and loads the new one after the whetstone.
-- The client sends the chosen items by io line index, so in multiplayer the
-- server gets the blade for an index it doesn't have and the action does
-- nothing. This sets the inputs again after Bug Zapper, in the vanilla order and
-- with the katana. zz_ModFixes_SharpenBladeServer.lua does the same on the
-- server.

if getActivatedMods():contains("BugZapper9000") or getActivatedMods():contains("\\BugZapper9000") then
    require "zz_ModFixes_SharpenBladeInputs"
    ModFixesSetSharpenBladeInputs()
end
