% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex14_2_6.gms
% Created 02-Aug-2007 10:39:52 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x6 = sdpvar(1);

% Define objective function 
objective = -(0-x6-0);

% Define constraints 
F = set([]);
F=[F,8.85*log(2.11*x1+3.19*x2+0.92*x3)-9.85*log(1.97*x1+2.4*x2+1.4*x3)-(3.7136*x2-0.865100000000001*x1-4.8952*x3)/(2.11*x1+3.19*x2+0.92*x3)-0.92*log(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+0.92*log(0.92*x1+2.4*x2+x3)-0.92*(0.92*x1/(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+3.53361528312402*x2/(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+1.21383720135623*x3/(1.11673022524774*x1+0.00499065620537111*x2+x3))-3803.98/(231.47+x4)-x6<=-12.8590236275375];
F=[F,11*log(2.11*x1+3.19*x2+0.92*x3)-12*log(1.97*x1+2.4*x2+1.4*x3)-(5.6144*x2-1.3079*x1-7.4008*x3)/(2.11*x1+3.19*x2+0.92*x3)-2.4*log(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+2.4*log(0.92*x1+2.4*x2+x3)-2.4*(0.0460854387520165*x1/(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+2.4*x2/(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+0.0020794400855713*x3/(1.11673022524774*x1+0.00499065620537111*x2+x3))-2788.51/(220.79+x4)-x6<=-11.1728763302021];
F=[F,6*log(2.11*x1+3.19*x2+0.92*x3)-7*log(1.97*x1+2.4*x2+1.4*x3)-(1.6192*x2-0.3772*x1-2.1344*x3)/(2.11*x1+3.19*x2+0.92*x3)-log(1.11673022524774*x1+0.00499065620537111*x2+x3)+log(0.92*x1+2.4*x2+x3)-(0.293449394138336*x1/(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+1.69874317415203*x2/(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+x3/(1.11673022524774*x1+0.00499065620537111*x2+x3))-3816.44/(227.02+x4)-x6<=-13.2058768767024];
F=[F,9.85*log(1.97*x1+2.4*x2+1.4*x3)-8.85*log(2.11*x1+3.19*x2+0.92*x3)+(3.7136*x2-0.865100000000001*x1-4.8952*x3)/(2.11*x1+3.19*x2+0.92*x3)+0.92*log(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)-0.92*log(0.92*x1+2.4*x2+x3)+0.92*(0.92*x1/(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+3.53361528312402*x2/(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+1.21383720135623*x3/(1.11673022524774*x1+0.00499065620537111*x2+x3))+3803.98/(231.47+x4)-x6<=12.8590236275375];
F=[F,12*log(1.97*x1+2.4*x2+1.4*x3)-11*log(2.11*x1+3.19*x2+0.92*x3)+(5.6144*x2-1.3079*x1-7.4008*x3)/(2.11*x1+3.19*x2+0.92*x3)+2.4*log(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)-2.4*log(0.92*x1+2.4*x2+x3)+2.4*(0.0460854387520165*x1/(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+2.4*x2/(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+0.0020794400855713*x3/(1.11673022524774*x1+0.00499065620537111*x2+x3))+2788.51/(220.79+x4)-x6<=11.1728763302021];
F=[F,7*log(1.97*x1+2.4*x2+1.4*x3)-6*log(2.11*x1+3.19*x2+0.92*x3)+(1.6192*x2-0.3772*x1-2.1344*x3)/(2.11*x1+3.19*x2+0.92*x3)+log(1.11673022524774*x1+0.00499065620537111*x2+x3)-log(0.92*x1+2.4*x2+x3)+0.293449394138336*x1/(0.92*x1+0.120222883700913*x2+0.31896673275906*x3)+1.69874317415203*x2/(1.35455252519754*x1+2.4*x2+0.707809655896681*x3)+x3/(1.11673022524774*x1+0.00499065620537111*x2+x3)+3816.44/(227.02+x4)-x6<=13.2058768767024];
F=[F,x1+x2+x3==1];
F=[F,1e-006<=x1<=1];
F=[F,1e-006<=x2<=1];
F=[F,1e-006<=x3<=1];
F=[F,40<=x4<=90];
F=[F,0<=x6];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),0 , 1e-2);