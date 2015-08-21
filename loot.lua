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

local function memoize( closure, mode )
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

local function newtable( size, init )
	local init = init or false
	if not size or size <= 0 then return {}
	elseif size == 1 then return {init}
	elseif size == 2 then return {init,init}
	elseif size == 3 then return {init,init,init}
	elseif size == 4 then return {init,init,init,init}
	elseif size == 5 then return {init,init,init,init,init}
	elseif size == 6 then return {init,init,init,init,init,init}
	elseif size == 7 then return {init,init,init,init,init,init,init}
	elseif size >= 8 then 
		local t = {init,init,init,init,init,init,init,init}
		for i = 9,size do t[i] = init end
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

local function cand( x, y )
	return function( ... ) return x(...) and y(...) end
end

local function cor( x, y )
	return function( ... ) return x(...) or y(...) end
end

local function cnot( x )
	return function( ... ) return not x( ... ) end
end

local function append( t1, t2, inplace )
	local t, n = inplace and t1 or deepcopy(t1), #t1
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
		local t = deepcopy( t2 )
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
	elseif n == 3 then local f1,f2,f3 = fs[1],fs[2],fs[3]; return function(...) return f3(f2(f1(...)))end
	elseif n == 4 then local f1,f2,f3,f4 = fs[1],fs[2],fs[3],fs[4]; return function(...) return f4(f3(f2(f1(...))))end
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

local function pipe( x, ... )
	local y = x
	for i = 1, select( '#', ... ) do
		local f = select( i, ... )
		local tf = type( f )
		if tf == 'table' then y = f[1](y, table.unpack(f,2))
		elseif tf == 'function' then y = f(y)
		else error( 'pipe arguments have to be unary functions or tables {f,arg2,arg3,...}')
		end
	end
	return y
end


local function map( t, f )   local t_ = {}; for i = 1, #t do t_[i] = f( t[i] ) end return t_ end
local function imap( t, f )  local t_ = {}; for i = 1, #t do t_[i] = f( t[i], i ) end return t_ end
local function vmap( t, f )  local t_ = {}; for k,v in pairs( t ) do t_[k] = f( v ) end return t_ end
local function kmap( t, f )  local t_ = {}; for k,v in pairs( t ) do t_[k] = f( k ) end return t_ end
local function kvmap( t, f ) local t_ = {}; for k,v in pairs( t ) do t_[k] = f( k, v ) end return t_ end
local function vkmap( t, f ) local t_ = {}; for k,v in pairs( t ) do t_[k] = f( v, k ) end return t_ end

local function mapx( t, f )   for i = 1, #t do t[i] = f( t[i] ) end return t end
local function imapx( t, f )  for i = 1, #t do t[i] = f( t[i], i ) end return t end
local function vmapx( t, f )  for k,v in pairs( t ) do t[k] = f( v ) end return t end
local function kmapx( t, f )  for k,v in pairs( t ) do t[k] = f( k ) end return t end
local function kvmapx( t, f ) for k,v in pairs( t ) do t[k] = f( k, v ) end return t end
local function vkmapx( t, f ) for k,v in pairs( t ) do t[k] = f( v, k ) end return t end

local function each( t, f )   for i = 1, #t do f( t[i] ) end end
local function ieach( t, f )  for i = 1, #t do f( t[i], i ) end end
local function veach( t, f )  for k,v in pairs( t ) do f( v ) end end
local function keach( t, f )  for k,v in pairs( t ) do f( k ) end end
local function kveach( t, f ) for k,v in pairs( t ) do f( k, v ) end end
local function vkeach( t, f ) for k,v in pairs( t ) do f( v, k ) end end

local function filter( t, f )   local t_,j = {},0; for i = 1, #t do if f( t[i] ) then j = j + 1; t_[j] = t[i] end end return t_ end
local function ifilter( t, f )  local t_,j = {},0; for i = 1, #t do if f( t[i], i ) then j = j + 1; t_[j] = t[i] end end return t_ end
local function vfilter( t, f )  local t_ = {}; for k,v in pairs( t ) do if f( v ) then t_[k] = v end end return t_ end
local function kfilter( t, f )  local t_ = {}; for k,v in pairs( t ) do if f( k ) then t_[k] = v end end return t_ end
local function kvfilter( t, f ) local t_ = {}; for k,v in pairs( t ) do if f( k, v ) then t_[k] = v end end return t_ end
local function vkfilter( t, f ) local t_ = {}; for k,v in pairs( t ) do if f( v, k ) then t_[k] = v end end return t_ end

local function filterx( t, f )   local j = 0; for i = 1, #t do if f( t[i] ) then j = j + 1; t[j] = t[i] end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function ifilterx( t, f )  local j = 0; for i = 1, #t do if f( t[i],i ) then j = j + 1; t[j] = t[i] end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function vfilterx( t, f )  for k,v in pairs( t ) do if not f( v ) then t[k] = nil end end return t end
local function kfilterx( t, f )  for k,v in pairs( t ) do if not f( k ) then t[k] = nil end end return t end
local function kvfilterx( t, f ) for k,v in pairs( t ) do if not f( k, v ) then t[k] = nil end end return t end
local function vkfilterx( t, f ) for k,v in pairs( t ) do if not f( v, k ) then t[k] = nil end end return t end

local function foldl( t, f, acc )  local j,acc = acc==nil and 2 or 1, acc==nil and t[1] or acc;  for i = j,#t do acc = f( t[i], acc ) end return acc end
local function ifoldl( t, f, acc ) local j,acc = acc==nil and 2 or 1, acc==nil and t[1] or acc;  for i = j,#t do acc = f( t[i], i, acc ) end return acc end
local function foldr( t, f, acc )  local l = #t; local j,acc = acc==nil and l-1 or l,acc==nil and t[l] or acc;  for i = j,1,-1 do acc = f( t[i], acc ) end return acc end
local function ifoldr( t, f, acc ) local l = #t; local j,acc = acc==nil and l-1 or l,acc==nil and t[l] or acc;  for i = j,1,-1 do acc = f( t[i], i, acc ) end return acc end
local function vfold( t, f, acc )  local j,acc; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( v, acc ) end return acc end
local function kfold( t, f, acc )  local j,acc; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( k, acc ) end return acc end
local function vkfold( t, f, acc ) local j,acc; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( v, k, acc ) end return acc end
local function kvfold( t, f, acc ) local j,acc; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( k, v, acc ) end return acc end

local function sum( t, acc ) local acc = acc or 0;  for i = 1, #t do acc = acc + t[i] end;  return acc end
local function product( t, acc ) local acc = acc or 1;  for i = 1, #t do acc = acc * t[i] end;  return acc end

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

local function inject( t1, t2, pos, inplace )
	local pos = pos < 0 and #t1 + pos + 1 or pos
	if pos <= 1 then return prepend( t1, t2, inplace )
	elseif pos >= #t1 then return append( t1, t2, inplace )
	else return append( append( slice( t1, pos-1 ), t2 ), slice( t1, pos, -1 ))
	end
end

local function update( t, args, inplace )
	local t = inplace and t or deepcopy( t )
	for k, v in pairs( args ) do
		t[k] = v
	end
	return t
end

local function reverse( t )
	local t_, n = {}, #t
	for i = 1, n do t_[i] = t[n-i+1] end
	return t_
end

local function sorted( t, f, inplace )
	local t_ = inplace and t or deepcopy( t, true )
	table.sort( t_, f )
	return t_ 
end

local function indexof( t, v, fcmp, feq )
	if not feq then
		if not fcmp then
			for i = 1, #t do if t[i] == v then return i end end
		else
			local function defaultcmp( a, b ) return a < b end
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
	else
		if not fcmp then
			for i = 1, #t do if feq( t[i], v ) then return i end end
		else
			local function defaultcmp( a, b ) return a < b end
			local init, limit = 1, #t, 0
			local f = type(fcmp) == 'function' and fcmp or defaultcmp
			local floor = math.floor
			while init <= limit do
				local mid = floor( 0.5*(init+limit))
				local v_ = t[mid]
				if feq( v, v_ ) then return mid
				elseif f( v, v_ ) then limit = mid - 1
				else init = mid + 1
				end
			end
		end
	end
end

local function keyof( t, v, feq )
	if not feq then
		for k, v_ in pairs( t ) do if v_ == v then return k end end
	else
		for k, v_ in pairs( t ) do if feq( v_, v ) then return k end end
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
	local t_ = inplace and t or deepcopy( t ) 
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
	pipe = pipe,
	cand = cand,
	cor = cor,
	cnot = cnot,
	swap = swap,

	map = map, imap = imap, vmap = vmap, kmap = kmap, vkmap = vkmap, kvmap = kvmap,
	mapx = mapx, imapx = imapx, vmapx = vmapx, kmapx = kmapx, vkmapx = vkmapx, kvmapx = kvmapx,
	filter = filter, ifilter = ifilter, vfilter = vfilter, kfilter = kfilter, vkfilter = vkfilter, kvfilter = kvfilter,
	foldl = foldl, foldr = foldr, ifoldl = ifoldl, ifoldr = ifoldr, kfold = kfold, vfold = vfold, vkfold = vkfold, kvfold = kvfold,
	each = each, ieach = ieach, veach = veach, keach = keach, vkeach = vkeach, kveach = kveach,
	
	sum = sum,
	product = product,
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
	update = update,

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

	unpack = table.unpack or unpack,
	pack = table.pack or function(...) local t = {...}; t.n = #t; return t end,

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
