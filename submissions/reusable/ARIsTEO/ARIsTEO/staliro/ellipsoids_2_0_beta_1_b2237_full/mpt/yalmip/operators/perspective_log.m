% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function z = perspective_log(x)
if isequal(x(1),[0])
    z = 0;
else
    z = x(1)*log(x(1)/x(2));
end