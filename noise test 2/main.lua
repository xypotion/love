function love.load()
	screenWidth, screenHeight = 512, 512
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
	-- halfway = (screenWidth / 2)
	for i = 1, screenWidth do
		-- bump = screenHeight - ((i - halfway) ^ 2) / screenHeight * 4
		pixels[i] = i
			+ love.math.noise(i / 200 + seed) * 200 - 100
			-- + love.math.noise(i / 100 + seed) * 100 - 50
			+ love.math.noise(i / 50 + seed) * 50 - 25
			-- + love.math.noise(i / 25 + seed) * 25 - 12.5
			+ love.math.noise(i / 12.5 + seed) * 12.5 - 6.25
		-- pixels[i] = bump
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	for i = 1, #pixels do
		love.graphics.rectangle("fill", i, pixels[i], 1, 1)
		-- love.graphics.rectangle("fill", i, screenHeight - pixels[i], 1, 1)
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
