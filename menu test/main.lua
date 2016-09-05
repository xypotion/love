require "globalFunctions" --could still go in a folder
require "menuDEBUG"

require "MISC/helpers"
require "MENU/listMenu"

--"homebrew particle engine"
require 'HPE/modules/particleTEST'
require 'HPE/modules/homebrewParticles'
require 'HPE/scripts/spellAnimations'
require 'HPE/scripts/metaParticles'

function love.load()
	--math always comes first
	ONE_THIRD = 1/3
	TWO_THIRDS = ONE_THIRD * 2

	math.randomseed(os.time())
	
	--basics
	screenWidth = 800
	screenHeight = 600
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor(31,63,31)
	love.graphics.setNewFont(20)
	
	paused = false
	
	initParticleTEST()
	
	initParticleSystem()
	
	--menu stuff!?
	focusStack = {}
	
	makeDebugMenu()
	
	-- print(pcall(love.draw))
	-- print(pcall("love.draw"))
	-- print(pcall(lobeliaaa))
	-- _G["love"]["update"](1)
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
	
	--...actually menu stuff goes on top of everything else!
	local dim = false
	for key, element in ipairs(focusStack) do
		element:draw(dim)
		dim = true
	end
	
	--pause overlay
	if paused then
		love.graphics.setColor(0,0,0,127)
		love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
	end
end

------------------------------------------------------------------------------------------------------------------------------------

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		paused = not paused
	elseif not paused then
		if #focusStack > 0 then
			focusStack[#focusStack]:keypressed(key)
		else
			--should never happen...
			print("no focused element to interact with")
		end
	end
end