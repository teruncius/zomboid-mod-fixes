# zomboid-mod-fixes

Project Zomboid (Build 42) mod with small fixes for other mods. Each fix only changes the behaviour described here. Every fix only runs when the mod it fixes is active.

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

### Bug Zapper 9000: Inventive trait bonus missing for skill recipes

Bug Zapper 9000 replaces `xpUpdate.onLoad` with an older copy that ignores the Inventive trait. This mod registers the vanilla function again.

File: `zz_ModFixes_SkillRecipes.lua`

### Bug Zapper 9000: restored forage icons re-roll their item count

Bug Zapper 9000 replaces `ISBaseIcon:initItemCount` with a copy that ignores `self.icon.count`. This mod keeps its fix for the item count range and adds that branch back.

File: `zz_ModFixes_Foraging.lua`

### Real USA: black floor tiles

Real USA's map uses `floors_exterior_natural_01` tiles that 42.22 still defines but has no textures for (`_0`, `_1`, `_2`, `_13`, `_14`, `_18`, `_19`, `_40`, `_42`, `_43`, `_48` to `_51`), so these floors render black. This mod gives these sprites a placeholder texture on the client: dirt, or a tile from the same row of the tileset that still has a texture. It only changes the texture, not the saved sprite, and skips sprites that have a texture again.

File: `zz_ModFixes_RealUSATiles.lua`

### Vanilla: errors when reloading with a chest rig, ALICE belt or shoulder holster

`ISReloadWeaponAction.setReloadSpeed` reads the worn ammo strap without a nil check. With a fast reload tag from another item and no ammo strap, reloading a shotgun or loading bullets into a magazine throws, and the reload action then throws on every update. This mod adds the nil check. It is always active.

File: `zz_ModFixes_ReloadSpeed.lua`

### Bandits: error when a bandit has no square

`Bandit.SayLocation` reads the bandit's square without a nil check. On multiplayer clients a bandit can be updated while its square is not loaded, which throws on every update. This mod skips the callout while the bandit has no square. It is only active with Bandits.

File: `zz_ModFixes_BanditsSayLocation.lua`

### Vanilla: no recoil pad or laser for the tactical shotgun

The recoil pad and the laser can't be mounted on the JS-3T Tactical Shotgun, even though its item script names a recoil pad model. This mod adds the shotgun to both parts' `MountOn` lists. The parts only change the stats: the model has no attachment points for them, so they don't show. It is always active.

File: `zz_ModFixes_TacticalShotgunParts.lua`

### RadArchery Restrung: no laser or sights for the crossbow

This mod adds the crossbow to the `MountOn` lists of the laser, the x2 scope and the red dot. The parts only change the stats: the model has no attachment points for them, so they don't show. The x2 scope and the red dot share the scope slot, so the crossbow takes one of them. RadArchery sets the crossbow's hit chance every tick, so the laser only shortens the aiming time. It is only active with RadArchery Restrung.

File: `zz_ModFixes_CrossbowParts.lua`

Both use `zz_ModFixes_MountOn.lua`. It reads a part's current `MountOn` list from the game, appends the weapon and writes the whole list back, so weapons from the game and other mods stay in the list.

## Updates

The fixed functions are copies, so compare them with the game and the original mods after updates.

## Server config

Add the mod after the mods it fixes:

```ini
Mods=...;BugZapper9000;...;ProjectSummerCar;...;RealUSA;...;Bandits2;...;com.github.teruncius.modfixes
```
