% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function gp

x=sdpvar(1,1);
y=sdpvar(1,1);
t=x/y;
F=set(t>0.5);
F=F+set(y<2);
F=F+set(y>1);
obj=x^2*y^3;
F=F+set(t<=1);
F=F+set(t>=1);
F=F+set(y^2<4);

sol = solvesdp(F,obj);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj),1,1e-4);
mbg_asserttolequal(double([x y t]), [1 1 1], 1e-4);

sol = solvesdp(F,1/obj);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj),32,1e-4);
mbg_asserttolequal(double([x y t]), [2 2 1], 1e-4);


x=sdpvar(1,1);
y=sdpvar(1,1);
t=x/y;
F=set(t>0.5);
F=F+set(y<2);
F=F+set(y>1);
obj=x^2*y^3;
F=F+set(t<=1);
F=F+set(t>=1);
F=F+set(y^2.5<4);

sol = solvesdp(F,obj);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj),1,1e-5);
mbg_asserttolequal(double([x y t]), [1 1 1], 1e-4);

sol = solvesdp(F,1/obj);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj),16,1e-5);
mbg_asserttolequal(double([x y t]), [1.74110112659225   1.74110112659225   1.00000000000000], 1e-4);