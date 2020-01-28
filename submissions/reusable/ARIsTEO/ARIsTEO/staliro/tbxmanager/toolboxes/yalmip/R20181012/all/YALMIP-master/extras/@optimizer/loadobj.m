% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function P = loadobj(P)
if isstruct(P),
    P = class(P,'optimizer');
end