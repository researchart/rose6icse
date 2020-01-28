% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = assignschur(AConstraint,thecompiler,varargin)

sys = assignschur(lmi(AConstraint),thecompiler,varargin{:})
