% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = display(X)
% DISPLAY Overloaded

try
    X = sdpvar(X);
    display(X);
catch
    disp('Incomplete block variable.');
end
