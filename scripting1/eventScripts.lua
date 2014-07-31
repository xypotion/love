function loadScripts()
	foo = {}
	
	foo[1] = {
		bar = 0
		baz = "whatever"
		qux = {1,2,3,4}
	}
	
	foo[2] = {
		-- ...
	}
	
	-- like this, i guess. one file per array, then just include in main, call loadWhatever(), then call script events by number
		-- if these are just huge text files, they shouldn't take up tooooooo much memory...
		-- can script images with corresponding filenames and quads here too! whee (although each animated thing might get its own file)
		
	-- i guess common stuff like many objects that init the same way, or AI that all/most enemies perform can use common functions? to save space~! :o
	
	-- might wanna keep a "manifest" somewhere. top sounds nice, but bottom might actually be more practical
end