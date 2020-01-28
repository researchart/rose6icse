% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function F = display(X)
% DISPLAY Overloaded

% Author Johan Löfberg
% $Id: display.m,v 1.2 2005-05-25 16:14:25 joloef Exp $

try
    X = sdpvar(X);
    display(X);
catch
    disp('Incomplete block variable.');
end
