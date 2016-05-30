local Table = require'Table'

local setmetatable, next, select = setmetatable, next, select 

local Generator = {}

local GeneratorMt = {__index = Generator}

function Generator:apply( f, arg )
	self[#self+1] = f
	self[#self+1] = arg
	return self
end

local function domap( g, ... )
	return true, g( ... )
end

function Generator:map( f )
	return self:apply( domap, f )
end

local function dofilter( pred, ... )
	if pred( ... ) then
		return true, ...
	else
		return false
	end
end

function Generator:filter( p )
	return self:apply( dofilter, p )
end

local function dozip( frm, k, v, ... )
	if frm <= 1 then return true, {k, v, ...}
	elseif frm <= 2 then return true, k, {v, ...}
	elseif frm <= 3 then return true, k, v, {...}
	else
		local allargs = {...}
		allargs[frm+1] = {select( frm, ... )}
		allargs[frm+2] = nil
		return true, unpack( allargs ) 
	end
end

function Generator:zip( from )
	return self:apply( dozip, from or 1 )
end

local function doswap( _, x, y, ... )
	return true, y, x, ...
end

function Generator:swap()
	return self:apply( doswap, false )
end

local function dodup( _, x, ... )
	return true, x, x, ...
end

function Generator:dup()
	return self:apply( dodup, false )
end

local function dounique( cache, k, ... )
	if not cache[k] then
		cache[k] = true
		return true, k, ...
	else
		return false
	end
end

function Generator:unique()
	return self:apply( dounique, {} )
end

local function dowithindex( i, ... )
	local index = i[1]
	i[1] = index + i[2]
	return true, index, ...
end

function Generator:withindex( init, step )
	return self:apply( dowithindex, {init or 1, step or 1} )
end

local function dotake( m, ... )
	if m[1] < m[2] then
		m[1] = m[1] + 1
		return true, ...
	end
end

function Generator:take( n )
	return self:apply( dotake, {0, n} )
end

local function dotakewhile( pred, ... )
	if pred( ... ) then
		return true, ...
	end
end

function Generator:takewhile( p )
	return self:apply( dotakewhile, p )
end

local function dodrop( m, ... )
	if m[1] < m[2] then
		m[1] = m[1] + 1
		return false
	else
		return true, ...
	end
end

function Generator:drop( n )
	return self:apply( dodrop, {0,n} )
end

local function dodropwhile( pred, ... )
	if pred[2] and pred[1]( ... ) then
		return false
	else
		pred[2] = false
		return true, ...
	end
end

function Generator:dropwhile( p )
	return self:apply( dodropwhile, {p,true} )
end

local function doupdate( tbl, k, v, ... )
	if tbl[k] then
		return true, k, tbl[k], ...
	else
		return true, k, v, ...
	end
end

function Generator:update( self, utable )
	return self:apply( doupdate, utable )
end

local function dodelete( tbl, k, ... )
	if not tbl[k] then
		return true, k, ...
	else
		return false
	end
end

function Generator:delete( dtable )
	return self:apply( dodelete, dtable )
end

local function doeach( status, ... )
	if status then
		f( ... )
		return doeach( self:next())
	elseif status == false then
		return doeach( self:next())
	end
end

function Generator:each( f )
	return doeach( self:next())
end

local function doreduce( self, f, accum, status, ... )
	if status then
		return doreduce( self, f, f(accum, ...), self:next())
	elseif status == false then
		return doreduce( self, f, accum, self:next())
	else
		return accum
	end
end

function Generator:reduce( f, acc )
	return doreduce( self, f, acc, self:next())
end

local function tablefold( acc, k, v )
	acc[k] = v
	return acc
end

function Generator:table()
	return Table( self:reduce( tablefold, {} )) 
end

local function arrayfold( acc, v )
	acc[#acc+1] = v
	return acc
end

function Generator:array()
	return Table( self:reduce( arrayfold, {} ))
end

local function dosum( accum, status, ... )
	if status then
		return dosum( accum + ..., self:next())
	elseif status == false then
		return dosum( accum, self:next())
	else
		return accum
	end
end

function Generator:sum( acc )
	return dosum( acc or 0, self:next())
end

local function docount( acc, status, ... )
	if status == nil then
		return acc
	elseif status and (p == nil or p(...)) then
		return docount( acc + 1, self:next())
	else
		return docount( acc, self:next())
	end
end

function Generator:count( p )
	return docount( 0, self:next())
end

function Generator:next()
	return self[1]( self )
end

local function reccall( self, i, status, ... )
	if status then
		if self[i] then
			return reccall( self, i+2, self[i]( self[i+1], ... ))
		else
			return status, ...
		end
	else
		return status
	end
end


local Stream = {}

local function evalrangeargs( init, limit, step )
	if not limit then init, limit = init > 0 and 1 or -1, init end
	if not step then step = init < limit and 1 or -1 end
	if (init <= limit and step > 0) or (init >= limit and step < 0) then
		return init, limit, step
	else
		error('bad initial variables for range')
	end
end

local function rangenext( self )
	local index = self[2]
	if index <= self[3] then
		self[2] = index + self[4]
		return reccall( self, 5, true, index )
	end
end

local function rrangenext( self )
	local index = self[2]
	if index >= self[3] then
		self[2] = index + self[4]
		return reccall( self, 5, true, index )
	end
end

function Stream.range( init, limit, step )
	init, limit, step = evalrangeargs( init, limit, step )
	return setmetatable( {step > 0 and rangenext or rrangenext, init, limit, step}, GeneratorMt )
end

local function evalsubargs( tbl, init, limit, step )
	local len = #tbl
	init, limit = init or 1, limit or len
	if init < 0 then init = len + init + 1 end
	if limit < 0 then limit = len + init + 1 end
	if not step then step = init < limit and 1 or -1 end
	if (init <= limit and step > 0) or (init >= limit and step < 0) then
		return init, limit, step
	else
		error('bad initial variables for generator')
	end
end

local function iternext( self )
	local index = self[3]
	local value = self[2][index]
	if value ~= nil and index <= self[4] then
		self[3] = index + self[5]
		return reccall( self, 6, true, value ) 
	end
end

local function riternext( self )
	local index = self[3]
	local value = self[2][index]
	if value ~= nil and index >= self[4] then
		self[3] = index + self[5]
		return reccall( self, 6, true, value ) 
	end
end

function Stream.iter( tbl, init, limit, step )
	init, limit, step = evalsubargs( tbl, init, limit, step )
	return setmetatable( {step > 0 and iternext or riternext, tbl, init, limit, step}, GeneratorMt ) 
end


local function ipairsnext( self )
	local index = self[3]
	local value = self[2][index]
	if value ~= nil and index <= self[4] then
		self[3] = index + self[5]
		return reccall( self, 6, true, index, value ) 
	end
end

local function ripairsnext( self )
	local index = self[3]
	local value = self[2][index]
	if value ~= nil and index >= self[4] then
		self[3] = index + self[5]
		return reccall( self, 6, true, index, value ) 
	end
end

function Stream.ipairs( tbl, init, limit, step ) 
	init, limit, step = evalsubargs( tbl, init, limit, step )
	return setmetatable( {step > 0 and ipairsnext or ripairsnext, tbl, init, limit, step}, GeneratorMt ) 
end

local function pairsnext( self )
	local key, value = next( self[2], self.k )
	if key ~= nil then
		self.k = key
		return reccall( self, 3, true, key, value )
	end
end

function Stream.pairs( tbl ) 
	return setmetatable( {pairsnext, tbl}, GeneratorMt )
end

local function keysnext( self )
	local key, _ = next( self[2], self.k )
	if key ~= nil then
		self.k = key
		return reccall( self, 3, true, key )
	end
end

function Stream.keys( tbl ) 
	return setmetatable( {keysnext, tbl}, GeneratorMt ) 
end

local function valuesnext( self )
	local key, value = next( self[2], self.k )
	if key ~= nil then
		self.k = key
		return reccall( self, 3, true, value )
	end
end

function Stream.values( tbl ) 
	return setmetatable( {valuesnext, tbl}, GeneratorMt )
end

return Stream
