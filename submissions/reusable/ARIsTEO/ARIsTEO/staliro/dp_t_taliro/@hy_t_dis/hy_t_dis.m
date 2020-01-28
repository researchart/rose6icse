% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% hy_t_dis class: Instantiates hy_t_dis objects for time robustness
% computations.
% 
% USAGE:
%   [obj,aux] = hy_t_dis
%       Create an empty hy_t_dis object
%
%   [obj,aux] = hy_t_dis(A)
%   where: 
%       A is numeric: generate time robustness where the first component 
%         is zero and the second component is A      

% (C) 2012 by Hengyi Yang 
% Last update: 2013.1.28

function [obj,aux] = hy_t_dis(varargin)

if nargin==0
    obj = struct('pt',{[]},'ft',{[]});
    aux = struct('most_related_iteration',{[]}, 'most_related_predicate_index',{[]});
elseif nargin==1 && isnumeric(varargin{1})
    s_in = size(varargin{1});
    if length(s_in)==2 && max(max(varargin{1}==0))
        obj = struct('pt',zeros(s_in),'ft',zeros(s_in));
    elseif length(s_in)==2 && max(max(varargin{1}==inf))
        obj = struct('pt',inf(s_in),'ft',inf(s_in));
    elseif length(s_in)==2 && max(max(varargin{1}==-inf))
        obj = struct('pt',-inf(s_in),'ft',-inf(s_in));
    else
        obj = struct('pt',zeros(s_in),'ft',varargin{1});
    end
elseif nargin==1 && isa(varargin{1},'hy_t_dis')
    obj = varargin{1};
    return
elseif nargin==1 && isa(varargin{1},'struct')
     if min(isfield(varargin{1}, {'pt'; 'ft'; 'most_related_iteration'; 'most_related_predicate_index'}))
         if min(size(varargin{1}.pt)==size(varargin{1}.ft))
             obj = struct('pt',varargin{1}.pt,'ft',varargin{1}.ft);
             aux = struct('i',varargin{1}.most_related_iteration,'pred',varargin{1}.most_related_predicate_index);
         else
          error('hy_t_dis: This is not a valid input structure: fielft "pt" and "ft" do not have the same size!')
         end
     elseif min(isfield(varargin{1}, {'ft'; 'pt'}))
        if min(size(varargin{1}.pt)==size(varargin{1}.ft))
            obj = struct('pt',varargin{1}.pt,'ft',varargin{1}.ft);
        else
          error('hy_t_dis: This is not a valid input structure: fielft "pt" and "ft" do not have the same size!')
        end
    else
        error('hy_t_dis: This is not a valid input structure: field "pt" or "ft" is missing!')
    end
elseif nargin==2
    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && min(size(varargin{1})==size(varargin{2}))
        obj = struct('pt',varargin{1},'ft',varargin{2});
    else
        error('hy_t_dis: The inputs should be numeric arrays of the same size!')
    end
else
    error('hy_t_dis: Invalid input arguments')
end
%obj = class(obj, 'hy_t_dis');
superiorto('double')
end

