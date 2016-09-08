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
	math.randomseed(os.time())
	ONE_THIRD = 1/3
	TWO_THIRDS = ONE_THIRD * 2
	
	--debuggy stuff
	DEBUG = true
	fps = 0
	
	--basic graphics/window stuff
	--interesting to note: 752 is as tall as a non-fullscreen game can get on your 13in macbook
	minScreenWidth = 400
	minScreenHeight = 300 
	scale = 1
	screenWidth = minScreenWidth * scale
	screenHeight = minScreenHeight * scale

	love.window.setMode(screenWidth, screenHeight, {
		resizable = true,
		minwidth = minScreenWidth,
		minheight = minScreenHeight
	})
	
	love.graphics.setBackgroundColor(31,63,31)
	font = love.graphics.setNewFont(20)
	
	--this is the pixel-scaling trick you've been looking for since 2014
	canvas = love.graphics.newCanvas(320, 240)
	canvas:setFilter('nearest', 'nearest', 0)
	
	--whatever
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
	fps = round(1/dt)
	
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

------------------------------------------------------------------------------------------------------------------------------------

--i'm really trying to solve the pixel-scale problem right now. changing zoom levels is such a headache; praying that this is a magic solution
-- local chipset = love.graphics.newImage("chipset1.png")
-- local quad = love.graphics.newQuad(0,32,16,16,32,64)

--solved it!!
function love.draw()
  love.graphics.setCanvas(canvas)
	love.graphics.clear()
	
	-- love.graphics.draw(chipset, quad, 10, 26, 0)

  love.graphics.setCanvas()
  love.graphics.draw(canvas, 100, 100, 0, scale, scale);

	--FPS bar & other debug stuff outside of scaled canvas
	if DEBUG then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle("fill", 10, 10, fps, 10)
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.rectangle("line", 10, 10, 60, 10)
	end
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

--change scale & snap window dimensions on resize
function love.resize(w, h)
	--did they go bigger or smaller? enough to change scale?
	local wRatio = round(w / minScreenWidth)
	local hRatio = round(h / minScreenHeight)
	local avgRatio = round((wRatio + hRatio) / 2)
	
	if w - screenWidth + h - screenHeight > 0 then
		avgRatio = math.ceil((wRatio + hRatio) / 2)
	else
		avgRatio = math.floor((wRatio + hRatio) / 2)
	end
	
	--make sure it's not too big before changing anything
	local maxW, maxH = love.window.getDesktopDimensions()
	
	if minScreenWidth * avgRatio < maxW and minScreenHeight * avgRatio < maxH then
		scale = avgRatio
		screenWidth = minScreenWidth * scale
		screenHeight = minScreenHeight * scale
	end

	--snap to new (or old) dimensions
	love.window.setMode(screenWidth, screenHeight, {
		resizable = true,
		minwidth = minScreenWidth,
		minheight = minScreenHeight
	})
end