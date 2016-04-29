return {
	add = function( x, y ) return x + y end,
	sub = function( x, y ) return x - y end,
	div = function( x, y ) return x / y end,
	idiv = function( x, y ) if x >= 0 then return math.floor(x/y) else return math.ceil(x/y) end end,
	mul = function( x, y ) return x * y end,
	mod = function( x, y ) return x % y end,
	pow = function( x, y ) return x ^ y end,
	expt = function( x, y ) return y ^ x end,
	log = math.log,
	neg = function( x ) return -x end,
	
	len = function( x ) return #x end,
	
	inc = function( x ) return x + 1 end,
	dec = function( x ) return x - 1 end,
	
	concat = function( x, y ) return x .. y end,
	lconcat = function( x, y ) return y .. x end,
	
	lor = function( x, y ) return x or y end,
	land = function( x, y ) return x and y end,
	lnot = function( x ) return not x end,
	
	gt = function( x, y ) return x >  y end,
	ge = function( x, y ) return x >= y end,
	lt = function( x, y ) return x <  y end,
	le = function( x, y ) return x <= y end,
	eq = function( x, y ) return x == y end,
	ne = function( x, y ) return x ~= y end,
	
	index = function( x, y ) return x[y] end,
	newindex = function( x, y, z ) x[y] = z end,
	
	const = function( x ) return x end,
	call = function( x, y ) return x( y ) end,
	swap = function( x, y ) return y, x end,
}
