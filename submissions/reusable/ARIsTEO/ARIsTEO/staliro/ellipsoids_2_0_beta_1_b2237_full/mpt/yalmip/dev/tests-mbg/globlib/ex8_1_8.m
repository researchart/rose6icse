% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex8_1_8.gms
% Created 28-Jul-2007 17:52:19 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);
x6 = sdpvar(1);

% Define objective function 
objective = -(x4);

% Define constraints 
F = set([]);
F=[F,0.09755988*x1*x5+x1==1];
F=[F,0.0965842812*x2*x6+x2-x1==0];
F=[F,0.0391908*x3*x5+x3+x1==1];
F=[F,0.03527172*x4*x6+x4-x1+x2-x3==0];
F=[F,x5^0.5+x6^0.5<=4];
F=[F,0<=x1<=1];
F=[F,0<=x2<=1];
F=[F,0<=x3<=1];
F=[F,0<=x4<=1];
F=[F,1e-005<=x5<=16];
F=[F,1e-005<=x6<=16];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objective),-0.3888, 1e-3);