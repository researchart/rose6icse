% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex9_2_5.gms
% Created 28-Jul-2007 17:54:49 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
objvar = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);
x6 = sdpvar(1);
x7 = sdpvar(1);
x8 = sdpvar(1);
x9 = sdpvar(1);

% Define constraints 
objvar = (x3-3)*(x3-3)+(x1-2)*(x1-2);
F = set([]);
F=[F,x1-2*x3+x4==1];
F=[F,-2*x1+x3+x5==2];
F=[F,2*x1+x3+x6==14];
F=[F,x4*x7==0];
F=[F,x5*x8==0];
F=[F,x6*x9==0];
F=[F,2*x1+x7-2*x8+2*x9==10];
F=[F,0<=x3<=8];
F=[F,0<=x4];
F=[F,0<=x5];
F=[F,0<=x6];
F=[F,0<=x7];
F=[F,0<=x8];
F=[F,0<=x9];

% Solve problem
x = recover(F);
sol = solvesdp(F,objvar,sdpsettings('solver','bmibnb','allownonconvex',1));
sol = solvesdp(F+[-100<x<100],objvar,sdpsettings('solver','bmibnb','allownonconvex',1))

mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objvar),5, 1e-2);