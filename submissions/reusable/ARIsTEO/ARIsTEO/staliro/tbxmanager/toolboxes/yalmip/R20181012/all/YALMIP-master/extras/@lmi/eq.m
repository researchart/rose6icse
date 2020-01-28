% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = eq(X,Y)
%EQ Overloaded

dX = binvar(1);
dY = binvar(1);
sys = [iff(dX,X), iff(dY,Y), dX == dY];
