-- makes a class OR subclass if passed the name of the superclass
-- notes:
-- * all classes and subclasses must have _init() defined
-- * class instances are constructed simply as var = NewClass(stuff)
-- * if calling superclass methods, there is a difference between self.super:foo(bar) and self.super.foo(self,bar)! they look similar but behave differently!
math.randomseed(os.time())

function class(base)
	local cls = {}
	cls.__index = cls

	if base then
		setmetatable(cls, {
			__index = base,
			__call = function (cls, ...)
				local self = setmetatable({}, cls)
				self:_init(...)
				return self
			end,
		})
		
		cls.super = base
	else
		setmetatable(cls, {
			-- __index = base,
			__call = function (cls, ...)
				local self = setmetatable({}, cls)
				self:_init(...)
				return self
			end,
		})
	end
	
	return cls
end

function round(num)
	return math.floor(num + 0.5)
end

-- NEVER PASS _G TO THIS (or any table containing pointers to itself)
function tablePrint(table, offset)
	offset = offset or "  "
	
	for k,v in pairs(table) do
		if type(v) == "table" then
			if next(v) then
				print(offset..""..k.." = {")
				tablePrint(v, offset.."  ")
				print(offset.."}")
			else
				print(offset..""..k.." = {}")
			end
		elseif type(v) == "string" then
			print(offset..k.." = ".."\""..v.."\"")
		else
			print(offset..""..k.." = "..tostring(v))
		end
	end	
end

function ping(...)
	print("--ping",unpack({...}))
end

-- prints non-function values in _G whose keys contain str, or prints all non-function values if str not provided
function showGlobals(str)	
	for k,v in pairs(_G) do
		if not (type(v) == "function") then
			if str then
				if k:find(str) then
					print(k,v)
				end
			else
				print(k,v)
			end
		end
	end
end

--so this works...
-- function stuff(arg, ...)
-- 	arr = {...}
--
-- 	for i=1,#arr do
-- 		print(arr[i])
-- 	end
-- end
-- stuff(1,2,3,4)

---------------------------------------------------------------------------------------------------------------------

function sample(t)
	-- math.randomseed(os.time())
	return t[math.random(1, #t)]
end

-- sampleMe = {11,22,33,44,55,66,77,88,99}
-- for i = 1, 20 do
-- 	print(sample(sampleMe))
-- end
--
-- tablePrint({44,2,4})


function shuffle(t)
	-- ping()
	local input = clone(t)
	-- print( input)
	local out = {}
	
	for i = 1, #input do
		out[i] = table.remove(input, math.random(1, #input))
	end
	
	return out
	-- t = out
end

-- foo = {2,3,4,5,6}
--
-- tablePrint(foo)
-- bar = shuffle(foo)
-- tablePrint(bar)
-- ping()
-- tablePrint(foo)


--clones a given object shallowly, i.e. table references stored as values in original object (not keys) will point to the SAME table in both the original and the clone.
function clone(original)
	local new = {}
	
	if type(original) == "table" then
		for key,value in pairs(original) do
			new[key] = value
		end
	else
		new = original
	end
	
	return new
end

--clones a given object deeply, i.e. all values in original's sub-tables are cloned to an entirely new but, identical table.
--...the question is whether or not this will work with classes. :S TODO figure it out! luckily you probably won't need to for Megapixel.
function deepclone(original)
	local new = {}
	
	if type(original) == "table" then
		for key,value in pairs(original) do
			new[key] = deepclone(value)--value
		end
	else
		new = original
	end
	
	return new
end


-- cloneme = {11,22,33,a=44,b=55,c={6,7},d={x=8,y=9,z=0}}
-- copy = clone(cloneme)
-- copy2 = deepclone(cloneme)
--
-- cloneme[1] = -999
-- cloneme.d.x = -999
--
-- ping("cloneme")
-- tablePrint(cloneme)
-- ping("copy")
-- tablePrint(copy)
-- ping("copy2")
-- tablePrint(copy2)