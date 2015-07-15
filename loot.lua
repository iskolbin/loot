local any = {}

local function nkeys( t )
	local len = 0
	for k, v in pairs( t ) do
		len = len + 1
	end
	return len
end

local function equal( x, y )
	if x == y or x == any or y == any then
		return true
	elseif type(x) == 'table' and type(y) == 'table' then
		if nkeys( x ) ~= nkeys( y ) then
			return false
		else
			for k, v in pairs( x ) do
				if y[k] == nil then
					return false
				elseif not equal( v, y[k] ) then
					return false
				end
			end
			return true
		end
	else
		return false
	end
end

local function isid( s )
	return type( s ) == 'string' and s:match('[%a_][%w_]*') == s
end

local op = {
	add = function( x, y ) return x + y end,
	sub = function( x, y ) return x - y end,
	div = function( x, y ) return x / y end,
	idiv = function( x, y ) if x >= 0 then return math.floor(x/y) else return math.ceil(x/y) end end,
	mul = function( x, y ) return x * y end,
	mod = function( x, y ) return x % y end,
	pow = function( x, y ) return x ^ y end,
	log = math.log,
	neg = function( x ) return -x end,
	len = function( x ) return #x end,
	inc = function( x ) return x + 1 end,
	dec = function( x ) return x - 1 end,
	concat = function( x, y ) return x .. y end,

	isid = isid,
	isnil = function( y ) return y == nil end,
	istrue = function( y ) return y == true end,
	isfalse = function( y ) return y == false end,
	isnumber = function( y ) return type( y ) == 'number' end,
	isstring = function( y ) return type( y ) == 'string' end,
	istable = function( y ) return type( y ) == 'table' end,
	isfunction = function( y ) return type( y ) == 'function' end,
	isthread = function( y ) return type( y ) == 'thread' end,
	isuserdata = function( y ) return type( y ) == 'userdata' end,
	isboolean = function( y ) return type( y ) == 'boolean' end,

	lor = function( x, y ) return x or y end,
	land = function( x, y ) return x and y end,
	lnot = function( x ) return not x end,

	gt = function( x, y ) return x >  y end,
	ge = function( x, y ) return x >= y end,
	lt = function( x, y ) return x <  y end,
	le = function( x, y ) return x <= y end,
	eq = function( x, y ) return x == y end,
	ne = function( x, y ) return x ~= y end,
	equal = equal,
}

local opc = {
	add = function( x ) return function( y ) return y + x end end,
	sub = function( x ) return function( y ) return y - x end end,
	div = function( x ) return function( y ) return y / x end end,
	idiv = function( x ) return function( y ) if y >= 0 then return math.floor(y/x) else return math.ceil(y/x) end end end,
	mul = function( x ) return function( y ) return y * x end end,
	mod = function( x ) return function( y ) return y % x end end,
	pow = function( x ) return function( y ) return y ^ x end end,
	expt = function( x ) return function( y ) return x ^ y end end,
	log = function( x ) return function( y ) return math.log( y, x ) end end,
	concatr = function( x ) return function( y ) return y .. x end end,
	concatl = function( x ) return function( y ) return x .. y end end,

	gt = function( x ) return function( y ) return y >  x end end,
	ge = function( x ) return function( y ) return y >= x end end,
	lt = function( x ) return function( y ) return y <  x end end,
	le = function( x ) return function( y ) return y <= x end end,
	eq = function( x ) return function( y ) return y == x end end,
	ne = function( x ) return function( y ) return y ~= x end end,
	equal = function( x ) return function( y ) return equal( x, y ) end end,
	c = function( x ) return function() return x end end,
}

local function compose( ... )
	local n = select( '#', ... )
	if n <= 1 then
		local f = ...
		return f
	elseif n == 2 then
		local f, g = ...
		return function(x) return g( f( x )) end
	elseif n == 3 then
		local f, g, h = ...
		return function(x) return h( g( f( x ))) end
	elseif n == 4 then
		local f, g, h, b = ...
		return function(x) return b( h( g( f( x )))) end
	elseif n == 5 then
		local f, g, h, b, q = ...
		return function(x) return q( b( h( g( f( x ))))) end
	else
		local f, g, h, b, q = ...
		local ff = {select(6,...)}
		local n_ = n - 5
		return function(x) 
			local y = q( b( h( g( f( x )))))
			for i = 1, n_ do y = ff[i](y) end
			return y
		end
	end
end

local function map( f, t )
	local t_ = {}
	for i = 1, #t do
		t_[i] = f( t[i], i )
	end
	return t_
end

local function each( f, t )
	for i = 1, #t do
		f( t[i], i )
	end
end

local function filter( f, t )
	local t_, j = {}, 0
	for i = 1, #t do
		if f( t[i], i ) then
			j = j + 1
			t_[j] = t[i]
		end
	end
	return t_
end

local function foldl( f, acc, t )
	local acc = acc or 0
	for i = 1, #t do
		acc = f( acc, t[i], i )
	end
	return acc
end

local function foldr( f, acc, t )
	local acc = acc or 0
	for i = #t, 1, -1 do
		acc = f( acc, t[i], i )
	end
	return acc
end

local function kvmap( f, t )
	local t_ = {}
	for k, v in pairs( t ) do
		t_[k] = f( v, k )
	end
	return t_
end

local function kveach( f, t )
	for k, v in pairs( t ) do
		f( v, k )
	end
end

local function kvfilter( f, t )
	local t_ = {}
	for k, v in pairs( t ) do
		if f( v, k ) then
			t_[k] = v
		end
	end
	return t_
end

local function kvreduce( f, acc, t )
	local acc = acc or 0
	for k, v in pairs( t ) do
		acc = f( acc, v, k )
	end
	return acc
end

local function sum( t, acc )
	local acc = acc or 0
	for i = 1, #t do
		acc = acc + t[i]
	end
	return acc
end

local function range( init, limit, step )
	local init, limit, step = init, limit, step or 1
	if not limit then
		init, limit = 1, init
	end
	local t, k = {}, 0
	for i = init, limit, step do
		k = k + 1
		t[k] = i
	end
	return t
end
	
local function slice( t, init, limit, step )
	local init, limit, step = init, limit, step or 1
	if not limit then
		init, limit = 1, init
	end

	if init < 0 then
		init = #t + init + 1
	end

	if limit < 0 then
		limit = #t + limit + 1
	end

	local t_, j = {}, 0
	for i = init, limit, step do
		j = j + 1
		t_[j] = t[i]
	end
	return t_
end

local function reverse( t )
	local t_, n = {}, #t
	for i = 1, n do
		t_[i] = t[n-i+1]
	end
	return t_
end

local function indexof( t, v, fcmp )
	if not fcmp then
		for i = 1, #t do
			if t[i] == v then
				return i
			end
		end
	else
		local function defaultcmp( a, b ) 
			return a < b 
		end
		local init, limit, mid = 1, #t, 0
		local f = type(fcmp) == 'function' and fcmp or defaultcmp
		local floor = math.floor
		while init <= limit do
			mid = floor( 0.5*(init+limit))
			local v_ = t[mid]
			if v == v_ then
				return mid
			elseif f( v, v_ ) then
				limit = mid - 1
			else
				init = mid + 1
			end
		end
	end
end

local function keyof( t, v )
	for k, v_ in pairs( t ) do
		if v_ == v then
			return k
		end
	end
end

local function topairs( t )
	local t_, j = {}, 0
	for k, v in pairs( t ) do
		j = j + 1
		t_[j] = {k,v}
	end
	return t_
end

local function frompairs( t )
	local t_ = {}
	for i = 1, #t do
		t_[t[i][1]] = t[i][2]
	end
	return t_
end

local function recflatten( t, v, i )
	if type( v ) == 'table' then
		for j = 1, #v do
			i = recflatten( t, v[j], i )
		end
	else
		i = i + 1
		t[i] = v
	end
	return i
end

local function flatten( t )
	local t_, j = {}, 0
	for i = 1, #t do
		j = recflatten( t_, t[i], j )
	end
	return t_
end

local function set( ... )
	local t = {}
	for i = 1, select( '#', ... ) do
		local k = select( i, ... )
		t[k] = true
	end
	return t
end

local function intersect( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do
		if t2[k] ~= nil then
			t[k] = v
		end
	end
	return t
end

local function union( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do
		t[k] = v
	end
	for k, v in pairs( t2 ) do
		t[k] = v
	end
	return t
end

local function difference( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do
		if t2[k] == nil then
			t[k] = v
		end
	end
	return t
end

local function diffclock( f, ... )
	local t = os.clock()
	f( ... )
	return os.clock() - t
end

local function ndiffclock( n, f, ... )
	local t = os.clock()
	for i = 1, n do
		f( ... )
	end
	return (os.clock() - t) / n 
end

local function diffmemory( f, ... )
	collectgarbage()
	local m = collectgarbage('count')
	f( ... )
	return 1024*(collectgarbage('count') - m)
end

local function shuffle( t, f )
	local f = f or math.random
	local t_ = {}
	local n = #t
	for i = 1, n do
		t_[i] = t[i]
	end
	for i = n, 1, -1 do
		local idx = f( i )
		t_[idx], t_[i] = t_[i], t_[idx]
	end
	return t_
end


local function serialize( v, tables, ident, identSymbol )
	local t_ = type( v )
	if t_ ~= 'table' then
		if t_ == 'string' then
			return ('%q'):format( v )
		else
			return tostring( v )
		end
	else
		if not tables[v] then
			tables.n = (tables.n or 0) + 1
			tables[v] = tables.n
			local buff = {}
			local arr = {}
			for i = 1, #v do
				arr[i] = true
				buff[i] = serialize( v[i], tables )
			end
			for k, vv in pairs( v ) do
				if not arr[k] then
					if isid( k ) then
						buff[#buff+1] = ('%s%s = %s'):format( ident and ('\n' .. (identSymbol or (' ')):rep(ident)) or '', k, serialize( vv, tables, ident and (ident + 1), identSymbol ))
					else
						buff[#buff+1] = ('%s[%s] = %s'):format( (ident and (identSymbol or (' ')):rep(ident)) or '', serialize( k, tables, ident, identSymbol ), serialize( vv, tables, ident, identSymbol ))
					end
				end
			end
			return '{' .. table.concat( buff, ', ' ) .. '}' 
		else
			return '__' .. tables[v]
		end
	end
end

local function xtostring( v, ident )
	return serialize( v, {}, ident or 1, '  ' )
end

local function pp( ... )
	local n = select( '#', ... )
	local x, pred
	for i = 1, n do
		pred = x
		x = select( i, ... )
		if type( x ) == 'table' and i > 1 then
			io.write( '\n' )
		end	
		io.write( xtostring( x ) )
		if i < n then
			io.write( type(x) == 'table' and '\n' or '\t' )
		end
	end
	io.write('\n')
end

local function copy( t )
	if type( t ) == 'table' then
		local t_ = {}
		for k, v in pairs( t ) do
			t_[k] = v
		end
		return t_
	else
		return t
	end
end

local function deepcopy( t, saved )
	local saved = saved or {}
	if type( t ) == 'table' then
		if not saved[t] then
			local t_ = {}
			for k, v in pairs( t ) do
				t_[deepcopy( k, saved )] = deepcopy( v, saved )
			end
			saved[t] = setmetatable( t_, getmetatable( t ))
			return t_
		else
			return saved[t]
		end
	else
		return t
	end
end

local function kvzip( t1, t2 )
	local t = {}
	for i = 1, math.min( #t1, #t2 ) do
		t[t1[i]] = t2[i]
	end
	return t
end

local function kvunzip( t )
	local t1, t2, i = {}, {}, 0
	for k, v in pairs( t ) do
		i = i + 1
		t1[i], t2[i] = k, v
	end
	return t1, t2
end

local function zip( ... )
	local n = select( '#', ... )
	local len = math.huge
	for i = 1, n do
		local a = select( i, ... )
		if #a < len then
			len = #a
		end
	end
	local t = {}
	for i = 1, len do
		t[i] = {}
	end
	for i = 1, len do
		for j = 1, n do
			local a = select( j, ... )
			t[i][j] = a[j]
		end
	end
	return t
end

local function zip( ... )
	local ts = { ... }
	local t = {}
	if ts[1] then
		local ncols, nrows = #ts, #ts[1]
		for i = 2, ncols do
			if #ts[i] < nrows then nrows = #ts[i] end
		end
		for i = 1, nrows do
			local t_ = {}
			for j = 1, ncols do
				t_[j] = ts[j][i]
			end
			t[i] = t_
		end
	end
	return t
end
	
local function unzip( t )
	local t_ = {}
	local unpack = table.unpack or unpack
	if #t > 0 and type( t[1] ) == 'table' then
		local n = #t[1]
		for i = 1, n do
			t_[i] = {}
		end
		for i = 1, n do
			for j = 1, #t do
				t_[i][j] = t[j][i]
			end
		end
	end
	return unpack( t_ )
end

local function traverse( t, f, level, key, saved )
	local level = level or 1
	local saved = saved or {}
	if type( t ) == 'table' and not saved[t] then
		saved[t] = t
		for k, v in pairs( t ) do
			local x = traverse( v, f, level + 1, k, saved ) 
			if x then
				return x
			end
		end
	else
		return f( t, key, level ) 
	end
end

local functions

local function export( ... )
	local n = select( '#', ... )
	if n == 0 then
		for k, v in pairs( functions ) do
			_G[k] = v
		end
	else
		for i = 1, n do
			local k = select( i, ... )
			_G[k] = functions[k]
		end
	end
end

functions = {
	any = any,
	op = op,
	opc = opc,
	equal = equal,
	compose = compose,
	kvmap = kvmap,
	kvfilter = kvfilter,
	map = map,
	filter = filter,
	
	kveach = kveach,
	each = each,
	traverse = traverse,
	
	kvreduce = kvreduce,
	foldl = foldl,
	foldr = foldr,
	sum = sum,

	range = range,
	slice = slice,
	reverse = reverse,
	shuffle = shuffle,
	
	nkeys = nkeys,
	indexof = indexof,
	keyof = keyof,
	
	keys = keys,
	values = values,

	set = set,
	intersect = intersect,
	difference = difference,
	union = union,
	
	copy = copy,
	deepcopy = deepcopy,
	
	topairs = topairs,
	frompairs = frompairs,
	flatten = flatten,
	kvzip = kvzip,
	kvunzip = kvunzip,
	zip = zip,
	unzip = unzip,
	
	diffclock = diffclock,
	ndiffclock = ndiffclock,
	diffmemory = diffmemory,
	
	serialize = serialize,
	xtostring = xtostring,
	pp = pp,

	export = export,
}

return functions
