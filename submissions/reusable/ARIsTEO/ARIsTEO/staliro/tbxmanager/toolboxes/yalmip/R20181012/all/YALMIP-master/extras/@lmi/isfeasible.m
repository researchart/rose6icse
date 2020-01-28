% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [feasible,feaslistLMI] = isfeasible(F,tol)

if nargin == 1
    tol = 0;
end
feaslistLMI = checkset(F);
feasible = all(feaslistLMI >= -tol);
