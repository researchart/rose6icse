% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from sample.gms
% Created 28-Jul-2007 18:39:24 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);

% Define objective function 
objective = -(-x1-x2-x3-x4);

% Define constraints 
F = set([]);
F=[F,4/x1+2.25/x2+1/x3+0.25/x4<=0.0401];
F=[F,0.16/x1+0.36/x2+0.64/x3+0.64/x4<=0.010085];
F=[F,100<=x1<=400000];
F=[F,100<=x2<=300000];
F=[F,100<=x3<=200000];
F=[F,100<=x4<=100000];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));

mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objective),726.6783, 1e-2);