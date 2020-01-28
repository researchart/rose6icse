% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function fail = regress_bmibnb_gamsrobot(ops)

x1 = sdpvar(1,1);
x2 = sdpvar(1,1);
F = set(0 < x1 < 6)+set(0 < x2 < 4) + set(x1*x2 < 4); 

obj = -x1-x2;

sol = solvesdp(F,obj,ops);

fail=getfail(sol.problem,double(obj),-6.6666,checkset(F));
   