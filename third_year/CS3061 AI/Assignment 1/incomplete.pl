:- dynamic(kb/1).

makeKB(File):- open(File,read,Str),
               readK(Str,K), 
               reformat(K,KB), 
               asserta(kb(KB)), 
               close(Str).                  
   
readK(Stream,[]):- at_end_of_stream(Stream),!.
readK(Stream,[X|L]):- read(Stream,X),
                      readK(Stream,L).

reformat([],[]).
reformat([end_of_file],[]) :- !.
reformat([:-(H,B)|L],[[H|BL]|R]) :- !,  
                                    mkList(B,BL),
                                    reformat(L,R).
reformat([A|L],[[A]|R]) :- reformat(L,R).
    
mkList((X,T),[X|R]) :- !, mkList(T,R).
mkList(X,[X]).

initKB(File) :- retractall(kb(_)), makeKB(File).

astar(Node,Path,Cost) :- kb(KB), astar(Node,Path,Cost,KB).

goal([[]|_]).

arc([[[Head|Tail1]|History],Cost1], NewPathCost, KB) :- member([Head|Tail2], KB), append(Tail2,Tail1, NextProp), append([Head|Tail1], History, NewHistory),
			length(Tail2, L), TempCost is L+1, Cost is TempCost + Cost1, NewPathCost = [[NextProp,NewHistory],Cost]. 

add-to-frontier(Frontier, [], Frontier).
add-to-frontier(Frontier, [PathCost|Rest], NewFrontier) :-
	insert(PathCost, Frontier, TempFrontier),
	add-to-frontier(TempFrontier, Rest, NewFrontier).

insert(PathCost, [], [PathCost]).

insert(PathCost, [PathCostH|PathCostT1], Res) :- PathCost = [_,Cost1], PathCostH = [_,Cost2],
	(Cost1 =< Cost2, Res = [PathCost, PathCostH|PathCostT1] ;
	Res = [PathCostH|PathCostT2], insert(PathCost, PathCostT1, PathCostT2)).
	 

astar(Node,Path,Cost,KB) :- Frontier = [[[Node],0]], astarr(Frontier, KB, End), End = [[Path,Cost]|_].

astarr(Frontier, KB, End) :- Frontier = [H1|_], H1 = [Path|_], goal(Path), Frontier = End;
	Frontier = [PathCost|PathCostRest],
	PathCost = [Path,Cost], Path = [Current|History],
	findall(PathCostL, arc(PathCost,PathCostL, KB), List),
	add-to-frontier(PathCostRest, List, NewFrontier),
	astarr(NewFrontier, KB, End).
	

	
