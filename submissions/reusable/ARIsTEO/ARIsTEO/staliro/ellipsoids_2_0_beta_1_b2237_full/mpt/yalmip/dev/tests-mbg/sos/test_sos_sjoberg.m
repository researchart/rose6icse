% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_sos_sjoberg

% Regression for a problem in getexponentbase
% that caused issues in matrix sos

sdpvar x1 x2 
x = [x1 x2]';

f = [x2;
     -0.5*x1-0.5*x1^3-0.5*x2];

g = [0; 0.5];
h = x1;

gam = 1.52;      

% V = sum (c_i * x^something)
z = monolist(x,4);
c = sdpvar(length(z),1);
V = c'*z;

Vx = jacobian(V,x)

HJI = [Vx*f + f'*Vx.' + h'*h, 1/gam*Vx*g;
       1/gam*g'*Vx.' -1]
   
[sol,m,B,residuals] = solvesos( set(sos(-HJI)),[],[],c);
residual = norm(getbase(replace(-HJI-m{1}'*B{1}*m{1},c,double(c))),'inf')

mbg_asserttrue(residual < 1e-8);
