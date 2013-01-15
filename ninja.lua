function dig ()
  while turtle.detect() do
    turtle.dig()
  end
end

function forward (count)
  if count == nil then
    count = 1
  end

  while count > 0 do
    if turtle.detect() then
      dig()
    end
    if not turtle.forward() then
      forward()
    end
    count = count - 1
  end
end

function digUp ()
  while turtle.detectUp() do
    turtle.digUp()
  end
end

function up ()
  if turtle.detectUp() then
    digUp()
  end
  if not turtle.up() then
    up()
  end
end

function digDown ()
  while turtle.detectDown() do
    turtle.digDown()
  end
end

function down ()
  while turtle.detectDown() do
    digDown()
  end
  if not turtle.down() then
    down()
  end
end

function turnAround ()
  turtle.turnRight()
  turtle.turnRight()
end

function back ()
  if not turtle.back() then
    turnAround()
    forward()
    turnAround()
  end
end

function sortInventory ()
  for i = 1, 15 do
    if turtle.getItemCount(i) > 0 then
      spaceLeft = turtle.getItemSpace(i)
      if spaceLeft > 0 then
        for j = i + 1, 16 do
          turtle.select(i)
          if i ~= j then
            if turtle.compareTo(j) then
              turtle.select(j)
              if turtle.getItemCount(j) <= spaceLeft then
                spaceLeft = spaceLeft - turtle.getItemCount(j)
              else
                spaceLeft = 0
              end
              turtle.transferTo(i)
            end
          end
	  if spaceLeft == 0 then
            break
          end
        end
      end
    end
  end
end
