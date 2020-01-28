% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_e12.gms
% Created 21-Aug-2007 18:42:14 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);

% Define objective function 
objective = -(-(x1^0.6+x2^0.6-6*x1)+4*x3-3*x4+0-(0));

% Define constraints 
F = set([]);
F=[F,-3*x1+x2-3*x3==0];
F=[F,x1+2*x3<=4];
F=[F,x2+2*x4<=4];
F=[F,0<=x1<=3];
F=[F,0<=x2<=4];
F=[F,0<=x3<=2];
F=[F,0<=x4<=1];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -4.51420165136193, 1e-2);