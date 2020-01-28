% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from wall.gms
% Created 21-Aug-2007 17:09:27 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
objvar = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);
x6 = sdpvar(1);

% Define constraints 

F = set([]);
F=[F,objvar*x2==1];
F=[F,x3 == 4.8*objvar*x4];
F=[F,x5==0.98*x2*x6];
F=[F,x6*x4==1];
F=[F,objvar-x2+1E-7*x3-1E-5*x5==0];
F=[F,2*objvar-2*x2+1E-7*x3-0.01*x4-1E-5*x5+0.01*x6==0];

% Solve problem
sol = solvesdp(F + [-10000 <= recover(F) <= 10000],objvar,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objvar),-1 , 1e-2);