% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function P = polyhedron(C)
%POLYHEDRON (Overloaded)

P = Polyhedron(lmi(C));