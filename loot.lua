local any = {}

local function nkeys( t )
	local len = 0
	for k, v in pairs( t ) do len = len + 1 end
	return len
end

local function equal( x, y )
	if x == y or x == any or y == any then
		return true
	elseif type(x) == 'table' and type(y) == 'table' and nkeys( x ) == nkeys( y ) then
		for k, v in pairs( x ) do
			if y[k] == nil or not equal( v, y[k] ) then
				return false
			end
		end
		return true
	else
		return false
	end
end

--[[
local typespriority = {
	['nil'] = 1,
	['boolean'] = 2,
	['number'] = 3,
	['function'] = 4,
	['userdata'] = 5,
	['thread'] = 6,
	['string'] = 7,
	['table'] = 8,
}

local typecompare; typecompare = {
	['nil'] = function( a, b ) return 0 end,
	['boolean'] = function( a, b ) if a == b then return 0 elseif a then return 1 else return -1 end end,
	['number'] = function( a, b ) return a == b and 0 or a > b and 1 or -1 end,
	['function'] = function( a, b ) return a == b and 0 or typecompare.string( tostring(a), tostring(b)) end,
	['userdata'] = function( a, b ) return a == b and 0 or typecompare.string( tostring(a), tostring(b)) end,
	['thread'] = function( a , b ) return a == b and 0 or typecompare.string( tostring(a), tostring(b)) end,
	['string'] = function( a, b ) return a == b and 0 or a > b and 1 or -1 end,
	['table'] = function( a, b ) return a == b and 0 or typecompare.string( tostring(a), tostring(b)) end,
}

local function deepsort( t )
	local function kvcompare( a, b )
		local ta, tb = typespriority[type( a )], typespriority[type( b )]
		if ta > tb then
			return 1
		elseif ta < tb then
			return -1
		else
			return typecompare( a, b )
		end
	end
end

local function equal( x, y )
	if x == y or x == any or y == any then
		return true
	elseif type(x) == 'table' and type(y) == 'table' and nkeys( x ) == nkeys( y ) then
		local kv1, kv2 = {}, {}
		for k, v in pairs( x ) do kv1[#kv1+1] = {k,v} end
		for k, v in pairs( y ) do kv2[#kv2+1] = {k,v} end
		table.sort( kv1, typecompare )
		table.sort( kv2, typecompare )
		return false
	end
end
--]]

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
	isnotnil = function( y ) return y ~= nil end,
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

	eq0 = function( x ) return x == 0 end,
	ne0 = function( x ) return x ~= 0 end,
	positive = function( x ) return x > 0 end,
	negative = function( x ) return x < 0 end,
	even = function( x ) return x % 2 == 0 end,
	odd = function( x ) return x % 2 == 1 end,

	equal = equal,
}

local memoize = function( closure, mode )
	local cache
	cache = setmetatable( {}, {
		__mode = mode, 
		__index = function( self, v )
			local f = closure( v )
			cache[v] = f
			return f
		end,
		__call = function( self, v )
			return cache[v]
		end,
	} )
	return cache
end

local opc = {
	add = memoize( function( x ) return function( y ) return y + x end end, 'kv' ),
	sub = memoize( function( x ) return function( y ) return y - x end end, 'kv' ),
	div = memoize( function( x ) return function( y ) return y / x end end, 'kv' ),
	idiv = memoize( function( x ) return function( y ) if y >= 0 then return math.floor(y/x) else return math.ceil(y/x) end end end, 'kv' ),
	mul = memoize( function( x ) return function( y ) return y * x end end, 'kv' ),
	mod = memoize( function( x ) return function( y ) return y % x end end, 'kv' ),
	pow = memoize( function( x ) return function( y ) return y ^ x end end, 'kv' ),
	expt = memoize( function( x ) return function( y ) return x ^ y end end, 'kv' ),
	log = memoize( function( x ) return function( y ) return math.log( y, x ) end end, 'kv' ),
	concatr = memoize( function( x ) return function( y ) return y .. x end end, 'kv' ),
	concatl = memoize( function( x ) return function( y ) return x .. y end end, 'kv' ),

	lor = memoize( function( x )  return function( y ) return y or x end end, 'kv' ),
	land = memoize( function( x ) return function( y ) return y and x end end, 'kv' ),
	lnot = memoize( function( x ) return function() return not x end end, 'kv' ),

	fnot = memoize( function( x ) return function( y ) return not x( y ) end end, 'kv' ),
	fand = function( x, y ) return function( z ) return x( z ) and y( z ) end end,
	fnor = function( x, y ) return function( z ) return x( z ) or  y( z ) end end,

	gt = memoize( function( x ) return function( y ) return y >  x end end, 'kv' ),
	ge = memoize( function( x ) return function( y ) return y >= x end end, 'kv' ),
	lt = memoize( function( x ) return function( y ) return y <  x end end, 'kv' ),
	le = memoize( function( x ) return function( y ) return y <= x end end, 'kv' ),
	eq = memoize( function( x ) return function( y ) return y == x end end, 'kv' ),
	ne = memoize( function( x ) return function( y ) return y ~= x end end, 'kv' ),
	equal = memoize( function( x ) return function( y ) return equal( x, y ) end end, 'kv' ),
	c = memoize( function( x ) return function() return x end end, 'kv' ),
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
	for i = 1, #t do t_[i] = f( t[i] ) end
	return t_
end

local function mapin( f, t )
	for i = 1, #t do t[i] = f( t[i] ) end
	return t
end

local function each( f, t )
	for i = 1, #t do f( t[i] ) end
end

local function filter( f, t )
	local t_, j = {}, 0
	for i = 1, #t do
		if f( t[i] ) then
			j = j + 1
			t_[j] = t[i]
		end
	end
	return t_
end

local function foldl( f, acc, t )
	local acc = acc or 0
	for i = 1, #t do acc = f( acc, t[i] ) end
	return acc
end

local function foldr( f, acc, t )
	local acc = acc or 0
	for i = #t, 1, -1 do acc = f( acc, t[i] ) end
	return acc
end

local function sum( t, acc )
	local acc = acc or 0
	for i = 1, #t do acc = acc + t[i] end
	return acc
end

local function imap( f, t )
	local t_ = {}
	for i = 1, #t do t_[i] = f( t[i], i ) end
	return t_
end

local function imapin( f, t )
	for i = 1, #t do t[i] = f( t[i], i ) end
	return t
end

local function ieach( f, t )
	for i = 1, #t do f( t[i], i ) end
end

local function ifilter( f, t )
	local t_, j = {}, 0
	for i = 1, #t do
		if f( t[i], i ) then
			j = j + 1
			t_[j] = t[i]
		end
	end
	return t_
end

local function ifoldl( f, acc, t )
	local acc = acc or 0
	for i = 1, #t do acc = f( acc, t[i], i ) end
	return acc
end

local function ifoldr( f, acc, t )
	local acc = acc or 0
	for i = #t, 1, -1 do acc = f( acc, t[i], i ) end
	return acc
end

local function kvmap( f, t )
	local t_ = {}
	for k, v in pairs( t ) do t_[k] = f( k, v ) end
	return t_
end

local function kvmapin( f, t )
	for k, v in pairs( t ) do t[k] = f( k, v ) end
	return t
end

local function kveach( f, t )
	for k, v in pairs( t ) do f( k, v ) end
end

local function kvfilter( f, t )
	local t_ = {}
	for k, v in pairs( t ) do
		if f( k, v ) then t_[k] = v end
	end
	return t_
end

local function kvfilterin( f, t )
	for k, v in pairs( t ) do
		if not f( k, v ) then t[k] = nil end
	end
	return t
end

local function kvreduce( f, acc, t )
	local acc = acc or 0
	for k, v in pairs( t ) do acc = f( acc, k, v ) end
	return acc
end

local function vkmap( f, t )
	local t_ = {}
	for k, v in pairs( t ) do t_[k] = f( v, k ) end
	return t_
end

local function vkmapin( f, t )
	for k, v in pairs( t ) do t[k] = f( v, k ) end
	return t
end

local function vkeach( f, t )
	for k, v in pairs( t ) do f( v, k ) end
end

local function vkfilter( f, t )
	local t_ = {}
	for k, v in pairs( t ) do
		if f( v, k ) then t_[k] = v end
	end
	return t_
end

local function vkfilterin( f, t )
	for k, v in pairs( t ) do
		if not f( v, k ) then t[k] = nil end
	end
	return t
end

local function vkreduce( f, acc, t )
	local acc = acc or 0
	for k, v in pairs( t ) do acc = f( acc, v, k ) end
	return acc
end

local function vmap( f, t )
	local t_ = {}
	for k, v in pairs( t ) do t_[k] = f( v ) end
	return t_
end

local function vmapin( f, t )
	for k, v in pairs( t ) do t[k] = f( v ) end
	return t
end

local function veach( f, t )
	for k, v in pairs( t ) do f( v ) end
end

local function vfilter( f, t )
	local t_ = {}
	for k, v in pairs( t ) do
		if f( v ) then t_[k] = v end
	end
	return t_
end

local function vfilterin( f, t )
	for k, v in pairs( t ) do
		if not f( v ) then t[k] = nil end
	end
	return t
end

local function vreduce( f, acc, t )
	local acc = acc or 0
	for k, v in pairs( t ) do acc = f( acc, v ) end
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
	for i = 1, n do t_[i] = t[n-i+1] end
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
	for i = 1, #t do t_[t[i][1]] = t[i][2] end
	return t_
end


local function flatten( t )
	local function recflatten( t, v, i )
		if type( v ) == 'table' then
			for j = 1, #v do i = recflatten( t, v[j], i ) end
		else
			i = i + 1
			t[i] = v
		end
		return i
	end

	local t_, j = {}, 0
	for i = 1, #t do j = recflatten( t_, t[i], j ) end
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
		if t2[k] ~= nil then t[k] = v end
	end
	return t
end

local function union( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do t[k] = v end
	for k, v in pairs( t2 ) do t[k] = v end
	return t
end

local function difference( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do
		if t2[k] == nil then t[k] = v end
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
	for i = 1, n do f( ... ) end
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
	for i = 1, n do t_[i] = t[i] end
	for i = n, 1, -1 do
		local idx = f( i )
		t_[idx], t_[i] = t_[i], t_[idx]
	end
	return t_
end

local function shufflein( t, f )
	local f = f or math.random
	for i = #t, 1, -1 do
		local idx = f( i )
		t[idx], t[i] = t[i], t[idx]
	end
	return t
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

local function acopy( t )
	if type( t ) == 'table' then
		local t_ = {}
		for i = 1, #t do
			t_[i] = t[i]
		end
		return t_
	else
		return t
	end
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
	for i = 1, math.min( #t1, #t2 ) do t[t1[i]] = t2[i] end
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
	local ts = { ... }
	local t = {}
	if ts[1] then
		local ncols, nrows = #ts, #ts[1]
		for i = 2, ncols do
			if #ts[i] < nrows then nrows = #ts[i] end
		end
		for i = 1, nrows do
			local t_ = {}
			for j = 1, ncols do t_[j] = ts[j][i] end
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
		for i = 1, n do t_[i] = {} end
		for i = 1, n do
			for j = 1, #t do t_[i][j] = t[j][i] end
		end
	end
	return unpack( t_ )
end

local function permutations( input )
	local out, used, n, level, acc = {}, {}, #input, 1, {}
	local function recpermute( level )
		if level <= n then
			for i = 1, n do
				if not used[i] then
					used[i] = true
					out[#out+1] = input[i]
					recpermute( level+1 )
					used[i] = false
					out[#out] = nil
				end
			end
		else
			local t = {}
			for i = 1, n do t[i] = out[i] end
			acc[#acc+1] = t
		end
		return acc
	end
	return recpermute( 1 )
end

local function combinations( ts )
	local n, t, acc = #ts, {}, {}

	local function reccombine( i )
		if i > n then
			acc[#acc+1] = copy( t )
		else
			local c = ts[i]
			for j = 1, #c do
				t[#t+1] = c[j]
				reccombine( i+1 )
				t[#t] = nil
			end
		end
	end
	reccombine( 1 )
	return acc
end

local function unique( t )
	local enc, out, k = {}, {}, 0
	for i = 1, #t do
		local e = t[i]
		if not enc[e] then
			enc[e] = true
			k = k + 1
			out[k] = e
		end
	end
	return out
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
	
	map = map,
	mapin = mapin,
	each = each,
	filter = filter,
	foldl = foldl,
	foldr = foldr,
	sum = sum,

	imap = imap,
	imapin = imapin,
	ieach = ieach,
	ifilter = ifilter,
	ifoldl = ifoldl,
	ifoldr = ifoldr,

	vmap = vmap,
	vmapin = vmapin,
	veach = veach,
	vfilter = vfilter,
	vfilterin = vfilterin,
	vreduce = vreduce,
	
	vkmap = vkmap,
	vkmapin = vkmapin,
	vkeach = vkeach,
	vkfilter = vkfilter,
	vkfilterin = vkfilterin,
	vkreduce = vkreduce,
	
	kvmap = kvmap,
	kvmapin = kvmapin,
	kveach = kveach,
	kvfilter = kvfilter,
	kvfilterin = kvfilterin,
	kvreduce = kvreduce,

	traverse = traverse,

	range = range,
	slice = slice,
	reverse = reverse,
	shuffle = shuffle,
	shufflein = shufflein,
	
	nkeys = nkeys,
	indexof = indexof,
	keyof = keyof,
	
	keys = keys,
	values = values,

	set = set,
	intersect = intersect,
	difference = difference,
	union = union,
	permutations = permutations,
	combinations = combinations,

	unique = unique,

	acopy = acopy,
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

	memoize = memoize,
}

return functions
