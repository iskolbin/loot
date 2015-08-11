local any = {}

local function swap( x, y )
	return y, x
end

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

local function isid( s )
	return type( s ) == 'string' and s:match('[%a_][%w_]*') == s
end

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

local function newtable( size )
	if not size or size <= 0 then return {}
	elseif size == 1 then return {false}
	elseif size == 2 then return {false,false}
	elseif size == 3 then return {false,false,false}
	elseif size == 4 then return {false,false,false,false}
	elseif size == 5 then return {false,false,false,false,false}
	elseif size == 6 then return {false,false,false,false,false,false}
	elseif size == 7 then return {false,false,false,false,false,false,false}
	elseif size >= 8 then 
		local t = {false,false,false,false,false,false,false,false}
		for i = 9,size do t[i] = false end
		return t
	end
end

local opc = {}
local op; op = {
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
	positive = function( x ) return x > 0 end,
	negative = function( x ) return x < 0 end,
	even = function( x ) return x % 2 == 0 end,
	odd = function( x ) return x % 2 == 1 end,
	index = function( x, y ) return x[y] end,
	item = function( x, y ) return y[x] end,
	equal = equal,
	const = function( x ) return x end,
	newtable = newtable,
	call = function( x, y ) return x( y ) end,
	fun = function( x, y ) return y( x ) end,
	selfcall = function( x, y ) return x[y](x) end,
	selffun = function( x, y ) return y[x](y) end,
	c = setmetatable( {}, {
		__index = function( self, k )
			if not opc[k] then
				opc[k] = memoize( function( x ) local f = op[k]; return function( y ) return f(y,x) end end, 'kv' )
			end
			return opc[k]
		end,
	})
}

local cand = function( x, y )
	return function( ... ) return x(...) and y(...) end
end

local cor = function( x, y )
	return function( ... ) return x(...) or y(...) end
end

local cnot = function( x )
	return function( ... ) return not x( ... ) end
end

local function append( t1, t2, inplace )
	local t, n = inplace and t1 or copy(t1), #t1
	for i = 1, #t2 do t[i+n] = t2[i] end
	return t
end

local function prepend( t1, t2, inplace )
	local n, m = #t1, t2
	if inplace then
		for i = n+1, n+m do t1[i] = false end
		for i = n+m, n+1, -1 do t1[i] = t1[i-m] end
		for i = 1, m do t1[i] = t2[i] end
		return t1
	else
		local t = copy( t2 )
		for i = 1, n do t[i+m] = t1[i] end
		return t
	end
end

local function curry( f, ... )
	local n = select( '#', ... )
	if n <= 0 then return f
	elseif n == 1 then local x1 = ...; return function(x) return f( x,x1 ) end
	elseif n == 2 then local x1,x2 = ...; return function(x) return f( x,x1,x2 ) end
	elseif n == 3 then local x1,x2,x3 = ...; return function(x) return f( x,x1,x2,x3 ) end
	elseif n == 4 then local x1,x2,x3,x4 = ...; return function(x) return f( x,x1,x2,x3,x4 ) end
	elseif n == 5 then local x1,x2,x3,x4,x5 = ...; return function(x) return f( x,x1,x2,x3,x4,x5 ) end
	elseif n == 6 then local x1,x2,x3,x4,x5,x6 = ...; return function(x) return f( x,x1,x2,x3,x4,x5,x6 ) end
	elseif n == 7 then local x1,x2,x3,x4,x5,x6,x7 = ...; return function(x) return f( x,x1,x2,x3,x4,x5,x6,x7 ) end
	elseif n == 8 then local x1,x2,x3,x4,x5,x6,x7,x8 = ...; return function(x) return f( x,x1,x2,x3,x4,x5,x6,x7,x8 ) end
	else error( 'currying max up to only to 8 arg supported, sorry' )
	end
end

local function compose( fs )
	local n = #fs
	if n <= 1 then return fs[1]
	elseif n == 2 then local f1,f2 = fs[1],fs[2]; return function(...) return f2(f1(...))end
	elseif n == 3 then local f1,f2,f3 = fs[1],fs[2],fs[3]; return function(...) return f3(f2( f1(...)))end
	elseif n == 4 then local f1,f2,f3,f4 = fs[1],fs[2],fs[3],fs[4]; return function(...) return f4(f3(f2( f1(...))))end
	else
		local f1,f2,f3,f4,f5 = fs[1],fs[2],fs[3],fs[4],fs[5]
		if n <= 5 then return function(...) return f5(f4(f3(f2(f1(...))))) end
		else return function(...) 
			local y = f5(f4(f3(f2(f1(...)))))
			for i = 6, n-5 do y = fs[i](y) end
			return y
		end end
	end
end

local function map( t, f, mode )
	local t_
	if not mode or mode == '' then
		t_ = {}; for i = 1, #t do t_[i] = f( t[i] ) end
	elseif mode == 'v' then
		t_ = {}; for k, v in pairs( t ) do t_[k] = f( v ) end
	elseif mode == '!' then
		for i = 1, #t do t[i] = f( t[i] ) end
	elseif mode == 'i' then
		t_ = {}; for i = 1, #t do t_[i] = f( t[i], i ) end
	elseif mode == 'i!' then
		for i = 1, #t do t_[i] = f( t[i], i ) end
	elseif mode == 'v!' then
		for k, v in pairs( t ) do t[k] = f( v ) end
	elseif mode == 'vk' then
		t_ = {}; for k, v in pairs( t ) do t_[k] = f( v, k ) end
	elseif mode == 'vk!' then
		for k, v in pairs( t ) do t[k] = f( v, k ) end
	elseif mode == 'k' then
		t_ = {}; for k, v in pairs( t ) do t_[k] = f( k ) end
	elseif mode == 'k!' then
		for k, v in pairs( t ) do t[k] = f( k ) end
	elseif mode == 'kv' then
		t_ = {}; for k, v in pairs( t ) do t_[k] = f( k, v ) end
	elseif mode == 'kv!' then
		for k, v in pairs( t ) do t[k] = f( k, v ) end
	else
		error( 'mode(3rd parameter) have to be nil or one of "!", "i", "i!", "k", "k!", "v", "v!", "kv", "kv!", "vk", "vk!"')
	end
	return t_ or t
end

local function each( t, f, mode )
	if not mode or mode == '' then
		for i = 1, #t do f( t[i] ) end
	elseif mode == 'v' then
		for k, v in pairs( t ) do f( v ) end
	elseif mode == 'i' then
		for i = 1, #t do f( t[i], i ) end
	elseif mode == 'vk' then
		for k, v in pairs do f( v, k ) end
	elseif mode == 'k' then
		for k, v in pairs( t ) do f( k ) end
	elseif mode == 'kv' then
		for k, v in pairs( t ) do f( k, v ) end
	else
		error( 'mode(3rd parameter) have to be nil or one of "i", "k", "v", "kv", "vk"')
	end
end

local function filter( t, f, mode )
	local t_
	local j = 0
	if not mode or mode == '' then
		t_ = {}; for i = 1, #t do if f( t[i] ) then j = j + 1; t_[j] = t[i] end end
	elseif mode == 'v' then
		t_ = {}; for k, v in pairs( t ) do if f( v ) then t_[k] = v end end
	elseif mode == '!' then
		for i = 1, #t do if f( t[i] ) then j = j + 1; t[j] = t[i] end end
		for i = j+1, #t do t[i] = nil end
	elseif mode == 'i' then
		t_ = {}; for i = 1, #t do if f( t[i], i ) then j = j + 1; t_[j] = t[i] end end
	elseif mode == 'i!' then
		for i = 1, #t do if f( t[i], i ) then j = j + 1; t[j] = t[i] end end
		for i = j+1, #t do t[i] = nil end
	elseif mode == 'v!' then
		for k, v in pairs( t ) do if not f( v ) then t[k] = nil end end
	elseif mode == 'vk' then
		t_ = {}; for k, v in pairs( t ) do if f( v, k ) then t_[k] = v end end
	elseif mode == 'vk!' then
		for k, v in pairs( t ) do if not f( v, k ) then t[k] = v end end
	elseif mode == 'k' then
		t_ = {}; for k, v in pairs( t ) do if f( k ) then t_[k] = v end end
	elseif mode == 'k!' then
		for k, v in pairs( t ) do if not f( k ) then t[k] = nil end end
	elseif mode == 'kv' then
		t_ = {}; for k, v in pairs( t ) do if f( k, v ) then t_[k] = v end end
	elseif mode == 'kv!' then
		for k, v in pairs( t ) do if not f( k, v ) then t[k] = v end end
	else
		error( 'mode(3rd parameter) have to be nil or one of "!", "i", "i!", "k", "k!", "v", "v!", "kv", "kv!", "vk", "vk!"')
	end	
	return t_ or t
end

local function reduce( t, f, acc, mode )
	local acc = acc or 0
	if not mode or mode == 'l' then
		for i = 1, #t do acc = f( acc, t[i] ) end
	elseif mode == 'v' then
		for k, v in pairs( t ) do acc = f( acc, v ) end
	elseif mode == 'i' or mode == 'li' then
		for i = 1, #t do acc = f( acc, t[i], i ) end
	elseif mode == 'vk' then
		for k, v in pairs( t ) do acc = f( acc, v, k ) end
	elseif mode == 'r' then
		for i = #t, 1, -1 do acc = f( acc, t[i] ) end
	elseif mode == 'ri' then
		for i = #t, 1, -1 do acc = f( acc, t[i], i ) end
	elseif mode == 'k' then
		for k, v in pairs( t ) do acc = f( acc, k ) end
	elseif mode == 'kv' then
		for k, v in pairs( t ) do acc = f( acc, k, v ) end
	end
	return acc
end

local function sum( t, acc )
	local acc = acc or 0
	for i = 1, #t do acc = acc + t[i] end
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

local RangeMT = {
	__index = function( self, k ) return self.i + self.s*(k-1) end,
	__len   = function( self ) return self.l end,
}

local function xrange( init, limit, step )
	local init, limit, step = init, limit, step or 1
	if not limit then
		init, limit = 1, init
	end
	return setmetatable( {i = init,l = 1+math.floor((limit-init)/step),s = step}, RangeMT )
end

local function slice( t, init, limit, step )
	local init, limit, step = init, limit or #t, step or 1

	if init < 0 then init = #t + init + 1 end
	if limit < 0 then limit = #t + limit + 1 end

	local t_, j = {}, 0
	for i = init, limit, step do
		j = j + 1
		t_[j] = t[i]
	end
	return t_
end

local function inject( t1, t2, pos )
	local pos = pos < 0 and #t1 + pos + 1 or pos
	if pos <= 1 then return append( t2, t1 )
	elseif pos >= #t1 then return append( t1, t2 )
	else return append( append( slice( t1, pos-1 ), t2 ), slice( t1, pos, -1 ))
	end
end

local function reverse( t )
	local t_, n = {}, #t
	for i = 1, n do t_[i] = t[n-i+1] end
	return t_
end

local function sorted( t, f, inplace )
	local t_ = inplace and t or copy( t, true )
	table.sort( t_, f )
	return t_ 
end

local function indexof( t, v, fcmp )
	if not fcmp then
		for i = 1, #t do
			if t[i] == v then return i end
		end
	else
		local function defaultcmp( a, b ) 
			return a < b 
		end
		local init, limit = 1, #t, 0
		local f = type(fcmp) == 'function' and fcmp or defaultcmp
		local floor = math.floor
		while init <= limit do
			local mid = floor( 0.5*(init+limit))
			local v_ = t[mid]
			if v == v_ then return mid
			elseif f( v, v_ ) then limit = mid - 1
			else init = mid + 1
			end
		end
	end
end

local function keyof( t, v )
	for k, v_ in pairs( t ) do
		if v_ == v then return k end
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

local function shuffle( t, f, inplace )
	local f = f or math.random
	local n = #t
	local t_ = inplace and t or copy( t ) 
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
		elseif t_ == 'function' then
			return ('loadstring(%q)'):format( string.dump( v ))
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

local function copy( t, arrayfor )
	if type( t ) == 'table' then
		local t_ = {}
		if arrayfor then
			for i = 1, #t do t_[i] = t[i] end
		else
			for k, v in pairs( t ) do t_[k] = v end
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

local function ncombinations( ts, n )
	local m, t, acc = #ts, {}, {}

	local function reccombine( i )
		if #t >= n then
			acc[#acc+1] = copy( t )
		else
			for j = i, m do
				t[#t+1] = ts[j]
				reccombine( j + 1 )
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

local function count( t )
	local t_ = {}
	for i = 1, #t do
		local v = t[i]
		t_[v] = (t_[v] or 0) + 1
	end
	return t_
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
	local unpack = table.unpack or unpack
	local n = select( '#', ... )
	if n == 0 then
		for k, v in pairs( functions ) do	_G[k] = v end
	else
		local f = {}
		for i = 1, n do
			f[i] = functions[select( i, ... )]
		end
		return unpack( f )
	end
end


functions = {
	any = any,
	op = op,
	equal = equal,
	curry = curry,
	compose = compose,
	cand = cand,
	cor = cor,
	cnot = cnot,
	swap = swap,

	map = map,
	each = each,
	filter = filter,
	reduce = reduce,
	sum = sum,
	count = count,

	traverse = traverse,
	newtable = newtable,

	range = range,
	xrange = xrange,
	slice = slice,
	append = append,
	prepend = prepend,
	inject = inject,
	reverse = reverse,
	shuffle = shuffle,
	
	nkeys = nkeys,
	indexof = indexof,
	keyof = keyof,
	sorted = sorted,
	
	keys = keys,
	values = values,

	set = set,
	intersect = intersect,
	difference = difference,
	union = union,
	
	permutations = permutations,
	combinations = combinations,
	ncombinations = ncombinations,

	unique = unique,

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
