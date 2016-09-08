function makeDebugMenu()
	local debugMenu = ListMenu.new({x = canvasWidth / 20, y = canvasHeight / 15})
	
	debugMenu.w = canvasWidth / 3
	debugMenu.h = canvasHeight * 4 / 5
	
	debugMenu.options = {
		{
			label = "Particle effects!", enabled = true, 
			action = {func = "makeParticleMenu"}
		},
		{
			label = "test", enabled = true, 
			action = {func = "test", args = {"foo", "bar"}}
		},
		-- {
		-- 	label = "cancel", enabled = true,
		-- 	action = {func = "cancel"}
		-- },
	}
	
	debugMenu.h = #debugMenu.options * ListMenu.optionHeight * 2
	
	--TODO this shit ^^^ should not go here. use addParams inside .new
	
	table.insert(focusStack, debugMenu)
end

function makeParticleMenu(pos)
	local currentCursorY = focusStack[#focusStack].cursor.pos * 23 + 40
	print(currentCursorY)
	local menu = ListMenu.new(canvasWidth / 20 + 200, currentCursorY)
	
	menu.w = canvasWidth / 3
	menu.h = canvasHeight * 2 / 5
	
	menu.options = {
		{
			label = "Initialize", enabled = true, 
			action = {func = "initParticleTEST"}
		},
		{
			label = "throw snowball", enabled = true, 
			action = {func = "startFireball", args = {"ice"}}
		},
		{
			label = "throw fireball", enabled = true, 
			action = {func = "startFireball", args = {"fire"}}
		},
		{
			label = "make random emitter", enabled = true, 
			action = {func = "makeEmitter", args = {"random tame", 1}}
		},
		{
			label = "make random puffer", enabled = true, 
			action = {func = "makeEmitter", args = {"random tame", 1, {interval = 1, burstSize = 20}}}
		},
		{
			label = "remove last emitter", enabled = true, 
			action = {func = "removeLastEmitter"}
		},
		{
			label = "Done", enabled = true, 
			action = {func = "gfCancel"}
		},
	}
	
	table.insert(focusStack, menu)
end

------------------------------------------------------------------------------------------------------------------------------------

function test(args)
	tablePrint (args)
	for k,v in args do
		print(k,v)
	end
end