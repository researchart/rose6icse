% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = binary(x)
%BINARY Overloaded

if isempty(x)
    x = [];
else
    error('BINARY can only be applied to SDPVAR objects or empty doubles');
end