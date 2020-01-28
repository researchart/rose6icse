% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function algebraicmpc

% Test bilinearization functionality 
N = 2;
x = sdpvar(2*ones(1,N),ones(1,N));
u = sdpvar(  ones(1,N),ones(1,N));

F = set(-5 < [x{:}] <5) + set(-10 < [u{:}] < 10);
obj = 0;
Q = eye(2);R = 1/10;
h = 0.05;

A = [1 h;-h 1-2*0.3*h];
B = [0;h];
dd = binvar(2,N-1);
bounds([x{:}],-5,5);
bounds([u{:}],-10,10);
for i = 1:N-1
    obj = obj + x{i+1}'*Q*x{i+1} + u{i}'*R*u{i};  
     F = F + set(x{i+1} == A*x{i} + B*u{i} + [0;-h*x{i}(1)^3]);   
end

obj = obj + ([x{2}]'*[x{2}])^2;
        
xk = [2.5;1];
uk = [];
cost = 0;
ops =sdpsettings('solver','bmibnb','bmibnb.lpreduce',0,'bmibnb.maxiter',10,'debug',1,'bmibnb.upper','fmincon','bmibnb.root',1);
          
sol = solvesdp(F+set(-10 < x{1} < 10) + set(x{1} == xk(:,end)),obj,ops)
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 48.8272, 1e-3);

P1 = optimizer(F+set(-10 < x{1} < 10) ,obj,ops,x{1},u{1})
mbg_asserttolequal(P1{xk},-0.3307, 1e-3);

