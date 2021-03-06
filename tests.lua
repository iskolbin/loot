require('loot').export()

local _assert = assert
local _count = 0
local function assert( v )
	_count = _count + 1
	return _assert( v )
end

assert( predicates.n( nil ))
assert( predicates.t( true ))
assert( predicates.f( false ))
assert( predicates.boolean( true ) and predicates.boolean( false ))
assert( predicates.number( 5e4))
assert( predicates.integer( 1 ) and not predicates.integer( 1.5 ))
assert( predicates.string( "" ))
assert( predicates.table( {} ))
assert( predicates.lambda( function() end ))
assert( predicates.thread( coroutine.create(function() end )))
assert( predicates.userdata( io.tmpfile()))
assert( predicates.zero( 0 ))
assert( predicates.positive( 5 ))
assert( predicates.negative( -5))
assert( predicates.even( 2 ))
assert( predicates.odd( 5 ))
assert( predicates.id( "abc" ))

assert( is.n( nil ))
assert( is.t( 3 == 3 ))
assert( is.f( 5 < 2 ))
assert( is.boolean( 2 == 5 ))
assert( is.number( 5 ))
assert( is.integer( 1 ))
assert( is.string"some" )
assert( is.table{} )
assert( is.lambda( math.sin ))
assert( is.thread( coroutine.create( function() end )))
assert( is.userdata( io.tmpfile()))
assert( is.zero(0))
assert( is.positive( 5 ))
assert( is.negative( -5 ))
assert( is.even( 52 ))
assert( is.odd( 31 ))
assert( is.id( "__AUS" ))

assert( isnot.n( 5 ))
assert( isnot.t( 3 > 5 ))
assert( isnot.f( 3 < 5 ))
assert( isnot.boolean"" )
assert( isnot.number( 5 == 5 ))
assert( isnot.integer( 1.2 ))
assert( isnot.string( print))
assert( isnot.table( true ))
assert( isnot.thread( nil ))
assert( isnot.userdata( 2 ))
assert( isnot.zero(-1))
assert( isnot.positive( -4 ))
assert( isnot.negative( 5 ))
assert( isnot.even( 45 ))
assert( isnot.odd( 62 ))
assert( isnot.id( "23fz" ) and isnot.id("@41") and isnot.id("  ads"))

assert( all( {1,3,5,3,9,7}, is.odd ) and all({k = 6, v = 8, y = 3,4,1}, is.integer ))
assert( any( {4,3,1,'x',3,5}, is.string ) and any({k = 15, v = math.sin, 4,1,false}, isnot.thread ))

assert( op.add( 4, 10 ) == 14 )
assert( op.sub( 12, 20 ) == -8 )
assert( op.div( 4, 8 ) == 0.5 )
assert( op.idiv( 10, 4 ) == 2 )
assert( op.idiv( -10, 4 ) == -2 )
assert( op.mul( 5, 3 ) == 15 )
assert( op.mod( 10, 3 ) == 1 )
assert( op.pow( 2, 5 ) == 2^5 )
assert( op.expt( 2, 5 ) == 5^2 )
assert( op.log( 5,3 ) == math.log( 5,3))
assert( op.neg( 100 ) == -100 )
assert( op.len({1,2,3} ) == 3 )
assert( op.inc( 2 ) == 3 )
assert( op.dec( -10 ) == -11 )
assert( op.concat( "Hi ", "there" ) == "Hi there" )
assert( op.lconcat( "roof", "From ") == "From roof" )
assert( op.lor( 2 > 5, 3 < 4 ))
assert( op.land( 5 > 2, is.even( 2 )))
assert( op.lnot( false ))
assert( op.gt( 5, 3 ) and not op.gt( 5, 5 ))
assert( op.ge( 5, 3 ) and op.ge( 5, 5 ))
assert( op.lt( 3, 5 ) and not op.lt( 3, 3 ))
assert( op.le( 3, 5 ) and op.le( 3, 3 ))
assert( op.eq( 4, 4 ) and not op.eq( 4, 5 ))
assert( op.ne( 4, 5 ) and not op.ne( 4, 4 ))
assert( op.at({1,2,3,4,5},3) == 3 )
assert( op.of( 3,{1,2,3,4,5}) == 3 )
assert( op.const( 5 ) == 5 )
assert( op.call( math.sin, 1 ) == math.sin( 1 ))
assert( op.fun( 1, math.cos ) == math.cos( 1 ))
assert( op.selfcall( {b = true, x = function(self) return self.b end}, 'x' ))
assert( op.selffun( 'x', {b = true, x = function(self) return self.b end} ))

assert( cr.add( 5 )( 4 ) == 9 )
assert( cr.sub( 10 )( 4 ) == -6 )
assert( cr.div( 5 )(25 ) == 5 )
assert( cr.idiv( 2 )(11) == 5 )
assert( cr.idiv( 2 )(-11) == -5 )
assert( cr.mul( 3 )( 5 ) == 15 )
assert( cr.mod( 2 )( 10 ) == 0 )
assert( cr.pow( 5 )( 3 ) == 3^5 )
assert( cr.expt( 5 )( 3 ) == 5^3 )
assert( cr.log( 2 )( 10 ) == math.log(10,2))
assert( cr.concat( " to add?")"What" == "What to add?" )
assert( cr.lconcat( "By ")"the way" == "By the way" )
assert( cr.lor( 5 )( nil ) == 5 )
assert( cr.land( false )(true ) == false )
assert( cr.gt( 5 )(10 ) and not cr.gt( 5 )(5))
assert( cr.ge( 5 )( 10 ) and cr.ge( 5 )(5))
assert( cr.lt( 10 )( 5 ) and not cr.lt( 10 )( 10 ))
assert( cr.le( 10 )( 5 ) and cr.le( 10 )( 10 ))
assert( cr.eq( 5 )( 5 ) and not cr.eq( 5 )( 10 ))
assert( cr.ne( 5 )( 10 ) and not cr.ne( 10 )( 10 ))
assert( cr.at( 5 ){1,2,3,4,'x'} == 'x' )
assert( cr.of({1,-2,3,4,5})(2) == -2 )
assert( cr.call( 2 )(math.sin) == math.sin( 2 ))
assert( cr.fun( math.cos )(2) == math.cos(2))
assert( cr.selfcall( 'xyz', {v = 2, xyz = function(self) return self.v end} ))
assert( cr.selffun( {x = 5, f = function(self) return self.x == 5 end} )('f'))

assert( curry( math.log, 2 )( 53 ) == math.log( 53, 2 ))

assert( compose{ math.sin, math.cos, math.tan }(2) == math.tan(math.cos(math.sin(2))))
assert( cand( is.even, is.positive )( 4 ))
assert( cor( cr.gt(10), is.odd )(5)) 
assert( cand( is.even, is.number, is.integer, isnot.zero, cr.gt(5), cr.lt(10))( 6 ))
assert( pipe( 5, cr.add(10), cr.mul(50), cr.div(30), math.sin, op.neg, {math.log,2}  ) == math.log(-math.sin(((5+10)*50)/30),2))

assert( equal( {1,2,3}, {1,2,3} ))
assert( equal( map({2,4,6,8},op.inc), {3,5,7,9} ))
assert( equal( imap({1,2,3,4,4},op.sub), {0,0,0,0,1} ))
assert( equal( vmap({x = 2, y = 3}, op.dec), {x = 1, y = 2} ))
assert( equal( kmap({x = 5, y = false},cr.concat("z")), {x = "xz", y = "yz"} ))
assert( equal( vkmap({[4] = 8, [5] = 9},op.div), {[4] = 8/4, [5] = 9/5} ))
assert( equal( kvmap({[4] = 8, [5] = 9},op.div), {[4] = 4/8, [5] = 5/9} ))

local t = {1,2,3}
assert( equal( mapI(t,op.inc), {2,3,4} ) and equal( t, {2,3,4} ))
assert( equal( imapI(t,op.sub), {-1,-1,-1}) and equal( t, {-1,-1,-1} ))
local t = {x = 10, y = 20, z = 30}
assert( equal( vmapI(t,cr.mul(2)), {x=20,y=40,z=60}) and equal(t,{x=20,y=40,z=60}))
local t = {[5] = 10, [10] = 20, [30] =-30}
assert( equal( kmapI(t,cr.add(5)), {[5]=10, [10]=15, [30]=35}) and equal(t,{[5]=10,[10]=15,[30]=35}))
assert( equal( vkmapI(t,op.sub),{[5]=5,[10]=5,[30]=5}) and equal(t,{[5]=5,[10]=5,[30]=5} ))
assert( equal( kvmapI(t,op.div),{[5]=1,[10]=2,[30]=6}) and equal(t,{[5]=1,[10]=2,[30]=6} ))

assert( equal( filter({1,2,3,4,5,6,7,8,9,10},is.odd), {1,3,5,7,9} ))
assert( equal( ifilter({1,2,4,3,5},op.ne), {4,3} ))
assert( equal( ifilter({1,2,3,4,5},is.odd), {1,3,5} ))
assert( equal( vfilter({x = 20, y = 40}, cr.lt(30)), {x=20} ))
assert( equal( kfilter({[-10] = 2, [20] = 30, [5] = 4}, is.even ), {[-10]=2,[20]=30} ))
assert( equal( vkfilter({[30]=30,x = "xxx",y = "y",[20]=30},op.eq), {[30]=30,y="y"} ))
assert( equal( kvfilter({[10] = 20, [-5] = -20, [20] = 10},op.gt),{[-5]=-20,[20]=10} ))

local t = {2,3,4}
assert( equal( filterI(t,is.even),{2,4}) and equal(t,{2,4} ))
local t = {1,3,2,4}
assert( equal( ifilterI( t,op.ne),{3,2}) and equal( t, {3,2} ))
local t = {x = 20, y = 40}
assert( equal( vfilterI(t, cr.lt(30)), {x=20} ) and equal( t,{x=20}))
local t = {[-10] = 2, [20] = 30, [5] = 4}
assert( equal( kfilterI(t, is.even ), {[-10]=2,[20]=30} ) and equal(t,{[-10]=2,[20]=30}))
local t = {[30]=30,x = "xxx",y = "y",[20]=30}
assert( equal( vkfilterI(t,op.eq), {[30]=30,y="y"} ) and equal(t,{[30]=30,y="y"}))
assert( equal( kvfilterI({[10] = 20, [-5] = -20, [20] = 10},op.gt),{[-5]=-20,[20]=10} ))


assert( equal( mapfilter({1,2,3,4,5,6,7,8,9,10},cr.add(2),is.odd), {3,5,7,9,11} ))
assert( equal( imapfilter({0,1,3,2,0},op.add, op.eq), {1,5} ))
assert( equal( imapfilter({1,2,3,4,5},cr.add(2), is.odd), {3,5,7} ))
assert( equal( vmapfilter({x = 20, y = 40}, cr.sub(10), cr.lt(30)), {x=10} ))
assert( equal( kmapfilter({[-10] = 2, [20] = 30, [5] = 4}, cr.add(4), is.even ), {[-10]=-6,[20]=24} ))
assert( equal( vkmapfilter({[30]=30,x = "xxx",y = "y",[20]=30,[''] = ''}, op.concat, op.ne), {[30]="3030",y="yy",x="xxxx",[20] = "3020"} ))
assert( equal( kvmapfilter({[10] = 20, [-5] = -20, [20] = 10},cr.mul(-1), op.gt),{[10]=-10,[20]=-20} ))

local t = {2,3,4}
assert( equal( mapfilterI(t,cr.add(4), is.even),{6,8}) and equal(t,{6,8} ))
local t = {2,4,3,5}
assert( equal( imapfilterI( t,function(i,v)return v-1 end, op.ne),{3,2}) and equal( t, {3,2} ))
local t = {x = 20, y = 40}
assert( equal( vmapfilterI(t, cr.add(5), cr.lt(30)), {x=25} ) and equal( t,{x=25}))
local t = {[-10] = 2, [20] = 30, [5] = 4}
assert( equal( kmapfilterI(t, cr.add(5), is.even ), {[-10]=-5,[20]=25} ) and equal(t,{[-10]=-5,[20]=25}))
local t = {[30]=30,x = "xxx",y = "y",[20]=30,[''] = ''}
assert( equal( vkmapfilterI(t,op.concat, op.ne), {[30]='3030',y="yy",x='xxxx',[20]='3020'} ) and equal(t,{[30]='3030',y="yy",x='xxxx',[20]='3020'}))
assert( equal( kvmapfilterI({[10] = 20, [-5] = -20, [20] = 10},cr.mul(-1), op.gt),{[10]=-10,[20]=-20} ))

assert( foldl( {1,2,3,4}, op.add ) == 10 )
assert( foldl( {'x','y','z'}, op.concat ) == 'xyz' )
assert( foldl( {1,2,3,4},op.sub,10) == 0 )
assert( ifoldl( {2,4,6}, function(acc,i,v)return acc + v/i end ) == 6 )
assert( foldr( {'x','y','z'},op.lconcat) == 'xyz' )
assert( ifoldr( {10,20,30}, function(acc,i,v)return acc + v*i end) == 80 )
assert( vfold( {x = 5, y = 10, z = 20}, op.sub, 30) == -5 )
assert( vkfold( {10,20,30,x=5,y=6}, function(acc,v,k) if is.number(k) then
	return acc + v else return acc end end, 0 ) == 60 )
assert( kvfold( {20,40,5,x = 15,y = 30}, function(acc,k,v) if is.string(k) then
	return acc + v else return acc end end, 10 ) == 55 )
assert( sum{1,5,9,10} == 25 )
assert( product{2,4,10} == 80 )

local i = 0
each( {1,2,3,5}, function(j) i = i + j end )
assert( i == 11 )
ieach( {1,2,3,5}, function(j,v) if j == 4 then i = v end end )
assert( i == 5 )
veach( {x = 10, y = -10, z = 3}, function(v) if is.odd(v) then i = v end end )
assert( i == 3 )
keach( {x = 5, z = 3, [5] = 2}, function(k) if is.number(k) then i = k end end )
assert( i == 5 )
kveach( {[5] = 6, [7] = 8}, function(k,v) i = i + k - v end )
assert( i == 3 )
vkeach( {k = 3, z = 12}, function(v,k) if k == 'z' then i = v end end )
assert( i == 12 )

assert( equal( append({1,2,3},{'x','y','z'}), {1,2,3,'x','y','z'} ))
assert( equal( prepend({1,2,3},{'x','y','z'}), {'x','y','z',1,2,3} ))
assert( equal( inject({1,2,3,4,5},{'x','y','z'},3),{1,2,'x','y','z',3,4,5} ))
assert( equal( reverse{1,2,3,4,1},{1,4,3,2,1} ))
local r = {1,2,3,4,5,6,7,8,9,10}
assert( equal( slice( r, 1,5 ), {1,2,3,4,5} ))
assert( equal( slice( r, 4 ), {4,5,6,7,8,9,10} ))
assert( equal( slice( r, 1,-3), {1,2,3,4,5,6,7,8} ))
assert( equal( slice( r, -2 ), {9,10} ))
assert( equal( slice( r, 2, 4), {2,3,4} ))
assert( equal( slice( r, 2,-2), {2,3,4,5,6,7,8,9} ))
assert( equal( slice( r, -10, -10 ), {1} ))
assert( equal( reverse{1,2,3,4,5}, {5,4,3,2,1} ))
assert( equal( frompairs( topairs{k = 55, z = 33, v = 'xx'} ), frompairs{{'k',55},{'z',33},{'v','xx'}})) 
assert( equal( frompairs{{'xxx',55},{'v',{3}},{5,'g'}}, {xxx=55, v = {3}, [5] = 'g'}))
assert( equal( flatten{{1,2,{3},4,5,6},7,{8,{{{9}}}}}, {1,2,3,4,5,6,7,8,9} ))
assert( equal( unique{1,1,2,3,4,5,1,2}, {1,2,3,4,5} ))
assert( equal( update({1,2,3,4,5}, {[3] = 'z',[5] = 'q'}), {1,2,'z',4,'q'} ))
assert( equal( update({k = 15, v = 24}, {k = 17, z = 3, 1}), {1,k = 17, z=3, v=24}))
assert( equal( flatten{1,2,3,{4,5,{6,7,{8},9},10,{11,{12}},13},14,{15}}, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15} ))

assert( traverse( _G, function(v,k,level) if k == 'sin' then return v(7) end end ) == math.sin(7))

local x = {1,2,3}
assert( equal( appendI(x,{'x','y','z'}), {1,2,3,'x','y','z'} ))
assert( equal( prependI(x,{'x','y','z'}), {'x','y','z',1,2,3,'x','y','z'} ))
assert( equal( injectI(x,{'X','Y','Z'},3),{'x','y','X','Y','Z','z',1,2,3,'x','y','z'} ))
assert( equal( reverseI(x),{'z','y','x',3,2,1,'z','Z','Y','X','y','x'} ))
assert( equal( updateI(x, {[12] = null,[11] = null,[10]=null,[9]=null,[8]=null}), {'z','y','x',3,2,1,'z'} ))

assert( equal( indexof( {1,2,3,4,5,6,7,8,9,10}, 5  ), 5 ))
assert( equal( indexof( {1,2,3,4,5,6,7,8,9,10}, 5, true ), 5 ))
assert( equal( indexof( {10,9,8,7,6,5,4,3,2,1}, 5, op.gt ), 6 ))
assert( equal( indexofq( {{1},{2},{3},{4},{5}}, {3} ), 3 ))
assert( equal( indexofq( {{k=2},{k=3},{k=1},{k=4},{k=12},{k='z'}}, 4, function(a,b) return a.k == 4 end ), 4)) 
assert( equal( keyof( {k = 4, z = 88, y = 15}, 88), 'z' ))
assert( equal( keyofq( {k = {4}, v = {12}, z = {x=55}}, {x=55} ), 'z' ))
assert( equal( keyofq( {k = {x = 3, y = 8}, v = {x = 4, y = 5}}, '', function(a,b) return a.x == 3 and a.y == 8 end ), 'k'))
assert( equal( sort{1,2,3,4,5,1,2,3,4,5}, {1,1,2,2,3,3,4,4,5,5} ))
assert( equal( sort({1,2,3,4,5,1,2,3,4,5},op.gt), {5,5,4,4,3,3,2,2,1,1} ))
local x = {1,2,3,4,5,1,2,3,4,5}
assert( equal( sortI(x), {1,1,2,2,3,3,4,4,5,5} ) and equal(x,{1,1,2,2,3,3,4,4,5,5}))
local x = {1,2,3,4,5,1,2,3,4,5}
assert( equal( sortI(x,op.gt), {5,5,4,4,3,3,2,2,1,1} ) and equal(x,{5,5,4,4,3,3,2,2,1,1}))

assert( equal( {partition( {1,2,3,4,5,6,7,8,9,10}, is.odd )}, {{1,3,5,7,9},{2,4,6,8,10}} ))
assert( equal( {ipartition( {1,2,3,4,5,6}, cr.lt(3))}, {{1,2},{3,4,5,6}} ))
assert( equal( {vpartition( {x = 5, y = 6, z = 9}, is.even)},{{y=6},{x=5,z=9}} ))
assert( equal( {kpartition( {x = 5, ['!!'] = 9, b = 4}, is.id)},{{x=5,b=4},{['!!']=9}} ))
assert( equal( {vkpartition( {x = 'x', y = 'y', z = 22, [5] = 'x'}, function(v,k) return is.number(k) and is.string(v) end)}, {{[5]='x'},{x='x',y='y',z=22}} ))
assert( equal( {kvpartition( {x = 'x', y = 'y', z = 22, [5] = 'x'}, function(k,v) return is.number(k) and is.string(v) end)}, {{[5]='x'},{x='x',y='y',z=22}} ))

assert( equal( zip({1,2,3,4,5},{'x','y','z'},{true,true,false,false}), {{1,'x',true},{2,'y',true},{3,'z',false}} ))
assert( equal( {unzip{{'mig',29,4},{'su',37,5},{'yak',1,2}}},{{'mig','su','yak'},{29,37,1},{4,5,2}}))

assert( equal( newtable(5), {false,false,false,false,false} ))
assert( equal( #newtable(100), 100 ))
assert( equal( sort(keys{x = 5, y = 10, z = 14}), sort({'x','y','z'}) ))
assert( equal( sort(values{x = 5, y = 10, z = 14}),sort({5,10,14}) ))
local cmppairs = function(a,b) return a[1] > b[1] end
assert( equal( sort(topairs{x=5,y=10,z=14},cmppairs),sort({{'x',5},{'y',10},{'z',14}},cmppairs) ))
assert( equal( frompairs{{'x',5},{'y',10},{'z',14}}, {x=5,y=10,z=14} ))
assert( equal( fromlists( tolists{x = 5, y=10,z=14} ), {x=5,y=10,z=14}))
assert( equal( fromlists({'x','y','z'},{5,10,14}), {x=5,y=10,z=14} ))
assert( equal( pack(1,2,3,4,5), {1,2,3,4,5} ))

assert( equal( wild, nil ))
assert( equal( wild, type ))
assert( equal( wild, coroutine.create( function() end )))
assert( equal( wild, 55 ))
assert( equal( wild, null ))
assert( equal( wild, 'xxx' ))
assert( equal( match( {1,2,3,4,5}, {1,2,wild,capture'X',5} ), mt{X=4} ))
assert( equal( match( {1,2,3,{1,2},5}, {1,2,3,{1,capture'Y'},5} ), mt{Y=2}) )

assert( equal( count{1,1,3,3,4,3,2,10}, {[1] = 2, [3] = 3, [2] = 1, [10] = 1, [4] = 1} ))
assert( nkeys{k= 4, v = 5, 3, 2, 1} == 5 )

local t = {x = 5, y = 10, v = {}}
local v = {t,t}

assert( equal( copy(t), {x = 5, y = 10, v = {}} ))
assert( copy(t).v == t.v )
assert( equal( copy( v ), v ))
assert( equal( deepcopy(t), {x = 5, y = 10, v = {}} ))
assert( deepcopy(t).v ~= t.v )
assert( equal( deepcopy(v), v ))

v[v] = v
copy(v)
deepcopy( v )

assert( equal( {1,2,3,4,5}, setmetatable( map(range(5),cr.const(true)), nil ), true ))
assert( equal( {2,3,4,5}, setmetatable( map(range(2,5),op.self), nil), true ))
assert( equal( {1,3,5,7,9}, setmetatable( map(range(1,10,2),op.self), nil ), true ))
assert( equal( {5,4,3,2,1}, setmetatable( map(range(5,1,-1),op.self), nil), true ))

assert( equal( setof('red','blue','green'), mt{red=true,blue=true,green=true} ))
assert( equal( intersect(setof('red','green','blue'),setof('red','yellow','blue')), setof('red','blue') ))
assert( equal( difference(setof('red','green','blue'),setof('red','yellow','blue')), setof('green') ))
assert( equal( union(setof('red','green','blue'),setof('red','yellow','blue')), setof('red','yellow','blue','green') ))

assert( equal( permutations{1,2,3}, {{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}} ))
assert( #permutations{1,2,3,4,5,6,7,8} == 40320 )
assert( equal( combinations({1,2,3,4},2), {{1,2},{1,3},{1,4},{2,3},{2,4},{3,4}}))
assert( equal( combinationsof({1,2,3},{'x','y'}), {{1,'x'},{1,'y'},{2,'x'},{2,'y'},{3,'x'},{3,'y'}} ))

assert( equal( {swap(1,2)}, {2,1} ))

local _ = capture'_'
local ___ = capture'___'
local R = capture'...'
local X, Y = capture'X',capture'Y'
assert( equal( match( {1,2,2,3}, {X,Y,_,_} ), mt{X = 1, Y = 2} ))
assert( equal( match( {1,2,2,3}, {X,Y,_} ), false ))
assert( equal( match( {1,2,3,4,5}, {X,___} ), mt{X = 1} ))
assert( equal( match( {1,2,3,4,5}, {Y,X,R} ), mt{Y = 1, X = 2, _ = {3,4,5}} ))
assert( equal( match( {1,2,{3,{4,{5}}}}, {X,_,{3,{_,{Y}}}} ), mt{X = 1, Y = 5} ))
assert( equal( match( 1, 2, 3, 4, 1 ), mt{} ))
assert( equal( match( 1, 2, 3, 4, {} ), false ))
assert( equal( match( {1,2,3,3,4},
	{1,_,X,X,X},
	{1,_,X,X,___} ), mt{X=3} ))
assert( equal( fn'x>2', fn'x>2' ))
assert( equal( fn'math.sin(x)'(2), math.sin(2)))
assert( equal( fn'x+y'(1,2), 3 ))
assert( equal( fn'x*y*z'(2,5,10), 100 ))
assert( equal( fn'x*y*z*u'(2,5,10,10), 1000 ))
assert( equal( fn'x*y*z*u*v'(2,5,10,10,20), 20000 ))
assert( equal( fn'x*y*z*u*v*w'(2,5,10,10,20,30), 600000 ))

assert( mt{1,2,3,4,5}:shuffle():reverse():mapfilter(cr.add(1),cr.gt(2)):sum() == sum{3,4,5,6} )

print( _count, "tests passed" )
