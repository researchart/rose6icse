% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  P = linearize(P)
%LINEARIZE Linearize constraints and objective around current solution
%
%   P = LINEARIZE(P)

P.Objective = linearize(P.Objective);
P.Constraints = linearize(P.Constraints);

