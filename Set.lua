local Set = {}
local SetMt

function Set:new( ... )
	local result = {}
	for i = 1, select( '#', ... ) do
		result[select( i, ... )] = true
	end
	return setmetatable( result, SetMt )
end

function Set:intersection( other )
	local result = {}
	for k, v in pairs( self ) do
		if other[k] ~= nil then result[k] = v end
	end
	return setmetatable( result, getmetatable( self ))
end

function Set:union( other )
	local result = {}
	for k, v in pairs( self ) do result[k] = v end
	for k, v in pairs( other ) do result[k] = v end
	return setmetatable( result, getmetatable( self ))
end

function Set:xorunion( other )
	local result = {}
	for k, v in pairs( self ) do if not other[k] then result[k] = v end end
	for k, v in pairs( other ) do if not self[k] then result[k] = v end end
	return setmetatable( result, getmetatable( self ))
end

function Set:difference( other )
	local result = {}
	for k, v in pairs( self ) do
		if other[k] == nil then result[k] = v end
	end
	return setmetatable( result, getmetatable( self ))
end

SetMt = {__index = Set}

return setmetatable( Set, {__call = Set.new} )
