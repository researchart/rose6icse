% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function sys = double2sdpvar(varargin)

% Author Johan Löfberg
% $Id: double2sdpvar.m,v 1.2 2006-08-15 14:44:03 joloef Exp $

sys = sdpvar(1);
sys = struct(sys);
sys.dim = size(varargin{1});
sys.lmi_variables = [];
sys.basis = varargin{1}(:);
sys = sdpvar(sys);
