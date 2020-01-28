% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = sqrtm_internal(x)

if x>=0
    y = sqrt(x);
else
    y = -x.^2;
end
