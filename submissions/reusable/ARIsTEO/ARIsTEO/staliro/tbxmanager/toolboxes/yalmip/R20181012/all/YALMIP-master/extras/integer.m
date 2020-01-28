% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = integer(x)
%INTEGER Overloaded

if isempty(x)
    x = [];
else
    error('INTEGER can only be applied to SDPVAR objects or empty doubles');
end