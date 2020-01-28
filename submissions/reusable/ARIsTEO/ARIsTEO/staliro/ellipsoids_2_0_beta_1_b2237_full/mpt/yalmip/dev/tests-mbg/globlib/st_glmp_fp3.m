% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_glmp_fp3.gms
% Created 06-Aug-2007 09:41:18 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);

% Define objective function 
objective = -(-x3*x4+0-(0));

% Define constraints 
F = set([]);
F=[F,2*x1+x2<=2];
F=[F,x1+x2<=2];
F=[F,-4*x1+x2<=12];
F=[F,-2*x1-x2<=6];
F=[F,-x1-2*x2<=6];
F=[F,x1-x2<=3];
F=[F,x1+x2-x3==0];
F=[F,x1-x2-x4==0];
F=[F,-10<=x1<=1];
F=[F,-10<=x2<=10];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -12, 1e-2);