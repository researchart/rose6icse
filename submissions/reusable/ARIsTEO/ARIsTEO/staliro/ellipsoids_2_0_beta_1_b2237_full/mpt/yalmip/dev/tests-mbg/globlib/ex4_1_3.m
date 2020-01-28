% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex4_1_3.gms
% Created 28-Jul-2007 18:50:55 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);

% Define objective function 
objective = -(-(8.9248e-5*x1-0.0218343*sqr(x1)+0.998266*POWER(x1,3)-1.6995*POWER(x1,4)+0.2*POWER(x1,5)));

% Define constraints 
F = set([]);
F=[F,0<=x1<=10];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1))
mbg_asserttrue(sol.problem == 0);
mbg_asserttolequal(double(objective), -4.43672e2, 1e-2);