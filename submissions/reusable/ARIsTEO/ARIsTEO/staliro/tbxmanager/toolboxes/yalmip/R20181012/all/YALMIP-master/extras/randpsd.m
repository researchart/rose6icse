% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Q = randpsd(n)

Q = randn(n);Q = Q*Q';