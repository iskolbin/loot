local Match = {
	Wild = {},
	Rest = {},
	Var = {},
	RestVar = {},
}

Match._ = Match.Wild
Match.___ = setmetatable( {'___'}, Match.RestVar )
Match.X = setmetatable( {'X'}, Match.Var )
Match.Y = setmetatable( {'Y'}, Match.Var )
Match.Z = setmetatable( {'Z'}, Match.Var )
Match.N = setmetatable( {'N', function(v) return type(v) == 'number' end}, Match.Var )
Match.S = setmetatable( {'S', function(v) return type(v) == 'string' end}, Match.Var )
Match.B = setmetatable( {'B', function(v) return type(v) == 'boolean' end}, Match.Var )
Match.F = setmetatable( {'F', function(v) return type(v) == 'function' end}, Match.Var )
Match.T = setmetatable( {'T', function(v) return type(v) == 'thread' end}, Match.Var )
Match.U = setmetatable( {'U', function(v) return type(v) == 'userdata' end}, Match.Var )

function Match.equal( itable1, itable2 )
	if itable1 == itable2 or itable2 == Match.Wild or itable2 == Match.Rest then
		return true
	elseif getmetatable( itable2 ) == Match.Var then
		return not itable2[2] or itable2[2]( itable1 )
	else
		local t1, t2 = type( itable1 ), type( itable2 )
		if t1 == t2 and t1 == 'table' then
			local k1, k2 = next( itable1 ), next( itable2 )

			while k1 ~= nil and k2 ~= nil do
				k1, k2 = next( itable1, k1 ), next( itable2, k2 )
			end

			local last2 = itable2[#itable2]
			if (k1 == nil and k2 == nil) or last2 == Match.Rest or getmetatable( last2 ) == Match.RestVar then
				for k, v in pairs( itable2 ) do
					local v1 = itable1[k]
					if v1 ~= v then
						if v == Match.Rest then
							return true
						elseif getmetatable( v ) == Match.RestVar then
							if v[2] then
								local rest = {v1}
								for _, v_ in next, itable1, k do
									rest[#rest+1] = v_
								end
								return v[2]( rest )
							else
								return true
							end
						elseif itable1[k] == nil or not Match.equal( v1, v ) then
							return false
						end
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
end

local function doMatch( itable1, itable2, matchtable )
	if itable1 == itable2 or itable2 == Match.Wild or itable2 == Match.Rest then
		return true
	elseif getmetatable( itable2 ) == Match.Var then
		if not itable2[2] or itable2[2]( itable1 ) then
			matchtable[itable2[1]] = itable1
			return true
		else
			return false
		end
	else
		local t1, t2 = type( itable1 ), type( itable2 )
		if t1 == t2 and t1 == 'table' then
			local n1 = 0; for _, _ in pairs( itable1 ) do n1 = n1 + 1 end
			local n2 = 0; for _, _ in pairs( itable2 ) do n2 = n2 + 1 end
			local last2 = itable2[#itable2]
			local mt2 = getmetatable( last2 )
			if n1 == n2 or last2 == Match.Rest or mt2 == Match.RestVar then
				for k, v in pairs( itable2 ) do
					local v1 = itable1[k]
					if v == Match.Rest then
						return true
					elseif getmetatable( v ) == Match.RestVar then
						local rest = {v1}
						for _, v_ in next, itable1, k do
							rest[#rest+1] = v_
						end
						if not v[2] or v[2]( rest ) then
							matchtable[v[1]] = rest
							return true
						else
							return false
						end
					elseif itable1[k] == nil or not doMatch( v1, v, matchtable ) then
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
end

function Match.match( a, b, ... )
	local acc = {}
	local result = doMatch( a, b, acc ) 
	if result then
		return acc
	else
		local n = select( '#', ... )
		for i = 1, n do
			acc = next( acc ) == nil and acc or {}
			result = doMatch( a, select( i, ... ), acc )
			if result then 
				return acc
			end
		end
		return result
	end
end

return Match
