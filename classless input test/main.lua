--TODO problems:
--love.keypressed() and love.keyboard.isDown() both need to be controlled via focus stack
--that ^ plus controller input. this is going to turn into an "input test", i can just tell :)
--classes! do we use them everywhere or nowhere? a mix of both isn't gonna fly. 
--  if using everywhere, ALL of the particle stuff has to be reworked. classes are a little annoying, though. periods and colons are confusing
--  if using nowhere... i'm not sure. will i regret it? will it be harder? would need a lot of type="foo"s and elseiffy checking, but maybe that's smoother?
--  leaning towards not using classes! :) will be an interesting exercise, at least

--dual input model:
--keys = {}; keys.CONFIRM = "enter"; keys.CANCEL = "rshift", etc 
--buttons = {}; buttons.CONFIRM = "1"; buttons.CANCEL = "2", etc
--function love.keypressed(key) / if key == keys.CONFIRM then menuConfirm()
--function love.controllerpressed(button) / if button == buttons.CONFIRM then menuConfirm()
	
--probably need a initGraphics.load or something, to initialize all the graphical stuff. will be where zoom level matters. sigh.

--weird tricks i'm learning:
--  foo = require "bar"
--  local functions inside functions. i guess so you can make some variables more dynamic?
--  ;foo(), like in debug quest/libs/state.lua, line 43. why do this??
	--    ;(initialized_states[to] or to.init or __NULL__)(to) --calling one of a set of functions!! :O
--  function __NULL_() end - for a no-op. maybe i should make one of these

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
	
	thing = 99
	print(nil)
	print(thing)
	-- print(thing.x)
	
	--basics
	screenWidth = 800
	screenHeight = 600
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor(31,63,31)
	font = love.graphics.setNewFont(20)
	-- font:setFilter("nearest", "nearest", 0) --shouldn't this work?
	
	--graphics stuff, including the pixel-scaling trick you've been looking for since 2014
	canvas = love.graphics.newCanvas(320, 240)
	canvas:setFilter('nearest', 'nearest', 0)
	scale = 15
	
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
	
	showGlobals()
	print()
	-- tablePrint(_G.ListMenu) --never do this. it works, though! this is where listMenu.lua's functions are stored
	shallowTablePrint(_G.ListMenu)
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

-- function love.draw()
-- 	--TEST's wizard, enemy, emitters, and puffers (and all shadows) go on the bottom
-- 	drawParticleTEST()
--
-- 	--particles go on top of basically everything else
-- 	drawParticles()
--
-- 	--...actually menu stuff goes on top of everything else!
-- 	local dim = false
-- 	for key, element in ipairs(focusStack) do
-- 		-- element:draw(dim)
-- 		dim = true
-- 	end
--
-- 	--pause overlay
-- 	if paused then
-- 		love.graphics.setColor(0,0,0,127)
-- 		love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
-- 	end
-- end

function DrawCoolThing()
    love.graphics.push("all") -- save all love.graphics state so any changes can be restored
 
    love.graphics.setColor(0, 0, 255)
    love.graphics.setBlendMode("subtract")
 
    love.graphics.circle("fill", 400, 300, 80)
 
    love.graphics.pop() -- restore the saved love.graphics state
end
 
-- function love.draw()
--     love.graphics.setColor(255, 128, 128)
--     love.graphics.circle("fill", 400, 300, 100)
--
--     DrawCoolThing()
--
--     love.graphics.rectangle("fill", 600, 200, 200, 200) -- still uses the color set at the top of love.draw
--
--
--     love.graphics.push()
--     love.graphics.scale(5, 5)   -- reduce everything by 50% in both X and Y coordinates
--     love.graphics.print("Scaled text", 50, 50)
--     love.graphics.pop()
--     love.graphics.print("Normal text", 50, 50)
-- end



------------------------------------------------------------------------------------------------------------------------------------

--i'm really trying to solve the pixel-scale problem right now. changing zoom levels is such a headache; praying that this is a magic solution


local chipset = love.graphics.newImage("chipset1.png")
local quad = love.graphics.newQuad(0,32,16,16,32,64)

function love.draw()
  love.graphics.setCanvas(canvas)
	love.graphics.clear()
	-- love.graphics.scale(1)

  -- Do all drawing here as usual.
  -- You should round all love.graphics.draw coordinates or you will get visual bugs around the edges of your sprites.
  -- eg. love.graphics.draw(player.image, math.floor(x + 0.5), math.floor(y + 0.5))
	love.graphics.print("foo")
	
	love.graphics.draw(chipset, quad, 10, 26, 0)
	-- love.graphics.draw(chipset, 10, 6, 0)

  love.graphics.setCanvas()
  love.graphics.draw(canvas, 100, 100, 0, scale, scale);
end

------------------------------------------------------------------------------------------------------------------------------------

function love.keypressed(key)
	scale = scale - 1
	
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		paused = not paused
	elseif not paused then
		if #focusStack > 0 then
			-- focusStack[#focusStack]:keypressed(key)
		else
			--should never happen...
			print("no focused element to interact with")
		end
	end
end