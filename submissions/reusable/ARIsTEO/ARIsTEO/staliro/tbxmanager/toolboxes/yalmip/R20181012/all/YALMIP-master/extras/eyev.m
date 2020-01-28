% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function ei=eyev(n,i)
%EYEV Internal function to generate unit vector

if i>n
  disp('Error in eyev')
  return
  else
ei = zeros(n,1);ei(i)=1;
end;

