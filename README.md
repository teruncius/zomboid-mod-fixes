# zomboid-mod-fixes

Project Zomboid (Build 42) mod with small fixes for other mods. Each fix only changes the behaviour described here.

## Fixes

### Bug Zapper 9000: no Mechanics XP for vehicle parts

Bug Zapper 9000 replaces `ISInstallVehiclePart:complete()` and `ISUninstallVehiclePart:complete()` with a copy that calls `sendObjectChange('mechanicActionDone', ...)`. The method now takes an `IsoObjectChange`, so the call throws. The part is already swapped by then, but `addMechanicsItem` and `addXp` never run. Bug Zapper has no option for this patch.

This mod restores the vanilla 42.21 functions and keeps Bug Zapper's fix for failed uninstalls always damaging the part.

File: `zz_ModFixes_PartActions.lua`

### Project Summer Car: error on vehicles without a windshield window

`Vehicles.Update.PassengerCompartment` throws on vehicles whose `Windshield` part has no window. This mod adds a nil check. It is only active with Project Summer Car.

File: `zz_ModFixes_SummerCar.lua`

### Bug Zapper 9000: errors when adding fishing bait

Bug Zapper 9000 replaces `onAddBaitToWater` and `onAddBaitToFishingNet` with a search that calls `PropertyContainer.Is`, which no longer exists. This mod restores the vanilla 42.21 actions and their local path helpers.

File: `zz_ModFixes_FishingBait.lua`

### Bug Zapper 9000: improvised gas masks lose their filter

Bug Zapper 9000 replaces the `OnCreate` of `MakeImprovisedGasMask` with one that removes the filter, while its matching output change no longer applies in 42.21. This mod restores the vanilla `OnCreate`.

File: `zz_ModFixes_GasMask.lua`

## Updates

The fixed functions are copies, so compare them with the game and the original mods after updates.

## Server config

Add the mod after the mods it fixes:

```ini
Mods=...;BugZapper9000;...;ProjectSummerCar;...;com.github.teruncius.modfixes
```
