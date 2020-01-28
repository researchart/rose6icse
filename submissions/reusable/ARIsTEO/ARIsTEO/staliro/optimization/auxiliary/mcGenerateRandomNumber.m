% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% mcGenerateRandomNumber - 

% (C) 2010 Sriram Sankaranarayanan - University of Colorado

function r = mcGenerateRandomNumber(a,b,dispL)

r0 = dispL-2*dispL*rand(1,1);

if (r0 > 1.0)
 r0=0.99;
end

if (r0 < -1.0)
 r0 = -0.99;
end

if (r0 >= 0.0)
  r = a * r0;
else
  r = -b * r0;
end

end
