% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Z = conj(Y)
%CONJ (overloaded)

Z = Y;
Z.basis = conj(Z.basis);
% Reset info about conic terms
Z.conicinfo = [0 0];