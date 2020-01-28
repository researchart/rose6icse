% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_bpv1.gms
% Created 17-Mar-2008 10:59:26 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);

% Define objective function 
objective = -(-(x1*x3+x2*x4)+0-(0));

% Define constraints 
F = set([]);
F=[F,x1+3*x2>=30];
F=[F,2*x1+x2>=20];
F=[F,-1.6667*x3+x4>=10];
F=[F,x3+x4<=15];
F=[F,0<=x1<=27];
F=[F,0<=x2<=16];
F=[F,0<=x3<=10];
F=[F,0<=x4<=10];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), 10, 1e-2);