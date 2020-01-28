% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = vertcat(varargin)
%VERTCAT (overloaded)

% Author Johan L�fberg 
% $Id: vertcat.m,v 1.2 2006-08-11 11:48:15 joloef Exp $   

prenargin = nargin;
% Fast exit
if prenargin<2
    y=varargin{1};
    return
end

% Get dimensions
n = zeros(prenargin,1);
m = zeros(prenargin,1);
for i = 1:prenargin
    if isa(varargin{i},'blkvar')
        varargin{i} = sdpvar(varargin{i});
    end
    if isa(varargin{i},'sdpvar')
        varargin{i}= ncvar(struct(varargin{i}));
    end
    [n(i),m(i)]=size(varargin{i});
end

% Keep only non-empty
keep_these = find((n.*m)~=0);
if length(keep_these)<length(n)
    varargin = {varargin{keep_these}};
    n = n(keep_these);
    m = m(keep_these);
end;

% All widths should be equal
if any(m~=m(1))
    error('All rows in the bracketed expression must have the same number of columns.');
end

nblocks = size(varargin,2);
isasdpvar = zeros(nblocks,1);
% Get dimensions
for i = 1:nblocks
    isasdpvar(i) = isa(varargin{i},'ncvar');
end

% Find all free variables used
all_lmi_variables = [];
for i = 1:nblocks
    if isasdpvar(i)
        all_lmi_variables = [all_lmi_variables varargin{i}.lmi_variables];
    end
end
all_lmi_variables = uniquestripped(all_lmi_variables);

% Pick one of the sdpvar objects to build on...
y = varargin{min(find(isasdpvar))};

% Some indexation tricks...
basis_i = [];
basis_j = [];
basis_s = [];
m = m(1);
sumn=sum(n);
shift=[0;cumsum(n)];
for j = 1:nblocks
    if isasdpvar(j)
        in_this = find(ismembc(all_lmi_variables,varargin{j}.lmi_variables));
        dummy = [1 1+in_this];
        [i2,j2,s2] = find(varargin{j}.basis);
        j2 = dummy(j2);
    else
        [i2,j2,s2] = find(varargin{j}(:));
    end
    if ~isempty(j2)
    col = 1+floor((i2-1)/n(j));
    row = i2-(col-1)*n(j);
    basis_i = [basis_i;row(:)+shift(j)+sumn*(col(:)-1)];
    basis_j = [basis_j;j2(:)];
    basis_s = [basis_s;s2(:)];
    end
end
basis = sparse(basis_i,basis_j,basis_s,sum(n)*m,1+length(all_lmi_variables));

y.dim(1) = sum(n);
y.dim(2) = m;
y.basis = basis;
y.lmi_variables = all_lmi_variables;
% Reset info about conic terms
y.conicinfo = [0 0];

