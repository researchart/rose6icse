% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function r=getsosrank(X)

try
    r = X.extra.rank;
catch
    r = inf;
end
  
  
      