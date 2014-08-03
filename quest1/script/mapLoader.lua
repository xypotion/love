-- where map data is loaded at runtime and then fetched

function loadMapData()
	local w = {}
	
	-- maybe not necessary...
	for i = -10,10 do
		w[i] = {}
	end
	
	-- come on TODO actually load these the real way :P
	w[1][1] = makeStartMap()
	w[1][2] = makeRandomMap()
	
	return w
end

------------------------------------------------------------------------------------------------------

-- i believe NONE of the functions below will have a place in the final game.

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

function makeStartMap()
	m = {}
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
	m.events = emptyMapGrid()
	
	return m
end

function makeCaveMap()
	m = {}
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
	m.mapType = "start"
	m.events = emptyMapGrid()
	
	return m
end

function makeBonusMap()
	m = {}
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
	m.tiles = replaceSome0sWith1s(m.tiles)
	
	m.mapType = "bonus"
	m.events = emptyMapGrid()
	return m
end

function makeFlatMap()
	m = {}
	m.tiles = {
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,2,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	}
	
	m.mapType = "flat"
	m.events = emptyMapGrid()
	return m
end

function makeRandomMap()
	m = {}
	m.tiles = {}
	for y=1, yLen do
		m.tiles[y] = {}
		for x=1, xLen do
			m.tiles[y][x] = 2- math.floor(math.random(0,80) ^ 0.25)
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

-- map.tiles is an array of arrays; this just makes a blank one the same size as that (for something like .events) 
function emptyMapGrid()
	t = {}
	for y = 1,(yLen) do
		t[y] = {}
	end
	
	return t
end