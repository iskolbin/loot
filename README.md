# loot
Lua ootility toolbox

## Memoization
* memoize( | v -> z |, mode=nil )

### Predicates
* n
* t
* f
* boolean
* number
* integer
* string
* table
* lambda
* thread
* userdata
* zero
* positive
* negative
* even
* odd
* id

## Testing predicates
* is.predicate( x ) 
* isnot.predicate( x )
* all( t, | v -> ? | )
* any( t, | v -> ? | )

## Operators
* op.add( x, y ) -> x + y
* op.sub( x, y ) -> x - y
* op.div( x, y ) -> x / y
* op.idiv( x, y ) -> x // y
* op.mul( x, y ) -> x * y
* op.mod( x, y ) -> x % y
* op.pow( x, y ) -> x ^ y
* op.expt( x, y ) -> y ^ x
* op.log( x, y ) -> log( x, y )
* op.neg( x ) -> -x
* op.len( x ) -> #x
* op.inc( x ) -> x + 1
* op.dec( x ) -> x - 1
* op.concat( x, y ) - > x .. y
* op.lconcat( x, y ) -> y .. x
* op.lor( x, y ) -> x or y
* op.land( x, y ) -> x and y
* op.lnot( x ) -> not x
* op.gt( x, y ) -> x > y
* op.ge( x, y ) -> x >= y
* op.lt( x, y ) -> x < y
* op.le( x, y ) -> x <= y
* op.eq( x, y ) -> x == y
* op.ne( x, y ) -> x ~= y
* op.at( x, y ) -> x[y]
* op.of( x, y ) -> y[x]
* op.const( x ) -> x
* op.call( x, y ) -> x( y )
* op.fun( x, y ) -> y( x )
* op.selfcall( x, y ) -> x[y](x)
* op.selffun( x, y ) -> y[x](y)

## Currying 
* cr.operator( y ) 
* curry( f, ... )

## Composition
* compose( {|... -> x|, |x -> y|, ...} )
* cand( |x -> v|, |x -> z|, ... )
* cor( |x -> v|, |x -> z|, ... )
* cnot( |... -> v| )
* pipe( x, {|x,... -> y|, |y,... -> z|, ...}  )

## Map
* map( array, |a -> z| )		
* imap( array, |i,a -> z| )
* vmap( table, |v -> z| )
* kmap( table, |k -> z| )
* vkmap( table, |v,k -> z| )
* kvmap( table, |k,v -> z| )

## Inplace map
* mapI( array, |a -> z| )		
* imapI( array, |i,a -> z| )
* vmapI( table, |v -> z| )
* kmapI( table, |k -> z| )
* vkmapI( table, |v,k -> z| )
* kvmapI( table, |k,v -> z| )

## Filter
* filter( array, |a -> ?| )
* ifilter( array, |i,a -> ?| )
* vfilter( table, |v -> ?| )
* kfilter( table, |k -> ?| )
* vkfilter( table, |v,k -> ?| )
* kvfilter( table, |k,v -> ?| )

## Inplace filter
* filterI( array, |a -> ?| )
* ifilterI( array, |i,a -> ?| )
* vfilterI( table, |v -> ?| )
* kfilterI( table, |k -> ?| )
* vkfilterI( table, |v,k -> ?| )
* kvfilterI( table, |k,v -> ?| )

## Fold
* foldl( array, |acc,a -> acc|, acc=array[1] )
* ifoldl( array, |acc,i,a -> acc|, acc=array[1] )
* foldr( array, |acc,a -> acc|, acc=array[#array] )
* ifoldr( array, |acc,i,a -> acc|, acc=array[#array] )
* vfold( table, |acc,v -> acc|, acc=next(table) )
* kfold( table, |acc,k -> acc|, acc=next(table) )
* vkfold( table, |acc,v,k -> acc|, acc=next(table) )
* kvfold( table, |acc,k,v -> acc|, acc=next(table) )
* sum( array, acc=0 )
* product( array, acc=1 )

## For each
* each( array, |a -> | )
* ieach( array, |i,a -> | )
* veach( table, |v -> | )
* keach( table, |k -> | )
* vkeach( table, |v,k -> | )
* kveach( table, |k,v -> | )

## Traversing table
* traverse( table, |t,k,level -> any|, level=nil, key=nil, saved=nil ) 

## Transformations
* append( array1, array2 )
* prepend( array1, array2 )
* inject( array1, array2, pos )
* reverse( array )
* shuffle( array )
* slice( array, init, limit=#array, step=1 )
* unique( array ) 
* update( table, table )
* flatten( array )

## Inplace transformations
* appendI( array1, array1 )
* prependI( array1, array2 )
* injectI( array1, array2 )
* reverseI( array )
* shuffleI( array )
* updateI( table, table )

## Indexing and sorting
* indexof( array, value, |a,b -> ?|=|a,b = a < b| )
* indexofq( array, value, |a,b -> ?|=equal, |a,b -> ?|=|a,b = a < b| )
* keyof( table, value )
* keyofq( table, value, |a,b -> ?|=equal )
* sort( array, |a,b -> ?|=|a,b -> a < b| )
* sortI( array, |a,b -> ?|=|a,b -> a < b| )

## Partition
* partition( array, |a -> ?| )
* ipartition( array, |i,a -> ?| )
* vpartition( table, |v -> ?| )
* kpartition( table, |k -> ?| )
* vkpartition( table, |v,k -> ?| )
* kvpartition( table, |k,v -> ?| )

## Zip/unzip
* zip( ... )
* unzip( array )

## Table creation and manipulation
* newtable( n=0 )
* keys( table )
* values( table )
* topairs( table )
* frompairs( table )
* tolists( table )
* fromlists( table )
* pack( ... )

## Matching
* wild
* capture( name, |v -> ?|=|v -> true|, |v -> z|=|v -> v| )
* equal( x, y, partial=false, captures=nil )
* match( x, y, partial=false )

## Counting
* count( table )
* nkeys( table )

## Copying
* copy( table )
* deepcopy( table )

## Range
* range( limit )
* range( init, limit, step=1 )

## Set operations
* setof( ... )
* instersect( set1, set2 )
* difference( set1, set2 )
* union( set1, set2 )

## Combinatorics
* permutations( array )
* combinations( array, n )
* combinationsof( array or arrays )

## Profiling utilities
* diffmemory( | ...-> |, ... )
* diffclock( | ...-> |, ... )
* ndiffclock( count, | ...-> |, ... )

## Swap
* swap( a, b )

## Advanced tostring and pretty-printing
* xtostring( ... )
* pp( ... )

# Exporting library 
* export
