local Utils = require'Utils'
local Match = require'Match'
local Set   = require'Set'

local Table = {
	equal = Match.equal,
	tostring = Utils.tostring,
	copy = Utils.copy,
	deepcopy = Utils.deepcopy,
	difference = Set.difference,
	union = Set.union,
	xorunion = Set.xorunion,
	intersection = Set.intersection
}

function Table:match( ... )
	local result = Match.match( self, ... )
	if result then
		return setmetatable( result, getmetatable(self) )
	end
end

-- Searching
function Table:indexof( item, cmp )
	if not cmp then
		for i = 1, #self do if self[i] == item then return i end end
	else
		local function defaultcmp( a, b ) 
			return a < b 
		end
		
		local init, limit = 1, #self
		local f = type( cmp ) == 'function' and cmp or defaultcmp
		local floor = math.floor
		while init <= limit do
			local mid = floor( 0.5*(init+limit))
			local v = self[mid]
			if item == v then 
				return mid
			elseif f( item, v ) then 
				limit = mid - 1
			else 
				init = mid + 1
			end
		end
	end
end

function Table:keyof( item )
	for k, v in pairs( self ) do
		if v == item then
			return k
		end
	end
end

function Table:get( key, default )
	local v = self[key]
	return (v ~= nil) and v or default
end


function Table:sum( acc )
	acc = acc or 0
	for i = 1, #self do
		acc = self[i] + acc
	end
	return acc
end
	
function Table:shuffle( random )
	local rand = random or math.random
	local result = Table.copy(self)
	for i = #self, 1, -1 do
		local j = rand( i )
		result[j], result[i] = result[i], result[j]
	end
	return Table.cpmt( result, self )
end

function Table:sub( init, limit, step )
	init, limit, step = init, limit or #self, step or 1

	if init < 0 then init = #self + init + 1 end
	if limit < 0 then limit = #self + limit + 1 end

	local result, j = {}, 0
	for i = init, limit, step do
		j = j + 1
		result[j] = self[i]
	end
	return Table.cpmt( result, self )
end

function Table:reverse()
	local result, n = {}, #self + 1
	for i = n, 1, -1 do
		result[n - i] = self[i]
	end
	return Table.cpmt( result, self )
end

function Table:insert( toinsert, pos )
	local n, m, result = #self, #toinsert, {}
	pos = pos or n+1
	pos = pos < 0 and n + pos + 2 or pos
	if pos <= 1 then
		for i = 1, m do result[i] = toinsert[i] end
		for i = 1, n do result[m+i] = self[i] end
	elseif pos > n then
		for i = 1, n do result[i] = self[i] end
		for i = 1, m do result[i+n] = toinsert[i] end
	else
		for i = 1, pos-1 do result[i] = self[i] end
		for i = 1, m do result[i+pos-1] = toinsert[i] end
		for i = pos, n do result[i+m] = self[i] end
	end
	return Table.cpmt( result, self )
end

function Table:remove( init, limit )
	init, limit = init or #self, limit or #self
	if init < 0 then
		init = #self + init + 1
	end
	if limit < 0 then
		limit = #self + limit + 1
	end
	local result, j = {}, 0
	for i = 1, init-1 do
		j = j + 1
		result[j] = self[i]
	end
	for i = limit+1, #self do
		j = j + 1
		result[j] = self[i]
	end
	return Table.cpmt( result, self )
end

function Table:reject( toremove, cmp )
	local result, j = {}, 0
	for i = 1, #self do
		local v = self[i]
		if Table.indexof( toremove, v, cmp ) == nil then
			j = j + 1
			result[j] = v
		end
	end
	return Table.cpmt( result, self )
end

function Table:flatten()
	local function doFlatten( t, v, index )
		if type( v ) == 'table' then
			for k = 1, #v do index = doFlatten( t, v[k], index ) end
		else
			index = index + 1
			t[index] = v
		end
		return index
	end

	local result, j = {}, 0
	for i = 1, #self do 
		j = doFlatten( result, self[i], j ) 
	end
	return Table.cpmt( result, self )
end

function Table:cpmt( source )
	return setmetatable( self, getmetatable( source ))
end

function Table:len()
	return #self
end

-- Transform to list
function Table:keys()    
	local result, i = {}, 0
	for k, _ in pairs( self ) do i = i + 1; result[i] = k end
	return Table.copymt( result, self ) 
end
function Table:values()  
	local result, i = {}, 0
	for _, v in pairs( self ) do i = i + 1; result[i] = v end
	return Table.cpmt( result, self ) 
end
function Table:itemskv() 
	local result, i = {}, 0
	for k, v in pairs( self ) do i = i + 1; result[i] = {k,v} end
	return Table.cpmt( result, self )
end
function Table:itemsvk() 
	local result, i = {}, 0
	for k, v in pairs( self ) do i = i + 1; result[i] = {v,k} end
	return Table.cpmt( result, self )
end
function Table:indices() 
	local result = {}
	for i = 1, #self do result[i] = i end
	return Table.cpmt( result, self )
end
function Table:itemsiv() 
	local result = {}
	for i = 1, #self do result[i] = {i,self[i]} end
	return Table.cpmt( result, self )
end
function Table:itemsvi()
	local result = {}
	for i = 1, #self do result[i] = {self[i],i} end
	return Table.cpmt( result, self )
end

-- Transform from items
function Table:dict()
	local result = {}
	for i = 1, #self do result[self[i][1]] = self[i][2] end
	return Table.cpmt( result, self )
end
function Table:dictvk()
	local result = {}; for i = 1, #self do result[self[i][2]] = self[i][1] end
	return Table.cpmt( result, self )
end

-- Map
function Table:map( f )
	local result = {}
	for i = 1, #self do result[i] = f( self[i] ) end 
	return Table.cpmt( result, self ) 
end
function Table:mapiv( f )
	local result = {}
	for i = 1, #self do result[i] = f( i, self[i] ) end
	return Table.cpmt( result, self )
end
function Table:mapvi( f )
	local result = {}
	for i = 1, #self do result[i] = f( self[i], i ) end
	return Table.cpmt( result, self )
end
function Table:mapv( f )
	local result = {}
	for k,v in pairs( self ) do result[k] = f( v ) end
	return Table.cpmt( result, self )
end
function Table:mapk( f )
	local result = {}
	for k,_ in pairs( self ) do result[k] = f( k ) end
	return Table.cpmt( result, self )
end
function Table:mapkv( f )
	local result = {}
	for k,v in pairs( self ) do result[k] = f( k, v ) end
	return Table.cpmt( result, self )
end
function Table:mapvk( f )
	local result = {}
	for k,v in pairs( self ) do result[k] = f( v, k ) end
	return Table.cpmt( result, self )
end

-- Filter
function Table:filter( p )
	local result, j = {}, 0
	for i = 1, #self do if p( self[i] ) then j = j + 1; result[j] = self[i] end end
	return Table.cpmt( result, self )
end
function Table:filteriv( p )
	local result, j = {}, 0 
	for i = 1, #self do if p( i, self[i] ) then j = j + 1; result[j] = self[i] end end 
	return Table.cpmt( result, self )
end
function Table:filtervi( p )
	local result, j = {},0
	for i = 1, #self do if p( self[i], i ) then j = j + 1; result[j] = self[i] end end
	return Table.cpmt( result, self )
end
function Table:filterv( p )
	local result = {}
	for k,v in pairs( self ) do if p( v ) then result[k] = v end end
	return Table.cpmt( result, self )
end
function Table:filterk( p ) 
	local result = {}
	for k,v in pairs( self ) do if p( k ) then result[k] = v end end
	return Table.cpmt( result, self )
end
function Table:filterkv( p )
	local result = {}
	for k,v in pairs( self ) do if p( k, v ) then result[k] = v end end
	return Table.cpmt( result, self )
end
function Table:filtervk( p )
	local result = {}
	for k,v in pairs( self ) do if p( v, k ) then result[k] = v end end
	return Table.cpmt( result, self )
end

-- Filter-map in one pass
function Table:filtermap( p, f )
	local result, j = {}, 0
	for i = 1, #self do if p( self[i] ) then j = j + 1; result[j] = f( self[i] ) end end
	return Table.cpmt( result, self )
end
function Table:filtermapiv( p, f )
	local result, j = {}, 0 
	for i = 1, #self do if p( i, self[i] ) then j = j + 1; result[j] = f( i, self[i] ) end end 
	return Table.cpmt( result, self )
end
function Table:filtermapvi( p, f )
	local result, j = {}, 0
	for i = 1, #self do if p( self[i], i ) then j = j + 1; result[j] = f( self[i], i ) end end
	return Table.cpmt( result, self )
end
function Table:filtermapv( p, f )
	local result = {}
	for k, v in pairs( self ) do if p( v ) then result[k] = f( v ) end end
	return Table.cpmt( result, self )
end
function Table:filtermapk( p, f ) 
	local result = {}
	for k, _ in pairs( self ) do if p( k ) then result[k] = f( k ) end end
	return Table.cpmt( result, self )
end
function Table:filtermapkv( p, f )
	local result = {}
	for k, _ in pairs( self ) do if p( k, v ) then result[k] = f( k, v ) end end
	return Table.cpmt( result, self )
end
function Table:filtermapvk( p, f )
	local result = {}
	for k, v in pairs( self ) do if p( v, k ) then result[k] = f( v, k ) end end
	return Table.cpmt( result, self )
end

-- Fold
function Table:foldl( f, acc )
	local j
	j,acc = acc==nil and 2 or 1, acc==nil and self[1] or acc
	for i = j,#self do acc = f( acc, self[i] ) end 
	return acc 
end
function Table:foldliv( f, acc )
	local j
	j,acc = acc==nil and 2 or 1, acc==nil and self[1] or acc
	for i = j,#self do acc = f( acc, i, self[i] ) end
	return acc 
end
function Table:foldlvi( f, acc )
	local j
	j,acc = acc==nil and 2 or 1, acc==nil and self[1] or acc
	for i = j,#self do acc = f( acc, self[i], i ) end
	return acc
end
function Table:foldr( f, acc )
	local j
	j,acc = acc==nil and #self-1 or #self,acc==nil and self[#self] or acc
	for i = j,1,-1 do acc = f( acc, self[i] ) end
	return acc 
end
function Table:foldriv( f, acc )
	local j
	j,acc = acc==nil and #self-1 or #self,acc==nil and self[#self] or acc
	for i = j,1,-1 do acc = f( acc, i, self[i] ) end 
	return acc 
end
function Table:foldrvi( f, acc )
	local j
	j,acc = acc==nil and #self-1 or #self,acc==nil and self[#self] or acc
	for i = j,1,-1 do acc = f( acc, self[i], i ) end
	return acc
end
function Table:foldv( f, acc )
	local j
	if acc==nil then j,acc = next(self) end
	for _,v in next, self, j do acc = f( acc, v ) end
	return acc
end
function Table:foldk( f, acc )
	local j
	if acc==nil then j,acc = next(self) end
	for k,_ in next, self, j do acc = f( acc, k ) end
	return acc 
end
function Table:foldkv( f, acc )
	local j
	if acc==nil then j,acc = next(self) end
	for k,v in next, self, j do acc = f( acc, k, v ) end 
	return acc 
end
function Table:foldvk( f, acc )
	local j
	if acc==nil then j,acc = next(self) end
	for k,v in next, self, j do acc = f( acc, v, k ) end
	return acc 
end

-- For each
function Table:each( f )
	for i = 1, #self do f( self[i] ) end 
end
function Table:eachiv( f )
	for i = 1, #self do f( i, self[i] ) end 
end
function Table:eachvi( f )
	for i = 1, #self do f( self[i], i ) end 
end
function Table:eachv( f )
	for _,v in pairs( self ) do f( v ) end 
end
function Table:eachk( f )
	for k,_ in pairs( self ) do f( k ) end 
end
function Table:eachkv( f )
	for k,v in pairs( self ) do f( k, v ) end 
end
function Table:eachvk( f )
	for k,v in pairs( self ) do f( v, k ) end 
end

-- Any test
function Table:any( p )
	for i = 1, #self do if p( self[i] ) then 
		return true end 
	end 
	return false 
end
function Table:anyiv( p )
	for i = 1, #self do if p( i, self[i] ) then 
		return true end 
	end 
	return false end
function Table:anyvi( p )
	for i = 1, #self do if p( self[i], i ) then 
		return true end 
	end return false 
end
function Table:anyv( p )
	for _, v in pairs( self ) do if p( v ) then 
		return true end 
	end 
	return false 
end
function Table:anyk( p )
	for k, _ in pairs( self ) do if p( k ) then 
		return true end 
	end 
	return false 
end
function Table:anykv( p )
	for k, v in pairs( self ) do if p( k, v ) then 
		return true end 
	end 
	return false 
end
function Table:anyvk( p )
	for k, v in pairs( self ) do if p( v, k ) then 
		return true end 
	end 
	return false 
end

-- All test
function Table:all( p )
	for i = 1, #self do if not p( self[i] ) then 
		return false end 
	end 
	return true 
end
function Table:alliv( p )
	for i = 1, #self do if not p( i, self[i] ) then 
		return false end 
	end 
	return true 
end
function Table:allvi( p )
	for i = 1, #self do if not p( self[i], i ) then 
		return false end 
	end 
	return true 
end
function Table:allv( p )
	for _, v in pairs( self ) do if not p( v ) then 
		return false end 
	end 
	return true 
end
function Table:allk( p )
	for k, _ in pairs( self ) do if not p( k ) then 
		return false end 
	end 
	return true 
end
function Table:allkv( p )
	for k, v in pairs( self ) do if not p( k, v ) then 
		return false end 
	end 
	return true 
end
function Table:allvk( p )
	for k, v in pairs( self ) do if not p( v, k ) then 
		return false end 
	end 
	return true 
end

-- Counting
function Table:count( p )
	local c = 0
	for i = 1, #self do if p( self[i] ) then c = c + 1 end end 
	return c 
end
function Table:countiv( p )
	local c = 0
	for i = 1, #self do if p( i, self[i] ) then c = c + 1 end end 
	return c 
end
function Table:countvi( p )
	local c = 0
	for i = 1, #self do if p( self[i], i ) then c = c + 1 end end
	return c
end
function Table:countv( p )
	local c = 0
	for _, v in pairs( self ) do if p( v ) then c = c + 1 end end
	return c
end
function Table:countk( p )
	local c = 0
	for k, _ in pairs( self ) do if p( k ) then c = c + 1 end end
	return c
end
function Table:countkv( p )
	local c = 0
	for k, v in pairs( self ) do if p( k, v ) then c = c + 1 end end
	return c
end
function Table:countvk( p )
	local c = 0
	for k, v in pairs( self ) do if p( v, k ) then c = c + 1 end end
	return c
end

-- Partition
function Table:part( f )
	local t1, t2, j, k = {}, {}, 0, 0
	for i = 1, #self do if f( self[i] ) then j = j + 1; t1[j] = self[i] else k = k + 1; t2[k] = self[i] end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 
function Table:partiv( f )
	local t1, t2, j, k = {}, {}, 0, 0
	for i = 1, #self do if f( i, self[i] ) then j = j + 1; t1[j] = self[i] else k = k + 1; t2[k] = self[i] end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 
function Table:partvi( f ) 
	local t1, t2, j, k = {}, {}, 0, 0
	for i = 1, #self do if f( self[i], i ) then j = j + 1; t1[j] = self[i] else k = k + 1; t2[k] = self[i] end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 
function Table:partv( f ) 
	local t1, t2 = {}, {}
	for k, v in pairs( self ) do if f( v ) then t1[k] = v else t2[k] = v end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 
function Table:partk( f ) 
	local t1, t2 = {}, {}
	for k, v in pairs( self ) do if f( k)  then t1[k] = v else t2[k] = v end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 
function Table:partkv( f ) 
	local t1, t2 = {}, {}
	for k, v in pairs( self ) do if f( k, v ) then t1[k] = v else t2[k] = v end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 
function Table:partvk( f ) 
	local t1, t2 = {}, {}
	for k, v in pairs( self ) do if f( v, k ) then t1[k] = v else t2[k] = v end end
	return Table.cpmt( t1, self ), Table.cpmt( t2, self )
end 

-- Unique
function Table:unique()
	local result, checked, j = {}, {}, 0
	for _, v in pairs( self ) do
		if v ~= nil and not checked[v] then
			j = j + 1
			checked[v] = true
			result[j] = v
		end
	end
	return Table.cpmt( result, self )
end

local TableMt = {__index = Table}

function Table.new( _, v )
	return setmetatable( v, TableMt ) 
end

function Table:sort( cmp )
	local result = Table.copy( self )
	table.sort( result, cmp )
	return result
end

Table.concat = table.concat
Table.setmetatable = setmetatable
Table.getmetatable = getmetatable
Table.pairs = pairs
Table.ipairs = ipairs
Table.pack = table.pack or function( ... ) return {...} end
Table.unpack = table.unpack or unpack

return setmetatable( Table, {__call = Table.new} )
