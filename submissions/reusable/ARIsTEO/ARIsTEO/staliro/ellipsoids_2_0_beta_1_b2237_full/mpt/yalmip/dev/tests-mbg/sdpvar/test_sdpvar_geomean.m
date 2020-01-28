% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_sdpvar_geomean

% Test real vector geomean, length == 2^n
randn('seed',1234);
rand('seed',1234);
A = randn(15,2);
b = rand(15,1)*5;
x = sdpvar(2,1);
obj = geomean(b-A*x);
solvesdp([],-obj);
mbg_asserttolequal(double(x'), [-0.05519469470525   0.26970610928222], 1e-5);
mbg_asserttolequal(double(obj), 1.83896843735621, 1e-5);

% Test real vector geomean, length == 2^n
randn('seed',1234);
rand('seed',1234);
A = randn(16,2);
b = rand(16,1)*5;
x = sdpvar(2,1);
obj = geomean(b-A*x);
solvesdp([],-obj);
mbg_asserttolequal(double(x'), [ -0.01148934254297  -0.20720944929269], 1e-5);
mbg_asserttolequal(double(obj), 1.93924577959868, 1e-5);

% Test real vector geomean, length == 1
randn('seed',1234);
rand('seed',1234);
A = randn(1,2);
b = rand(1,1)*5;
x = sdpvar(2,1);
obj = geomean(b-A*x);
sol = solvesdp([],-obj);
mbg_asserttolequal(sol.problem,2);

% Test real matrix geomean, length ~2^n
randn('seed',1234);
rand('seed',1234);
D = randn(5,5);
P = sdpvar(5,5);
obj = geomean(P);
solvesdp(set(P < D*D'),-obj);
mbg_asserttolequal(double(obj), 2.00333629658259, 1e-5);
 
% Test real matrix geomean, length == 2^n
randn('seed',1234);
rand('seed',1234);
D = randn(8,8);
P = sdpvar(8,8);
obj = geomean(P);
solvesdp(set(P < D*D'),-obj);
mbg_asserttolequal(double(obj), 3.32199302165511, 1e-5);

% Test real matrix geomean, length == 2
randn('seed',1234);
rand('seed',1234);
D = randn(2,2);
P = sdpvar(2,2);
obj = geomean(P);
solvesdp(set(P < D*D'),-obj);
mbg_asserttolequal(double(obj),  2.02896175488410, 1e-5);

% Test complex matrix geomean, length ~2^n
randn('seed',1234);
rand('seed',1234);
D = randn(5,5)+sqrt(-1)*randn(5,5);D = D + D'+eye(5)*10;
P = sdpvar(5,5,'he','co');
obj = geomean(P);
solvesdp(set(P < D),-obj);
mbg_asserttolequal(double(obj),9.07516376113709, 1e-5);
 
% Test complex matrix geomean, length == 2^n
randn('seed',1234);
rand('seed',1234);
D = randn(8,8)+sqrt(-1)*randn(8,8);D = D + D'+eye(8)*20;
P = sdpvar(8,8,'he','co');
obj = geomean(P);
solvesdp(set(P < D),-obj);
mbg_asserttolequal(double(obj), 18.42071980565500, 1e-5);
 











 
