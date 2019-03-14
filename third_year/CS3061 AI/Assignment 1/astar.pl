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

astar(Node,Path,Cost,KB) :- Frontier = [[[Node],0]], astarr(Frontier, Path, Cost, KB).

astarr(Frontier, FinalPath, FinalCost, KB) :- Frontier = [PathCost|PathCostRest], PathCost = [Path,Cost], 
	(goal(Path), FinalPath = Path, FinalCost = Cost ;
	findall(PathCostL, arc(PathCost,PathCostL, KB), List),
	add-to-frontier(PathCostRest, List, NewFrontier),
	astarr(NewFrontier, FinalPath, FinalCost, KB)). 
	
goal([[]|_]). 

%Arc predicate, takes a PathCost pair, the knowledge base and the next PathCost pair connect to the first via the KB
%Takes the head of the current node in the path of the Pathcost pair and looks in the KB for a proposition
% or rule that starts with that head. With the body of the rule, create a new Node by appending it 
%to the rest of the current Node and updates the path and cost to form the new pathcost pair.
%In this case, the cost is just the basic arc cost of 1 for each new node.
arc([[[HeadNode|TailNode]|PathHistory],Cost], NewPathCost, KB) :- 
			member([HeadNode|RuleBody], KB), append(RuleBody,TailNode, NextNode),
			length(RuleBody, L), LengthCost is L + 1,
			TotalCost is Cost + LengthCost, NewPathCost = [[NextNode,[HeadNode|TailNode]|PathHistory],TotalCost]. 

%Arc predicate with Cost being Heuristic + arc Cost
%arc([[[HeadNode|TailNode]|PathHistory],Cost], NewPathCost, KB) :- 
%			member([HeadNode|RuleBody], KB), append(RuleBody,TailNode, NextNode),
%			heuristic(RuleBody, H), NextCost is H+1, TotalCost is NextCost + Cost, 
%			NewPathCost = [[NextNode,[HeadNode|TailNode]|PathHistory],TotalCost]. 


%The heuristic for Astar with propositional knowledge base is just a function of the length of the current Node.
heuristic(Node, H) :- length(Node, H).
	
%Add-to-frontier predicate takes the current set of frontier node, the new arc node and the resulting new frontier
%from adding the first two variables.
%The frontier is always sorted according to Astar cost function	
add-to-frontier(Frontier, [], Frontier).
add-to-frontier(Frontier, [PathCost|Rest], NewFrontier) :-
	insert(PathCost, Frontier, FrontierResult),
	add-to-frontier(FrontierResult, Rest, NewFrontier).


%Insert predicate, takes a PathCost, a list of PathCost and the resulting list of PathCost after insertion
%The list is always sorted according to the cost function used by Astar, uses the 'less-than' predicate to sort
%the elements
insert(PathCost, [], [PathCost]).
insert(PathCost, [PathCostH|PathCostT1], Res) :-
	(less-than(PathCost, PathCostH), Res = [PathCost, PathCostH|PathCostT1] ;
	Res = [PathCostH|PathCostT2], insert(PathCost, PathCostT1, PathCostT2)).

%Less-than predicate, takes two PathCost pair and succeeds
%when the first Node1 has a smaller or equal value then the 
%second Node2 according to the cost function used by Astar which
%combines the cost of a Path and its heuristic
%F(Node) = Cost(Node) + Heuristic(Node)
less-than([[Node1|_],Cost1], [[Node2|_],Cost2]) :-
	heuristic(Node1, H1), heuristic(Node2, H2),
	F1 is Cost1 + H1, F2 is Cost2 + H2,
	F1 =< F2.