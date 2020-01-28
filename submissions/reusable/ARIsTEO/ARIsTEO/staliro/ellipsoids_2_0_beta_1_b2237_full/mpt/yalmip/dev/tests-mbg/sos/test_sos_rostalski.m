% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sos_rostalski

% This test checks that YALMIP correcly detects
% a trivially infeasible SOS problem, when the 
% image model is used. for kernel model, the solver
% should fail, but doesn't due to numerical reasons

x=sdpvar(2,1);
p = x(1)^8+x(2)^7+x(1)*x(2);

axu=[1;1];
bxu=[1];
f=axu'*x+bxu
A=[ 1   0; 
-1   0; 
  0   1; 
  0 -1];
B=[1;1;1;1];
h=[A*x-B];

s = [];
F= set([]);
v= monolist(x,2); % all monomials of total degree<2

for i = 1:4; 
 c = sdpvar(length(v));
 s = [s v'*c*v]
 F = F + set(c>0);
end


sol = solvesos(set(sos(p-f+s*h))+F,[],sdpsettings('sos.model',2))

mbg_asserttolequal(sol.problem,2);
