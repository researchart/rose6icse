% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [Z,Q1,R] = sparsenull(A)

[Q,R] = qr(A');
n = max(find(sum(abs(R),2)));
Q1 = Q(:,1:n);
R = R(1:n,:);
Z = Q(:,n+1:end); % New basis