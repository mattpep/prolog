% This is some prolog code to solve puzzles in the Android app "Calculator: The
% Game" and its many clones, such as the webapp https://calculator-game-reactjs.vercel.app/
%
% It is entirely unaffiliated with the Android app and derivatives.
%
% I've completed the Android version but decided to write this prolog code in
% an attempt to improve my prolog knowledge.
%
% To spell it out: If you use this code to get past levels you are only doing
% yourself a disservice.
%
% Code released without license – do what you want, I don't care.

% insert plain digits
digits_key(In, Digits, Out) :-
	Digits < 10,
	Out is In * 10 + Digits.

digits_key(In, Digits, Out) :-
	Digits >= 10, Digits < 100,
	Out is In * 100 + Digits.

digits_key(In, Digits, Out) :-
	Digits >= 100, Digits < 1000,
	Out is In * 1000 + Digits.

% 4 basic operators
add_quantity(In, Q, Out) :- Out is In + Q.

sub_quantity(In, Q, Out) :- Out is In - Q.

mul_quantity(In, Q, Out) :-
	In \= 0,
	Out is In * Q.

div_quantity(In, Q, Out) :- Out is In / Q.

negate(In, Out) :- Out is 0 - In.

% lrotate
% 123 -> 312
lrot(In, Out) :-
	number_chars(In, [H|T]),
	append(T,[H], Combined),
	number_chars(Out, Combined).

% rrotate
% 123 -> 231
rrot(In, Out) :-
	number_chars(In, Digits),
	reverse(Digits, [Last|StemRev]),
	reverse(StemRev, Stem),
	append([Last], Stem, Combined),
	number_chars(Out, Combined).

% right shift
% 123 -> 12,  12345 -> 1234
rshift(In, Out) :-
	In > 0, In >= 10,
	number_chars(In, LHS),
	reverse(LHS, [_|Interim]),
	reverse(Interim, Truncated),
	number_chars(Out, Truncated).

% reverse (but we can't call it 'reverse' because there is a built-in called reverse/2
% abcde -> edcba
rev(In, Out):-
	number_chars(In, X),
	reverse(X, Y),
	number_chars(Out, Y).

% mirror: abcde -> abcdeedcba
mirror(In, Out) :-
	number_chars(In, LHS),
	reverse(LHS, RHS),
	append(LHS, RHS, Combined),
	number_chars(Out, Combined).

% sum: 1234 -> 1+2+3+4=10,  21326 -> 13
digit_sum([], 0).
digit_sum([H], H).
digit_sum([H|T], Sum) :-
	length(T, Len), Len > 0,
	digit_sum(T, Interim),
	Sum is Interim + H.
sum(In, Out) :-
	number_codes(In,X),
	maplist(plus(48), Digits, X),
	digit_sum(Digits, Out).

% inv10: 123 -> 987,  0 -> 0, 5->5
s10([], []).
s10([HIn|TIn], [HOut|TOut]) :-
	HIn is 0,
	HOut is 0,
	s10(TIn, TOut).

s10([HIn|TIn], [HOut|TOut]) :-
	HIn > 0,
	HOut is 10 - HIn,
	s10(TIn, TOut).

inv10(In, Out) :-
	number_codes(In,X), maplist(plus(48), Digits, X), s10(Digits, Inverted), maplist(plus(48), Inverted, Z),  number_codes(Out, Z).


cube(In, Out) :-
	Out is In * In * In.

square(In, Out) :-
	Out is In * In.

 % this has many names: subsitute, change (unfortunately 'c' and 's' are both used)
replace(Old, New, Orig, Replaced) :-
    atomic_list_concat(Split, Old, Orig),
    atomic_list_concat(Split, New, Replaced).

       	% (HIn =:= 0 -> HOut is 0 ) ; HOut is 10 - HIn . s10(TIn, TOut).
% s10([HIn|TIn], [HOut|TOut]) :- HIn > 0, HOut is 10 - HIn, s10(TIn, TOut).
% s10([HIn|TIn], [HOut|TOut]) :- HIn =:= 0, HOut is 0, s10(TIn, TOut).
% Button encoding:
%  A list, where each element is a string from the following:
%  d1, d10, d-5 :   plain digits key (1, 10, -5)
%  +1, +10, /5, *-3 numbers with operators (self explanatory)
%  r39,93   r15,00  replace 39 with 93,  or 15 with 00
%  >                right shift
%  v                reverse (we don't say 'r', because that's the first letter of the word 'right' and so would be ambiguous)
%  m                mirror
%  i                invert10
%  n                negate (plus/minus)
%  q                square
%  c                cube
%  s                sum
%
%
% TODO: replacements, memory, alter_buttons, cube, left shift, square
%
% simple digits (possibly more than one, e.g. 1, 4, 10, 23)
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|ValueStr]), atom_string(OpTypeA, OpType),
	OpType =:= "d", number_string(Value, ValueStr),  digits_key(Current, Value, Next),
	MoveMade = Button.

% basic operators +, -, /, *
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|ValueStr]), atom_string(OpTypeA, OpType),
	OpType =:= "+", number_string(Value, ValueStr),  add_quantity(Current, Value, Next),
	MoveMade = Button.

step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|ValueStr]), atom_string(OpTypeA, OpType),
	OpType =:= "-", number_string(Value, ValueStr),  sub_quantity(Current, Value, Next),
	MoveMade = Button.

step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|ValueStr]), atom_string(OpTypeA, OpType),
	OpType =:= "/", number_string(Value, ValueStr),  div_quantity(Current, Value, Next),
	MoveMade = Button.

step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|ValueStr]), atom_string(OpTypeA, OpType),
	OpType =:= "*", number_string(Value, ValueStr),  mul_quantity(Current, Value, Next),
	MoveMade = Button.

% right shift
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|_]), atom_string(OpTypeA, OpType),
	OpType =:= ">", rshift(Current, Next),
	MoveMade = Button.

% reverse
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|_]), atom_string(OpTypeA, OpType),
	OpType =:= "v", rev(Current, Next),
	MoveMade = Button.

% mirror
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|_]), atom_string(OpTypeA, OpType),
	OpType =:= "m", mirror(Current, Next),
	MoveMade = Button.

% negate:  5 -> -5
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|_]), atom_string(OpTypeA, OpType),
	OpType =:= "n", negate(Current, Next),
	MoveMade = Button.

% invert10
step(Current, Next, MoveMade, Buttons) :-
	member(Button, Buttons),  string_chars(Button, [OpTypeA|_]), atom_string(OpTypeA, OpType),
	OpType =:= "i", inv10(Current, Next),
	MoveMade = Button.


% terminating condition
solve(Start, Target, _, _, _):-
	Start =:= Target.

% solver-entry point
solve(Start, Target, [H|T], MovesLeft, Buttons):-
	MovesLeft >= 1, Target \= Start, step(Start, Intermediate, H, Buttons), solve(Intermediate, Target, T, MovesLeft-1, Buttons).

tests :-
	solve(0, 111, M0, 3, ['d1']),                  %
	solve(0, 20, M1, 3, ['+4', '*4']),             % 4
	solve(0, 40, M2, 4, ['+2', '*4']),             % 5
	solve(100,10, M3, 4, ['+3', '/5']),            % 6
	solve(171, 23, M4, 5, ['>', '-9', '*2']),      % 10
	solve(0, 321, M5, 3, ['d1', 'd23', 'v']),      %
	solve(55, 13, M6, 4, ['>', 'n', '+9']),        % 47
	solve(0, 123, M7, 7, ['+3','-2','d1' ]). % 68
