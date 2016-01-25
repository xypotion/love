function loadImages()
	makeQuads()
	
	-- meh.
end

--
images = {
	chipsets = {
		love.graphics.newImage("img/chipset2.png"),
		love.graphics.newImage("img/chipset2castles??.png"),
	},
	stillActors = {love.graphics.newImage("img/sprites1.png")},
	marble = {
		love.graphics.newImage("img/marble1.png"),
		love.graphics.newImage("img/marble2.png"),
		love.graphics.newImage("img/marble6.3.png"),
		love.graphics.newImage("img/marble4.1.png"),
		love.graphics.newImage("img/marble4.2.png"),
		love.graphics.newImage("img/marble5.3.png"),
		love.graphics.newImage("img/marble6.7.png"),
		love.graphics.newImage("img/marble6.6.png"),
		love.graphics.newImage("img/marble6.9.png"),
		love.graphics.newImage("img/marble7.1.png"),
		love.graphics.newImage("img/marble8.png"),
	},
	characters = {
		hero = love.graphics.newImage("img/directional-man1.2.png"),
		elf = love.graphics.newImage("img/directional-elf-1.png"),
	},
	swirl = {love.graphics.newImage("img/swirl9.png")}, --eh.
	event = {love.graphics.newImage("img/event2.png")}
}

--
colors = {
	white = {r=255,g=255,b=255},
	blue = {r=31,g=31,b=191},
}

-- TODO pretty hacky/devvy for now, but this is the gist of it. 1 = collide, 0 = clear
-- * should have as many members as there are chipsets
-- * each member should have as many members as there are in quadsets.map (1 per tile type)
collisionMaps = {}
collisionMaps[1] = {0,0,1,0,0,1,1} --normal chipset
collisionMaps[2] = {0,1,1,0,0,1,1} --"castle" derpset

--
anikeys = {}
anikeys.map = {
	frame = 1,
	count = 2,
	interval = .4,
	time = 0
}
anikeys.stillActors = {
	frame = 1,
	count = 1,
}
anikeys.characters = {
	frame = 1,
	count = 2,
	interval = .32,
	time = 0
}
anikeys.swirl = {
	frame = 1,
	count = 8,
	interval = .06,
	time = 0
}
anikeys.marble = {
	frame = 1,
	count = 8,
	interval = .06,
	time = 0
}
anikeys.event = {
	frame = 1,
	count = 4,
	interval = .1,
	time = 0
}
anikeys.minimap = {
	frame = 1,
	count = 2,
	interval = .2,
	time = 0
}

function tickAniKey(ak, dt)
	if ak.interval then --if it's nil, then it's still!
		ak.time = ak.time + dt
		if ak.time > ak.interval then
			ak.time = 0
			ak.frame = (ak.frame) % ak.count + 1
		end
	end
end

-- called at startup (from loadImages() above) and whenever zoom changes
function makeQuads()
	quadSets = {}
	
	local qs = {} --"quad size", shortcut for the last 4 of 6 arguments to newQuad in quadAt

	qs = {1,1,8,1}
	quadSets.characters = {
		s = {quadAt(0,0,qs),quadAt(1,0,qs)},
		n = {quadAt(2,0,qs),quadAt(3,0,qs)},
		w = {quadAt(4,0,qs),quadAt(5,0,qs)},
		e = {quadAt(6,0,qs),quadAt(7,0,qs)},
		shock = {quadAt(0.5,0,qs)} --TODO glad it works but it's so wrong :P (ART NEEDED)
	}
	--TODO also emotion/casting/hit/down/whatever quads used by all characters in cutscenes? anikeys may change in those cases, is the problem
	
	qs = {1,1,4,4}
	quadSets.stillActors = {
		{quadAt(0,0,qs)}, --1:map
		{quadAt(1,0,qs)}, --2:rock
		{quadAt(2,0,qs)}, --3:hole
		{quadAt(0,1,qs)}, --4:gold
		{quadAt(1,1,qs)}, --5:sign
	}
	
	qs = {1,1,2,4}
	mapTileQuads = { --TODO integrate into quadSets
		quadAt(0,1,qs), --1: grass
		quadAt(0,2,qs), --2: flower
		{quadAt(0,0,qs), quadAt(1,0,qs)}, --3: water
		quadAt(1,1,qs), --4: light dirt
		quadAt(1,2,qs), --5: dark dirt
		quadAt(0,3,qs), --6: stone
		quadAt(1,3,qs), --7: daarkness
	}

	qs = {1,1,8,1}
	quadSets.swirl = {
		{
			quadAt(0,0,qs),
			quadAt(1,0,qs),
			quadAt(2,0,qs),
			quadAt(3,0,qs),
			quadAt(4,0,qs),
			quadAt(5,0,qs),
			quadAt(6,0,qs),
			quadAt(7,0,qs),
		}
	}

	qs = {1,1,4,1}
	quadSets.event = {
		{
			quadAt(0,0,qs),
			quadAt(1,0,qs),
			quadAt(2,0,qs),
			quadAt(3,0,qs),
		}
	}
	
	quadSets.marble = quadSets.swirl
	
	--repeat for other quad collections
end

-- makes a quad with provided args. just saves space above ~
function quadAt(x, y, qs)
	return love.graphics.newQuad(x*tileSize, y*tileSize, qs[1]*tileSize, qs[2]*tileSize, qs[3]*tileSize, qs[4]*tileSize)
end