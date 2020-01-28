% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_complexsdp2

h = [1 2 3 4]+sqrt(-1)*[4 3 2 1];

N=size(h,2);
A= sdpvar(N,N,'hermitian','complex');
F= set(-diag(A)==-1/N*ones(N,1));
F= F+set(A>=0);
obj= h*(eye(N)-A)*h';
options=sdpsettings('verbose',1);
solvesdp(F,obj,options);
R1=double(A);
cg1 = trace(R1*dual(F(2)));

y = sdpvar(N,1);
F2 = set(-h'*h - diag(y) > 0);
solvesdp(F2,-sum(y)/N)
R2 = dual(F2(1));
cg2 = trace(R2*double(F2(1)));

mbg_asserttrue(norm(R1-R2) < 1e-4)
mbg_asserttrue(cg1 < 1e-7)
mbg_asserttrue(cg2 < 1e-7)
