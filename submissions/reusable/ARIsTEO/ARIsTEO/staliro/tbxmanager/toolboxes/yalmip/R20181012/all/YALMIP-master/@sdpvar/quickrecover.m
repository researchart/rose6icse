% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = quickrecover(x,v,b);

x.lmi_variables = v;
x.conicinfo = [0 0];
if nargin == 3
    x.basis(2) = b;
end