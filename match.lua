require('loot').export('slice','copy','pp','serialize')

local VarMT = {__tostring = function( self ) return self.name end}

local function var( name )
	return setmetatable( {name = name, wild = name:sub(1,1) == '_', rest = name:sub(1,3) == '...'}, VarMT )
end

local function findpaths( t, path, paths, vars )
	local path, paths, vars = path or {}, paths or {}, vars or {}
	if type( t ) == 'table' then
		for k, v in pairs( t ) do
			path[#path+1] = k
			if getmetatable( v ) == VarMT then
				vars[v] = vars[v] or {}
				paths[#paths+1] = copy( path )
				table.insert( vars[v], paths[#paths] )
			elseif type( v ) ~= 'table' then
				paths[#paths+1] = copy( path )
			else
				findpaths( v, path, paths, vars )
			end
			path[#path] = nil
		end
	end
	return paths, vars
end

local function pathtostr( path )
	return '[' .. table.concat( path, '][' ) .. ']'
end

local function getbypath( t, path )
	local t_ = t
	for i = 1, #path do t_ = t_[path[i]] end
	return t_
end

local function matcher( clauses )
	local funcache = {}
	local init = {}
	local code = {'return function(t)\n'}
	for i = 1, #clauses do
		local capturesneeded = false
		local clause, result, when = clauses[i][1], clauses[i][2], clauses[i][3]
		local ct = type( clause )
		local whencall, resultcall = '', ''
		if when then
			if not funcache[when] then
				init[#init+1] = ('local _when%d = loadstring(%q)\n'):format( i, string.dump( when ))
				funcache[when] = '_when' .. i
			else
				init[#init+1] = ('local _when%d = %s\n'):format( i, funcache[when] )
			end
			whencall = ('_when%d( t, _captures )'):format( i )
			capturesneeded = true
		end

		if type(result) == 'function' then
			if not funcache[result] then
				init[#init+1] = ('local _result%d = loadstring(%q)\n'):format( i, string.dump( result ))
				funcache[result] = '_result' .. i
			else
				init[#init+1] = ('local _result%d = %s\n'):format( i, funcache[result] )
			end
			resultcall = ('_result%d( t, _captures )'):format( i )
			capturesneeded = true
		end
		
		code[#code+1] = ' --' .. i .. '\n'
		if ct == 'table' and getmetatable( clause ) ~= VarMT then
			local typecheckpos
			if not clauses.notypecheck then 
				code[#code+1] = ' if true then\n' 
				typecheckpos = #code	
			else
				code[#code+1] = ' do\n'
			end

			local paths, vars = findpaths( clause )
			local varpaths = {}
			local captures = {}
			local kvars = {}
			local vvars = {}
			
			local typecheckcond = clauses.notypecheck and {} or {'(type(t)=="table")', '(#t>=' .. #clause .. ')'}

			for v, path in pairs( vars ) do
				if not v.wild then
					varpaths[path[1]] = true
					kvars[#kvars+1] = v.name
					vvars[#vvars+1] = 't' .. pathtostr( path[1] )
					captures[#captures+1] = ('%s=%s'):format( v.name, v.name )
					if not clauses.notypecheck then typecheckcond[#typecheckcond+1] = '(type(t' .. pathtostr( slice( path[1],-2) ) .. ')=="table")' end
				end
			end

			if #kvars > 0 then
				code[#code+1] = ('  local %s = %s\n'):format( table.concat( kvars, ',' ), table.concat( vvars,','))
			end	
			if capturesneeded then
				code[#code+1] = ('  local _captures = {%s}\n'):format( table.concat( captures, ',' ))
			end
			local cond = {}
			for j = 1, #paths do
				local x = getbypath( clause, paths[j] )
				if not( getmetatable( x ) == VarMT and x.wild ) and not varpaths[paths[j]] then
					if not clauses.notypecheck then
						typecheckcond[#typecheckcond+1] = '(type(t' .. pathtostr( slice( paths[j],-2) ) .. ')=="table")'
					end
					cond[#cond+1] = '( t' .. pathtostr( paths[j] ) .. ' == ' .. tostring( getbypath( clause, paths[j] )) .. ' )'
				end
			end

			if when then
				cond[#cond+1] = whencall
			end
			
			local _result = type( result ) == 'function' and resultcall or serialize( result )
			if #cond > 0 then
				code[#code+1] = ('  if %s then\n   return %s\n  end\n'):format( table.concat( cond, ' and ' ), _result )
			else
				code[#code+1] = ('  return %s\n'):format( _result )
			end
			if not clauses.notypecheck then
				code[typecheckpos] = (' if %s then\n'):format( table.concat( typecheckcond, ' and ' ))
			end
			code[#code+1] = ' end\n'
		elseif getmetatable( clause ) == VarMT then
			if clause.wild or clause.rest then
				code[#code+1] = (' return %s\n'):format( serialize( result ))
			else
				if capturesneeded then
					if capturesneeded then
						code[#code+1] = ('  local _captures = {%s}\n'):format( clause.name .. '=' .. clause.name )
					end
					if when then
						code[#code+1] = ('  if %s then\n   return %s\n  end\n'):format( whencall, _result )
					else
						code[#code+1] = ('  return %s\n'):format( _result )
					end
				end
			end
		elseif ct ~= 'function' then
			code[#code+1] = ('  return %s\n'):format( serialize( result ))
		end
	end
	code[#code+1] = 'end\n'

	local source = table.concat( init ).. table.concat( code )

	if clauses.printcode then
		print( source )
	end
	return assert(loadstring( table.concat( init ) .. table.concat( code )))()
end

return {
	matcher = matcher,
	var = var,
}
