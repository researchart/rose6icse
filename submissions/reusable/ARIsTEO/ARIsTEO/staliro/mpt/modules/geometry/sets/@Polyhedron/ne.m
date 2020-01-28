% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function tf = ne(P, S)
% EQUAL Test if the polyhedron are not equal.
%
% ------------------------------------------------------------------
% tf = P.neq(S) or P ~= S
% 
% Param
%  S - polyhedron
%
% Returns true if S is not equal to this polyhedron, false otherwise.


tf = ~eq(P,S);

end