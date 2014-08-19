require "script/mapTileDataRaw"

-- where map data is loaded at runtime and then fetched

function loadMapData()
	w = {}
	
	-- TODO use actual dimensions of world map
	-- TODO you keep thinking about Z positions for non-overworld maps, too. just implement it already!
	for wy = -5,5 do
		w[wy] = {}
		
		for wx = -5,5 do
			w[wy][wx] = {}
			insertMap(wx,wy)
		end
	end
	
	return w --why? you're not making multiple worlds... TODO
end

--the big one. nothing else for it, really.
-- TODO i mean is there any reason not to keep all this data in an external array and just call it from here? seems cleaner...
function insertMap(wx,wy)
	m = {}
	-- m.events = emptyMapGrid()
	-- m.eventShortcuts = {}
	m.eventPointers = {} --rename
	
	if wx == 1 then
		if wy == 1 then
			m.tiles = mapTileDataRaw[1]
			m.mapType = "start"
			m.eventPointers = {
				{x=8,y=5,id=99} -- elf
			}
		elseif wy == 2 then
			m.tiles = mapTileDataRaw[2]
			m.mapType = "bonus"
		elseif wy == 3 then
			m.tiles = mapTileDataRaw[3]
			m.mapType = "cave"
			-- m.events[] -- ladder
		end
	elseif wx == 2 then
		if wy == 1 then
			m.tiles = mapTileDataRaw[5]
			m.mapType = "hole"
			m.eventPointers = {
				{x=8,y=8,id=100}, --rock OR hole to 1,3
				{x=3,y=8,id=2}, --just hole
				{x=8,y=11,id=101}, --rock2
				{x=10,y=11,id=5},
				{x=10,y=10,id=99}, --elf
				{x=3,y=13,id=8}
			}
		elseif wy == 2 then
			m.tiles = mapTileDataRaw[4]
			m.mapType = "bonus"
			m.eventPointers = {
				{x=3,y=8,id=6},
				{x=13,y=8,id=7}
			}
		elseif wy == 3 then
			m.tiles = mapTileDataRaw[4]
			m.mapType = "start"
		end
	end
	
	--little catch-all for now. derp. (and it doesn't actually work)
	if not m.tiles then
			m.tiles = mapTileDataRaw[1]
			m.mapType = "random"
			m.eventPointers = {
				{x=8,y=5,id=6}
			}
	end
	
	--TODO do properly. it IS ok to have a default chipset, note
	if m.tiles.chipset and m.tiles.chipset == 2 then
		m.chipset = 2 --TODO think of something better to call this
	else 
		m.chipset = 1
	end
		
	
	w[wy][wx] = m
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

------------------------------------------------------------------------------------------------------

-- i believe NONE of the functions below will have a place in the final game. for testing, only!

function makeMap(_type)	
	if _type == "start" then
		m = makeStartMap()
	elseif _type == "random" then 
		m = makeRandomMap()
	elseif _type == "flat" then 
		m = makeFlatMap()
	elseif _type == "bonus" then 
		m = makeBonusMap()	
	elseif _type == "cave" then 
		m = makeCaveMap()	
	else
		print("ERROR in makeMap: unknown map type encountered.")
		return nil
	end
	
	--just a little check for myself :3 TODO keep this up-to-date whenever you add new map attributes!
	if m.mapType and m.events and m.tiles then
		return m
	else
		print("ERROR in makeMap: some necessary map attributes missing from generated map")
		return nil
	end	
end

function makeRandomMap()
	m = {}
	m.tiles = {}
	for y=1, yLen do
		m.tiles[y] = {}
		for x=1, xLen do
			m.tiles[y][x] = 5- math.floor(math.random(0,1295) ^ 0.25)
		end
	end

	m.mapType = "random"
	m.events = emptyMapGrid()
	
	return m
end

--oh yes.
function replaceSome0sWith1s(m)
	t = {}
	for key,row in pairs(m) do
		t[key] = {}
		for k,cell in pairs(row) do
			if cell == 0 then
				t[key][k] = math.random(0,1)
			else
				t[key][k] = m[key][k]
			end
		end
	end
	return t
end
