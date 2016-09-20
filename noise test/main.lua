function love.load()
	love.window.setMode(720, 720)
	math.randomseed(os.time())
	-- print(love.math.getRandomSeed())--os.time()))
	seed = os.time() % 2 ^ 16
	denominator = 50
	counter = 0
	frameCounter = 0
	
	genTerrain()
	
	-- love.graphics.setBackgroundColor(0, 0, 0)
end

function genTerrain()
	--make a canvas
	canvas = love.graphics.newCanvas(720, 720)
	
	--make all those pixels
	pixels = {}
	for i = 0, 720 do
		pixels[i] = {}
		for j = 0, 720 do
			pixels[i][j] = {
				r = math.floor(love.math.noise(i / denominator + seed * 0.1, j / denominator + seed) * 1.9) * 256,
				g = math.floor(love.math.noise(i / denominator + seed * 0.2, j / denominator + seed) * 1.6) * 256,
				b = math.floor(love.math.noise(i / denominator / 2 + seed * 0.3, j / denominator / 2 + seed) * 3) * 256,
				-- r = love.math.noise(i / denominator + seed * 0.1, j / denominator + seed) * 1 * 128,
				-- g = love.math.noise(i / denominator + seed * 0.2, j / denominator + seed) * 1 * 128,
				-- b = love.math.noise(i / denominator / 2 + seed * 0.3, j / denominator / 2 + seed) * 1 * 223,
			}
		end
	end
	
	--draw to the canvas
	love.graphics.setCanvas(canvas)

	for i = 0, 720 do
		for j = 0, 720 do
			local p = pixels[i][j]
			love.graphics.setColor(127 + p.r, 127 + p.g, 31 + p.b)
			love.graphics.rectangle("fill", i, j, 1, 1)
		end
	end
	
	--prepare for normal drawings
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255, 255)
end

function love.draw()
	love.graphics.draw(canvas)
	
	love.graphics.print("hello")
end

function love.update(dt)
	-- counter = counter + dt
	-- frameCounter = frameCounter + 1
	--
	-- if counter > 1 then
	-- 	print(frameCounter)
	-- 	frameCounter = 0
	-- end
	--
	-- counter = counter % 1
end