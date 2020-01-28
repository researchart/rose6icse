% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from house.gms
% Created 17-Mar-2008 09:59:39 using YALMIP R20070810

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
objective = -x7-x8-0-(0);

% Define constraints 
F = set([]);
F=[F,-(x1*x2+x5*x4)+x7==0];
F=[F,-x1*x3+x8==0];
F=[F,-x2-x5+x6==0];
F=[F,x1-0.333333333333333*x4>=0];
F=[F,x1-0.5*x4<=0];
F=[F,x2*(x4-x1)>=1500];
F=[F,-0.5*x2+x3-x5==0];
F=[F,-0.5*x2+x5>=0];
F=[F,40<=x4<=68];
F=[F,56<=x6<=100];
F=[F,x7<=3000];

% Solve problem
sol = solvesdp(F+set(-5000<recover(depends(F))<5000),objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -4500, 1e-2);