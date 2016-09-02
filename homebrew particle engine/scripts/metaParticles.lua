--metaparticles are used as a prototype for a given emitter's particles. see addParticle() and comment on vary() for a little more info on this.
function makeMetaParticle(type)
	attributes = {}
	
	--all "deltas" are applied per second, i.e. how much is a given attribute allowed to change after 1s?
	if type == "fire trail" then
		attributes = {
			static = {
				segments = 4,
			},
			variable = {
				maxAge = {min = 1, var = 1},
			
				r = {min = 247, var = 8},
				g = {min = 191, var = 64},
				b = {min = 127, var = 32},
				a = {min = 191, var = 0},
			
				deltaR = {min = -0, var = 0},
				deltaG = {min = -191, var = 100},
				deltaB = {min = -191, var = 25},
				deltaA = {min = -191, var = 25},
			
				size = {min = 6, var = 1},
				deltaSize = {min = -4, var = 2},
			
				xVelocity = {min = -100, var = 200},
				yVelocity = {min = -100, var = 200},
				xAcceleration = {min = -150, var = 300},
				yAcceleration = {min = 50, var = 100},
				xJerk = {min = -100, var = 200},
				yJerk = {min = -100, var = 200},
			}
		}
	elseif type == "ice ball" then
		attributes = {
			static = {
				maxAge = 3,

				r = 191,
				g = 223,
				b = 255,
				a = 223,
				
				segments = 6,
			},
			variable = {
				deltaR = {min = -191, var = 50},
				deltaG = {min = -191, var = 50},
				deltaB = {min = -127, var = 50},
				deltaA = {min = -255, var = 0},
			
				size = {min = 5, var = 2},
				deltaSize = {min = -2, var = 2},
			
				xVelocity = {min = -50, var = 100},
				yVelocity = {min = -20, var = 60},
				xAcceleration = {min = -50, var = 100},
				yAcceleration = {min = 200, var = 0},
				xJerk = {min = -200, var = 400},
				yJerk = {min = -350, var = 0},
			}
		}	
	elseif type == "go arrow" then
		attributes = {
			static = {
				maxAge = 8,

				r = 31,
				g = 255,
				b = 31,
				a = 255,
				
				segments = 3,
			},
			variable = {
				deltaR = {min = 63, var = 50},
				deltaG = {min = 0, var = 0},
				deltaB = {min = 63, var = 50},
				deltaA = {min = 0, var = 0},
			
				size = {min = 5, var = 10},
				deltaSize = {min = 0, var = 0},
			
				xVelocity = {min = -250, var = 100},
				yVelocity = {min = -50, var = 100},
				xAcceleration = {min = 0, var = 100},
				yAcceleration = {min = 0, var = 0},
				xJerk = {min = 500, var = 0},
				yJerk = {min = 0, var = 0},
			}
		}	
	elseif type == "x-beam spark" then
		attributes = {
			static = {
				maxAge = 0.5,

				r = 255,
				g = 255,
				b = 255,
				a = 255,
				
				segments = 8,
			},
			variable = {
				deltaR = {min = -640, var = 256},
				deltaG = {min = -640, var = 0},
				deltaB = {min = -1024, var = 0},
				-- deltaR = {min = -1024, var = 512, mode = "extreme"},
				-- deltaG = {min = -1024, var = 512, mode = "extreme"},
				-- deltaB = {min = -1024, var = 512, mode = "extreme"},
				deltaA = {min = 0, var = 0},
			
				size = {min = 6, var = 0},
				deltaSize = {min = -8, var = 1},
			
				xVelocity = {min = -256, var = 512, mode = "extreme"},
				yVelocity = {min = -256, var = 512, mode = "extreme"},
				xAcceleration = {min = 0, var = 0},
				yAcceleration = {min = 0, var = 0},
				xJerk = {min = 0, var = 0},
				yJerk = {min = 0, var = 0},
			}
		}	
	elseif type == "random wild" then
		attributes = {
			static = {
			},
			variable = {
				maxAge = {min = 1, var = 10},
				
				segments = {min = 3, var = 5, mode = "integer"},
			
				r = {min = 0, var = 256},
				g = {min = 0, var = 256},
				b = {min = 0, var = 256},
				a = {min = 0, var = 256},
			
				deltaR = {min = -256, var = 512},
				deltaG = {min = -256, var = 512},
				deltaB = {min = -256, var = 512},
				deltaA = {min = -256, var = 512},
			
				size = {min = 1, var = 10},
				deltaSize = {min = -10, var = 20},
			
				xVelocity = {min = -500, var = 1000},
				yVelocity = {min = -500, var = 1000},
				xAcceleration = {min = -500, var = 1000},
				yAcceleration = {min = -500, var = 1000},
				xJerk = {min = -500, var = 1000},
				yJerk = {min = -500, var = 1000},
			}
		}
	elseif type == "random tame" then
		attributes = {
			static = {
			},
			variable = {
				maxAge = {min = math.random(5), var = math.random(5)},

				segments = {min = math.random(3) + 2, var = math.random(3), mode = "integer"},
			
				r = {min = math.random(256), var = math.random(256)},
				g = {min = math.random(256), var = math.random(256)},
				b = {min = math.random(256), var = math.random(256)},
				a = {min = math.random(256), var = math.random(256)},
			
				deltaR = {min = 0 - math.random(256), var = math.random(512)},
				deltaG = {min = 0 - math.random(256), var = math.random(512)},
				deltaB = {min = 0 - math.random(256), var = math.random(512)},
				deltaA = {min = 0 - math.random(256), var = math.random(512)},
			
				size = {min = math.random(10), var = math.random(10)},
				deltaSize = {min = 0 - math.random(10), var = math.random(10)},
			
				xVelocity = {min = 0 - math.random(256), var = math.random(512)},
				yVelocity = {min = 0 - math.random(256), var = math.random(512)},
				xAcceleration = {min = 0 - math.random(256), var = math.random(512)},
				yAcceleration = {min = 0 - math.random(256), var = math.random(512)},
				xJerk = {min = 0 - math.random(256), var = math.random(512)},
				yJerk = {min = 0 - math.random(256), var = math.random(512)},
			}
		}
		
		for k,v in pairs(attributes.variable) do
			print(v.min, v.var, k)
		end
	else
		print("metaparticle type not found")
		attributes = makeMetaParticle("fire trail")
	end
	
	return attributes
end