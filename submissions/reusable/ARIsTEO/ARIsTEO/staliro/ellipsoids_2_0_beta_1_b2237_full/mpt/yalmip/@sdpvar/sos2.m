% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X=sos2(X)
%SOS Declare special ordered set of type 2
%
% F = sos(p)
%
% Input
%  p : SDPVAR object
% Output
%  F : CONSTRAINT object
%
% Example:
%  Typical usage is
%
%   F = sos(p)

% Author Johan L�fberg 
% $Id: sos2.m,v 1.8 2009-10-08 11:11:06 joloef Exp $  

X.typeflag = 50;
X = set(X);
