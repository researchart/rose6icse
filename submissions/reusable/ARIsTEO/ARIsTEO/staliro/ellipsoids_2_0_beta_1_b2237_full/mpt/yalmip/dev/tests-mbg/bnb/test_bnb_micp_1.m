% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function micp

randn('seed',123456);
n = 5;
%  65.63177408018771   6.95052852960134 -58.66230788287043 -70.86445052912004  58.37564024957875
%  17.58996579270265  65.53001366712473  18.43985990767680 -58.43579533652219 -72.32340882851518
% -46.45728349558073  15.51300078651673  68.32913865172714  18.82218749426777 -57.90310836270277
% -79.19194296790369 -53.92234161527504  21.23787385808123  65.53955212353939  17.48548000466040
%  51.25486176425121 -73.14184210768217 -50.35188380380193  19.83022901147247  67.22698658022694
P = toeplitz(randn(n,1)*100)+randn(n,n)*5;
Z = intvar(n,n,'toeplitz');
t = sdpvar(n,n,'full');
e = P(:)-Z(:);
ops = sdpsettings('solver','bnb','verbose',2);

F = set(-t < P-Z < t);
obj = sum(sum(t));
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 66.18236738983525, 1e-5);

F = set([]);
obj = norm(e,1);
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 66.18236738983525, 1e-5);

obj = e'*e;
F = set([]);
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 3.352603490492911e+002, 1e-5);

t = sdpvar(1,1);
obj = t;
F = set(cone(e,t));
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 18.31011603130778, 1e-5);

t = sdpvar(1,1);
obj = norm(e);
F = set([]);
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 18.31011603130778, 1e-5);

obj = t;
F = set([t e';e eye(length(e))]>0);
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 3.352603420494530e+002, 1e-5);

