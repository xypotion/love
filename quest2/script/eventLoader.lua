require "script/eventDataRaw"

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
			e = newEvent(eventDataRaw[1]) -- LIKE THIS?
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