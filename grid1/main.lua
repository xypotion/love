require "../helpers"

require "Tile"

function love.load()
	print("what")
	math.randomseed(os.time())

	t1 = Tile(10,10)
	-- t2 = Tile(2,3)
	
	tiles = {}
	for y = 1, 5, 1 do
		tiles[y] = {}
		for x = 1, 5, 1 do
			tiles[y][x] = Tile(x,y)
		end
	end
end

function love.update()
	
end

function love.draw()
	t1:draw()
	-- t2:draw()
	
	for y = 1, 5, 1 do
		for x = 1, 5, 1 do
			tiles[y][x]:draw()
		end
	end
end