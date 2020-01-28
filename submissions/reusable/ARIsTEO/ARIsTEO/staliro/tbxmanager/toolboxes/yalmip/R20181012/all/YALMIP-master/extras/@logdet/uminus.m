% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Z = uminus(P)
%display           Overloaded

Z = P;
Z.cx =  - Z.cx;
Z.gain = -Z.gain;
