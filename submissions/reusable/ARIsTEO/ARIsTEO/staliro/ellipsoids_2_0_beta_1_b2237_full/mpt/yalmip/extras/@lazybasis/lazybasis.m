% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = lazybasis(n,m,i,j,s)

%sys.basis = basis;
sys.n = n;
sys.m = m;
sys.iX = i;
sys.jX = j;
sys.sX = s;
sys = class(sys,'lazybasis');
