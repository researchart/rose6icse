% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function v = getvectorvariables(X)

B = X.basis;
B(:,1)=[];
[i,j,k] = find(B');
v = X.lmi_variables(i);
