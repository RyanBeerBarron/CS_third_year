:- dynamic q/5.
:- dynamic v/4.
:- dynamic v/3.

prob(fit, exercise, fit, X) :- X is float(0.99) * float(0.9), asserta(prob(fit, exercise, fit, X) :- !).
prob(fit, exercise, unfit, X) :- X is float(0.01) * float(0.9), asserta(prob(fit, exercise, unfit, X) :- !).

prob(fit, relax, fit, X) :- X is float(0.7) * float(0.99), asserta(prob(fit, relax, fit, X) :- ! ).
prob(fit, relax, unfit, X) :- X is float(0.3) * float(0.99), asserta(prob(fit, relax, unfit, X) :- ! ).

prob(unfit, exercise, fit, X) :- X is float(0.2) * float(0.9), asserta(prob(unfit, exercise, fit, X) :- !).
prob(unfit, exercise, unfit, X) :- X is float(0.8) * float(0.9), asserta(prob(unfit, exercise, unfit, X) :- !).

prob(unfit, relax, fit, 0.0).
prob(unfit, relax, unfit, 0.99).
 
prob(fit, exercise, dead, 0.1).
prob(unfit, exercise, dead, 0.1). 

prob(fit, relax, dead, 0.01).
prob(unfit, relax, dead, 0.01).

prob(dead, _, dead, 1.0).
prob(dead, _, fit, 0.0).
prob(dead, _, unfit, 0.0).

reward(fit, exercise, fit, 8).
reward(fit, exercise, unfit, 8).

reward(unfit, exercise, fit, 0).
reward(unfit, exercise, unfit, 0).

reward(fit, relax, fit, 10).
reward(fit, relax, unfit, 10).

reward(unfit, relax, fit, 5).
reward(unfit, relax, unfit, 5).

reward(_, _, dead, 0).
reward(dead, _, _, 0).

q(0, State, Action, Q):-prob(State, Action, fit, Prob1), reward(State, Action, fit, Reward1),
						prob(State, Action, unfit, Prob2), reward(State, Action, unfit, Reward2),
						prob(State, Action, dead, Prob3), reward(State, Action, dead, Reward3),
						Q is Prob1 * Reward1 + Prob2 * Reward2 + Prob3 * Reward3,
						asserta(q(0, State, Action, Q) :- !).

q(N, N, State, Action, Q, Gamma) :- q(N, State, Action, Q, Gamma).

q(N, Acc, State, Action, Q, Gamma) :- 	Acc < N, q(0, State, Action, Q0),
								prob(State, Action, fit, Prob1), prob(State, Action, unfit, Prob2), prob(State, Action, dead, Prob3),
								NewAcc is Acc + 1, v(Acc, fit, Value1, Gamma), v(Acc, unfit, Value2, Gamma), v(Acc, dead, Value3, Gamma),
								TempQ is Q0 + Gamma * (Prob1*Value1 + Prob2*Value2 + Prob3*Value3),
								asserta(q(NewAcc, State, Action, TempQ, Gamma) :- !), q(N, NewAcc, State, Action, Q, Gamma). 

v(0, State, Value, _) :- 	(v(0, State, Value);	
							(q(0, State, exercise, Q1), q(0, State, relax, Q2), max_list([Q1,Q2], Value),
							asserta(v(0, State, Value) :- !))), !.

v(N, State, Value, Gamma) :- 	(q(N, State, exercise, Q1, Gamma), ! ; q(N, 0, State, exercise, Q1, Gamma), !), 
								(q(N, State, relax, Q2, Gamma), ! ; q(N, 0, State, relax, Q2, Gamma), !),
								max_list([Q1,Q2],Value), asserta(v(N, State, Value, Gamma) :- !).

show(N, State, Gamma) :- show(N, State, Gamma, _, _).

show(N, State, Gamma, Qexercise, Qrelax) :- float(Gamma) > float(0.0), float(Gamma) < float(1.0), 
											q(N, 0, State, exercise, Qexercise, Gamma), q(N, 0, State, relax, Qrelax, Gamma).


























