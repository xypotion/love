-- behavior/appearance scripts for all events! yup.
-- DON'T know their own world locations; map loader will look in allEvents by index when it loads a map
-- DO know their own appearance conditions (e.g. story progression, other flags)

-- duplicate events, e.g. a town exit: up to the map loader, so make sure it can handle them!

-- kind of a "constructor" for events. lots of these fields will be unused, so i want to put default values in them
function newEvent(params)
	-- a good reference :)
	e = {
		appearsIf = true, --always appears unless altered
		pos = {x=0,y=0}, --grid position; optional
		sprite = nil,
		collide = false,
		destination = {wx=1,wy=1,mx=8,my=8}, -- obviously change if using TODO consider simply folding into interaction behavior
		interactionBehavior = {},
		idleBehavior = {}
	}
	
	for k,v in pairs(params) do
		e[k] = v
	end
	
	return e
end

-- called from main's love.load()? hm
function loadAllEvents()
	allEvents = {}
	ae = allEvents
	
	--[[ template:
	allEvents[#] = newEvent({
		pos = {} -- where on the map grid it appears; optional!
	})
	]]
	
	allEvents[1] = newEvent({
		bar = 0,
		baz = "whatever",
		qux = {1,2,3,4}
	})
	
	
	-- like this, i guess. one file per array, then just include in main, call loadWhatever(), then call script events by number
		-- if these are just huge text files, they shouldn't take up tooooooo much memory...
		-- can script images with corresponding filenames and quads here too! whee (although each animated thing might get its own file)
		
	-- i guess common stuff like many objects that init the same way or AI that all/most enemies perform, etc can use actual functions? to save space
		-- note that AI is not going here, obviously
	
	-- might wanna keep a block-comment "manifest" somewhere. top sounds nice, but bottom might actually be more practical.
end