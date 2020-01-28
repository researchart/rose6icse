% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [M,R] = computeLyap(A,w)

options=sdpsettings('verbose',[0]);

[m,n] = size(A);

P = sdpvar(m);
F = (P>eye(m))+(A'*P+P*A<-eye(m)*eps);
% F = set(P>eye(m))+set(A'*P+P*A<-eye(m)*eps); % set is an obsolete command
% F = set(P>0)+set(A'*P+P*A<-eye(m)*eps);
% solvesdp(F,-[0 0 1 0]*P*[0 0 1 0]');
% solvesdp(F,-[1 1 1 1]*P*[1 1 1 1]');

% verify_bench
% solvesdp(F,-[1 1 0 0]*P*[1 1 0 0]',options);

% solvesdp(F,-[ 1 1]*P*[1 1]');

% verifyha
% solvesdp(F,-[1 0]*P*[1 0]',options);

% solvesdp(F,-[ 0 1]*P*[0 1]');

solvesdp(F,-w*P*w',options);

M = double(P);
[V,D] = eig(M,'nobalance');
R = sqrtm(D)*V';

