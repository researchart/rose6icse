% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function mpt_paramcost_1

B = [-1  1  1  1  0  0  0  0  0  0;
      1  0  0  0  1 -1  1  0  0  0;
      0 -1  0  0  0  0  0  1 -1  1;
      0  0 -1  0 -1  1  0 -1  1  0
      0  0  0 -1  0  0 -1  0  0 -1]

c = [3.1 2.3 1.2  12.3 2.5 9.6 2.1 6.8 2.1 2.2]';
d = [4.2 7.4 14.7 9.7  1.0 3.1 5.1 2.2 5.9 6.7]';
b = [size(B,1)-1;-ones(4,1)];

t = sdpvar(1,1);
x = sdpvar(10,1);
F = set(0 <= t <= 1) + set(B*x == b) + set(0 <= x <= 10)

[SOL, DIAGNOSTIC,Z,HPWF,ZPWF] = solvemp(F,(t*c+(1-t)*d)'*x,sdpsettings('debug',1),t)

assign(t,0.38);
cost = double(HPWF);

mbg_asserttolequal(cost,43.8,0.0001);


