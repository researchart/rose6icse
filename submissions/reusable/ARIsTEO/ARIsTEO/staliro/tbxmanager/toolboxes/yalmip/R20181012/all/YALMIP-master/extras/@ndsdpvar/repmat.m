% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Y=repmat(varargin)
%REPMAT (overloaded)

Y = varargin{1};
dim = Y.dim;
resize = [varargin{2:end}];
index = (1:size(Y.basis,1))';
index = reshape(index,Y.dim);
index = repmat(index,resize);
Y.basis = Y.basis(index(:),:);
Y.dim = size(index);
Y = flush(Y);
% Reset info about conic terms
Y.conicinfo = [0 0];
