% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function pos = findhash(T,t,dummy)

if isempty(T)
    pos = []; % Random warnings on 6.1
else
    pos = find(T==t);
end
    