local Utils = require'Utils'
local Match = require'Match'

local Table = {
	equal = Match.equal,
	tostring = Utils.tostring,
}

function Table.match( ... )
	local result = Match.match( ... )
	if result then
		return Table:new( result )
	end
end

function Table:indexof( item )
	for i = 1, #self do
		if self[i] == item then
			return i
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

function Table:copy()
	local out = {}
	for k, v in pairs(self) do
		out[k] = v
	end
	return out
end

function Table:each( f )
	for k, v in pairs( self ) do
		f( v, k ) 
	end 
end

function Table:reduce( f, acc )
	for k, v in pairs( self ) do	
		acc = f( v, acc, k )
	end
	return acc
end

function Table:foldl( f, acc )
	for i = 1, #self do
		acc = f( self[i], acc )
	end
	return acc
end

function Table:foldr( f, acc )
	for i = #self, 1, -1 do
		acc = f( self[i], acc )
	end
	return acc
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
	local oarray = Table.copy(self)
	for i = #self, 1, -1 do
		local j = rand( i )
		oarray[j], oarray[i] = oarray[i], oarray[j]
	end
	return oarray
end

function Table:sub( init_, limit_, step_ )
	local init, limit, step = init_, limit_ or #self, step_ or 1

	if init < 0 then init = #self + init + 1 end
	if limit < 0 then limit = #self + limit + 1 end

	local oarray, j = {}, 0
	for i = init, limit, step do
		j = j + 1
		oarray[j] = self[i]
	end
	return setmetatable( oarray, Table )
end

function Table:reverse()
	local oarray, n = {}, #self + 1
	for i = n, 1, -1 do
		oarray[n - i] = self[i]
	end
	return setmetatable( oarray, Table )
end

function Table:insertat( toinsert, pos_ )
	local n, m, oarray = #self, #toinsert, {}
	local pos = pos_ or n+1
	pos = pos < 0 and n + pos + 2 or pos
	if pos <= 1 then
		for i = 1, m do oarray[i] = toinsert[i] end
		for i = 1, n do oarray[m+i] = self[i] end
	elseif pos > n then
		for i = 1, n do oarray[i] = self[i] end
		for i = 1, m do oarray[i+n] = toinsert[i] end
	else
		for i = 1, pos-1 do oarray[i] = self[i] end
		for i = 1, m do oarray[i+pos-1] = toinsert[i] end
		for i = pos, n do oarray[i+m] = self[i] end
	end
	return setmetatable( oarray, Table )
end

function Table:remove( toremove, cmp )
	local oarray, j = {}, 0
	for i = 1, #self do
		local v = self[i]
		if Table.indexof( toremove, v, cmp ) == nil then
			j = j + 1
			oarray[j] = v
		end
	end
	return setmetatable( oarray, Table )
end

function Table:partition( p )
	local oarray, j, k = {setmetatable({}, Table),setmetatable({}, Table)}, 0, 0
	for i = 1, #self do
		if p( self[i] ) then
			j = j + 1
			oarray[1][j] = self[i]
		else
			k = k + 1
			oarray[2][k] = self[i]
		end
	end
	return setmetatable( oarray, Table )
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

	local oarray, j = {}, 0
	for i = 1, #self do 
		j = doFlatten( oarray, self[i], j ) 
	end
	return setmetatable( oarray, Table )
end

function Table:count( p )
	local n = 0
	for k, v in pairs( self ) do
		if p( k, v ) then
			n = n + 1
		end
	end
	return n
end

function Table:all( f )
	for k, v in pairs( self ) do
		if not f( v, k ) then
			return false
		end
	end
	return true
end

function Table:any( f )
	for k, v in pairs( self ) do
		if not f( v, k ) then
			return true
		end
	end
	return false
end

function Table:filter( p )
	local out, j = {}, 0
	for k, v in pairs( self ) do
		if p( v, k ) then
			j = j + 1
			out[j] = v
		end
	end
	return setmetatable( out, Table )
end

function Table:map( f )
	local oarray = {}		
	for i = 1, #self do
		oarray[i] = f( self[i] )
	end
	return setmetatable( oarray, Table )
end

function Table:keys()
	local oarray, i = {}, 0
	for k, _ in pairs( self ) do
		i = i + 1
		oarray[i] = k
	end
	return setmetatable( oarray, Table )
end

function Table:values()
	local oarray, i = {}, 0
	for _, v in pairs( self ) do
		i = i + 1
		oarray[i] = v
	end
	return setmetatable( oarray, Table )
end

local TableMt = {__index = Table}

function Table.new( _, v )
	return setmetatable( v, TableMt ) 
end

return setmetatable( Table, {__call = Table.new, __index = table} )
