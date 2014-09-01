-- makes a class OR subclass if passed the name of the superclass
-- notes:
-- * all classes and subclasses must have _init() defined
-- * class instances are constructed simply as var = NewClass(stuff)
-- * if calling superclass methods, there is a difference between self.super:foo(bar) and self.super.foo(self,bar)! they look similar but behave differently!
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

-- NEVER PASS _G TO THIS (or any table containing pointers to itself)
function tablePrint(table, offset)
	offset = offset or "  "
	
	for k,v in pairs(table) do
		if type(v) == "table" then
			print(offset.."sub-table ["..k.."]:")
			tablePrint(v, offset.."  ")
		else
			print(offset.."["..k.."] = "..tostring(v))
		end
	end	
end

function ping(...)
	print("ping",unpack({...}))
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

---------------------------------------------------------------------------------------------------------------------
--so this works...
-- function stuff(arg, ...)
-- 	arr = {...}
--
-- 	for i=1,#arr do
-- 		print(arr[i])
-- 	end
-- end
-- stuff(1,2,3,4)