-- Lets the recoil pad and the laser mount on the JS-3T Tactical Shotgun.
-- Function only: the model has no attachment points for these parts, so they
-- do not show on the weapon.

require "zz_ModFixes_MountOn"

ModFixesAddMountOn("Base.RecoilPad", "Base.JS3T_Shotgun")
ModFixesAddMountOn("Base.Laser", "Base.JS3T_Shotgun")
