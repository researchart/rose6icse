% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function see(X)
% SEE (overloaded)

disp('Constant matrix');disp(' ')
disp(full(getbasematrix(X,0)))
disp('Base matrices');disp(' ')
for i = 1:length(X.lmi_variables);
    disp(full(getbasematrix(X,X.lmi_variables(i))))
    disp(' ')
end;
disp('Used variables');disp(' ')
disp(X.lmi_variables)