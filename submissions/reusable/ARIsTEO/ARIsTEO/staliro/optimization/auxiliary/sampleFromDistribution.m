% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sampValue,sampProb] = sampleFromDistribution(distrib,lo,hi,n)
  sampProb = 1.0;
  r0 = rand(1);
  s = 0;
  j = 0;
  for i = 1:n
    s = s + distrib(i,1);
    if (s >= r0)
      sampProb = distrib(i,1);
      j = i;
      break;
    end
  end
 assert ( j > 0);
 assert ( j <= n);
 
 r1 = rand(1);
 delta = (hi - lo)/n;
 sampValue = lo + (j+r1-1) * delta; 
 
end
