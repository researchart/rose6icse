% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function f = deadhub(p,lambda)

f = -(invsathub(p,lambda)-lambda*abs(p));


