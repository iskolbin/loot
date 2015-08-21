Match
=====

Syntax
------
match{
	rule1,
	rule2,
	...
	ruleN
}

Rule
----
{<clause>,<result>,<predicate>}

Clause
------
*	atom( nil, number, boolean, string )
* predicate( function )
* capture( table with *Variable* metatable )
* container( table )

Wild
----
local _ = match.wild()   -- wild match ( matches any and drops result )
local _ = match.wild(0,2) -- ranged wild match( matches any element 0, 1 or 2 times and drops result ) (note than wild() <=> wild(1,1))

Capture
-------
local X = match.var('X') -- simple capture with name 'X' ( matches any and write result to 'X' field of captures table )
local X01  = match.var('X01',0,1) -- captures 0 or 1 elements  (note that var() <=> var(1,1))
local R = match.rest('R')   -- capture rest arguments and write result to 'R' field of captures table

Result
------
* atom( nil, number, boolean, string )
* function( called with captures table as first argument )
* string pattern
* container( table which fields can be filled with captured varialbes )

String pattern
--------------
local S = match.pattern('%{X} %{Y}')

Predicate
---------
Function called with captures table as first argument


Poker combinations matcher
==========================
Hand is array or 2-tuples or size 5,6 or 7 (i.e 2 -- in hand and 3,4,5 on table). 
Assume that hand is sorted by value in descending order. If values of the cards are the same then we use suit sorting.
Assume that value or "2" is 1, "3" is 2 and so forth. So "A" is 13 in this case.
For example: {{4,3},{4,2},{3,4},{1,3},{1,2}} (2 pairs by the way)

local X1,X2,X3,X4,X5 = match.var('X1'), match.var('X2'), match.var('X3'), match.var('X4'), match.var('X5') -- values
local Y = match.var('Y') -- suit
local K1,K2,K3,K4,K5 = match.var('K1'), match.var('K2'), match.var('K3'), match.var('K4'), match.var('K5') -- kickers
local R = match.rest()
local _ = match.wild()
local w02 = match.wild(0,2)
local P = match.pattern

local function isstraight( C ) 
	return C.X1 == C.X2 -1 and C.X2 == C.X3 -1 and C.X3 == C.X4 - 1 and C.X4 == C.X5 - 1
end

local matcher = match{
	{{w02,{13,Y},w02,{12,Y},w02,{11,Y},w02,{10,Y},w02,{9,Y},R}, P"Royal flush of %{Y}"},
	{{w02,{X1,Y},w02,{X2,Y},w02,{X3,Y},w02,{X4,Y},w02,{X5,Y},R}, P"Straight %{X1} flush of %{Y}", isstraight},
	{{w02,{13,Y},w02,{4,Y},w02,{3,Y},w02,{2,Y},w02,{1,Y},R}, P"Straight 4 flush of %{Y}"},
	{{{K1,_},w02,{X1,_},{X1,_},{X1,_},{X1,_},R}, P"Four %{X1} with %{K1} kicker"},
	{{{X1,_},{X1,_},{X1,_},{X1,_},{K1,_},R}, P"Four %{X1} with %{K1} kicker"},
	{{w02,{X1,_},{X1,_},{X1,_},w02,{X2,_},{X2,_},R}, P"Full %{X1} house of %{X2}"},
	{{w02,{X1,_},{X1,_},w02,{X2,_},{X2,_},{X2,_},R}, P"Full %{X2} house of %{X1}"},
	{{w02,{K1,Y},w02,{K2,Y},w02,{K3,Y},w02,{K4,Y},w02,{K5,Y},R}, P"Flush of %{Y}"},
	{{w02,{X1,_},w02,{X2,_},w02,{X3,_},w02,{X4,_},w02,{X5,_},R}, P"Straight of %{X1}", isstraight },
	{{w02,{13,_},w02,{4,_},w02,{3,_},w02,{2,_},w02,{1,_},R}, P"Straight of 4"},
	{{{K1,_},{K2,_},w02,{X1,_},{X1,_},{X1,_},R}, P"Three %{X1} with %{K1},%{K2} kickers"},
	{{{X1,_},{X1,_},{X1,_},{K1,_},{K2,_},R}, P"Three %{X1} with %{K1},%{K2} kickers"},
	{{{K1,_},w02,{X1,_},{X1,_},w02,{X2,_},{X2,_},R}, P"Two pairs of %{X1} and %{X2} with %{K1} kicker"},
	{{{X1,_},{X1,_},{K1,_},w02,{X2,_},{X2,_},R}, P"Two pairs of %{X1} and %{X2} with %{K1} kicker"},
	{{{X1,_},{X1,_},{X2,_},{X2,_},{K1,_},R}, P"Two pairs of %{X1} and %{X2} with %{K1} kicker"},
	{{{X1,_},{X1,_},{K1,_},{K2,_},{K3,_},R}, P"Pairs of %{X1} with %{K1}, %{K2}, %{K3} kickers"},
	{{{K1,_},{X1,_},{X1,_},{K2,_},{K3,_},R}, P"Pairs of %{X1} with %{K1}, %{K2}, %{K3} kickers"},
	{{{K1,_},{K2,_},{X1,_},{X1,_},{K3,_},R}, P"Pairs of %{X1} with %{K1}, %{K2}, %{K3} kickers"},
	{{{K1,_},{K2,_},{K3,_},w02,{X1,_},{X1,_},R}, P"Pairs of %{X1} with %{K1}, %{K2}, %{K3} kickers"},
	{{{K1,_},{K2,_},{K3,_},{K4,_},{K5,_},R}, P"Highest card %{K1} with %{K2}, %{K3}, %{K4}, %{K5} kickers"},
}

