:- dynamic q/5.
:- dynamic v/4.
:- dynamic gamma/1.


prob(fit, exercise, fit, X) :- X is float(0.99) * float(0.9), asserta(prob(fit, exercise, fit, X) :- !), !.
prob(fit, exercise, unfit, X) :- X is float(0.01) * float(0.9), asserta(prob(fit, exercise, unfit, X) :- !),! .

prob(fit, relax, fit, X) :- X is float(0.7) * float(0.99), asserta(prob(fit, relax, fit, X) :- ! ), !.
prob(fit, relax, unfit, X) :- X is float(0.3) * float(0.99), asserta(prob(fit, relax, unfit, X) :- ! ), !.

prob(unfit, exercise, fit, X) :- X is float(0.2) * float(0.9), asserta(prob(unfit, exercise, fit, X) :- !), !.
prob(unfit, exercise, unfit, X) :- X is float(0.8) * float(0.9), asserta(prob(unfit, exercise, unfit, X) :- !), !.

prob(unfit, relax, fit, 0.0).
prob(unfit, relax, unfit, 0.99).
 
prob(fit, exercise, dead, 0.1).
prob(unfit, exercise, dead, 0.1). 

prob(fit, relax, dead, 0.01).
prob(unfit, relax, dead, 0.01).

prob(dead, _, dead, 1.0).
prob(dead, _, X, 0.0) :- X \= dead.

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



show(N, State, Gamma) :- 	float(Gamma) > float(0.0), float(Gamma) < float(1.0),
							retractall(gamma(_)), asserta(gamma(Gamma)),
							show__(N, 0, State).

show__(N, N, State) :-	gamma(Gamma),
						( q(N, State, exercise, Qexercise, Gamma) ; q(N, State, exercise, Qexercise) ), !,
						( q(N, State, relax, Qrelax, Gamma) ; q(N, State, relax, Qrelax) ), !,
						format('n=~w, exer:~w relax:~w~n', [N, Qexercise, Qrelax]), !.

show__(N, Acc, State) :- 	gamma(Gamma),
							( q(Acc, State, exercise, Qexercise, Gamma) ; q(Acc, State, exercise, Qexercise) ), !,
							( q(Acc, State, relax, Qrelax, Gamma) ; q(Acc, State, relax, Qrelax) ), !,
							Newacc is Acc + 1,
							format('n=~w, exer:~w relax:~w~n', [Acc, Qexercise, Qrelax]),
							show__(N, Newacc, State).

q(0, State, Action, Q):-prob(State, Action, fit, Prob1), reward(State, Action, fit, Reward1),
						prob(State, Action, unfit, Prob2), reward(State, Action, unfit, Reward2),
						prob(State, Action, dead, Prob3), reward(State, Action, dead, Reward3),
						Q is Prob1 * Reward1 + Prob2 * Reward2 + Prob3 * Reward3,
						asserta(q(0, State, Action, Q) :- !), !.

q(N, State, Action, Value) :- 	gamma(Gamma), M is N - 1,
								( v(M, fit, Value1, Gamma); v(M, fit, Value1) ),
								( v(M, unfit, Value2, Gamma); v(M, unfit, Value2) ),
								( v(M, dead, Value3, Gamma); v(M, dead, Value3) ), !,
								prob(State,Action,fit,Prob1),
								prob(State, Action, unfit, Prob2),
								prob(State, Action, dead, Prob3),
								q(0, State, Action, Q0),
								Value is Q0 + Gamma * (Prob1*Value1 + Prob2*Value2 + Prob3*Value3),
								asserta(q(N, State, Action, Value, Gamma) :- !), !.

v(N, State, Value) :-	gamma(Gamma),
						( q(N, State, exercise, Value1, Gamma) ;  q(N, State, exercise, Value1) ), !,
						( q(N, State, relax, Value2, Gamma) ; q(N, State, relax, Value2) ), !,
						max_list([Value1, Value2], Value), asserta( v(N,State,Value,Gamma) :- !), !.