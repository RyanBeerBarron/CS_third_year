pterm(null).
pterm(f0(X)) :- pterm(X).
pterm(f1(X)) :- pterm(X).

%part 1
incr(f1(null), f0(f1(null))).
incr(f0(X), f1(X)).
incr(f1(X),f0(Y)) :- incr(X,Y).
					  

%part 2
%legal(f0(null)).
%legal(X) :- legalAlt(X).
%legalAlt(f1(null)).
%legalAlt(f1(X)):-legalAlt(X).
%legalAlt(f0(X)):-legalAlt(X).

legal(f0(null)).
legal(X) :- legal(Y),
			incr(Y,X).

incR(X,Y) :- legal(X),
			 incr(X,Y).

%part 3
add(X,f0(null),X).
add(f0(null),X,X).
add(X,Y,Z):- incr(A,X),
			 incr(Y,B),
			 add(A,B,Z).

%part 4
mult(X,f0(null),f0(null)).
mult(X,f1(null),X).
mult(f0(null),X,f0(null)).
mult(f1(null),X,X).
mult(A,B,C):-incr(X,A),
			 mult(X,B,Y),		 
			 add(Y,B,C).

%part 5
revers(null,null).
revers(X,Y):-reversAlt(X,null,Y).

reversAlt(null,X,X).
reversAlt(f0(X),Y,Z):-reversAlt(X,f0(Y),Z).
reversAlt(f1(X),Y,Z):-reversAlt(X,f1(Y),Z).

%part 6
normalize(null, f0(null)).
normalize(X, Y):-legal(Y),
				 revers(X,A),
				 removeZero(A,B),
				 revers(B,C),
				 legal(C).

removeZero(f1(X),f1(X)).
removeZero(f0(X),Y):-removeZero(X,Y).

% test add inputting numbers N1 and N2
testAdd(N1,N2,T1,T2,Sum,SumT) :- numb2pterm(N1,T1), numb2pterm(N2,T2),
add(T1,T2,SumT), pterm2numb(SumT,Sum).

% test mult inputting numbers N1 and N2
testMult(N1,N2,T1,T2,N1N2,T1T2) :- numb2pterm(N1,T1), numb2pterm(N2,T2),
mult(T1,T2,T1T2), pterm2numb(T1T2,N1N2).
% test revers inputting list L
testRev(L,Lr,T,Tr) :- ptermlist(T,L), revers(T,Tr), ptermlist(Tr,Lr).
% test normalize inputting list L
testNorm(L,T,Tn,Ln) :- ptermlist(T,L), normalize(T,Tn), ptermlist(Tn,Ln).
% make a pterm T from a number N
numb2term(+N,?T)
numb2pterm(0,f0(null)).
numb2pterm(N,T) :- N>0, M is N-1, numb2pterm(M,Temp), incr(Temp,T).
% make a number N from a pterm T pterm2numb(+T,?N)
pterm2numb(null,0).
pterm2numb(f0(X),N) :- pterm2numb(X,M), N is 2*M.
pterm2numb(f1(X),N) :- pterm2numb(X,M), N is 2*M +1.
% reversible ptermlist(T,L)
ptermlist(null,[]).
ptermlist(f0(X),[0|L]) :- ptermlist(X,L).
ptermlist(f1(X),[1|L]) :- ptermlist(X,L).