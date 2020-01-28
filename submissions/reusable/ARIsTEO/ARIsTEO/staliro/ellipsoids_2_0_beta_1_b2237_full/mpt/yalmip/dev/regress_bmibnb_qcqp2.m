% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function fail = regress_bmibnb(ops)

x1 = sdpvar(1,1);
x2 = sdpvar(1,1);
x3 = sdpvar(1,1);
x4 = sdpvar(1,1);
x5 = sdpvar(1,1);
x6 = sdpvar(1,1);

objective = -25*(x1-2)^2-(x2-2)^2-(x3-1)^2-(x4-4)^2-(x5-1)^2-(x6-4)^2;

F = set((x3-3)^2+x4>4) + set((x5-3)^2+x6>4);
F = F + set(x1-3*x2<2) + set(-x1+x2<2) + set(x1+x2>2);
F = F + set(6>x1+x2>2);
F = F + set(1<x3<5) + set(0<x4<6)+set(1<x5<5)+set(0<x6<10)+set(x1>0)+set(x2>0);

sol = solvesdp(F,objective,ops);
fail=getfail(sol.problem,double(objective),-310,checkset(F));
   