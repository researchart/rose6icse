% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function P = robustify(P)
%ROBUSTIFY  Derives robust counterpart.

[P.Constraints,P.Objective] = robustify(P.Constraints,P.Objective,P.Options);
