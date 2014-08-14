require "script/eventDataRaw"

-- behavior/appearance scripts for all events! yup.
-- DON'T know their own world locations; map loader will look in allEvents by index when it loads a map
-- DO know their own appearance conditions (e.g. story progression, other flags)

-- duplicate events, e.g. a town exit: up to the map loader, so make sure it can handle them!

-- ...or maybe this is the big one where logic goes? looks at raw table for more data?? woof
function loadLocalActor(pointer) --contains x, y, and id
	e = {currentPos = {x=pointer.x, y=pointer.y}}
	
	if pointer.id == 99 then
		e = newEvent(eventDataRaw[3])
	elseif pointer.id == 100 then
		if score < 300 then
			e = newEvent(eventDataRaw[1]) -- LIKE THIS?
		else
			e = newEvent(eventDataRaw[2])
		end
	elseif pointer.id == 101 then
		e = newEvent(eventDataRaw[4])
	else
		print("loading generic event "..pointer.id..".")
		print(eventDataRaw[pointer.id].name)
		e = newEvent(eventDataRaw[pointer.id])
		if not e then print ("no generic event for ID "..pointer.id.."found.") end
		-- TODO so the logically complicated ones above can start with 1000? sounds good, though it'll be a tiny bit harder to add them to raw data table. meh.
	end
	
	return e
end

-- kind of a "constructor" for events. lots of these fields will be unused, so i want to put default values in them
function newEvent(params) --TODO rename
	e = {
		currentPos = e.currentPos, --goddammit TODO but i don't waaanna pass pos to this every time it's called
		-- appearsIf = true, --always appears unless altered
		-- sprite = nil,
		collide = false,
		destination = {wx=1,wy=1,mx=8,my=8}, -- obviously change if using; TODO consider simply specifying within interaction behavior script
		interactionBehavior = {},
		idleBehavior = {},
		volatile = false, -- if true, will get re-loaded every time something else happens; intended for locks unlocked by switches on the same screen TODO lol
		
		-- image = eventSpritesImage,
		-- quads =
	}
	
	--then apply custom stuff:
	if params then
		for k,v in pairs(params) do
			e[k] = v
		end
	else
		print "no params!"
	end
	
	--flesh out sprite stuff if it was provided
	if e.spriteId then
		e.spriteQuad = spriteQuads[e.spriteId]
		e.spriteImage = eventSpritesImage --TODO actually store & recall this value, since there will be many image variables (even a table of them?)
		if type(e.spriteQuad) == "table" then
			e.anikey = anikeys[e.spriteQuad.anikeyId]
			
			if e.spriteQuad.anikeyId == "swirl" then
				e.spriteImage = swirlImage --TODO supahack. see above
			end
		else--if type(e.spriteQuad) == "number" then
			e.anikey = {frame = 1} --stating explicitly in case an event's sprite gets changed somehow
			e.spriteQuad = {e.spriteQuad} --TODO pretty hacky. i dunno. this mess is half-fixed already, so kinda no biggie yet
		end
		
		--TODO consolidate.. this is just for testing during the transition
		e.image = e.spriteImage
		e.quads = e.spriteQuad
	end
	
	--also add actor stuff if actor == true. that means scripts are gonna do stuff to it!
	if e.name then
		print("newEvent; name is "..e.name)
		-- copied from hero.lua, can you tell? just for a template...
		e.distanceFromTarget = 0
		e.speed = 200 * zoom --TODO update at zoom? also how would i set this o_o
		-- e.facing = 's'
		-- e.screenX = 0
		-- e.screenY = 0
	else
		print("newEvent ~ no name!")
	end
	
	return e
end