% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function r=getsosrank(X)

% Author Johan Löfberg 
% $Id: getsosrank.m,v 1.1 2005-07-18 15:01:30 joloef Exp $  

try
    r = X.extra.rank;
catch
    r = inf;
end
  
  
      