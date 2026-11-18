-- YANMC's CPU probe hooks ZombiePrograms stages on the first tick and names
-- each hooked table with tostring(owner). Bandits Radio Expansion gives every
-- program table an __index that returns a fallback stage for any missing key,
-- so tostring finds a "__tostring" stage. That stage calls BanditBrain.Get on
-- the table, whose getModData lookup returns another fallback stage, and so on
-- until the stack overflows. This installs the same hooks but tracks the
-- hooked tables by identity instead of by tostring.

if getActivatedMods():contains("YANMCBanditsCore") or getActivatedMods():contains("\\YANMCBanditsCore") then

require "YANMCPerformanceProbe"

local P = YANMCPerformanceProbe

if P and P.Wrap and P.InstallTables then

local hooked = {}

local function hook(owner, key, label)
    if type(owner) ~= "table" or type(owner[key]) ~= "function" then return end
    local keys = hooked[owner]
    if not keys then
        keys = {}
        hooked[owner] = keys
    end
    if keys[key] then return end
    keys[key] = true
    owner[key] = P.Wrap(label, owner[key], function(original, wrapper)
        if owner[key] == wrapper then owner[key] = original end
    end)
end

function P.InstallTables()
    local selections = {
        {'YANMCFreshNeutralWindowRoutes', {'Start', 'Work', 'Finish'}},
        {'YANMCFreshNeutralRoutePlanner', {'New', 'Step', 'CanWalkSegment'}},
        {'YANMCFreshVision', {'CanDetectPlayer'}},
        {'Bandit', {'ApplyVisuals'}},
        {'BWOPopControl', {'UpdateCivs', 'Zombie', 'StreetsSpawn', 'InhabitantsSpawn', 'SurvivorsSpawn'}},
        {'YANMCFreshCivilianEscape', {'Adapt'}},
        {'YANMCFreshZombieTargeting', {'Nearest', 'Track', 'RequestPath'}},
        {'YANMCWeekOneCrimeResponse', {'WitnessPlan', 'OnHit', 'OnDeath', 'OnSound'}},
        {'YANMCFreshPathDiagnostics', {'Tick'}},
        {'YANMCFreshRenderDiagnostics', {'Tick'}},
    }
    for _, entry in ipairs(selections) do
        for _, key in ipairs(entry[2]) do hook(_G[entry[1]], key, entry[1] .. '.' .. key) end
    end
    if BanditPrograms and BanditPrograms.Weapon then
        hook(BanditPrograms.Weapon, 'Resupply', 'Weapon.Resupply')
    end
    for name, program in pairs(ZombiePrograms or {}) do
        if type(program) == 'table' then
            for stage, fn in pairs(program) do
                if type(fn) == 'function' then hook(program, stage, 'Program.' .. name .. '.' .. stage) end
            end
        end
    end
    for _, action in ipairs({'Move', 'GoTo', 'Time', 'LootWeapons', 'Shoot'}) do
        local owner = ZombieActions and ZombieActions[action]
        for _, phase in ipairs({'onStart', 'onWorking', 'onComplete'}) do
            hook(owner, phase, 'Action.' .. action .. '.' .. phase)
        end
    end
end

end

end
