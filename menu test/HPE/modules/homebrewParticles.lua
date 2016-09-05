--indent = priority
--TODO z-ordering? draw non-particle entities in correct y-order? shadows always on the bottom, also
--TODO images for particles (D for dandelion?)
--TODO ...aaand animated particles. yikes.
--TODO array of projectiles so you can have many at once on screen. come on.
--TODO stationary emitters. E not taken yet :) use "line" polygons!
--TODO better "no effect" cases, both failsafes and when you simply don't want a projectile, particle stream, and/or particle explosion
--TODO variation on particles' origin points. deltaX and deltaY? is that confusing? haha
--TODO emission (except from puffers) is currently timer-free. should definitely change to emit on a set interval, not just "some % chance of emitting every update() cycle"
--TODO decide exactly where emitter code will live. it's in particleTEST right now, but should it not be a core part of the engine?
--TODO   you'll eventually probably need different tables of particles so they can be drawn at different times
--TODO   pixel-lock particle locations. kinda anal to insist on this, but it'll make small, image-based particles look way better. anti-aliasing = bad for pixel aesthetic
--TODO   destroy particles when they're off screen, alpha <= 0, or size <= 0 (in or near updateParticles(), maybe separate to new func)
--TODO   confetti gun that only has an explosion, no trail
--TODO   other particle attribute ideas... blink (kinda easy), oscillation (hard), image?, accel/jerk for color/size changes?, rotation?, orbit around origin point?, 
--       minima/maxima for colors and other attributes?
--       - picture the x-beam with a twirl effect! O_O ...but would need variable (via vary()? or something else?) angle-calculators built into the metaparticle
--TODO   MAYBE unite metaparticle attributes again instead of separating into "static" and "variable". instead, assume: if type(attribute) == table, then vary(), else foo = attribute
--       - advantage to above: would be much easier to make slight variations on prefab mParticles. could just pass the swap-out params to makeMeta()
--       - could also list static attributes in another table? some static attributes might BE tables & shouldn't vary()
--TODO   oscillation/blinking as an option for any attribute? making xOscillation, yOscillation, rOscillation, etc., plus timers and stuff for all those sounds awful
--       - probably calculating sines and stuff ahead of time (even storing in global arrays that oscillators walk) will be necessary. then different animation modes :/
--       - option to accelerate/jerk multiplicitavely? decay to 0? :/ difficult to do nicely, wait until needed. this could be another animation mode, like oscillation
--TODO     multiple metaparticles on a given projectile/emitter. could also just throw two fireballs :P
--TODO     nesting/grouping of attributes in library, or maybe attribute abstraction/generalization. like makeBall() instead of size=..., color=..., segments=..., just to save space
--TODO     random polygons instead of segmented circles? unfortunately love.graphics.polygon() doesn't take mode/x/y/shape, it just takes mode/shape, making this a bit harder

--things love.ParticleSystem can't do:
	--customizable animation speed (interval depends solely on how many quads you set)
	--pixel-locked motion
	--precise customization of particle attributes, especially velocity/accel/jerk
	--basic geometry for particles! must use images
	--oscillation
	--variable methods of vary()ing when emitting particles

--things love.ParticleSystem CAN do that i don't know how to do yet:
	--particle rotation (esp for segmented circles), particle orbit

function initParticleSystem()
	particles = {}
end

--update particles (their ages, colors, locations, sizes, velocities, and acceleration), then kill if they're too old
function updateParticles(dt)
	for k,p in pairs(particles) do
		p.age = p.age + dt
		
		--move particle
		p.x = p.x + p.xVelocity * dt
		p.y = p.y + p.yVelocity * dt

		--change color (linear)
		p.r = p.r + p.deltaR * dt
		p.g = p.g + p.deltaG * dt
		p.b = p.b + p.deltaB * dt
		p.a = p.a + p.deltaA * dt
		
		--change size
		p.size = p.size + p.deltaSize * dt
		if p.size < 0 then 
			p.size = 0
		end
		
		--change velocities
		p.xVelocity = p.xVelocity + p.xAcceleration * dt
		p.yVelocity = p.yVelocity + p.yAcceleration * dt
		
		--change acceleration
		p.xAcceleration = p.xAcceleration + p.xJerk * dt
		p.yAcceleration = p.yAcceleration + p.yJerk * dt
		
		--release
		if p.age > p.maxAge then
			table.remove(particles, k)
		end
	end
end

function drawParticles()
	for i = 1, #particles do
		local p = particles[i]
		love.graphics.setColor(p.r, p.g, p.b, p.a)
		love.graphics.circle("fill", p.x, p.y, p.size, p.segments)
	end
end

------------------------------------------------------------------------------------------------------------------------------------

function addParticle(x, y, meta, extraParams)
	--location + default particle init (just age = 0 for now)
	local p = {
		x = x,
		y = y,
		age = 0
	}
	
	--adopt all of metaparticle's static attributes
	for attribute, value in pairs(meta.static) do --what if this is nil? (it crashes! failsafe needed around line 362, but also TODO be safer with .static and .variable)
		p[attribute] = value
	end

	--adopt all of metaparticle's variable attributes with variance applied
	for attribute, range in pairs(meta.variable) do
		p[attribute] = vary(range)
	end
	
	--replace anything specified
	if extraParams then 
		for k,v in pairs(extraParams) do
			p[k] = v
		end
	end
	
	table.insert(particles, p)
end

--TODO change into, or merge with, emit(). explode() is just not a function you find in grown-ups' game code. u_u
function explode(fb)
	local mp = fb.explosionMetaParticle or fb.metaParticle or makeMetaParticle("fire trail")
	
	for i = 1, 10 + fb.particleRate * 10 do
		addParticle(fb.x, fb.y, mp)
	end
end

--range must be a table containing two numbers, "min" and "var", and optionally "mode"
--if range also contains the "mode" attribute, complex functions of variance may be used, like "extreme" or "integer"
--if range does not contain "mode", the default variance algorithm, "linear", is used. this will generate a rational number between [range.min] and [range.min + range.var]
function vary(range)
	local value = 0
	local mode = range.mode or "linear" 
	
	if mode == "linear" then
		--a rational number between [range.min] and [range.min + range.var]
		value = math.random() * range.var + range.min
	elseif mode == "integer" then
		--a whole number between [range.min] and [range.min + range.var]. rounds to nearest
		value = math.random() * range.var + range.min
		if value - 0.5 < math.floor(value) then
			value = math.floor(value)
		else
			value = math.ceil(value)
		end
	elseif mode == "extreme" then
		--50/50 chance: either [range.min] or [range.min + range.var]
		if math.random() > 0.5 then
			value = range.min
		else
			value = range.min + range.var
		end
	-- elseif mode == "absolute value" then --TODO
	-- elseif mode == "bell curve" then --TODO
	-- elseif mode == "inverse bell curve" then --TODO
	end
	
	return value
end