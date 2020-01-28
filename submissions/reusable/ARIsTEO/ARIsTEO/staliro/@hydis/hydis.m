% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% hydis class: Instantiates hydis objects for hybrid distance robustness
% computations.
% 
% USAGE:
%   obj = hydis
%       Create an empty hydis object
%
%   obj = hydis(A)
%   where: 
%       A is numeric: generate hybrid disatnces where the first component 
%         is zero and the second component is A      

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function obj = hydis(varargin)

if nargin==0 
    obj = struct('dl',{[]},'ds',{[]});
elseif nargin==1 && isnumeric(varargin{1})
    s_in = size(varargin{1});
    if min(s_in)==0
        obj = struct('dl',{zeros(s_in)},'ds',{zeros(s_in)});
    elseif length(s_in)==2 && max(max(varargin{1}==0))
        obj = struct('dl',zeros(s_in),'ds',zeros(s_in));
    elseif length(s_in)==2 && max(max(varargin{1}==inf))
        obj = struct('dl',inf(s_in),'ds',inf(s_in));
    elseif length(s_in)==2 && max(max(varargin{1}==-inf))
        obj = struct('dl',-inf(s_in),'ds',-inf(s_in));
    else
        obj = struct('dl',zeros(s_in),'ds',varargin{1});
    end
elseif nargin==1 && isa(varargin{1},'hydis')
    obj = varargin{1};
    return
elseif nargin==1 && isa(varargin{1},'struct')
    if min(isfield(varargin{1}, {'ds'; 'dl'}))
        if min(size(varargin{1}.dl)==size(varargin{1}.ds))
            obj = struct('dl',varargin{1}.dl,'ds',varargin{1}.ds);
        else
          error('hydis: This is not a valid input structure: fields "dl" and "ds" do not have the same size!')
        end
    else
        error('hydis: This is not a valid input structure: field "dl" or "ds" is missing!')
    end
elseif nargin==2
    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && min(size(varargin{1})==size(varargin{2}))
        obj = struct('dl',varargin{1},'ds',varargin{2});
    else
        error('hydis: The inputs should be numeric arrays of the same size!')
    end
else
    error('hydis: Invalid input arguments')
end
obj = class(obj, 'hydis');
superiorto('double')
end

