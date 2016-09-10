ParticleTEST = {}

function initParticleTEST()
	table.insert(focusStack, {
		type = "ParticleTEST",
		-- draw = function() love.graphics.print("HELLOOOO") end
	})
	
	--some object properties
	hoverHeight = 10
	
	wizardSize = 10
	wizardSpeed = 100
	
	enemySize = 5
		
	--actual objects
	wizard = {x=canvasWidth/2, y = canvasHeight - wizardSize * 2}
	
	makeEnemy()
	
	fireball = nil
	
	emitters = {}
end

function ParticleTEST.update(pT, dt)
	--moving the wizard?
	if love.keyboard.isDown("left", "right", "up", "down") then
		moveWizard(dt)
	end
	
	-- print("update")
	
	--update fireball if there is one
	if fireball then
		moveFireball(dt)
		
		--maybe add a particle
		if math.random() < fireball.particleRate then
			addParticle(fireball.x, fireball.y + fireball.elevation, fireball.metaParticle)
		end
		
		--remove fireball if it hit the enemy
		if math.abs(fireball.distanceTraveled) >= math.abs(fireball.xDist) then
			explode(fireball)
			
			fireball = nil
			
			makeEnemy()
		end
	end
	
	--emitters: emit
	updateEmitters(dt)
end

function updateEmitters(dt)
	for i,e in pairs(emitters) do		
		if e.interval and e.interval > 0 then
			--it's a puffer. increment counter; burst and reset if interval surpassed
			e.counter = e.counter + dt
			
			if e.counter >= e.interval then
				for i = 1, e.burstSize do
					addParticle(e.x, e.y, e.metaParticle)
				end
				
				e.counter = e.counter % e.interval
			end
		else
			--it's a regular, constant emitter
			if math.random() < e.frequency then
				addParticle(e.x, e.y, e.metaParticle)
			end
		end
	end
end

function ParticleTEST.draw()
	--draw emitter shadows & emitters/puffers
	for i,e in pairs(emitters) do
		love.graphics.setColor(31, 31, 31, 127)
		love.graphics.ellipse("fill", e.x, e.y + hoverHeight, e.size * TWO_THIRDS, e.size * ONE_THIRD)
	
		love.graphics.setColor(e.color.r, e.color.g, e.color.b, e.color.a)
		love.graphics.circle("line", e.x, e.y, e.size, e.segments)
		if e.interval then 
			love.graphics.circle("line", e.x, e.y, e.size * 0.5, e.segments) 
		end
	end
	
	--draw wizard shadow & wizard
	love.graphics.setColor(31, 31, 31, 127)
	love.graphics.ellipse("fill", wizard.x, wizard.y + hoverHeight, wizardSize * TWO_THIRDS, wizardSize * ONE_THIRD)
		
	love.graphics.setColor(127, 127, 255)
	love.graphics.circle("fill", wizard.x, wizard.y, wizardSize)
	
	--draw enemy shadow & enemy
	if enemy then
		love.graphics.setColor(31, 31, 31, 127)
		love.graphics.ellipse("fill", enemy.x, enemy.y + hoverHeight, enemySize * TWO_THIRDS, enemySize * ONE_THIRD)

		love.graphics.setColor(127, 255, 127)
		love.graphics.circle("fill", enemy.x, enemy.y, enemySize)
	end
	
	--draw fireball shadow and fireball
	if fireball then
		if fireball.shadow then
			love.graphics.setColor(31, 31, 31, 127)
			love.graphics.ellipse("fill", fireball.x, fireball.y + hoverHeight, fireball.size * TWO_THIRDS, fireball.size * ONE_THIRD)
		end
	
		love.graphics.setColor(fireball.color.r, fireball.color.g, fireball.color.b, fireball.color.a)
		love.graphics.circle("fill", fireball.x, fireball.y + fireball.elevation, fireball.size, fireball.segments)
	end
	
	--draw particles!
	drawParticles()
end

------------------------------------------------------------------------------------------------------------------------------------

--NOT moving the wizard.
function moveWizard(dt)
	-- if love.keyboard.isDown("left") then
	-- 	wizard.x = wizard.x - dt * wizardSpeed
	-- end
	--
	-- if love.keyboard.isDown("right") then
	-- 	wizard.x = wizard.x + dt * wizardSpeed
	-- end
	--
	-- if love.keyboard.isDown("up") then
	-- 	wizard.y = wizard.y - dt * wizardSpeed
	-- end
	--
	-- if love.keyboard.isDown("down") then
	-- 	wizard.y = wizard.y + dt * wizardSpeed
	-- end
end

function makeEnemy()
	enemy = {
		x = math.random(canvasWidth), 
		y = math.random(canvasHeight)
	}
end

function makeEmitter(mpType, freq, other)
	local e = {
		x = math.random(canvasWidth), 
		y = math.random(canvasHeight),
		frequency = freq,
		metaParticle = makeMetaParticle(mpType),
		color = {
			r = 127 + math.random(128),
			g = 127 + math.random(128),
			b = 127 + math.random(128),
			a = 255
		},
		segments = 2 + math.random(3) * 2,
		size = wizardSize * 3 / 4,
		
		counter = 0,
		-- interval = 0,
		-- burstSize = 1
	}
	
	--add in special stuff. should just be for puffers (for now)
	if other then
		for k,v in pairs(other) do
			e[k] = v
		end
	end
	
	-- print(e.metaParticle)
	
	table.insert(emitters, e)
end

function startFireball(params)
	--i realize how gross this is to have near-duplicate functions, but it's transitional! startFireball() was experimental, but prefabProjectile() was the goal. TODO: consolidate
	if type(params) == "string" then
		fireball = prefabProjectile(params)
		return
	end
	
	--default fireball stuff
	fireball = {
		start = wizard, dest = enemy, 
		x = wizard.x, y = wizard.y,
		elevation = 0,
		distanceTraveled = 0,
		xDist = enemy.x - wizard.x,
		yDist = enemy.y - wizard.y,
		particleRate = 0.5,
		segments = 4,
		color = {r = 255, g = 255, b = 255, a = 255},
		arc = 10,
		speed = 1,
		particleRate = 0.5,
		shadow = true,
		size = 8,
	}
	
	--replace attributes as necessary
	for k,v in pairs(params) do
		fireball[k] = v
	end
	
	--make metaparticle
	fireball.metaParticle = makeMetaParticle(fireball.metaParticle)
	
	--should be simplified alongside the "elevation" refactor
	fireball.vector = {x = fireball.xDist, y = fireball.yDist}
	fireball.ascentSpeed = fireball.arc
	fireball.descentSpeed = fireball.ascentSpeed * 2
end

function moveFireball(dt)
	--move fireball closer to enemy, arcing
	fireball.x = fireball.x + fireball.vector.x * fireball.speed * dt
	fireball.y = fireball.y + fireball.vector.y * fireball.speed * dt
	
	--adjust elevation & arc angle
	fireball.elevation = fireball.elevation - fireball.ascentSpeed
	fireball.ascentSpeed = fireball.ascentSpeed - fireball.descentSpeed * dt * fireball.speed
	
	--count down distance
	fireball.distanceTraveled = fireball.distanceTraveled + fireball.speed * fireball.vector.x * dt
end

--unused letters: ydm
function makeParticleTESTObject(key)
	print()
	if key == "backspace" then
		-- table.remove(emitters)
		removeLastEmitter()
	elseif key == "a" then
		print("TEST ALL")
		startFireball("ice")
		makeEmitter("random tame", 1)
		makeEmitter("random tame", 1, {interval = 1, burstSize = 20})
	elseif key == "f" then
		print("arcing fireball")
		startFireball("fire")
	elseif key == "i" then
		print("arcing ice ball")
		startFireball("ice")
	elseif key == "g" then
		print("go go go")
		startFireball("go")
	elseif key == "x" then
		print("x-beam")
		startFireball("x-beam")
	elseif key == "e" then
		print("summon constant emitter")
		makeEmitter("random tame", 1)
	elseif key == "k" then
		print("summon confetti emitter")
		makeEmitter("random wild", 1)
	elseif key == "p" then
		print("summon puffer")
		makeEmitter("random tame", 1, {interval = 1, burstSize = 20})
	elseif key == "b" then
		print("summon beamer")
		makeEmitter("x-beam spark", 1, {interval = 0.5, burstSize = 10})
	else
		--more experimental stuff
		if key == "n" then
			print("linear fireball, no shadow")
			startFireball({speed=1, arc=0, shadow=false})
		elseif key == "l" then
			print("linear fireball")
			startFireball({speed=1, arc=0,})
		elseif key == "j" then
			print("jumping elements")
			addParticle(wizard.x, wizard.y, makeMetaParticle("fire trail"), {yVelocity = -200, yAcceleration = 400})
			addParticle(wizard.x, wizard.y, makeMetaParticle("ice ball"), {yVelocity = -200, yAcceleration = 400})
			addParticle(wizard.x, wizard.y, makeMetaParticle("x-beam spark"), {yVelocity = -200, xVelocity = 200, yAcceleration = 400})
			addParticle(wizard.x, wizard.y, makeMetaParticle("go arrow"), {yVelocity = -200, yAcceleration = 400})
		elseif key == "h" then
			print("high-arcing fireball")
			startFireball({speed=1, arc=20,})
		elseif key == "s" then
			print("shallow-arcing fireball")
			startFireball({speed=1, arc=3,})
		elseif key == "z" then
			print("arcing fireball, no shadow")
			startFireball({speed=1, arc=10, shadow=false})
		elseif key == "q" then
			print("quick linear fireball")
			startFireball({speed=2, arc=0,})
		elseif key == "w" then
			print("slow linear fireball")
			startFireball({speed=.5, arc=0,})
		elseif key == "u" then
			print("quick arcing fireball")
			startFireball({speed=2, arc=10,})
		elseif key == "o" then
			print("slow arcing fireball")
			startFireball({speed=0.5, arc=10,})
		elseif key == "v" then
			print("very hot arcing fireball")
			startFireball({speed=1, arc=5, particleRate=0.9, color = {r = 255, g = 255, b = 255, a = 255}})
		elseif key == "c" then
			print("very cold arcing fireball")
			startFireball({speed=1, arc=5, particleRate=0.1, color = {r = 15, g = 15, b = 15, a = 255}})
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
			print("\n'"..key.."' key not recognized...")
			makeParticleTESTObject("r")
		end
	end
end

function removeLastEmitter()
	table.remove(emitters)
end