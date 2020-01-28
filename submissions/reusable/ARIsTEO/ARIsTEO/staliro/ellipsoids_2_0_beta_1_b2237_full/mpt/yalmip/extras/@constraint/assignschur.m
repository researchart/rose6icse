% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function sys = assignschur(AConstraint,thecompiler,varargin)
% Author Johan Löfberg
% $Id: assignschur.m,v 1.1 2009-05-12 07:33:29 joloef Exp $

sys = assignschur(set(AConstraint),thecompiler,varargin{:})
