local loadstring = loadstring or load

local cache = setmetatable( {}, {__mode = 'k'} )

return function( k )
	local f = cache[k]
	if not f then
		f = assert(loadstring( 'return function(_1,_2,_3,_4,_5,_6,...) return ' .. k .. ' end' ))()
		cache[k] = f
	end
	return f
end
