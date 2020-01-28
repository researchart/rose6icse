% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = powerinternalhelper(d,x);

y = [];
for i = 1:prod(size(d))
    y = [y x(i).^d(i)];
end
y = reshape(y,size(d));