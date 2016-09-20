function love.load()
	love.window.setMode(720, 720)
	math.randomseed(os.time())
	-- print(love.math.getRandomSeed())--os.time()))
	seed = os.time() % 2 ^ 16
	denominator = 100
	counter = 0
	frameCounter = 0
	
	startTime = os.time()
	
	-- genPerlinTerrain()
	-- genVoronoiTerrain()
	genVoronoiTerrainWithOcean()
	-- genCombinedTerrain()
	
	print(os.time() - startTime, "seconds to generate")
	
	-- love.graphics.setBackgroundColor(0, 0, 0)
end

function distanceBetween(p1, p2)
	local xDiff = p1.x - p2.x
	local yDiff = p1.y - p2.y
	
	return (xDiff ^ 2 + yDiff ^ 2) ^ 0.5
end

function genCombinedTerrain()
	--make a canvas
	canvas = love.graphics.newCanvas(720, 720)
	local points = {}
	
	--random points
	for i = 1, 100 do
		points[i] = {
			x = math.random(720),
			y = math.random(720),
			c = {r = math.random(256), g = math.random(256), b = math.random(256)}
		}
	end
	
	--make all those pixels
	local pixels = {}
	for i = 0, 720 do
		pixels[i] = {}
		for j = 0, 720 do
			-- k = i * j % 240
			local min = 720
			local mindex = 0
			for k, p in pairs(points) do
				local d = distanceBetween(p, {x = i, y = j})
				if d == min then
					pixels[i][j] = {c = 255, 255, 255}
				elseif d < min then
					min = d
					mindex = k
				end
			end
			
			-- if points[mindex].c.r > noise or something then
			-- end
			--TODO this. other stuff first, though
			
			pixels[i][j] = {c = points[mindex].c}
			-- pixels[i][j].c[2] = 
		end
	end
	
	--draw to the canvas
	love.graphics.setCanvas(canvas)

	for i = 0, 720 do
		for j = 0, 720 do
			local p = pixels[i][j]
			-- love.graphics.setColor(127 + p.b, 127 + p.b, 127 + p.b)
			love.graphics.setColor(p.r, p.g, p.b)
			love.graphics.rectangle("fill", i, j, 1, 1)
		end
	end
	
	--prepare for normal drawings
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255, 255)
end

function smallerNumber(n, m)
	if n < m then
		return n
	else
		return m
	end
end

function genVoronoiTerrainWithOcean()
	local oceanWidth = 60
	
	--make a canvas
	canvas = love.graphics.newCanvas(720, 720)
	
	--random points
	local points = {}
	for i = 1, 100 do
		if i < 80 then
			points[i] = {
				x = math.random(720),
				y = math.random(720),
				elevation = 100
			}
		else
			points[i] = {
				x = math.random(720),
				y = math.random(720),
				elevation = 0
			}
		end
	end
	
	points[0] = {elevation = 0}
	
	--make all those pixels
	local pixels = {}
	for i = 0, 720 do
		pixels[i] = {}
		for j = 0, 720 do
			local min = 720
			local mindex = 0

			--close to an edge = ocean
			min = smallerNumber(min, i - oceanWidth)
			min = smallerNumber(min, j - oceanWidth)
			min = smallerNumber(min, 720 - i - oceanWidth)
			min = smallerNumber(min, 720 - j - oceanWidth)
			
			--for anything that's not ocean, use voronoi map
			for k = 1, #points do
				local p = points[k]
				local d = distanceBetween(p, {x = i, y = j})
				if d == min then
					pixels[i][j] = {elevation = 0}
				elseif d < min then
					min = d
					mindex = k
				end
			end
			
			pixels[i][j] = {elevation = points[mindex].elevation}
		end
	end
	
	--draw to the canvas
	love.graphics.setCanvas(canvas)

	for i = 0, 720 do
		for j = 0, 720 do
			local p = pixels[i][j]

			if p.elevation > 0 then
				love.graphics.setColor(63, 127, 31)
				love.graphics.rectangle("fill", i, j, 1, 1)
			elseif p.elevation == 0 then
				love.graphics.setColor(63, 63, 191)
				love.graphics.rectangle("fill", i, j, 1, 1)
			end
		end
	end
	
	--prepare for normal drawing again
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255, 255)
end

function genVoronoiTerrain()
	--make a canvas
	canvas = love.graphics.newCanvas(720, 720)
	local points = {}
	
	--random points
	for i = 1, 100 do
		points[i] = {
			x = math.random(720),
			y = math.random(720),
			c = {math.random(256), math.random(256), math.random(256)}
		}
	end
	
	--make all those pixels
	local pixels = {}
	for i = 0, 720 do
		pixels[i] = {}
		for j = 0, 720 do
			-- k = i * j % 240
			local min = 720
			local mindex = 0
			for k, p in pairs(points) do
				local d = distanceBetween(p, {x = i, y = j})
				if d == min then
					pixels[i][j] = {c = 255, 255, 255}
				elseif d < min then
					min = d
					mindex = k
				end
			end
			
			pixels[i][j] = {c = points[mindex].c}
		end
	end
	
	--draw to the canvas
	love.graphics.setCanvas(canvas)

	for i = 0, 720 do
		for j = 0, 720 do
			local p = pixels[i][j]
			-- love.graphics.setColor(127 + p.b, 127 + p.b, 127 + p.b)
			love.graphics.setColor(p.c)
			love.graphics.rectangle("fill", i, j, 1, 1)
		end
	end
	
	--prepare for normal drawings
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255, 255)
end

function genPerlinTerrain()
	--make a canvas
	canvas = love.graphics.newCanvas(720, 720)
	
	--make all those pixels
	pixels = {}
	for i = 0, 720 do
		pixels[i] = {}
		for j = 0, 720 do
			k = i * j % 240
			pixels[i][j] = {
				-- r = math.floor(love.math.noise(i / denominator + seed * 0.1, j / denominator + seed) * 1.9) * 256,
				-- g = math.floor(love.math.noise(i / denominator + seed * 0.2, j / denominator + seed) * 1.6) * 256,
				-- b = math.floor(love.math.noise(i / denominator / 2 + seed * 0.3, j / denominator / 2 + seed) * 3) * 256,
				-- r = love.math.noise(i / denominator + seed * 0.1, j / denominator + seed) * 1 * 128 % 364,
				-- g = love.math.noise(i / denominator + seed * 0.2, j / denominator + seed) * 1 * 128 % 364,
				-- b = love.math.noise(i / denominator / 2 + seed * 0.3, j / denominator / 2 + seed) * 1 * 223 % 64,
				--
				z = math.floor(1.5 *
				love.math.noise(k / denominator + seed, k / denominator + seed) * 256),-- - love.math.noise(i / denominator / 4 + seed, j / denominator / 4 + seed) * 128),

				y = math.floor((
				love.math.noise(i / denominator + seed, j / denominator + seed) * 256 -
				love.math.noise(i / denominator * 2 + seed, j / denominator * 2 + seed) * 128 -
				love.math.noise(i / denominator * 4 + seed, j / denominator * 4 + seed) * 64
				) * 2),	
				
				x = math.floor((
				-- love.math.noise(i / denominator + seed, j / denominator + seed) - 
				love.math.noise(i / denominator * 2 + seed, j / denominator * 2 + seed) / 2 -
				love.math.noise(i / denominator * 3 + seed, j / denominator * 3 + seed) / 3 
				-- love.math.noise(i / denominator * 4 + seed, j / denominator * 4 + seed) / 4
				) * 4) * 256,
				
				w = math.floor((
				-- love.math.noise(i / denominator + seed, j / denominator + seed) -
				-- love.math.noise(i / denominator * 2 + seed, j / denominator * 2 + seed) / 2 -
				love.math.noise(i / denominator * 3 + seed, j / denominator * 3 + seed) / 3 -
				love.math.noise(i / denominator * 4 + seed, j / denominator * 4 + seed) / 4
				) * 4) * 256,
				
				v = math.floor((
				-- love.math.noise(i / denominator + seed, j / denominator + seed) - 
				love.math.noise(i / denominator * 2 + seed, j / denominator * 2 + seed) / 2 -
				-- love.math.noise(i / denominator * 3 + seed, j / denominator * 3 + seed) / 3 - 
				love.math.noise(i / denominator * 4 + seed, j / denominator * 4 + seed) / 4
				) * 4) * 256,
				
				u = math.floor((
				-- love.math.noise(i / denominator + seed, j / denominator + seed) - 
				love.math.noise(i / denominator * 2 + seed, j / denominator * 2 + seed) / 2 -
				-- love.math.noise(i / denominator * 3 + seed, j / denominator * 3 + seed) / 3 - 
				love.math.noise(i / denominator * 4 + seed, j / denominator * 4 + seed) / 4
				) * 4) * 256 - math.abs(i / 2 - 180) - math.abs(j / 2 - 180),
			}
		end
	end
	
	--draw to the canvas
	love.graphics.setCanvas(canvas)

	for i = 0, 720 do
		for j = 0, 720 do
			local p = pixels[i][j]
			-- love.graphics.setColor(127 + p.b, 127 + p.b, 127 + p.b)
			love.graphics.setColor(p.u, p.x, p.u)
			love.graphics.rectangle("fill", i, j, 1, 1)
		end
	end
	
	--prepare for normal drawings
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255, 255)
end

function love.draw()
	love.graphics.draw(canvas)
	
	-- love.graphics.print("hello")
end

function love.update(dt)
	counter = counter + dt
	frameCounter = frameCounter + 1

	if counter > 1 then
		print(frameCounter)
		frameCounter = 0
	end

	counter = counter % 1
end