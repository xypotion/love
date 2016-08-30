function love.load()
	math.randomseed(os.time())
	
	screenWidth = 800
	screenHeight = 600
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor(31,63,31)
	
	hoverHeight = 20
	
	wizardSize = 20
	wizardSpeed = 200
	
	enemySize = 10
	
	fireballSize = 7.5
	
	particleSize = 3
	particleCoolingMin = 4
	particleCoolingVariance = 4
	
	wizard = {x=screenWidth/2, y=screenHeight/2}
	makeEnemy(100)
	
	--animation-related 
	fireball = nil
	
	particles = {}
	
	paused = false
end

function love.update(dt)
	if paused then return end

	if love.keyboard.isDown("left", "right", "up", "down") then
		moveWizard(dt)
	end
	
	if fireball then
		moveFireball(dt)
		
		--add particle
		if math.random() < fireball.particleRate then
			addParticle(fireball.x, fireball.y, fireball.metaParticle)
		end
		
		--remove fireball if it hit
		if math.abs(fireball.distanceTraveled) >= math.abs(fireball.xDist) then
			print("hit!")
			explosionAt(fireball.x, fireball.y, fireball.particleRate)
			fireball = nil
			makeEnemy()
		end
	end
	
	--age, fade, jitter, remove dead particles
	updateParticles(dt)
end

function love.draw()
	--draw wizard shadow
	love.graphics.setColor(31, 31, 31, 127)
	love.graphics.ellipse("fill", wizard.x, wizard.y + hoverHeight, wizardSize/1.5, wizardSize/3)
		
	--draw wizard
	love.graphics.setColor(127, 127, 255)
	love.graphics.circle("fill", wizard.x, wizard.y, wizardSize)
	
	--draw enemy
	if enemy then
		--draw shadow first
		love.graphics.setColor(31, 31, 31, 127)
		love.graphics.ellipse("fill", enemy.x, enemy.y + hoverHeight, enemySize/1.5, enemySize/3)

		love.graphics.setColor(127, 255, 127)
		love.graphics.circle("fill", enemy.x, enemy.y, enemySize)
	end
	
	--draw fireball
	if fireball then
		--draw shadow first
		if fireball.shadow then
			love.graphics.setColor(31, 31, 31, 127)
			love.graphics.ellipse("fill", fireball.sx, fireball.sy + hoverHeight, fireballSize/1.5, fireballSize/3)
		end
	
		love.graphics.setColor(255, 127, 127)
		love.graphics.circle("fill", fireball.x, fireball.y, fireballSize, 4)
	end
	
	--draw particles
	for i = 1, #particles do
		local p = particles[i]
		love.graphics.setColor(p.r, p.g, p.b, p.a)--particles[i].luminosity)
		love.graphics.circle("fill", particles[i].x, particles[i].y, p.size, 4)
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		paused = not paused
	else
		print()
		if key == "n" then
			print("linear fireball, no shadow")
			startFireball({speed=1, arc=0, shadow=false})
		elseif key == "l" then
			print("linear fireball")
			startFireball({speed=1, arc=0, shadow=true})
		elseif key == "a" then
			print("arcing fireball")
			startFireball({speed=1, arc=10, shadow=true})
		elseif key == "h" then
			print("high-arcing fireball")
			startFireball({speed=1, arc=20, shadow=true})
		elseif key == "s" then
			print("shallow-arcing fireball")
			startFireball({speed=1, arc=3, shadow=true})
		elseif key == "z" then
			print("arcing fireball, no shadow")
			startFireball({speed=1, arc=10, shadow=false})
		elseif key == "q" then
			print("quick linear fireball")
			startFireball({speed=2, arc=0, shadow=true})
		elseif key == "w" then
			print("slow linear fireball")
			startFireball({speed=.5, arc=0, shadow=true})
		elseif key == "u" then
			print("quick arcing fireball")
			startFireball({speed=2, arc=10, shadow=true})
		elseif key == "o" then
			print("slow arcing fireball")
			startFireball({speed=0.5, arc=10, shadow=true})
		elseif key == "v" then
			print("very hot arcing fireball")
			startFireball({speed=1, arc=5, shadow=true, particleRate=0.9})
		elseif key == "c" then
			print("very cold arcing fireball")
			startFireball({speed=1, arc=5, shadow=true, particleRate=0.1})
		elseif key == "r" then
			print("random fireball!")
			local f = {
				speed = math.random() + 0.5, 
				arc = math.sqrt(math.random(100)), 
				shadow = true,
				particleRate = math.random()
			}
			for k,v in pairs(f) do
				print(k,v)
			end
			startFireball(f)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------

function moveWizard(dt)
	if love.keyboard.isDown("left") then
		wizard.x = wizard.x - dt * wizardSpeed
	end
	
	if love.keyboard.isDown("right") then
		wizard.x = wizard.x + dt * wizardSpeed
	end
	
	if love.keyboard.isDown("up") then
		wizard.y = wizard.y - dt * wizardSpeed
	end
	
	if love.keyboard.isDown("down") then
		wizard.y = wizard.y + dt * wizardSpeed
	end
end

function updateParticles(dt)
	numParticles = #particles
	
	--age, fade, jitter particles
	for k,p in pairs(particles) do
		p.age = p.age + dt

		p.r = p.r + p.deltaR * dt
		p.g = p.g + p.deltaG * dt
		p.b = p.b + p.deltaB * dt
		p.a = p.a + p.deltaA * dt
		
		p.x = p.x + p.xVelocity * dt
		p.y = p.y + p.yVelocity * dt
		
		p.size = p.size + p.deltaSize * dt
		if p.size < 0 then 
			p.size = 0
			--TODO or maybe just kill the particle
		end
		
		--change velocities
		p.xVelocity = p.xVelocity + p.xAcceleration * dt
		p.yVelocity = p.yVelocity + p.yAcceleration * dt
		
		--change acceleration
		p.xAcceleration = p.xAcceleration + p.xJerk * dt
		p.yAcceleration = p.yAcceleration + p.yJerk * dt
		
		if p.age > p.maxAge then
			table.remove(particles, k)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------

function makeEnemy()
	enemy = {
		x = math.random(screenWidth), 
		y = math.random(screenHeight)
	}
end

function startFireball(params)
	--all just initialization of the fireball!
	fireball = {
		start = wizard, dest = enemy, 
		x = wizard.x, y = wizard.y,
		sx = wizard.x, sy = wizard.y,
		distanceTraveled = 0,
		xDist = enemy.x - wizard.x,
		yDist = enemy.y - wizard.y,
		-- heat = 0.5,
		particleRate = 0.5,
		
		metaParticle = metaParticle("fire trail")
	}
	
	for k,v in pairs(params) do
		-- print(k,v)
		fireball[k] = v
	end
	
	fireball.vector = {x = fireball.xDist, y = fireball.yDist}
	
	fireball.ascentSpeed = fireball.arc
	fireball.descentSpeed = fireball.ascentSpeed * 2
end

function moveFireball(dt)
	--move fireball closer to enemy
	fireball.x = fireball.x + fireball.vector.x * fireball.speed * dt
	fireball.y = fireball.y + (fireball.vector.y) * fireball.speed * dt - fireball.ascentSpeed
	
	--move shadow closer to enemy
	fireball.sx = fireball.sx + fireball.vector.x * fireball.speed * dt
	fireball.sy = fireball.sy + fireball.vector.y * fireball.speed * dt	
	
	--adjust arc
	fireball.ascentSpeed = fireball.ascentSpeed - fireball.descentSpeed * dt * fireball.speed
	
	--count down distance
	fireball.distanceTraveled = fireball.distanceTraveled + fireball.speed * fireball.vector.x * dt
	-- print(fireball.distanceTraveled)
end

function addParticle(x, y, meta, extraParams)
	--location + default particle init
	local mp = meta or metaParticle("fire trail")
	local p = {
		x = x,
		y = y,
		age = 0
	}
	
	-- print()
	for attribute, range in pairs(meta) do
		p[attribute] = vary(range)
		-- print(attribute, p[attribute])
	end
	-- local p = {
	-- 	x = x,
	-- 	y = y,
	-- 	age = 0,
	-- 	luminosity = 255,
	-- 	cooling = math.random() * particleCoolingVariance + particleCoolingMin,
	-- 	vx = math.random() - 0.5,
	-- 	vy = math.random() - 0.5,
	-- 	volatility = 0.5,
	-- 	heat = 0.5,
	-- 	size = 3
	-- }
	
	--replace anything specified
	if extraParams then 
		for k,v in pairs(extraParams) do
			-- print(k,v)
			p[k] = v
		end
	end
	
	--other params... density, fadespeed, blink/oscillation, startingLuminosity, color (duh), 
	--	size, shape (try circle() with varying segments!)? image?, sizeChange, sizeMin/Variance, wind?
	
	table.insert(particles, p)
end

function explosionAt(x, y, particleRate)
	explosionMeta = metaParticle("explosion fire")
	
	for i = 1, 10 + particleRate * 10 do
		addParticle(x, y, explosionMeta)
		-- {
		-- 	volitilty = 0.9,
		-- 	vx = (math.random() - 0.5) * 5,
		-- 	vy = (math.random() - 0.5) * 5,
		-- })
	end
end

function metaParticle(type)
	attributes = {}
	
	--all deltas are applied per second. how much is a given attribute allowed to change after 1s?
	if type == "fire trail" then
		attributes = {
			maxAge = {min = 1, var = 1},
			
			-- r = {min = 0, var = 256},
			-- g = {min = 0, var = 256},
			-- b = {min = 0, var = 256},
			r = {min = 247, var = 8},
			g = {min = 191, var = 64},
			b = {min = 127, var = 32},
			a = {min = 191, var = 0},
			
			deltaR = {min = -0, var = 0},
			deltaG = {min = -191, var = 100},
			deltaB = {min = -191, var = 25},
			deltaA = {min = -191, var = 25},
			
			size = {min = 4, var = 1},
			deltaSize = {min = -4, var = 2},
			
			xVelocity = {min = -50, var = 100},
			yVelocity = {min = -50, var = 100},
			xAcceleration = {min = -50, var = 100},
			yAcceleration = {min = 100, var = 0},
			-- xAcceleration = {min = 0, var = 0},
			-- yAcceleration = {min = 0, var = 0},
			xJerk = {min = 0, var = 0},
			yJerk = {min = 0, var = 0},
		}
	-- elseif type == "fire explosion" then
		--...
	else
		attributes = metaParticle("fire trail")
	end
	
	return attributes
end

--range must be a table containing two numbers, min and var
--mode should only be "linear", "bell curve" (TODO), or other complex styles of variance
function vary(range, mode)
	local value = 0
	local mode = mode or "linear"
	
	if mode == "linear" then
		value = math.random() * range.var + range.min
	-- elseif mode == "integer" then
		-- value = math.random() * range.vary + range.min
	end
	
	return value
end

--TODO pixellize locations. #analretentive
--TODO z-ordering? draw in correct order?
--TODO clean up a little. code seems messy
--TODO more robust particle attributes + testing. different colors, gravities, etc