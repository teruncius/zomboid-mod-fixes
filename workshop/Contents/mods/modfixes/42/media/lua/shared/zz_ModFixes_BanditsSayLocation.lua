-- Bandits' Bandit.SayLocation reads the bandit's square without a nil check. On
-- multiplayer clients a bandit can be updated while its square is not loaded,
-- so the call throws every update. This skips the callout while the bandit has
-- no square.

if getActivatedMods():contains("Bandits2") or getActivatedMods():contains("\\Bandits2") then

require "Bandit"

local original = Bandit.SayLocation

function Bandit.SayLocation(bandit, targetSquare)
    if not bandit:getSquare() then
        return
    end
    return original(bandit, targetSquare)
end

end
