-- Bug Zapper 9000 replaces these actions with a search that calls
-- PropertyContainer.Is, which no longer exists. These are the vanilla 42.21
-- functions. The path helpers are copies, since vanilla keeps them local.

if getActivatedMods():contains("BugZapper9000") or getActivatedMods():contains("\\BugZapper9000") then

local function isValidWaterSquare(square)
    if square == nil then
        return false
    end
    local floor = square:getFloor()
    return floor ~= nil and floor:hasProperty(IsoFlagType.water)
end

local function isValidShoreSquare(square)
    if square == nil then
        return false
    end
    if square:isSolid() or square:isSolidTrans() then
        return false
    end
    -- Shore squares have both a non-water floor tile and a water tile.
    local floor = square:getFloor()
    if floor == nil then
        return false
    end
    if floor:hasProperty(IsoFlagType.water) then
        return false
    end
    return true
end

local function isSquareAdjacentToWater(square)
    if not isValidShoreSquare(square) then
        return false
    end
    for i=1,8 do
        local square2 = square:getAdjacentSquare(IsoDirections.fromIndex(i-1))
        if isValidWaterSquare(square2) then
            return true
        end
    end
    return false
end

local function getSquaresAdjacentToWater(x, y, z, range)
    local result = {}
    for y1=y-range,y+range do
        local square = getCell():getGridSquare(x-range, y1, z)
        if isSquareAdjacentToWater(square) then
            table.insert(result, square)
        end
        square = getCell():getGridSquare(x+range, y1, z)
        if isSquareAdjacentToWater(square) then
            table.insert(result, square)
        end
    end
    for x1=x-range+1,x+range-1 do
        local square = getCell():getGridSquare(x1, y-range, z)
        if isSquareAdjacentToWater(square) then
            table.insert(result, square)
        end
        square = getCell():getGridSquare(x1, y+range, z)
        if isSquareAdjacentToWater(square) then
            table.insert(result, square)
        end
    end
    return result
end

local function findPathNextToWater(playerObj, waterSquare, range, callback, args)
    if playerObj:getZ() ~= 0 then
        return nil
    end
    local squares = getSquaresAdjacentToWater(waterSquare:getX(), waterSquare:getY(), waterSquare:getZ(), range)
    while #squares == 0 and range < 5 do
        range = range + 1
        squares = getSquaresAdjacentToWater(waterSquare:getX(), waterSquare:getY(), waterSquare:getZ(), range)
    end
    if #squares == 0 then
        return nil
    end
    local locations = {}
    for _,square in ipairs(squares) do
        table.insert(locations, square:getX() + 0.5)
        table.insert(locations, square:getY() + 0.5)
        table.insert(locations, square:getZ())
    end
    local action = ISPathFindAction:pathToNearest(playerObj, locations)
    action:setOnComplete(ISWorldObjectContextMenu.onWalkNextToWaterComplete, callback, args)
    action:setOnFail(ISWorldObjectContextMenu.onWalkNextToWaterFail, playerObj, waterSquare, range, callback, args)
    ISTimedActionQueue.add(action)
    return action
end

ISWorldObjectContextMenu.onAddBaitToWater = function(playerObj, chum, square)
    findPathNextToWater(playerObj, square, 1, function(args)
        ISWorldObjectContextMenu.transferIfNeeded(args.playerObj, args.chum)
        ISTimedActionQueue.add(AddChumToWaterAction:new(args.playerObj, args.chum, args.square));
    end, { playerObj=playerObj, chum=chum, square=square })
end

ISWorldObjectContextMenu.onAddBaitToFishingNet = function(worldobjects, playerObj, trap, bait)
    findPathNextToWater(playerObj, trap:getSquare(), 1, function(args)
        ISWorldObjectContextMenu.transferIfNeeded(args.playerObj, args.bait)
        ISTimedActionQueue.add(ISAddBaitToFishNetAction:new(args.playerObj, args.trap, args.bait));
    end, { playerObj=playerObj, trap=trap, bait=bait })
end

end
