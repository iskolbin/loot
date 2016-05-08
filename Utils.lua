local Utils = {}

function Utils.tostring( arg, saved, ident )
	local t = type( arg )
	saved, ident = saved or {n = 0, recursive = {}}, ident or 0
	if t == 'nil' or t == 'boolean' or t == 'number' or t == 'function' or t == 'userdata' or t == 'thread' then
		return tostring( arg )
	elseif t == 'string' then
		return ('%q'):format( arg )
	else
		if saved[arg] then
			saved.recursive[arg] = true
			return '<table rec:' .. saved[arg] .. '>'
		else
			saved.n = (saved.n or 0) + 1
			saved[arg] = saved.n
			saved.recursive = saved.recursive or {}
			local mt = getmetatable( arg )
			if mt ~= nil and mt.__tostring then
				return mt.__tostring( arg )
			else
				local ret = {}
				local na = #arg
				for i = 1, na do
					ret[i] = Utils.tostring( arg[i], saved, ident )
				end
				local tret = {}
				local nt = 0					
				for k, v in pairs(arg) do
					if not ret[k] then
						nt = nt + 1
						tret[nt] = (' '):rep(ident+1) .. Utils.tostring( k, saved, ident + 1 ) .. ' => ' .. Utils.tostring( v, saved, ident + 1 )
					end
				end
				local retc = table.concat( ret, ',' )
				local tretc = table.concat( tret, ',\n' )
				if tretc ~= '' then
					tretc = '\n' .. tretc
				end
				return '{' .. retc .. ( retc ~= '' and tretc ~= '' and ',' or '') .. tretc .. (saved.recursive[arg] and (' <' .. saved[arg] .. '>}') or '}' )
			end
		end
	end
end

function Utils.copy( arg )
	if type( arg ) == 'table' then
		local result = {}
		for k, v in pairs(arg) do
			result[k] = v
		end
		return setmetatable( result, getmetatable( arg ))
	else
		return arg
	end
end

function Utils.deepcopy( arg_ )
	local function doCopy( arg, t )
		if type( arg ) == 'table' then
			if t[arg] == nil then
				local result = {}
				t[arg] = result
				for k, v in pairs(arg) do
					result[doCopy(k,t)] = doCopy(v,t)
				end
				return setmetatable( result, getmetatable( arg ))
			else
				return t[arg]
			end
		else
			return arg
		end
	end

	return doCopy( arg_, {} )
end

function Utils.print( ... )
	for i = 1, select( '#', ... ) do
		io.write( Utils.tostring( select( i, ... )))
		io.write( ' ' )
	end
	io.write( '\n' )
end

return Utils
