% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex9_2_3.gms
% Created 28-Jul-2007 18:01:27 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
objvar = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);
x6 = sdpvar(1);
x7 = sdpvar(1);
x8 = sdpvar(1);
x9 = sdpvar(1);
x10 = sdpvar(1);
x11 = sdpvar(1);
x12 = sdpvar(1);
x13 = sdpvar(1);
x14 = sdpvar(1);
x15 = sdpvar(1);
x16 = sdpvar(1);
x17 = sdpvar(1);

% Define constraints 
objvar = -3*x1-3*x2+2*x4+2*x5-60;

F = set([]);
F=[F,x1-2*x2+x4+x5<=40];
F=[F,2*x1-x4+x6==-10];
F=[F,2*x2-x5+x7==-10];
F=[F,-x1+x8==10];
F=[F,x1+x9==20];
F=[F,-x2+x10==10];
F=[F,x2+x11==20];
F=[F,x6*x12==0];
F=[F,x7*x13==0];
F=[F,x8*x14==0];
F=[F,x9*x15==0];
F=[F,x10*x16==0];
F=[F,x11*x17==0];
F=[F,2*x1-2*x4+2*x12-x14+x15==-40];
F=[F,2*x2-2*x5+2*x13-x16+x17==-40];
F=[F,0<=x4<=50];
F=[F,0<=x5<=50];
F=[F,0<=x6<=200];
F=[F,0<=x7<=200];
F=[F,0<=x8<=200];
F=[F,0<=x9<=200];
F=[F,0<=x10<=200];
F=[F,0<=x11<=200];
F=[F,0<=x12<=200];
F=[F,0<=x13<=200];
F=[F,0<=x14<=200];
F=[F,0<=x15<=200];
F=[F,0<=x16<=200];
F=[F,0<=x17<=200];

% Solve problem
sol = solvesdp(F,objvar,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objvar),0, 1e-2);
