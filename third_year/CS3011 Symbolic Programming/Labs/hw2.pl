

















s1 --> s1(_).
s1(Count) --> ublock(Count,0), vblock(Count).

ublock(Count,Acc) --> [1], ublock(Count,Acc).
ublock(Count,Acc) --> [0], {NewAcc is Acc + 1}, ublock(Count,NewAcc).
ublock(X,X) --> [2].

vblock(0) --> [].
vblock(Count) --> [0], vblock(Count).
vblock(Count) --> [1], {NewCount is Count - 2}, vblock(NewCount). 






















s2 --> col(Col1),nat(Nat1),pet(Pet1),col(Col2),nat(Nat2),pet(Pet2),col(Col3),nat(Nat3),pet(Pet3), 
	{Col1 \= Col2, Col2 \= Col3, Col1 \= Col3},
	{Nat1 \= Nat2, Nat2 \= Nat3, Nat1 \= Nat3},
	{Pet1 \= Pet2, Pet2 \= Pet3, Pet1 \= Pet3}.

col(Colour) --> {lex(Colour,colour)}, [Colour].
nat(Nationality) --> {lex(Nationality,nationality)}, [Nationality].
pet(Pet) --> {lex(Pet,pet)}, [Pet].

lex(red,colour).
lex(green,colour).
lex(blue,colour).
lex(english,nationality).
lex(japanese,nationality).
lex(spanish,nationality).
lex(jaguar,pet).
lex(snail,pet).
lex(zebra,pet).




















/*
s3(0) --> [].
s3(Sum) --> [H], s3(Newsum), {H \= [], Sum is Newsum + H}.

%p(Sum, Element) :- member(Element, L), mkList(Sum, L).
%s3(Sum) --> [M], s3(Newsum), {Sum is Newsum+M, member(M,List), mkList(Sum,M)}.

%sumList(0, []).
%sumList(Sum, [H|T]). 
*/




s3(0) --> [].
s3(Sum) --> {mkList(Sum,L), member(M,L)}, [M], {Newsum is Sum - M}, s3(Newsum).

mkList(0,[]).
mkList(X,[H|T]) :- X=H, NewX is X-1, NewX >= 0, mkList(NewX, T). 

member(H,[H|_]).
member(X,[_|T]) :- member(X,T).





















