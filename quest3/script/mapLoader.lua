require "script/mapTileDataRaw"

-- where map data is loaded at runtime and then fetched

function loadWorld()
	world = {}
	
	-- TODO use actual dimensions of world map. worldSize or whatever
	-- TODO you keep thinking about Z positions for non-overworld maps, too. just implement it already!
	for wy = 1,10 do
		world[wy] = {}
		
		for wx = 1,10 do
			world[wy][wx] = {}
			insertMap(wx,wy)
		end
	end
end

--the big one. nothing else for it, really.
-- TODO i mean is there any reason not to keep all this data in an external array and just call it from here? seems cleaner...
function insertMap(wx,wy)
	m = {}
	-- m.events = emptyMapGrid()
	-- m.eventShortcuts = {}
	m.localActorPointers = {}
	
	if wx == 1 then
		if wy == 1 then
			m.tiles = mapTileDataRaw[1]
			m.mapType = "start"
			m.localActorPointers = {
				-- {x=8,y=5,id=99} -- elf
				{x=8,y=5,id=21}
			}
			m.fastTravelTargetPos = {x=8,y=12} 
			m.seen = true -- derp TODO apply dynamically in or after saveLoader (then obvs also in navigation)
		elseif wy == 2 then
			m.tiles = mapTileDataRaw[2]
			m.mapType = "bonus"
			m.fastTravelTargetPos = {x=15,y=15}
		elseif wy == 3 then
			m.tiles = mapTileDataRaw[3]
			m.mapType = "cave"
			m.fastTravelTargetPos = {x=15,y=15}
			-- m.events[] -- ladder
		end
	elseif wx == 2 then
		if wy == 1 then
			m.tiles = mapTileDataRaw[5]
			m.mapType = "hole"
			m.localActorPointers = {
				{x=8,y=3,id=100}, --rock OR hole to 1,3
				{x=3,y=3,id=2}, --just hole
				{x=13,y=13,id=101}, --rock2
				{x=13,y=3,id=5},
				{x=13,y=8,id=99}, --elf
				{x=8,y=13,id=18},
				{x=3,y=8,id=19}, --elf2
			}
		elseif wy == 2 then
			m.tiles = mapTileDataRaw[4]
			m.mapType = "bonus"
			m.localActorPointers = {
				{x=3,y=8,id=6},
				{x=13,y=8,id=7},
				{x=3,y=3,id=20}, --!
			}
		elseif wy == 3 then
			m.tiles = mapTileDataRaw[4]
			m.mapType = "start"
			m.localActorPointers = {
				{x=2,y=3,id=8},
				{x=5,y=3,id=9},
				{x=8,y=3,id=10},
				{x=11,y=3,id=11},
				{x=14,y=3,id=12},
				{x=2,y=5,id=13},
				{x=5,y=5,id=14},
				{x=8,y=5,id=15},
				{x=11,y=5,id=16},
				{x=14,y=5,id=17},
			}
		end
	end

	-- little catch-all for now. derp TODO will have no place in final game
	if not m.tiles then
		m.tiles = mapTileDataRaw[1]
		m.mapType = "random"
		m.localActorPointers = {
			{x=8,y=5,id=6}
		}
	end

	--TODO do without mixing chipset into .tiles in raw map data; it IS ok to have a default chipset, note
	if m.tiles.chipset and m.tiles.chipset == 2 then
		m.chipset = 2 --TODO think of something better to call this
	else
		m.chipset = 1
	end

	--...and put it in the world!
	world[wy][wx] = m
end

-- map.tiles is an array of arrays; this just makes a blank one the same size as that (for something like .events)
function emptyMapGrid()
	t = {}
	for y = 1,(yLen) do
		t[y] = {}
	end

	return t
end

rawTileArray = {}