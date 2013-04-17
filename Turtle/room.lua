local tArgs = { ... }
shell.run('clear')
if #tArgs < 3 then
	print( "----------------------------------" )
	print( "-- Room Digger v0.1             --" )
	print( "-- By Keith                     --" )
	print( "----------------------------------" )
	print( "Usage: room <width> <length> <height>" )
	return
end

local width = 0
local height = 0
local length = 0
local collected = 0
local direction = 0
local directionToggle = 0
local heightToggle = 1

width = tonumber(tArgs[1])
if width <= 0 then
	print( "Width must be positive ")
	return
end

length = tonumber(tArgs[2])
if length <= 0 then
	print( "Length must be positive ")
	return
end

height = tonumber(tArgs[3])
if height <= 0 then
	print( "height must be positive ")
	return
end

-- Local Functions
local function collect()
	collected = collected + 1
	if math.fmod(collected, 25) == 0 then
		print( "Mined "..collected.." items." )
	end
end

local function tryDig()
	while turtle.detect() do
		if turtle.dig() then
			collect()
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

local function tryDigUp()
	while turtle.detectUp() do
		if turtle.digUp() then
			collect()
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

local function tryDigDown()
	while turtle.detectDown() do
		if turtle.digDown() then
			collect()
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

local function refuel()
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" or fuelLevel > 0 then
		return
	end
	
	local function tryRefuel()
		for n=1,16 do
			if turtle.getItemCount(n) > 0 then
				turtle.select(n)
				if turtle.refuel(1) then
					turtle.select(1)
					return true
				end
			end
		end
		turtle.select(1)
		return false
	end
	
	if not tryRefuel() then
		print( "Add more fuel to continue." )
		while not tryRefuel() do
			sleep(1)
		end
		print( "Resuming Operation." )
	end
end

local function tryUp()
	refuel()
	while not turtle.up() do
		if turtle.detectUp() then
			if not tryDigUp() then
				return false
			end
		elseif turtle.attackUp() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	return true
end

local function tryDown()
	refuel()
	while not turtle.down() do
		if turtle.detectDown() then
			if not tryDigDown() then
				return false
			end
		elseif turtle.attackDown() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	return true
end

local function tryForward()
	refuel()
	while not turtle.forward() do
		if turtle.detect() then
			if not tryDig() then
				return false
			end
		elseif turtle.attack() then
			collect()
		else
			sleep( 0.5 )
		end
	end
	return true
end

local function clearSubRow()
	if directionToggle == 0 then
	 	turtle.turnLeft()
	 	directionToggle = 1
	else
	 	turtle.turnRight()
	 	directionToggle = 0
	end
	for k=2, width do
	 	tryDig()
	 	tryForward()
	end
	if directionToggle == 0 then
	 	turtle.turnLeft()
	else
	 	turtle.turnRight()
	end
end

--our dig routine
local function clearRow()
	--dig forward - enter our row
	tryDig()
	tryForward()
	--clear the first row
	clearSubRow()
	for j=2, height do
		if heightToggle == 1 then
			tryDigUp()
			tryUp()
		else
			tryDigDown()
			tryDown()
		end
		clearSubRow()
	end
	-- --switch our height direction
	if heightToggle == 1 then
	 	heightToggle = 0
	else 
	 	heightToggle = 1
	end
end

print("Do you want me to dig left or right? [l/r]")
local continue = false
while continue == false do
	direction = string.lower(io.read())
	if direction == 'l' or direction == 'r' or direction == 'left' or direction =='right' then
		continue = true
		direction = string.sub(direction, 1, 1)
		if direction == 'l' then
			direction = 0
		elseif direction == 'r' then
			direction = 1
		end
	end
	if not continue then
		sleep( 0.5 )
		print("Invalid Entry - please use [l/r/left/right]")
	end
end

--initial dig into the wall
refuel()
directionToggle = direction
depth = 0
heightToggle = 1

for i=1, length do
	clearRow()
end

--get your ass back
if heightToggle then
	for i=1, height do
		refuel()
		turtle.down()
	end
end
if directionToggle ~= direction then
	--come back to the right side of the room
	if directionToggle == 1 then
	 	turtle.turnRight()
	else
	 	turtle.turnLeft()
	end
	for i=1, length do
		refuel()
		turtle.forward()
	end
	if directionToggle == 0 then
	 	turtle.turnRight()
	else
	 	turtle.turnLeft()
	end
end
for i=1, length do
	refuel()
	turtle.back()
end
print('Finished')
