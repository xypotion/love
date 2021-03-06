require 'modules/particleTEST'
require 'modules/homebrewParticles'

require 'scripts/spellAnimations'
require 'scripts/metaParticles'

function love.load()
	--math always comes first
	ONE_THIRD = 1/3
	TWO_THIRDS = ONE_THIRD * 2

	math.randomseed(os.time())
	-- math.randomseed(205) --good stuff on T
	-- math.randomseed(986) --dustin's choice
	
	--basics
	screenWidth = 800
	screenHeight = 600
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor(31,63,31)
	love.graphics.setNewFont(20)
	
	paused = false
	
	initParticleTEST()
	
	initParticleSystem()
end

function love.update(dt)
	if paused then
		return
	else
	
		updateParticleTEST(dt)
	
		--update & remove dead particles
		updateParticles(dt)
	end
end

function love.draw()
	--TEST's wizard, enemy, emitters, and puffers (and all shadows) go on the bottom
	drawParticleTEST()
	
	--particles go on top of basically everything else
	drawParticles()
	
	--draw pause overlay
	if paused then
		love.graphics.setColor(0, 0, 0, 127)
		love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf("Particles: "..#particles, 0, screenHeight * ONE_THIRD, screenWidth, "center")
		love.graphics.printf("Press keyboard keys for different effects!", 0, screenHeight * TWO_THIRDS, screenWidth, "center")
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		paused = not paused
	else
		makeParticleTESTObject(key)
	end
end