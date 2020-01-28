% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function misdp

% Test two regression bugs
% 1. quadratic costs in binary SDP
% 2. OR on SDP constraints

X = sdpvar(3,3);
obj = trace((X-2*eye(3))*(X-2*eye(3))');
sol = solvesdp(set (X<3*eye(3)) + set((X>eye(3)) | (X<-eye(3))) + set(-50 < X(:) < 50),obj)

mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 0, 1e-5);

