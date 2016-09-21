function love.load()
	screenWidth, screenHeight = 400, 400
	love.window.setMode(screenWidth, screenHeight)
	math.randomseed(os.time())
	startTime = os.time()
	seed = os.time() % 2 ^ 16
	
	--generate!
	
	--or just generate this, maybe
	generateNoisyLine()
	
	print(os.time() - startTime, "seconds to generate")
end

function generateNoisyLine()
	pixels = {}
	for i = 1, screenWidth do
		pixels[i] = 200 
			+ love.math.noise(i / 200 + seed) * 200 - 100
			-- + love.math.noise(i / 100 + seed) * 100 - 50
			+ love.math.noise(i / 50 + seed) * 50 - 25
			-- + love.math.noise(i / 25 + seed) * 25 - 12.5
			+ love.math.noise(i / 12.5 + seed) * 12.5 - 6.25
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	for i = 1, #pixels do
		love.graphics.rectangle("fill", i, pixels[i], 1, 1)
	end
end

--i love this article, but it's a little beyond me and/or Love2D, i think: http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/
function generateMap()
	--random points
	
	--relax points w/ lloyd's algo (twice?)
	
	--improve corners?
	
	--elevation?
	
	--rivers?
	
	--biomes???
	
	--crinkly edges. ugh, way harder than expected. despair.
end


function randomPoints(num)
end

--recursive!
function lloydRelaxation(points, iterations)
end
