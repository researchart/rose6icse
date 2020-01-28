% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_qpk1.gms
% Created 28-Jul-2007 18:15:36 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(2*x1-2*x1*x1+2*x1*x2+3*x2-2*x2*x2));

% Define constraints 
F = set([]);
F=[F,-x1+x2<=1];
F=[F,x1-x2<=1];
F=[F,-x1+2*x2<=3];
F=[F,2*x1-x2<=3];
F=[F,0<=x1];
F=[F,0<=x2];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));

mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objective),-3, 1e-2);