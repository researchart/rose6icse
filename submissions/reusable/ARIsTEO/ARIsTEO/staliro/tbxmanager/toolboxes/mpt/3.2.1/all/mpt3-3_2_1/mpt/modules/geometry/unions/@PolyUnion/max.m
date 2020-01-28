% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function out = max(PUs, func)
% Maxmimum of PolyUnions 'inPUs' using function 'func'

% the code is identical to PolyUnion/min, so just call it with a special
% flag
if nargin<2
	func = [];
end
coefficient = -1;
out = min(PUs, func, coefficient);
