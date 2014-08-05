-- where map data is loaded at runtime and then fetched

function loadMapData()
	 w = {}
	
	-- come on TODO actually load these the real way :P
	-- w[1][1] = makeStartMap()
	-- w[1][2] =makeRandomMap()
	
	for wy = -5,5 do
		w[wy] = {}
		
		for wx = -5,5 do
			w[wy][wx] = {}
			insertMap(wx,wy) --don't like this
		end
	end
	
	return w --why? you're not making multiple worlds...
end

--the big one. nothing else for it, really.
function insertMap(wx,wy)
	m = {}
	m.events = emptyMapGrid()
	
	if wx == 1 then
		if wy == 1 then
			m.tiles = {
				{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
				{1,1,1,1,1,3,1,1,1,3,1,1,1,1,1},
				{1,1,1,1,1,3,1,3,1,3,1,1,1,1,1},
				{1,1,1,1,1,3,1,3,1,3,1,1,1,1,1},
				{1,1,1,1,1,1,3,1,3,1,1,1,1,1,1},
				{1,1,3,3,1,1,1,1,1,1,1,3,3,3,1},
				{1,3,1,1,3,1,2,2,2,1,3,1,1,1,1},
				{1,3,3,3,3,1,2,1,2,1,3,3,3,3,1},
				{1,3,1,1,3,1,2,2,2,1,1,1,1,3,1},
				{1,3,1,1,3,1,1,1,1,1,3,3,3,1,1},
				{1,1,1,1,1,3,3,3,3,1,1,1,1,1,1},
				{1,1,1,1,1,3,1,1,1,3,1,1,1,1,1},
				{1,1,1,1,1,3,1,1,1,3,1,1,1,1,1},
				{1,1,1,1,1,3,3,3,3,1,1,1,1,1,1},
				{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			}
			m.mapType = "start"
		elseif wy == 2 then
			m.tiles = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,2,2,2,0,0,0,2,2,0,0,0,0},
				{0,0,0,2,0,0,2,0,2,0,0,2,0,0,0},
				{0,4,0,2,2,2,0,0,2,0,0,2,0,4,0},
				{0,0,0,2,0,0,2,0,2,0,0,2,0,0,0},
				{0,0,0,2,2,2,0,0,0,2,2,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,2,0,0,2,0,2,0,0,2,0,2,2,2,0},
				{0,2,2,0,2,0,2,0,0,2,0,2,0,0,0},
				{0,2,0,2,2,0,2,0,0,2,0,0,2,0,0},
				{0,2,0,0,2,0,2,0,0,2,0,0,0,2,0},
				{0,2,0,0,2,0,0,2,2,0,0,2,2,2,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			}
			m.mapType = "bonus"
		elseif wy == 3 then
			m.tiles = {
				{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6},
				{6,6,6,5,5,5,5,5,5,5,5,5,6,6,6},
				{6,6,5,5,5,5,5,5,5,5,5,5,5,6,6},
				{6,5,5,4,3,4,3,4,3,4,3,4,5,5,6},
				{6,5,4,3,4,3,4,3,4,3,4,3,4,5,6},
				{6,4,3,4,3,4,3,4,3,4,3,4,3,4,6},
				{6,4,4,3,4,3,4,3,4,3,4,3,4,4,6},
				{6,4,3,4,3,4,3,4,3,4,3,4,3,4,6},
				{6,4,4,3,4,3,4,3,4,3,4,3,4,4,6},
				{6,4,3,4,3,4,3,4,3,4,3,4,3,4,6},
				{6,4,4,3,4,3,4,3,4,3,4,3,4,4,6},
				{6,6,3,4,3,4,3,4,3,4,3,4,3,6,6},
				{6,6,6,3,4,3,4,3,4,3,4,3,6,6,6},
				{6,6,6,6,6,6,6,4,6,6,6,6,6,6,6},
				{6,6,6,6,6,6,6,4,6,6,6,6,6,6,6},
			}
			m.mapType = "cave"
			-- m.events[] -- ladder
		end
	elseif wx == 2 then
		if wy == 1 then
			m.tiles = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,2,2,2,0,0,0,0,0,0},
				{0,0,0,0,0,0,2,0,2,0,0,0,0,0,0},
				{0,0,0,0,0,0,2,2,2,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			}
			m.mapType = "hole"
			m.events[8][8] = 100 --hole to 1,3
		elseif wy == 2 then
			m.tiles = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,2,2,2,0,0,0,2,2,0,0,0,0},
				{0,0,0,2,0,0,2,0,2,0,0,2,0,0,0},
				{0,4,0,2,2,2,0,0,2,0,0,2,0,4,0},
				{0,0,0,2,0,0,2,0,2,0,0,2,0,0,0},
				{0,0,0,2,2,2,0,0,0,2,2,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,2,0,0,2,0,2,0,0,2,0,2,2,2,0},
				{0,2,2,0,2,0,2,0,0,2,0,2,0,0,0},
				{0,2,0,2,2,0,2,0,0,2,0,0,2,0,0},
				{0,2,0,0,2,0,2,0,0,2,0,0,0,2,0},
				{0,2,0,0,2,0,0,2,2,0,0,2,2,2,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			}
			m.mapType = "bonus"
		elseif wy == 3 then
			m.tiles = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
				{0,0,0,0,0,1,0,1,0,1,0,0,0,0,0},
				{0,0,0,0,0,1,0,1,0,1,0,0,0,0,0},
				{0,0,0,0,0,0,1,0,1,0,0,0,0,0,0},
				{0,0,1,1,0,0,0,0,0,0,0,1,1,1,0},
				{0,1,0,0,1,0,2,2,2,0,1,0,0,0,0},
				{0,1,1,1,1,0,2,0,2,0,1,1,1,1,0},
				{0,1,0,0,1,0,2,2,2,0,0,0,0,1,0},
				{0,1,0,0,1,0,0,0,0,0,1,1,1,0,0},
				{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
				{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
				{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
				{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			}
			m.mapType = "start"
		end
	end
	
	--little catch-all for now
	if not m.tiles then
		m = makeRandomMap()
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
