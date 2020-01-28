% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sdp1

n = 50;
randn('seed',123456789);

A = randn(n);A = A - max(real(eig(A)))*eye(n)*1.5;
B = randn(n,1);
C = randn(1,n);

t = sdpvar(1,1);
P = sdpvar(n,n);

obj = t;
F = set(kyp(A,B,P,blkdiag(C'*C,-t)) < 0)

[Fp,objp,free] = primalize(F,-obj);

sol = solvesdp(Fp,objp,sdpsettings('removeequalities',1))

mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj),3.74980908287456, 1e-5);
