% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_iqpbk1.gms
% Created 06-Aug-2007 09:38:43 using YALMIP R20070725

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
objective = -(-(0.845*x1*x1+7*x1+0.5*x1*x2+6*x2+x1*x3+5*x3+1.5*x1*x4+4*x4+2*x1*x5+3*x5+2.5*x1*x6+2*x6+3*x1*x7+x7+3.5*x1*x8+0.5*x2*x1+0.845*x2*x2+0.5*x2*x3+x2*x4+1.5*x2*x5+2*x2*x6+2.5*x2*x7+3*x2*x8+x3*x1+0.5*x3*x2+0.845*x3*x3+0.5*x3*x4+x3*x5+1.5*x3*x6+2*x3*x7+2.5*x3*x8+1.5*x4*x1+x4*x2+0.5*x4*x3+0.845*x4*x4+0.5*x4*x5+x4*x6+1.5*x4*x7+2*x4*x8+2*x5*x1+1.5*x5*x2+x5*x3+0.5*x5*x4+0.845*x5*x5+0.5*x5*x6+x5*x7+1.5*x5*x8+2.5*x6*x1+2*x6*x2+1.5*x6*x3+x6*x4+0.5*x6*x5+0.845*x6*x6+0.5*x6*x7+x6*x8+3*x7*x1+2.5*x7*x2+2*x7*x3+1.5*x7*x4+x7*x5+0.5*x7*x6+0.845*x7*x7+0.5*x7*x8+3.5*x8*x1+3*x8*x2+2.5*x8*x3+2*x8*x4+1.5*x8*x5+x8*x6+0.5*x8*x7+0.845*x8*x8)+0-(0));

% Define constraints 
F = set([]);
F=[F,-x1+x2>=-1];
F=[F,-x2+x3>=-1.05];
F=[F,-x3+x4>=-1.1];
F=[F,-x4+x5>=-1.15];
F=[F,-x5+x6>=-1.2];
F=[F,-x6+x7>=-1.25];
F=[F,-x7+x8>=-1.3];
F=[F,-1<=x1<=1];
F=[F,-2.1<=x2<=2];
F=[F,-3.2<=x3<=3];
F=[F,-4.3<=x4<=4];
F=[F,-5.4<=x5<=5];
F=[F,-6.5<=x6<=6];
F=[F,-7.6<=x7<=7];
F=[F,-8.7<=x8<=8];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),-621.4878 , 1e-2);