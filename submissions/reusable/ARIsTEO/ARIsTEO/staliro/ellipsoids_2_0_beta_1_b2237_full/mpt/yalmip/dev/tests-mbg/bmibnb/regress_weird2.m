% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function regress_weird2

clear sin % To avoid aby problems from code above
sdpvar x
strange = @(x) sdpfun(x,'@(x) sin(10*x)+abs(sin(x))+x');
sol = solvesdp(set(-pi < x < pi),strange(x),sdpsettings('solver','bmibnb'));

mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(strange(x)),-3.21, 1e-2);
clear sin
