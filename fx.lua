local fx = {}

local loadstring = loadstring or load

local ARGS = {'self','__1','__2','__3','__4','__5','__6','__7','__8','__9'}

local function compile( code )
	return assert( loadstring( 'return function(' .. table.concat(ARGS,',',1,nargs+1) .. ')\n' .. code .. '\nreturn self' ))()
end

local function build( namepattern, head, body )
	fx[namepattern:format('')] = compile( head .. '\nfor i = 1,#self do\nlocal __A = self[i]\n' .. code .. '\nend')
	fx[namepattern:format('k')] = compile( head .. '\nfor k,v in pairs(self) do\nlocal __A = k\n' .. code .. '\nend')
	fx[namepattern:format('v')] = compile( head .. '\nfor k,v in pairs(self) do\nlocal __A = v\n' .. code .. '\nend')
	fx[namepattern:format('kv')] = compile( head .. '\nfor k,v in pairs(self) do\nlocal __A,__B = k,v\n' .. code .. '\nend')
	fx[namepattern:format('vk')] = compile( head .. '\nfor k,v in pairs(self) do\nlocal __A,__B = v,k\n' .. code .. '\nend')
	fx[namepattern:format('iv')] = compile( head .. '\nfor i = 1,#self do\nlocal __A,__B = i,self[i]\n' .. code .. '\nend')
	fx[namepattern:format('iv')] = compile( head .. '\nfor i = 1,#self do\nlocal __A,__B = self[i],i\n' .. code .. '\nend')
end
