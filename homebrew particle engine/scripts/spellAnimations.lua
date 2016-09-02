function prefabProjectile(type)
	--default stuff
	proj = {
		start = wizard, 
		dest = enemy, 
		x = wizard.x, 
		y = wizard.y,
		sx = wizard.x, 
		sy = wizard.y,
		distanceTraveled = 0,
		xDist = enemy.x - wizard.x,
		yDist = enemy.y - wizard.y,
		arc = 10,
		speed = 1,
		particleRate = 0.5,
		shadow = true,
		segments = 4,
		color = {r = 255, g = 255, b = 255, a = 255},
		size = 8,
	}
	
	--specifications
	if type == "fire" then
		proj.arc = 10
		proj.speed = 1
		
		proj.segments = 4
		proj.color = {r = 255, g = 127, b = 127, a = 255}

		proj.particleRate = 0.6
		proj.metaParticle = makeMetaParticle("fire trail")
	elseif type == "ice" then
		proj.arc = 7.5
		proj.speed = 1.25
		
		proj.segments = 12
		proj.color = {r = 247, g = 247, b = 255, a = 255}

		proj.particleRate = 0.8
		proj.metaParticle = makeMetaParticle("ice ball")
		
		proj.size = 10
	elseif type == "go" then
		proj.arc = 0
		proj.speed = 10
		
		proj.segments = 3
		proj.color = {r = 31, g = 247, b = 31, a = 255}

		proj.particleRate = 1
		proj.metaParticle = makeMetaParticle("go arrow")
		-- proj.explosionMetaParticle = makeMetaParticle("x-beam spark")
	elseif type == "x-beam" then
		proj.arc = 0
		proj.speed = 1
		
		proj.segments = 0
		proj.color = {r = 255, g = 255, b = 31, a = 255}

		proj.particleRate = 2
		proj.metaParticle = makeMetaParticle("x-beam spark")
		proj.explosionMetaParticle = makeMetaParticle("fire trail")
		
		proj.shadow = false
	end
	--TODO need failsafe here if type not found
	
	--should be simplified alongside the "elevation" refactor
	proj.vector = {x = proj.xDist, y = proj.yDist}
	proj.ascentSpeed = proj.arc
	proj.descentSpeed = proj.ascentSpeed * 2
	
	return proj
end