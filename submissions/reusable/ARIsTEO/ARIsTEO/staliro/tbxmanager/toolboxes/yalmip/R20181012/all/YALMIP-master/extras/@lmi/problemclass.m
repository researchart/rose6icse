% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function p = problemclass(F,h)
% PROBLEMCLASS Derives an optimization object and determines the class

if nargin < 2
    h = [];
end
[aux1,aux2,aux3,model] = export(F,h);
p = problemclass(model);
