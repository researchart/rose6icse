% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function P = polytope(C)
%POLYTOPE (Overloaded)

P = polytope(lmi(C));