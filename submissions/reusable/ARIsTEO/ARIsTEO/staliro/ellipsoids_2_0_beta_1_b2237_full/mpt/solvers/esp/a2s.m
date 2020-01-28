% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [A,b] = a2s(H)

if(isempty(H))
  A = [];
  b = [];
else
  A = H(:,1:end-1);
  b = H(:,end);
end;

