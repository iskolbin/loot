local loot = require('loot')
local match = require('match')
local pp, xtostring = loot.pp, loot.xtostring
assert(pp)
oldprint = print
--print, pp = function() end, function() end
local function sorthand( hand )
	local function comparecard( a, b )
		return a[1] > b[1] or (a[1] == b[1] and a[2] > b[2])
	end

	table.sort( hand, comparecard )
	return hand
end

local function isstraight( t, cs )
	return (cs.X1 == cs.X2 - 1) and (cs.X2 == cs.X3 - 1) and (cs.X3 == cs.X4 - 1) and (cs.X4 == cs.X5 - 1)
end

local function royalflush( t, cs )
	print( 'Royal Flush' )
	--pp(cs)
end

local function straightflush( t, cs )
	print( 'Straight Flush' )
--	pp(cs)
end

local function fourofakind( t, cs )
	print( 'Four of a Kind' )
	--pp(cs)
end

local function fullhouse( t, cs )
	print( 'Full house' )
	--pp( cs )
end

local function flush( t, cs )
	print( 'Flush' )
	--pp( cs )
end

local function straight( t, cs )
	print( 'Straight' )
	--pp( cs )
end

local function threeofakind( t, cs )
	print( 'Three of a Kind' )
	--pp(cs)
end

local function twopairs( t, cs )
	print( 'Two pairs' )
	--pp(cs)
end

local function pair( t, cs )
	print( 'Pair' )
	--pp(cs)
end

local function highestcard( t, cs )
	print( 'Highest card' )
	--pp(cs)
end

local X1,X2,X3,X4,X5,Y,K1,K2,K3,K4,K5,_ = table.unpack( loot.map({'X1','X2','X3','X4','X5','Y','K1','K2','K3','K4','K5','_'}, match.var ))

local flopmatch = match.matcher {
	{ {{14,Y},{13,Y},{12,Y},{11,Y},{10,Y}},	royalflush },

	{ {{X1,Y},{X2,Y},{X3,Y},{X4,Y},{X5,Y}}, straightflush, isstraight},

	{ {{K1,_},{X1,_},{X1,_},{X1,_},{X1,_}}, fourofakind },

	{ {{X1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, fullhouse },
	{ {{X2,_},{X2,_},{X1,_},{X1,_},{X1,_}}, fullhouse },
	
	{ {{K1,Y},{K2,Y},{K3,Y},{K4,Y},{K5,Y}}, flush },
	
	{ {{X1,_},{X2,_},{X3,_},{X4,_},{X5,_}}, straight, isstraight },
	
	{ {{K1,_},{K2,_},{X1,_},{X1,_},{X1,_}}, threeofakind},
	{ {{K1,_},{X1,_},{X1,_},{X1,_},{K2,_}}, threeofakind},
	{ {{X1,_},{X1,_},{X1,_},{K1,_},{K2,_}}, threeofakind},
	
	{ {{K1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{K1,_},{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{X2,_},{X2,_},{K1,_}}, twopairs},

	{ {{K1,_},{K2,_},{K3,_},{X1,_},{X1,_}}, pair},
	{ {{K1,_},{K2,_},{X1,_},{X1,_},{K3,_}}, pair},
	{ {{K1,_},{X1,_},{X1,_},{K2,_},{K3,_}}, pair},
	{ {{X1,_},{X1,_},{K1,_},{K2,_},{K3,_}}, pair},

	{ {{K1,_},{K2,_},{K3,},{K4,_},{K5,_}}, highestcard},
}

local turnmatch = match.matcher {
	{ {{14,Y},{13,Y},{12,Y},{11,Y},{10,Y}},	royalflush },

	{ {{X1,Y},{X2,Y},{X3,Y},{X4,Y},{X5,Y}}, straightflush, isstraight},
	{ {_,{X1,Y},{X2,Y},{X3,Y},{X4,Y},{X5,Y}}, straightflush, isstraight},

	{ {{K1,_},{X1,_},{X1,_},{X1,_},{X1,_}}, fourofakind },
	{ {{K1,_},_,{X1,_},{X1,_},{X1,_},{X1,_}}, fourofakind },

	{ {{X1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, fullhouse },
	{ {_,{X1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, fullhouse },

	{ {{X2,_},{X2,_},{X1,_},{X1,_},{X1,_}}, fullhouse },
	{ {_,{X2,_},{X2,_},{X1,_},{X1,_},{X1,_}}, fullhouse },
	
	{ {{K1,Y},{K2,Y},{K3,Y},{K4,Y},{K5,Y}}, flush },
	{ {_,{K1,Y},{K2,Y},{K3,Y},{K4,Y},{K5,Y}}, flush },
	
	{ {{X1,_},{X2,_},{X3,_},{X4,_},{X5,_}}, straight, isstraight },
	{ {_,{X1,_},{X2,_},{X3,_},{X4,_},{X5,_}}, straight, isstraight },
	
	{ {{K1,_},{K2,_},{X1,_},{X1,_},{X1,_}}, threeofakind},
	{ {{K1,_},{K2,_},_,{X1,_},{X1,_},{X1,_}}, threeofakind},
	{ {{K1,_},{X1,_},{X1,_},{X1,_},{K2,_}}, threeofakind},
	{ {{X1,_},{X1,_},{X1,_},{K1,_},{K2,_}}, threeofakind},
	
	{ {{K1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, twopairs},
	{ {{K1,_},_,{X1,_},{X1,_},{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{K1,_},{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{K1,_},_,{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{X2,_},{X2,_},{K1,_}}, twopairs},

	{ {{K1,_},{K2,_},{K3,_},{X1,_},{X1,_}}, pair},
	{ {{K1,_},{K2,_},{K3,_},_,{X1,_},{X1,_}}, pair},
	{ {{K1,_},{K2,_},{X1,_},{X1,_},{K3,_}}, pair},
	{ {{K1,_},{X1,_},{X1,_},{K2,_},{K3,_}}, pair},
	{ {{X1,_},{X1,_},{K1,_},{K2,_},{K3,_}}, pair},

	{ {{K1,_},{K2,_},{K3,},{K4,_},{K5,_}}, highestcard}, --]]
}


--require'tamale'
--local X1,X2,X3,X4,X5,Y,K1,K2,K3,K4,K5,_ = table.unpack( loot.map({'X1','X2','X3','X4','X5','Y','K1','K2','K3','K4','K5','_'}, tamale.var ))


local rivermatch = match.matcher {
--local rivermatch = tamale.matcher {	
	{ {{14,Y},{13,Y},{12,Y},{11,Y},{10,Y}},	royalflush },

	{ {{X1,Y},{X2,Y},{X3,Y},{X4,Y},{X5,Y}}, straightflush, isstraight},
	{ {_,{X1,Y},{X2,Y},{X3,Y},{X4,Y},{X5,Y}}, straightflush, isstraight},
	{ {_,_,{X1,Y},{X2,Y},{X3,Y},{X4,Y},{X5,Y}}, straightflush, isstraight},

	{ {{K1,_},{X1,_},{X1,_},{X1,_},{X1,_}}, fourofakind },
	{ {{K1,_},_,{X1,_},{X1,_},{X1,_},{X1,_}}, fourofakind },
	{ {{K1,_},_,_,{X1,_},{X1,_},{X1,_},{X1,_}}, fourofakind },

	{ {{X1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, fullhouse },
	{ {_,{X1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, fullhouse },
	{ {_,_,{X1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, fullhouse },
	{ {_,{X1,_},{X1,_},{X1,_},_,{X2,_},{X2,_}}, fullhouse },
	{ {{X1,_},{X1,_},{X1,_},_,_,{X2,_},{X2,_}}, fullhouse },

	{ {{X2,_},{X2,_},{X1,_},{X1,_},{X1,_}}, fullhouse },
	{ {_,{X2,_},{X2,_},{X1,_},{X1,_},{X1,_}}, fullhouse },
	{ {_,_,{X2,_},{X2,_},{X1,_},{X1,_},{X1,_}}, fullhouse },
	{ {_,{X2,_},{X2,_},_,{X1,_},{X1,_},{X1,_}}, fullhouse },
	{ {{X2,_},{X2,_},_,_,{X1,_},{X1,_},{X1,_}}, fullhouse },
	
	{ {{K1,Y},{K2,Y},{K3,Y},{K4,Y},{K5,Y}}, flush },
	{ {_,{K1,Y},{K2,Y},{K3,Y},{K4,Y},{K5,Y}}, flush },
	{ {_,_,{K1,Y},{K2,Y},{K3,Y},{K4,Y},{K5,Y}}, flush },
	
	{ {{X1,_},{X2,_},{X3,_},{X4,_},{X5,_}}, straight, isstraight },
	{ {_,{X1,_},{X2,_},{X3,_},{X4,_},{X5,_}}, straight, isstraight },
	{ {_,_,{X1,_},{X2,_},{X3,_},{X4,_},{X5,_}}, straight, isstraight },
	
	{ {{K1,_},{K2,_},{X1,_},{X1,_},{X1,_}}, threeofakind},
	{ {{K1,_},{K2,_},_,{X1,_},{X1,_},{X1,_}}, threeofakind},
	{ {{K1,_},{K2,_},_,_,{X1,_},{X1,_},{X1,_}}, threeofakind},
	{ {{K1,_},{X1,_},{X1,_},{X1,_},{K2,_}}, threeofakind},
	{ {{X1,_},{X1,_},{X1,_},{K1,_},{K2,_}}, threeofakind},
	
	{ {{K1,_},{X1,_},{X1,_},{X2,_},{X2,_}}, twopairs},
	{ {{K1,_},_,{X1,_},{X1,_},{X2,_},{X2,_}}, twopairs},
	{ {{K1,_},_,_,{X1,_},{X1,_},{X2,_},{X2,_}}, twopairs},
	{ {{K1,_},_,{X1,_},{X1,_},_,{X2,_},{X2,_}}, twopairs},
	{ {{K1,_},{X1,_},{X1,_},_,_,{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{K1,_},{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{K1,_},_,{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{K1,_},_,_,{X2,_},{X2,_}}, twopairs},
	{ {{X1,_},{X1,_},{X2,_},{X2,_},{K1,_}}, twopairs},

	{ {{K1,_},{K2,_},{K3,_},{X1,_},{X1,_}}, pair},
	{ {{K1,_},{K2,_},{K3,_},_,{X1,_},{X1,_}}, pair},
	{ {{K1,_},{K2,_},{K3,_},_,_,{X1,_},{X1,_}}, pair},
	{ {{K1,_},{K2,_},{X1,_},{X1,_},{K3,_}}, pair},
	{ {{K1,_},{X1,_},{X1,_},{K2,_},{K3,_}}, pair},
	{ {{X1,_},{X1,_},{K1,_},{K2,_},{K3,_}}, pair},

	{ {{K1,_},{K2,_},{K3,},{K4,_},{K5,_}}, highestcard}, --]]
	debug = true, index = false, partial = false,printcode = true,
}

local poker = coroutine.wrap( function( nplayers )

	--local print, pp = function() end, function() end
	local deck = loot.combinations{
		{2,3,4,5,6,7,8,9,10,11,12,13,14}, 
		{'H','D','S','C'}
	}
	local iflop1 = 2*nplayers+1
	local iflop2, iflop3, iturn, iriver = iflop1+1, iflop1+2, iflop1+3, iflop1+4
	coroutine.yield()	
	while true do
		local deck = loot.shuffle( deck )
		local state = 'preflop'
		print( '>>>>PREFLOP<<<<')
		local hands, ontable = {}, {}
		for i = 1, nplayers do 
			hands[i] = {deck[2*i-1],deck[2*i]} 
			print( i .. ">", xtostring( hands[i] ))
		end
		coroutine.yield()
		
		state = 'flop'
		print( '>>>>FLOP<<<<' )
		ontable[1] = deck[iflop1]
		ontable[2] = deck[iflop2]
		ontable[3] = deck[iflop3]
		print( "TABLE>", xtostring( ontable ))
		for j = 1, nplayers do 
			hands[j][3] = ontable[1] 
			hands[j][4] = ontable[2] 
			hands[j][5] = ontable[3] 
			sorthand( hands[j] )
			--flopmatch( hands[j] )
			print( j .. ">", xtostring( hands[j] ))
		end
		coroutine.yield()

		state = 'turn'
		print('>>>>TURN<<<<')
		ontable[4] = deck[iturn]
		print( "TABLE>", xtostring(ontable ))
		for j = 1, nplayers do 
			hands[j][6] = ontable[4] 
			sorthand( hands[j] )
			--rivermatch( hands[j] )
			print( j .. ">", xtostring(hands[j] ))
		end
		coroutine.yield()

		state = 'river'
		print('>>>>RIVER<<<<')
		ontable[5] = deck[iriver]
		print( "TABLE>", xtostring(ontable ) )
		for j = 1, nplayers do 
			hands[j][7] = ontable[5] 
			sorthand( hands[j] )
			rivermatch( hands[j] )
			print( j .. ">", xtostring(hands[j] ))
		end
		coroutine.yield()
	end
end )

----[[
poker( 6 )
math.randomseed(1)
oldprint( loot.ndiffclock( 10, function()
	poker()
	poker()
	poker()
	poker()
end )) 
--]]
