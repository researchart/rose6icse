% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_robot.gms
% Created 28-Jul-2007 18:17:16 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);
x6 = sdpvar(1);
x7 = sdpvar(1);
x8 = sdpvar(1);

% Define objective function 
objective = -(0);

% Define constraints 
F = set([]);
F=[F,0.004731*x1*x3-0.1238*x1-0.3578*x2*x3-0.001637*x2-0.9338*x4+x7==0.3571];
F=[F,0.2238*x1*x3+0.2638*x1+0.7623*x2*x3-0.07745*x2-0.6734*x4-x7==0.6022];
F=[F,x6*x8+0.3578*x1+0.004731*x2==0];
F=[F,-0.7623*x1+0.2238*x2==-0.3461];
F=[F,POWER(x1,2)+POWER(x2,2)==1];
F=[F,POWER(x3,2)+POWER(x4,2)==1];
F=[F,POWER(x5,2)+POWER(x6,2)==1];
F=[F,POWER(x7,2)+POWER(x8,2)==1];
F=[F,-1<=x1<=1];
F=[F,-1<=x2<=1];
F=[F,-1<=x3<=1];
F=[F,-1<=x4<=1];
F=[F,-1<=x5<=1];
F=[F,-1<=x6<=1];
F=[F,-1<=x7<=1];
F=[F,-1<=x8<=1];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));

mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objective),0, 1e-2);