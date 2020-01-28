% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = semicont(x)
%SEMICONT Constrains variables to be semi-continuous 
%
%   F = SEMICONT(x) is used to posteriori constrain 
%   variables to be semi-continuous, in contrast to SEMIVAR 
%   that declares variables as semi-continuous a priori.
%
%   INPUT
%    x : SDPVAR object
%
%   OUTPUT
%    F : Constraint object
%
%   See also BINARY, SDPVAR, INTVAR, BINVAR

x.typeflag = 52;
x = lmi(x);