% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = double2sdpvar(varargin)
sys = sdpvar(1);
sys = struct(sys);
sys.dim = size(varargin{1});
sys.lmi_variables = [];
sys.basis = varargin{1}(:);
sys = sdpvar(sys);
