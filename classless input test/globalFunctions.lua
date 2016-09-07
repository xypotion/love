--removes the top element from focusStack
function cancel()
	table.remove(focusStack)
end

--redirects to other draw methods based on thing.type
function draw(thing)
	--validate for a sec
	if not thing then
		print("trying to draw nil")
		return
	elseif type(thing) ~= "table" then
		print("trying to draw a primitive value ("..type(thing)..")")
		return
	elseif not thing.type then
		print("trying to draw something with no type")
		return
	end
	
	if thing.type == "list menu" then
		--draw dat
		
		--also draw thing.sublayers? or leave that kind of thing up to ListMenu.draw(thing)?
	end
end