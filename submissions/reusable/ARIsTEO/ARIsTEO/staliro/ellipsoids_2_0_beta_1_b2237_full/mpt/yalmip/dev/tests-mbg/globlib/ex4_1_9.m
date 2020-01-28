% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex4_1_9.gms
% Created 28-Jul-2007 18:55:16 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
objvar = sdpvar(1);

% Define constraints 
objvar = -x1-x2;
F = set([]);
%F=[F,x1+x2+objvar==0];
F=[F,8*POWER(x1,3)-2*POWER(x1,4)-8*sqr(x1)+x2<=2];
F=[F,32*POWER(x1,3)-4*POWER(x1,4)-88*sqr(x1)+96*x1+x2<=36];
F=[F,0<=x1<=3];
F=[F,0<=x2<=4];

% Solve problem
sol = solvesdp(F,objvar,sdpsettings('solver','bmibnb','allownonconvex',1));

mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objvar), -5.508, 1e-2);