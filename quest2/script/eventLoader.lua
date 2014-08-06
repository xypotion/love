-- behavior/appearance scripts for all events! yup.
-- DON'T know their own world locations; map loader will look in allEvents by index when it loads a map
-- DO know their own appearance conditions (e.g. story progression, other flags)

-- duplicate events, e.g. a town exit: up to the map loader, so make sure it can handle them!

-- ...or maybe this is the big one where logic goes? looks at raw table for more data?? woof
function loadEvent(id)
	e = {}
	

	
	if id == 99 then
		e = newEvent({
			spriteId = 3 -- elf
		})
	elseif id == 100 then
		if score < 300 then
			e = newEvent({
				spriteId = 1 -- rock
			})
		else
			e = newEvent({
				spriteId = 2 -- hole
			})
		end
	else
		print "don't know that event"
	end
	
	return e
end

-- kind of a "constructor" for events. lots of these fields will be unused, so i want to put default values in them
function newEvent(params)
	e = {
		-- appearsIf = true, --always appears unless altered
		-- pos = {x=0,y=0}, --grid position; optional
		-- sprite = nil,
		collide = false,
		destination = {wx=1,wy=1,mx=8,my=8}, -- obviously change if using; TODO consider simply specifying within interaction behavior script
		interactionBehavior = {},
		idleBehavior = {},
		volatile = false, -- if true, will get re-loaded every time something else happens; intended for locks unlocked by switches on the same screen 
	}
	
	--then apply custom stuff:
	for k,v in pairs(params) do
		e[k] = v
	end
	
	--and flesh out sprite stuff if it was provided
	if e.spriteId then
		e.spriteQuad = spriteQuads[e.spriteId]
		e.spriteImage = eventSpritesImage --TODO actually store & recall this value, since there will be many image variables (even a table of them?)
		if type(e.spriteQuad) == "table" then
			e.anikey = anikeys[e.spriteQuad.anikeyId]
		else--if type(e.spriteQuad) == "number" then
			e.anikey = nil --stating explicitly in case an event's sprite gets changed somehow
		end
	end
	
	return e
end

-- called from main's love.load()? hm
-- function loadAllEvents()
-- 	allEvents = {}
-- 	-- -- ae = allEvents --?
-- 	--
-- 	-- --[[ template:
-- 	-- allEvents[#] = newEvent({
-- 	-- 	pos = {} -- where on the map grid it appears; optional!
-- 	-- })
-- 	-- ]]
-- 	--
-- 	allEvents[1] = newEvent({
-- 		bar = 0,
-- 		baz = "whatever",
-- 		qux = {1,2,3,4}
-- 	})
--
-- 	if score < 300 then
-- 		allEvents[100] = newEvent({
-- 			spriteId = 1 -- rock
-- 		})
-- 	else
-- 		allEvents[100] = newEvent({
-- 			spriteId = 2 -- hole
-- 		})
-- 	end
-- 	--
-- 	--
-- 	-- -- like this, i guess. one file per array, then just include in main, call loadWhatever(), then call script events by number
-- 	-- 	-- if these are just huge text files, they shouldn't take up tooooooo much memory...
-- 	-- 	-- can script images with corresponding filenames and quads here too! whee (although each animated thing might get its own file)
-- 	--
-- 	-- -- i guess common stuff like many objects that init the same way or AI that all/most enemies perform, etc can use actual functions? to save space
-- 	-- 	-- note that AI is not going here, obviously
-- 	--
-- 	-- -- might wanna keep a block-comment "manifest" somewhere. top sounds nice, but bottom might actually be more practical.
-- end


	
-- allEvents = {
-- 	id1={
-- 		},
-- 		-- id2 = function(){if true then return 2
-- 		-- 	else return -2 end},
-- 			id3 = 3
-- }