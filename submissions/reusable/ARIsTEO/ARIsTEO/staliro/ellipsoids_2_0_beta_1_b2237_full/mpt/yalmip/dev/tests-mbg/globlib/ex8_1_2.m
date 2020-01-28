% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex8_1_2.gms
% Created 02-Aug-2007 11:01:55 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);

% Define objective function 

y = 10.8095222429746-4.21478541710781.*cos(x1-2.09439333333333);
z = 10.8095222429746-4.21478541710781.*cos(x1);
w = 10.8095222429746-4.21478541710781.*cos(x1+2.09439333333333);
sdpvar yy zz ww
objective = -(-(588600/power(yy,6)-1079.1/power(yy,3)+600800/power(zz,6)-1071.5/power(zz,3)+481300/power(ww,6)-1064.6/power(ww,3)));

% Define constraints 
F = set([]);
F=[F,0<=x1<=6.2832,y==yy,z==zz,w==ww];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),-1.053 , 1e-2);