% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% dp_t_taliro_casting class: Instantiates dp_t_taliro_casting objects
% for time robustness and best iteration and best predicate
% computations.
% 
% USAGE:
%
%   [obj,aux] = dp_t_taliro_casting(A)
%   where: 
%       A is struct: generate time robustness and
%       auxiliary information when the struct consists 
%       of most_related_iteration, most_related_predicate_index,
%       past time robustness and future time robustness.
       
% (C) 2012 by Hengyi Yang 
% Last update: 2013.01.27

function [obj,aux] = dp_t_taliro_casting(varargin)


if nargin==1 && isa(varargin{1},'struct')
     if min(isfield(varargin{1}, {'most_related_iteration'; 'most_related_predicate_index'; 'pt'; 'ft'}))
         if min(size(varargin{1}.pt)==size(varargin{1}.ft))
             obj = struct('pt',varargin{1}.pt,'ft',varargin{1}.ft);
             aux = struct('i',varargin{1}.most_related_iteration,'pred',varargin{1}.most_related_predicate_index);
         else
          error('hy_t_dis: This is not a valid input structure: fields "pt" and "ft" do not have the same size!')
         end
    else
        error('hy_t_dis: This is not a valid input structure: field "pt" or "ft" is missing!')
     end
else
    error('Wrapup: Invalid input arguments')
end

end