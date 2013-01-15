args = { ... }

-- Config
local edgeSlot = 1
local roadSlot = 2
local roadWidth = 5
local clearAbove = 5
-- End config

if ninja == nil then
  print("This program requires the ninja API.")
  return
end

if #args == 0 then
  print("Usage:")
  print("road DISTANCE") 
  return
end

local distance = tonumber(args[1])
if type(distance) ~= "number" then
  print("DISTANCE must be a number!")
  return
end

local function placeBlock (slot)
  if turtle.getItemCount(slot) == 0 then
    print("Warning: out of blocks in slot ", slot)
    return false
  elseif turtle.getItemCount(slot) == 1 then
    ninja.sortInventory()
  end
  if turtle.detectDown() then
    ninja.digDown()
  end
  turtle.select(slot)
  turtle.placeDown()

  local clearedAbove = 0
  while turtle.detectUp() and clearedAbove < clearAbove do
    ninja.up()
    clearedAbove = clearedAbove + 1
  end
  while clearedAbove > 0 do
    ninja.down()
    clearedAbove = clearedAbove - 1
  end
end

local function placeEdge ()
  placeBlock(edgeSlot)
end

local function placeRoad ()
  placeBlock(roadSlot)
end

local function placeRoadBlocks ()
  for i = 2, roadWidth - 1 do
    ninja.forward()
    placeRoad()      
  end
end

for i = 1, distance do
  if turtle.getItemCount(edgeSlot) == 1 or turtle.getItemCount(roadSlot) == 1 then
    ninja.sortInventory()
  end
  if i == 1 then
    turtle.turnLeft()
    ninja.forward(math.floor(roadWidth / 2))
    if (turtle.detectDown()) then
      ninja.digDown()
    end
    placeEdge()
    ninja.turnAround()
    placeRoadBlocks()
    ninja.forward()
    placeEdge()
    turtle.turnLeft()
  else
    ninja.forward()
    if i % 2 == 0 then
      turtle.turnRight()
    else
      turtle.turnLeft()
    end
    placeEdge()
    ninja.turnAround()
    placeRoadBlocks()
    ninja.forward()
    placeEdge()
    if i % 2 == 0 then
      turtle.turnRight()
    else
      turtle.turnLeft()
    end
  end
end

if distance % 2 == 0 then
  turtle.turnRight()
  ninja.forward(math.floor(roadWidth / 2))
  turtle.turnLeft()
else
  turtle.turnLeft()
  ninja.forward(math.floor(roadWidth / 2))
  turtle.turnRight()
end
ninja.forward()