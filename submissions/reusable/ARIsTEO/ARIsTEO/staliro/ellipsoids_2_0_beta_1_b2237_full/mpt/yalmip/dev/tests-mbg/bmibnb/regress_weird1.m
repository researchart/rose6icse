% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function regress_weird1

sdpvar x
sol = solvesdp(set(-pi < x < pi),2^sin(x),sdpsettings('solver','bmibnb'))
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(x), -pi/2, 1e-3);