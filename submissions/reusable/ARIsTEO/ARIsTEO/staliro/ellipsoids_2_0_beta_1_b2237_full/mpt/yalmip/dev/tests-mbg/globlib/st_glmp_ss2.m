% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_glmp_ss2.gms
% Created 06-Aug-2007 09:39:34 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);

% Define objective function 
objective = -(-x4*x5-x3+0-(0));

% Define constraints 
F = set([]);
F=[F,x1-2*x2<=100];
F=[F,-x1-2*x2<=100];
F=[F,-x1+2*x2>=5];
F=[F,-x1+2*x2<=8];
F=[F,x1+2*x2<=12];
F=[F,x1-x3==0];
F=[F,2*x1-3*x2-x4==-13];
F=[F,x1+x2-x5==1];
F=[F,0<=x1<=7];
F=[F,0<=x2<=6];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), 3, 1e-2);