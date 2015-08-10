require('loot').export('serialize')

return {

	-- aand{X1,X2}
	aand = {
		eval = function( self ) return self[1]:eval() and self[2]:eval() end,
		compile = function( self ) return ('((%s)and(%s))'):format( self[1]:compile(), self[2]:compile()) end,
	},

	-- aor{X1,X2}
	aor = {
		eval = function( self ) return self[1]:eval() or self[2]:eval() end,
		compile = function( self ) return ('((%s)and(%s))'):format( self[1]:compile(), self[2]:compile()) end,
	},

	-- anot{X}
	anot = {
		eval = function( self ) return self[1]:eval() end,
		compile = function( self ) return ('(not(%s))'):format(self[1]:compile()) end,
	},

	-- {condition,then-clause[,else-clause]}
	aif = {
		eval = function( self ) return self[1]:eval() and self[2]:eval() or (self[3] and self[3]:eval()) end,
		compile = function( self ) return ('((%s)and(%s)%s)'):format( self[1]:compile(), self[2]:compile(), self[3] and '(' .. self[3]:compile() .. ')' ) end,
	},

	-- self-evaluating
	avar = {
		eval = function( self ) return self[1] end,
		compile = function( self ) return serialize( self[1] ) end,
	},

	-- {body,{...}}
	alet = {
		compile = function( self ) 
			local l, v = self[2] and #self[2] > 0 and unzip( self[2] )
			local l_, v_ = map( l, op.c.selfcall'compile' ), map( v, op.c.selfcall'compile' )
			local var = l and v and (' %s = %s\n'):format( table.concat(l), table.concat(v)) or ''
			return ('do\n%s %s\nend'):format( var, self[1]:compile())
		end,
	}

	aletl = {	
		compile = function( self ) 
			local var = self[2] and #self[2] > 0 and map( self[2], function(x) return(' local %s = %s\n'):format(x[1]:compile(), x[2]:compile())end ) or ''
			return ('do\n%s %s\nend'):format( var, self[1]:compile())
		end,
	}
}

