-- Config
local defaultBranchLength = 50
local torchInterval = 7
local branchSpacing = 2
local staggerBranchY = true
local placeTorches = true
local defaultTorchSlot = 1
-- End config

local args = { ... }
if #args < 2 or (string.lower(args[1]) ~= "left" and string.lower(args[1]) ~= "right") then
  print("Usage:")
  print("branch <left|right> COUNT [LENGTH]")
  return
end

local branchDir = string.lower(args[1])
local branchCount = tonumber(args[2])
local branchLength = defaultBranchLength
local fuelSlots = {}
local torchSlots = {}
local blocksMined = 0

if #args == 3 then
  branchLength = tonumber(args[3])
end

print("Creating ", branchCount, " branches of length ", branchLength)

local function setFuelSlots (slot)
  fuelSlots = {}
  for s = 1, 16 do
    if s == slot then
      table.insert(fuelSlots, s)
    else
      turtle.select(s)
      if turtle.compareTo(slot) then
        table.insert(fuelSlots, s)
      end
    end
  end
end

local function setTorchSlots (slot)
  torchSlots = {}
  for s = 1, 16 do
    if s == slot then
      table.insert(torchSlots, s)
    else
      turtle.select(s)
      if turtle.compareTo(slot) then
        table.insert(torchSlots, s)
      end
    end
  end
end

local function turnToChest ()
  if branchDir == "left" then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
end

local function turnFromChest ()
  if branchDir == "left" then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
end

local function attemptRefuel (level)
  for slot = 1, 16 do
    turtle.select(slot)
    while turtle.refuel(1) do
      setFuelSlots(slot)
      turtle.select(slot)
      if turtle.getFuelLevel() >= level then
        return true
      end
    end
  end
  return false
end

local function refuel (level)
  if attemptRefuel(level) then
    return
  else
    print("Add more fuel to continue branch mining.")
    while true do
      sleep(1)
      if attemptRefuel(level) then
        print("Resuming.")
        return
      end
    end
  end
end

local function torchesLeft ()
  local torchCount = 0
  for i = 1, #torchSlots do
    torchCount = torchCount + turtle.getItemCount(torchSlots[i])
  end
  return torchCount
end

local function moveTorches ()
  if #torchSlots > 1 then
    for i = 2, #torchSlots do
      turtle.select(torchSlots[i])
      turtle.transferTo(torchSlots[1])
    end
    setTorchSlots(torchSlots[1])
    return true
  else
    return false
  end
end

local function placeTorch ()
  if placeTorches then
    if torchesLeft() > 1 then
      if turtle.getItemCount(torchSlots[1]) > 1 then
        turtle.select(torchSlots[1])
        return turtle.placeUp()
      else
        moveTorches()
        return placeTorch()
      end
    elseif torchesLeft() == 1 then
      turtle.select(torchSlots[1])
      turtle.placeUp()
      placeTorches = false
      print("Out of torches.")
    end
  end
end

local function searchTable (haystack, needle)
  for i = 1, #haystack do
    if haystack[i] == needle then
      return true
    end
  end
  return false
end

local function dig ()
  while turtle.detect() do
    turtle.dig()
    blocksMined = blocksMined + 1
  end
end

-- Abstract around Turtle API to make movement idiot-proof
-- (Hopefully these don't overflow the stack...)

local function forward ()
  if turtle.detect() then
    dig()
  end
  if not turtle.forward() then
    forward()
  end
end

local function digUp ()
  while turtle.detectUp() do
    turtle.digUp()
    blocksMined = blocksMined + 1
  end
end

local function up ()
  if turtle.detectUp() then
    digUp()
  end
  if not turtle.up() then
    up()
  end
end

local function digDown ()
  while turtle.detectDown() do
    turtle.digDown()
    blocksMined = blocksMined + 1 
  end
end

local function down ()
  while turtle.detectDown() do
    digDown()
  end
  if not turtle.down() then
    down()
  end
end

local function turnAround ()
  turtle.turnRight()
  turtle.turnRight()
end

local function back ()
  if not turtle.back() then
    turnAround()
    forward()
    turnAround()
  end
end

-- Identify torch slots if enabled
if placeTorches then
  if turtle.getItemCount(defaultTorchSlot) > 0 then
    setTorchSlots(defaultTorchSlot)
  else
    print("Warning: inventory slot ", defaultTorchSlot, " empty.")
    print("Torches will not be placed.")  
  end
end

-- Look for fuel and then identify fuel slots
for s = 1, 16 do
  turtle.select(s)
  if turtle.refuel(1) then
    setFuelSlots(s)
    break
  end
end

for i = 1, branchCount do
  -- Determine fuel necessary to mine each branch before starting.
  -- If more fuel is needed, attempt to refuel from inventory. If
  -- necessary, pause and ask for fuel.

  local fuelCost = (i - 1) * 4 + 2 * branchLength
  if placeTorches then
    if branchLength > torchInterval then
      fuelCost = fuelCost + 2 * (branchLength / torchInterval - 1)
    end
    if branchLength % torchInterval > 0 then
      fuelCost = fuelCost + 2
    end
  end
  if turtle.getFuelLevel() < fuelCost then
    refuel(fuelCost)
  end

  -- For branches other than the first, move to the correct branch offset

  if i > 1 then 
    turnFromChest()
    for p = 1, branchSpacing * (i - 1) do
      forward()
    end
    turnToChest()
  end

  -- Stagger the y-coordinate of each branch if enabled

  if staggerBranchY then
    if i % 2 == 0 then
      digDown()
      down()
    else
      digUp()
      up()
      digUp()
    end
  end

  -- Now, mine the branch

  print("Mining branch ", i, " of ", branchCount)

  for p = 1, branchLength do
    dig()
    forward()
    digUp()
    if placeTorches and p > 1 and p % torchInterval == 1 then
      back()
      placeTorch()
      forward()
    end
  end

  -- Place torch at the end of the branch if necessary

  if placeTorches and branchLength % torchInterval == 0 then
    placeTorch()
  end

  -- Turn around and head back out

  turnAround()
  for p = 1, branchLength do
    forward()
  end
  if staggerBranchY then
    if i % 2 == 0 then
      up()
    else
      down()
    end
  end

  -- Return to the starting point

  turnFromChest()

  if i > 1 then
    for p = 1, branchSpacing * (i - 1) do
      forward()
    end
  end

  print("Branch complete.")
  print(blocksMined, " blocks mined so far.")

  -- Assume that a chest is adjacent to the starting point,
  -- and dump everything except what is known to be fuel and
  -- torches into the chest.

  for slot = 2, 16 do
    if not (searchTable(fuelSlots, slot) or searchTable(torchSlots, slot)) then
      turtle.select(slot)
      turtle.drop()
    end
  end
  turnFromChest()
end
print("Branch mining complete.")
print("Mined ", blocksMined, " blocks.")