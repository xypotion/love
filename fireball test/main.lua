function love.load()
	math.randomseed(os.time())
	
	--basics
	screenWidth = 800
	screenHeight = 600
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor(31,63,31)
	
	paused = false
	
	--some object properties
	hoverHeight = 20
	
	wizardSize = 20
	wizardSpeed = 200
	
	enemySize = 10
	
	fireballSize = 7.5
	
	--actual objects
	wizard = {x=screenWidth/2, y=screenHeight/2}
	
	makeEnemy()
	
	fireball = nil
	
	particles = {}
end

function love.update(dt)
	if paused then return end

	--moving the wizard?
	if love.keyboard.isDown("left", "right", "up", "down") then
		moveWizard(dt)
	end
	
	--update fireball if there is one
	if fireball then
		moveFireball(dt)
		
		--maybe add a particle
		if math.random() < fireball.particleRate then
			addParticle(fireball.x, fireball.y, fireball.metaParticle)
		end
		
		--remove fireball if it hit the enemy
		if math.abs(fireball.distanceTraveled) >= math.abs(fireball.xDist) then
			explosionAt(fireball.x, fireball.y, fireball.particleRate)
			
			fireball = nil
			
			makeEnemy()
		end
	end
	
	--update & remove dead particles
	updateParticles(dt)
end

function love.draw()
	--draw wizard shadow & wizard
	love.graphics.setColor(31, 31, 31, 127)
	love.graphics.ellipse("fill", wizard.x, wizard.y + hoverHeight, wizardSize/1.5, wizardSize/3)
		
	love.graphics.setColor(127, 127, 255)
	love.graphics.circle("fill", wizard.x, wizard.y, wizardSize)
	
	--draw enemy shadow & enemy
	if enemy then
		love.graphics.setColor(31, 31, 31, 127)
		love.graphics.ellipse("fill", enemy.x, enemy.y + hoverHeight, enemySize/1.5, enemySize/3)

		love.graphics.setColor(127, 255, 127)
		love.graphics.circle("fill", enemy.x, enemy.y, enemySize)
	end
	
	--draw fireball shadow and fireball
	if fireball then
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
		love.graphics.setColor(p.r, p.g, p.b, p.a)
		love.graphics.circle("fill", p.x, p.y, p.size, p.segments)
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
		elseif key == "i" then
			print("arcing ice ball")
			startFireball({speed=1, arc=10, shadow=true, metaParticle = "ice ball"})
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
		elseif key == "t" then
			print("random-element ball")
			
			local params = {
				speed = math.random() + 0.5, 
				arc = math.sqrt(math.random(100)), 
				shadow = true,
				particleRate = math.random(), 
				metaParticle = "random tame"
			}
			
			startFireball(params)

			for k,v in pairs(fireball.metaParticle.variable) do
				print(v.min, v.var, k)
			end
		elseif key == "r" then	
			print("random confetti ball!!")
			
			local params = {
				speed = math.random() + 0.5, 
				arc = math.sqrt(math.random(100)), 
				shadow = true,
				particleRate = math.random(),
				metaParticle = "random wild"
			}
			
			startFireball(params)
		else
			print("\nkey not recognized...")
			love.keypressed("r")
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

--update particles' ages, colors, locations, sizes, velocities, and acceleration, THEN kill if they're too old
function updateParticles(dt)
	for k,p in pairs(particles) do
		p.age = p.age + dt
		
		--move particle
		p.x = p.x + p.xVelocity * dt
		p.y = p.y + p.yVelocity * dt

		--change color (linear)
		p.r = p.r + p.deltaR * dt
		p.g = p.g + p.deltaG * dt
		p.b = p.b + p.deltaB * dt
		p.a = p.a + p.deltaA * dt
		
		--change size
		p.size = p.size + p.deltaSize * dt
		if p.size < 0 then 
			p.size = 0
			--TODO or maybe just kill the particle at this point
		end
		
		--change velocities
		p.xVelocity = p.xVelocity + p.xAcceleration * dt
		p.yVelocity = p.yVelocity + p.yAcceleration * dt
		
		--change acceleration
		p.xAcceleration = p.xAcceleration + p.xJerk * dt
		p.yAcceleration = p.yAcceleration + p.yJerk * dt
		
		--release
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
	--default fireball stuff
	fireball = {
		start = wizard, dest = enemy, 
		x = wizard.x, y = wizard.y,
		sx = wizard.x, sy = wizard.y,
		distanceTraveled = 0,
		xDist = enemy.x - wizard.x,
		yDist = enemy.y - wizard.y,
		particleRate = 0.5,
	}
	
	--replace attributes as necessary
	for k,v in pairs(params) do
		fireball[k] = v
	end
	
	-- print(fireball.metaParticle)
	-- print("generating mp")
	fireball.metaParticle = metaParticle(fireball.metaParticle)
	-- for k,v in pairs(fireball.metaParticle) do
	-- 	print(k, v)
	-- end
	
	--TODO simplify?
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
end

function addParticle(x, y, meta, extraParams)
	--location + default particle init (just age = 0 for now)
	local p = {
		x = x,
		y = y,
		age = 0
	}
	
	--adopt all of metaparticle's static attributes
	for attribute, value in pairs(meta.static) do --what if this is nil? TODO
		p[attribute] = value
	end

	--adopt all of metaparticle's variable attributes with variance applied
	for attribute, range in pairs(meta.variable) do
		p[attribute] = vary(range)
	end
	
	--replace anything specified
	if extraParams then 
		for k,v in pairs(extraParams) do
			p[k] = v
		end
	end
	
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
			static = {
				segments = 4,
			},
			variable = {
				maxAge = {min = 1, var = 1},
			
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
				xJerk = {min = 0, var = 0},
				yJerk = {min = 0, var = 0},
			}
		}
	-- elseif type == "fire explosion" then
		--...
	elseif type == "ice ball" then
		attributes = {
			static = {
				maxAge = 3,

				r = 191,
				g = 191,
				b = 255,
				a = 191,
				
				segments = 6,
			},
			variable = {
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
				xJerk = {min = 0, var = 0},
				yJerk = {min = 0, var = 0},
			}
		}	
	elseif type == "random wild" then
		attributes = {
			static = {
			},
			variable = {
				maxAge = {min = 1, var = 10},
				
				segments = {min = 3, var = 5, mode = "integer"},
			
				r = {min = 0, var = 256},
				g = {min = 0, var = 256},
				b = {min = 0, var = 256},
				a = {min = 0, var = 256},
			
				deltaR = {min = -256, var = 512},
				deltaG = {min = -256, var = 512},
				deltaB = {min = -256, var = 512},
				deltaA = {min = -256, var = 512},
			
				size = {min = 1, var = 10},
				deltaSize = {min = -10, var = 20},
			
				xVelocity = {min = -500, var = 1000},
				yVelocity = {min = -500, var = 1000},
				xAcceleration = {min = -500, var = 1000},
				yAcceleration = {min = -500, var = 1000},
				xJerk = {min = -500, var = 1000},
				yJerk = {min = -500, var = 1000},
			}
		}
	elseif type == "random tame" then
		attributes = {
			static = {
			},
			variable = {
				maxAge = {min = math.random(5), var = math.random(5)},

				segments = {min = math.random(3) + 2, var = math.random(3), mode = "integer"},
			
				r = {min = math.random(256), var = math.random(256)},
				g = {min = math.random(256), var = math.random(256)},
				b = {min = math.random(256), var = math.random(256)},
				a = {min = math.random(256), var = math.random(256)},
			
				deltaR = {min = 0 - math.random(256), var = math.random(512)},
				deltaG = {min = 0 - math.random(256), var = math.random(512)},
				deltaB = {min = 0 - math.random(256), var = math.random(512)},
				deltaA = {min = 0 - math.random(256), var = math.random(512)},
			
				size = {min = math.random(10), var = math.random(10)},
				deltaSize = {min = 0 - math.random(10), var = math.random(10)},
			
				xVelocity = {min = 0 - math.random(256), var = math.random(512)},
				yVelocity = {min = 0 - math.random(256), var = math.random(512)},
				xAcceleration = {min = 0 - math.random(256), var = math.random(512)},
				yAcceleration = {min = 0 - math.random(256), var = math.random(512)},
				xJerk = {min = 0 - math.random(256), var = math.random(512)},
				yJerk = {min = 0 - math.random(256), var = math.random(512)},
			}
		}
	else
		attributes = metaParticle("fire trail")
	end
	
	return attributes
end

--range must be a table containing two numbers, "min" and "var"
--if range also contains the "mode" attribute, complex functions of variance may be used, like "bell curve" or "integer" (TODO)
--if range does not contain "mode", the default variance algorithm, "linear", is used. this will generate a rational number between [range.min] and [range.min + range.var]
function vary(range)
	local value = 0
	local mode = range.mode or "linear" 
	
	if mode == "linear" then
		value = math.random() * range.var + range.min
	-- elseif mode == "bell curve" then
	-- elseif mode == "inverse bell curve" then
	elseif mode == "integer" then
		value = math.random() * range.var + range.min
		if value - 0.5 < math.floor(value) then
			value = math.floor(value)
		else
			value = math.ceil(value)
		end
	-- elseif mode == "absolute value" then
	end
	
	return value
end

--TODO pixellize locations. #analretentive
--TODO z-ordering? draw in correct order?
--TODO clean up a little. code seems messy
--TODO more robust particle attributes + testing. different colors, gravities, etc
--TODO other particle attribute ideas... blink/oscillation, shape (circle() with varying segments), image?, wind?