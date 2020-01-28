% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function regress_weird3

sdpvar x
obj = sin(sin(x.^2) + x.^2)+0.01*x.^2-sin(x);
sol = solvesdp([-2*pi < x < 2*pi],obj,sdpsettings('allownonconvex',1,'solver','bmibnb'));

mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj),-1.734, 1e-3);