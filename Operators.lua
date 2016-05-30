local Operators = {
	add = function( x, y ) return x + y end,
	sub = function( x, y ) return x - y end,
	div = function( x, y ) return x / y end,
	idiv = function( x, y ) if x >= 0 then return math.floor(x/y) else return math.ceil(x/y) end end,
	mul = function( x, y ) return x * y end,
	mod = function( x, y ) return x % y end,
	pow = function( x, y ) return x ^ y end,
	expt = function( x, y ) return y ^ x end,
	log = math.log,
	neg = function( x ) return -x end,
	
	len = function( x ) return #x end,
	
	inc = function( x ) return x + 1 end,
	dec = function( x ) return x - 1 end,
	
	concat = function( x, y ) return x .. y end,
	lconcat = function( x, y ) return y .. x end,
	
	lor = function( x, y ) return x or y end,
	land = function( x, y ) return x and y end,
	lnot = function( x ) return not x end,
	
	gt = function( x, y ) return x >  y end,
	ge = function( x, y ) return x >= y end,
	lt = function( x, y ) return x <  y end,
	le = function( x, y ) return x <= y end,
	eq = function( x, y ) return x == y end,
	ne = function( x, y ) return x ~= y end,
	
	index = function( x, y ) return x[y] end,
	newindex = function( x, y, z ) x[y] = z end,
	
	const = function( x ) return x end,
	call = function( x, y ) return x( y ) end,
	swap = function( x, y ) return y, x end,

	iszero = function( x ) return x == 0 end,
	iseven = function( x ) return x % 2 == 0 end,
	isodd = function( x ) return x % 2 == 1 end,
	ispositive = function( x ) return x % 2 > 0 end,
	isnegative = function( x ) return x % 2 < 0 end,
	isnan = function( x ) return x ~= x end,
	isnil = function( x ) return x == nil end,
	isboolean = function( x ) return x == true or x == false end,
	isnumber = function( x ) return type(x) == 'number' end,
	isstring = function( x ) return type(x) == 'string' end,
	istable = function( x ) return type(x) == 'table' end,
	isuserdata = function( x ) return type(x) == 'userdata' end,
	isthread = function( x ) return type(x) == 'thread' end,
	isfunction = function( x ) return type(x) == 'function' end,

	cnot = function( f ) return function( ... ) return not f( ... ) end end,
	cand = function( f, g ) return function( ... ) return f( ... ) and g( ... ) end end,
	cor = function( f, g ) return function( ... ) return f( ... ) or g( ... ) end end,
}

local cache = {}

Operators.c = setmetatable( {}, {__index = function( self, k )
	local op = Operators[k]
	if not op then
		error( 'Operator not registred: ' .. tostring(op))
	else
		local c = cache[k]
		if not c then
			c = setmetatable( {}, {__mode = 'kv', __call = function( cself, v )
				if not cself[v] then
					cself[v] = function(x)
						return op( x, v ) 
					end
				end
				return cself[v]
			end} )
			cache[k] = c
		end
		return c
	end
end} )

return Operators
