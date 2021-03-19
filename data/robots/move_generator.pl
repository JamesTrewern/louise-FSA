:-module(move_generator, [write_dataset/0
			 ,dataset_file_name/2
			 ,generate_locations/2
			 ,generate_moves/1
			 ,generate_problems/1
			 ]).

:-use_module(generator_configuration).
:-use_module(world).
:-use_module(render).

/** <module> Data generator for grid world navigation experiments.

Predicates in this module generate extensional definitions of a) cell
locations, b) move primitives, and c) navigation tasks for a grid world.

The type and dimensions of the grid world are given in
generator_configuration.pl, as experiment_world/1 and
world_dimensions/2, respectively.

Navigation tasks
================

Grid world navigation tasks consist of a list of atoms of the predicate
move/2 where the first argument is a start state and the second argument
is the end state of a task.

==
move([0/0,0/0,1-1],[0/0,0/0,1-1]).
move([0/0,0/1,1-1],[0/1,0/1,1-1]).
move([0/0,1/0,1-1],[1/0,1/0,1-1]).
% ...
==

Grid world states are generated by predicates in module world.pl. Refer
to that module for an explanation of the representation of grid world
states. In general, the representation is a Prolog list whose elements
are X/Y terms representing the coordinates of locations on the grid
world where the grid world navigating agent and various objects of
interest, or goals, are situated.

Additionally, the dimensions of the grid world, and sometimes the name
of the world also, are included in the state-list for some worlds and
used for disambiguation between states relevant to different worlds.

The predicate generate_problems/1 defined in this module generates all
possible move/2 tasks for a given world.

Move primitives
===============

Move primitives consist of atoms of the predicates move_right/2,
move_left/2, move_up/2 and move_down/2, representing primitive grid
world navigation actions. For example:

==
move_right([0/0,0/0,1-1],[1/0,0/0,1-1]).
move_left([1/0,0/0,1-1],[0/0,0/0,1-1]).
move_up([0/0,0/0,1-1],[0/1,0/0,1-1]).
move_down([0/1,0/0,1-1],[0/0,0/0,1-1]).
==

The predicate generate_moves/2 generates all atoms of the four primitive
actions that are true in a given world, or in other words, an
extensional definition of each of the four primitive actions.

Location primitives
===================

Location primitives consist of atoms of the predicates start/1 and
end/1 representing the start and end locations of all possible
navigation tasks in a grid world. start/1 atoms have as their single
argument each of the starting states of the move/2 atoms generated by
generate_problems/1. end/1 atoms have as their single argument each of
the end states of the move/2 atoms generated by generate_problems/2.

==
% Task:
move([0/0,0/0,1-1],[0/0,0/0,1-1]).

% Start and end locations:
start([0/0,0/0,1-1]).
end([0/0,0/0,1-1]).
==

Location primitives are generated by the predicate generate_locations/2.
This takes as input a list of move/2 atoms generated by
generate_problems/1 and outputs a list of the corresponding start/1 and
end/1 atoms.

Usage instructions
==================

Configuration options
---------------------

Before generating tasks and primitives, make sure you have the correct
options configured in generator_configuration.pl. The parameters you
absolutely need to set are the type of world and its dimensions. The
following options will choose an empty world, with just the agent and a
goal cell, and of the smallest possible dimensions, 1x1:

==
experiment_world(empty_world).
world_dimensions(1,1).
==

Writing a dataset to file
-------------------------

To write a dataset to a file, call write_dataset/0:

==
?- write_dataset.
==

To open the just-written file in the Swi-Prolog IDE, use
dataset_file_name/2:

==
?- dataset_file_name(_,P), edit(P).
==

Loading a dataset
-----------------

The just-written file is automatically loaded into robots_gen.pl when
robots_gen.pl is loaded.

Known bugs
----------

Unfortunately, you can't immediately use the generated file- because of
module access complications, an existence error will be raised if you
immediately call a learning predicate on the newly generated file,
particularly if you have just changed the world's dimensions. To avoid
errors, you should start a new Prolog session. We apologies for the
delay this will cause to your journey. Hey, once I got a refund of 2.00
GBP from Southern Rail for a delay of 00:30 min that had cost me 25 GBP.
The system works!

Debugging a dataset
-------------------

Dataset generator debugging facilities are a bit thin on the ground.

You can visually inspect primitive moves with predicates defined in
module render.pl. Ensure that, in render.pl, the option output_to/1 is
set to "console":

==
output_to(console).
==

This will avoid writing to a log file, if one is defined, or raising an
error if one is not. Once output_to/1 is set, you can make the folloqing
query to generate all primitive moves on backtracking, and print them
out to screen in glorious ASCII:


==
?- generate_moves(_Ms), member(M, _Ms), M =.. [_,_Ss,_Gs], render:render_sequence([_Ss,_Gs]).
# .
. .

. .
# .

M = move_down([0/1, _, 1-1], [0/0, _, 1-1]) ;
. #
. .

. .
. #

M = move_down([1/1, _, 1-1], [1/0, _, 1-1]) ;
. .
. #

. .
# .

M = move_left([1/0, _, 1-1], [0/0, _, 1-1]) .

% etc
==

Or, if you want to generate all problems:

==
?- generate_problems(_Ms), member(M, _Ms), render:render_problem(M).Starting state: [0/0,0/0,1-1]
Goal state: [0/0,0/0,1-1]
. .
x .

. .
x .

M = move([0/0, 0/0, 1-1], [0/0, 0/0, 1-1]) ;
Starting state: [0/0,0/1,1-1]
Goal state: [0/1,0/1,1-1]
x .
# .

x .
. .

M = move([0/0, 0/1, 1-1], [0/1, 0/1, 1-1]) ;
Starting state: [0/0,1/0,1-1]
Goal state: [1/0,1/0,1-1]
. .
# x

. .
. x

M = move([0/0, 1/0, 1-1], [1/0, 1/0, 1-1]) .

% etc.
==

Note that problems include a goal state whereas primitive moves do not
(else they apply to every problem).

In the ASCII listing above, the "#" is the navigation agent and the "x"
is the goal. The first grid listed is the start state of a primitive
move action and the second grid is the end state of the same action.
In the first example, the listing helps visually check that a
"move_down" is indeed moving the agent one cell down from its starting
position. In the second example you get to see the goal and check what
primitive move can reach it, if any.

ASCII symbols for entities and locations in a grid world are listed in
the predicate symbol/3 in render.pl. TODO: make these available at the
configuration level.

Other worlds
------------

The world generator in worlds.pl can generate worlds with not just the
robot but also a ball to be carried to a goal, a randomly placed
obstacle, or an adversarial agent that moves to hinder the agent's
plans. These are not yet fully handled in terms of dataset generation.

The set of worlds for which a dataset can be generate with a complete
extensional definition of primitive moves and with all possible
navigation tasks is as follows:

* empty_world An agent and a goal location.
* simple_world An agent, an object and a goal location.

*/

% ========================================
% Dataset writing
% ========================================


%!	init_output_dir is det.
%
%	Initialise the dataset output directory.
%
init_output_dir:-
	dataset_file_name(_Bn,Fn)
	,file_directory_name(Fn,P)
	,(   \+ exists_directory(P)
	 ->   make_directory(P)
	 ;   true
	 ).


%!	write_dataset is det.
%
%	Write a grid navigation dataset to a file.
%
%	The dataset is the set of tasks, moves and locations generated
%	by generate_problems/1, generate_moves/2 and
%	generate_locations/2.
%
%	The dataset is written in a module file exporting the primitive
%	grid world navigation action and primitive location predicates,
%	move_right/2, move_left/2, move_up/2, move_down/2, start/1 and
%	end/1.
%
%	The path for the dataset's module file is generated by
%	dataset_file_name/2.
%
%	Once a dataset file is written it is meant to be imported in
%	robots_gen.pl, and its exported definitions of primitives
%	re-exported to the module user. Predicates in robots_gen.pl find
%	the current file from the path in dataset_file_name/2.
%
%	@tbd
%
write_dataset:-
	generator_configuration:experiment_world(Wrld)
	,generator_configuration:exported_moves(Wrld,Es)
	,init_output_dir
	,dataset_file_name(Bn,Fn)
	,generate_problems(Ps)
	,generate_moves(Ms)
	,generate_locations(Ps,Ls)
	,open(Fn,write,S,[alias(robots_dataset)])
	,format(S,':-module(~w, ~w).~n~n' , [Bn,Es])
	,list_dataset(S,Ps,Ms,Ls)
	,write_atoms(S,Ps)
	,nl(S)
	,write_atoms(S,Ls)
	,nl(S)
	,write_atoms(S,Ms)
	,close(S).


%!	dataset_file_name(-Basename,-Path) is det.
%
%	Generate a Path for a grid world navigation dataset.
%
dataset_file_name(Bn,P):-
	generator_configuration:output_directory(O)
	,generator_configuration:experiment_world(Wr)
	,generator_configuration:world_dimensions(W,H)
	% Gets the absolute name of this module file
	,module_property(move_generator, file(M))
	,file_directory_name(M,D)
	,atomic_list_concat([Wr,W,H],'_',Bn)
	,file_name_extension(Bn,'.pl',Fn)
	,atomic_list_concat([D,O],'/',R)
	,directory_file_path(R,Fn,P).


%!	list_dataset(+Stream,+Tasks,+Moves,+Locations) is det.
%
%	Print a dataset's properties to a Stream.
%
list_dataset(S,Ps,Ms,Ls):-
	experiment_world(World)
	,world_dimensions(W,H)
	,maplist(length,[Ps,Ms,Ls],[L,M,N])
	,format(S,'% World: ~w~n', [World])
	,format(S,'% Dimensions: ~w x ~w~n', [W,H])
	,format(S,'% Tasks: ~D~n', [L])
	,format(S,'% Primitive Moves: ~D~n', [M])
	,format(S,'% Locations: ~D~n~n', [N]).


%!	write_atoms(+Stream,+Atoms) is det.
%
%	Write a list of atoms to a Stream.
%
write_atoms(S,As):-
	forall(member(A,As)
	      ,(write_term(S,A,[fullstop(true)
			       ,nl(true)
			       ,numbervars(true)
			       ]
			  )
	       )
	      ).


% ========================================
% Dataset generation
% ========================================


%!	generate_locations(+Moves,-Locations) is det.
%
%	Generate Locations on a grid world.
%
%	Moves is a list of primitive moves generated by
%	generate_moves/2. Locations is a list of atoms location(X,Y)
%	where X and Y are the X and Y coordinates of a location on the
%	grid world.
%
%	Locations are connected by paths that are to be found by solving
%	a move/2 task. location/2 atoms are mostly provided for the
%	purpose of generating locations nondeterministically to test
%	learned navigation paths, or in general for debugging. They are
%	not necessary for learning and indeed location/2 should not be
%	used as background knoweldge because all it will do is add
%	noise.
%
generate_locations(Ms,Ls):-
	setof(location(X,Y)
	     ,M^Ms^F^Ss^Gs^(member(M,Ms)
			   ,M =.. [F,[X/Y|Ss],Gs]
			   )
	     ,Ls).


%!	generate_moves(+Moves) is det.
%
%	Generate extensional move/2 definitions.
%
%	Generates all possible moves in the current grid world.
%
%	Moves is a list of atoms of the predicates move_right/2,
%	move_left/2, move_up/2 and move_down/2, representing all
%	primitive moves that it is possible to make in the current grid
%	world from each unique location.
%
%	Atoms in Moves are generated by taking each start state
%	generated by world:problem/6 and calling move/3 with it as
%	input, ignoring the goal state in the problem (because we only
%	care about a single move from one location and where that move
%	takes us - not whether the move connects a starting location
%	with a goal location).
%
%	@tbd Can't this just take in problems from generate_problems/1
%	and extract their starting locations? It doesn't seem to be
%	doing anything different - it just calls problem/5 which is
%	already called in generate_problems/1.
%
generate_moves(Ms):-
	generator_configuration:experiment_world(Wr)
	,generator_configuration:exported_moves(Wr,MS)
	,world_dimensions(W,H)
	,setof(M
	      ,Wr^W^H^Ss^Gs^Mv^MS^(problem(Wr,nondeterministic,W,H,Ss,Gs)
				  ,member(Mv,MS)
				  ,move(Mv,Ss,M)
				  )
	      ,Ms).


%!	move(+Primitive,+Start,-Move) is nondet.
%
%	Generate a ground atom representing a grid world Primitive Move.
%
%	Primitive is the symbol and arity of the move primitive, e.g.
%	move_right/2, or pick_up/2. Primitives from which moves can
%	generated depend on the world (e.g. the empty world does not
%	include object manipulation primitives etc).
%
%	Start is the starting state of a grid world navigation task,
%	generated by problem/6.
%
%	Move is a ground atom of one of the predicates move_right/2,
%	move_left/2, move_up/2 or move_down/2 that is true for the given
%	Starting state locations.
%
%	Note that in primitive moves the location of the goal in the
%	state-list is left as a free variable. For example:
%	==
%	move_right([0/0,_,1-1],[1/0,_,1-1]).
%	==
%
%	This is to allow e.g. a right-move as the one above to be taken
%	regardless of the goal's location.
%
move(move_right/2,Ss,M):-
	move_right(Ss,M).
move(move_left/2,Ss,M):-
	move_left(Ss,M).
move(move_up/2,Ss,M):-
	move_up(Ss,M).
move(move_down/2,Ss,M):-
	move_down(Ss,M).
% Object manipulation moves
move(pick_up/2,Ss,M):-
	pick_up(Ss,M).
move(put_down/2,Ss,M):-
	put_down(Ss,M).


%!	generate_problems(+Problems) is det.
%
%	Generate a list of grid world navigation Problems.
%
%	Each problem in Problems is an atom of the predicate move/2
%	where the first atom is the starting state of a grid world
%	navigation task and the second argument is the end state of that
%	task (when the taks is solved successfully).
%
%	The grid world setup and dimensions are defined in
%	experiment_world/1 and world_dimensions/2. Problems are
%	generated by calling problem/6 and passing it the arguments of
%	the two predicates above and "nondeterministic" as the second
%	argument (controlling the method of problem generation).
%	"nondeterministic" generation means that all possible navigation
%	tasks in the given world are generated on backtracking.
%
generate_problems(Ps):-
	experiment_world(Wr)
	,world_dimensions(W,H)
	,findall(move(Ss,Gs)
		,problem(Wr,nondeterministic,W,H,Ss,Gs)
		,Ps).



%!	move_right(+State,-Move) is det.
%
%	Generate a right-move from a given State.
%
%	State is a starting state-list, as generate by problem/6.
%
%	Move is an atom move_right(Ss, Gs) where Ss is the starting
%	State and Gs is the state in which the world is when the agent
%	has taken a right move from its location in Ss. Move is a move
%	primitive, i.e. a clause of an extensional definition of
%	right-moves in the current grid world.
%
%	Note that the location of the goal in Sate is not carried over
%	in the move primitive. e.g right-moves may look like this:
%	==
%	move_right([0/0,_,1-1],[1/0,_,1-1]).
%	==
%
%	The point of this is to allow right moves from any possible
%	starting location regardless of the problem task, i.e.
%	regardless of the location of the goal in that task.
%
move_right([R,_G,W-H], move_right([R,G,W-H],[R_new,G,W-H])):-
% Empty world: the agent and a goal.
% The agent must move to the goal.
	!
	,move(R,+,1/0,W-H,R_new)
	% To print goal vars as the variable G
	,G = '$VAR'('G').
move_right([R,B,_G,HB,W-H],move_right([R,B,G,HB,W-H],[R_new,B_new,G,HB,W-H])):-
% Simple worlds: the agent, an object and a goal.
% The agent must move with the object if it is being held.
	!
	,move(R,+,1/0,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').
move_right([R,B,O,_G,HB,W-H],move_right([R,B,O,G,HB,W-H],[R_new,B_new,O,G,HB,W-H])):-
	!
	,move_unobstructed(R,+,1/0,O,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').


%!	move_left(+State, -Move) is det.
%
%	Generate a left-move from the given State.
%
move_left([R,_G,W-H],move_left([R,G,W-H],[R_new,G,W-H])):-
	!
	,move(R,-,1/0,W-H,R_new)
	,G = '$VAR'('G').
move_left([R,B,_G,HB,W-H],move_left([R,B,G,HB,W-H],[R_new,B_new,G,HB,W-H])):-
	!
	,move(R,-,1/0,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').
move_left([R,B,O,_G,HB,W-H],move_left([R,B,O,G,HB,W-H],[R_new,B_new,O,G,HB,W-H])):-
	!
	,move_unobstructed(R,-,1/0,O,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').


%!	move_up(+State, -Move) is det.
%
%	Generate a move-up from the given State.
%
move_up([R,_G,W-H],move_up([R,G,W-H],[R_new,G,W-H])):-
	!
	,move(R,+,0/1,W-H,R_new)
	,G = '$VAR'('G').
move_up([R,B,_G,HB,W-H],move_up([R,B,G,HB,W-H],[R_new,B_new,G,HB,W-H])):-
	!
	,move(R,+,0/1,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').
move_up([R,B,O,_G,HB,W-H],move_up([R,B,O,G,HB,W-H],[R_new,B_new,O,G,HB,W-H])):-
	!
	,move_unobstructed(R,+,0/1,O,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').


%!	move_down(+State, -New) is det.
%
%	Generate a move-down from the given State.
%
move_down([R,_G,W-H],move_down([R,G,W-H],[R_new,G,W-H])):-
	!
	,move(R,-,0/1,W-H,R_new)
	,G = '$VAR'('G').
move_down([R,B,_G,HB,W-H],move_down([R,B,G,HB,W-H],[R_new,B_new,G,HB,W-H])):-
	!
	,move(R,-,0/1,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').
move_down([R,B,O,_G,HB,W-H],move_down([R,B,O,G,HB,W-H],[R_new,B_new,O,G,HB,W-H])):-
	!
	,move_unobstructed(R,-,0/1,O,W-H,R_new)
	,with_the_ball(R,B,R_new,HB,B_new)
	,G = '$VAR'('G').


%!	pick_up(?World_Dimensions,?New) is semidet.
%
%	True when the ball has been picked up.
%
%	World Dimensions is a list [W,H] where W is the width and H the
%	height of the grid world. Unlike primitive moves that move the
%	agent from one location to another on the grid world, this move
%	leaves the agent's location unchanged and instead modifies the
%	"Holds Object" fluent in the world state.
%
%	@tbd Only a single clause of this move is needed for any world
%	where the agent must manipulate an object, but generate_moves/1
%	will actually generate one for every starting state in a
%	problem. The list of primitive moves will be sorted in the end
%	so only a sinlgle pick-up primitive will end up in the actual
%	dataset file, but mabye the overhead at generation time could be
%	avoided.
%
pick_up([_R,_B,_G,_HB,W-H],pick_up([R,R,G,false,W-H],[R,R,G,true,W-H])):-
	!
	,R = '$VAR'('R')
	,G = '$VAR'('G').
pick_up([_R,_B,_O,_G,false,W-H],pick_up([R,R,O,G,false,W-H],[R,R,O,G,true,W-H])):-
	!
	,R = '$VAR'('R')
	,G = '$VAR'('G')
	,O = '$VAR'('O').


%!	put_down(?World_Dimensions,?New) is semidet.
%
%	True when the ball has been put down.
%
%	Note that the ball can be put down anywhere- not necessarily on
%	the goal.
%
%	@tbd See notes in pick_up/2 about generator overhead.
%
put_down([_R,_B,_G,_HB,W-H],put_down([R,R,G,true,W-H],[R,R,G,false,W-H])):-
	!
	,G = '$VAR'('G')
	,R = '$VAR'('R').
put_down([_R,_B,_O,_G,true,W-H],put_down([R,R,O,G,true,W-H],[R,R,O,G,false,W-H])):-
	!
	,R = '$VAR'('R')
	,G = '$VAR'('G')
	,O = '$VAR'('O').


%!	move(+Point,+Delta,+Distance,+Limits,-End) is det.
%
%	Modify a coordinate, respecting spatial Limits.
%
%	Point is a compound X/Y wher X,Y are numbers, representing a
%	coordinate. Delta is one of [-,+], signifying how Point is to be
%	modified. Distance is a compound, Dx/Dy, where Dx,Dy are
%	numbers, each the amount by which the corresponding value in
%	Point is to be modified according to Delta. Limits is a
%	key-value pair, W-H, where each of W, H are numbers, the upper
%	limit of the two dimensions of the current world.
%
%	move/5 is true when End = Point Delta Distance and End_X in
%	[0,W], End_Y in [0,H].
%
move(X/Y,D,Dx/Dy,W-H,Ex/Ey):-
	ground(X/Y)
	,ground(Dx/Dy)
	,ground(D)
	,ground(W-H)
	,Mv_x =.. [D,X,Dx]
	,Mv_y =.. [D,Y,Dy]
	,Ex is Mv_x
	,Ey is Mv_y
	,within_limits(Ex,W)
	,within_limits(Ey,H).


%!	within_limits(+Distance,+Limit) is det.
%
%	True when a moving Distance is within the given Limit.
%
within_limits(X,L):-
	integer(X)
	,integer(L)
	,X >= 0
	,X =< L.


%!	with_the_ball(+Robot,+Ball,+Holds,-New) is det.
%
%	Determine the New location of the Ball.
%
%	If Holds is true, the Robot is holding the Ball; in that case,
%	a) their current coordinates must coincide and b) their New
%	coordinates, at the end of the move, must also coincide.
%
with_the_ball(R,R,R_new,true,R_new):-
	!.
with_the_ball(_R,B,_R_new,false,B).


%!	move_unobstructed(+Robot,+Delta,+Distance,+Obstacle,+Limit,-New)
%!	is det.
%
%	Modify a coordinate, taking into account relevant objects.
%
%	Ensures the Robot can not move through an Obstacle. Otherwise,
%	the Robot moves to the New position determined by Delta and
%	Distance.
%
%	@tbd Used with the obstacles world.
%
move_unobstructed(R,Dlt,Dst,O,L,R_new):-
	move(R,Dlt,Dst,L,R_new)
	,\+ obstructed(R_new,O).


%!	obstructed(+Object,+Obstacle) is det.
%
%	True when a destination tile is obstructed.
%
obstructed(O,O).
