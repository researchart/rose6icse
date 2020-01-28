% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function ex14_1_4

yalmip('clear');
sdpvar x1 x2 x3 objvar

F = set([]);

F = F + set(0.5*sin(x1*x2) - 0.5*x1 - 0.0795774703703634*x2 - x3 <= 0);
F = F + set(0.920422529629637*exp(2*x1) - 5.4365636*x1 + 0.865255957591193*x2 - x3 <= 2.5019678106022);
F = F + set(0.5*x1 - 0.5*sin(x1*x2) + 0.0795774703703634*x2 - x3 <= 0);
F = F + set(- x3 + objvar == 0);
F = F + set(5.4365636*x1 - 0.920422529629637*exp(2*x1) - 0.865255957591193*x2 - x3 <= -2.5019678106022); 

F = F + set(x1>= 0.25) + set(x1<= 1)+set(6.28 > x2 > 1.5);

sol = solvesdp(F,x3,sdpsettings('solver','bmibnb','bmibnb.upper','fmincon','allownon',1,'bmibnb.absgaptol',1e-8,'bmibnb.relgaptol',1e-8));
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double([objvar ]),0, 1e-4);
