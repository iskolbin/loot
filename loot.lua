local tunpack, pairs, next, type, select, getmetatable, setmetatable = table.unpack or unpack, pairs, next, type, select, getmetatable, setmetatable

local functions
local LootMT 

-- Memoization
local allowmemoize = ALLOW_MEMOIZE == nil and true or ALLOW_MEMOIZE

local function memoize( closure, mode )
	if not allowmemoize then
		return closure
	end
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


-- Matching
local CaptureMT = {}

local wild = {'_'}
local rest = {'...'}
local wildrest = {'___'}

local function capture( name, predicate, transform ) return name == '_' and wild or name == '...' and rest or name == '___' and wildrest or setmetatable( {name, predicate, transform}, CaptureMT ) end

local function equal( x, y, partial, captures )
	if x == y or x == wild or y == wild or y == wildrest then
		return true
	elseif getmetatable( y ) == CaptureMT then
		if captures then
			if (not y[2] or y[2](x)) then
				local name = y[1]
				local value = not y[3] and x or y[3](x)
				if captures[name] then
					return captures[name] == value
				else
					captures[name] = value
				end
			end
		end
		return true
	elseif type(x) == 'table' and type(y) == 'table' and getmetatable(x) == getmetatable(y) then
		local nx, ny = 0, 0
		for k, v in pairs( x ) do nx = nx + 1 end
		for k, v in pairs( y ) do ny = ny + 1 end
		if nx == ny or (partial and nx >= ny) then
			for k, v in pairs( x ) do
				if y[k] == wildrest then
					return true
				elseif y[k] == rest then
					if captures then
						captures._ = captures._ or {}
						for i = k,#x do
							captures._[i-k+1] = x[i]
						end
					end
					return true
				elseif y[k] == nil or not equal( v, y[k], partial, captures ) then
					return false
				end
			end
			return true
		else
			return false
		end
	else
		return false
	end
end

local function match( x, ... )
	for i = 1, select( '#', ... ) do
		local y = select( i, ... )
		local captures = setmetatable( {}, LootMT )
		if equal( x, y,  (type(y)=='table' and (y[#y] == rest or y[#y] == wildrest)), captures ) then
			return captures
		end
	end
	return false
end


-- Predicates
local pcache = {}

local predicates = {
	n = function( y ) return y == nil end,
	t = function( y ) return y == true end,
	f = function( y ) return y == false end,
	boolean = function( y ) return type( y ) == 'boolean' end,
	number = function( y ) return type( y ) == 'number' end,
	integer = function( y ) return math.floor( y ) == y end,
	string = function( y ) return type( y ) == 'string' end,
	table = function( y ) return type( y ) == 'table' end,
	lambda = function( y ) return type( y ) == 'function' end,
	thread = function( y ) return type( y ) == 'thread' end,
	userdata = function( y ) return type( y ) == 'userdata' end,
	zero = function( y ) return y == 0 end,
	positive = function( y ) return y > 0 end,
	negative = function( y ) return y < 0 end,
	even = function( y ) return y % 2 == 0 end,
	odd = function( y ) return y % 2 == 1 end,
	id = function( y ) return type( y ) == 'string' and y:match('[%a_][%w_]*') == y end
}


-- Testing predicates
local is = setmetatable( {}, {__index = function( self, k ) 
	local p = predicates[k]
	if not p then error( ('Predicate not defined %q'):format( k )) end
	return predicates[k] 
end} )

local isnot = setmetatable( {}, {__index = function( self, k ) 
	local p = predicates[k]
	if not p then error( ('Predicate not defined %q'):format( k )) end
	if not pcache[k] then
		pcache[k] = function( y ) return not p(y) end
	end
	return pcache[k]
end } )

local function all( t, f ) for k, v in pairs( t ) do if not f( v ) then return false end end return true end
local function any( t, f ) for k, v in pairs( t ) do if f( v ) then return true end end return false end


-- Operators
local opcache = {}

local op = {
	self = function( x ) return x end,
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
	at = function( x, y ) return x[y] end,
	of = function( x, y ) return y[x] end,
	const = function( x ) return x end,
	call = function( x, y ) return x( y ) end,
	fun = function( x, y ) return y( x ) end,
	selfcall = function( x, y ) return x[y](x) end,
	selffun = function( x, y ) return y[x](y) end,
}

-- Currying
local cr = setmetatable( {}, {
	__index = function( self, k )
		local f = op[k] or functions[k]
		if not f then error( ('Operator or function not defined %q'):format( k )) end
		if not opcache[k] then
			opcache[k] = memoize( function( y ) local f = op[k] or functions[k]; return function( x ) return f(x,y) end end, 'kv' )
		end
		return opcache[k]
	end,
})

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
	else local args = {...}; return function(x) return f( x, tunpack( args )) end
	end
end

-- Composition
local function compose( fs )
	local n = #fs
	if n <= 1 then return fs[1]
	elseif n == 2 then local f1,f2 = fs[1],fs[2]; return function(...) return f2(f1(...))end
	elseif n == 3 then local f1,f2,f3 = fs[1],fs[2],fs[3]; return function(...) return f3(f2(f1(...)))end
	elseif n == 4 then local f1,f2,f3,f4 = fs[1],fs[2],fs[3],fs[4]; return function(...) return f4(f3(f2(f1(...))))end
	else local f1,f2,f3,f4,f5 = fs[1],fs[2],fs[3],fs[4],fs[5]
		if n <= 5 then return function(...) return f5(f4(f3(f2(f1(...))))) end
		else 
			return function(...) 
			local y = {f5(f4(f3(f2(f1(...)))))}
			for i = 1, n-5 do y = {fs[i](tunpack(y))} end
			return y
		end end
	end
end

local function cand( ... ) 
	local n = select( '#', ... )
	if n == 1 then local f1 = ...; return function(x) return f1(x) end 
	elseif n == 2 then local f1,f2 = ...; return function(x) return f1(x) and f2(x) end
	elseif n == 3 then local f1,f2,f3 = ...; return function(x) return f1(x) and f2(x) and f3(x) end 
	elseif n == 4 then local f1,f2,f3,f4 = ...; return function(x) return f1(x) and f2(x) and f3(x) and f4(x) end
	else local f1,f2,f3,f4,f5 = ...
		if n <= 5 then return function(x) return f1(x) and f2(x) and f3(x) and f4(x) and f5(x) end
		else 
			local fs = {select(6,...)}
			return function(x)
			local y = f1(x) and f2(x) and f3(x) and f4(x) and f5(x)
			for i = 1,n-5 do 
				if not y then return y
				else y = y and fs[i](x)
				end
			end
			return y end 
		end
	end
end

local function cor( ... ) 
	local n = select( '#', ... )
	if n == 1 then local f1 = ...; return function(x) return f1(x) end 
	elseif n == 2 then local f1,f2 = ...; return function(x) return f1(x) or f2(x) end
	elseif n == 3 then local f1,f2,f3 = ...; return function(x) return f1(x) or f2(x) or f3(x) end 
	elseif n == 4 then local f1,f2,f3,f4 = ...; return function(x) return f1(x) or f2(x) or f3(x) or f4(x) end
	else local f1,f2,f3,f4,f5 = ...
		if n <= 5 then return function(x) return f1(x) or f2(x) or f3(x) or f4(x) or f5(x) end
		else 
			local fs = {select(6,...)}
			return function(x)
			local y = f1(x) or f2(x) or f3(x) or f4(x) or f5(x)
			for i = 1,n-5 do 
				if y then return y
				else y = y or fs[i](x)
				end
			end
			return y end 
		end
	end
end

local function cnot( x ) return function( ... ) return not x( ... ) end end

local function pipe( x, ... )
	local y = x
	for i = 1, select( '#', ... ) do
		local f = select( i, ... )
		local tf = type( f )
		if tf == 'table' then y = f[1](y, tunpack(f,2))
		elseif tf == 'function' then y = f(y)
		else error( 'pipe arguments have to be unary functions or tables {f,arg2,arg3,...}')
		end
	end
	return y
end


-- Map
local function map( t, f )   local t_ = {}; for i = 1, #t do t_[i] = f( t[i] ) end return setmetatable( t_, getmetatable(t) ) end
local function imap( t, f )  local t_ = {}; for i = 1, #t do t_[i] = f( i, t[i] ) end return setmetatable( t_, getmetatable(t) ) end
local function vmap( t, f )  local t_ = {}; for k,v in pairs( t ) do t_[k] = f( v ) end return setmetatable( t_, getmetatable(t) ) end
local function kmap( t, f )  local t_ = {}; for k,v in pairs( t ) do t_[k] = f( k ) end return setmetatable( t_, getmetatable(t) ) end
local function kvmap( t, f ) local t_ = {}; for k,v in pairs( t ) do t_[k] = f( k, v ) end return setmetatable( t_, getmetatable(t) ) end
local function vkmap( t, f ) local t_ = {}; for k,v in pairs( t ) do t_[k] = f( v, k ) end return setmetatable( t_, getmetatable(t) ) end


-- Inplace map
local function mapI( t, f )   for i = 1, #t do t[i] = f( t[i] ) end return t end
local function imapI( t, f )  for i = 1, #t do t[i] = f( i, t[i] ) end return t end
local function vmapI( t, f )  for k,v in pairs( t ) do t[k] = f( v ) end return t end
local function kmapI( t, f )  for k,v in pairs( t ) do t[k] = f( k ) end return t end
local function kvmapI( t, f ) for k,v in pairs( t ) do t[k] = f( k, v ) end return t end
local function vkmapI( t, f ) for k,v in pairs( t ) do t[k] = f( v, k ) end return t end


-- Filter
local function filter( t, p )   local t_,j = {},0; for i = 1, #t do if p( t[i] ) then j = j + 1; t_[j] = t[i] end end return setmetatable( t_, getmetatable(t)) end
local function ifilter( t, p )  local t_,j = {},0; for i = 1, #t do if p( i, t[i] ) then j = j + 1; t_[j] = t[i] end end return setmetatable( t_, getmetatable(t)) end
local function vfilter( t, p )  local t_ = {}; for k,v in pairs( t ) do if p( v ) then t_[k] = v end end return setmetatable( t_, getmetatable(t)) end
local function kfilter( t, p )  local t_ = {}; for k,v in pairs( t ) do if p( k ) then t_[k] = v end end return setmetatable( t_, getmetatable(t)) end
local function kvfilter( t, p ) local t_ = {}; for k,v in pairs( t ) do if p( k, v ) then t_[k] = v end end return setmetatable( t_, getmetatable(t)) end
local function vkfilter( t, p ) local t_ = {}; for k,v in pairs( t ) do if p( v, k ) then t_[k] = v end end return setmetatable( t_, getmetatable(t)) end


-- Inplace filter
local function filterI( t, p )   local j = 0; for i = 1, #t do if p( t[i] ) then j = j + 1; t[j] = t[i] end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function ifilterI( t, p )  local j = 0; for i = 1, #t do if p( i, t[i] ) then j = j + 1; t[j] = t[i] end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function vfilterI( t, p )  for k,v in pairs( t ) do if not p( v ) then t[k] = nil end end return t end
local function kfilterI( t, p )  for k,v in pairs( t ) do if not p( k ) then t[k] = nil end end return t end
local function kvfilterI( t, p ) for k,v in pairs( t ) do if not p( k, v ) then t[k] = nil end end return t end
local function vkfilterI( t, p ) for k,v in pairs( t ) do if not p( v, k ) then t[k] = nil end end return t end


-- Map-filter
local function mapfilter( t, f, p )   local t_,j = {},0; for i = 1, #t do local v_ = f( t[i] ); if p( v_ ) then j = j + 1; t_[j] = v_ end end return setmetatable( t_, getmetatable(t)) end
local function imapfilter( t, f, p )  local t_,j = {},0; for i = 1, #t do local v_ = f( i, t[i] ); if p( i, v_ ) then j = j + 1; t_[j] = v_ end end return setmetatable( t_, getmetatable(t)) end
local function vmapfilter( t, f, p )  local t_ = {}; for k,v in pairs( t ) do local v_ = f( v ); if p( v_ ) then t_[k] = v_ end end return setmetatable( t_, getmetatable(t)) end
local function kmapfilter( t, f, p )  local t_ = {}; for k,v in pairs( t ) do local v_ = f( k ); if p( k ) then t_[k] = v_ end end return setmetatable( t_, getmetatable(t)) end
local function kvmapfilter( t, f, p ) local t_ = {}; for k,v in pairs( t ) do local v_ = f( k, v ); if p( k, v_ ) then t_[k] = v_ end end return setmetatable( t_, getmetatable(t)) end
local function vkmapfilter( t, f, p ) local t_ = {}; for k,v in pairs( t ) do local v_ = f( v, k ); if p( v_, k ) then t_[k] = v_ end end return setmetatable( t_, getmetatable(t)) end


-- Inplace map-filter
local function mapfilterI( t, f, p )   local j = 0; for i = 1, #t do local v_ = f( t[i] ); if p( v_ ) then j = j + 1; t[j] = v_ end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function imapfilterI( t, f, p )  local j = 0; for i = 1, #t do local v_ = f( i, t[i] ); if p( i, v_ ) then j = j + 1; t[j] = v_ end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function vmapfilterI( t, f, p )  for k,v in pairs( t ) do local v_ = f( v ); if not p( v_ ) then t[k] = nil else t[k] = v_ end end return t end
local function kmapfilterI( t, f, p )  for k,v in pairs( t ) do local v_ = f( k ); if not p( k ) then t[k] = nil else t[k] = v_ end end return t end
local function kvmapfilterI( t, f, p ) for k,v in pairs( t ) do local v_ = f( k, v ); if not p( k, v_ ) then t[k] = nil else t[k] = v_ end end return t end
local function vkmapfilterI( t, f, p ) for k,v in pairs( t ) do local v_ = f( v, k ); if not p( v_, k ) then t[k] = nil else t[k] = v_ end end return t end


-- Filter-map
local function filtermap( t, p, f )   local t_,j = {},0; for i = 1, #t do if p( t[i] ) then j = j + 1; t_[j] = f( t[i] ) end end return setmetatable( t_, getmetatable(t)) end
local function ifiltermap( t, p, f )  local t_,j = {},0; for i = 1, #t do if p( i, t[i] ) then j = j + 1; t_[j] = f( i, t[i] ) end end return setmetatable( t_, getmetatable(t)) end
local function vfiltermap( t, p, f )  local t_ = {}; for k,v in pairs( t ) do if p( v ) then t_[k] = f( v ) end end return setmetatable( t_, getmetatable(t)) end
local function kfiltermap( t, p, f )  local t_ = {}; for k,v in pairs( t ) do if p( k ) then t_[k] = f( k ) end end return setmetatable( t_, getmetatable(t)) end
local function kvfiltermap( t, p, f ) local t_ = {}; for k,v in pairs( t ) do if p( k, v ) then t_[k] = f( k, v ) end end return setmetatable( t_, getmetatable(t)) end
local function vkfiltermap( t, p, f ) local t_ = {}; for k,v in pairs( t ) do if p( v, k ) then t_[k] = f( v, k ) end end return setmetatable( t_, getmetatable(t)) end


-- Inplace filter-map
local function filtermapI( t, p, f )   local j = 0; for i = 1, #t do if p( t[i] ) then j = j + 1; t[j] = f( t[i] ) end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function ifiltermapI( t, p, f )  local j = 0; for i = 1, #t do if p( i, t[i] ) then j = j + 1; t[j] = f( i, t[i] ) end end;  for i = j+1, #t do t[i] = nil end;  return t end
local function vfiltermapI( t, p, f )  for k,v in pairs( t ) do if not p( v ) then t[k] = nil else t[k] = f( v ) end end return t end
local function kfiltermapI( t, p, f )  for k,v in pairs( t ) do if not p( k ) then t[k] = nil else t[k] = f( k ) end end return t end
local function kvfiltermapI( t, p, f ) for k,v in pairs( t ) do if not p( k, v ) then t[k] = nil else t[k] = f( k, v ) end end return t end
local function vkfiltermapI( t, p, f ) for k,v in pairs( t ) do if not p( v, k ) then t[k] = nil else t[k] = f( v, k ) end end return t end


-- Fold
local function foldl( t, f, acc )  local j,acc = acc==nil and 2 or 1, acc==nil and t[1] or acc;  for i = j,#t do acc = f( acc, t[i] ) end return acc end
local function ifoldl( t, f, acc ) local j,acc = acc==nil and 2 or 1, acc==nil and t[1] or acc;  for i = j,#t do acc = f( acc, i, t[i] ) end return acc end
local function foldr( t, f, acc )  local l = #t; local j,acc = acc==nil and l-1 or l,acc==nil and t[l] or acc;  for i = j,1,-1 do acc = f( acc, t[i] ) end return acc end
local function ifoldr( t, f, acc ) local l = #t; local j,acc = acc==nil and l-1 or l,acc==nil and t[l] or acc;  for i = j,1,-1 do acc = f( acc, i, t[i] ) end return acc end
local function vfold( t, f, acc )  local j; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( acc, v ) end return acc end
local function kfold( t, f, acc )  local j; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( acc, k ) end return acc end
local function kvfold( t, f, acc ) local j; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( acc, k, v ) end return acc end
local function vkfold( t, f, acc ) local j; if acc==nil then j,acc = next(t) end;  for k,v in next, t, j do acc = f( acc, v, k ) end return acc end


-- Special folds
local function sum( t, acc ) local acc = acc or 0;  for i = 1, #t do acc = acc + t[i] end;  return acc end
local function product( t, acc ) local acc = acc or 1;  for i = 1, #t do acc = acc * t[i] end;  return acc end


-- For each
local function each( t, f )   for i = 1, #t do f( t[i] ) end end
local function ieach( t, f )  for i = 1, #t do f( i, t[i] ) end end
local function veach( t, f )  for k,v in pairs( t ) do f( v ) end end
local function keach( t, f )  for k,v in pairs( t ) do f( k ) end end
local function kveach( t, f ) for k,v in pairs( t ) do f( k, v ) end end
local function vkeach( t, f ) for k,v in pairs( t ) do f( v, k ) end end


-- Traversing table
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


-- Transformations
local function append( t1, t2 )
	local t, n = {}, #t1
	for i = 1, n do t[i] = t1[i] end
	for i = 1, #t2 do t[i+n] = t2[i] end
	return setmetatable( t, getmetatable( t1 ))
end

local function prepend( t1, t2 ) 
	local t, m = {}, #t2
	for i = 1, m do t[i] = t2[i] end
	for i = 1, #t1 do t[m+i] = t1[i] end
	return setmetatable( t, getmetatable( t1 ))
end

local function inject( t1, t2, pos )
	local pos = pos < 0 and #t1 + pos + 1 or pos
	if pos <= 1 then return prepend( t1, t2 )
	elseif pos >= #t1 then return append( t1, t2 )
	else 
		local n, m, t = #t1, #t2, {}
		for i = 1, pos-1 do t[i] = t1[i] end
		for i = 1, m do t[i+pos-1] = t2[i] end
		for i = pos, n do t[i+m] = t1[i] end
		return setmetatable( t, getmetatable( t1 ))
	end
end

local function reverse( t ) local t_, n = {}, #t;  for i = 1, n do t_[i] = t[n-i+1] end;  return setmetatable( t_, getmetatable( t )) end

local function shuffle( t, f )
	local f, n = f or math.random, #t
	local t_ = copy( t )
	for i = n, 1, -1 do
		local j = f( i )
		t_[j], t_[i] = t_[i], t_[j]
	end
	return t_
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
	return setmetatable( t_, getmetatable( t ))
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
	return setmetatable( out, getmetatable( t ))
end

local null = {}

local function update( t, args ) 
	local t_ = {}
	for k, v in pairs( t ) do t_[k] = t[k] end
	for k, v in pairs( args ) do t_[k] = v ~= null and v or nil end
	return setmetatable( t_, getmetatable( t )) 
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
	return setmetatable( t_, getmetatable( t ))
end


-- Inplace transformations
local function appendI( t1, t2 ) 
	local n = #t1
	for i = 1, #t2 do t1[i+n] = t2[i] end
	return t1 
end

local function prependI( t1, t2 ) 
	local n, m = #t1,#t2
	for i = n+1, n+m do t1[i] = false end
	for i = n+m, m+1, -1 do t1[i] = t1[i-m] end
	for i = 1, m do t1[i] = t2[i] end
	return t1
end

local function injectI( t1, t2, pos )
	local pos = pos < 0 and #t1 + pos + 1 or pos
	if pos <= 1 then return prependI( t1, t2 )
	elseif pos >= #t1 then return appendI( t1, t2 )
	else
		local n, m = #t1, #t2
		for i = 1, m do t1[i+n] = false end
		for i = n, pos, -1 do t1[i+m] = t1[i] end
		for i = 1, m do t1[i+pos-1] = t2[i] end
		return t1
	end
end

local function reverseI( t ) local n = #t; for i = 1,  math.floor( n/2 ) do t[i], t[n-i+1] = t[n-i+1], t[i] end;  return t end

local function updateI( t, args ) for k, v in pairs( args ) do t[k] = v ~= null and v or nil end;  return t end

local function shuffleI( t, f )
	local f, n = f or math.random, #t
	for i = n, 1, -1 do
		local j = f( i )
		t[j], t[i] = t[i], t[j]
	end
	return t
end


-- Searching and sorting
local function indexof( t, v, cmp )
	if not cmp then
		for i = 1, #t do if t[i] == v then return i end end
	else
		local function defaultcmp( a, b ) return a < b end
		local init, limit = 1, #t, 0
		local f = type(cmp) == 'function' and cmp or defaultcmp
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

local function indexofq( t, v, eq, cmp )
	local eq = eq or equal
	if not cmp then
		for i = 1, #t do if eq( t[i], v ) then return i end end
	else
		local function defaultcmp( a, b ) return a < b end
		local init, limit = 1, #t, 0
		local f = type(cmp) == 'function' and cmp or defaultcmp
		local floor = math.floor
		while init <= limit do
			local mid = floor( 0.5*(init+limit))
			local v_ = t[mid]
			if eq( v, v_ ) then return mid
			elseif f( v, v_ ) then limit = mid - 1
			else init = mid + 1
			end
		end
	end
end

local function keyof( t, v ) for k, v_ in pairs( t ) do if v_ == v then return k end end end
local function keyofq( t, v, eq ) local eq = eq or equal;  for k, v_ in pairs( t ) do if eq( v_, v ) then return k end end end

local function sort( t, f ) local t_ = copy(t);  table.sort( t_, f );  return t_ end
local function sortI( t, f ) table.sort( t, f );  return t end


-- Partition
local function partition( t, f ) local mt = getmetatable( t ); local t1, t2, j, k = setmetatable({},mt), setmetatable({},mt), 0, 0;  for i = 1, #t do  if f( t[i] ) then j = j + 1; t1[j] = t[i]  else k = k + 1;  t2[k] = t[i] end  end;  return t1,t2 end
local function ipartition( t, f ) local mt = getmetatable( t ); local t1, t2, j, k = setmetatable({},mt), setmetatable({},mt), 0, 0;  for i = 1, #t do  if f( i, t[i] ) then j = j + 1; t1[j] = t[i]  else k = k + 1;  t2[k] = t[i] end  end;  return t1,t2 end
local function vpartition( t, f ) local mt = getmetatable( t ); local t1, t2 = setmetatable({},mt), setmetatable({},mt);  for k, v in pairs( t ) do if f( v ) then t1[k] = v else t2[k] = v end end;  return t1,t2 end
local function kpartition( t, f ) local mt = getmetatable( t ); local t1, t2 = setmetatable({},mt), setmetatable({},mt);  for k, v in pairs( t ) do if f( k ) then t1[k] = v else t2[k] = v end end;  return t1,t2 end
local function vkpartition( t, f ) local mt = getmetatable( t ); local t1, t2 = setmetatable({},mt), setmetatable({},mt);  for k, v in pairs( t ) do if f( v, k ) then t1[k] = v else t2[k] = v end end;  return t1,t2 end
local function kvpartition( t, f ) local mt = getmetatable( t ); local t1, t2 = setmetatable({},mt), setmetatable({},mt);  for k, v in pairs( t ) do if f( k, v ) then t1[k] = v else t2[k] = v end end;  return t1,t2 end


-- Zip/unzip
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
	if #t > 0 and type( t[1] ) == 'table' then
		local n = #t[1]
		for i = 1, n do t_[i] = {} end
		for i = 1, n do
			for j = 1, #t do t_[i][j] = t[j][i] end
		end
	end
	return tunpack( t_ )
end


-- Table creation and manipulation
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

local function keys( t ) local t_,j = {},0;  for k, v in pairs( t ) do j = j + 1; t_[j] = k end;  return t_ end

local function values( t ) local t_,j = {},0;  for k, v in pairs( t ) do j = j + 1; t_[j] = v end;  return t_ end

local function topairs( t ) local t_,j = {},0;  for k, v in pairs( t ) do j = j + 1; t_[j] = {k,v} end;  return t_ end

local function frompairs( t ) local t_ = {};  for i = 1, #t do t_[t[i][1]] = t[i][2] end;  return t_ end

local function tolists( t )
	local t1, t2, i = {}, {}, 0
	for k, v in pairs( t ) do
		i = i + 1
		t1[i], t2[i] = k, v
	end
	return t1, t2
end

local function fromlists( t1, t2 )
	local t = {}
	for i = 1, math.min( #t1, #t2 ) do t[t1[i]] = t2[i] end
	return t
end

local function pack( ... ) return { ... } end


-- Counting
local function nkeys( t )
	local len = 0
	for k, v in pairs( t ) do len = len + 1 end
	return len
end

local function count( t )
	local t_ = {}
	for i = 1, #t do
		local v = t[i]
		t_[v] = (t_[v] or 0) + 1
	end
	return t_
end


-- Copying
local function copy( t, arrayfor )
	if type( t ) == 'table' then
		local t_ = {}
		if arrayfor then
			for i = 1, #t do t_[i] = t[i] end
		else
			for k, v in pairs( t ) do t_[k] = v end
		end
		return setmetatable( t_, getmetatable( t ))
	else
		return t
	end
end

local function deepcopy( t, saved )
	local saved = saved or {}
	if type( t ) == 'table' then
		if not saved[t] then
			local t_ = {}
			saved[t] = setmetatable( t_, getmetatable( t ))
			for k, v in pairs( t ) do
				t_[deepcopy( k, saved )] = deepcopy( v, saved )
			end
			return t_
		else
			return saved[t]
		end
	else
		return t
	end
end


-- Range
local RangeMT = {
	__index = function( self, k ) return self.i + self.s*(k-1) end,
	__len   = function( self ) return self.l end,
}

local function range( init, limit, step )
	local init, limit, step = init, limit, step or 1
	if not limit then

		init, limit = 1, init
	end
	return setmetatable( {i = init,l = 1+math.floor((limit-init)/step),s = step}, RangeMT )
end


-- Set operations
local function setof( ... )
	local t = {}
	for i = 1, select( '#', ... ) do
		local k = select( i, ... )
		t[k] = true
	end
	return setmetatable( t, LootMT )
end

local function intersect( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do
		if t2[k] ~= nil then t[k] = v end
	end
	return setmetatable( t, getmetatable( t1 ))
end

local function union( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do t[k] = v end
	for k, v in pairs( t2 ) do t[k] = v end
	return setmetatable( t, getmetatable( t1 ))
end

local function difference( t1, t2 )
	local t = {}
	for k, v in pairs( t1 ) do
		if t2[k] == nil then t[k] = v end
	end
	return setmetatable( t, getmetatable( t1 ))
end


-- Combinatorics
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

local function combinations( ts, n )
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

local function combinationsof( ... )
	local ts = {...}
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


-- Profiling utilities
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


-- Swap
local function swap( x, y ) return y, x end


-- Generate simple function from string
local fn = memoize( function(code) 
	return loadstring(('return function(x,y,z,u,v,w)\nreturn %s\nend'):format( code ))()
end )


-- Advanced tostring and pretty-printing
local function xtostring( x, tables, identSymbol )
	local tables = tables or {}
	local identSymbol = identSymbol or ' '
	local function serialize( v, ident )
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
				tables[tables.n] = v
				local buff = {}
				local arr = {}
				for i = 1, #v do
					arr[i] = true
					buff[i] = serialize( v[i], ident )
				end
				for k, vv in pairs( v ) do
					if not arr[k] then
						if type( k ) == 'string' and k:match('[%a_][%w_]*') == k then
							buff[#buff+1] = ('\n%s%s = %s'):format( ident and identSymbol:rep(ident) or '', k, serialize( vv, ident and (ident + 1)))
						else
							buff[#buff+1] = ('%s[%s] = %s'):format( ident and identSymbol:rep(ident) or '', serialize( k, ident ), serialize( vv, ident ))
						end
					end
				end
				return '{' .. table.concat( buff, ', ' ) .. '}' 
			else
				return '__' .. tables[v]
			end
		end
	end
	return serialize( x, 0 )
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
		io.write( xtostring( x,{},'  ' ) )
		if i < n then
			io.write( type(x) == 'table' and '\n' or '\t' )
		end
	end
	io.write('\n')
end


local function mt( t )
	return setmetatable( t, LootMT )
end

-- Exporting library
local function export( ... )
	local n = select( '#', ... )
	if n == 0 then
		setmetatable( _G, LootMT )
	else
		local f = {}
		for i = 1, n do
			f[i] = functions[select( i, ... )]
		end
		return tunpack( f )
	end
end

functions = {
	null = null, memoize = memoize, op = op, cr = cr,is = is, isnot = isnot, predicates = predicates,
	all = all, any = any, wild = wild, rest = rest, wildrest = wildrest, capture = capture, equal = equal, match = match,
	pipe = pipe, curry = curry, compose = compose, cand = cand, cor = cor, cnot = cnot, swap = swap,
	map = map, imap = imap, vmap = vmap, kmap = kmap, vkmap = vkmap, kvmap = kvmap,
	filter = filter, ifilter = ifilter, vfilter = vfilter, kfilter = kfilter, vkfilter = vkfilter, kvfilter = kvfilter,
	mapfilter = mapfilter, imapfilter = imapfilter, vmapfilter = vmapfilter, kmapfilter = kmapfilter, vkmapfilter = vkmapfilter, kvmapfilter = kvmapfilter,
	mapfilterI = mapfilterI, imapfilterI = imapfilterI, vmapfilterI = vmapfilterI, kmapfilterI = kmapfilterI, vkmapfilterI = vkmapfilterI, kvmapfilterI = kvmapfilterI,
	filtermap = filtermap, ifiltermap = ifiltermap, vfiltermap = vfiltermap, kfiltermap = kfiltermap, vkfiltermap = vkfiltermap, kvfiltermap = kvfiltermap,
	filtermapI = filtermapI, ifiltermapI = ifiltermapI, vfiltermapI = vfiltermapI, kfiltermapI = kfiltermapI, vkfiltermapI = vkfiltermapI, kvfiltermapI = kvfiltermapI,
	foldl = foldl, foldr = foldr, ifoldl = ifoldl, ifoldr = ifoldr, kfold = kfold, vfold = vfold, vkfold = vkfold, kvfold = kvfold,
	each = each, ieach = ieach, veach = veach, keach = keach, vkeach = vkeach, kveach = kveach,
	mapI = mapI, imapI = imapI, vmapI = vmapI, kmapI = kmapI, vkmapI = vkmapI, kvmapI = kvmapI,
	filterI = filterI, ifilterI = ifilterI, vfilterI = vfilterI, kfilterI = kfilterI, vkfilterI = vkfilterI, kvfilterI = kvfilterI,
	sum = sum, product = product, count = count, nkeys = nkeys, traverse = traverse, newtable = newtable,
	range = range, slice = slice, append = append, appendI = appendI, prepend = prepend, prependI = prependI, 
	inject = inject, injectI = injectI, reverse = reverse, reverseI = reverseI, shuffle = shuffle, shuffleI = shuffleI,
	update = update, updateI = updateI, indexof = indexof, indexofq = indexofq, keyof = keyof, keyofq = keyofq,
	sort = sort, sortI = sortI, keys = keys, values = values, setof = setof, intersect = intersect, difference = difference, union = union,
	permutations = permutations, combinations = combinations, combinationsof = combinationsof,
	unique = unique, copy = copy, deepcopy = deepcopy, topairs = topairs, frompairs = frompairs, tolists = tolists, fromlists = fromlists,
	flatten = flatten, zip = zip, unzip = unzip, partition = partition, ipartition = ipartition, vpartition = vpartition, 
	kpartition = kpartition, vkpartition = vkpartition, kvpartition = kvpartition, pack = pack, diffclock = diffclock, 
	ndiffclock = ndiffclock, diffmemory = diffmemory, xtostring = xtostring, pp = pp, export = export, fn = fn, mt = mt,
}

LootMT = {
	__index = functions,
}

return functions
