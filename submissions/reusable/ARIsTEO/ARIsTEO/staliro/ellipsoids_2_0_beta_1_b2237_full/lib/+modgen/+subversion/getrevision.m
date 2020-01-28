% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function rev= getrevision(varargin)
rev=modgen.subversion.getrevisionbypath(fileparts(mfilename('fullpath')),varargin{:});
end