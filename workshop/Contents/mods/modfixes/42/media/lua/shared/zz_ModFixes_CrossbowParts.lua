-- Lets the laser, the x2 scope and the red dot mount on RadArchery's crossbow.
-- Function only: the model has no attachment points for these parts, so they
-- do not show on the weapon. RadArchery sets the crossbow's hit chance every
-- tick, so the laser only gives its aiming time bonus.

if getActivatedMods():contains("RadArcheryRestrung") or getActivatedMods():contains("\\RadArcheryRestrung") then

require "zz_ModFixes_MountOn"

ModFixesAddMountOn("Base.Laser", "Base.RadCrossbow")
ModFixesAddMountOn("Base.x2Scope", "Base.RadCrossbow")
ModFixesAddMountOn("Base.RedDot", "Base.RadCrossbow")

end
