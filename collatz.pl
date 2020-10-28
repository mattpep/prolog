odd(Current, Next) :-
	1 =:= mod(Current,2), Next is Current * 3 + 1.

even(Current, Next) :-
	0 =:= mod(Current,2), Next is Current / 2.

step(Current, Next, ThisStep) :-
	Current \= 1, odd(Current, Next), ThisStep = Current.

step(Current, Next, ThisStep) :-
	even(Current, Next), ThisStep = Current.

steps(Start, End, [H|T]) :-
	step(Start, Interim, H), steps(Interim, End, T).

steps(Start, End, [H|[]]) :-
	step(Start, End, H), End is 1.

solve(Start, Path) :-
	steps(Start, 1, Path).
