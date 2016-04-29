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
			saved.n = saved.n + 1
			saved[arg] = saved.n
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

return Utils
