% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Z = minus(P)
%display           Overloaded

% Author Johan L�fberg 
% $Id: uminus.m,v 1.1 2004-06-17 08:40:09 johanl Exp $  

Z = P;
Z.cx =  - Z.cx;
Z.gain = -Z.gain;
