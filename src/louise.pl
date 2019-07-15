:-module(louise, [learn_episodic/1
		 ,learn_episodic/2
		 ,learn_episodic/5
		 ,learn/1
		 ,learn/2
		 ,learn/5
		 ,top_program/6
		 ]).

:-use_module(configuration).
:-use_module(mil_problem).


%!	learn_episodic(+Target) is det.
%
%	Learn a definition of a Target in successive episodes.
%
learn_episodic(T):-
	learn_episodic(T,Ps)
	,print_clauses(Ps).



%!	learn_episodic(+Target,-Definition) is det.
%
%	Learn a Definition of a Target in successive episodes.
%
learn_episodic(T,Ps):-
	experiment_data(T,Pos,Neg,BK,MS)
	,learn_episodic(Pos,Neg,BK,MS,Ps).



%!	learn_episodic(+Pos,+Neg,+BK,+Metarules,-Program) is det.
%
%	Learn a Program over successive episodes.
%
%	Base predicate for episodic learning. Program is learned in
%	successive episodes where the learned hypothesis is added to the
%	BK and learning begins all over again.
%
learn_episodic(Pos,Neg,BK,MS,Ps):-
	debug(episodic,'Encapsulating problem',[])
	,encapsulated_problem(Pos,Neg,BK,MS,Pos_,Neg_,BK_,MS_,Ss)
	,debug(episodic,'Learning first episode',[])
	,learning_episode(Pos_,Neg_,BK_,MS_,Ss,Ps_1)
	,examples_target(Pos,T)
	,learned_hypothesis(T,Ps_1,Es_1)
	,length(Es_1,N)
	,learn_episodic(T,N,Pos_,Neg_,BK_,MS_,Ss,Es_1,Ps_k)
	,excapsulated_clauses(T,Ps_k,Ps).


%!	learned_hypothesis(+Target,+Program,-Hypothesis) is det.
%
%	Collect the clauses of a learned Hypothesis.
%
%	Helper to separate a learned hypothesis from the rest of a
%	reduced program, so that it can be added to the background
%	knowledge for a subsequent learning episode.
%
learned_hypothesis(T/A,Ps,Hs):-
	findall(H:-B
	       ,(member(H:-B,Ps)
		,H =.. [m,T|As]
		,length(As,A)
		)
	       ,Hs).


%!	learn_episodic(+Target,+N,+Pos,+Neg,+BK,+Meta,+Sig,+Acc,-Bind)
%!	is det.
%
%	Business end of learn_episodic/5.
%
%	Recursively learns a hypothesis with background knowledge
%	including the hypothesis learned in the previous recursion step.
%
%	Recursion stops when the length of the learned hypothesis does
%	not change from one recursion step to the next.
%
learn_episodic(T/A,N,Pos,Neg,BK,MS,Ss,Es_i,Bind):-
	append(BK,Es_i,BK_)
	,debug(episodic,'Learning new episode',[])
	,learning_episode(Pos,Neg,BK_,MS,Ss,Ps)
	,learned_hypothesis(T/A,Ps,Es_j)
	,length(Es_j,M)
	,M > N
	,!
	,learn_episodic(T/A,M,Pos,Neg,BK_,MS,Ss,Es_j,Bind).
learn_episodic(_T,_M,_Pos,_Neg,_BK,_MS,_Ss,Ps,Ps).


%!	learning_episode(+Pos,+Neg,+BK,+Ms,+Sig,-Episode) is det.
%
%	Process one learning episode.
%
%	One learning episode consists of constructing the Top program
%	and then reducing it.
%
%	@tbd This could replace the two calls to top_program/6 and
%	reduced_top_program/6 in learn/5, so as to add the recursion
%	depth limit test in here. Just in case.
%
learning_episode(Pos,Neg,BK,MS,Ss,Es):-
	configuration:recursion_depth_limit(episodic_learning,L)
	,debug(episodic,'Constructing Top program',[])
	,G = top_program(Pos,Neg,BK,MS,Ss,Ms)
	,call_with_depth_limit(G,L,Rs)
	,Rs \= depth_limit_exceeded
	,debug(episodic,'Reducing Top program',[])
	,reduced_top_program(Pos,BK,MS,Ss,Ms,Es).



%!	learn(+Target) is det.
%
%	Learn a deafinition of a Target predicate.
%
learn(T):-
	learn(T,Ps)
	,print_clauses(Ps).



%!	learn(+Target,-Definition) is det.
%
%	Learn a definition of a Target predicate.
%
learn(T,Ps):-
	experiment_data(T,Pos,Neg,BK,MS)
	,learn(Pos,Neg,BK,MS,Ps).



%!	learn(+Pos,+Neg,+BK,+Metarules,-Progam) is det.
%
%	Learn a Progam from a MIL problem.
%
learn(Pos,Neg,BK,MS,Ps):-
	debug(learn,'Encapsulating problem',[])
	,encapsulated_problem(Pos,Neg,BK,MS,Pos_,Neg_,BK_,MS_,Ss)
	,debug(learn,'Constructing Top program',[])
	,top_program(Pos_,Neg_,BK_,MS_,Ss,Ms)
	,debug(learn,'Reducing Top program',[])
	,reduced_top_program(Pos_,BK_,MS_,Ss,Ms,Rs)
	,examples_target(Pos,T)
	,debug(learn,'Excapsulating problem',[])
	,excapsulated_clauses(T,Rs,Ps).



%!	top_program(+Pos,+Neg,+BK,+Metarules,+Signature,-Top) is det.
%
%	Construct the Top program for a MIL problem.
%
top_program(Pos,Neg,BK,MS,Ss,Ts):-
	write_program(Pos,BK,MS,Ss,Refs)
	,top_program(Pos,Neg,BK,MS,Ms)
	,unfolded_metasubs(Ms,Ts)
	,erase_program_clauses(Refs).


%!	write_program(+Pos,+BK,+MS,+PS,-Refs) is det.
%
%	Write an encapsulated program to the dynamic database.
%
%	@tbd The negative examples don't need to be written to the
%	dynamic database.
%
write_program(Pos,BK,MS,Ss,Rs):-
	findall(Rs_i
		,(member(P, [Pos,BK,MS,Ss])
		 ,assert_program(user,P,Rs_i)
		 )
		,Rs_)
	,flatten(Rs_,Rs).


%!	top_program(+Positive,+Negative,+BK,+Metarules,-Metasubstitutions)
%	is det.
%
%	Collect all correct Metasubstitutions in a MIL problem.
%
top_program(Pos,Neg,_BK,MS,Ss):-
	generalise(Pos,MS,Ss_Pos)
	,specialise(Ss_Pos,Neg,Ss).


%!	generalise(+Positive,+Metarules,-Generalised) is det.
%
%	Generalisation step of Top program construction.
%
%	Generalises a set of Positive examples by finding each
%	metasubstitution of a metarule that entails a positive example.
%
generalise(Pos,MS,Ss_Pos):-
	setof(H
	     ,M^MS^Ep^Pos^(member(M,MS)
			  ,member(Ep,Pos)
			  ,metasubstitution(Ep,M,H)
			  )
	     ,Ss_Pos).

/* Alternative version- only resolves metarules, without taking into
%  account the examples except to bind the symbol of the target predicate.
%  This one is a tiny bit faster but the one above is currently the one
%  in the technical report on Louise.

generalise(Pos,MS,Ss_Pos):-
	Pos = [E|_Es]
	,E =.. [m,T|_As]
	,setof(M
	     ,M^B^MS^N^T^Ps^
	       (member(M:-B,MS)
		     ,M =.. [m,N,T|Ps]
		     ,call(M)
		     )
	     ,Ss_Pos).
*/


%!	specialise(+Generalised,+Negatives,-Specialised) is det.
%
%	Specialisation step of Top program construction.
%
%	Specialises a set of metasubstitutions generalising the positive
%	examples against the Negative examples by discarding each
%	metasubstitution that entails a negative example.
%
specialise(Ss_Pos,Neg,Ss_Neg):-
	setof(H
	     ,Ss_Pos^En^Neg^M^
	      (member(H,Ss_Pos)
	      ,\+((member(En,Neg)
		  ,metasubstitution(En,M,H)
		  )
		 )
	      )
	     ,Ss_Neg).


%!	metasubstitution(+Example,+Metarule,-Metasubstitution) is
%!	nondet.
%
%	Perform one Metasubstutition of Metarule initialised to Example.
%
%	Example is either a positive example or a negative example. A
%	positive example is a ground definite unit clause, while a
%	negative example is a ground definite goal (i.e. a clause of the
%	form :-Example).
%
metasubstitution(:-E,M,H):-
	!
	,M= (H:-(Ps,(E,Ls)))
	,metarule_expansion(_Id,(H:-(Ps,(E,Ls))))
	,user:call(Ps)
	,user:call(Ls).
metasubstitution(E,M,H):-
	M =(H:-(Ps,(E,Ls)))
	,user:call(Ps)
	,user:call(Ls).



%!	reduced_top_program(+Pos,+BK,+Metarules,+Sig,+Program,-Reduced)
%!	is det.
%
%	Reduce the Top Program.
%
%	Clauses are selected according to the value of the configuration
%	option recursive_reduction/1. If this is set to true, the Top
%	program is reduced recursively, by passing the output of each
%	reduction step to the next, as input. If recursive_reduction/1
%	is set to false a single reduction step is performed.
%
%	Recursive reduction is useful when the Top program is large, or
%	recursive, and a large number of resolution steps are required
%	to reduce it effectively. In such cases, recursive reduction can
%	result in a stronger reduction of the Top program (i.e. result
%	in fewer redundant clauses in the learned hypothesis) in a
%	shorter amount of time, without increasing the number of
%	resolution steps in the program reduction meta-interpreter.
%
reduced_top_program(Pos,BK,MS,Ss,Ps,Rs):-
	configuration:recursive_reduction(true)
	,!
	,flatten([Ss,Pos,BK,Ps,MS],Fs_)
	,program_reduction(Fs_,Rs_,_)
	,length(Fs_,M)
	,length(Rs_,N)
	,debug(reduction,'Initial reduction: ~w to ~w',[M,N])
	,reduced_top_program_(N,Rs_,BK,MS,Ss,Rs)
	% program_reduction module leaves behind garbage
	% in program module. Why?
	,cleanup_experiment.
reduced_top_program(Pos,BK,MS,Ss,Ps,Rs):-
	configuration:recursive_reduction(false)
	,flatten([Ss,Pos,BK,Ps,MS],Fs_)
	,time(program_reduction(Fs_,Rs,_))
	,cleanup_experiment.


%!	reduced_top_program_(+N,+Prog,+BK,+Metarules,+Sig,-Reduced) is
%!	det.
%
%	Business end of reduced_top_program/6
%
%	Recursively reduces the Top Program, by feeding back the result
%	of each call to program_reduction/2 to itself, a process known
%	as "doing feedbacksies".
%
reduced_top_program_(N,Ps,BK,MS,Ss,Bind):-
	program_reduction(Ps,Rs,_)
	,length(Rs, M)
	,debug(reduction,'New reduction: ~w to ~w',[N,M])
	,M < N
	,!
	,reduced_top_program_(M,Rs,BK,MS,Ss,Bind).
reduced_top_program_(_,Rs,_BK,_MS,_Ss,Rs).
