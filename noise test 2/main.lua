-- pretty legit implementation of perlin noise (love.math.noise()) to generate land & water. this is what i went with for Leylines :)

function love.load()
	screenWidth, screenHeight = 512, 512
	love.window.setMode(screenWidth, screenHeight)
	math.randomseed(os.time())
	startTime = os.time()
	seed = os.time() % 2 ^ 16
	
	--generate!
	
	--or just generate this, maybe
	-- generateNoisyLine()
	
	--trying this, based on https://love2d.org/forums/viewtopic.php?f=4&t=82737&p=202175&hilit=perlin#p202175
	generateMultiOctavePerlinNoise()
	
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

function generateMultiOctavePerlinNoise()
	pixels = {}
	for i = 1, screenWidth do
		pixels[i] = {}
		for j = 1, screenHeight do
			pixels[i][j] = 0
			-- + love.math.noise(i / 256 + seed, j / 256 + seed) * 128
			+ love.math.noise(i / 128 + seed, j / 128 + seed) * 128
			+ love.math.noise(i / 64 + seed, j / 64 + seed) * 64
			+ love.math.noise(i / 32 + seed, j / 32 + seed) * 32
			+ love.math.noise(i / 16 + seed, j / 16 + seed) * 16
			+ love.math.noise(i / 8 + seed, j / 8 + seed) * 8
			+ love.math.noise(i / 4 + seed, j / 4 + seed) * 4
			-- + love.math.noise(i / 2 + seed, j / 2 + seed) * 2
			
			pixels[i][j] = math.floor(pixels[i][j] / 32) * 32
		end
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	-- for i = 1, #pixels do
	-- 	love.graphics.rectangle("fill", i, pixels[i], 1, 1)
	-- 	-- love.graphics.rectangle("fill", i, screenHeight - pixels[i], 1, 1)
	-- end

	for i = 1, screenWidth do
		for j = 1, screenHeight do
			if pixels[i][j] >= 128 then
				love.graphics.setColor(pixels[i][j], 255, pixels[i][j])
				love.graphics.rectangle("fill", i, j, 1, 1)
			else
				love.graphics.setColor(63, 63, pixels[i][j] + 64)
				love.graphics.rectangle("fill", i, j, 1, 1)
			end
		end
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
