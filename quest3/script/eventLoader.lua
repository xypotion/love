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
		-- print("loading generic event "..pointer.id..".")
		-- print(eventDataRaw[pointer.id].name)
		e = newEvent(eventDataRaw[pointer.id])
		if not e then print ("no generic event for ID "..pointer.id.."found.") end
		-- TODO so the logically complicated ones above can start with 1000? sounds good, just have to explicitly add them to raw data table.
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
		print "no actor params!?"
	end
	
	--use sc ("sprite construct"), if provided, to assign image, quads, and anikey
	if e.sc then		
		e.anikey = anikeys[e.sc.category]
		e.image = images[e.sc.category][e.sc.image]
		if e.complex then
			e.facing = e.facing or "s" 
			e.quads = quadSets[e.sc.category]
		else
			e.quads = quadSets[e.sc.category][e.sc.quadId]
		end
	end
	
	--also add actor stuff if name provided. that means scripts are gonna do stuff to it!
	if e.name then
		-- print("newEvent; name is "..e.name)
		e.distanceFromTarget = 0
		e.speed = e.speed or 200 * zoom --TODO update at zoom?
	else
		-- print("newEvent with no name!")
	end
	
	return e
end