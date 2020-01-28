% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_gp_7

sdpvar x y;
sol = solvesdp([y^+.1+x^0.7<-1],x+y)
mbg_asserttolequal(sol.problem,1);

sdpvar x y;
sol = solvesdp([y^+.1+x^0.7<-1;x<-41],x+y)
mbg_asserttolequal(sol.problem,1);

sdpvar x y;
sol = solvesdp([y^+.1+x^0.7<-1;y.^1.1<-2],x+y)
mbg_asserttolequal(sol.problem,1);
