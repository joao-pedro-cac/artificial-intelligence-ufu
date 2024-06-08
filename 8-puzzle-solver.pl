% RESOLUÇÃO DO JOGO DO 8
% 
% Cada combinação de blocos do tabuleiro é retratada através de uma lista de 3 listas.
% O espaço vazio é representado pelo caractere 'x'
%
% EX: O tabuleiro abaixo é representado por [[x,8,3], [4,5,1], [2,7,6]]
%
%          x 8 3
%          4 5 1
%          2 7 6
%
% O objetivo do quebra-cabeça é ordená-lo para o estado abaixo:
%
%          1 2 3
%          4 5 6
%          7 8 x

%----------------------------------------------------------------------------------------------------

% BEST-PATH SEARCH (A* Algorithm)
best_path_search(AnsPath) :-
	initial_state(Init),value(Init,V),
	best_path([[V,V,Init]],AnsPath),
	print_answer(AnsPath),
	print_length(AnsPath).

best_path([[_,_,S|Path]|_],AnsPath) :-
	final_state(S),!,
	reverse([S|Path],[],AnsPath).
best_path([Path|Rest],AnsPath) :-
	expand_best_path(Path,NPaths),
	merge(NPaths,Rest,NewList),
	best_path(NewList,AnsPath).

expand_best_path([C,V,S|Path],NPaths) :-
	setof([C1,V1,S1,S|Path],
	(extend([S|Path],S1),
		recost(S,C,V,S1,C1,V1)),NPaths),!.
expand_best_path(_,[]).

recost(S,C,V,S1,C1,V1) :-
	value(S1,V1),cost(S,S1,D),
	C1 is C - V + D + V1.

%----------------------------------------------------------------------------------------------------

% BEST-COST SEARCH
best_cost_search(AnsPath) :-
	initial_state(Init),
	best_cost([[0,Init]],AnsPath),
	print_answer(AnsPath),
	print_length(AnsPath).

best_cost([[_,S|Path]|_],AnsPath) :-
	final_state(S),!,
	reverse([S|Path],[],AnsPath).
best_cost([Path|Rest],AnsPath) :-
	expand_best_cost(Path,NPaths),
	merge(NPaths,Rest,NewList),
	best_cost(NewList,AnsPath).

expand_best_cost([C,S|Path],NPaths) :-
	setof([C1,S1,S|Path],
	(extend([S|Path],S1),
		costsum(S,C,S1,C1)),NPaths),!.
expand_best_cost(_,[]).

costsum(S,C,S1,C1) :-
	cost(S,S1,D), C1 is C + D.

%----------------------------------------------------------------------------------------------------

% BEST-FIRST SEARCH
best_first_search(AnsPath) :-
	initial_state(Init),value(Init,V),
	best_first([[V,Init]],AnsPath),
	print_answer(AnsPath),
	print_length(AnsPath).

best_first([[_,S|Path]|_],AnsPath) :-
	final_state(S),!,
	reverse([S|Path],[],AnsPath).
best_first([Path|Rest],AnsPath) :-
	expand_best_first(Path,NPaths),
	merge(NPaths,Rest,NewList),
	best_first(NewList,AnsPath).

expand_best_first([_|Path],NPaths) :-
	setof([V,S|Path],
	(extend(Path,S),value(S,V)),NPaths),!.
	expand_best_first(_,[]).

merge([],L,L) :- !.
merge(L,[],L) :- !.
merge([X|P],[Y|Q],[X|R]) :-
	less(X,Y),!,merge(P,[Y|Q],R).
merge(L,[Y|Q],[Y|R]) :-
	merge(L,Q,R).

less([V1|_],[V2|_]) :- V1 < V2.

%----------------------------------------------------------------------------------------------------

% HILL-CLIMBING SEARCH
hill_climbing_search(AnsPath) :-
	initial_state(Init),
	hill_climb([Init],AnsPath),
	print_answer(AnsPath),
	print_length(AnsPath).

hill_climb([S|_],[S]) :-
	final_state(S),!.
hill_climb([S|Path],[S|AnsPath]) :-
	extend_hill_climb([S|Path],S1),
	hill_climb([S1,S|Path],AnsPath).

extend_hill_climb([S|Path],S1) :-
	best_next_state(S,S1),
	not(is_member(S1,[S|Path])).

best_next_state(S,S1) :-
	setof((V,NS),(mov(S,NS),value(NS,V)),List),
	is_member((_,S1),List).

%----------------------------------------------------------------------------------------------------

% BREADTH-FIRST SEARCH (BFS)
breadth_first_search(AnsPath) :-
	initial_state(Init),
	breadth_first([[Init]|Q]-Q,AnsPath),
	print_answer(AnsPath),
	print_length(AnsPath).

breadth_first(Q-Qt,AnsPath) :-
	is_queue_member([S|Path],Q-Qt),final_state(S),!,
	reverse([S|Path],[],AnsPath).
breadth_first([Path|Q]-Qt,AnsPath) :-
	expand(Path,Qt-Qs),
	breadth_first(Q-Qs,AnsPath).

expand(Path,Queue) :-
	setof([S|Path],extend(Path,S),List),!,
	list_to_queue(List,Queue).
expand(_,Q-Q).

% extend is given in depth-first search below

is_queue_member(X,[Y|Q]-Qt) :-
	nonvar(Y),
	(X = Y; is_queue_member(X,Q-Qt)).

list_to_queue(L,Q-Qt) :-
	append(L,Qt,Q).

append([],L,L).
append([H|T],L,[H|R]) :- append(T,L,R).

reverse([], L, L).
reverse([H|T], L, R) :- reverse(T, [H|L], R).

%----------------------------------------------------------------------------------------------------

% DEPTH-FIRST SEARCH (DFS)
depth_first_search(AnsPath) :-
	initial_state(Init),
	depth_first([Init], AnsPath),
	print_answer(AnsPath),
	print_length(AnsPath).

depth_first([S|_],[S]) :-
	final_state(S), !.
depth_first([S|Path], [S|AnsPath]) :-
	extend([S|Path], S1),
	depth_first([S1, S|Path], AnsPath).

extend([S|Path], S1) :-
	mov(S, S1),
	not(is_member(S1, [S|Path])).

%----------------------------------------------------------------------------------------------------

% ESTADOS
initial_state([[1,2,3], [4,5,x], [7,8,6]]).    % Inicial (MUDAR CONFORME PROBLEMA INICIAL)
final_state([[1,2,3], [4,5,6], [7,8,x]]).      % Final

%----------------------------------------------------------------------------------------------------

% MOVIMENTOS POSSIVEIS
% Canto Superior Esquerdo
mov([[x,A,B], [C,D,E], [F,G,H]], [[A,x,B], [C,D,E], [F,G,H]]).
mov([[x,A,B], [C,D,E], [F,G,H]], [[C,A,B], [x,D,E], [F,G,H]]).

% Canto Superior Direito
mov([[A,B,x], [C,D,E], [F,G,H]], [[A,x,B], [C,D,E], [F,G,H]]).
mov([[A,B,x], [C,D,E], [F,G,H]], [[A,B,E], [C,D,x], [F,G,H]]).

% Canto Inferior Esquerdo
mov([[A,B,C], [D,E,F], [x,G,H]], [[A,B,C], [x,E,F], [D,G,H]]).
mov([[A,B,C], [D,E,F], [x,G,H]], [[A,B,C], [D,E,F], [G,x,H]]).

% Canto Inferior Direito
mov([[A,B,C], [D,E,F], [G,H,x]], [[A,B,C], [D,E,F], [G,x,H]]).
mov([[A,B,C], [D,E,F], [G,H,x]], [[A,B,C], [D,E,x], [G,H,F]]).

% Meio Superior
mov([[A,x,B], [C,D,E], [F,G,H]], [[x,A,B], [C,D,E], [F,G,H]]).
mov([[A,x,B], [C,D,E], [F,G,H]], [[A,B,x], [C,D,E], [F,G,H]]).
mov([[A,x,B], [C,D,E], [F,G,H]], [[A,D,B], [C,x,E], [F,G,H]]).

% Meio Esquerdo
mov([[A,B,C], [x,D,E], [F,G,H]], [[x,B,C], [A,D,E], [F,G,H]]).
mov([[A,B,C], [x,D,E], [F,G,H]], [[A,B,C], [D,x,E], [F,G,H]]).
mov([[A,B,C], [x,D,E], [F,G,H]], [[A,B,C], [F,D,E], [x,G,H]]).

% Meio Inferior
mov([[A,B,C], [D,E,F], [G,x,H]], [[A,B,C], [D,E,F], [x,G,H]]).
mov([[A,B,C], [D,E,F], [G,x,H]], [[A,B,C], [D,x,F], [G,E,H]]).
mov([[A,B,C], [D,E,F], [G,x,H]], [[A,B,C], [D,E,F], [G,H,x]]).

% Meio Direito
mov([[A,B,C], [D,E,x], [F,G,H]], [[A,B,x], [D,E,C], [F,G,H]]).
mov([[A,B,C], [D,E,x], [F,G,H]], [[A,B,C], [D,x,E], [F,G,H]]).
mov([[A,B,C], [D,E,x], [F,G,H]], [[A,B,C], [D,E,H], [F,G,x]]).

% Centro
mov([[A,B,C], [D,x,E], [F,G,H]], [[A,x,C], [D,B,E], [F,G,H]]).
mov([[A,B,C], [D,x,E], [F,G,H]], [[A,B,C], [x,D,E], [F,G,H]]).
mov([[A,B,C], [D,x,E], [F,G,H]], [[A,B,C], [D,G,E], [F,x,H]]).
mov([[A,B,C], [D,x,E], [F,G,H]], [[A,B,C], [D,E,x], [F,G,H]]).


%----------------------------------------------------------------------------------------------------

% MISCELÂNEOS
% Pertencimento a uma lista
is_member(X,[X|_]).
is_member(X,[_|T]) :- is_member(X,T).


% Cálculo do valor total de um estado do tabuleiro (quadrado da distância entre o ponto atual e o destino)
value(Game, Value) :-
	coords(1, Game, R1, C1), coords(2, Game, R2, C2), coords(3, Game, R3, C3),
	coords(4, Game, R4, C4), coords(5, Game, R5, C5), coords(6, Game, R6, C6),
	coords(7, Game, R7, C7), coords(8, Game, R8, C8), coords(x, Game, Rx, Cx),
	destiny(1, Rf1, Cf1), destiny(2, Rf2, Cf2), destiny(3, Rf3, Cf3),
	destiny(4, Rf4, Cf4), destiny(5, Rf5, Cf5), destiny(6, Rf6, Cf6),
	destiny(7, Rf7, Cf7), destiny(8, Rf8, Cf8), destiny(x, Rfx, Cfx),
	D1 is (Rf1 - R1) ** 2 + (Cf1 - C1) ** 2,                                    % Distância do bloco 1
	D2 is (Rf2 - R2) ** 2 + (Cf2 - C2) ** 2,                                    % Distância do bloco 2
	D3 is (Rf3 - R3) ** 2 + (Cf3 - C3) ** 2,                                    % Distância do bloco 3
	D4 is (Rf4 - R4) ** 2 + (Cf4 - C4) ** 2,                                    % Distância do bloco 4
	D5 is (Rf5 - R5) ** 2 + (Cf5 - C5) ** 2,                                    % Distância do bloco 5
	D6 is (Rf6 - R6) ** 2 + (Cf6 - C6) ** 2,                                    % Distância do blooc 6
	D7 is (Rf7 - R7) ** 2 + (Cf7 - C7) ** 2,                                    % Distância do bloco 7
	D8 is (Rf8 - R8) ** 2 + (Cf8 - C8) ** 2,                                    % Distância do bloco 8
	Dx is (Rfx - Rx) ** 2 + (Cfx - Cx) ** 2,                                    % Distância do espaço vazio
	Value is D1 + D2 + D3 + D4 + D5 + D6 + D7 + D8 + Dx.


% O custo de qualquer movimento é semelhante e pode ser considerado como 1
cost(_,_,1).


% Coordenadas atuais -> coords(ELEMENTO, TABULEIRO, LINHA, COLUNA).
coords(X, [[X,_,_], _, _], 0, 0).
coords(X, [[_,X,_], _, _], 0, 1).
coords(X, [[_,_,X], _, _], 0, 2).

coords(X, [_, [X,_,_], _], 1, 0).
coords(X, [_, [_,X,_], _], 1, 1).
coords(X, [_, [_,_,X], _], 1, 2).

coords(X, [_, _, [X,_,_]], 2, 0).
coords(X, [_, _, [_,X,_]], 2, 1).
coords(X, [_, _, [_,_,X]], 2, 2).


% Coordenadas finais -> destiny(ELEMENTO, LINHA, COLUNA).
destiny(1, 0, 0).
destiny(2, 0, 1).
destiny(3, 0, 2).
destiny(4, 1, 0).
destiny(5, 1, 1).
destiny(6, 1, 2).
destiny(7, 2, 0).
destiny(8, 2, 1).
destiny(x, 2, 2).


% Obtém o tamanho do resultado
list_length([], 0).
list_length([_|Rest], X) :-
	list_length(Rest, Y),
	X is 1 + Y.


% Imprime o estado
print_answer([]) :- nl.
print_answer([State|Rest]) :-
	write(State), nl,
	print_answer(Rest).


% Imprime o tamanho do resultado
print_length(Answer) :-
	list_length(Answer, Size),
	Steps is Size - 1,
	write('No. movimentos: '),
	write(Steps), nl.
